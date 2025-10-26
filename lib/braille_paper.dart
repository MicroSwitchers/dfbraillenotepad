import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'braille_input.dart';

class BrailleCell extends StatelessWidget {
  final BrailleCharacter brailleChar;
  final bool isActive;
  final double size;

  const BrailleCell({
    super.key,
    required this.brailleChar,
    this.isActive = false,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.5, // Braille cells are taller than wide
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDot(1, brailleChar.dots.contains(1)),
              _buildDot(4, brailleChar.dots.contains(4)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDot(2, brailleChar.dots.contains(2)),
              _buildDot(5, brailleChar.dots.contains(5)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDot(3, brailleChar.dots.contains(3)),
              _buildDot(6, brailleChar.dots.contains(6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int dotNumber, bool isActive) {
    final double dotSize = size * 0.18;
    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.black : Colors.transparent,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.12),
          width: 0.6,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ] : null,
      ),
    );
  }
}

class BraillePaper extends StatelessWidget {
  final List<BrailleCharacter> brailleCells;
  final int currentPosition;
  final double cellSize;
  final int cellsPerLine;
  final ScrollController scrollController;
  final double? viewportHeight;
  final double leftMargin;
  final double rightPadding;
  final double topPadding;
  final double bottomPadding;
  final Set<int> activeDots;
  const BraillePaper({
    super.key,
    required this.brailleCells,
    required this.scrollController,
    this.currentPosition = 0,
    this.cellSize = 40.0,
    this.cellsPerLine = 20,
    this.viewportHeight,
    this.leftMargin = 96,
    this.rightPadding = 40,
    this.topPadding = 48,
    this.bottomPadding = 56,
    this.activeDots = const <int>{},
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final double horizontalInsets = leftMargin + rightPadding + 32; // include per-line padding
        final double availableContentWidth = math.max(0, width - horizontalInsets);
        final double baseCellWidth = cellSize + 2; // cell plus horizontal margins
        final double additionalCellWidth = cellSize + 6; // cell plus spacing for each extra cell
        int computedCapacity;
        if (availableContentWidth <= 0) {
          computedCapacity = cellsPerLine;
        } else if (availableContentWidth <= baseCellWidth) {
          computedCapacity = 1;
        } else {
          final double remainingWidth = availableContentWidth - baseCellWidth;
          computedCapacity = 1 + remainingWidth ~/ additionalCellWidth;
        }
        final int effectiveCellsPerLine = computedCapacity.clamp(4, 40);

        final double? desiredHeight = viewportHeight ?? (constraints.hasBoundedHeight ? constraints.maxHeight : null);
        final double targetHeight = (desiredHeight == null || !desiredHeight.isFinite || desiredHeight <= 0)
            ? 620
            : desiredHeight;

        return SizedBox(
          height: targetHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF4E6D0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 36,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: scrollController,
                      builder: (context, _) {
                        final double scrollOffset = scrollController.hasClients
                            ? scrollController.offset
                            : 0;
                        return CustomPaint(
                          painter: _NotepadBackgroundPainter(
                            lineSpacing: cellSize * 1.6,
                            topInset: topPadding,
                            lineColor: const Color(0xFF8E7B62).withValues(alpha: 0.18),
                            scrollOffset: scrollOffset,
                          ),
                        );
                      },
                    ),
                  ),
                  ScrollConfiguration(
                    behavior: const _NotepadScrollBehavior(),
                    child: RawScrollbar(
                      controller: scrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      radius: const Radius.circular(10),
                      thickness: 8,
                      thumbColor: const Color(0xFF8E7B62),
                      trackColor: const Color(0xFFE9DCC4),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(
                          leftMargin,
                          topPadding,
                          rightPadding,
                          bottomPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildLines(effectiveCellsPerLine),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildLines(int effectiveCellsPerLine) {
    final List<Widget> lines = [];
    final Set<int> previewDots = activeDots.isEmpty
        ? <int>{}
        : BrailleMapping.normalizeDots(activeDots);
    final bool hasPreviewDots = previewDots.isNotEmpty;
    
    if (brailleCells.isEmpty) {
      // Show empty paper ready for input
      lines.add(_buildEmptyLine(
        showCursor: true,
        previewDots: hasPreviewDots ? previewDots : null,
      ));
      return lines;
    }

    // Group cells by actual lines (split on newline characters)
    final List<List<BrailleCharacter>> textLines = [];
    final List<BrailleCharacter> currentLine = [];
    
    for (BrailleCharacter cell in brailleCells) {
      if (cell.character == '\n') {
        textLines.add(List.from(currentLine));
        currentLine.clear();
      } else {
        currentLine.add(cell);
      }
    }
    
    // Add any remaining characters as the final line
    if (currentLine.isNotEmpty) {
      textLines.add(List.from(currentLine));
    }

    // Ensure at least one line is present
    if (textLines.isEmpty) {
      textLines.add([]);
    }

    // Handle trailing newline by ensuring an empty line is present
    if (brailleCells.isNotEmpty && brailleCells.last.character == '\n') {
      textLines.add([]);
    }

    // Build each line, chunking by the effective max cells per line
    for (int i = 0; i < textLines.length; i++) {
      final lineChars = textLines[i];

      if (lineChars.isEmpty) {
        final bool isCursorLine = i == textLines.length - 1;
        lines.add(_buildEmptyLine(
          showCursor: isCursorLine,
          previewDots: isCursorLine && hasPreviewDots ? previewDots : null,
        ));
        continue;
      }

      for (int offset = 0; offset < lineChars.length; offset += effectiveCellsPerLine) {
        final int end = math.min(offset + effectiveCellsPerLine, lineChars.length);
        final List<BrailleCharacter> segment = lineChars.sublist(offset, end);
        final bool isLastSegment = end >= lineChars.length;
        final bool isCursorLine = (i == textLines.length - 1) && isLastSegment;
        final bool lineFull = segment.length >= effectiveCellsPerLine;
        final bool previewWouldOverflow =
            isCursorLine && hasPreviewDots && (segment.length + 1) > effectiveCellsPerLine;
        final bool showCursorInRow = isCursorLine && !lineFull && !previewWouldOverflow;

        lines.add(_buildTextLine(
          segment,
          showCursorInRow,
          previewDots: showCursorInRow && hasPreviewDots ? previewDots : null,
        ));

        if (isCursorLine && !showCursorInRow) {
          lines.add(_buildEmptyLine(
            showCursor: true,
            previewDots: hasPreviewDots ? previewDots : null,
          ));
        }
      }
    }

    return lines;
  }

  Widget _buildTextLine(
    List<BrailleCharacter> chars,
    bool showCursor, {
    Set<int>? previewDots,
  }) {
    final List<Widget> rowChildren = [];

    for (int i = 0; i < chars.length; i++) {
      rowChildren.add(BrailleCell(
        brailleChar: chars[i],
        size: cellSize,
      ));
      if (i != chars.length - 1) {
        rowChildren.add(const SizedBox(width: 4));
      }
    }

    if (showCursor) {
      if (rowChildren.isNotEmpty) {
  rowChildren.add(const SizedBox(width: 4));
      }
      if (previewDots != null && previewDots.isNotEmpty) {
        rowChildren.add(
          BrailleCell(
            brailleChar: BrailleCharacter(Set<int>.from(previewDots), '', ''),
            size: cellSize,
            isActive: true,
          ),
        );
      } else {
        rowChildren.add(_buildCursor());
      }
    }

    return SizedBox(
      height: cellSize * 1.6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: rowChildren,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyLine({bool showCursor = false, Set<int>? previewDots}) {
    return SizedBox(
      height: cellSize * 1.6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: showCursor
              ? (previewDots != null && previewDots.isNotEmpty
                  ? BrailleCell(
                      brailleChar: BrailleCharacter(Set<int>.from(previewDots), '', ''),
                      size: cellSize,
                      isActive: true,
                    )
                  : _buildCursor())
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildCursor() {
    return Container(
      width: 3,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _NotepadBackgroundPainter extends CustomPainter {
  final double lineSpacing;
  final double topInset;
  final Color lineColor;
  final double scrollOffset;

  const _NotepadBackgroundPainter({
    required this.lineSpacing,
    required this.topInset,
    required this.lineColor,
    required this.scrollOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    final double offsetWithinSpacing = scrollOffset % lineSpacing;
    double start = topInset - offsetWithinSpacing;
    while (start > 0) {
      start -= lineSpacing;
    }

    for (double y = start; y <= size.height + lineSpacing; y += lineSpacing) {
      if (y >= 0) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NotepadBackgroundPainter oldDelegate) {
    return lineSpacing != oldDelegate.lineSpacing ||
        topInset != oldDelegate.topInset ||
        lineColor != oldDelegate.lineColor ||
        scrollOffset != oldDelegate.scrollOffset;
  }
}

class _NotepadScrollBehavior extends ScrollBehavior {
  const _NotepadScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}