import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/random_generator.dart';
import 'package:setpocket/services/generation_history_service.dart';
import 'package:setpocket/widgets/random_generator_layout.dart';

class DateGeneratorScreen extends StatefulWidget {
  final bool isEmbedded;

  const DateGeneratorScreen({super.key, this.isEmbedded = false});

  @override
  State<DateGeneratorScreen> createState() => _DateGeneratorScreenState();
}

class _DateGeneratorScreenState extends State<DateGeneratorScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 365));
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  int _dateCount = 5;
  double _dateCountSlider = 5.0;
  bool _allowDuplicates = true;
  List<DateTime> _generatedDates = [];
  bool _copied = false;
  List<GenerationHistoryItem> _history = [];
  bool _historyEnabled = false;
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final enabled = await GenerationHistoryService.isHistoryEnabled();
    final history = await GenerationHistoryService.getHistory('date');
    setState(() {
      _historyEnabled = enabled;
      _history = history;
    });
  }

  void _generateDates() {
    try {
      setState(() {
        _generatedDates = RandomGenerator.generateRandomDates(
          startDate: _startDate,
          endDate: _endDate,
          count: _dateCount,
          allowDuplicates: _allowDuplicates,
        );
        _copied = false;
      });

      // Save to history if enabled
      if (_historyEnabled && _generatedDates.isNotEmpty) {
        final formatter = DateFormat('yyyy-MM-dd');
        final datesText =
            _generatedDates.map((date) => formatter.format(date)).join(', ');
        GenerationHistoryService.addHistoryItem(
          datesText,
          'date',
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
    final formatter = DateFormat('yyyy-MM-dd');
    String datesText = _generatedDates.map((date) {
      return formatter.format(date);
    }).join('\n');

    Clipboard.setData(ClipboardData(text: datesText));
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

  Widget _buildDateSelector(String label, DateTime date, VoidCallback onTap) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateFormat.format(date)),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelectors(AppLocalizations loc) {
    final startDateSelector = _buildDateSelector(
      loc.startDate,
      _startDate,
      () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          setState(() {
            _startDate = date;
            // Ensure start date is before end date
            if (_startDate.isAfter(_endDate)) {
              _endDate = _startDate.add(const Duration(days: 1));
            }
          });
        }
      },
    );

    final endDateSelector = _buildDateSelector(
      loc.endDate,
      _endDate,
      () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _endDate,
          firstDate: _startDate,
          lastDate: DateTime(2100),
        );
        if (date != null) {
          setState(() {
            _endDate = date;
          });
        }
      },
    ); // Always use vertical layout for Start Date and End Date
    return Column(
      children: [
        startDateSelector,
        const SizedBox(height: 16),
        endDateSelector,
      ],
    );
  }

  Widget _buildCountSlider(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.dateCount,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _dateCountSlider,
                min: 1,
                max: 10,
                divisions: 9,
                label: _dateCount.toString(),
                onChanged: (value) {
                  setState(() {
                    _dateCountSlider = value;
                    _dateCount = value.toInt();
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _dateCount.toString().padLeft(2, '0'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtherSection(AppLocalizations loc) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    final duplicatesCheckbox = CheckboxListTile(
      title: Text(loc.allowDuplicates),
      value: _allowDuplicates,
      onChanged: (value) {
        setState(() {
          _allowDuplicates = value ?? true;
        });
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.other,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (isWideScreen)
          // Center vertically on PC
          Center(
            child: duplicatesCheckbox,
          )
        else
          // Normal layout on mobile
          duplicatesCheckbox,
      ],
    );
  }

  Widget _buildHistoryWidget(AppLocalizations loc) {
    return RandomGeneratorHistoryWidget(
      historyType: 'date',
      history: _history,
      title: loc.generationHistory,
      onClearHistory: () async {
        await GenerationHistoryService.clearHistory('date');
        await _loadHistory();
      },
      onCopyItem: _copyHistoryItem,
      customItemBuilder: (item, context) {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Build main content widget
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
                // Date selectors (responsive layout)
                _buildDateSelectors(loc),

                const SizedBox(height: 16),

                // Count slider and Other section (responsive layout)
                MediaQuery.of(context).size.width > 600
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildCountSlider(loc)),
                          const SizedBox(width: 32),
                          Expanded(flex: 2, child: _buildOtherSection(loc)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildCountSlider(loc),
                          const SizedBox(height: 16),
                          _buildOtherSection(loc),
                        ],
                      ),

                const SizedBox(height: 16),

                // Generate button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _generateDates,
                    icon: const Icon(Icons.refresh),
                    label: Text(loc.generate),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Results
        if (_generatedDates.isNotEmpty) ...[
          Text(
            loc.randomResult,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _generatedDates.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final date = _generatedDates[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          dateFormat.format(date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          DateFormat('EEEE').format(date),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        trailing: Text(
                          DateFormat.yMMMMd().format(date),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _copyToClipboard,
                    icon: Icon(_copied ? Icons.check : Icons.copy),
                    label: Text(_copied ? loc.copied : loc.copyToClipboard),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );

    return RandomGeneratorLayout(
      generatorContent: generatorContent,
      historyWidget: _buildHistoryWidget(loc),
      historyEnabled: _historyEnabled,
      hasHistory: _history.isNotEmpty,
      isEmbedded: widget.isEmbedded,
      title: loc.dateGenerator,
    );
  }
}
