import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/user_profile/application/bloc/user_profile_cubit.dart';
import 'package:orionhealth_health/features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:orionhealth_health/core/di/injection.dart';

class MockUserProfileCubit extends Mock implements UserProfileCubit {}

void main() {
  late MockUserProfileCubit mockCubit;

  setUpAll(() {
    mockCubit = MockUserProfileCubit();
    getIt.registerSingleton<UserProfileCubit>(mockCubit);
  });

  testWidgets('renders error message when state is UserProfileError', (tester) async {
    when(() => mockCubit.state).thenReturn(const UserProfileError('Error msg'));
    when(() => mockCubit.loadUserProfile()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(const UserProfileError('Error msg')));

    await tester.pumpWidget(
      const MaterialApp(
        home: UserProfilePage(),
      ),
    );

    expect(find.textContaining('Error'), findsOneWidget);
    expect(find.text('Error msg'), findsOneWidget);
  });
}
