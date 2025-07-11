import 'package:flutter/material.dart';
import 'package:setpocket/services/random_services/unified_random_state_service.dart';
import 'package:setpocket/models/random_models/random_state_models.dart';

/// Demo screen to test the new UnifiedRandomStateService
class UnifiedRandomStateDemo extends StatefulWidget {
  const UnifiedRandomStateDemo({super.key});

  @override
  State<UnifiedRandomStateDemo> createState() => _UnifiedRandomStateDemoState();
}

class _UnifiedRandomStateDemoState extends State<UnifiedRandomStateDemo> {
  String _status = 'Ready';
  Map<String, dynamic> _migrationStatus = {};
  Map<String, dynamic> _stateInfo = {};
  int _stateCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshInfo();
  }

  Future<void> _refreshInfo() async {
    final stateInfo = await UnifiedRandomStateService.getStateInfo();
    final stateCount = await UnifiedRandomStateService.getStateCount();
    final savedToolIds = await UnifiedRandomStateService.getSavedToolIds();

    setState(() {
      _stateInfo = stateInfo;
      _stateCount = stateCount;
      _migrationStatus = {
        'status': 'development_mode',
        'message': 'No migration needed in development',
        'savedTools': savedToolIds,
      };
    });
  }

  Future<void> _testSaveLoadPassword() async {
    setState(() {
      _status = 'Testing password generator state...';
    });

    try {
      // Create a test password generator state
      final testState = PasswordGeneratorState.createDefault()
        ..passwordLength = 16
        ..includeUppercase = true
        ..includeLowercase = true
        ..includeNumbers = true
        ..includeSpecial = false;

      // Save the state
      await UnifiedRandomStateService.savePasswordGeneratorState(testState);

      // Load the state back
      final loadedState =
          await UnifiedRandomStateService.getPasswordGeneratorState();

      // Verify the data
      if (loadedState.passwordLength == 16 &&
          loadedState.includeUppercase == true &&
          loadedState.includeLowercase == true &&
          loadedState.includeNumbers == true &&
          loadedState.includeSpecial == false) {
        setState(() {
          _status = 'Password generator test: PASSED ✅';
        });
      } else {
        setState(() {
          _status = 'Password generator test: FAILED ❌';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Password generator test: ERROR - $e';
      });
    }

    await _refreshInfo();
  }

  Future<void> _testSaveLoadNumber() async {
    setState(() {
      _status = 'Testing number generator state...';
    });

    try {
      // Create a test number generator state
      final testState = NumberGeneratorState.createDefault()
        ..isInteger = false
        ..minValue = 5.5
        ..maxValue = 99.9
        ..quantity = 10
        ..allowDuplicates = false;

      // Save the state
      await UnifiedRandomStateService.saveNumberGeneratorState(testState);

      // Load the state back
      final loadedState =
          await UnifiedRandomStateService.getNumberGeneratorState();

      // Verify the data
      if (loadedState.isInteger == false &&
          loadedState.minValue == 5.5 &&
          loadedState.maxValue == 99.9 &&
          loadedState.quantity == 10 &&
          loadedState.allowDuplicates == false) {
        setState(() {
          _status = 'Number generator test: PASSED ✅';
        });
      } else {
        setState(() {
          _status = 'Number generator test: FAILED ❌';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Number generator test: ERROR - $e';
      });
    }

    await _refreshInfo();
  }

  Future<void> _performMigration() async {
    setState(() {
      _status = 'Migration not available in development mode';
    });

    await _refreshInfo();
  }

  Future<void> _clearAllStates() async {
    setState(() {
      _status = 'Clearing all states...';
    });

    try {
      await UnifiedRandomStateService.clearAllStates();
      setState(() {
        _status = 'Clear states: SUCCESS ✅';
      });
    } catch (e) {
      setState(() {
        _status = 'Clear states: ERROR - $e';
      });
    }

    await _refreshInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unified Random State Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Migration Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Migration Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    ..._migrationStatus.entries
                        .map((entry) => Text('${entry.key}: ${entry.value}'))
                        .toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // State Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current States ($_stateCount total)',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    if (_stateInfo.isEmpty)
                      const Text('No states saved')
                    else
                      ..._stateInfo.entries
                          .map((entry) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if (entry.value is Map)
                                      ...(entry.value as Map)
                                          .entries
                                          .map((subEntry) => Text(
                                              '  ${subEntry.key}: ${subEntry.value}'))
                                          .toList(),
                                  ],
                                ),
                              ))
                          .toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _testSaveLoadPassword,
                  child: const Text('Test Password'),
                ),
                ElevatedButton(
                  onPressed: _testSaveLoadNumber,
                  child: const Text('Test Number'),
                ),
                ElevatedButton(
                  onPressed: _performMigration,
                  child: const Text('Migrate'),
                ),
                ElevatedButton(
                  onPressed: _clearAllStates,
                  child: const Text('Clear All'),
                ),
                ElevatedButton(
                  onPressed: _refreshInfo,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
