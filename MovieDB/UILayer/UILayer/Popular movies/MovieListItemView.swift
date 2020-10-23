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
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(uiImage: viewModel.image ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .onAppear(perform: viewModel.load)
                Spacer()
            }
            Spacer()
            Text("\(title)")
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
    }
}

private class MovieListItemViewModel: ObservableObject {
    private let dependencies: MovieListItemViewDependencies
    private let movieId: String

    @Published var image: UIImage?

    init(dependencies: MovieListItemViewDependencies, movieId: String) {
        self.dependencies = dependencies
        self.movieId = movieId
    }

    func load() {
        dependencies.posterImageUseCase.fetch(movieId: movieId) { result in
            switch result {
            case let .success(data):
                self.image = UIImage(data: data) ?? UIImage()
            case .failure:
                self.image = nil
            }
        }
    }
}
