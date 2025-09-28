# 😊 Emoji Keyboard for macOS

A floating emoji keyboard app for macOS that provides quick access to all iOS Apple emojis with direct insertion into any application.

## ✨ Features

- **Floating Window**: Always-on-top window that works across all applications
- **Direct Insertion**: Uses Accessibility API to insert emojis directly into text fields
- **Full Emoji Library**: Complete Unicode emoji collection organized by categories
- **Recent Emojis**: Track and quick access to recently used emojis
- **Search**: Find emojis quickly with text search
- **Categories**: Organized into Smileys & People, Animals & Nature, Food & Drink, Travel & Places, Activities, Objects, Symbols, and Flags
- **Fallback Support**: Automatic clipboard+paste fallback when accessibility permissions aren't available
- **System Integration**: Status bar icon for easy access

## 🛠 Technology Stack

- **Swift + AppKit**: Core window management and system integration
- **SwiftUI**: Modern UI components for emoji grid and interface
- **Accessibility APIs**: Direct text insertion using macOS accessibility framework
- **Unicode**: System emoji data with proper categorization

## 📋 Requirements

- macOS 12.0 or later
- Xcode 14.0 or later for building
- Accessibility permissions (optional, but recommended for direct insertion)

## 🚀 Getting Started

### Building from Source

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd emoji-keyboard
   ```

2. **Open in Xcode**:
   ```bash
   open EmojiKeyboard.xcodeproj
   ```

3. **Build and Run**:
   - Select your target device
   - Press `⌘R` to build and run

### First Launch Setup

1. **Launch the app** - A floating window will appear with the emoji keyboard
2. **Grant Accessibility Permissions** (recommended):
   - Go to System Preferences > Security & Privacy > Privacy
   - Select "Accessibility" from the left sidebar
   - Click the lock icon and enter your password
   - Find "Emoji Keyboard" and check the box
   - Restart the app if needed

3. **Start Using**:
   - Click any emoji to insert it into the currently focused text field
   - Use the status bar icon (😊) to show/hide the keyboard
   - Browse categories or use search to find specific emojis

## 📱 Usage

### Basic Usage
- **Click an emoji**: Inserts directly into the active text field
- **Recent emojis**: Access your most-used emojis quickly
- **Categories**: Browse emojis by type using the category tabs
- **Search**: Use the search icon to find specific emojis

### Keyboard Shortcuts
- **Status bar toggle**: Click the 😊 icon in the menu bar
- **Window management**: Standard macOS window controls

### Permission Modes
- **With Accessibility Permission**: Direct insertion into any application
- **Without Permission**: Copies to clipboard and simulates ⌘V paste

## 🏗 Architecture

### Project Structure
```
EmojiKeyboard/
├── App/
│   └── AppDelegate.swift          # Main app lifecycle
├── Windows/
│   └── FloatingEmojiWindow.swift  # Floating window management
├── Services/
│   ├── EmojiDataService.swift     # Emoji data loading and management
│   ├── EmojiInserter.swift        # Text insertion logic
│   └── AccessibilityManager.swift # Permission handling
├── Models/
│   └── EmojiCategory.swift        # Data models
├── Views/
│   └── EmojiGridView.swift        # SwiftUI interface
└── Resources/
    ├── Info.plist                 # App configuration
    ├── EmojiKeyboard.entitlements # Security permissions
    └── Assets.xcassets            # App icons and assets
```

### Key Components

#### AppDelegate
- Manages app lifecycle
- Sets up status bar integration
- Handles window creation and management

#### FloatingEmojiWindow
- Always-on-top window configuration
- Transparent background with rounded corners
- Integrates SwiftUI content with AppKit window

#### EmojiDataService
- Loads Unicode emoji data from system
- Organizes emojis into categories
- Manages recent emoji tracking
- Provides search functionality

#### EmojiInserter
- Handles direct text insertion via Accessibility APIs
- Fallback to clipboard+paste method
- Keyboard event simulation for compatibility

#### AccessibilityManager
- Manages accessibility permission requests
- Monitors permission status
- Provides helper methods for text field interaction

## 🔧 Development

### Adding New Features

#### Adding New Emoji Categories
```swift
// In EmojiDataService.swift
private func generateEmojiCategories() -> [EmojiCategory] {
    // Add new Unicode ranges here
    let emojiRanges: [(range: ClosedRange<Int>, category: String)] = [
        // Add your new range
        (0x1F900...0x1F9FF, "Your New Category")
    ]
}
```

#### Customizing UI
- Modify `EmojiGridView.swift` for interface changes
- Update `FloatingEmojiWindow.swift` for window behavior
- Adjust colors and styling in SwiftUI views

#### Enhancing Search
```swift
// In EmojiDataService.swift
func searchEmojis(query: String) -> [String] {
    // Enhance search algorithm here
    // Could add emoji name/description matching
}
```

### Building for Distribution

1. **Code Signing**: Configure your developer team in Xcode
2. **Entitlements**: Review security entitlements for your use case
3. **Notarization**: For distribution outside App Store
4. **App Store**: Follow App Store guidelines if submitting

## 🔒 Security & Privacy

- **Accessibility Permission**: Only used for emoji insertion, no data collection
- **No Network Access**: All emoji data is local to your system
- **No Data Tracking**: Recent emojis stored locally in UserDefaults
- **Sandboxing**: Disabled for accessibility features, but app follows security best practices

## 🐛 Troubleshooting

### Common Issues

**Emojis not inserting directly**:
- Check accessibility permissions in System Preferences
- Try restarting the app after granting permissions
- Fallback mode (clipboard) should work in all cases

**Window not staying on top**:
- Check if "Displays have separate Spaces" is disabled in Mission Control preferences
- Try toggling the window visibility via status bar

**Missing emojis**:
- Ensure you're running macOS 12.0 or later
- Some newer emojis may not be available on older systems

## 📄 License

[Add your license information here]

## 🤝 Contributing

[Add contribution guidelines here]

## 📞 Support

[Add support information here]

---

**Note**: This app requires macOS 12.0+ and benefits from accessibility permissions for the best user experience. 