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

  testWidgets('renders loading indicator when state is UserProfileLoading', (tester) async {
    when(() => mockCubit.state).thenReturn(const UserProfileLoading());
    when(() => mockCubit.loadUserProfile()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(const UserProfileLoading()));

    await tester.pumpWidget(
      const MaterialApp(
        home: UserProfilePage(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
