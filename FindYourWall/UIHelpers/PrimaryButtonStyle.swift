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
            .background(self.isEnabled ? self.backgroundColor : Color.gray)
            .foregroundColor(.white)
            .clipShape(.rect(cornerRadius: Constants.cornerRadius))
            .padding()
            // Resolves the label and its background as one geometry unit. Without this they
            // resolve separately while a sheet animates between detents, and the background
            // visibly detaches from the text mid-animation.
            .geometryGroup()
    }

    // MARK: - Constants

    private struct Constants {
        static let cornerRadius: CGFloat = 12
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static func primaryAction(_ color: Color = .blue) -> PrimaryButtonStyle { PrimaryButtonStyle(backgroundColor: color) }
}
