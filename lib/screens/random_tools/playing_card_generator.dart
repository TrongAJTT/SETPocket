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
    // Initialize with some default values
    _generateCards();
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
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _cardCount > 1
                            ? () => setState(() => _cardCount--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Container(
                        width: 60,
                        alignment: Alignment.center,
                        child: Text(
                          '$_cardCount',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        onPressed: _cardCount < 52
                            ? () => setState(() => _cardCount++)
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
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
            child: Padding(
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
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateY(isBack ? 0 : 3.14159); // 180 degrees in radians

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
                  color: Colors.black.withOpacity(0.3),
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
                        color: Colors.white.withOpacity(0.7),
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
