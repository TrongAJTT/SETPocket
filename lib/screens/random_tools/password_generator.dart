import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/models/random_generator.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  int _passwordLength = 12;
  bool _includeLowercase = true;
  bool _includeUppercase = true;
  bool _includeNumbers = true;
  bool _includeSpecial = true;
  String _generatedPassword = '';
  bool _copied = false;

  void _generatePassword() {
    setState(() {
      try {
        _generatedPassword = RandomGenerator.generatePassword(
          length: _passwordLength,
          includeLowercase: _includeLowercase,
          includeUppercase: _includeUppercase,
          includeNumbers: _includeNumbers,
          includeSpecial: _includeSpecial,
        );
        _copied = false;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    setState(() {
      _copied = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.copied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.passwordGenerator),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                          loc.numCharacters,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '$_passwordLength',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _passwordLength.toDouble(),
                      min: 4,
                      max: 32,
                      divisions: 28,
                      label: _passwordLength.toString(),
                      onChanged: (double value) {
                        setState(() {
                          _passwordLength = value.round();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: Text(loc.includeLowercase),
                      value: _includeLowercase,
                      onChanged: (value) {
                        setState(() {
                          _includeLowercase = value ?? true;
                        });
                      },
                      dense: true,
                    ),
                    CheckboxListTile(
                      title: Text(loc.includeUppercase),
                      value: _includeUppercase,
                      onChanged: (value) {
                        setState(() {
                          _includeUppercase = value ?? true;
                        });
                      },
                      dense: true,
                    ),
                    CheckboxListTile(
                      title: Text(loc.includeNumbers),
                      value: _includeNumbers,
                      onChanged: (value) {
                        setState(() {
                          _includeNumbers = value ?? true;
                        });
                      },
                      dense: true,
                    ),
                    CheckboxListTile(
                      title: Text(loc.includeSpecial),
                      value: _includeSpecial,
                      onChanged: (value) {
                        setState(() {
                          _includeSpecial = value ?? true;
                        });
                      },
                      dense: true,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _generatePassword,
                        icon: const Icon(Icons.refresh),
                        label: Text(loc.generate),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_generatedPassword.isNotEmpty) ...[
              Text(
                loc.generatedPassword,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SelectableText(
                        _generatedPassword,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 20,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}
