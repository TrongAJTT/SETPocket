import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/generation_history_service.dart';
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
      cards.add(PlayingCard(suit: '🃏', rank: 'Joker'));
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
                Container(
                  width: 60,
                  margin: const EdgeInsets.only(left: 16),
                  child: TextFormField(
                    controller:
                        TextEditingController(text: _cardCount.toString()),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    onChanged: (value) {
                      final newCount = int.tryParse(value);
                      if (newCount != null &&
                          newCount >= 1 &&
                          newCount <= (_includeJokers ? 54 : 52)) {
                        setState(() {
                          _cardCount = newCount;
                          _cardCountSlider = newCount.toDouble();
                        });
                      }
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
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
                  // Update slider max and reset count if necessary
                  final maxCards = value ? 54 : 52;
                  if (_cardCount > maxCards) {
                    _cardCount = maxCards;
                    _cardCountSlider = maxCards.toDouble();
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
      width: 60,
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            card.rank,
            style: TextStyle(
              fontSize: card.rank == '10' ? 10 : 12,
              fontWeight: FontWeight.bold,
              color: _getSuitColor(card.suit),
            ),
          ),
          Text(
            card.suit,
            style: TextStyle(
              fontSize: 16,
              color: _getSuitColor(card.suit),
            ),
          ),
          Text(
            card.rank,
            style: TextStyle(
              fontSize: card.rank == '10' ? 10 : 12,
              fontWeight: FontWeight.bold,
              color: _getSuitColor(card.suit),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryWidget() {
    if (!_historyEnabled || _history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        AppLocalizations.of(context)!.generationHistory,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () async {
                            await GenerationHistoryService.clearHistory(
                                'playing_cards');
                            _loadHistory();
                          },
                          icon: const Icon(Icons.clear_all),
                          label:
                              Text(AppLocalizations.of(context)!.clearHistory),
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
                          AppLocalizations.of(context)!.generationHistory,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          await GenerationHistoryService.clearHistory(
                              'playing_cards');
                          _loadHistory();
                        },
                        icon: const Icon(Icons.clear_all),
                        label: Text(AppLocalizations.of(context)!.clearHistory),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        item.value,
                        style: const TextStyle(fontFamily: 'monospace'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${AppLocalizations.of(context)!.generatedAt}: ${item.timestamp.toString().split('.')[0]}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () => _copyHistoryItem(item.value),
                        tooltip: AppLocalizations.of(context)!.copyToClipboard,
                      ),
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
    final loc = AppLocalizations.of(context)!;

    // Build main content and history widgets
    final mainContent = Column(
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

    final historyWidget = _buildHistoryWidget();

    // Responsive layout: side-by-side for large screens, vertical for small screens
    Widget content;
    if (MediaQuery.of(context).size.width >= 1200 &&
        _historyEnabled &&
        _history.isNotEmpty) {
      // Large screen: side-by-side layout
      content = Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content takes 60% of width
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: mainContent,
              ),
            ),
            const SizedBox(width: 16),
            // History takes 40% of width
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: historyWidget,
              ),
            ),
          ],
        ),
      );
    } else {
      // Small screen: vertical layout
      content = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            mainContent,
            historyWidget,
          ],
        ),
      );
    }

    if (widget.isEmbedded) {
      return content;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.playingCards),
        ),
        body: content,
      );
    }
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
