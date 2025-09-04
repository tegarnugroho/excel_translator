import 'package:flutter/material.dart';
import 'generated/generated_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excel Translator Demo',
      // 🎉 Super simple! All delegates included automatically
      localizationsDelegates: const [
        ...AppLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLanguages
          .map((language) => Locale(language))
          .toList(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _useSystemLanguage = true;
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = AppLocalizations.supportedLanguages.first;
  }

  @override
  Widget build(BuildContext context) {
    final systemLanguage = AppLocalizations.getSystemLanguage();

    // Get current localizations based on mode
    final AppLocalizations currentLocalizations = _useSystemLanguage
        ? AppLocalizations.current
        : AppLocalizations(_selectedLanguage!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Excel Translator Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Language Selection Mode Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Language Selection Mode',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ToggleButtons(
                      isSelected: [_useSystemLanguage, !_useSystemLanguage],
                      onPressed: (index) {
                        setState(() {
                          _useSystemLanguage = index == 0;
                        });
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Auto (System)'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Manual'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Manual Language Selection (when not using system)
            if (!_useSystemLanguage)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Language',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _selectedLanguage,
                        isExpanded: true,
                        items:
                            AppLocalizations.supportedLanguages.map((language) {
                          return DropdownMenuItem(
                            value: language,
                            child: Text(language.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedLanguage = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // System Language Information
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'System Language Detection',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Detected System Language: $systemLanguage'),
                    Text(
                        'Current Language Code: ${currentLocalizations.languageCode}'),
                    Text(
                        'Using System Detection: ${_useSystemLanguage ? "Yes" : "No"}'),
                    const SizedBox(height: 8),
                    const Text(
                      'How it works:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                        '• Auto mode: Automatically detects your system language'),
                    const Text('• Manual mode: Uses your selected language'),
                    const Text(
                        '• Falls back to English if language not supported'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Localized Content Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentLocalizations.login.hello,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentLocalizations.login
                          .welcomeMessage(name: 'User'),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentLocalizations.login.userCount(count: 42),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Buttons Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Interactive Buttons',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${currentLocalizations.buttons.submit} - Button pressed!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(currentLocalizations.buttons.submit),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                                currentLocalizations.login.appTitle),
                            content: Text(
                                'Language: ${currentLocalizations.languageCode.toUpperCase()}'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(currentLocalizations
                                    .login.cancelButton),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(currentLocalizations
                                    .login.saveButton),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                currentLocalizations.login.goodbye),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Text(currentLocalizations.login.goodbye),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // All Available Translations
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Available Translations',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...AppLocalizations.supportedLanguages.map((lang) {
                      final localizations = AppLocalizations(lang);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              alignment: Alignment.center,
                              child: Text(
                                lang.toUpperCase(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${localizations.login.hello} - ${localizations.login.welcomeMessage(name: 'World')}',
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Technical Information
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Technical Information',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Supported Languages: ${AppLocalizations.supportedLanguages.join(", ").toUpperCase()}'),
                    Text(
                        'Total Translations: ${AppLocalizations.supportedLanguages.length} languages'),
                    const Text(
                        'System Detection: PlatformDispatcher + Platform.localeName'),
                    const Text(
                        'Generated from Excel file with automatic fallbacks'),
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
