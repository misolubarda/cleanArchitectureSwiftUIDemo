//
//  MovieDetailsView.swift
//  UILayer
//
//  Created by Miso Lubarda on 15.10.20.
//

import SwiftUI
import DomainLayer

public protocol MovieDetailsViewDependencies {
    var movieDetailsUseCase: MovieDetailsUseCase { get }
}

struct MovieDetailsView: View {
    @ObservedObject private var viewModel: MovieDetailsViewModel

    init(dependencies: MovieDetailsViewDependencies, movieId: String) {
        viewModel = MovieDetailsViewModel(dependencies: dependencies, movieId: movieId)
    }

    var body: some View {
        if self.viewModel.showError {
            ErrorView(errorText: "Something went wrong")
        } else {
            VStack {
                Text(viewModel.title)
                    .font(.title)
                Spacer()
                Text(viewModel.description)
                    .font(.body)
                Spacer()
                Text(viewModel.date)
            }
        }
    }
}

private class MovieDetailsViewModel: ObservableObject {
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()

    @Published var showError: Bool = false
    @Published var title: String = "Loading..."
    @Published var description: String = ""
    @Published var date: String = ""

    init(dependencies: MovieDetailsViewDependencies, movieId: String) {
        dependencies.movieDetailsUseCase.fetch(forMovieId: movieId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(movieDetails):
                self.title = movieDetails.title
                self.description = movieDetails.description
                if let releaseDate = movieDetails.releaseDate {
                    self.date = "Release date: " + self.dateFormatter.string(from: releaseDate)
                }
            case .failure:
                self.showError = true
            }
        }
    }
}

//struct MovieDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        MovieDetailsView()
//    }
//}