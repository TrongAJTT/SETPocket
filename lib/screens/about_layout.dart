import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/utils/snackbar_utils.dart';
import 'package:setpocket/utils/variables_utils.dart';
import 'package:setpocket/widgets/generic/generic_settings_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:setpocket/variables.dart';

/// About layout with GitHub, Sponsor, Credits, and Version information
class AboutLayout extends StatefulWidget {
  final bool showHeader;

  const AboutLayout({super.key, this.showHeader = true});

  @override
  State<AboutLayout> createState() => _AboutLayoutState();
}

class _AboutLayoutState extends State<AboutLayout> {
  PackageInfo? packageInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          packageInfo = info;
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle error silently, will show fallback version
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // App Header (conditional)
          if (widget.showHeader) ...[
            _buildAppHeader(theme),
            const SizedBox(height: 24),
          ],

          // GitHub Repository section
          ListTile(
            leading: Icon(
              Icons.code,
              color: theme.colorScheme.onPrimary,
            ),
            title: Text(l10n.githubRepo),
            subtitle: Text(l10n.githubRepoDesc),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _openUrl(githubRepoUrl),
          ),

          // Donate section
          ListTile(
            leading: const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            title: Text(l10n.donate),
            subtitle: Text(l10n.donateDesc),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showDonateDialog,
          ),

          // Credits & Acknowledgments section
          ListTile(
            leading: const Icon(
              Icons.groups,
              color: Colors.orange,
            ),
            title: Text(l10n.creditAck),
            subtitle: Text(l10n.creditAckDesc),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showCreditsDialog,
          ),

