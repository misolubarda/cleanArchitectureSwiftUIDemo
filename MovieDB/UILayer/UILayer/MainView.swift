//
//  MainView.swift
//  UILayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation
import SwiftUI

public protocol MainViewDependencies: PopularMoviesViewDependencies, MovieDetailsViewDependencies {}

public struct MainView: View {
    private let dependencies: MainViewDependencies

    public init(dependencies: MainViewDependencies) {
        self.dependencies = dependencies
        UINavigationBar.appearance().backgroundColor = UIColor(Color.navigationBar)
        UILabel.appearance().textColor = UIColor(Color.textPrimary)
    }

    public var body: some View {
        PopularMoviesView(dependencies: dependencies) { movieId in
            MovieDetailsView(dependencies: dependencies, movieId: movieId)
        }
    }
}
