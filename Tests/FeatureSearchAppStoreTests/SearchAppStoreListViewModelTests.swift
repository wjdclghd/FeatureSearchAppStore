//
//  SearchAppStoreListViewModelTests.swift
//  FeatureSearchAppStoreTests
//
//  Created by jch on 4/22/26.
//

import Foundation
import XCTest
import AppDomain
@testable import FeatureSearchAppStore

/// `SearchAppStoreListViewModel`의 viewState.loadState 전환과 Intent 흐름을 검증합니다.
final class SearchAppStoreListViewModelTests: XCTestCase {

    // MARK: - Tests

    @MainActor
    func test_load_withValidSearchKeyword_updatesLoadStateToSuccess() async {
        // given
        let (sut, useCase, _) = makeSUT()
        useCase.stubbedResult = .success([.fixture])

        // when
        await sut.load(searchKeyword: "카카오톡")

        // then
        XCTAssertEqual(sut.viewState.loadState, .success([.fixture]))
    }

    @MainActor
    func test_load_withValidSearchKeyword_whenResultIsEmpty_updatesLoadStateToEmpty() async {
        // given
        let (sut, useCase, _) = makeSUT()
        useCase.stubbedResult = .success([])

        // when
        await sut.load(searchKeyword: "카카오톡")

        // then
        XCTAssertEqual(sut.viewState.loadState, .empty)
    }

    @MainActor
    func test_load_whenUseCaseThrowsDomainError_updatesLoadStateToFailure() async {
        // given
        let (sut, useCase, _) = makeSUT()
        useCase.stubbedResult = .failure(.temporarilyUnavailable)

        // when
        await sut.load(searchKeyword: "카카오톡")

        // then
        XCTAssertEqual(sut.viewState.loadState, .failure(.temporarilyUnavailable))
    }

    @MainActor
    func test_retryButtonTapped_whenPreviousLoadFailed_retriesWithSameKeyword() async {
        // given
        let (sut, useCase, _) = makeSUT()
        useCase.stubbedResult = .failure(.temporarilyUnavailable)
        await sut.load(searchKeyword: "카카오톡")

        useCase.stubbedResult = .success([.fixture])

        // when
        await sut.retryButtonTapped().value

        // then
        XCTAssertEqual(sut.viewState.loadState, .success([.fixture]))
    }

    @MainActor
    func test_itemTapped_callsCoordinatorShowSearchAppStoreDetail() {
        // given
        let (sut, _, coordinator) = makeSUT()

        // when
        sut.itemTapped(trackId: SearchAppStoreListEntity.fixture.trackId)

        // then
        XCTAssertEqual(coordinator.showSearchAppStoreDetailCallCount, 1)
        XCTAssertEqual(coordinator.lastTrackId, SearchAppStoreListEntity.fixture.trackId)
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
        sut: SearchAppStoreListViewModel<StubSearchAppStoreListUseCase, SpySearchAppStoreCoordinator>,
        useCase: StubSearchAppStoreListUseCase,
        coordinator: SpySearchAppStoreCoordinator
    ) {
        let useCase = StubSearchAppStoreListUseCase()
        let coordinator = SpySearchAppStoreCoordinator()
        let sut = SearchAppStoreListViewModel(useCase: useCase, coordinator: coordinator)
        return (sut, useCase, coordinator)
    }
}
