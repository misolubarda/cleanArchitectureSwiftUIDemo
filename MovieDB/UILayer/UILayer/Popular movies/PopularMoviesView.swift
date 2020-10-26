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
        NavigationView {
            List {
                ForEach(viewModel.listItems, id: \.movieId) { listItem in // *Bug fix
                    ZStack {
                        MovieListItemView(dependencies: dependencies, id: listItem.movieId, title: listItem.title)
                            .background(listItem.backgroundColor)
                            .onAppear { viewModel.moveIdAppeared = listItem.movieId }
                        NavigationLink(destination: detailsView(listItem.movieId), label: EmptyView.init)
                            .buttonStyle(PlainButtonStyle()) // *Bug fix
                    }
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationBarTitle("Popular movies")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: viewModel.loadMore)
        }
    }
}
// *Bug: https://stackoverflow.com/questions/56614080/how-to-remove-the-left-and-right-padding-of-a-list-in-swiftui

private class PopularMoviesViewModel: ObservableObject {
    private let dependencies: PopularMoviesViewDependencies
    @Published var listItems: [ListItem] = []
    var moveIdAppeared: String = "" {
        didSet {
            if moveIdAppeared == listItems.last?.movieId {
                loadMore()
            }
        }
    }

    init(dependencies: PopularMoviesViewDependencies) {
        self.dependencies = dependencies
    }

    func loadMore() {
        dependencies.popularMoviesUseCase.fetchNext { result in
            switch result {
            case let .success(movies):
                self.listItems = movies.listItems
            case .failure:
                break
            }
        }
    }
}

private struct ListItem: Equatable {
    let movieId: String
    let title: String
    let backgroundColor: Color
}

private extension Array where Element == Movie {
    var listItems: [ListItem] {
        enumerated().map { tuple in
            let movie = tuple.element
            let index = tuple.offset
            let colorIndex = index % Color.listItemBackgrounds.count
            let color = Color.listItemBackgrounds[colorIndex]

            return ListItem(movieId: movie.id, title: movie.title, backgroundColor: color)
        }
    }
}

//struct PopularMoviesView_Previews: PreviewProvider {
//    static var previews: some View {
//        PopularMoviesView()
//    }
//}
