//
//  MovieListItemView.swift
//  UILayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import SwiftUI
import DomainLayer

public protocol MovieListItemViewDependencies {
    var posterImageUseCase: PosterImageUseCase { get }
}

struct MovieListItemView: View {
    @ObservedObject private var viewModel: MovieListItemViewModel
    let title: String

    init(dependencies: MovieListItemViewDependencies, id: String, title: String) {
        viewModel = MovieListItemViewModel(dependencies: dependencies, movieId: id)
        self.title = title
        viewModel.load()
    }

    var body: some View {
        VStack {
            Spacer().frame(height: 30)
            HStack {
                Spacer().frame(width: 60)
                Image(uiImage: viewModel.image ?? UIImage())
                    .resizable()
                    .aspectRatio(viewModel.imageSize, contentMode: .fill)
                Spacer().frame(width: 60)
            }
            Spacer().frame(height: 10)
            Text("\(title)")
                .modifier(TextPrimary())
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Spacer().frame(height: 30)
        }
    }
}

private class MovieListItemViewModel: ObservableObject {
    private let dependencies: MovieListItemViewDependencies
    private let movieId: String
    private var subscription: AnyCancellable?

    @Published var image: UIImage?
    @Published var imageSize: CGSize = CGSize(width: 400, height: 600)

    init(dependencies: MovieListItemViewDependencies, movieId: String) {
        self.dependencies = dependencies
        self.movieId = movieId
    }

    deinit {
        subscription?.cancel()
    }

    func load() {
        subscription = dependencies.posterImageUseCase.fetch(movieId: movieId)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished: break
                case .failure: self?.image = nil
                }
            }, receiveValue: { [weak self] data in
                if let image = UIImage(data: data) {
                    self?.image = image
                    self?.imageSize = image.size
                } else {
                    self?.image = nil
                }
            })
    }
}
