//
//  MovieDetailsView.swift
//  UILayer
//
//  Created by Miso Lubarda on 15.10.20.
//

import SwiftUI
import DomainLayer
import Combine

public protocol MovieDetailsViewDependencies {
    var movieDetailsUseCase: MovieDetailsUseCase { get }
    var secondaryPosterImageUseCase: SecondaryPosterImageUseCase { get }
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
            ScrollView {
                Text(viewModel.title)
                    .modifier(TextPrimary())
                    .font(.title)
                Spacer()
                    .frame(height: 10)
                Image(uiImage: viewModel.image ?? UIImage())
                    .resizable()
                    .aspectRatio(viewModel.imageSize, contentMode: .fit)
                Spacer()
                    .frame(height: 10)
                Text(viewModel.date)
                    .modifier(TextPrimary())
                    .font(.caption)
                Spacer()
                    .frame(height: 20)
                Text(viewModel.description)
                    .modifier(TextPrimary())
                    .font(.body)
            }
            .padding(.init(top: 20, leading: 20, bottom: 0, trailing: 20))
            .background(Color.navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: viewModel.load)
        }
    }
}

private class MovieDetailsViewModel: ObservableObject {
    private let dependencies: MovieDetailsViewDependencies
    private let movieId: String
    private var subscribers = [AnyCancellable]()

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
    @Published var image: UIImage?
    @Published var imageSize: CGSize = CGSize(width: 500, height: 280)

    init(dependencies: MovieDetailsViewDependencies, movieId: String) {
        self.dependencies = dependencies
        self.movieId = movieId
    }

    deinit {
        subscribers.forEach { $0.cancel() }
    }

    func load() {
        dependencies.movieDetailsUseCase.fetch(forMovieId: movieId)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: self.showError = false
                case .failure: self.showError = true
                }
            }, receiveValue: { movieDetails in
                self.title = movieDetails.title
                self.description = movieDetails.description
                if let releaseDate = movieDetails.releaseDate {
                    self.date = "Release date: " + self.dateFormatter.string(from: releaseDate)
                }
            })
            .store(in: &subscribers)

        dependencies.secondaryPosterImageUseCase.fetchSecondaryImage(movieId: movieId)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] imageData in
                    if let image = UIImage(data: imageData) {
                        self?.image = image
                        self?.imageSize = image.size
                    }
                  })
            .store(in: &subscribers)
    }
}

//struct MovieDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        MovieDetailsView()
//    }
//}
