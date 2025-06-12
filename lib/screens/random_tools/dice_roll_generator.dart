import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/random_generator.dart';
import 'package:setpocket/services/generation_history_service.dart';
import 'dart:math' as math;

class DiceRollGeneratorScreen extends StatefulWidget {
  final bool isEmbedded;

  const DiceRollGeneratorScreen({super.key, this.isEmbedded = false});

  @override
  State<DiceRollGeneratorScreen> createState() =>
      _DiceRollGeneratorScreenState();
}

class _DiceRollGeneratorScreenState extends State<DiceRollGeneratorScreen>
    with TickerProviderStateMixin {
  int _diceCount = 2;
  int _diceSides = 6;
  List<int> _results = [];
  late AnimationController _rollController;
  late Animation<double> _rollAnimation;
  List<GenerationHistoryItem> _history = [];
  bool _historyEnabled = false;

  final List<int> _availableSides = [
    3,
    4,
    5,
    6,
    7,
    8,
    10,
    12,
    14,
    16,
    20,
    24,
    30,
    48,
    50,
    100
  ];
  @override
  void initState() {
    super.initState();
    _rollController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rollAnimation = CurvedAnimation(
      parent: _rollController,
      curve: Curves.easeOutBack,
    );
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final enabled = await GenerationHistoryService.isHistoryEnabled();
    final history = await GenerationHistoryService.getHistory('dice_roll');
    setState(() {
      _historyEnabled = enabled;
      _history = history;
    });
  }

  @override
  void dispose() {
    _rollController.dispose();
    super.dispose();
  }

  void _rollDice() {
    _rollController.reset();
    _rollController.forward();

    setState(() {
      _results = RandomGenerator.generateDiceRolls(
        count: _diceCount,
        sides: _diceSides,
      );
    });

    // Save to history if enabled
    if (_historyEnabled && _results.isNotEmpty) {
      String resultText = _results.length == 1
          ? 'd$_diceSides: ${_results[0]}'
          : '${_results.length}d$_diceSides: ${_results.join(", ")} (Total: ${_getTotal()})';
      GenerationHistoryService.addHistoryItem(
        resultText,
        'dice_roll',
      ).then((_) => _loadHistory());
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
                                'dice_roll');
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
                              'dice_roll');
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

  int _getTotal() {
    return _results.fold(0, (sum, value) => sum + value);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;

    final generatorContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dice count selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.diceCount,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '$_diceCount',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Slider(
                  value: _diceCount.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _diceCount.toString(),
                  onChanged: (double value) {
                    setState(() {
                      _diceCount = value.round();
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Dice sides selector
                Text(
                  loc.diceSides,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),

                // Wrap with dice side options
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableSides.map((sides) {
                    return ChoiceChip(
                      label: Text('d$sides'),
                      selected: _diceSides == sides,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _diceSides = sides;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Roll button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _rollDice,
                    icon: const Icon(Icons.casino),
                    label: Text(loc.generate),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (_results.isNotEmpty) ...[
          AnimatedBuilder(
            animation: _rollAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_rollAnimation.value * 0.1),
                child: child,
              );
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Result heading
                    Text(
                      loc.randomResult,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // Dice display
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: _results.map((result) {
                        return _buildDie(result);
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Total
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        'Total: ${_getTotal()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );

    final historyWidget = _buildHistoryWidget(loc);

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
              child: SingleChildScrollView(
                child: generatorContent,
              ),
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
            generatorContent,
            if (_historyEnabled && _history.isNotEmpty) ...[
              const SizedBox(height: 32),
              historyWidget,
            ],
          ],
        ),
      );
    }

    if (widget.isEmbedded) {
      return content;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.rollDice),
        ),
        body: content,
      );
    }
  }

  Widget _buildDie(int value) {
    // For d6, show actual dice face
    if (_diceSides == 6) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: _buildDiceFace(value),
      );
    }
    // For other dice, show number with polygon shape
    else {
      return Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Shape
            _buildDieShape(),

            // Number
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDiceFace(int value) {
    // Map classic die dots pattern for d6
    switch (value) {
      case 1:
        return const Center(child: _DiceDot());
      case 2:
        return const Stack(
          children: [
            Positioned(top: 10, left: 10, child: _DiceDot()),
            Positioned(bottom: 10, right: 10, child: _DiceDot()),
          ],
        );
      case 3:
        return const Stack(
          children: [
            Positioned(top: 10, left: 10, child: _DiceDot()),
            Center(child: _DiceDot()),
            Positioned(bottom: 10, right: 10, child: _DiceDot()),
          ],
        );
      case 4:
        return const Stack(
          children: [
            Positioned(top: 10, left: 10, child: _DiceDot()),
            Positioned(top: 10, right: 10, child: _DiceDot()),
            Positioned(bottom: 10, left: 10, child: _DiceDot()),
            Positioned(bottom: 10, right: 10, child: _DiceDot()),
          ],
        );
      case 5:
        return const Stack(
          children: [
            Positioned(top: 10, left: 10, child: _DiceDot()),
            Positioned(top: 10, right: 10, child: _DiceDot()),
            Center(child: _DiceDot()),
            Positioned(bottom: 10, left: 10, child: _DiceDot()),
            Positioned(bottom: 10, right: 10, child: _DiceDot()),
          ],
        );
      case 6:
        return const Stack(
          children: [
            Positioned(top: 10, left: 10, child: _DiceDot()),
            Positioned(top: 10, right: 10, child: _DiceDot()),
            Positioned(top: 25, left: 10, child: _DiceDot()),
            Positioned(top: 25, right: 10, child: _DiceDot()),
            Positioned(bottom: 10, left: 10, child: _DiceDot()),
            Positioned(bottom: 10, right: 10, child: _DiceDot()),
          ],
        );
      default:
        return Center(
          child: Text(
            '$value',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }

  Widget _buildDieShape() {
    // Different polygons for different die types
    switch (_diceSides) {
      case 3: // d3 - triangle
        return _buildPolygon(3, Colors.green);
      case 4: // d4 - tetrahedron (triangle)
        return _buildPolygon(3, Colors.blue);
      case 8: // d8 - octahedron
        return _buildPolygon(8, Colors.orange);
      case 10: // d10 - decagon
      case 100: // d100 (percentile)
        return _buildPolygon(10, Colors.purple);
      case 12: // d12 - dodecahedron
        return _buildPolygon(5, Colors.teal);
      case 20: // d20 - icosahedron
        return _buildPolygon(3, Colors.red);
      case 24: // d24
        return _buildPolygon(8, Colors.indigo);
      case 30: // d30
        return _buildPolygon(5, Colors.brown);
      default: // All others
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            shape: BoxShape.circle,
          ),
        );
    }
  }

  Widget _buildPolygon(int sides, Color color) {
    return SizedBox(
      width: 50,
      height: 50,
      child: CustomPaint(
        painter: PolygonPainter(sides: sides, color: color),
      ),
    );
  }
}

class _DiceDot extends StatelessWidget {
  const _DiceDot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}

class PolygonPainter extends CustomPainter {
  final int sides;
  final Color color;

  PolygonPainter({required this.sides, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final angle = 2 * math.pi / sides;

    // Move to the first point
    path.moveTo(
      center.dx + radius * math.cos(0),
      center.dy + radius * math.sin(0),
    );

    // Draw lines to each corner
    for (int i = 1; i <= sides; i++) {
      path.lineTo(
        center.dx + radius * math.cos(angle * i),
        center.dy + radius * math.sin(angle * i),
      );
    }

    // Close the path
    path.close();

    // Draw the polygon
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
