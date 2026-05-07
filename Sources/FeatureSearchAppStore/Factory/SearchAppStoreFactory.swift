//
//  SearchAppStoreFactory.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/22/26.
//

import Foundation
import AppDomain

/*
 SearchAppStore Feature 내부 화면 조립을 담당하는 factory입니다.

 이 타입은 Feature 내부의 ViewModel, View, Protocol 계약을 한 곳에서 연결하여
 App 레이어가 화면을 생성할 때 필요한 진입점을 제공합니다.
 실제 UseCase 구현체 생성과 외부 모듈 concrete 조립은 App 레이어에서 수행하고,
 이 factory는 전달받은 의존성을 바탕으로 Feature 내부 화면만 조립합니다.

 담당 역할
 - 목록 화면 ViewModel과 View 생성
 - 상세 화면 ViewModel과 View 생성
 - Feature 내부 화면 조립 진입점 제공

 담당하지 않는 역할
 - Networking, AppData concrete 생성
 - AppDomain UseCase concrete 생성
 - Feature 간 이동 흐름 결정
 */
@MainActor
public enum SearchAppStoreFactory {
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

    public static func makeSearchAppStoreDetailView<
        DetailUseCase: SearchAppStoreDetailUseCaseProtocol,
        Coordinator: SearchAppStoreCoordinatorProtocol
    >(
        useCase: DetailUseCase,
        coordinator: Coordinator,
        trackId: Int
    ) -> SearchAppStoreDetailView<DetailUseCase, Coordinator> {
        let viewModel = SearchAppStoreDetailViewModel(useCase: useCase)

        return SearchAppStoreDetailView(
            viewModel: viewModel,
            coordinator: coordinator,
            trackId: trackId
        )
    }
}
