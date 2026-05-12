import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/infrastructure/persistence/isar_user_profile.dart';
import 'package:orionhealth_health/features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart';

class MockIsar extends Mock implements Isar {}
class MockIsarCollection extends Mock implements IsarCollection<IsarUserProfile> {}
class MockEncryptionService extends Mock implements EncryptionService {}
class FakeIsarUserProfile extends Fake implements IsarUserProfile {}
class MockQueryBuilder extends Mock implements QueryBuilder<IsarUserProfile, IsarUserProfile, QAfterFilterCondition> {}

void main() {
  late UserProfileRepositoryImpl repository;
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late MockEncryptionService mockEncryptionService;

  setUpAll(() {
    registerFallbackValue(FakeIsarUserProfile());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    mockEncryptionService = MockEncryptionService();

    // For extension methods, we need to mock the underlying isar.collection()
    when(() => mockIsar.collection<IsarUserProfile>()).thenReturn(mockCollection);

    repository = UserProfileRepositoryImpl(mockIsar, mockEncryptionService);
  });

  test('saveUserProfile encrypts data before storing', () async {
    final profile = UserProfile(name: 'John Doe', age: 30);
    final encryptedData = Uint8List.fromList([1, 2, 3, 4]);

    when(() => mockEncryptionService.encrypt(any())).thenAnswer((_) async => encryptedData);
    when(() => mockIsar.writeTxn<void>(any())).thenAnswer((invocation) async {
      final callback = invocation.positionalArguments[0] as Future<void> Function();
      await callback();
    });
    when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

    await repository.saveUserProfile(profile);

    verify(() => mockEncryptionService.encrypt(any(that: contains('"name":"John Doe"')))).called(1);
    verify(() => mockCollection.put(any(that: isA<IsarUserProfile>().having((p) => p.encryptedBlob, 'encryptedBlob', encryptedData.toList())))).called(1);
  });

  test('getUserProfile decrypts data after loading', () async {
    final encryptedData = [1, 2, 3, 4];
    final isarProfile = IsarUserProfile()..encryptedBlob = encryptedData;
    final profileMap = {'name': 'John Doe', 'age': 30};

    final mockQueryBuilder = MockQueryBuilder();

    when(() => mockCollection.where()).thenReturn(mockQueryBuilder as dynamic);
    when(() => (mockQueryBuilder as dynamic).findFirst()).thenAnswer((_) async => isarProfile);
    when(() => mockEncryptionService.decrypt(any())).thenAnswer((_) async => jsonEncode(profileMap));

    final result = await repository.getUserProfile();

    expect(result?.name, 'John Doe');
    expect(result?.age, 30);
    verify(() => mockEncryptionService.decrypt(any(that: equals(Uint8List.fromList(encryptedData))))).called(1);
  });
}
