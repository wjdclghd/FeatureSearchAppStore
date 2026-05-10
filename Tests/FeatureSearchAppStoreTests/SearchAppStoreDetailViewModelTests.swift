//
//  SearchAppStoreDetailViewModelTests.swift
//  FeatureSearchAppStoreTests
//
//  Created by jch on 4/22/26.
//

import Foundation
import XCTest
import AppDomain
@testable import FeatureSearchAppStore

/// `SearchAppStoreDetailViewModel`의 viewState.loadState 전환과 Intent 흐름을 검증합니다.
final class SearchAppStoreDetailViewModelTests: XCTestCase {

    // MARK: - Tests

    @MainActor
    func test_load_withValidTrackId_updatesLoadStateToSuccess() async {
        // given
        let (sut, useCase, _) = makeSUT()
        useCase.stubbedResult = .success(.fixture)

        // when
        await sut.load(trackId: SearchAppStoreDetailEntity.fixture.trackId)

        // then
        XCTAssertEqual(sut.viewState.loadState, .success(.fixture))
    }

    @MainActor
    func test_load_whenUseCaseThrowsDomainError_updatesLoadStateToFailure() async {
        // given
        let (sut, useCase, _) = makeSUT()
        useCase.stubbedResult = .failure(.temporarilyUnavailable)

        // when
        await sut.load(trackId: SearchAppStoreDetailEntity.fixture.trackId)

        // then
        XCTAssertEqual(sut.viewState.loadState, .failure(.temporarilyUnavailable))
    }

    @MainActor
    func test_retryButtonTapped_whenPreviousLoadFailed_retriesWithSameTrackId() async {
        // given
        let (sut, useCase, _) = makeSUT()
        useCase.stubbedResult = .failure(.temporarilyUnavailable)
        await sut.load(trackId: SearchAppStoreDetailEntity.fixture.trackId)

        useCase.stubbedResult = .success(.fixture)

        // when
        await sut.retryButtonTapped().value

        // then
        XCTAssertEqual(sut.viewState.loadState, .success(.fixture))
    }

    @MainActor
    func test_backButtonTapped_callsCoordinatorPop() {
        // given
        let (sut, _, coordinator) = makeSUT()

        // when
        sut.backButtonTapped()

        // then
        XCTAssertEqual(coordinator.popCallCount, 1)
    }

    // MARK: - Helpers

    @MainActor
    private func makeSUT() -> (
        sut: SearchAppStoreDetailViewModel<StubSearchAppStoreDetailUseCase, SpySearchAppStoreCoordinator>,
        useCase: StubSearchAppStoreDetailUseCase,
        coordinator: SpySearchAppStoreCoordinator
    ) {
        let useCase = StubSearchAppStoreDetailUseCase()
        let coordinator = SpySearchAppStoreCoordinator()
        let sut = SearchAppStoreDetailViewModel(useCase: useCase, coordinator: coordinator)
        return (sut, useCase, coordinator)
    }
}
