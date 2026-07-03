import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/network_health/domain/repositories/network_repository.dart';
import 'package:orionhealth_health/features/network/network_health/domain/usecases/connect_node.dart';

class MockNetworkRepository extends Mock implements NetworkRepository {}

void main() {
  late ConnectNode usecase;
  late MockNetworkRepository mockRepository;

  setUp(() {
    mockRepository = MockNetworkRepository();
    usecase = ConnectNode(mockRepository);
  });

  const tNodeId = 'node-123';

  test('should connect node via repository', () async {
    // arrange
    when(() => mockRepository.connectNode(any()))
        .thenAnswer((_) async => {});

    // act
    await usecase(tNodeId);

    // assert
    verify(() => mockRepository.connectNode(tNodeId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should propagate error when repository fails', () async {
    // arrange
    when(() => mockRepository.connectNode(any()))
        .thenThrow(Exception('Failed to connect'));

    // act & assert
    expect(() => usecase(tNodeId), throwsException);
    verify(() => mockRepository.connectNode(tNodeId));
  });
}
