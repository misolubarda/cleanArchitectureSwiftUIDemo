//
//  Text+Default.swift
//  UILayer
//
//  Created by Miso Lubarda on 25.10.20.
//

import SwiftUI

struct TextPrimary: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.textPrimary)
    }
}
