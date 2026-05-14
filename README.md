# FeatureSearchAppStore Module

Clean Architecture + MVVM 환경에서 App 타겟이 SPM 모듈로 의존하는 형태를 전제로 만든 App Store 검색 피처 모듈입니다.
이 모듈은 **App Store 검색 목록과 상세 정보 표시** 역할에 집중하며, 네트워크·저장소 구현체를 직접 알지 않고 **AppDomain UseCase Protocol + CoordinatorProtocol + Factory** 계층으로 역할을 분리합니다.

모듈 내부는 검색 목록 화면과 상세 화면을 포함하며,
상위 계층은 `SearchAppStoreFactory.makeSearchAppStoreListView(...)`, `SearchAppStoreFactory.makeSearchAppStoreDetailView(...)`를 통해 완성된 View를 즉시 사용할 수 있습니다.

**요약**
- 화면 조립 진입점: `SearchAppStoreFactory`
- 화면 이동 계약: `SearchAppStoreCoordinatorProtocol`
- 검색 목록 화면: `SearchAppStoreListView` + `SearchAppStoreListViewModel` + `SearchAppStoreListViewState`
- 상세 화면: `SearchAppStoreDetailView` + `SearchAppStoreDetailViewModel` + `SearchAppStoreDetailViewState`
- AppDomain 의존: `SearchAppStoreListUseCaseProtocol`, `SearchAppStoreDetailUseCaseProtocol`, 도메인 Entity, `SearchAppStoreDomainError`
- Core UI 의존: `DesignSystem` (토큰), `UIComponents` (`RemoteImageView`, `EmptyStateView`, `ErrorStateView`, `BackButton`)
- 이미지 프리패치: List 화면에서 다음 3개 항목 아트워크를 `onAppear` 시점에 미리 적재

---

**모듈 구조**
```text
FeatureSearchAppStore/
├─ Package.swift
├─ Sources/
│  └─ FeatureSearchAppStore/
│     ├─ Coordinator/
│     │  └─ SearchAppStoreCoordinatorProtocol.swift
│     ├─ Factory/
│     │  └─ SearchAppStoreFactory.swift
│     └─ Scenes/
│        ├─ SearchAppStoreList/
│        │  ├─ View/
│        │  │  └─ SearchAppStoreListView.swift
│        │  └─ ViewModel/
│        │     ├─ SearchAppStoreListViewModel.swift
│        │     └─ SearchAppStoreListViewState.swift
│        └─ SearchAppStoreDetail/
│           ├─ View/
│           │  └─ SearchAppStoreDetailView.swift
│           └─ ViewModel/
│              ├─ SearchAppStoreDetailViewModel.swift
│              └─ SearchAppStoreDetailViewState.swift
└─ Tests/
   └─ FeatureSearchAppStoreTests/
      ├─ SearchAppStoreListViewModelTests.swift
      ├─ SearchAppStoreDetailViewModelTests.swift
      └─ TestDoubles/
         ├─ Fixtures/
         │  ├─ SearchAppStoreListEntity+Fixture.swift
         │  └─ SearchAppStoreDetailEntity+Fixture.swift
         ├─ Spies/
         │  └─ SpySearchAppStoreCoordinator.swift
         └─ Stubs/
            ├─ StubSearchAppStoreListUseCase.swift
            └─ StubSearchAppStoreDetailUseCase.swift
```

---

**빠른 시작**

App Target의 `RouteBuilder`에서 `SearchAppStoreFactory`를 통해 화면을 조립합니다.

```swift
import FeatureSearchAppStore

// 검색 목록 화면 조립
let listView = SearchAppStoreFactory.makeSearchAppStoreListView(
    useCase: container.makeSearchAppStoreListUseCase(),
    coordinator: navigator,
    searchKeyword: "kakaotalk"
)

// 상세 화면 조립
let detailView = SearchAppStoreFactory.makeSearchAppStoreDetailView(
    useCase: container.makeSearchAppStoreDetailUseCase(),
    coordinator: navigator,
    trackId: 284882215
)
```

