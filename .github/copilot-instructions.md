# Braille Notepad - Flutter Project Instructions

## Project Overview
This is a Flutter application that creates a professional Braille notepad where users can input Braille dots using the sdfjkl keys on their keyboard.

## Key Features
- Braille input using sdfjkl key mapping (s=dot1, d=dot2, f=dot3, j=dot4, k=dot5, l=dot6)
- Visual representation of Braille characters
- Text editing and notepad functionality
- Professional and accessible UI design

## Development Guidelines
- Use Flutter best practices for state management
- Implement proper keyboard event handling
- Create accessible and inclusive design
- Follow Material Design principles
- Test on multiple devices and screen sizes

## Key Mapping
- f = Braille dot 1 (top left)
- d = Braille dot 2 (middle left) 
- s = Braille dot 3 (bottom left)
- j = Braille dot 4 (top right)
- k = Braille dot 5 (middle right)
- l = Braille dot 6 (bottom right)

## Progress
- [x] Created project structure
- [x] Implemented Braille input system
- [x] Created Braille paper notepad UI
- [x] Added Braille cell visualization
- [x] Implemented professional styling
- [x] Added compact input indicator
- [x] App successfully running in Chrome browser

## Features
- **True Notepad Experience**: Write and edit text using Braille characters in lines
- **Live Input Feedback**: Compact corner indicator shows current dot pattern being formed  
- **Line-based Writing**: Proper line breaks, cursor positioning, and text flow
- **Professional Design**: Clean, focused interface for productive writing
- **Real-time Editing**: Backspace, enter, space work as expected in a notepad

## How to Run
1. Open terminal in project directory
2. Run `flutter pub get` to get dependencies
3. Run `flutter run -d chrome` to launch in browser
4. Or run `flutter run` for other platforms

## Usage
- **Braille Input**: Press down a cluster of fdsjkl keys for your desired character
- **Confirm Character**: Release ANY key from the cluster to confirm and add the Braille cell
- **Cursor Movement**: Cursor automatically moves to next position after each character
- **Line Navigation**: Use Enter for new lines, Space for word breaks, Backspace to delete
- **Live Feedback**: Blue corner indicator shows current dot pattern being formed
- **Continuous Writing**: Type one character after another without lifting all fingers