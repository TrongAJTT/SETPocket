import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/models/random_generator.dart';
import 'package:my_multi_tools/services/generation_history_service.dart';

class DateTimeGeneratorScreen extends StatefulWidget {
  final bool isEmbedded;

  const DateTimeGeneratorScreen({super.key, this.isEmbedded = false});

  @override
  State<DateTimeGeneratorScreen> createState() =>
      _DateTimeGeneratorScreenState();
}

class _DateTimeGeneratorScreenState extends State<DateTimeGeneratorScreen>
    with SingleTickerProviderStateMixin {
  DateTime _startDateTime = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDateTime = DateTime.now().add(const Duration(days: 30));
  int _dateTimeCount = 5;
  double _dateTimeCountSlider = 5.0;
  bool _allowDuplicates = true;
  List<DateTime> _generatedDateTimes = [];
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
    final history = await GenerationHistoryService.getHistory('date_time');
    setState(() {
      _historyEnabled = enabled;
      _history = history;
    });
  }

  void _generateDateTimes() {
    try {
      final generatedDateTimes = RandomGenerator.generateRandomDateTimes(
        startDateTime: _startDateTime,
        endDateTime: _endDateTime,
        count: _dateTimeCount,
        allowDuplicates: _allowDuplicates,
      );

      setState(() {
        _generatedDateTimes = generatedDateTimes;
        _copied = false;
      });
      _animationController.forward(from: 0.0);

      // Save to history if enabled
      if (_historyEnabled && generatedDateTimes.isNotEmpty) {
        final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
        final dateTimeStrings = generatedDateTimes
            .map((dateTime) => dateTimeFormat.format(dateTime))
            .toList();
        GenerationHistoryService.addHistoryItem(
          dateTimeStrings.join(', '),
          'date_time',
        ).then((_) => _loadHistory()); // Refresh history
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyToClipboard() {
    if (_generatedDateTimes.isEmpty) return;

    final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    String dateTimesText = _generatedDateTimes.map((dateTime) {
      return dateTimeFormat.format(dateTime);
    }).join('\n');

    Clipboard.setData(ClipboardData(text: dateTimesText));
    setState(() {
      _copied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.copied)),
    );
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.generationHistory,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () async {
                    await GenerationHistoryService.clearHistory('date_time');
                    await _loadHistory();
                  },
                  child: Text(loc.clearHistory),
                ),
              ],
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
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildDateTimeSelectors(AppLocalizations loc) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    Widget buildDateTimeSelector(
      String label,
      DateTime dateTime,
      Function(DateTime) onChanged,
    ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Date picker
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: dateTime,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      onChanged(DateTime(
                        date.year,
                        date.month,
                        date.day,
                        dateTime.hour,
                        dateTime.minute,
                      ));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          dateFormat.format(dateTime),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Time picker
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: dateTime.hour,
                        minute: dateTime.minute,
                      ),
                    );
                    if (time != null) {
                      onChanged(DateTime(
                        dateTime.year,
                        dateTime.month,
                        dateTime.day,
                        time.hour,
                        time.minute,
                      ));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          timeFormat.format(dateTime),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    final startSelector = buildDateTimeSelector(
      loc.startDate,
      _startDateTime,
      (newDateTime) {
        setState(() {
          _startDateTime = newDateTime;
          if (_startDateTime.isAfter(_endDateTime)) {
            _endDateTime = _startDateTime.add(const Duration(hours: 1));
          }
        });
      },
    );

    final endSelector = buildDateTimeSelector(
      loc.endDate,
      _endDateTime,
      (newDateTime) {
        setState(() {
          _endDateTime = newDateTime;
          if (_startDateTime.isAfter(_endDateTime)) {
            _startDateTime = _endDateTime.subtract(const Duration(hours: 1));
          }
        });
      },
    );

    if (isWideScreen) {
      return Row(
        children: [
          Expanded(child: startSelector),
          const SizedBox(width: 16),
          Expanded(child: endSelector),
        ],
      );
    } else {
      return Column(
        children: [
          startSelector,
          const SizedBox(height: 16),
          endSelector,
        ],
      );
    }
  }

  Widget _buildCountSlider(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.quantity,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _dateTimeCountSlider,
                min: 1.0,
                max: 50.0,
                divisions: 49,
                label: _dateTimeCount.toString(),
                onChanged: (value) {
                  setState(() {
                    _dateTimeCountSlider = value;
                    _dateTimeCount = value.round();
                  });
                },
              ),
            ),
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _dateTimeCount.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionsSection(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.options,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(loc.allowDuplicates),
          value: _allowDuplicates,
          onChanged: (value) {
            setState(() {
              _allowDuplicates = value;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildMainContent(AppLocalizations loc) {
    final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Configuration card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date time selectors (responsive layout)
                _buildDateTimeSelectors(loc),

                const SizedBox(height: 16),

                // Count slider and Options section (responsive layout)
                MediaQuery.of(context).size.width > 600
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildCountSlider(loc)),
                          const SizedBox(width: 32),
                          Expanded(flex: 2, child: _buildOptionsSection(loc)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildCountSlider(loc),
                          const SizedBox(height: 16),
                          _buildOptionsSection(loc),
                        ],
                      ),

                const SizedBox(height: 16),

                // Generate button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _generateDateTimes,
                    icon: const Icon(Icons.refresh),
                    label: Text(loc.generate),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Results card
        if (_generatedDateTimes.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.randomResult,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: Icon(_copied ? Icons.check : Icons.copy),
                        onPressed: _copyToClipboard,
                        tooltip: loc.copyToClipboard,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _animationController.value,
                        child: child,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _generatedDateTimes.map((dateTime) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              dateTimeFormat.format(dateTime),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontFamily: 'monospace',
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // Build main content and history widgets
    final mainContent = _buildMainContent(loc);
    final historyWidget = _buildHistoryWidget(loc);

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
            const SizedBox(height: 24),
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
          title: Text(loc.dateTimeGenerator),
        ),
        body: content,
      );
    }
  }
}
