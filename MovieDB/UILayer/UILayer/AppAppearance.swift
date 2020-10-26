//
//  AppAppearance.swift
//  UILayer
//
//  Created by Miso Lubarda on 26.10.20.
//

import SwiftUI

enum AppAppearance {
    static func applyStyle() {
        applyNavigationBarStyle()
    }

    private static func applyNavigationBarStyle() {
        UINavigationBar.appearance().backgroundColor = UIColor(Color.navigationBar)
        UINavigationBar.appearance().barTintColor = UIColor(Color.navigationBar)
        UINavigationBar.appearance().tintColor = UIColor(Color.textPrimary)
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.textPrimary)
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor(Color.textPrimary)
        ]
    }
}
