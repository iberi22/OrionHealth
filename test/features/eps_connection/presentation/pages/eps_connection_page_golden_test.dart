import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/presentation/eps_connect_button.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_cubit.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_state.dart' as state_lib;
import '../../../../core/golden_test_utils.dart';

class MockEpsConnectionCubit extends Mock implements EpsConnectionCubit {}

void main() {
  late MockEpsConnectionCubit mockCubit;

  setUp(() {
    mockCubit = MockEpsConnectionCubit();
  });

  Future<void> buildWidget(WidgetTester tester, EpsConnectionCubit cubit) async {
    await tester.pumpWidget(
      wrapWithMaterial(
        BlocProvider<EpsConnectionCubit>.value(
          value: cubit,
          child: const Scaffold(body: Center(child: Padding(padding: EdgeInsets.all(16), child: EpsConnectButton()))),
        ),
      ),
    );
    await tester.pump();
  }

  group('EPS Connection Golden Tests', () {
    testWidgets('EPS Connect Button - Disconnected', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const state_lib.EpsConnectionDisconnected());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      await buildWidget(tester, mockCubit);

      await expectLater(
        find.byType(EpsConnectButton),
        matchesGoldenFile("../../../../../golden/reference/eps_connect_button_disconnected.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('EPS Connect Button - Connected', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const state_lib.EpsConnectionConnected('PAT-12345'));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      await buildWidget(tester, mockCubit);

      await expectLater(
        find.byType(EpsConnectButton),
        matchesGoldenFile("../../../../../golden/reference/eps_connect_button_connected.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('EPS Connect Button - Loading', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const state_lib.EpsConnectionLoading());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      await buildWidget(tester, mockCubit);

      await expectLater(
        find.byType(EpsConnectButton),
        matchesGoldenFile("../../../../../golden/reference/eps_connect_button_loading.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
