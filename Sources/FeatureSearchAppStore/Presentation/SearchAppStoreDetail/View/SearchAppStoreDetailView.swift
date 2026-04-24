//
//  SearchAppStoreDetailView.swift
//  FeatureSearchAppStore
//
//  Created by jch on 4/22/26.
//

import SwiftUI
import AppDomain

/*
 SearchAppStore 상세 화면을 렌더링하는 View입니다.

 이 View는 ViewModel이 제공하는 SearchAppStoreDetailViewState만 관찰하며,
 상세 데이터 렌더링과 재시도 입력 전달만 담당합니다.
 실제 비즈니스 로직은 ViewModel과 Domain UseCase가 담당합니다.
 */
public struct SearchAppStoreDetailView<
    DetailUseCase: SearchAppStoreDetailUseCaseProtocol
>: View {
    @StateObject private var viewModel: SearchAppStoreDetailViewModel<DetailUseCase>
    private let trackId: Int

    public init(
        viewModel: SearchAppStoreDetailViewModel<DetailUseCase>,
        trackId: Int
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.trackId = trackId
    }

    public var body: some View {
        ScrollView {
            content
                .padding()
        }
        .navigationTitle("앱 상세")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: trackId) {
            await viewModel.load(trackId: trackId)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .initial, .loading:
            ProgressView("불러오는 중...")
                .frame(maxWidth: .infinity, minHeight: 240)
            
        case let .error(message):
            VStack(spacing: 16) {
                Text(message)
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
            VStack(alignment: .leading, spacing: 16) {
                detailArtworkView(urlString: item.artworkUrl100)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.trackName)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(item.artistName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let rating = item.averageUserRating {
                    Text("평점: \(rating, specifier: "%.1f")점")
                        .font(.subheadline)
                }

                if item.genres.isEmpty == false {
                    Text("장르: \(item.genres.joined(separator: ", "))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let description = item.description,
                   description.isEmpty == false {
                    Text(description)
                        .font(.body)
                        .padding(.top, 8)
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
                        .frame(maxWidth: .infinity, minHeight: 200)
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)
                case .failure:
                    placeholderArtwork
                default:
                    placeholderArtwork
                }
            }
            .padding(.bottom, 8)
        } else {
            placeholderArtwork
                .frame(maxWidth: .infinity, maxHeight: 200)
                .padding(.bottom, 8)
        }
    }

    private var placeholderArtwork: some View {
        Image(systemName: "photo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.gray)
    }
}
