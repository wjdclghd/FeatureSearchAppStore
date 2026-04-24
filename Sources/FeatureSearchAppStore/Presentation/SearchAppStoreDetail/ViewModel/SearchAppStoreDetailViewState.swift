//
//  SearchAppStoreDetailViewState.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/22/26.
//

import Foundation
import AppDomain

/*
 SearchAppStore 상세 화면의 렌더링 상태를 표현합니다.

 View는 이 상태를 관찰하여 로딩, 성공, 실패를 렌더링합니다.
 ViewModel은 상세 조회 UseCase 실행 결과를 화면 관점의 상태로 변환합니다.
 */
public enum SearchAppStoreDetailViewState: Sendable {
    case initial
    case loading
    case loaded(SearchAppStoreDetailEntity)
    case error(String)
}
