# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

All building, testing, and running is done through Xcode. Use `xcodebuild` from the command line when needed:

```bash
# Build the app
xcodebuild -project FindYourWall.xcodeproj -scheme FindYourWall -sdk iphonesimulator build

# Run all unit tests
xcodebuild test -project FindYourWall.xcodeproj -scheme FindYourWall -destination 'platform=iOS Simulator,name=iPhone 16'

# Run a single test file (e.g., SpotSaveFormViewModelTests)
xcodebuild test -project FindYourWall.xcodeproj -scheme FindYourWall -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:FindYourWallTests/SpotSaveFormViewModelTests
```

## Architecture

**Find Your Wall** is a SwiftUI app for discovering and saving wall ball spots on a map. It uses MVVM with these frameworks:
- **SwiftData** for persistence (`@Model`, `@Query`, `modelContainer`)
- **MapKit + CoreLocation** for maps and location (`MKLocalSearch`, `CLLocationManager`)
- **Swift Testing** (not XCTest) for all unit tests — use `@Suite`, `@Test`, `#expect()`

### Data Flow

`LocalWallBallSpot` is the sole SwiftData model. It is inserted into the model context in `FindYourWallApp` and queried via `@Query` in `MapView`. The model container is currently configured as **in-memory** (not persistent) — there's a known TODO to switch this.

### Navigation

The app is a single-screen experience anchored in `MapView`. All sub-screens are sheets:
- Tap a search result marker → `MarkerSheetView` → tap "Add" → `SpotSaveFormView` (init from `MKMapItem`)
- Tap a saved spot marker → `LocalWallBallSpotSheetView` → tap "Edit" → `SpotSaveFormView` (init from `LocalWallBallSpot`)
- Tap the FAB → pin-placement mode → tap the map → `MarkerSheetView`

Sheet visibility is controlled by boolean `@State` flags on `MapView` (`showMarkerSheet`, `showLocalSpotSheet`). Marker selection uses integer tags on `MapViewModel.selectedTag`; tag `-1` is reserved for user-placed pins.

### Key Files

| File | Role |
|------|------|
| `FindYourWall/MapView/MapViewModel.swift` | Location management, map camera, MKLocalSearch, marker selection |
| `FindYourWall/MapView/Model/LocalWallBallSpot.swift` | SwiftData model; includes `init(from: MKMapItem)` |
| `FindYourWall/SaveForm/SpotSaveFormViewModel.swift` | Form state, ZIP filtering (5 digits), validation |
| `FindYourWall/UIHelpers/PrimaryButtonStyle.swift` | Shared button style (blue, rounded, grayscale when disabled) |

### Conventions

- ViewModels use the `@Observable` macro (not `ObservableObject`/`@Published`)
- Views reference ViewModels with `@Bindable` (not `@ObservedObject`)
- `SpotSaveFormViewModel` has two inits: `init(mapItem:)` and `init(spot:)` for create vs. edit flows
- The ZIP code setter filters input to exactly 5 numeric characters via `willSet`
