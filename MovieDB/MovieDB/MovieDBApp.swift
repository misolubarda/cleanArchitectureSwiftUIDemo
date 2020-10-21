//
//  MovieDBApp.swift
//  MovieDB
//
//  Created by Miso Lubarda on 14.10.20.
//

import SwiftUI
import UILayer

@main
struct MovieDBApp: App {
    var body: some Scene {
        WindowGroup {
            if isTestTarget {
                Spacer()
            } else {
                MainView(dependencies: AppDependencies())
            }
        }
    }
}

private var isTestTarget: Bool { NSClassFromString("MovieDBTests.MovieDBTests") != nil }
