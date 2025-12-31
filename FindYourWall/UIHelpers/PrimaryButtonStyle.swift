//
//  PrimaryButtonStyle.swift
//  FindYourWall
//
//  Created by Max Wayne on 12/31/25.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding()
            .grayscale(isEnabled ? 0 : 1.0)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primaryAction: PrimaryButtonStyle { PrimaryButtonStyle() }
}
