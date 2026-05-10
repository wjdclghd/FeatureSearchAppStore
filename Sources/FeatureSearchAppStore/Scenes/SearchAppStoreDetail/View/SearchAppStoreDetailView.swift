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

/// SearchAppStore 상세 화면을 렌더링하는 View입니다.
public struct SearchAppStoreDetailView<
    DetailUseCase: SearchAppStoreDetailUseCaseProtocol,
    Coordinator: SearchAppStoreCoordinatorProtocol
>: View {
    @StateObject private var viewModel: SearchAppStoreDetailViewModel<DetailUseCase, Coordinator>
    private let trackId: Int

    public init(
        viewModel: SearchAppStoreDetailViewModel<DetailUseCase, Coordinator>,
        trackId: Int
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                    viewModel.backButtonTapped()
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState.loadState {
        case .idle, .loading:
            ProgressView("불러오는 중...")
                .frame(maxWidth: .infinity, minHeight: 240)

        case let .failure(error):
            ErrorStateView(message: error.localizedDescription) {
                viewModel.retryButtonTapped()
            }
            .frame(maxWidth: .infinity, minHeight: 240)

        case let .success(item):
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                detailArtworkView(
                    artworkUrl100: item.artworkUrl100,
                    artworkUrl512: item.artworkUrl512
                )

                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text(item.trackName)
                        .font(DSTypography.title1)
                        .foregroundStyle(DSColor.textPrimary)
                        .accessibilityIdentifier("searchDetail.title")

                    Text(item.artistName)
                        .font(DSTypography.body2)
                        .foregroundStyle(DSColor.textSecondary)
                }

                if let rating = item.averageUserRating {
                    Text("평점: \(rating, specifier: "%.1f")점")
                        .font(DSTypography.body2)
                        .foregroundStyle(DSColor.textPrimary)
                }

                if item.genres.isEmpty == false {
                    Text("장르: \(item.genres.joined(separator: ", "))")
                        .font(DSTypography.caption1)
                        .foregroundStyle(DSColor.textSecondary)
                }

                if let description = item.description,
                   description.isEmpty == false {
                    Text(description)
                        .font(DSTypography.body1)
                        .foregroundStyle(DSColor.textPrimary)
                        .lineSpacing(3)
                        .padding(.top, DSSpacing.xs)
                }
            }
        }
    }

    @ViewBuilder
    private func detailArtworkView(
        artworkUrl100: String?,
        artworkUrl512: String?
    ) -> some View {
        let urls = [artworkUrl512, artworkUrl100]
            .compactMap { $0.flatMap { URL(string: $0) } }

        RemoteImageView(
            preferredURLs: urls,
            configuration: .appIconDetail
        )
        .frame(maxWidth: .infinity)
        .padding(.bottom, DSSpacing.xs)
    }
}
