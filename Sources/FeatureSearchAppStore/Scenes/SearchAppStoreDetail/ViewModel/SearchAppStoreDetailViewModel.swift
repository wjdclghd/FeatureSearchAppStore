//
//  SearchAppStoreDetailViewModel.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/22/26.
//

import Foundation
import Combine
import AppDomain

/*
 SearchAppStore 상세 화면의 상태와 사용자 액션을 관리하는 ViewModel입니다.

 이 타입은 상세 조회 UseCase를 실행하고,
 결과를 SearchAppStoreDetailViewState로 변환하여 View에 제공합니다.
 View는 이 상태만 관찰하며,
 실제 데이터 조회와 에러 해석은 ViewModel이 담당합니다.
 */
@MainActor
public final class SearchAppStoreDetailViewModel<
    DetailUseCase: SearchAppStoreDetailUseCaseProtocol
>: ObservableObject {
    @Published public private(set) var viewState: SearchAppStoreDetailViewState = .initial

    private let useCase: DetailUseCase

    public init(useCase: DetailUseCase) {
        self.useCase = useCase
    }

    /*
     trackId를 기준으로 상세 정보를 조회합니다.

     Parameters:
     - trackId: 상세 조회에 사용할 앱 식별자
     */
    public func load(trackId: Int) async {
        viewState = .loading

        do {
            let entity = try await useCase.execute(trackId: trackId)
            viewState = .loaded(entity)
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
}
