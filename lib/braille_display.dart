import 'package:flutter/material.dart';
import 'braille_input.dart';

class BrailleDisplay extends StatelessWidget {
  final BrailleInputController controller;

  const BrailleDisplay({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.accessibility_new,
                  color: Color(0xFF4A90E2),
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Braille Input',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const Spacer(),
                if (controller.isInputActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Braille Dot Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left column (dots 1, 2, 3)
                  Column(
                    children: [
                      _buildDot(1, controller.currentDots.contains(1)),
                      const SizedBox(height: 12),
                      _buildDot(2, controller.currentDots.contains(2)),
                      const SizedBox(height: 12),
                      _buildDot(3, controller.currentDots.contains(3)),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Right column (dots 4, 5, 6)
                  Column(
                    children: [
                      _buildDot(4, controller.currentDots.contains(4)),
                      const SizedBox(height: 12),
                      _buildDot(5, controller.currentDots.contains(5)),
                      const SizedBox(height: 12),
                      _buildDot(6, controller.currentDots.contains(6)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Key mapping guide
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  const Text(
                    'Key Mapping',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKeyIndicator('F', 1, controller.currentDots.contains(1)),
                      _buildKeyIndicator('D', 2, controller.currentDots.contains(2)),
                      _buildKeyIndicator('S', 3, controller.currentDots.contains(3)),
                      const SizedBox(width: 8),
                      _buildKeyIndicator('J', 4, controller.currentDots.contains(4)),
                      _buildKeyIndicator('K', 5, controller.currentDots.contains(5)),
                      _buildKeyIndicator('L', 6, controller.currentDots.contains(6)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Current character preview
            if (controller.currentDots.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.preview,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Preview: ${_getPreviewCharacter(controller.currentDots)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDot(int dotNumber, bool isActive) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF4A90E2) : Colors.grey[300],
        border: Border.all(
          color: isActive ? const Color(0xFF2C5AB0) : Colors.grey[400]!,
          width: 2,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: const Color(0xFF4A90E2).withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: Center(
        child: Text(
          dotNumber.toString(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyIndicator(String key, int dotNumber, bool isActive) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4A90E2) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive ? const Color(0xFF2C5AB0) : Colors.grey[400]!,
          width: 2,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: const Color(0xFF4A90E2).withValues(alpha: 0.3),
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: Center(
        child: Text(
          key,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  String _getPreviewCharacter(Set<int> dots) {
    final brailleChar = BrailleMapping.getCharacter(dots);
    if (brailleChar != null) {
      return '${brailleChar.character} (${brailleChar.brailleUnicode})';
    } else {
      return 'Unknown pattern';
    }
  }
}