//
//  MainView.swift
//  UILayer
//
//  Created by Miso Lubarda on 14.10.20.
//

import Foundation
import SwiftUI

public protocol MainViewDependencies: PopularMoviesViewDependencies {}

public struct MainView: View {
    private let dependencies: MainViewDependencies

    public init(dependencies: MainViewDependencies) {
        self.dependencies = dependencies
    }

    public var body: some View {
        PopularMoviesView(dependencies: dependencies) { movieId in
            MovieDetailsView()
        }
    }
}
