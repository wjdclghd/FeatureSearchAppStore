//
//  SpySearchAppStoreCoordinator.swift
//  FeatureSearchAppStoreTests
//

import FeatureSearchAppStore

/// 테스트에서 Coordinator 호출 횟수와 전달 인자를 기록하는 Spy입니다.
final class SpySearchAppStoreCoordinator: SearchAppStoreCoordinatorProtocol, @unchecked Sendable {

    private(set) var popCallCount: Int = 0
    private(set) var showSearchAppStoreDetailCallCount: Int = 0
    private(set) var lastTrackId: Int?

    func pop() {
        popCallCount += 1
    }

    func showSearchAppStoreDetail(trackId: Int) {
        showSearchAppStoreDetailCallCount += 1
        lastTrackId = trackId
    }
}
