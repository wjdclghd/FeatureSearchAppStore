//
//  SearchAppStoreListView.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/22/26.
//

import SwiftUI
import AppDomain

/*
 SearchAppStore 목록 화면을 렌더링하는 View입니다.

 이 View는 ViewModel이 제공하는 SearchAppStoreListViewState만 관찰하며,
 목록 데이터 렌더링과 사용자 입력 전달만 담당합니다.
 실제 비즈니스 로직과 화면 이동 결정은 ViewModel과 App 레이어 coordinator가 담당합니다.
 */
public struct SearchAppStoreListView<
    UseCase: SearchAppStoreListUseCaseProtocol,
    Coordinator: SearchAppStoreCoordinatorProtocol
>: View {
    @StateObject private var viewModel: SearchAppStoreListViewModel<UseCase, Coordinator>
    private let searchKeyword: String

    public init(
        viewModel: SearchAppStoreListViewModel<UseCase, Coordinator>,
        searchKeyword: String
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.searchKeyword = searchKeyword
    }

    public var body: some View {
        content
            .navigationTitle("검색 결과")
            .task(id: searchKeyword) {
                await viewModel.load(searchKeyword: searchKeyword)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .initial, .loading:
            VStack {
                ProgressView("검색 중...")
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .noResults:
            VStack {
                Text("검색 결과가 없습니다.")
                    .foregroundStyle(.secondary)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .error(message):
            VStack(spacing: 16) {
                Text(message)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)

                Button("다시 시도") {
                    Task {
                        await viewModel.load(searchKeyword: searchKeyword)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .loaded(items):
            List(items) { item in
                Button {
                    viewModel.didSelectItem(item)
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        artworkView(urlString: item.artworkUrl100)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.trackName)
                                .font(.headline)

                            Text(item.artistName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            if let rating = item.averageUserRating {
                                Text("평점: \(rating, specifier: "%.1f")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private func artworkView(urlString: String?) -> some View {
        if let urlString,
           let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 60, height: 60)
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                case .failure:
                    placeholderArtwork
                default:
                    placeholderArtwork
                }
            }
        } else {
            placeholderArtwork
        }
    }

    private var placeholderArtwork: some View {
        Image(systemName: "photo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 60, height: 60)
            .foregroundStyle(.gray)
    }
}