          // Version Information section
          ListTile(
            leading: const Icon(
              Icons.info,
              color: Colors.blue,
            ),
            title: Text(l10n.versionInfo),
            subtitle: Text(_getVersionString()),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showVersionDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAppHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                theme.primaryColor,
                theme.primaryColor.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            Icons.apps,
            size: 40,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'SETPocket',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Set of Essential Tools in one Pocket',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  String _getVersionString() {
    final l10n = AppLocalizations.of(context)!;
    final versionType = currentVersionType.getDisplayName(l10n);
    
    if (isLoading || packageInfo == null) {
      return 'Loading... ($versionType)';
    }
    
    return '${packageInfo!.version}+${packageInfo!.buildNumber} ($versionType)';
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: show snackbar with error
        if (mounted) {
          SnackbarUtils.showTyped(
            context,
            'Could not open URL: $url',
            SnackBarType.error,
          );
        }
      }
    } catch (e) {
      // Handle error silently or show user-friendly message
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          'Error opening URL: $e',
          SnackBarType.error,
        );
      }
    }
  }

  void _showDonateDialog() {
    final l10n = AppLocalizations.of(context)!;
    final config = GenericSettingsConfig<dynamic>(
      title: l10n.donate,
      settingsLayout: _buildDonateContent(),
      currentSettings: null,
      onSettingsChanged: (_) {},
      showActions: false,
      isCompact: false,
      barrierDismissible: true,
      padding: const EdgeInsets.all(16),
    );

    GenericSettingsHelper.showSettings(context, config);
  }

  Widget _buildDonateContent() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Donation header
          const Icon(
            Icons.favorite,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.supportDesc,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 24),

          // Donation options
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('GitHub Sponsors'),
            subtitle: Text(l10n.supportOnGitHub),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _openUrl(githubSponsorUrl),
          ),
          ListTile(
            leading: const Icon(Icons.coffee),
            title: const Text('Ko-fi'),
            subtitle: Text(l10n.buyMeCoffee),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _openUrl(donateKofiUrl),
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('PayPal'),
            subtitle: Text(l10n.oneTimeDonation),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _openUrl(paypalDonateUrl),
          ),
        ],
      ),
    );
  }

  void _showCreditsDialog() {
    final l10n = AppLocalizations.of(context)!;
    final config = GenericSettingsConfig<dynamic>(
      title: l10n.creditAck,
      settingsLayout: _buildCreditsContent(),
      currentSettings: null,
      onSettingsChanged: (_) {},
      showActions: false,
      isCompact: false,
      barrierDismissible: true,
      padding: const EdgeInsets.all(16),
    );

    GenericSettingsHelper.showSettings(context, config);
  }

  Widget _buildCreditsContent() {
    final libraries = _getLibraryList();

    return ListView.separated(
      shrinkWrap: true,
      itemCount: libraries.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final lib = libraries[index];
        return ListTile(
          title: Text(lib['name'] ?? ''),
          subtitle: Text('${lib['author'] ?? ''} • ${lib['license'] ?? ''}'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _openUrl('https://pub.dev/packages/${lib['name'] ?? ''}'),
        );
      },
    );
  }

  List<Map<String, String>> _getLibraryList() {
    return [
      {
        'name': 'flutter',
        'author': 'Flutter Team',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'file_picker',
        'author': 'Miguel Ruivo',
        'license': 'MIT',
      },
      {
        'name': 'path_provider',
        'author': 'Flutter Team',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'intl',
        'author': 'Dart Team',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'shared_preferences',
        'author': 'Flutter Team',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'crypto',
        'author': 'Dart Team',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'http',
        'author': 'Dart Team',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'fl_chart',
        'author': 'Iman Khoshabi',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'math_expressions',
        'author': 'Fabian Stein',
        'license': 'MIT',
      },
      {
        'name': 'decimal',
        'author': 'Alexandre Ardhuin',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'flutter_localizations',
        'author': 'Flutter Team',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'flutter_gen',
        'author': 'FlutterGen Team',
        'license': 'MIT',
      },
      {
        'name': 'logger',
        'author': 'Johannes Milke',
        'license': 'MIT',
      },
      {
        'name': 'logging',
        'author': 'Dart Team',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'quick_actions',
        'author': 'Flutter Team',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'window_manager',
        'author': 'LiJianying',
        'license': 'MIT',
      },
      {
        'name': 'flutter_colorpicker',
        'author': 'mchome',
        'license': 'MIT',
      },
      {
        'name': 'package_info_plus',
        'author': 'Flutter Community',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'url_launcher',
        'author': 'Flutter Team',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'connectivity_plus',
        'author': 'Flutter Community',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'network_info_plus',
        'author': 'Flutter Community',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'permission_handler',
        'author': 'Baseflow',
        'license': 'MIT',
      },
      {
        'name': 'device_info_plus',
        'author': 'Flutter Community',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'multicast_dns',
        'author': 'Flutter Team',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'socket_io_client',
        'author': 'Darshan Gada',
        'license': 'MIT',
      },
      {
        'name': 'dio',
        'author': 'Flutterchina',
        'license': 'MIT',
      },
      {
        'name': 'encrypt',
        'author': 'Leonardo Rignanese',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'pointycastle',
        'author': 'Dart Team',
        'license': 'BSD-2-Clause',
      },
      {
        'name': 'cryptography',
        'author': 'Gohilla',
        'license': 'Apache-2.0',
      },
      {
        'name': 'uuid',
        'author': 'Yulian Kuncheff',
        'license': 'MIT',
      },
      {
        'name': 'nsd',
        'author': 'Sebastian Roth',
        'license': 'MIT',
      },
      {
        'name': 'cupertino_icons',
        'author': 'Flutter Team',
        'license': 'MIT',
      },
      {
        'name': 'provider',
        'author': 'Remi Rousselet',
        'license': 'MIT',
      },
      {
        'name': 'open_file',
        'author': 'crazecoder',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'share_plus',
        'author': 'Flutter Community',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'path',
        'author': 'Dart Team',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'flutter_local_notifications',
        'author': 'MaikuB',
        'license': 'BSD-3-Clause',
      },
      {
        'name': 'workmanager',
        'author': 'Tim Visée',
        'license': 'MIT',
      },
      {
        'name': 'isar',
        'author': 'Simon Leier',
        'license': 'Apache-2.0',
      },
      {
        'name': 'isar_flutter_libs',
        'author': 'Simon Leier',
        'license': 'Apache-2.0',
      },
      {
        'name': 'get',
        'author': 'Jonny Borges',
        'license': 'MIT',
      },
    ];
  }

  void _showVersionDialog() {
    final l10n = AppLocalizations.of(context)!;
    final config = GenericSettingsConfig<dynamic>(
      title: l10n.versionInfo,
      settingsLayout: _buildVersionContent(),
      currentSettings: null,
      onSettingsChanged: (_) {},
      showActions: false,
      isCompact: false,
      barrierDismissible: true,
      padding: const EdgeInsets.all(16),
    );

    GenericSettingsHelper.showSettings(context, config);
  }

  Widget _buildVersionContent() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.tag),
            title: Text(l10n.appVersion),
            subtitle: Text(
              isLoading 
                ? 'Loading...' 
                : (packageInfo?.version ?? 'Unknown')
            ),
          ),
          // ListTile(
          //   leading: const Icon(Icons.build),
          //   title: const Text('Build Number'),
          //   subtitle: Text(buildNumber),
          // ),
          ListTile(
            leading: const Icon(Icons.science),
            title: Text(l10n.versionType),
            subtitle: Text(currentVersionType.getDisplayName(l10n)),
          ),
          ListTile(
            leading: const Icon(Icons.phone_android),
            title: Text(l10n.platform),
            subtitle: Text(Theme.of(context).platform.name),
          ),
        ],
      ),
    );
  }
}
