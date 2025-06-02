import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/models/random_generator.dart';

class CoinFlipGeneratorScreen extends StatefulWidget {
  const CoinFlipGeneratorScreen({super.key});

  @override
  State<CoinFlipGeneratorScreen> createState() =>
      _CoinFlipGeneratorScreenState();
}

class _CoinFlipGeneratorScreenState extends State<CoinFlipGeneratorScreen>
    with TickerProviderStateMixin {
  bool? _result;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _flipController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _flipCoin() async {
    _scaleController.reset();
    _scaleController.forward().then((_) => _scaleController.reverse());

    _flipController.reset();
    await _flipController.forward();

    // Set result after animation
    setState(() {
      _result = RandomGenerator.generateCoinFlip();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.flipCoin),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_flipAnimation, _scaleAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective
                      ..rotateX(_flipAnimation.value),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Show heads or tails based on animation value (for smooth transition)
                        color: _showHeadsDuringAnimation()
                            ? Colors.amber.shade800
                            : Colors.amber.shade600,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _result != null
                            ? Text(
                                _result! ? loc.heads : loc.tails,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('?',
                                style: TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                )),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              height: 50,
              child: FilledButton.icon(
                onPressed: _flipCoin,
                icon: const Icon(Icons.monetization_on),
                label: Text(loc.flipCoin),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Text(
                '${loc.randomResult}: ${_result! ? loc.heads : loc.tails}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper to determine if we show heads or tails during animation
  bool _showHeadsDuringAnimation() {
    if (_result == null) return true;

    // During first half of animation show one side, during second half show the other
    double animValue = _flipAnimation.value;
    bool firstHalf = animValue < math.pi;

    if (_result!) {
      return firstHalf;
    } else {
      return !firstHalf;
    }
  }
}
