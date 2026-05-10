//
//  StubSearchAppStoreDetailUseCase.swift
//  FeatureSearchAppStoreTests
//

import AppDomain

/// 테스트에서 App Store 상세 조회 결과를 주입하는 Stub입니다.
final class StubSearchAppStoreDetailUseCase: SearchAppStoreDetailUseCaseProtocol, @unchecked Sendable {

    var stubbedResult: Result<SearchAppStoreDetailEntity, SearchAppStoreDomainError> = .success(.fixture)

    func execute(trackId: Int) async throws -> SearchAppStoreDetailEntity {
        switch stubbedResult {
        case let .success(entity):
            return entity
        case let .failure(error):
            throw error
        }
    }
}
