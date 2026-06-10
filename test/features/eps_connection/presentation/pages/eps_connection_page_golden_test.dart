import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/eps_connection/presentation/eps_connect_button.dart';
import 'package:orionhealth_health/features/eps_connection/domain/eps_connection_cubit.dart' as cubit_lib;
import '../../../../core/golden_test_utils.dart';

class MockEpsConnectionCubit extends Mock implements cubit_lib.EpsConnectionCubit {}

void main() {
  late MockEpsConnectionCubit mockCubit;

  setUpAll(() {
    mockCubit = MockEpsConnectionCubit();
    GetIt.I.registerSingleton<cubit_lib.EpsConnectionCubit>(mockCubit);
  });

  tearDownAll(() {
    GetIt.I.reset();
  });

  group('EPS Connection Golden Tests', () {
    testWidgets('EPS Connect Button - Disconnected', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const cubit_lib.EpsConnectionDisconnected());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(wrapWithMaterial(const Scaffold(body: Center(child: Padding(padding: EdgeInsets.all(16), child: EpsConnectButton())))));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(EpsConnectButton),
        matchesGoldenFile('goldens/eps_connect_button_disconnected.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('EPS Connect Button - Connected', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const cubit_lib.EpsConnectionConnected('PAT-12345'));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(wrapWithMaterial(const Scaffold(body: Center(child: Padding(padding: EdgeInsets.all(16), child: EpsConnectButton())))));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(EpsConnectButton),
        matchesGoldenFile('goldens/eps_connect_button_connected.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('EPS Connect Button - Loading', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const cubit_lib.EpsConnectionLoading());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(wrapWithMaterial(const Scaffold(body: Center(child: Padding(padding: EdgeInsets.all(16), child: EpsConnectButton())))));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(EpsConnectButton),
        matchesGoldenFile('goldens/eps_connect_button_loading.png'),
      );
      resetGoldenTest(tester);
    });
  });
}
