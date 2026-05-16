import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_sharing/application/health_sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/nfc_sharing_service.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/wifi_direct_service.dart';

class MockBleSharingService extends Mock implements BleSharingService {}
class MockNfcSharingService extends Mock implements NfcSharingService {}
class MockWifiDirectService extends Mock implements WifiDirectService {}

void main() {
  late HealthSharingCubit cubit;
  late MockBleSharingService mockBle;
  late MockNfcSharingService mockNfc;
  late MockWifiDirectService mockWifi;

  setUp(() {
    mockBle = MockBleSharingService();
    mockNfc = MockNfcSharingService();
    mockWifi = MockWifiDirectService();

    when(() => mockBle.initialize()).thenAnswer((_) async {});
    when(() => mockNfc.initialize()).thenAnswer((_) async {});
    when(() => mockWifi.initialize()).thenAnswer((_) async {});
    when(() => mockBle.stateStream).thenAnswer((_) => const Stream.empty());
    when(() => mockNfc.stateStream).thenAnswer((_) => const Stream.empty());
    when(() => mockWifi.stateStream).thenAnswer((_) => const Stream.empty());
    when(() => mockBle.dispose()).thenReturn(null);
    when(() => mockNfc.dispose()).thenReturn(null);
    when(() => mockWifi.dispose()).thenReturn(null);

    cubit = HealthSharingCubit(
      bleService: mockBle,
      nfcService: mockNfc,
      wifiService: mockWifi,
    );
  });

  test('initial state is HealthSharingInitial', () {
    expect(cubit.state, isA<HealthSharingInitial>());
  });

  test('initialize calls initialize on all services', () async {
    await cubit.initialize();
    verify(() => mockBle.initialize()).called(1);
    verify(() => mockNfc.initialize()).called(1);
    verify(() => mockWifi.initialize()).called(1);
    expect(cubit.state, isA<HealthSharingReady>());
  });
}
