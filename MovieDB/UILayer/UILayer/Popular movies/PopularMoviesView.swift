//
//  PopularMoviesView.swift
//  UILayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import SwiftUI
import DomainLayer

public protocol PopularMoviesViewDependencies: MovieListItemViewDependencies {
    var popularMoviesUseCase: PopularMoviesUseCase { get }
}

struct PopularMoviesView<DetailsView>: View where DetailsView: View {
    @ObservedObject private var viewModel: PopularMoviesViewModel
    typealias DetailsViewCallback = (_ movieId: String) -> DetailsView
    let detailsView: DetailsViewCallback
    private let dependencies: PopularMoviesViewDependencies

    init(dependencies: PopularMoviesViewDependencies, detailsView: @escaping DetailsViewCallback) {
        viewModel = PopularMoviesViewModel(dependencies: dependencies)
        self.detailsView = detailsView
        self.dependencies = dependencies
    }

    var body: some View {
        VStack {
            NavigationView {
                List(viewModel.movies, id: \.id) { movie in
                    NavigationLink(destination: detailsView(movie.id)) {
                        MovieListItemView(dependencies: dependencies, id: movie.id, title: movie.title)
                    }
                    .onAppear { viewModel.moveIdAppeared = movie.id }
                }
                .navigationBarTitle("Popular movies")
            }
        }
    }
}

private class PopularMoviesViewModel: ObservableObject {
    private let dependencies: PopularMoviesViewDependencies
    @Published var movies: [Movie] = []
    var moveIdAppeared: String = "" {
        didSet {
            if moveIdAppeared == movies.last?.id {
                loadMore()
            }
        }
    }

    init(dependencies: PopularMoviesViewDependencies) {
        self.dependencies = dependencies

        dependencies.popularMoviesUseCase.fetch { result in
            switch result {
            case let .success(movies):
                self.movies = movies
            case .failure:
                self.movies = []
            }
        }
    }

    func loadMore() {
        dependencies.popularMoviesUseCase.fetchMore { result in
            switch result {
            case let .success(movies):
                self.movies = movies
            case .failure:
                break
            }
        }
    }
}

//struct PopularMoviesView_Previews: PreviewProvider {
//    static var previews: some View {
//        PopularMoviesView()
//    }
//}
