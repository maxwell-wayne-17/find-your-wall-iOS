//
//  SheetPreviewHost.swift
//  FindYourWall
//
//  Created by Max Wayne on 1/8/26.
//

import SwiftUI

struct SheetPreviewHost<Content: View>: View {
    let content: Content
    @State private var showSheet = true
    var body: some View {
        Text("Preview Host")
            .sheet(isPresented: self.$showSheet) {
                content
            }
    }
}

#Preview {
    SheetPreviewHost(content: Text(""))
}
