# Braille Notepad

[![Deploy to GitHub Pages](https://github.com/MicroSwitchers/dfbraillenotepad/actions/workflows/deploy.yml/badge.svg)](https://github.com/MicroSwitchers/dfbraillenotepad/actions/workflows/deploy.yml)

A beautiful and professional Flutter application that provides Braille input functionality using keyboard keys (fdsjkl) to create Braille characters. This app is designed to be accessible and intuitive for users who need to input Braille text.

## 🚀 Live Demo

**Try it now**: [https://microswitchers.github.io/dfbraillenotepad/](https://microswitchers.github.io/dfbraillenotepad/)

## Features

### 🔤 Braille Input System
- **fdsjkl Key Mapping**: Use the fdsjkl keys to input Braille dots
  - `f` = Dot 1 (top left)
  - `d` = Dot 2 (middle left)
  - `s` = Dot 3 (bottom left)
  - `j` = Dot 4 (top right)
  - `k` = Dot 5 (middle right)
  - `l` = Dot 6 (bottom right)

### 📝 Professional Notepad
- Rich text editing experience
- Real-time character and word count
- Copy/paste functionality
- Clear all functionality
- Professional Material Design UI

### 🎯 Visual Feedback
- Live Braille dot visualization
- Key mapping indicator
- Character preview
- Input status display

### ♿ Accessibility Features
- High contrast design
- Clear visual indicators
- Intuitive keyboard navigation
- Professional styling optimized for accessibility

## How to Use

1. **Launch the App**: Open the Braille Notepad application
2. **Input Braille Characters**: 
   - Hold down the combination of fdsjkl keys for your desired Braille character
   - Release all keys to input the character
   - The app shows a live preview of the character being formed
3. **Text Navigation**:
   - Press Space for word separation
   - Press Backspace to delete characters
   - Press Enter for new lines
4. **Text Management**:
   - Use the menu (⋮) to access copy, paste, and clear functions
   - View character and word count at the bottom

## Installation & Setup

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- A code editor like VS Code with Flutter extensions

### Getting Started

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd braille_notepad
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

### Building for Release

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

#### Windows
```bash
flutter build windows --release
```

### Running on Different Platforms

#### Web Browser
```bash
flutter run -d chrome
```

#### Windows Desktop
```bash
flutter run -d windows
```

## Project Structure

```
lib/
├── main.dart              # App entry point and theme configuration
├── braille_input.dart     # Braille input logic and character mapping
├── braille_notepad.dart   # Main notepad UI and text editing
└── braille_display.dart   # Visual Braille dot display widget

assets/
└── fonts/                 # Font assets (for future Braille fonts)

android/                   # Android-specific configuration
pubspec.yaml              # Project dependencies and configuration
```

## Technical Details

### Architecture
- **State Management**: Built-in Flutter ChangeNotifier pattern
- **UI Framework**: Material Design 3
- **Platform Support**: Android, iOS, Web, Windows, macOS, Linux

### Key Components
- `BrailleInputController`: Handles keyboard input and Braille character mapping
- `BrailleDisplay`: Visual representation of Braille dots and key mapping
- `BrailleNotepad`: Main text editor with professional UI
- `BrailleMapping`: Character mapping between dot patterns and text

### Supported Characters
The app currently supports:
- Complete English alphabet (a-z)
- Basic punctuation (period, comma, question mark, exclamation)
- Space and line breaks
- Extensible mapping system for additional characters

## Customization

### Adding New Braille Characters
Edit the `_mapping` in `BrailleMapping` class in `braille_input.dart`:

```dart
static const Map<Set<int>, BrailleCharacter> _mapping = {
  {1, 2, 3}: BrailleCharacter({1, 2, 3}, 'your_char', '⠇'),
  // Add more mappings here
};
```

### Styling
Modify colors and styling in:
- `main.dart` for app theme
- Individual widget files for component-specific styling

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with Flutter framework
- Inspired by accessibility needs in the visually impaired community
- Material Design 3 components for professional UI
- Unicode Braille patterns for character display

## Support

For questions, issues, or feature requests, please:
1. Check existing issues in the repository
2. Create a new issue with detailed description
3. Include steps to reproduce any bugs

---

**Made with ❤️ for accessibility and inclusion**