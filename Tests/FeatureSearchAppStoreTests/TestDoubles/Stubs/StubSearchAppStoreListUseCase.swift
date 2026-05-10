//
//  StubSearchAppStoreListUseCase.swift
//  FeatureSearchAppStoreTests
//

import AppDomain

/// 테스트에서 App Store 목록 조회 결과를 주입하는 Stub입니다.
final class StubSearchAppStoreListUseCase: SearchAppStoreListUseCaseProtocol, @unchecked Sendable {

    var stubbedResult: Result<[SearchAppStoreListEntity], SearchAppStoreDomainError> = .success([.fixture])

    func execute(searchKeyword: String) async throws -> [SearchAppStoreListEntity] {
        switch stubbedResult {
        case let .success(entities):
            return entities
        case let .failure(error):
            throw error
        }
    }
}
