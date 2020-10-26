//
//  Color+Assets.swift
//  UILayer
//
//  Created by Miso Lubarda on 25.10.20.
//

import SwiftUI

extension Color {
    // MARK: Background
    static let listItemBackground0 = Color.currentBundleColor("listItemBackground0")
    static let listItemBackground1 = Color.currentBundleColor("listItemBackground1")
    static let listItemBackground2 = Color.currentBundleColor("listItemBackground2")
    static let listItemBackground3 = Color.currentBundleColor("listItemBackground3")
    static let listItemBackground4 = Color.currentBundleColor("listItemBackground4")
    static let listItemBackgrounds: [Color] = [listItemBackground0,
                                               listItemBackground1,
                                               listItemBackground2,
                                               listItemBackground3,
                                               listItemBackground4]

    // MARK: Navigation
    static let navigationBar = Color.currentBundleColor("navigationBar")

    // MARK: Text
    static let textPrimary = Color.currentBundleColor("textPrimary")
}

private extension Color {
    static func currentBundleColor(_ name: String) -> Color {
        Color(name, bundle: currentBundle)
    }
}

private class Dummy {}
private let currentBundle = Bundle(for: Dummy.self)
