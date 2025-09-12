import 'package:flutter/material.dart';
import '../Controller/controller.dart';
import 'components/custom_color_dialog.dart';
import 'components/qr_modal_sheet.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>  {
  late String currentLanguage;
  late String currentColorScheme;
  bool showAllLanguages = false;
  bool showAllThemes = false;
  late bool pushNotificationsEnabled;// = Controller.readHiveNotification();

  @override
  void initState(){
    super.initState();
    currentLanguage = Controller.getCurrentLanguage();
    currentColorScheme = Controller.getCurrentColorScheme(context);
    pushNotificationsEnabled = Controller.getCurrentNotification();
  }


  Widget _buildLanguageTile(String langCode) {
    final flag = switch (langCode) {
      'de' => '🇩🇪',
      'en' => '🇬🇧',
      'es' => '🇪🇸',
      'fr' => '🇫🇷',
      'nl' => '🇳🇱',
      'it' => '🇮🇹',
      'ja' => '🇯🇵',
      'schwäbisch' => '🇩🇪',
      'bayrisch' => '🇩🇪',
      _ => '🌐',              // Default
    };
    final label = langCode == 'de'
      ? Controller.getTextLabel('Language_German')
      : langCode == 'en'
        ? Controller.getTextLabel('Language_English')
        : langCode == 'es'
          ? Controller.getTextLabel('Language_Spanish')
          : langCode == 'fr'
            ? Controller.getTextLabel('Language_French')
            : langCode == 'nl'
              ? Controller.getTextLabel('Language_Dutch')
              : langCode == 'it'
                  ? Controller.getTextLabel('Language_Italian')
                  : langCode == 'ja'
                    ? Controller.getTextLabel('Language_Japanese')
                    : langCode == 'schwäbisch'
                      ? Controller.getTextLabel('Language_Schwäbisch')
                      : langCode == 'bayrisch'
                        ? Controller.getTextLabel('Language_Bayrisch')
                        : langCode.toUpperCase();

    return GestureDetector(
      onTap: () async {
        await Controller.setLanguage(context, langCode);
        // writing to hive when language is set
        await Controller.writeHiveLanguage(langCode);
        setState(() {
          currentLanguage = langCode;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: currentLanguage == langCode
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: currentLanguage == langCode
              ? Border(
            left: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 8,
            ),
          )
              : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
          ],
        )
      )
    );
  }

  Widget _buildColorSquare(String schemeName) {
    final scheme = Controller.getColorSchemeByKey(context, schemeName);
    final isSelected = currentColorScheme == schemeName;
    return GestureDetector(
      onTap: () {
        Controller.setColorScheme(context, schemeName);
        // write to hive when setting the colorScheme
        Controller.writeHiveColor(schemeName);
        setState(() {
          currentColorScheme = schemeName;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 4 - 20,
            height: 60,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          if (isSelected)
            const Icon(Icons.check, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildNotificationSwitch() {
    return GestureDetector(
      onTap: () async {
        final newValue = !pushNotificationsEnabled;
        await Controller.setNotification(context, newValue);
        await Controller.writeHiveNotification(newValue);
        setState(() {
          pushNotificationsEnabled = newValue;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: pushNotificationsEnabled
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Controller.getTextLabel('Settings_Notification_Switch'),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Switch(
              value: pushNotificationsEnabled,
              onChanged: (value) async {
                await Controller.setNotification(context, value);
                await Controller.writeHiveNotification(value);
                setState(() {
                  pushNotificationsEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Custom Color Kachel
  Widget _buildCustomColorTile() {
    final isSelected = currentColorScheme == 'customColor';
    ColorScheme scheme;
    try {
      scheme = Controller.getColorSchemeByKey(context, 'customColor');
    } catch (_) {
      scheme = Controller.getColorSchemeByKey(context, 'lightblue');
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const CustomColorDialog(),
        ).then((_) {
          Controller.setLifetimeStats(context);
          setState(() {
            currentColorScheme = Controller.getCurrentColorScheme(context);
          });
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 4 - 20,
        height: 60,
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.palette, color: Colors.black54),
                  SizedBox(height: 4),
                  Text("Custom", style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            if (isSelected)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(Icons.check_circle, color: Colors.white, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  void _openQrDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const QrModalSheet(),
    ).then((_) {
      setState(() {
        currentLanguage = Controller.getCurrentLanguage();
        currentColorScheme = Controller.getCurrentColorScheme(context);
        pushNotificationsEnabled = Controller.getCurrentNotification();
      });
      Controller.setLifetimeStats(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final availableLanguages = Controller.getAvailableLanguages();
    final availableColors = Controller.getAvailableColorSchemes(context)
        .where((c) => c != 'customColor')
        .toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text(
              Controller.getTextLabel('Settings_Title'),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
          ),
          const SizedBox(height: 24),

          //Toggle Button for Push Notifications
          Text(Controller.getTextLabel('Settings_Notification_Label')),
          _buildNotificationSwitch(),
          const Divider(height: 32),

          /// Language Tile
          Text(Controller.getTextLabel('Settings_Language')),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLanguageTile('de'),
              _buildLanguageTile('en'),
              if (showAllLanguages)
                ...availableLanguages
                    .where((lang) => lang != 'de' && lang != 'en')
                    .map(_buildLanguageTile),
              TextButton(
                onPressed: () {
                  setState(() {
                    showAllLanguages = !showAllLanguages;
                  });
                },
                child: Text(showAllLanguages ? Controller.getTextLabel('Show_Less') : Controller.getTextLabel('Show_More'),
                style: const TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
          const Divider(height: 32),

          /// Color Scheme Tile
          Text(Controller.getTextLabel('Settings_Color')),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildCustomColorTile(),
              ...availableColors
                  .take(3)
                  .map((schemeName) => _buildColorSquare(schemeName)),
              if (showAllThemes)
                ...availableColors
                    .skip(3)
                    .map((schemeName) => _buildColorSquare(schemeName)),
            ],
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () {
              setState(() {
                showAllThemes = !showAllThemes;
              });
            },
            child: Text(
                showAllThemes
                  ? Controller.getTextLabel('Show_Less')
                  : Controller.getTextLabel('Show_More'),
                style: const TextStyle(color: Colors.black54),
            ),
          ),
          const Divider(height: 32),

          /// QR-Code Navigation
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: Text(Controller.getTextLabel('Settings_QR')),
            subtitle: Text(Controller.getTextLabel('Desc_QR_Demo')),
            onTap: () => _openQrDialog(context),
          ),
        ],
      ),
    );
  }
}


