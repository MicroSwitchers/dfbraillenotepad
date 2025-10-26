import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Represents a Braille character with its dot pattern and corresponding text
class BrailleCharacter {
  final Set<int> dots;
  final String character;
  final String brailleUnicode;

  const BrailleCharacter(this.dots, this.character, this.brailleUnicode);
}

/// Maps Braille dot patterns to characters
class BrailleMapping {
  static const Map<Set<int>, BrailleCharacter> _mapping = {
    {1}: BrailleCharacter({1}, 'a', '⠁'),
    {1, 2}: BrailleCharacter({1, 2}, 'b', '⠃'),
    {1, 4}: BrailleCharacter({1, 4}, 'c', '⠉'),
    {1, 4, 5}: BrailleCharacter({1, 4, 5}, 'd', '⠙'),
    {1, 5}: BrailleCharacter({1, 5}, 'e', '⠑'),
    {1, 2, 4}: BrailleCharacter({1, 2, 4}, 'f', '⠋'),
    {1, 2, 4, 5}: BrailleCharacter({1, 2, 4, 5}, 'g', '⠛'),
    {1, 2, 5}: BrailleCharacter({1, 2, 5}, 'h', '⠓'),
    {2, 4}: BrailleCharacter({2, 4}, 'i', '⠊'),
    {2, 4, 5}: BrailleCharacter({2, 4, 5}, 'j', '⠚'),
    {1, 3}: BrailleCharacter({1, 3}, 'k', '⠅'),
    {1, 2, 3}: BrailleCharacter({1, 2, 3}, 'l', '⠇'),
    {1, 3, 4}: BrailleCharacter({1, 3, 4}, 'm', '⠍'),
    {1, 3, 4, 5}: BrailleCharacter({1, 3, 4, 5}, 'n', '⠝'),
    {1, 3, 5}: BrailleCharacter({1, 3, 5}, 'o', '⠕'),
    {1, 2, 3, 4}: BrailleCharacter({1, 2, 3, 4}, 'p', '⠏'),
    {1, 2, 3, 4, 5}: BrailleCharacter({1, 2, 3, 4, 5}, 'q', '⠟'),
    {1, 2, 3, 5}: BrailleCharacter({1, 2, 3, 5}, 'r', '⠗'),
    {2, 3, 4}: BrailleCharacter({2, 3, 4}, 's', '⠎'),
    {2, 3, 4, 5}: BrailleCharacter({2, 3, 4, 5}, 't', '⠞'),
    {1, 3, 6}: BrailleCharacter({1, 3, 6}, 'u', '⠥'),
    {1, 2, 3, 6}: BrailleCharacter({1, 2, 3, 6}, 'v', '⠧'),
    {2, 4, 5, 6}: BrailleCharacter({2, 4, 5, 6}, 'w', '⠺'),
    {1, 3, 4, 6}: BrailleCharacter({1, 3, 4, 6}, 'x', '⠭'),
    {1, 3, 4, 5, 6}: BrailleCharacter({1, 3, 4, 5, 6}, 'y', '⠽'),
    {1, 3, 5, 6}: BrailleCharacter({1, 3, 5, 6}, 'z', '⠵'),
    
    // Numbers (preceded by number sign ⠼)
    {1, 2, 4, 5, 6}: BrailleCharacter({1, 2, 4, 5, 6}, '0', '⠼⠚'),
    
    // Common punctuation
    {}: BrailleCharacter({}, ' ', ' '), // Space
    {2, 5, 6}: BrailleCharacter({2, 5, 6}, '.', '⠲'),
    {2, 3}: BrailleCharacter({2, 3}, ',', '⠂'),
    {2, 3, 6}: BrailleCharacter({2, 3, 6}, '?', '⠦'),
    {2, 3, 5}: BrailleCharacter({2, 3, 5}, '!', '⠖'),
  };

  static BrailleCharacter? getCharacter(Set<int> dots) {
    return _mapping[dots];
  }

  static Set<int> normalizeDots(Set<int> dots) {
    return dots.where((dot) => dot >= 1 && dot <= 6).toSet();
  }
}

/// Controller for handling Braille input using fdsjkl keys
class BrailleInputController extends ChangeNotifier {
  final Set<LogicalKeyboardKey> _pressedKeys = {};
  final Set<int> _currentDots = {};
  final List<BrailleCharacter> _brailleCells = [];
  String _text = '';
  bool _isInputActive = false;
  int _currentPosition = 0;

