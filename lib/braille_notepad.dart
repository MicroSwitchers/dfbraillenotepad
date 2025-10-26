import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'braille_input.dart';
import 'braille_paper.dart';

class BrailleNotepad extends StatefulWidget {
  final BrailleInputController controller;

  const BrailleNotepad({
    super.key,
    required this.controller,
  });

  @override
  State<BrailleNotepad> createState() => _BrailleNotepadState();
}

class _BrailleNotepadState extends State<BrailleNotepad> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _paperScrollController = ScrollController();
  int _lastKnownCursorIndex = 0;
  int _lastKnownCellCount = 0;
  bool _scrollScheduled = false;

  @override
  void initState() {
    super.initState();
    // Request focus to capture keyboard events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _lastKnownCursorIndex = widget.controller.currentPosition;
    _lastKnownCellCount = widget.controller.brailleCells.length;
    widget.controller.addListener(_handleControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerUpdate);
    _paperScrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: widget.controller.handleKeyEvent,
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final Size mediaSize = MediaQuery.of(context).size;
            final double availableWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : mediaSize.width;
            final double availableHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : mediaSize.height;

            double horizontalPadding;
            if (availableWidth >= 1280) {
              horizontalPadding = 112;
            } else if (availableWidth >= 1040) {
              horizontalPadding = 88;
            } else if (availableWidth >= 840) {
              horizontalPadding = 64;
            } else if (availableWidth >= 680) {
              horizontalPadding = 48;
            } else {
              horizontalPadding = 28;
            }

            final double maxPaperWidth = (availableWidth - horizontalPadding * 2).clamp(360.0, 980.0);
            final double paperWidth = maxPaperWidth;

            final EdgeInsets contentPadding = EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: availableHeight >= 760 ? 36 : 24,
            );

            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF070B12), Color(0xFF101A26)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: contentPadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: paperWidth + 160),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildHeader(paperWidth),
                          const SizedBox(height: 24),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: paperWidth),
                                child: LayoutBuilder(
                                  builder: (context, innerConstraints) {
                                    final double maxHeight = innerConstraints.maxHeight;
                                    final double effectiveHeight = maxHeight.isFinite && maxHeight > 0
                                        ? maxHeight
                                        : 620.0;
                                    final double clampedHeight;
                                    if (effectiveHeight >= 460.0) {
                                      clampedHeight = math.min(780.0, effectiveHeight);
                                    } else {
                                      clampedHeight = effectiveHeight;
                                    }
                                    return _buildNotepadSurface(
                                      paperWidth: paperWidth,
                                      paperHeight: clampedHeight,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.center,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: paperWidth),
                              child: ListenableBuilder(
                                listenable: widget.controller,
                                builder: (context, child) => _buildStatusBar(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleControllerUpdate() {
    final int cursorIndex = widget.controller.currentPosition;
    final int cellCount = widget.controller.brailleCells.length;

    if (cursorIndex != _lastKnownCursorIndex || cellCount != _lastKnownCellCount) {
      _scheduleScrollToCursor();
      _lastKnownCursorIndex = cursorIndex;
      _lastKnownCellCount = cellCount;
    }
  }

  void _scheduleScrollToCursor() {
    if (_scrollScheduled) {
      return;
    }
    _scrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollScheduled = false;
      if (!_paperScrollController.hasClients) {
        return;
      }
      final double target = _paperScrollController.position.maxScrollExtent;
      _paperScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _saveToUnicode(BuildContext modalContext) async {
    final String text = widget.controller.text;

    if (text.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to export yet. Add some Braille first.')),
      );
      return;
    }

    final NavigatorState navigator = Navigator.of(modalContext);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    const String suggestedName = 'braille-note.txt';

    try {
      final FileSaveLocation? location = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: const [
          XTypeGroup(label: 'Text', extensions: ['txt']),
        ],
      );

      if (location == null) {
        // User cancelled the dialog
        return;
      }

      final Uint8List data = Uint8List.fromList(utf8.encode(text));
      final XFile file = XFile.fromData(
        data,
        mimeType: 'text/plain',
        name: suggestedName,
      );

      await file.saveTo(location.path);

      if (!mounted) {
        return;
      }

      if (navigator.canPop()) {
        navigator.pop();
      }

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Saved UTF-8 text. Open the file in any text editor to view the Braille Unicode.'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      // Close the modal if it's still open
      if (navigator.canPop()) {
        navigator.pop();
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text('Error saving file: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _saveToUnicode(context),
          ),
        ),
      );
    }
  }

  Widget _buildHeader(double contentWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: math.max(contentWidth, 520.0)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isNarrow = constraints.maxWidth < 640;

          final Widget infoColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Braille Workspace',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hold combinations of f d s j k l to form dots. Release any of the held keys to commit the Braille cell at the cursor.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          );

          final Widget actionButton = FilledButton.tonal(
            onPressed: _showTextOptions,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, size: 18),
                SizedBox(width: 8),
                Text('Document options'),
              ],
            ),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                infoColumn,
                const SizedBox(height: 20),
                actionButton,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: infoColumn),
              const SizedBox(width: 24),
              actionButton,
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotepadSurface({
    required double paperWidth,
    required double paperHeight,
  }) {
    final double dynamicLeftMargin = math.max(32, paperWidth * 0.1);
    final double dynamicRightPadding = math.max(24, paperWidth * 0.08);
    final double topPadding = math.max(44, paperHeight * 0.08);
    final double bottomPadding = math.max(52, paperHeight * 0.09);
    return SizedBox(
      width: paperWidth,
      height: paperHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 60,
              offset: const Offset(0, 26),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: ListenableBuilder(
            listenable: widget.controller,
            builder: (context, child) {
              return BraillePaper(
                brailleCells: widget.controller.brailleCells,
                currentPosition: widget.controller.currentPosition,
                cellSize: 42,
                scrollController: _paperScrollController,
                viewportHeight: paperHeight,
                leftMargin: dynamicLeftMargin,
                rightPadding: dynamicRightPadding,
                topPadding: topPadding,
                bottomPadding: bottomPadding,
                activeDots: widget.controller.currentDots,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    final String text = widget.controller.text;
    final int characterCount = text.replaceAll('\n', '').length;
    final List<Widget> badges = [
      const _FooterBadge(
        icon: Icons.keyboard_rounded,
        label: 'fdsjkl input',
      ),
      _FooterBadge(
        icon: Icons.text_fields_rounded,
        label: '$characterCount characters',
      ),
    ];

    const String statusMessage = 'Export to keep your work safe';
    final TextStyle statusStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.45),
      fontSize: 12,
      letterSpacing: 0.2,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 480;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 18 : 24,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: badges,
                    ),
                    const SizedBox(height: 12),
                    Text(statusMessage, style: statusStyle),
                  ],
                )
              : Row(
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: badges,
                    ),
                    const Spacer(),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          statusMessage,
                          style: statusStyle,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _showTextOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Text Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Clear All'),
              onTap: () {
                widget.controller.clearText();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: const Text('Save as Unicode text'),
              subtitle: const Text('Exports a UTF-8 .txt file you can open in any text viewer.'),
              onTap: () => _saveToUnicode(context),
            ),
            ListTile(
              leading: const Icon(Icons.paste),
              title: const Text('Paste from Clipboard'),
              onTap: () async {
                try {
                  final data = await Clipboard.getData('text/plain');
                  if (context.mounted) {
                    if (data?.text != null && data!.text!.isNotEmpty) {
                      widget.controller.setText(widget.controller.text + data.text!);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Text pasted from clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Clipboard is empty or contains no text'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error accessing clipboard: ${e.toString()}'),
                        backgroundColor: Colors.red.shade700,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy to Clipboard'),
              subtitle: const Text('Copy your Braille text to paste elsewhere'),
              onTap: () async {
                try {
                  final text = widget.controller.text;
                  if (text.isEmpty) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nothing to copy. Add some Braille first.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    return;
                  }
                  await Clipboard.setData(ClipboardData(text: text));
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error copying to clipboard: ${e.toString()}'),
                        backgroundColor: Colors.red.shade700,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _FooterBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FooterBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
