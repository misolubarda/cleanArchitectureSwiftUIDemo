//
//  ErrorView.swift
//  UILayer
//
//  Created by Miso Lubarda on 15.10.20.
//

import SwiftUI

struct ErrorView: View {
    @State var errorText: String = ""

    var body: some View {
        Text(errorText)
            .font(.callout)
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
    }
}
