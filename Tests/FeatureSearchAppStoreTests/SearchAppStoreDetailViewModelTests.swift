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

/*
 SearchAppStoreDetailViewModel의 상태 전환을 검증하는 테스트입니다.

 이 테스트는 Mock UseCase를 사용하여 실제 AppData나 Networking 구현 없이,
 상세 조회 성공과 실패 시 ViewModel이 적절한 상태로 전환되는지 확인합니다.
 */
@MainActor
final class SearchAppStoreDetailViewModelTests: XCTestCase {
    /*
     테스트에서 사용하는 상세 조회 UseCase의 Mock 구현체입니다.

     호출 횟수, 마지막 trackId, stub 결과를 저장하여
     ViewModel이 상세 조회 요청을 올바르게 수행하는지 확인합니다.
     */
    private final class MockSearchAppStoreDetailUseCase: SearchAppStoreDetailUseCaseProtocol, @unchecked Sendable {
        var executeCallCount = 0
        var receivedTrackId: Int?
        var stubbedResult: Result<SearchAppStoreDetailEntity, Error> = .success(
            SearchAppStoreDetailEntity(
                trackId: 1,
                trackName: "ChatGPT",
                artistName: "OpenAI",
                artworkUrl100: nil,
                description: "AI assistant",
                averageUserRating: 4.9,
                userRatingCount: 1000,
                screenshotUrls: [],
                genres: []
            )
        )

        func execute(trackId: Int) async throws -> SearchAppStoreDetailEntity {
            executeCallCount += 1
            receivedTrackId = trackId
            return try stubbedResult.get()
        }
    }

    /*
     상세 조회가 성공하면 loaded 상태로 전환되는지 검증합니다.
     */
    func test_load_whenUseCaseReturnsEntity_updatesLoadedState() async {
        let useCase = MockSearchAppStoreDetailUseCase()
        useCase.stubbedResult = .success(
            SearchAppStoreDetailEntity(
                trackId: 55,
                trackName: "YouTube",
                artistName: "Google",
                artworkUrl100: nil,
                description: "Video platform",
                averageUserRating: 4.6,
                userRatingCount: 3000,
                screenshotUrls: [],
                genres: ["Entertainment"]
            )
        )

        let viewModel = SearchAppStoreDetailViewModel(useCase: useCase)

        await viewModel.load(trackId: 55)

        XCTAssertEqual(useCase.executeCallCount, 1)
        XCTAssertEqual(useCase.receivedTrackId, 55)

        switch viewModel.viewState {
        case let .loaded(entity):
            XCTAssertEqual(entity.trackName, "YouTube")
        default:
            XCTFail("Expected loaded state")
        }
    }

    /*
     상세 조회 UseCase가 오류를 던지면 failure 상태로 전환되는지 검증합니다.
     */
    func test_load_whenUseCaseThrows_updatesFailureState() async {
        let useCase = MockSearchAppStoreDetailUseCase()
        useCase.stubbedResult = .failure(SearchAppStoreDomainError.temporarilyUnavailable)

        let viewModel = SearchAppStoreDetailViewModel(useCase: useCase)

        await viewModel.load(trackId: 55)

        switch viewModel.viewState {
        case let .error(message):
            XCTAssertFalse(message.isEmpty)
        default:
            XCTFail("Expected failure state")
        }
    }
}
