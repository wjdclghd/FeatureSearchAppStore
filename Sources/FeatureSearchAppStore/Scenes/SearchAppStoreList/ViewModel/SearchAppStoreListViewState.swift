//
//  SearchAppStoreListViewState.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/22/26.
//

import Foundation
import AppDomain

/*
 SearchAppStore 목록 화면의 렌더링 상태를 표현합니다.

 View는 이 상태만 관찰하여 로딩, 빈 상태, 목록 표시, 오류 메시지를 그립니다.
 ViewModel은 UseCase 실행 결과를 화면 관점의 상태로 변환하고,
 View는 그 상태를 기반으로 렌더링만 담당합니다.
 */
public enum SearchAppStoreListViewState: Sendable {
    case initial
    case loading
    case noResults
    case loaded([SearchAppStoreListEntity])
    case error(String)
}
