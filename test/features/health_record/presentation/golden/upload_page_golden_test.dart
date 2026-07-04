import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_record/application/bloc/health_record_cubit.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/upload_page.dart';
import '../../../../core/golden_test_utils.dart';
import 'health_record_mocks.dart';

void main() {
  late MockHealthRecordCubit mockCubit;

  setUp(() {
    mockCubit = MockHealthRecordCubit();
  });

  Widget wrapWithCubit(Widget child) {
    return wrapWithMaterial(
      BlocProvider<HealthRecordCubit>.value(
        value: mockCubit,
        child: child,
      ),
    );
  }

  testWidgets('UploadPage source selection state golden test', (tester) async {
    setupGoldenTest(tester);

    when(() => mockCubit.state).thenReturn(const HealthRecordInitial());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});

    await tester.pumpWidget(wrapWithCubit(const UploadPage()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(UploadPage),
      matchesGoldenFile('goldens/upload_page_sources.png'),
    );
  });

  testWidgets('UploadPage loading state golden test', (tester) async {
    setupGoldenTest(tester);

    when(() => mockCubit.state).thenReturn(const HealthRecordLoading());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});

    await tester.pumpWidget(wrapWithCubit(const UploadPage()));
    // Don't use pumpAndSettle because CircularProgressIndicator animates infinitely
    await tester.pump(const Duration(milliseconds: 100));

    await expectLater(
      find.byType(UploadPage),
      matchesGoldenFile('goldens/upload_page_loading.png'),
    );
  });

  testWidgets('UploadPage details step state golden test', (tester) async {
    setupGoldenTest(tester);

    when(() => mockCubit.state).thenReturn(const HealthRecordFilePicked(
      filePath: '/path/to/my_scan.jpg',
      extractedText: 'DR. SMITH CLINIC\nPatient: John Doe\nDiagnosis: Hypertension',
    ));
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});

    await tester.pumpWidget(wrapWithCubit(const UploadPage()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(UploadPage),
      matchesGoldenFile('goldens/upload_page_details.png'),
    );
  });
}
