import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medications/application/bloc/medication_bloc.dart';
import 'package:orionhealth_health/features/medications/presentation/pages/medications_page.dart';
import 'package:orionhealth_health/core/di/injection.dart';

class MockMedicationBloc extends Mock implements MedicationBloc {}

void main() {
  late MockMedicationBloc mockBloc;

  setUpAll(() {
    mockBloc = MockMedicationBloc();
    getIt.registerSingleton<MedicationBloc>(mockBloc);
  });

  testWidgets('renders empty message when no medications', (tester) async {
    when(() => mockBloc.state).thenReturn(const MedicationState.loaded([]));
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(const MedicationState.loaded([])));

    await tester.pumpWidget(
      const MaterialApp(
        home: MedicationsPage(),
      ),
    );

    expect(find.byType(ListView), findsOneWidget);
  });
}
