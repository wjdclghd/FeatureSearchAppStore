//
//  SearchAppStoreCoordinatorProtocol.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/22/26.
//

import Foundation

/// SearchAppStore 화면에서 사용하는 라우팅 계약입니다.
///
/// Feature ViewModel은 이 계약만 알고, 실제 화면 전환 구현은 App 레이어의 Navigator가 담당합니다.
@MainActor
public protocol SearchAppStoreCoordinatorProtocol: AnyObject {
    func pop()
    func showSearchAppStoreDetail(trackId: Int)
}
