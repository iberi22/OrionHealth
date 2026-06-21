import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart';
import 'package:orionhealth_health/features/auth/presentation/setup_pin_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthCubit mockCubit;

  setUp(() {
    mockCubit = MockAuthCubit();
    when(() => mockCubit.state).thenReturn(AuthNotSetup());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: mockCubit),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SetupPinPage(),
      ),
    );
  }

  group('SetupPinPage', () {
    testWidgets('renders PIN and confirm fields', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Nuevo PIN'), findsOneWidget);
      expect(find.text('Confirmar PIN'), findsOneWidget);
      expect(find.text('Guardar PIN'), findsOneWidget);
    });

    testWidgets('shows error when PIN too short', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.widgetWithText(TextField, 'Nuevo PIN'), '123');
      await tester.tap(find.text('Guardar PIN'));
      await tester.pump();

      expect(find.text('El PIN debe tener al menos 4 dígitos'), findsOneWidget);
    });

    testWidgets('shows error when PINs do not match', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.widgetWithText(TextField, 'Nuevo PIN'), '1234');
      await tester.enterText(find.widgetWithText(TextField, 'Confirmar PIN'), '1235');
      await tester.tap(find.text('Guardar PIN'));
      await tester.pump();

      expect(find.text('Los PINs no coinciden'), findsOneWidget);
    });

    testWidgets('calls setupPin when valid PIN entered', (tester) async {
      when(() => mockCubit.setupPin(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.widgetWithText(TextField, 'Nuevo PIN'), '1234');
      await tester.enterText(find.widgetWithText(TextField, 'Confirmar PIN'), '1234');
      await tester.tap(find.text('Guardar PIN'));
      await tester.pump();

      verify(() => mockCubit.setupPin('1234')).called(1);
    });
  });
}
