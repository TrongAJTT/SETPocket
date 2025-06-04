import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/models/random_generator.dart';

class TimeGeneratorScreen extends StatefulWidget {
  const TimeGeneratorScreen({super.key});

  @override
  State<TimeGeneratorScreen> createState() => _TimeGeneratorScreenState();
}

class _TimeGeneratorScreenState extends State<TimeGeneratorScreen>
    with SingleTickerProviderStateMixin {
  TimeOfDay _startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 23, minute: 59);
  int _timeCount = 5;
  double _timeCountSlider = 5.0;
  bool _allowDuplicates = true;
  List<TimeOfDay> _generatedTimes = [];
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

  void _generateTimes() {
    try {
      setState(() {
        _generatedTimes = RandomGenerator.generateRandomTimes(
          startTime: _startTime,
          endTime: _endTime,
          count: _timeCount,
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
    String timesText = _generatedTimes.map((time) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }).join('\n');

    Clipboard.setData(ClipboardData(text: timesText));
    setState(() {
      _copied = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.copied)),
    );
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hours = tod.hour.toString().padLeft(2, '0');
    final minutes = tod.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  Widget _buildTimeSelector(
      String label, TimeOfDay time, Function(TimeOfDay?) onTimeSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final selectedTime = await showTimePicker(
              context: context,
              initialTime: time,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    alwaysUse24HourFormat: true,
                  ),
                  child: child!,
                );
              },
            );
            if (selectedTime != null) {
              onTimeSelected(selectedTime);
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
                const SizedBox(width: 12),
                Text(_formatTimeOfDay(time)),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelectors(AppLocalizations loc) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    final startTimeSelector = _buildTimeSelector(
      loc.startTime,
      _startTime,
      (time) {
        if (time != null) {
          setState(() {
            _startTime = time;
          });
        }
      },
    );

    final endTimeSelector = _buildTimeSelector(
      loc.endTime,
      _endTime,
      (time) {
        if (time != null) {
          setState(() {
            _endTime = time;
          });
        }
      },
    );

    if (isWideScreen) {
      // Side-by-side layout for desktop/tablet
      return Row(
        children: [
          Expanded(child: startTimeSelector),
          const SizedBox(width: 16),
          Expanded(child: endTimeSelector),
        ],
      );
    } else {
      // Always side-by-side for mobile too (like Date Generator)
      return Row(
        children: [
          Expanded(child: startTimeSelector),
          const SizedBox(width: 16),
          Expanded(child: endTimeSelector),
        ],
      );
    }
  }

  Widget _buildCountSlider(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.timeCount,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _timeCountSlider,
                min: 1,
                max: 10,
                divisions: 9,
                label: _timeCount.toString(),
                onChanged: (value) {
                  setState(() {
                    _timeCountSlider = value;
                    _timeCount = value.toInt();
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
                _timeCount.toString().padLeft(2, '0'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.timeGenerator),
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
                    // Time selectors (responsive layout)
                    _buildTimeSelectors(loc),

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
                        onPressed: _generateTimes,
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
            if (_generatedTimes.isNotEmpty)
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
                          children: _generatedTimes.map((time) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                _formatTimeOfDay(time),
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
