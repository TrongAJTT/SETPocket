import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/models/random_generator.dart';

class ColorGeneratorScreen extends StatefulWidget {
  const ColorGeneratorScreen({super.key});

  @override
  State<ColorGeneratorScreen> createState() => _ColorGeneratorScreenState();
}

class _ColorGeneratorScreenState extends State<ColorGeneratorScreen>
    with SingleTickerProviderStateMixin {
  Color _generatedColor = Colors.blue;
  bool _withAlpha = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _generateColor();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateColor() {
    _controller.reset();
    _controller.forward();

    setState(() {
      _generatedColor = RandomGenerator.generateColor(withAlpha: _withAlpha);
    });
  }

  String _getHexColor() {
    if (_withAlpha) {
      return '#${_generatedColor.value.toRadixString(16).padLeft(8, '0')}';
    } else {
      return '#${_generatedColor.value.toRadixString(16).substring(2).padLeft(6, '0')}';
    }
  }

  String _getRgbColor() {
    if (_withAlpha) {
      return 'rgba(${_generatedColor.red}, ${_generatedColor.green}, ${_generatedColor.blue}, ${_generatedColor.alpha / 255})';
    } else {
      return 'rgb(${_generatedColor.red}, ${_generatedColor.green}, ${_generatedColor.blue})';
    }
  }

  void _copyToClipboard(String value) {
    Clipboard.setData(ClipboardData(text: value));
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.copied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.colorGenerator),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Color display
          Expanded(
            flex: 3,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  color: _generatedColor,
                  child: Center(
                    child: Transform.scale(
                      scale: 0.7 + (_animation.value * 0.3),
                      child: Text(
                        _getHexColor(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _isColorDark(_generatedColor)
                              ? Colors.white
                              : Colors.black,
                          shadows: [
                            Shadow(
                              color: _isColorDark(_generatedColor)
                                  ? Colors.black38
                                  : Colors.white38,
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Controls
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Format selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: Text(loc.hex6),
                              value: false,
                              groupValue: _withAlpha,
                              onChanged: (value) {
                                setState(() {
                                  _withAlpha = value ?? false;
                                  _generateColor();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: Text(loc.hex8),
                              value: true,
                              groupValue: _withAlpha,
                              onChanged: (value) {
                                setState(() {
                                  _withAlpha = value ?? true;
                                  _generateColor();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Color info
                  Text(
                    loc.generatedColor,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildColorInfoCard(
                          'HEX',
                          _getHexColor(),
                          onTap: () => _copyToClipboard(_getHexColor()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildColorInfoCard(
                          'RGB',
                          _getRgbColor(),
                          onTap: () => _copyToClipboard(_getRgbColor()),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Generate button
                  FilledButton.icon(
                    onPressed: _generateColor,
                    icon: const Icon(Icons.refresh),
                    label: Text(loc.generate),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorInfoCard(String title, String value,
      {VoidCallback? onTap}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.copyToClipboard,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isColorDark(Color color) {
    // Calculate luminance of the color
    double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance < 0.5;
  }
}
