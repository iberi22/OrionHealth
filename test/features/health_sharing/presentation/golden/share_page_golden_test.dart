import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/share_page.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart' as auth_state;
import 'package:orionhealth_health/core/di/injection.dart';
import '../../../../core/golden_test_utils.dart';

class MockSharingCubit extends Mock implements SharingCubit {}
class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockSharingCubit mockSharingCubit;
  late MockAuthCubit mockAuthCubit;

  setUpAll(() {
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockSharingCubit = MockSharingCubit();
    mockAuthCubit = MockAuthCubit();

    getIt.registerSingleton<SharingCubit>(mockSharingCubit);
    getIt.registerSingleton<AuthCubit>(mockAuthCubit);

    when(() => mockSharingCubit.initialize()).thenAnswer((_) async => {});
    when(() => mockSharingCubit.close()).thenAnswer((_) async => {});
    when(() => mockSharingCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSharingCubit.state).thenReturn(SharingReady());

    when(() => mockAuthCubit.close()).thenAnswer((_) async => {});
    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthCubit.state).thenReturn(const auth_state.AuthInitial());
    when(() => mockAuthCubit.checkStatus()).thenAnswer((_) async {});
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets('SharePage golden test', (tester) async {
    setupGoldenTest(tester);
    await tester.pumpWidget(
      wrapWithMaterial(
        const SharePage(),
        sharingCubit: mockSharingCubit,
        authCubit: mockAuthCubit,
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(SharePage),
      matchesGoldenFile('goldens/share_page.png'),
    );
    resetGoldenTest(tester);
  });
}
