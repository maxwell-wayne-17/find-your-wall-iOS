//
//  PrimaryButtonStyle.swift
//  FindYourWall
//
//  Created by Max Wayne on 12/31/25.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isEnabled ? self.backgroundColor : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding()
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static func primaryAction(_ color: Color = .blue) -> PrimaryButtonStyle { PrimaryButtonStyle(backgroundColor: color) }
}
