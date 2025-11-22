# DO-AI-Controls-Prototypes - Project Context

## Project Overview

This is an iOS prototype application built with SwiftUI that showcases AI-powered UI controls and interactions for the Day One journaling app. The project serves as a testbed for exploring different UI/UX patterns, presentation methods, and AI feature integrations.

## Technology Stack

- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **Platform**: iOS 16.0+
- **IDE**: Xcode 15.0+
- **Architecture**: MVVM-like pattern with SwiftUI's declarative approach

## Project Structure

```
DO-AI-Controls-Prototypes/
├── .claude/                             # Claude Code configuration
│   ├── claude.md                        # This file - project context
│   └── settings.local.json              # Local Claude settings
├── DO-AI-Controls/                      # Main source directory
│   ├── DO_AI_ControlsApp.swift         # App entry point and Color extension
│   ├── ContentView.swift               # Main navigation menu with all components
│   ├── ImageGenerationView.swift       # Image generation prototype v1
│   ├── ImageGenerationView2.swift      # Advanced carousel-based generation v2
│   ├── EntrySummaryView.swift          # Entry summarization interface
│   ├── TranscribeAudioView.swift       # Audio transcription UI
│   ├── PhotoDescriptionView.swift      # Photo description generation
│   ├── CaptionsDescriptionsView.swift  # Caption editing interface
│   ├── IOSNativeViewsView.swift        # Native iOS component exploration
│   ├── PresentationMethodsView.swift   # Modal presentation patterns
│   ├── KeyboardAccessoriesView.swift   # Keyboard accessory implementations v1
│   └── KeyboardAccessoryViewsView.swift # Keyboard accessory implementations v2
├── DO-AI-Controls.xcodeproj/           # Xcode project files
└── README.md                            # Project documentation
```

## Design System

### Color Palette
- **Primary Accent**: `#44C0FF` (bright blue) - used consistently across all views
- **Implementation**: Custom `Color(hex:)` extension in DO_AI_ControlsApp.swift

### Typography
- Uses system fonts with semantic styles (headline, subheadline, body, caption)
- Maintains iOS native feel

### UI Components
- **Buttons**: Rounded rectangles with accent color backgrounds (10% opacity)
- **Sheets**: Large presentation detent with drag indicator
- **Carousels**: TabView with PageTabViewStyle
- **Panels**: Floating rounded rectangles with shadows
- **Input Fields**: Rounded text fields with focus state styling

## Key Features & Views

### 1. ContentView (Main Menu)
**Location**: `ContentView.swift`

The main navigation hub with:
- 9 feature buttons in a scrollable vertical layout
- Sheet-based navigation to feature views
- Consistent button styling with accent color
- Navigation title: "Day One AI"

Also contains reusable components:
- `FeatureButton`: Styled button component
- `PhotoDetailView`: Full-screen photo viewer with metadata
- `CaptionSheetView`: Floating panel for caption editing
- `KeyboardAwarePanel`: Container that adapts to keyboard
- `KeyboardObserver`: Keyboard notification handler

**Enums**:
- `AIFeature`: Identifiable enum for routing

### 2. ImageGenerationView2 (Advanced Carousel)
**Location**: `ImageGenerationView2.swift`

The most complex view featuring:
- **Three Independent Rows**: Each with its own carousel state
- **Dynamic Carousels**: Auto-generate placeholders as user scrolls
- **Style Picker**: 18+ art styles (3D, Analog Film, Anime, Cinematic, etc.)
- **Auto-Advance**: All carousels advance to next empty slot on style change
- **Context Menus**: Save to Photos and Share actions
- **Progressive Loading**: Shows loading indicators during generation

**Key Components**:
- `ImageCarouselRow`: Reusable carousel component
- `GeneratedImage`: Model for carousel items
- `ImageStyle`: Enum for art styles

**State Management**:
- Separate state for each row (`row1Images`, `row2Images`, `row3Images`)
- Separate page tracking (`row1CurrentPage`, etc.)
- Style selection state

### 3. Photo Description Features
**Location**: Multiple files (PhotoDescriptionView, CaptionsDescriptionsView)

Features include:
- **Caption Editing**: Character limit (280), focus management
- **Media Descriptions**: Long-form AI-generated descriptions
- **Metadata Display**: Date, time, timezone, location, camera info
- **Favorite Toggle**: Heart icon with state persistence
- **Keyboard Awareness**: Panel repositions when keyboard appears

**Models**:
- `PhotoMetadata`: Stores photo information

### 4. Keyboard Management
**Location**: `ContentView.swift` (components)

Custom keyboard handling via:
- `KeyboardAwarePanel`: Wrapper that positions content above keyboard
- `KeyboardObserver`: UIViewRepresentable for notifications
- Animated transitions
- Tap-to-dismiss background overlay

