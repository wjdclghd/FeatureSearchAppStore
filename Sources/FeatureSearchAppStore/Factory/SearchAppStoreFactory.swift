//
//  SearchAppStoreFactory.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/22/26.
//

import Foundation
import AppDomain

/// SearchAppStore Feature 화면 조립 진입점입니다.
///
/// App 레이어에서 전달받은 UseCase와 Coordinator를 바탕으로 Feature 화면만 조립합니다.
/// UseCase concrete 생성과 외부 모듈 조립은 App 레이어가 담당합니다.
@MainActor
public enum SearchAppStoreFactory {

    /// SearchAppStore 목록 화면을 조립하여 반환합니다.
    ///
    /// - Parameters:
    ///   - useCase: 목록 조회에 사용할 UseCase입니다.
    ///   - coordinator: 화면 이동 계약 구현체입니다.
    ///   - searchKeyword: 검색에 사용할 키워드입니다.
    public static func makeSearchAppStoreListView<
        UseCase: SearchAppStoreListUseCaseProtocol,
        Coordinator: SearchAppStoreCoordinatorProtocol
    >(
        useCase: UseCase,
        coordinator: Coordinator,
        searchKeyword: String
    ) -> SearchAppStoreListView<UseCase, Coordinator> {
        let viewModel = SearchAppStoreListViewModel(
            useCase: useCase,
            coordinator: coordinator
        )

        return SearchAppStoreListView(
            viewModel: viewModel,
            searchKeyword: searchKeyword
        )
    }

    /// SearchAppStore 상세 화면을 조립하여 반환합니다.
    ///
    /// - Parameters:
    ///   - useCase: 상세 조회에 사용할 UseCase입니다.
    ///   - coordinator: 화면 이동 계약 구현체입니다.
    ///   - trackId: 조회할 앱의 식별자입니다.
    public static func makeSearchAppStoreDetailView<
        DetailUseCase: SearchAppStoreDetailUseCaseProtocol,
        Coordinator: SearchAppStoreCoordinatorProtocol
    >(
        useCase: DetailUseCase,
        coordinator: Coordinator,
        trackId: Int
    ) -> SearchAppStoreDetailView<DetailUseCase, Coordinator> {
        let viewModel = SearchAppStoreDetailViewModel(
            useCase: useCase,
            coordinator: coordinator
        )

        return SearchAppStoreDetailView(
            viewModel: viewModel,
            trackId: trackId
        )
    }
}