  // Key mapping: f=1, d=2, s=3, j=4, k=5, l=6
  final Map<LogicalKeyboardKey, int> _keyToDot = {
    LogicalKeyboardKey.keyF: 1,
    LogicalKeyboardKey.keyD: 2,
    LogicalKeyboardKey.keyS: 3,
    LogicalKeyboardKey.keyJ: 4,
    LogicalKeyboardKey.keyK: 5,
    LogicalKeyboardKey.keyL: 6,
  };

  String get text => _text;
  Set<int> get currentDots => Set.from(_currentDots);
  bool get isInputActive => _isInputActive;
  List<BrailleCharacter> get brailleCells => List.from(_brailleCells);
  int get currentPosition => _currentPosition;

  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _handleKeyDown(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _handleKeyUp(event.logicalKey);
    }
  }

  void _handleKeyDown(LogicalKeyboardKey key) {
    if (_keyToDot.containsKey(key)) {
      if (!_pressedKeys.contains(key)) {
        _pressedKeys.add(key);
        _currentDots.add(_keyToDot[key]!);
        _isInputActive = true;
        notifyListeners();
      }
    } else if (key == LogicalKeyboardKey.space) {
      // Only process space if not currently inputting Braille
      if (!_isInputActive) {
        _addCharacter(' ');
      }
    } else if (key == LogicalKeyboardKey.backspace) {
      // Only process backspace if not currently inputting Braille
      if (!_isInputActive) {
        _deleteCharacter();
      }
    } else if (key == LogicalKeyboardKey.enter) {
      // Only process enter if not currently inputting Braille
      if (!_isInputActive) {
        _addCharacter('\n');
      }
    }
  }

  void _handleKeyUp(LogicalKeyboardKey key) {
    if (_keyToDot.containsKey(key)) {
      // As soon as ANY Braille key is released, and we have input active, process the cluster
      if (_isInputActive && _pressedKeys.isNotEmpty) {
        _processCurrentDots();
        _isInputActive = false;
        _pressedKeys.clear();
        _currentDots.clear();
      }
      notifyListeners();
    }
  }

  void _processCurrentDots() {
    final normalizedDots = BrailleMapping.normalizeDots(_currentDots);
    final brailleChar = BrailleMapping.getCharacter(normalizedDots);
    
    if (brailleChar != null) {
      _addBrailleCell(brailleChar);
      _text += brailleChar.character;
    } else if (normalizedDots.isNotEmpty) {
      // Unknown pattern - create a placeholder character
      final unknownChar = BrailleCharacter(normalizedDots, '?', '⠿');
      _addBrailleCell(unknownChar);
      _text += '?';
    }
    notifyListeners();
  }

  void _addBrailleCell(BrailleCharacter brailleChar) {
    if (_currentPosition < _brailleCells.length) {
      _brailleCells[_currentPosition] = brailleChar;
    } else {
      _brailleCells.add(brailleChar);
    }
    _currentPosition++;
    notifyListeners();
  }

  void _addCharacter(String char) {
    if (char == ' ') {
      // Add a space cell
      const spaceChar = BrailleCharacter(<int>{}, ' ', ' ');
      _addBrailleCell(spaceChar);
      _text += char;
    } else if (char == '\n') {
      // Add a newline cell
      const newlineChar = BrailleCharacter(<int>{}, '\n', '↵');
      _addBrailleCell(newlineChar);
      _text += char;
    }
    notifyListeners();
  }

  void _deleteCharacter() {
    if (_brailleCells.isNotEmpty && _currentPosition > 0) {
      _currentPosition--;
      _brailleCells.removeAt(_currentPosition);
      
      if (_text.isNotEmpty) {
        _text = _text.substring(0, _text.length - 1);
      }
      notifyListeners();
    }
  }

  void setText(String newText) {
    _text = newText;
    // TODO: Could rebuild braille cells from text if needed
    notifyListeners();
  }

  void clearText() {
    _text = '';
    _brailleCells.clear();
    _currentPosition = 0;
    _currentDots.clear();
    _pressedKeys.clear();
    _isInputActive = false;
    notifyListeners();
  }


}