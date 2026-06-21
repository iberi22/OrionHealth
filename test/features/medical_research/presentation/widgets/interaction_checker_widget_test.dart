import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medical_research/application/medical_research_cubit.dart';
import 'package:orionhealth_health/features/medical_research/presentation/widgets/interaction_checker_widget.dart';

class MockMedicalResearchCubit extends Mock implements MedicalResearchCubit {}

Widget createTestWidget(MedicalResearchCubit cubit) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<MedicalResearchCubit>.value(value: cubit),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: InteractionCheckerWidget(),
      ),
    ),
  );
}

void main() {
  late MockMedicalResearchCubit mockCubit;

  setUp(() {
    mockCubit = MockMedicalResearchCubit();
    when(() => mockCubit.close()).thenAnswer((_) async {});
    when(() => mockCubit.state).thenReturn(const MedicalResearchState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('InteractionCheckerWidget renders VERIFICADOR DE INTERACCIONES title', (tester) async {
    await tester.pumpWidget(createTestWidget(mockCubit));

    expect(find.text('VERIFICADOR DE INTERACCIONES'), findsOneWidget);
  });

  testWidgets('InteractionCheckerWidget shows drug name input field', (tester) async {
    await tester.pumpWidget(createTestWidget(mockCubit));

    expect(find.text('Nombre del medicamento o RxNorm...'), findsOneWidget);
  });

  testWidgets('InteractionCheckerWidget shows add button', (tester) async {
    await tester.pumpWidget(createTestWidget(mockCubit));

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('InteractionCheckerWidget adds a drug and shows chip', (tester) async {
    when(() => mockCubit.checkInteractions(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createTestWidget(mockCubit));

    await tester.enterText(find.byType(TextField), 'Omeprazol');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Omeprazol'), findsOneWidget);
    verify(() => mockCubit.checkInteractions(['Omeprazol'])).called(1);
  });

  testWidgets('InteractionCheckerWidget removes a drug when chip delete is tapped', (tester) async {
    when(() => mockCubit.checkInteractions(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createTestWidget(mockCubit));

    // Add a drug
    await tester.enterText(find.byType(TextField), 'Paracetamol');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Paracetamol'), findsOneWidget);

    // Tap the chip's delete button (Chip renders a delete IconButton internally)
    // Find the Chip widget and tap its onDeleted callback
    final chip = tester.widget<Chip>(find.byType(Chip));
    chip.onDeleted?.call();
    await tester.pump();

    // Drug should be removed
    expect(find.text('Paracetamol'), findsNothing);
  });

  testWidgets('InteractionCheckerWidget shows loading indicator when checking interactions', (tester) async {
    when(() => mockCubit.state).thenReturn(
      const MedicalResearchState(
        status: MedicalResearchStatus.loading,
        loadingMessage: 'Verificando interacciones...',
      ),
    );

    await tester.pumpWidget(createTestWidget(mockCubit));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('InteractionCheckerWidget enters drug via onSubmitted', (tester) async {
    when(() => mockCubit.checkInteractions(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createTestWidget(mockCubit));

    await tester.enterText(find.byType(TextField), 'Ibuprofeno');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('Ibuprofeno'), findsOneWidget);
    verify(() => mockCubit.checkInteractions(['Ibuprofeno'])).called(1);
  });
}
