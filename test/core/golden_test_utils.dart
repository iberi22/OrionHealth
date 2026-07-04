import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';

Widget wrapWithMaterial(Widget child, {SharingCubit? sharingCubit, AuthCubit? authCubit}) {
  final providers = [
    if (sharingCubit != null)
      BlocProvider<SharingCubit>.value(value: sharingCubit),
    if (authCubit != null)
      BlocProvider<AuthCubit>.value(value: authCubit),
  ];

  Widget result = child;
  if (providers.isNotEmpty) {
    result = MultiBlocProvider(
      providers: providers,
      child: child,
    );
  }

  return MaterialApp(
    theme: AppTheme.darkTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    home: result,
  );
}

void setupGoldenTest(WidgetTester tester, {Size size = const Size(360, 640)}) {
  GoogleFonts.config.allowRuntimeFetching = false;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
}

void resetGoldenTest(WidgetTester tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}
