import 'package:flutter/material.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_main_page.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<MemoryGraph>().initialize();
  runApp(const OnboardingPreview());
}

class OnboardingPreview extends StatelessWidget {
  const OnboardingPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onboarding Preview',
      theme: CyberTheme.darkTheme,
      home: OnboardingMainPage(
        onFinish: () {
          debugPrint('Onboarding Finished');
        },
      ),
    );
  }
}
