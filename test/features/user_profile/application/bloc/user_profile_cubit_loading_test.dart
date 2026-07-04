import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/user_profile/application/bloc/user_profile_cubit.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  late UserProfileCubit cubit;
  late MockUserProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockUserProfileRepository();
    cubit = UserProfileCubit(mockRepository);
  });

  test('initial state is UserProfileInitial', () {
    expect(cubit.state, isA<UserProfileInitial>());
  });
}
