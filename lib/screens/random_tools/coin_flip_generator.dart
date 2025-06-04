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
  bool _currentSide = true; // true = heads, false = tails
  bool? _finalResult;
  bool _isFlipping = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 2000), // Longer animation
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 6 * math.pi, // More rotations for better effect
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeOut,
    ));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Listen to animation to alternate sides in real-time
    _flipAnimation.addListener(() {
      if (_isFlipping) {
        // Change side every half rotation (π radians)
        int halfRotations = (_flipAnimation.value / math.pi).floor();
        bool newSide = halfRotations.isEven;
        if (newSide != _currentSide) {
          setState(() {
            _currentSide = newSide;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _flipCoin() async {
    if (_isFlipping) return; // Prevent multiple flips at once

    setState(() {
      _isFlipping = true;
      _finalResult = null; // Clear previous result
    });

    _scaleController.reset();
    _scaleController.forward().then((_) => _scaleController.reverse());

    _flipController.reset();
    await _flipController.forward();

    // Determine final result
    final result = RandomGenerator.generateCoinFlip();

    setState(() {
      _isFlipping = false;
      _finalResult = result;
      _currentSide = result; // Set final side
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
                        // Different colors for heads and tails
                        color: _currentSide
                            ? Colors.amber.shade700 // Heads - golden
                            : Colors.grey.shade600, // Tails - silver
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _currentSide ? loc.heads : loc.tails,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
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
                onPressed: _isFlipping ? null : _flipCoin,
                icon: const Icon(Icons.monetization_on),
                label: Text(_isFlipping ? loc.flipping : loc.flipCoin),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _finalResult != null
                  ? '${loc.randomResult}: ${_finalResult! ? loc.heads : loc.tails}'
                  : loc.flipCoinInstruction,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: _finalResult != null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
