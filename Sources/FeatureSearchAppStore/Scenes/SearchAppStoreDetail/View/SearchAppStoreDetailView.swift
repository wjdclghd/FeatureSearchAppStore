//
//  SearchAppStoreDetailView.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/22/26.
//

import SwiftUI
import AppDomain
import DesignSystem
import UIComponents

/*
 SearchAppStore 상세 화면을 렌더링하는 View입니다.

 이 View는 ViewModel이 제공하는 SearchAppStoreDetailViewState만 관찰하며,
 상세 데이터 렌더링과 재시도 입력 전달만 담당합니다.
 실제 비즈니스 로직은 ViewModel과 Domain UseCase가 담당합니다.
 */
public struct SearchAppStoreDetailView<
    DetailUseCase: SearchAppStoreDetailUseCaseProtocol,
    Coordinator: SearchAppStoreCoordinatorProtocol
>: View {
    @StateObject private var viewModel: SearchAppStoreDetailViewModel<DetailUseCase>
    private let coordinator: Coordinator
    private let trackId: Int

    public init(
        viewModel: SearchAppStoreDetailViewModel<DetailUseCase>,
        coordinator: Coordinator,
        trackId: Int
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.coordinator = coordinator
        self.trackId = trackId
    }

    public var body: some View {
        navigationConfiguredContent
            .task(id: trackId) {
                await viewModel.load(trackId: trackId)
            }
    }

    private var navigationConfiguredContent: some View {
        ScrollView {
            content
                .padding(DSSpacing.md)
        }
        .navigationTitle("앱 상세")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    Task { @MainActor in
                        coordinator.pop()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .initial, .loading:
            ProgressView("불러오는 중...")
                .frame(maxWidth: .infinity, minHeight: 240)
            
        case let .error(message):
            VStack(spacing: DSSpacing.md) {
                Text(message)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)

                Button("다시 시도") {
                    Task {
                        await viewModel.load(trackId: trackId)
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 240)

        case let .loaded(item):
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                detailArtworkView(urlString: item.artworkUrl100)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.trackName)
                        .font(.system(size: 22, weight: .bold))
                        .fontWeight(.bold)
                        .accessibilityIdentifier("searchDetail.title")

                    Text(item.artistName)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.secondary)
                }

                if let rating = item.averageUserRating {
                    Text("평점: \(rating, specifier: "%.1f")점")
                        .font(.system(size: 14, weight: .regular))
                }

                if item.genres.isEmpty == false {
                    Text("장르: \(item.genres.joined(separator: ", "))")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.secondary)
                }

                if let description = item.description,
                   description.isEmpty == false {
                    Text(description)
                        .font(.system(size: 15, weight: .regular))
                        .lineSpacing(3)
                        .padding(.top, DSSpacing.xs)
                }
            }
        }
    }

    @ViewBuilder
    private func detailArtworkView(urlString: String?) -> some View {
        if let urlString,
           let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 120, height: 120)
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                case .failure:
                    placeholderArtwork
                default:
                    placeholderArtwork
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, DSSpacing.xs)
        } else {
            placeholderArtwork
                .frame(width: 120, height: 120)
                .frame(maxWidth: .infinity)
                .padding(.bottom, DSSpacing.xs)
        }
    }

    private var placeholderArtwork: some View {
        Image(systemName: "photo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 120, height: 120)
            .foregroundStyle(.gray)
    }
}