`coordinator`는 `SearchAppStoreCoordinatorProtocol`을 구현하는 App Target의 Navigator입니다.
Feature 모듈은 Navigator 구현체를 직접 알지 않습니다.

```swift
// App Target — HomeNavigator 예시
@MainActor
final class HomeNavigator: SearchAppStoreCoordinatorProtocol {
    func showSearchAppStoreDetail(trackId: Int) {
        navigator.push(.searchAppStoreDetail(trackId: trackId))
    }

    func pop() {
        navigator.pop()
    }
}
```

---

**핵심 설계 방향**

- **Feature → AppDomain 단방향 의존**
  Feature 모듈은 `AppDomain`의 UseCase Protocol과 Entity만 참조합니다.
  `AppData`, `Networking`, `Persistence`, `SearchEngine` 구현체를 직접 의존하지 않습니다.

- **조립 지점 통일**
  App Target의 `RouteBuilder`는 `SearchAppStoreFactory`를 통해 화면을 조립합니다.
  Factory가 ViewModel을 내부에서 생성하고 완성된 View를 반환하므로, RouteBuilder에서 ViewModel 구현 세부를 노출하지 않습니다.

- **제네릭 기반 타입 안전성**
  ViewModel과 View는 UseCase와 Coordinator를 제네릭으로 받아 `any` 프로토콜 existential 저장을 피합니다.
  컴파일 타임에 의존성 연결이 검증됩니다.

- **iOS 15 호환 상태 관찰**
  `@Observable`을 사용하지 않습니다. `ObservableObject` + `@Published`를 기본으로 사용합니다.

- **이미지 프리패치**
  List 화면에서 `onAppear` 시점에 현재 항목 기준 다음 3개 항목의 아트워크를 `UIComponents.prefetchRemoteImages()`로 미리 적재합니다.
  `ImagePipeline` 구현 세부는 Feature 외부에 숨깁니다.

---

**SearchAppStoreCoordinatorProtocol**

`SearchAppStoreCoordinatorProtocol`은 Feature ViewModel이 화면 이동을 요청하는 공개 계약입니다.

```swift
@MainActor
public protocol SearchAppStoreCoordinatorProtocol: AnyObject {
    func pop()
    func showSearchAppStoreDetail(trackId: Int)
}
```

구현체는 App Target의 Navigator에 둡니다. Feature 모듈은 Navigator 구현체를 import하지 않습니다.

---

**SearchAppStoreFactory**

`SearchAppStoreFactory`는 FeatureSearchAppStore 모듈의 **화면 조립 진입점(composition entry point)** 입니다.

제공 팩토리:
- `makeSearchAppStoreListView(useCase:coordinator:searchKeyword:)` — 검색 목록 View 조립
- `makeSearchAppStoreDetailView(useCase:coordinator:trackId:)` — 상세 View 조립

```swift
@MainActor
public enum SearchAppStoreFactory {
    public static func makeSearchAppStoreListView<
        UseCase: SearchAppStoreListUseCaseProtocol,
        Coordinator: SearchAppStoreCoordinatorProtocol
    >(
        useCase: UseCase,
        coordinator: Coordinator,
        searchKeyword: String
    ) -> SearchAppStoreListView<UseCase, Coordinator>

    public static func makeSearchAppStoreDetailView<
        DetailUseCase: SearchAppStoreDetailUseCaseProtocol,
        Coordinator: SearchAppStoreCoordinatorProtocol
    >(
        useCase: DetailUseCase,
        coordinator: Coordinator,
        trackId: Int
    ) -> SearchAppStoreDetailView<DetailUseCase, Coordinator>
}
```

Factory는 ViewModel 생성과 View 조립만 담당합니다. UseCase · Repository · DataSource 생성은 App Target의 `DIContainer`가 담당합니다.

---

**Scene: SearchAppStoreList**

### SearchAppStoreListViewState

```swift
public struct SearchAppStoreListViewState: Equatable {
    public var loadState: LoadState = .idle
}

extension SearchAppStoreListViewState {
    public enum LoadState: Equatable {
        case idle
        case loading
        case success([SearchAppStoreListEntity])
        case empty
        case failure(SearchAppStoreDomainError)
    }
}
```

