import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/models/random_generator.dart';

class DateTimeGeneratorScreen extends StatefulWidget {
  const DateTimeGeneratorScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateDateTimes() {
    try {
      setState(() {
        _generatedDateTimes = RandomGenerator.generateRandomDateTimes(
          startDateTime: _startDateTime,
          endDateTime: _endDateTime,
          count: _dateTimeCount,
          allowDuplicates: _allowDuplicates,
        );
        _copied = false;
      });
      _animationController.forward(from: 0.0);
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

  Widget _buildCountSlider(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.quantity,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _dateTimeCountSlider,
                min: 1,
                max: 10,
                divisions: 9,
                label: _dateTimeCount.toString(),
                onChanged: (value) {
                  setState(() {
                    _dateTimeCountSlider = value;
                    _dateTimeCount = value.toInt();
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
                _dateTimeCount.toString().padLeft(2, '0'),
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');
    final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.dateTimeGenerator),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Configuration card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Start date and time
                    Text(
                      loc.startDate,
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
                                initialDate: _startDateTime,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  _startDateTime = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    _startDateTime.hour,
                                    _startDateTime.minute,
                                  );
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today),
                                  const SizedBox(width: 8),
                                  Text(dateFormat.format(_startDateTime)),
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
                                  hour: _startDateTime.hour,
                                  minute: _startDateTime.minute,
                                ),
                                builder: (context, child) {
                                  return MediaQuery(
                                    data: MediaQuery.of(context).copyWith(
                                      alwaysUse24HourFormat: true,
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) {
                                setState(() {
                                  _startDateTime = DateTime(
                                    _startDateTime.year,
                                    _startDateTime.month,
                                    _startDateTime.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time),
                                  const SizedBox(width: 8),
                                  Text(timeFormat.format(_startDateTime)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // End date and time
                    Text(
                      loc.endDate,
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
                                initialDate: _endDateTime,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  _endDateTime = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    _endDateTime.hour,
                                    _endDateTime.minute,
                                  );
                                  // Ensure start date time is before end date time
                                  if (_startDateTime.isAfter(_endDateTime)) {
                                    _startDateTime = _endDateTime
                                        .subtract(const Duration(hours: 1));
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today),
                                  const SizedBox(width: 8),
                                  Text(dateFormat.format(_endDateTime)),
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
                                  hour: _endDateTime.hour,
                                  minute: _endDateTime.minute,
                                ),
                                builder: (context, child) {
                                  return MediaQuery(
                                    data: MediaQuery.of(context).copyWith(
                                      alwaysUse24HourFormat: true,
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) {
                                setState(() {
                                  _endDateTime = DateTime(
                                    _endDateTime.year,
                                    _endDateTime.month,
                                    _endDateTime.day,
                                    time.hour,
                                    time.minute,
                                  );
                                  // Ensure start date time is before end date time
                                  if (_startDateTime.isAfter(_endDateTime)) {
                                    _startDateTime = _endDateTime
                                        .subtract(const Duration(hours: 1));
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time),
                                  const SizedBox(width: 8),
                                  Text(timeFormat.format(_endDateTime)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                              child: Text(
                                dateTimeFormat.format(dateTime),
                                style: Theme.of(context).textTheme.titleMedium,
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
        ),
      ),
    );
  }
}
