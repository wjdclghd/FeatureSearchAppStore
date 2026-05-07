//
//  SearchAppStoreListViewModel.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/22/26.
//

import Foundation
import Combine
import AppDomain

/*
 SearchAppStore 목록 화면의 상태와 사용자 액션을 관리하는 ViewModel입니다.

 이 타입은 목록 조회 UseCase를 실행하고,
 결과를 SearchAppStoreListViewState로 변환하여 View에 제공합니다.
 또한 사용자가 목록 항목을 선택했을 때
 App 레이어 coordinator가 구현하는 coordinator 계약으로 상세 화면 이동을 요청합니다.

 담당 역할
 - 목록 조회 실행
 - 로딩, 빈 상태, 성공, 실패 상태 관리
 - 목록 항목 선택 시 coordinator 요청 전달

 담당하지 않는 역할
 - Networking, AppData concrete 생성
 - DTO 매핑
 - 실제 화면 전환 구현
 */
@MainActor
public final class SearchAppStoreListViewModel<
    UseCase: SearchAppStoreListUseCaseProtocol,
    Coordinator: SearchAppStoreCoordinatorProtocol
>: ObservableObject {
    @Published public private(set) var viewState: SearchAppStoreListViewState = .initial

    private let useCase: UseCase
    private let coordinator: Coordinator

    public init(
        useCase: UseCase,
        coordinator: Coordinator
    ) {
        self.useCase = useCase
        self.coordinator = coordinator
    }

    /*
     검색어를 기준으로 App Store 목록을 조회합니다.

     Parameters:
     - searchKeyword: 목록 조회에 사용할 검색어
     */
    public func load(searchKeyword: String) async {
        viewState = .loading

        do {
            let entities = try await useCase.execute(searchKeyword: searchKeyword)
            viewState = entities.isEmpty ? .noResults : .loaded(entities)
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    /*
     사용자가 목록 항목을 선택했을 때 상세 화면 이동을 요청합니다.

     Parameters:
     - item: 상세 화면으로 전달할 선택된 목록 항목
     */
    public func didSelectItem(_ item: SearchAppStoreListEntity) {
        coordinator.showSearchAppStoreDetail(trackId: item.trackId)
    }

    /// 사용자가 뒤로가기 버튼을 눌렀을 때 이전 화면 이동을 요청합니다.
    public func backButtonTapped() {
        coordinator.pop()
    }
}
