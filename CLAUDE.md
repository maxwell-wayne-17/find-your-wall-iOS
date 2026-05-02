# FindYourWall iOS

An iOS app for finding and saving wall ball spots (lacrosse). Users can search for locations on a map, drop pins manually, and save spots with names, addresses, notes, and photos.

## Build & Test

```bash
# Build
xcodebuild -scheme FindYourWall -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run all tests
xcodebuild -scheme FindYourWall -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a specific test suite
xcodebuild -scheme FindYourWall -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:FindYourWallTests/MapViewModelTests
```

## Architecture

- **SwiftUI + SwiftData** app targeting iOS
- **MVVM** pattern: views have companion `ViewModel` classes using `@Observable`
- **SwiftData** for persistence with `WallBallSpot` as the single `@Model` class
- Model container is set at the app level (`FindYourWallApp.swift`) and injected via environment
- Tests use Swift Testing framework (`@Test`, `#expect`, `@Suite`)


## Code Conventions

- Use `self.` explicitly for all property/method access
- Constants live in private nested `Constants` structs within each type
- Mark sections with `// MARK: -` comments
- Button styles use the `.primaryAction()` extension pattern