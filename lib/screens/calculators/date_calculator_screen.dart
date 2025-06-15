import 'package:flutter/material.dart';

class DateCalculatorScreen extends StatefulWidget {
  const DateCalculatorScreen({super.key});

  @override
  State<DateCalculatorScreen> createState() => _DateCalculatorScreenState();
}

class _DateCalculatorScreenState extends State<DateCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Date Difference Calculator
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String? _dateDifference;

  // Add/Subtract Date Calculator
  DateTime _baseDate = DateTime.now();
  int _daysToAdd = 0;
  int _monthsToAdd = 0;
  int _yearsToAdd = 0;
  DateTime? _resultDate;

  // Age Calculator
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 365 * 25));
  String? _ageResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _calculateDateDifference();
    _calculateNewDate();
    _calculateAge();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Calculator'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Difference', icon: Icon(Icons.date_range)),
            Tab(text: 'Add/Subtract', icon: Icon(Icons.add_circle)),
            Tab(text: 'Age', icon: Icon(Icons.cake)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDateDifferenceCalculator(),
          _buildAddSubtractCalculator(),
          _buildAgeCalculator(),
        ],
      ),
    );
  }

  Widget _buildDateDifferenceCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Date Difference Calculator',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildDateSelector(
            label: 'Start Date',
            date: _startDate,
            icon: Icons.start,
            onChanged: (date) {
              setState(() {
                _startDate = date;
                _calculateDateDifference();
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDateSelector(
            label: 'End Date',
            date: _endDate,
            icon: Icons.event,
            onChanged: (date) {
              setState(() {
                _endDate = date;
                _calculateDateDifference();
              });
            },
          ),
          const SizedBox(height: 24),
          if (_dateDifference != null) ...[
            _buildResultCard([
              _buildResultText('Duration', _dateDifference!),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildAddSubtractCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add/Subtract Date Calculator',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildDateSelector(
            label: 'Base Date',
            date: _baseDate,
            icon: Icons.calendar_today,
            onChanged: (date) {
              setState(() {
                _baseDate = date;
                _calculateNewDate();
              });
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Add/Subtract:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildNumberInput(
            label: 'Years',
            value: _yearsToAdd,
            icon: Icons.calendar_today,
            onChanged: (value) {
              setState(() {
                _yearsToAdd = value;
                _calculateNewDate();
              });
            },
          ),
          const SizedBox(height: 12),
          _buildNumberInput(
            label: 'Months',
            value: _monthsToAdd,
            icon: Icons.calendar_view_month,
            onChanged: (value) {
              setState(() {
                _monthsToAdd = value;
                _calculateNewDate();
              });
            },
          ),
          const SizedBox(height: 12),
          _buildNumberInput(
            label: 'Days',
            value: _daysToAdd,
            icon: Icons.calendar_view_day,
            onChanged: (value) {
              setState(() {
                _daysToAdd = value;
                _calculateNewDate();
              });
            },
          ),
          const SizedBox(height: 24),
          if (_resultDate != null) ...[
            _buildResultCard([
              _buildResultText(
                'Result Date',
                '${_resultDate!.day}/${_resultDate!.month}/${_resultDate!.year}',
              ),
              _buildResultText(
                'Day of Week',
                _getDayOfWeek(_resultDate!),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildAgeCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Age Calculator',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildDateSelector(
            label: 'Birth Date',
            date: _birthDate,
            icon: Icons.cake,
            onChanged: (date) {
              setState(() {
                _birthDate = date;
                _calculateAge();
              });
            },
          ),
          const SizedBox(height: 24),
          if (_ageResult != null) ...[
            _buildResultCard([
              _buildResultText('Your Age', _ageResult!),
              _buildResultText(
                'Days Lived',
                '${DateTime.now().difference(_birthDate).inDays} days',
              ),
              _buildResultText(
                'Hours Lived',
                '${DateTime.now().difference(_birthDate).inHours} hours',
              ),
              _buildResultText(
                'Next Birthday',
                _getNextBirthday(),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime date,
    required IconData icon,
    required Function(DateTime) onChanged,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text('${date.day}/${date.month}/${date.year}'),
        trailing: const Icon(Icons.calendar_month),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            onChanged(picked);
          }
        },
      ),
    );
  }

  Widget _buildNumberInput({
    required String label,
    required int value,
    required IconData icon,
    required Function(int) onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
        SizedBox(
          width: 120,
          child: Row(
            children: [
              IconButton(
                onPressed: () => onChanged(value - 1),
                icon: const Icon(Icons.remove),
                iconSize: 20,
              ),
              Expanded(
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add),
                iconSize: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(List<Widget> children) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildResultText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _calculateDateDifference() {
    final difference = _endDate.difference(_startDate);
    final days = difference.inDays;
    final years = days ~/ 365;
    final remainingDays = days % 365;
    final months = remainingDays ~/ 30;
    final finalDays = remainingDays % 30;

    String result = '';
    if (years > 0) result += '$years year${years > 1 ? 's' : ''} ';
    if (months > 0) result += '$months month${months > 1 ? 's' : ''} ';
    if (finalDays > 0 || result.isEmpty) {
      result += '$finalDays day${finalDays != 1 ? 's' : ''}';
    }

    _dateDifference = result.trim();
    _dateDifference = '$_dateDifference\n($days total days)';
  }

  void _calculateNewDate() {
    try {
      DateTime result =
          DateTime(_baseDate.year, _baseDate.month, _baseDate.day);

      // Add years
      result = DateTime(result.year + _yearsToAdd, result.month, result.day);

      // Add months
      result = DateTime(result.year, result.month + _monthsToAdd, result.day);

      // Add days
      result = result.add(Duration(days: _daysToAdd));

      _resultDate = result;
    } catch (e) {
      _resultDate = null;
    }
  }

  void _calculateAge() {
    final now = DateTime.now();

    int years = now.year - _birthDate.year;
    int months = now.month - _birthDate.month;
    int daysDiff = now.day - _birthDate.day;

    if (daysDiff < 0) {
      months--;
      daysDiff += DateTime(now.year, now.month, 0).day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    _ageResult =
        '$years year${years != 1 ? 's' : ''}, $months month${months != 1 ? 's' : ''}, $daysDiff day${daysDiff != 1 ? 's' : ''}';
  }

  String _getDayOfWeek(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[date.weekday - 1];
  }

  String _getNextBirthday() {
    final now = DateTime.now();
    DateTime nextBirthday =
        DateTime(now.year, _birthDate.month, _birthDate.day);

    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, _birthDate.month, _birthDate.day);
    }

    final daysUntil = nextBirthday.difference(now).inDays;
    return 'In $daysUntil days (${nextBirthday.day}/${nextBirthday.month}/${nextBirthday.year})';
  }
}
