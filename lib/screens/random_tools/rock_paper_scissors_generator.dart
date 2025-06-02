import 'package:flutter/material.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/models/random_generator.dart';

class RockPaperScissorsGeneratorScreen extends StatefulWidget {
  const RockPaperScissorsGeneratorScreen({super.key});

  @override
  State<RockPaperScissorsGeneratorScreen> createState() =>
      _RockPaperScissorsGeneratorScreenState();
}

class _RockPaperScissorsGeneratorScreenState
    extends State<RockPaperScissorsGeneratorScreen>
    with SingleTickerProviderStateMixin {
  int? _result;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generateResult() async {
    _controller.reset();
    await _controller.forward();

    setState(() {
      _result = RandomGenerator.generateRockPaperScissors();
    });
  }

  IconData _getIcon() {
    if (_result == null) {
      return Icons.help_outline;
    }
    switch (_result) {
      case 0:
        return Icons.sports_mma; // Rock
      case 1:
        return Icons.article; // Paper
      case 2:
        return Icons.content_cut; // Scissors
      default:
        return Icons.help_outline;
    }
  }

  String _getResultText(AppLocalizations loc) {
    if (_result == null) {
      return '?';
    }
    switch (_result) {
      case 0:
        return loc.rock;
      case 1:
        return loc.paper;
      case 2:
        return loc.scissors;
      default:
        return '?';
    }
  }

  Color _getResultColor() {
    if (_result == null) {
      return Colors.grey.shade400;
    }
    switch (_result) {
      case 0:
        return Colors.brown.shade700; // Rock
      case 1:
        return Colors.blue.shade700; // Paper
      case 2:
        return Colors.red.shade700; // Scissors
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.rockPaperScissors),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 + _animation.value * 0.3,
                  child: Opacity(
                    opacity: 0.7 + (_animation.value * 0.3),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getResultColor().withOpacity(0.2),
                        border: Border.all(
                          color: _getResultColor(),
                          width: 4,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getIcon(),
                            size: 80,
                            color: _getResultColor(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getResultText(loc),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _getResultColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOptionButton(
                    Icons.sports_mma, loc.rock, 0, Colors.brown.shade700),
                const SizedBox(width: 16),
                _buildOptionButton(
                    Icons.article, loc.paper, 1, Colors.blue.shade700),
                const SizedBox(width: 16),
                _buildOptionButton(
                    Icons.content_cut, loc.scissors, 2, Colors.red.shade700),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              height: 50,
              child: FilledButton(
                onPressed: _generateResult,
                child: Text(loc.generate),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
      IconData icon, String label, int value, Color color) {
    bool isSelected = _result == value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? color : Colors.grey,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
