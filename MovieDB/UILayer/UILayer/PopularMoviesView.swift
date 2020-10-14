//
//  PopularMoviesView.swift
//  UILayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import SwiftUI
import DomainLayer

public protocol PopularMoviesViewDependencies {
    var popularMoviesUseCase: PopularMoviesUseCase { get }
}

struct PopularMoviesView<DetailsView>: View where DetailsView: View {
    @ObservedObject private var viewModel: PopularMoviesViewModel
    typealias DetailsViewCallback = (_ movieId: String) -> DetailsView
    let detailsView: DetailsViewCallback

    init(dependencies: PopularMoviesViewDependencies, detailsView: @escaping DetailsViewCallback) {
        viewModel = PopularMoviesViewModel(dependencies: dependencies)
        self.detailsView = detailsView
    }

    var body: some View {
        VStack {
            NavigationView {
                List(viewModel.movies, id: \.id) { movie in
                    NavigationLink(movie.title, destination: detailsView(movie.id))
                        .font(.headline)
                        .lineLimit(2)
                }.navigationBarTitle("Popular movies")
            }
        }
    }
}

private class PopularMoviesViewModel: ObservableObject {
    @Published var movies: [Movie] = []

    init(dependencies: PopularMoviesViewDependencies) {
        dependencies.popularMoviesUseCase.fetch { result in
            switch result {
            case let .success(movies):
                self.movies = movies
            case .failure:
                self.movies = []
            }
        }
    }
}

//struct PopularMoviesView_Previews: PreviewProvider {
//    static var previews: some View {
//        PopularMoviesView()
//    }
//}
