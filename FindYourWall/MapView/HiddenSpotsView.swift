//
//  HiddenSpotsView.swift
//  FindYourWall
//

import SwiftUI

struct HiddenSpotsView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: HiddenSpotsViewModel

    init(hiddenSpotsStore: HiddenSpotsStore) {
        self._viewModel = State(wrappedValue: HiddenSpotsViewModel(hiddenSpotsStore: hiddenSpotsStore))
    }

    var body: some View {
        NavigationView {
            Group {
                if self.viewModel.allHiddenSpots.isEmpty {
                    ContentUnavailableView(Constants.emptyTitle,
                                           systemImage: Constants.emptyIcon,
                                           description: Text(Constants.emptyDescription))
                } else {
                    List {
                        ForEach(self.viewModel.allHiddenSpots) { spot in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(spot.name)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                    if let address = spot.address, !address.isEmpty {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Spacer()

                                Button(Constants.unhideButtonTitle) {
                                    self.viewModel.unhide(id: spot.id)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
            }
            .navigationTitle(Constants.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Constants.doneButtonTitle) {
                        self.dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Constants

    private struct Constants {
        static let navigationTitle = "Hidden Spots"
        static let unhideButtonTitle = "Unhide"
        static let doneButtonTitle = "Done"
        static let emptyTitle = "No Hidden Spots"
        static let emptyIcon = "eye"
        static let emptyDescription = "Spots you hide will appear here."
    }
}

#Preview {
    HiddenSpotsView(hiddenSpotsStore: HiddenSpotsStore())
}