### SearchAppStoreListViewModel

| Intent 메서드 | 설명 |
|---|---|
| `load(searchKeyword:) async` | UseCase 호출, loadState 전환 (loading → success / empty / failure) |
| `retryButtonTapped() -> Task<Void, Never>` | 마지막 검색어로 재시도 |
| `itemTapped(trackId:)` | `coordinator.showSearchAppStoreDetail(trackId:)` 호출 |
| `backButtonTapped()` | `coordinator.pop()` 호출 |

### SearchAppStoreListView

- `.task(id: searchKeyword)` 기반 키워드 변경 감지 및 자동 로드
- `loadState` 분기 렌더링

| LoadState | 표시 |
|---|---|
| `.idle` / `.loading` | `ProgressView("검색 중...")` |
| `.empty` | `EmptyStateView(title: "검색 결과가 없습니다.")` |
| `.failure(error)` | `ErrorStateView(message:)` + 재시도 버튼 |
| `.success(items)` | `List` — 아트워크, trackName, artistName, 평점 표시 |

- 아트워크: `RemoteImageView(preferredURLs: [url512, url100], configuration: .appIconList)`
- 접근성: 각 셀 `.accessibilityIdentifier("searchResults.item.\(item.trackId)")`
- 프리패치: 목록 항목 출현 시 다음 3개 아트워크 선제 적재

---

**Scene: SearchAppStoreDetail**

### SearchAppStoreDetailViewState

```swift
public struct SearchAppStoreDetailViewState: Equatable {
    public var loadState: LoadState = .idle
}

extension SearchAppStoreDetailViewState {
    public enum LoadState: Equatable {
        case idle
        case loading
        case success(SearchAppStoreDetailEntity)
        case failure(SearchAppStoreDomainError)
    }
}
```

### SearchAppStoreDetailViewModel

| Intent 메서드 | 설명 |
|---|---|
| `load(trackId:) async` | UseCase 호출, loadState 전환 (loading → success / failure) |
| `retryButtonTapped() -> Task<Void, Never>` | 마지막 trackId로 재시도 |
| `backButtonTapped()` | `coordinator.pop()` 호출 |

### SearchAppStoreDetailView

- `.task(id: trackId)` 기반 자동 로드
- `ScrollView` 내 `VStack` 구성

| LoadState | 표시 |
|---|---|
| `.idle` / `.loading` | `ProgressView("불러오는 중...")` |
| `.failure(error)` | `ErrorStateView(message:)` + 재시도 버튼 |
| `.success(item)` | 아트워크, trackName, artistName, 평점, 장르, 설명 |

- 아트워크: `RemoteImageView(preferredURLs: [url512, url100], configuration: .appIconDetail)`
- 접근성: 앱 이름 레이블 `.accessibilityIdentifier("searchDetail.title")`
- 디자인 토큰: `DSSpacing`, `DSTypography.title1 / body1 / body2 / caption1`, `DSColor.textPrimary / textSecondary`

---

**AppDomain 의존 타입**

| 타입 | 설명 |
|---|---|
| `SearchAppStoreListUseCaseProtocol` | `execute(searchKeyword:) async throws -> [SearchAppStoreListEntity]` |
| `SearchAppStoreDetailUseCaseProtocol` | `execute(trackId:) async throws -> SearchAppStoreDetailEntity` |
| `SearchAppStoreListEntity` | trackId, trackName, artistName, artworkUrl100, artworkUrl512, averageUserRating, userRatingCount |
| `SearchAppStoreDetailEntity` | ListEntity 항목 + description, screenshotUrls, genres |
| `SearchAppStoreDomainError` | `.emptyQuery`, `.invalidAppID`, `.appNotFound`, `.temporarilyUnavailable` |

Feature 모듈은 위 타입만 참조합니다. AppData 구현체 조립은 App Target의 `DIContainer`와 `RouteBuilder`가 담당합니다.

---

**테스트**

모듈은 10개 테스트를 포함합니다.

포함된 테스트 범위:
- ViewModel 상태 전환: `SearchAppStoreListViewModelTests`, `SearchAppStoreDetailViewModelTests`

