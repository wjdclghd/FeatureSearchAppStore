//
//  SearchAppStoreListViewModel.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/22/26.
//

import Foundation
import Combine
import AppDomain

/// SearchAppStore 목록 화면의 상태와 사용자 Intent를 관리합니다.
@MainActor
public final class SearchAppStoreListViewModel<
    UseCase: SearchAppStoreListUseCaseProtocol,
    Coordinator: SearchAppStoreCoordinatorProtocol
>: ObservableObject {

    // MARK: - Output

    @Published public private(set) var viewState: SearchAppStoreListViewState = .init()

    // MARK: - Dependencies

    private let useCase: UseCase
    private let coordinator: Coordinator

    // MARK: - Private State

    private var currentSearchKeyword: String = ""

    // MARK: - Init

    public init(
        useCase: UseCase,
        coordinator: Coordinator
    ) {
        self.useCase = useCase
        self.coordinator = coordinator
    }

    // MARK: - Intent

    /// 검색어를 기준으로 App Store 목록을 조회합니다.
    ///
    /// - Parameter searchKeyword: 목록 조회에 사용할 검색어
    public func load(searchKeyword: String) async {
        currentSearchKeyword = searchKeyword
        viewState.loadState = .loading

        do {
            let entities = try await useCase.execute(searchKeyword: searchKeyword)
            viewState.loadState = entities.isEmpty ? .empty : .success(entities)
        } catch let error as SearchAppStoreDomainError {
            viewState.loadState = .failure(error)
        } catch {
            viewState.loadState = .failure(.temporarilyUnavailable)
        }
    }

    /// 사용자가 재시도 버튼을 눌렀을 때 목록을 다시 조회합니다.
    @discardableResult
    public func retryButtonTapped() -> Task<Void, Never> {
        Task { await load(searchKeyword: currentSearchKeyword) }
    }

    /// 사용자가 목록 항목을 선택했을 때 상세 화면 이동을 요청합니다.
    ///
    /// - Parameter trackId: 선택된 앱의 식별자
    public func itemTapped(trackId: Int) {
        coordinator.showSearchAppStoreDetail(trackId: trackId)
    }

    /// 사용자가 뒤로가기 버튼을 눌렀을 때 이전 화면 이동을 요청합니다.
    public func backButtonTapped() {
        coordinator.pop()
    }
}
