import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/generation_history_service.dart';
import 'package:setpocket/widgets/random_generator_layout.dart';
import 'dart:math';

class PlayingCardGeneratorScreen extends StatefulWidget {
  final bool isEmbedded;

  const PlayingCardGeneratorScreen({super.key, this.isEmbedded = false});

  @override
  State<PlayingCardGeneratorScreen> createState() =>
      _PlayingCardGeneratorScreenState();
}

class _PlayingCardGeneratorScreenState extends State<PlayingCardGeneratorScreen>
    with SingleTickerProviderStateMixin {
  int _cardCount = 5;
  double _cardCountSlider = 5.0;
  bool _includeJokers = false;
  bool _allowDuplicates = true;
  List<PlayingCard> _generatedCards = [];
  bool _copied = false;
  late AnimationController _animationController;
  List<GenerationHistoryItem> _history = [];
  bool _historyEnabled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final enabled = await GenerationHistoryService.isHistoryEnabled();
    final history = await GenerationHistoryService.getHistory('playing_cards');
    setState(() {
      _historyEnabled = enabled;
      _history = history;
    });
  }

  void _generateCards() {
    final random = Random();
    final cards = <PlayingCard>[];
    final availableCards = _createDeck();

    if (!_allowDuplicates && _cardCount > availableCards.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Cannot generate $_cardCount cards. Only ${availableCards.length} are available.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final usedCards = <PlayingCard>{};

    for (int i = 0; i < _cardCount; i++) {
      PlayingCard selectedCard;

      if (_allowDuplicates) {
        selectedCard = availableCards[random.nextInt(availableCards.length)];
      } else {
        final availableForSelection =
            availableCards.where((card) => !usedCards.contains(card)).toList();
        if (availableForSelection.isEmpty) break;
        selectedCard =
            availableForSelection[random.nextInt(availableForSelection.length)];
        usedCards.add(selectedCard);
      }

      cards.add(selectedCard);
    }

    setState(() {
      _generatedCards = cards;
      _copied = false;
    });

    _animationController.forward(from: 0);

    // Save to history if enabled
    if (_historyEnabled) {
      final cardStrings = cards.map((card) => card.toString()).toList();
      GenerationHistoryService.addHistoryItem(
        cardStrings.join(', '),
        'playing_cards',
      ).then((_) => _loadHistory());
    }
  }

  List<PlayingCard> _createDeck() {
    final cards = <PlayingCard>[];

    // Standard 52 cards
    for (final suit in ['♠', '♥', '♦', '♣']) {
      for (final rank in [
        'A',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '10',
        'J',
        'Q',
        'K'
      ]) {
        cards.add(PlayingCard(suit: suit, rank: rank));
      }
    }

    // Add jokers if enabled
    if (_includeJokers) {
      cards.add(PlayingCard(suit: '🃏', rank: 'Joker'));
      cards.add(PlayingCard(suit: '��', rank: 'Joker'));
    }

    return cards;
  }

  void _copyToClipboard() {
    if (_generatedCards.isEmpty) return;

    final cardStrings =
        _generatedCards.map((card) => card.toString()).join(', ');
    Clipboard.setData(ClipboardData(text: cardStrings));
    setState(() {
      _copied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.copied),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyHistoryItem(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.copied),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getSuitColor(String suit) {
    if (suit == '♥' || suit == '♦') {
      return Colors.red;
    } else if (suit == '♠' || suit == '♣') {
      return Colors.black;
    } else {
      return Colors.purple; // Joker
    }
  }

  Widget _buildSliderControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.cardCount,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _cardCountSlider,
                    min: 1,
                    max: _includeJokers ? 54 : 52,
                    divisions: _includeJokers ? 53 : 51,
                    label: _cardCount.toString(),
                    onChanged: (value) {
                      setState(() {
                        _cardCountSlider = value;
                        _cardCount = value.round();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      _cardCount.toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.includeJokers),
              value: _includeJokers,
              onChanged: (value) {
                setState(() {
                  _includeJokers = value;
                  if (!value && _cardCount > 52) {
                    _cardCount = 52;
                    _cardCountSlider = 52.0;
                  }
                });
              },
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.allowDuplicates),
              value: _allowDuplicates,
              onChanged: (value) {
                setState(() {
                  _allowDuplicates = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.randomResult,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_generatedCards.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      _copied ? Icons.check : Icons.copy,
                      color: _copied ? Colors.green : null,
                    ),
                    onPressed: _copyToClipboard,
                    tooltip: AppLocalizations.of(context)!.copyToClipboard,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_generatedCards.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.style,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.generate,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              )
            else
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animationController.value,
                    child: Transform.scale(
                      scale: 0.8 + (0.2 * _animationController.value),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _generatedCards
                            .map((card) => _buildCardWidget(card))
                            .toList(),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardWidget(PlayingCard card) {
    return Container(
      width: 80,
      height: 112,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            card.rank,
            style: TextStyle(
              fontSize: card.rank == '10' ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: _getSuitColor(card.suit),
            ),
          ),
          Text(
            card.suit,
            style: TextStyle(
              fontSize: 20,
              color: _getSuitColor(card.suit),
            ),
          ),
          Text(
            card.rank,
            style: TextStyle(
              fontSize: card.rank == '10' ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: _getSuitColor(card.suit),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryWidget(AppLocalizations loc) {
    return RandomGeneratorHistoryWidget(
      historyType: 'playing_cards',
      history: _history,
      title: loc.generationHistory,
      onClearHistory: () async {
        await GenerationHistoryService.clearHistory('playing_cards');
        await _loadHistory();
      },
      onCopyItem: _copyHistoryItem,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final generatorContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSliderControls(),
        const SizedBox(height: 16),
        _buildResultCard(),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _generateCards,
            icon: const Icon(Icons.casino),
            label: Text(loc.generate),
          ),
        ),
      ],
    );

    return RandomGeneratorLayout(
      generatorContent: generatorContent,
      historyWidget: _buildHistoryWidget(loc),
      historyEnabled: _historyEnabled,
      hasHistory: _historyEnabled,
      isEmbedded: widget.isEmbedded,
      title: loc.playingCards,
    );
  }
}

class PlayingCard {
  final String suit;
  final String rank;

  PlayingCard({required this.suit, required this.rank});

  @override
  String toString() => '$rank$suit';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayingCard &&
          runtimeType == other.runtimeType &&
          suit == other.suit &&
          rank == other.rank;

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;
}
