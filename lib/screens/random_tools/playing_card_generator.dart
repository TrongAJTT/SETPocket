import 'package:flutter/material.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/models/random_generator.dart';

class PlayingCardGeneratorScreen extends StatefulWidget {
  const PlayingCardGeneratorScreen({super.key});

  @override
  State<PlayingCardGeneratorScreen> createState() =>
      _PlayingCardGeneratorScreenState();
}

class _PlayingCardGeneratorScreenState extends State<PlayingCardGeneratorScreen>
    with TickerProviderStateMixin {
  int _cardCount = 5;
  double _tens = 0.0; // 0-5 representing tens place (0-50)
  double _units = 5.0; // 0-9 representing units place (0-9)
  List<String> _generatedCards = [];
  late AnimationController _dealController;
  List<AnimationController> _flipControllers = [];
  List<Animation<double>> _flipAnimations = [];

  @override
  void initState() {
    super.initState();
    _dealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    // Initialize sliders based on initial _cardCount
    _updateSlidersFromCount(_cardCount);
    // Initialize with some default values
    _generateCards();
  }

  void _updateSlidersFromCount(int count) {
    _tens = (count ~/ 10).toDouble();
    _units = (count % 10).toDouble();
  }

  void _updateCountFromSliders() {
    final newCount = (_tens * 10 + _units).toInt();
    // Ensure count is within valid range (1-52 for playing cards)
    final validCount = newCount.clamp(1, 52);
    if (validCount != _cardCount) {
      setState(() {
        _cardCount = validCount;
      });
      // Update sliders if count was clamped
      if (validCount != newCount) {
        _updateSlidersFromCount(validCount);
      }
    }
  }

  @override
  void dispose() {
    _dealController.dispose();
    for (var controller in _flipControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _generateCards() {
    // Reset and dispose old controllers
    for (var controller in _flipControllers) {
      controller.dispose();
    } // Generate new cards
    final cards = RandomGenerator.generatePlayingCards(_cardCount);
    // Không cần đảo thứ tự nữa, hiển thị đúng thứ tự đã tạo

    // Create flip controllers for each card
    _flipControllers = List.generate(
      cards.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );

    _flipAnimations = _flipControllers
        .map((controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            ))
        .toList();

    // Deal animation setup
    _dealController.reset();

    setState(() {
      _generatedCards = cards;
    });

    // Deal cards with animation
    _dealController.forward();

    // Flip cards with staggered animation
    Future.delayed(const Duration(milliseconds: 800), () {
      for (int i = 0; i < _flipControllers.length; i++) {
        Future.delayed(Duration(milliseconds: 150 * i), () {
          _flipControllers[i].forward();
        });
      }
    });
  }

  Color _getSuitColor(String card) {
    if (card.contains('♥') || card.contains('♦')) {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }

  Widget _buildSliderControls(AppLocalizations loc) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    final tensSlider = Column(
      children: [
        Text(
          loc.tens,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        Slider(
          value: _tens,
          min: 0,
          max: 5, // Maximum 50 cards
          divisions: 5,
          label: '${_tens.toInt()}0',
          onChanged: (value) {
            setState(() {
              _tens = value;
              // Special handling for 52 card limit
              final newCount = (value * 10 + _units).toInt();
              if (newCount > 52) {
                _units = 2.0; // Set units to 2 if tens is 5 (making it 52)
              }
            });
            _updateCountFromSliders();
          },
        ),
      ],
    );

    final unitsSlider = Column(
      children: [
        Text(
          loc.units,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        Slider(
          value: _units,
          min: 0,
          max: 9,
          divisions: 9,
          label: _units.toInt().toString(),
          onChanged: (value) {
            setState(() {
              _units = value;
              // Special handling for 52 card limit
              final newCount = (_tens * 10 + value).toInt();
              if (newCount > 52) {
                _units = 2.0; // Set to 2 if tens is 5 (making it 52)
              }
            });
            _updateCountFromSliders();
          },
        ),
      ],
    );

    if (isWideScreen) {
      // Horizontal layout for desktop/tablet
      return Row(
        children: [
          Expanded(child: tensSlider),
          const SizedBox(width: 16),
          Expanded(child: unitsSlider),
        ],
      );
    } else {
      // Vertical layout for mobile
      return Column(
        children: [
          tensSlider,
          const SizedBox(height: 8),
          unitsSlider,
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    int maxCardsPerRow;
    if (width < 400) {
      maxCardsPerRow = 3;
    } else if (width < 600) {
      maxCardsPerRow = 4;
    } else if (width < 900) {
      maxCardsPerRow = 6;
    } else if (width < 1200) {
      maxCardsPerRow = 8;
    } else {
      maxCardsPerRow = 10;
    }

    // Chia các lá bài thành các dòng (giữ nguyên thứ tự)
    List<List<int>> cardRows = [];
    for (int i = 0; i < _generatedCards.length; i += maxCardsPerRow) {
      int end = (i + maxCardsPerRow < _generatedCards.length)
          ? i + maxCardsPerRow
          : _generatedCards.length;
      cardRows.add(List.generate(end - i, (j) => i + j));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.playingCards),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card count controls
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.cardCount,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  // Current count display
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_cardCount',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Slider controls
                  _buildSliderControls(loc),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _generateCards,
                      icon: const Icon(Icons.refresh),
                      label: Text(loc.generate),
                    ),
                  ),
                ],
              ),
            ),
          ), // Cards display
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final row in cardRows)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final idx in row)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                            child: _buildCard(idx, 0),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index, double offsetX) {
    if (index >= _flipAnimations.length || index >= _generatedCards.length) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _flipAnimations[index],
      builder: (context, child) {
        // 3D flip effect
        final value = _flipAnimations[index].value;
        final isBack = value < 0.5;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001); // perspective
        // ..rotateX(isBack ? 3.14159 : 0); // 180 degrees in radians

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: Container(
            width: 70,
            height: 100,
            decoration: BoxDecoration(
              color: isBack ? Colors.blue.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 5,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: isBack
                ? Center(
                    child: Text(
                      '♠♥♦♣',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _generatedCards[index],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getSuitColor(_generatedCards[index]),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              _getCardSuit(_generatedCards[index]),
                              style: TextStyle(
                                fontSize: 32,
                                color: _getSuitColor(_generatedCards[index]),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Transform.rotate(
                            angle: 3.14159, // 180 degrees
                            child: Text(
                              _generatedCards[index],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getSuitColor(_generatedCards[index]),
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

  String _getCardSuit(String card) {
    // Extract the suit (last character)
    return card.substring(card.length - 1);
  }
}
