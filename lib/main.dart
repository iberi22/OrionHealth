// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:async';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'l10n/app_localizations.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';

import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'features/local_agent/infrastructure/services/medical_indexing_service.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/onboarding/application/onboarding_cubit.dart';
import 'features/sync/infrastructure/sync_repository.dart';
import 'features/home/presentation/pages/main_navigation_page.dart';

// ─────────────────────────────────────────────
// BACKGROUND SYNC
// ─────────────────────────────────────────────

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await configureDependencies();
      final syncRepository = getIt<SyncRepository>();
      await syncRepository.syncAll();
      return true;
    } catch (e) {
      return false;
    }
  });
}

// ─────────────────────────────────────────────
// MAIN ENTRY POINT
// ─────────────────────────────────────────────

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    tz.initializeTimeZones();

    await Workmanager().initialize(
      callbackDispatcher,
    );

    await Workmanager().registerPeriodicTask(
      "fhir-sync-task",
      "fhirSyncTask",
      frequency: const Duration(hours: 6),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );

    // Global error handlers
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack);
    };

    try {
      await configureDependencies();
      await getIt<MemoryGraph>().initialize();

      // Index medical standards and patient context at startup
      unawaited(getIt<MedicalIndexingService>().indexAll());

      runApp(const MyApp());
    } catch (e, stack) {
      _logError(e, stack);
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Error de Inicialización',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hubo un problema al iniciar OrionHealth. Por favor, intenta reiniciar la aplicación.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => main(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: Colors.black,
        ),
      ));
    }
  }, (error, stack) {
    _logError(error, stack);
  });
}

void _logError(Object error, StackTrace? stack) {
  // ignore: avoid_print
  print('--- FATAL ERROR ---');
  // ignore: avoid_print
  print(error);
  // ignore: avoid_print
  print(stack);
}

// ─────────────────────────────────────────────
// APP ROOT
// ─────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es', ''), // Force Spanish for now as requested
      home: const _StartupRouter(),
    );
  }
}

// ─────────────────────────────────────────────
// STARTUP ROUTER — checks onboarding flag
// ─────────────────────────────────────────────

class _StartupRouter extends StatelessWidget {
  const _StartupRouter();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SharedPreferences.getInstance()
          .then((p) => p.getBool('onboarding_completed') ?? false),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.data == true) {
          return const MainNavigationPage();
        }
        return BlocProvider(
          create: (_) => getIt<OnboardingCubit>(),
          child: const OnboardingPage(),
        );
      },
    );
  }
}
