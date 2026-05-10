//
//  SearchAppStoreDetailViewState.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/22/26.
//

import Foundation
import AppDomain

/// SearchAppStore 상세 화면의 렌더링 상태입니다.
public struct SearchAppStoreDetailViewState: Equatable {
    public var loadState: LoadState = .idle

    public init() {}
}

extension SearchAppStoreDetailViewState {

    /// 상세 조회 상태를 나타냅니다.
    public enum LoadState: Equatable {
        case idle
        case loading
        case success(SearchAppStoreDetailEntity)
        case failure(SearchAppStoreDomainError)
    }
}
