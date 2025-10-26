import 'package:flutter/material.dart';
import 'braille_input.dart';
import 'braille_notepad.dart';

void main() {
  runApp(const BrailleNotepadApp());
}

class BrailleNotepadApp extends StatelessWidget {
  const BrailleNotepadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Braille Notepad',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667EEA),
          brightness: Brightness.dark,
        ),
        fontFamily: 'SF Pro Display',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F1419),
      ),
      home: const BrailleNotepadHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BrailleNotepadHome extends StatefulWidget {
  const BrailleNotepadHome({super.key});

  @override
  State<BrailleNotepadHome> createState() => _BrailleNotepadHomeState();
}

// Helper widgets for the help dialog
class _KeyIndicator extends StatelessWidget {
  final String keyText;
  final String label;

  const _KeyIndicator(this.keyText, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              keyText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InstructionItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: const Color(0xFF667EEA),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrailleNotepadHomeState extends State<BrailleNotepadHome> {
  final BrailleInputController _brailleController = BrailleInputController();

  @override
  void dispose() {
    _brailleController.dispose();
    super.dispose();
  }

  Widget _buildLiveInputCell() {
    return Container(
      width: 24,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLiveDot(1),
              _buildLiveDot(4),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLiveDot(2),
              _buildLiveDot(5),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLiveDot(3),
              _buildLiveDot(6),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveDot(int dotNumber) {
    final isActive = _brailleController.currentDots.contains(dotNumber);
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.white : Colors.transparent,
        border: !isActive
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 0.5,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1F2E), Color(0xFF2E3440)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.create,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Braille Notepad',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: _brailleController,
            builder: (context, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Input:',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildLiveInputCell(),
                    ],
                  ),
                ),
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () => _showHelpDialog(context),
            ),
          ),
        ],
      ),
      body: BrailleNotepad(controller: _brailleController),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final double maxHeight = MediaQuery.of(context).size.height * 0.85;
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: maxHeight,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.help_outline,
                                color: Colors.white, size: 24),
                            SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Braille Input Guide',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Content
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1F2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Key Mapping Section
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF667EEA)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.keyboard_rounded,
                                    color: Color(0xFF667EEA),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Key Mapping',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Key grid
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F1419),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              child: const Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _KeyIndicator('F', 'Dot 1'),
                                      SizedBox(width: 40),
                                      _KeyIndicator('J', 'Dot 4'),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _KeyIndicator('D', 'Dot 2'),
                                      SizedBox(width: 40),
                                      _KeyIndicator('K', 'Dot 5'),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _KeyIndicator('S', 'Dot 3'),
                                      SizedBox(width: 40),
                                      _KeyIndicator('L', 'Dot 6'),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Instructions Section
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF667EEA)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.touch_app_rounded,
                                    color: Color(0xFF667EEA),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'How to Use',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            const _InstructionItem(
                              icon: Icons.touch_app,
                              text: 'Press down keys for your Braille pattern',
                            ),
                            const _InstructionItem(
                              icon: Icons.pan_tool,
                              text: 'Release ANY key to confirm character',
                            ),
                            const _InstructionItem(
                              icon: Icons.arrow_forward,
                              text:
                                  'Cursor moves automatically to next position',
                            ),
                            const _InstructionItem(
                              icon: Icons.space_bar,
                              text: 'Space for words, Enter for new lines',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Close Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF667EEA),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Got it!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
