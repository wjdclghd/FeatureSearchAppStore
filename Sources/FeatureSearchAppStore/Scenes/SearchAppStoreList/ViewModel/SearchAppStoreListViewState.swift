//
//  SearchAppStoreListViewState.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/22/26.
//

import Foundation
import AppDomain

/// SearchAppStore 목록 화면의 렌더링 상태입니다.
public struct SearchAppStoreListViewState: Equatable {
    public var loadState: LoadState = .idle

    public init() {}
}

extension SearchAppStoreListViewState {

    /// 목록 조회 상태를 나타냅니다.
    public enum LoadState: Equatable {
        case idle
        case loading
        case success([SearchAppStoreListEntity])
        case empty
        case failure(SearchAppStoreDomainError)
    }
}
