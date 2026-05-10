//
//  SearchAppStoreDetailViewModel.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/22/26.
//

import Foundation
import Combine
import AppDomain

/// SearchAppStore 상세 화면의 상태와 사용자 Intent를 관리합니다.
@MainActor
public final class SearchAppStoreDetailViewModel<
    DetailUseCase: SearchAppStoreDetailUseCaseProtocol,
    Coordinator: SearchAppStoreCoordinatorProtocol
>: ObservableObject {

    // MARK: - Output

    @Published public private(set) var viewState: SearchAppStoreDetailViewState = .init()

    // MARK: - Dependencies

    private let useCase: DetailUseCase
    private let coordinator: Coordinator

    // MARK: - Private State

    private var currentTrackId: Int = 0

    // MARK: - Init

    public init(useCase: DetailUseCase, coordinator: Coordinator) {
        self.useCase = useCase
        self.coordinator = coordinator
    }

    // MARK: - Intent

    /// trackId를 기준으로 상세 정보를 조회합니다.
    ///
    /// - Parameter trackId: 상세 조회에 사용할 앱 식별자
    public func load(trackId: Int) async {
        currentTrackId = trackId
        viewState.loadState = .loading

        do {
            let entity = try await useCase.execute(trackId: trackId)
            viewState.loadState = .success(entity)
        } catch let error as SearchAppStoreDomainError {
            viewState.loadState = .failure(error)
        } catch {
            viewState.loadState = .failure(.temporarilyUnavailable)
        }
    }

    /// 사용자가 재시도 버튼을 눌렀을 때 상세 정보를 다시 조회합니다.
    @discardableResult
    public func retryButtonTapped() -> Task<Void, Never> {
        Task { await load(trackId: currentTrackId) }
    }

    /// 사용자가 뒤로가기 버튼을 눌렀을 때 이전 화면 이동을 요청합니다.
    public func backButtonTapped() {
        coordinator.pop()
    }
}
