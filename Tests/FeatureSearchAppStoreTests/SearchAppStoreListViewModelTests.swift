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
/*
 SearchAppStoreListViewModel의 상태 전환과 라우팅 요청을 검증하는 테스트입니다.

 이 테스트는 Mock UseCase와 Mock Coordinator를 사용하여 실제 AppData 또는 Navigation 구현 없이,
 목록 조회 성공, 빈 결과, 실패 상태 전환과 항목 선택 시 상세 화면 이동 요청이
 올바르게 발생하는지 확인합니다.
 */
@MainActor
final class SearchAppStoreListViewModelTests: XCTestCase {
    /*
     테스트에서 사용하는 목록 조회 UseCase의 Mock 구현체입니다.

     호출 횟수, 마지막 검색어, stub 결과를 저장하여
     ViewModel이 UseCase 실행과 상태 전환을 올바르게 수행하는지 확인합니다.
     */
    private final class MockSearchAppStoreListUseCase: SearchAppStoreListUseCaseProtocol, @unchecked Sendable {
        var executeCallCount = 0
        var receivedSearchKeyword: String?
        var stubbedResult: Result<[SearchAppStoreListEntity], Error> = .success([])

        func execute(searchKeyword: String) async throws -> [SearchAppStoreListEntity] {
            executeCallCount += 1
            receivedSearchKeyword = searchKeyword
            return try stubbedResult.get()
        }
    }

    /*
     테스트에서 사용하는 목록 화면 라우터의 Mock 구현체입니다.

     ViewModel이 목록 항목 선택 시 올바른 trackId로 상세 이동 요청을 보내는지 확인합니다.
     */
    private final class MockSearchAppStoreListCoordinator: SearchAppStoreCoordinatorProtocol, @unchecked Sendable {
        var showSearchAppStoreDetailCallCount = 0
        var receivedTrackId: Int?

        func showSearchAppStoreDetail(trackId: Int) {
            showSearchAppStoreDetailCallCount += 1
            receivedTrackId = trackId
        }
    }

    /*
     목록 조회가 성공하고 결과가 존재하면 loaded 상태로 전환되는지 검증합니다.
     */
    func test_load_whenUseCaseReturnsItems_updatesLoadedState() async {
        let useCase = MockSearchAppStoreListUseCase()
        let coordinator = MockSearchAppStoreListCoordinator()
        useCase.stubbedResult = .success([
            SearchAppStoreListEntity(
                trackId: 10,
                trackName: "ChatGPT",
                artistName: "OpenAI",
                artworkUrl100: nil,
                averageUserRating: 4.8,
                userRatingCount: 100
            )
        ])

        let viewModel = SearchAppStoreListViewModel(
            useCase: useCase,
            coordinator: coordinator
        )

        await viewModel.load(searchKeyword: "chat")

        XCTAssertEqual(useCase.executeCallCount, 1)
        XCTAssertEqual(useCase.receivedSearchKeyword, "chat")

        switch viewModel.viewState {
        case let .loaded(items):
            XCTAssertEqual(items.count, 1)
            XCTAssertEqual(items.first?.trackId, 10)
        default:
            XCTFail("Expected loaded state")
        }
    }

    /*
     목록 조회가 성공했지만 결과가 비어 있으면 noResults 상태로 전환되는지 검증합니다.
     */
    func test_load_whenUseCaseReturnsNoResultsItems_updatesNoResultsState() async {
        let useCase = MockSearchAppStoreListUseCase()
        let coordinator = MockSearchAppStoreListCoordinator()
        useCase.stubbedResult = .success([])

        let viewModel = SearchAppStoreListViewModel(
            useCase: useCase,
            coordinator: coordinator
        )

        await viewModel.load(searchKeyword: "chat")

        switch viewModel.viewState {
        case .noResults:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected noResults state")
        }
    }

    /*
     목록 조회 UseCase가 오류를 던지면 error 상태로 전환되는지 검증합니다.
     */
    func test_load_whenUseCaseThrows_updatesErrorState() async {
        let useCase = MockSearchAppStoreListUseCase()
        let coordinator = MockSearchAppStoreListCoordinator()
        useCase.stubbedResult = .failure(SearchAppStoreDomainError.temporarilyUnavailable)

        let viewModel = SearchAppStoreListViewModel(
            useCase: useCase,
            coordinator: coordinator
        )

        await viewModel.load(searchKeyword: "chat")

        switch viewModel.viewState {
        case let .error(message):
            XCTAssertFalse(message.isEmpty)
        default:
            XCTFail("Expected error state")
        }
    }

    /*
     목록 항목 선택 시 Coordinator로 상세 화면 이동 요청이 전달되는지 검증합니다.
     */
    func test_didSelectItem_requestsDetailRoute() {
        let useCase = MockSearchAppStoreListUseCase()
        let coordinator = MockSearchAppStoreListCoordinator()
        let viewModel = SearchAppStoreListViewModel(
            useCase: useCase,
            coordinator: coordinator
        )
        let item = SearchAppStoreListEntity(
            trackId: 42,
            trackName: "ChatGPT",
            artistName: "OpenAI",
            artworkUrl100: nil,
            averageUserRating: 4.8,
            userRatingCount: 100
        )

        viewModel.didSelectItem(item)

        XCTAssertEqual(coordinator.showSearchAppStoreDetailCallCount, 1)
        XCTAssertEqual(coordinator.receivedTrackId, 42)
    }
}
