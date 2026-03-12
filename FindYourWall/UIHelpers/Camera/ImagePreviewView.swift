//
//  ImagePreviewView.swift
//  FindYourWall
//
//  Created by Max Wayne on 3/12/26.
//

import SwiftUI

struct ImagePreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    let uiImage: UIImage
    
    @State private var dragAmount = CGSize.zero
    @State private var offset = CGSize.zero
    private var swipeDownGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { gesture in
                self.dragAmount = gesture.translation
            }
            .onEnded { gesture in
                // Check for a significant downward movement
                if gesture.translation.height > 75 && abs(gesture.translation.width) < 50 {
                    self.dismiss()
                } else {
                    self.dragAmount = .zero
                    self.offset = .zero // Reset view position
                }
            }
    }

    var body: some View {
        ZStack {
            Image(uiImage: self.uiImage)
                .resizable()
                .scaledToFit()
        }
        .onTapGesture { self.dismiss() }
        .gesture(self.swipeDownGesture)
    }
}
