//
//  MovieView.swift
//  UILayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import SwiftUI
import DomainLayer

public protocol MovieViewDependencies {
    var posterImageUseCase: PosterImageUseCase { get }
}

struct MovieView: View {
    @ObservedObject private var viewModel: MovieViewModel
    let title: String

    init(dependencies: MovieViewDependencies, id: String, title: String) {
        viewModel = MovieViewModel(dependencies: dependencies, movieId: id)
        self.title = title
    }

    var body: some View {
        VStack {
            Text("\(title)")
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Spacer()
            HStack {
                Spacer()
                Image(uiImage: viewModel.image ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .onAppear(perform: viewModel.load)
                Spacer()
            }
        }
    }
}

private class MovieViewModel: ObservableObject {
    private let dependencies: MovieViewDependencies
    private let movieId: String

    @Published var image: UIImage?

    init(dependencies: MovieViewDependencies, movieId: String) {
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