테스트 전략:
- `@MainActor makeSUT()` helper 패턴으로 ViewModel을 테스트 메서드 안에서 생성합니다.
- UseCase는 `StubSearchAppStoreListUseCase` / `StubSearchAppStoreDetailUseCase`로 대체합니다.
- Coordinator는 `SpySearchAppStoreCoordinator`로 호출 횟수와 전달 인자를 기록합니다.
- `retryButtonTapped()` Intent는 `await sut.retryButtonTapped().value`로 완료를 보장합니다.
- 테스트 간 상태를 공유하지 않습니다.

| 테스트 클래스 | 테스트 수 | 주요 검증 항목 |
|---|---|---|
| `SearchAppStoreListViewModelTests` | 6 | loadState 전환, 재시도, itemTapped Coordinator 호출, backButtonTapped Coordinator 호출 |
| `SearchAppStoreDetailViewModelTests` | 4 | loadState 전환, 재시도, backButtonTapped Coordinator 호출 |

---

**TestDoubles**

| 종류 | 타입 | 역할 |
|---|---|---|
| Stub | `StubSearchAppStoreListUseCase` | `stubbedResult: Result<[SearchAppStoreListEntity], SearchAppStoreDomainError>` 반환 |
| Stub | `StubSearchAppStoreDetailUseCase` | `stubbedResult: Result<SearchAppStoreDetailEntity, SearchAppStoreDomainError>` 반환 |
| Spy | `SpySearchAppStoreCoordinator` | `popCallCount`, `showSearchAppStoreDetailCallCount`, `lastTrackId` 기록 |
| Fixture | `SearchAppStoreListEntity+Fixture` | trackId: 284882215, trackName: "카카오톡", artistName: "Kakao Corp.", averageUserRating: 4.5 |
| Fixture | `SearchAppStoreDetailEntity+Fixture` | ListEntity Fixture 기반 + description, screenshotUrls, genres |

---

**의존성**

| 모듈 | 역할 |
|---|---|
| `AppDomain` | UseCase Protocol, Entity, Domain Error 타입 |
| `DesignSystem` | `DSSpacing`, `DSTypography`, `DSColor` 토큰 |
| `UIComponents` | `RemoteImageView`, `EmptyStateView`, `ErrorStateView`, `BackButton`, `prefetchRemoteImages()` |

의존 금지:

```text
FeatureSearchAppStore ─X→ AppData
FeatureSearchAppStore ─X→ SearchAppStoreListRepository
FeatureSearchAppStore ─X→ SearchAppStoreResponseDTO
FeatureSearchAppStore ─X→ Networking
FeatureSearchAppStore ─X→ Persistence
FeatureSearchAppStore ─X→ SearchEngine
FeatureSearchAppStore ─X→ 다른 Feature 모듈
```

---

**권장 사용 전략**
- App Target `RouteBuilder`는 `SearchAppStoreFactory`와 `DIContainer`를 연결합니다.
- App Target `Navigator`는 `SearchAppStoreCoordinatorProtocol`을 구현합니다.
- ViewModel 단위 테스트는 Stub UseCase와 Spy Coordinator로 격리 검증합니다.
- 화면 전환 결과는 XCUITest 기반 UI 테스트에서 검증합니다.

---

**권장 확장 방식**
1. 새 화면이 필요하면 `Scenes/{SceneName}/View`, `Scenes/{SceneName}/ViewModel` 구조로 추가합니다.
2. 새 화면 이동이 필요하면 `SearchAppStoreCoordinatorProtocol`에 메서드를 추가합니다.
3. `SearchAppStoreFactory`에 새 View 조립 메서드를 추가합니다.
4. App Target의 `HomeRoute`, `HomeRouteBuilder`, `HomeNavigator`에 새 Route case와 Builder를 추가합니다.
5. 새 UseCase Protocol이 필요하면 `AppDomain`에 Protocol을 먼저 추가합니다.
6. 새 화면 전용 TestDouble과 Fixture를 `TestDoubles/` 하위에 추가합니다.

---

Created by: JEONG, Chi-hong  
Updated: May 2026
