import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/random_generator.dart';
import 'package:setpocket/services/generation_history_service.dart';
import 'package:setpocket/widgets/random_generator_layout.dart';

class DateTimeGeneratorScreen extends StatefulWidget {
  final bool isEmbedded;

  const DateTimeGeneratorScreen({super.key, this.isEmbedded = false});

  @override
  State<DateTimeGeneratorScreen> createState() =>
      _DateTimeGeneratorScreenState();
}

class _DateTimeGeneratorScreenState extends State<DateTimeGeneratorScreen>
    with SingleTickerProviderStateMixin {
  // Static DateFormat instances for better performance
  static final _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final _dateTimeFormatWithSeconds = DateFormat('yyyy-MM-dd HH:mm:ss');

  DateTime _startDateTime = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDateTime = DateTime.now().add(const Duration(days: 30));
  int _dateTimeCount = 5;
  double _dateTimeCountSlider = 5.0;
  bool _allowDuplicates = true;
  bool _includeSeconds = false;
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
        final dateTimeFormat =
            _includeSeconds ? _dateTimeFormatWithSeconds : _dateTimeFormat;
        final dateTimeStrings = generatedDateTimes
            .map((dateTime) => dateTimeFormat.format(dateTime))
            .toList();
        GenerationHistoryService.addHistoryItem(
          dateTimeStrings.join(', '),
          'date_time',
        ).then((_) => _loadHistory());
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

    final dateTimeFormat =
        _includeSeconds ? _dateTimeFormatWithSeconds : _dateTimeFormat;
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
    return RandomGeneratorHistoryWidget(
      historyType: 'date_time',
      history: _history,
      title: loc.generationHistory,
      onClearHistory: () async {
        await GenerationHistoryService.clearHistory('date_time');
        await _loadHistory();
      },
      onCopyItem: _copyHistoryItem,
      customItemBuilder: (item, context) => ListTile(
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
          '${loc.generatedAt}: ${item.timestamp.toString().split('.')[0]}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy, size: 18),
          onPressed: () => _copyHistoryItem(item.value),
          tooltip: loc.copyToClipboard,
        ),
      ),
    );
  }

  Future<void> _selectStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDateTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      if (mounted) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_startDateTime),
        );
        if (time != null) {
          setState(() {
            _startDateTime = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
            if (_startDateTime.isAfter(_endDateTime)) {
              _endDateTime = _startDateTime.add(const Duration(hours: 1));
            }
          });
        }
      }
    }
  }

  Future<void> _selectEndDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDateTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      if (mounted) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_endDateTime),
        );
        if (time != null) {
          setState(() {
            _endDateTime = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
            if (_endDateTime.isBefore(_startDateTime)) {
              _startDateTime = _endDateTime.subtract(const Duration(hours: 1));
            }
          });
        }
      }
    }
  }

  Widget _buildDateTimeField(
      String label, DateTime dateTime, bool isStartDate) {
    final dateTimeFormat =
        _includeSeconds ? _dateTimeFormatWithSeconds : _dateTimeFormat;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () =>
              isStartDate ? _selectStartDateTime() : _selectEndDateTime(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  dateTimeFormat.format(dateTime),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelectors(AppLocalizations loc) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth > 800
            ? Row(
                children: [
                  Expanded(
                      child: _buildDateTimeField(
                          loc.startDate, _startDateTime, true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildDateTimeField(
                          loc.endDate, _endDateTime, false)),
                ],
              )
            : Column(
                children: [
                  _buildDateTimeField(loc.startDate, _startDateTime, true),
                  const SizedBox(height: 16),
                  _buildDateTimeField(loc.endDate, _endDateTime, false),
                ],
              );
      },
    );
  }

  Widget _buildCountSlider(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.dateCount,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _dateTimeCountSlider,
                min: 1,
                max: 20,
                divisions: 19,
                label: _dateTimeCount.toString(),
                onChanged: (value) {
                  setState(() {
                    _dateTimeCountSlider = value;
                    _dateTimeCount = value.round();
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
                  _dateTimeCount.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
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

        // Responsive layout for options using LayoutBuilder
        LayoutBuilder(
          builder: (context, constraints) {
            return constraints.maxWidth > 800
                ? Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(loc.includeSeconds),
                          value: _includeSeconds,
                          onChanged: (value) {
                            setState(() {
                              _includeSeconds = value ?? false;
                            });
                          },
                          dense: true,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(loc.allowDuplicates),
                          value: _allowDuplicates,
                          onChanged: (value) {
                            setState(() {
                              _allowDuplicates = value ?? true;
                            });
                          },
                          dense: true,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      CheckboxListTile(
                        title: Text(loc.includeSeconds),
                        value: _includeSeconds,
                        onChanged: (value) {
                          setState(() {
                            _includeSeconds = value ?? false;
                          });
                        },
                        dense: true,
                      ),
                      CheckboxListTile(
                        title: Text(loc.allowDuplicates),
                        value: _allowDuplicates,
                        onChanged: (value) {
                          setState(() {
                            _allowDuplicates = value ?? true;
                          });
                        },
                        dense: true,
                      ),
                    ],
                  );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dateTimeFormat =
        _includeSeconds ? _dateTimeFormatWithSeconds : _dateTimeFormat;

    final generatorContent = Column(
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

                // Count slider
                _buildCountSlider(loc),

                const SizedBox(height: 16),

                // Options section
                _buildOptionsSection(loc),

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
                        final formattedDateTime =
                            dateTimeFormat.format(dateTime);
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
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    formattedDateTime,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                          fontFamily: 'monospace',
                                        ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18),
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: formattedDateTime));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(loc.copied)),
                                    );
                                  },
                                  tooltip: loc.copyToClipboard,
                                  style: IconButton.styleFrom(
                                    foregroundColor: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                              ],
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

    return RandomGeneratorLayout(
      generatorContent: generatorContent,
      historyWidget: _buildHistoryWidget(loc),
      historyEnabled: _historyEnabled,
      hasHistory: _historyEnabled,
      isEmbedded: widget.isEmbedded,
      title: loc.dateTimeGenerator,
    );
  }
}
