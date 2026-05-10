//
//  SearchAppStoreListView.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/22/26.
//

import SwiftUI
import AppDomain
import DesignSystem
import UIComponents

/// SearchAppStore 목록 화면을 렌더링하는 View입니다.
public struct SearchAppStoreListView<
    UseCase: SearchAppStoreListUseCaseProtocol,
    Coordinator: SearchAppStoreCoordinatorProtocol
>: View {
    @StateObject private var viewModel: SearchAppStoreListViewModel<UseCase, Coordinator>
    private let searchKeyword: String

    @Environment(\.imagePipeline) private var pipeline
    @Environment(\.displayScale) private var displayScale

    public init(
        viewModel: SearchAppStoreListViewModel<UseCase, Coordinator>,
        searchKeyword: String
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.searchKeyword = searchKeyword
    }

    public var body: some View {
        navigationConfiguredContent
            .task(id: searchKeyword) {
                await viewModel.load(searchKeyword: searchKeyword)
            }
    }

    private var navigationConfiguredContent: some View {
        content
            .navigationTitle("검색 결과")
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
            VStack {
                ProgressView("검색 중...")
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .empty:
            EmptyStateView(title: "검색 결과가 없습니다.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .failure(error):
            ErrorStateView(message: error.localizedDescription) {
                viewModel.retryButtonTapped()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .success(items):
            List(Array(items.enumerated()), id: \.element.trackId) { index, item in
                Button {
                    viewModel.itemTapped(trackId: item.trackId)
                } label: {
                    HStack(alignment: .top, spacing: DSSpacing.sm) {
                        artworkView(
                            artworkUrl100: item.artworkUrl100,
                            artworkUrl512: item.artworkUrl512
                        )

                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            Text(item.trackName)
                                .font(DSTypography.headline)
                                .foregroundStyle(DSColor.textPrimary)
                                .lineLimit(2)

                            Text(item.artistName)
                                .font(DSTypography.body2)
                                .foregroundStyle(DSColor.textSecondary)
                                .lineLimit(1)

                            if let rating = item.averageUserRating {
                                Text("평점: \(rating, specifier: "%.1f")")
                                    .font(DSTypography.caption1)
                                    .foregroundStyle(DSColor.textSecondary)
                            }
                        }
                    }
                    .padding(.vertical, DSSpacing.xs)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("searchResults.item.\(item.trackId)")
                .onAppear {
                    let nextRange = (index + 1)..<min(index + 4, items.count)
                    for nextItem in items[nextRange] {
                        let urls = [nextItem.artworkUrl512, nextItem.artworkUrl100]
                            .compactMap { $0.flatMap { URL(string: $0) } }
                        prefetchRemoteImages(
                            preferredURLs: urls,
                            configuration: .appIconList,
                            displayScale: displayScale,
                            pipeline: pipeline
                        )
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private func artworkView(
        artworkUrl100: String?,
        artworkUrl512: String?
    ) -> some View {
        let urls = [artworkUrl512, artworkUrl100]
            .compactMap { $0.flatMap { URL(string: $0) } }

        RemoteImageView(
            preferredURLs: urls,
            configuration: .appIconList
        )
    }
}