## State Management Patterns

### SwiftUI Property Wrappers
- `@State`: Local view state
- `@Binding`: Parent-child data flow
- `@Environment(\.dismiss)`: Sheet dismissal
- `@Environment(\.colorScheme)`: Dark/light mode
- `@FocusState`: Keyboard focus tracking

### Data Flow
1. **Top-Down**: Parent passes data via bindings
2. **Bottom-Up**: Child calls closure callbacks
3. **Environment**: System values injected via environment

## Common Patterns

### Sheet Presentation
```swift
.sheet(item: $selectedFeature) { feature in
    switch feature {
    case .imageGeneration:
        ImageGenerationView()
    // ...
    }
}
```

### Carousel with Dynamic Content
```swift
TabView(selection: $currentPage) {
    ForEach(Array(images.enumerated()), id: \.element.id) { index, item in
        // Content
    }
    .tag(index)
}
.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
```

### Focus Management
```swift
@FocusState private var isFocused: Bool

TextField("Placeholder", text: $text)
    .focused($isFocused)
    .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isFocused = true
        }
    }
```

### Context Menus
```swift
.contextMenu {
    Button {
        // Action
    } label: {
        Label("Save", systemImage: "photo.on.rectangle")
    }
}
```

## Important Implementation Details

### Image Generation Simulation
Currently uses placeholder gradient images:
- Random color selection
- 2-second delay to simulate API call
- `UIImage.gradientImage()` extension method

### Keyboard Handling
- Uses NotificationCenter for keyboard events
- `keyboardWillShowNotification` and `keyboardWillHideNotification`
- Animates content position based on keyboard height
- 8pt bottom padding when keyboard is visible

### Carousel Behavior
- Auto-adds placeholder when viewing last item
- Generates image when placeholder becomes visible
- Uses `.id()` modifier to force TabView refresh
- 0.3s delay for smooth animations

### Photo Metadata
Sample metadata hardcoded for demonstration:
- Multiple `PhotoMetadata` instances
- Real DateFormatter usage
- Realistic camera and location data

## Code Style & Conventions

### Naming
- Views: Descriptive names ending in "View" (e.g., `ImageGenerationView2`)
- Properties: camelCase with descriptive names
- Constants: camelCase (not SCREAMING_SNAKE_CASE)
- Private helpers: prefixed with "private"

### Organization
- Extensions at top of app file
- Main view body comes first
- Helper views and components follow
- Private methods at bottom
- Preview at very end

### SwiftUI Best Practices
- Use `VStack`, `HStack`, `ZStack` for layout
- Prefer modifiers over custom UIKit wrapping
- Extract complex views into separate components
- Use `@ViewBuilder` for conditional content
- Keep view bodies under 10 expressions when possible

## Development Workflow

### Building and Running
1. Open `DO-AI-Controls.xcodeproj` in Xcode
2. Select iOS simulator or device
3. Build (⌘B) and Run (⌘R)
4. No external dependencies or API keys needed

### Testing Features
- Navigate from main menu
- All features are self-contained
- No network calls (everything is simulated)
- Safe to run on any iOS 16+ device

## Known Limitations

1. **No Real AI Integration**: All AI features are simulated with placeholders
2. **No Persistence**: No CoreData or file storage
3. **Sample Data**: Hardcoded photos and metadata
4. **No Error Handling**: Assumes happy path
5. **Limited Accessibility**: No VoiceOver optimization
6. **No Tests**: No unit or UI tests

## Future Enhancement Ideas

- Integrate real AI models (CoreML, OpenAI API)
- Add persistent storage (CoreData, CloudKit)
- Implement photo library integration
- Add proper error handling and loading states
- Enhance accessibility with VoiceOver
- Add unit and UI tests
- Implement user authentication
- Add settings and preferences
- Support for iPad layouts
- Localization for multiple languages

## Common Tasks

### Adding a New Feature View
1. Create new Swift file in `DO-AI-Controls/`
2. Define SwiftUI view struct
3. Add case to `AIFeature` enum in ContentView.swift
4. Add button in ContentView body
5. Add case to sheet switch statement

### Modifying the Accent Color
Change hex value in `ContentView.swift` and other views:
```swift
let accentColor = Color(hex: "44C0FF") // Change this
```

### Adding a New Art Style
Add to `ImageStyle` enum and update styles array:
```swift
enum ImageStyle: String, CaseIterable {
    // Add new case
    case newStyle = "New Style"
}
```

## Git Information

- **Current Branch**: main
- **Main Branch**: main
- **Status**: Clean working directory

## Contact

**Author**: Paul Mayne
**Project**: Day One AI Controls Prototype
**Created**: March 25, 2025
