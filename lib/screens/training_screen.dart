import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Используем AppBar в общем стиле, который мы задали в main.dart
      appBar: AppBar(
        title: Text(AppLocalizations.get('training') ?? 'Training'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 80, color: Colors.amber.shade700),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.get('underDevelopment'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.get('trainingDescription'),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}