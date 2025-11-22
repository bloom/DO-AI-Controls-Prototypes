# DO-AI-Controls-Prototypes

iOS prototype application showcasing AI-powered UI controls and interactions for Day One journal app.

![2025-03-25-Figma-Mayne 3](https://github.com/user-attachments/assets/46a002b9-01df-42bc-808c-f0dc919fc0f1)

## Overview

This project is a SwiftUI-based iOS application that prototypes various AI-enhanced features and UI controls for the Day One journaling app. It demonstrates different approaches to presenting AI features, handling user interactions, and managing UI states.

## Features

The app includes multiple prototype views accessible from the main menu:

### 1. Image Generation (v1 & v2)
- **ImageGenerationView**: Basic image generation interface
- **ImageGenerationView2**: Advanced carousel-based image generation with:
  - Three independent rows of generated images
  - Horizontal scrolling carousels with page indicators
  - Dynamic placeholder generation
  - Style picker with 18+ art styles (3D, Anime, Cinematic, etc.)
  - Context menu support for saving and sharing
  - Auto-advance on style changes

### 2. Entry Summary
- **EntrySummaryView**: AI-powered journal entry summarization interface

### 3. Transcribe Audio
- **TranscribeAudioView**: Audio transcription UI with AI integration

### 4. Photo Description
- **PhotoDescriptionView**: Automatic photo description generation
- Caption and media description support
- Photo metadata display (date, location, camera info)
- Favorite toggling
- Keyboard-aware floating panel for editing

### 5. Captions & Descriptions
- **CaptionsDescriptionsView**: Enhanced caption and description editing
- Floating panel design
- Character count validation (280 character limit)
- Focus management for optimal UX

### 6. iOS Native Views
- **IOSNativeViewsView**: Exploration of native iOS UI components and patterns

### 7. Presentation Methods
- **PresentationMethodsView**: Different approaches to presenting modal content
- Sheet presentations
- Custom presentation styles

### 8. Keyboard Accessories
- **KeyboardAccessoriesView**: Keyboard accessory view implementations
- Custom input accessories
- Keyboard-aware layouts

## Technical Architecture

### Design System
- **Accent Color**: `#44C0FF` (bright blue) - consistent across all views
- **Custom Color Extension**: Hex color support for SwiftUI
- **Responsive Design**: Adapts to different screen sizes

### Key Components

#### PhotoDetailView
Full-screen photo viewing with:
- Photo metadata display
- Caption editing
- Favorite marking
- Info panel overlay

#### CaptionSheetView
Floating panel for editing photo captions with:
- Date, time, and timezone display
- Location information
- Caption text field with character limit
- Focus state management
- Dismissible UI

#### KeyboardAwarePanel
Custom container that:
- Monitors keyboard appearance
- Adjusts content position dynamically
- Provides tap-to-dismiss functionality
- Centers content when keyboard is hidden

#### KeyboardObserver
UIViewRepresentable wrapper for:
- Keyboard notification handling
- Height tracking
- Active state monitoring

### UI Patterns

1. **Sheet Presentations**: Used for feature views
2. **Navigation Stack**: Main menu navigation
3. **TabView with PageTabViewStyle**: Carousel implementations
4. **Context Menus**: Long-press actions for images
5. **Focus States**: Keyboard focus management
6. **Custom Presentation Detents**: Large sheet presentations

## Project Structure

```
DO-AI-Controls-Prototypes/
├── DO-AI-Controls/
│   ├── DO_AI_ControlsApp.swift          # App entry point
│   ├── ContentView.swift                # Main menu with feature buttons
│   ├── ImageGenerationView.swift       # Image generation v1
│   ├── ImageGenerationView2.swift      # Image generation v2 (carousel)
│   ├── EntrySummaryView.swift          # Entry summarization
│   ├── TranscribeAudioView.swift       # Audio transcription
│   ├── PhotoDescriptionView.swift      # Photo descriptions
│   ├── CaptionsDescriptionsView.swift  # Caption editing
│   ├── IOSNativeViewsView.swift        # Native views showcase
│   ├── PresentationMethodsView.swift   # Presentation patterns
│   ├── KeyboardAccessoriesView.swift   # Keyboard accessories v1
│   └── KeyboardAccessoryViewsView.swift # Keyboard accessories v2
├── DO-AI-Controls.xcodeproj/
└── README.md
```

## Requirements

- iOS 16.0+
- Xcode 15.0+
- SwiftUI
- Swift 5.9+

## Getting Started

1. Clone the repository
2. Open `DO-AI-Controls.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run (⌘R)

## Development Notes

### State Management
- Uses `@State` for local view state
- `@Binding` for parent-child data flow
- `@Environment` for system values (dismiss, colorScheme)
- `@FocusState` for keyboard focus tracking

### Async Operations
- `DispatchQueue.main.asyncAfter` for simulated image generation
- Delayed focus management for smooth animations
- Keyboard notification handling via NotificationCenter

### Extensions
- `Color(hex:)`: Custom hex color initialization
- `UIImage.gradientImage()`: Gradient image generation for placeholders

## Future Enhancements

- Actual AI model integration
- Real image generation via API
- Persistent data storage
- Enhanced error handling
- Accessibility improvements
- Unit and UI tests

## License

Copyright © 2025 Day One. All rights reserved.

## Author

Paul Mayne
