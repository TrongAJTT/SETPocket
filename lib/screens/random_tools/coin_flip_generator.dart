import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/models/random_generator.dart';
import 'package:my_multi_tools/services/generation_history_service.dart';

class CoinFlipGeneratorScreen extends StatefulWidget {
  final bool isEmbedded;

  const CoinFlipGeneratorScreen({super.key, this.isEmbedded = false});

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
  List<GenerationHistoryItem> _history = [];
  bool _historyEnabled = false;

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
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final enabled = await GenerationHistoryService.isHistoryEnabled();
    final history = await GenerationHistoryService.getHistory('coin_flip');
    setState(() {
      _historyEnabled = enabled;
      _history = history;
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
    }); // Save to history if enabled
    if (_historyEnabled && _finalResult != null) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      String resultText = _finalResult! ? loc.heads : loc.tails;
      GenerationHistoryService.addHistoryItem(
        resultText,
        'coin_flip',
      ).then((_) => _loadHistory()); // Refresh history
    }
  }

  void _copyHistoryItem(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.copied)),
    );
  }

  Widget _buildHistoryWidget(AppLocalizations loc) {
    if (!_historyEnabled || _history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive header that wraps on small screens
            LayoutBuilder(
              builder: (context, constraints) {
                // If space is limited, use Column layout
                if (constraints.maxWidth < 300) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.generationHistory,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            await GenerationHistoryService.clearHistory(
                                'coin_flip');
                            await _loadHistory();
                          },
                          child: Text(loc.clearHistory),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Use Row layout when there's enough space
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          loc.generationHistory,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await GenerationHistoryService.clearHistory(
                              'coin_flip');
                          await _loadHistory();
                        },
                        child: Text(loc.clearHistory),
                      ),
                    ],
                  );
                }
              },
            ),
            const Divider(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _history.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      item.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${loc.generatedAt}: ${item.timestamp.toString().substring(0, 19)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () => _copyHistoryItem(item.value),
                      tooltip: loc.copyToClipboard,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;

    final generatorCard = Center(
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
                        _currentSide ? l10n.heads : l10n.tails,
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
              label: Text(_isFlipping ? l10n.flipping : l10n.flipCoin),
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
                ? '${l10n.randomResult}: ${_finalResult! ? l10n.heads : l10n.tails}'
                : l10n.flipCoinInstruction,
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
    );

    final historyWidget = _buildHistoryWidget(l10n);

    Widget content;
    if (isLargeScreen && (_historyEnabled && _history.isNotEmpty)) {
      // Large screen layout: generator on left, history on right
      content = Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: generatorCard,
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: historyWidget,
            ),
          ],
        ),
      );
    } else {
      // Small screen layout: vertical stack
      content = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: generatorCard,
            ),
            if (_historyEnabled && _history.isNotEmpty) ...[
              const SizedBox(height: 32),
              historyWidget,
            ],
          ],
        ),
      );
    }

    // Return either the content directly (if embedded) or wrapped in a Scaffold
    if (widget.isEmbedded) {
      return content;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.flipCoin),
          elevation: 0,
        ),
        body: content,
      );
    }
  }
}
