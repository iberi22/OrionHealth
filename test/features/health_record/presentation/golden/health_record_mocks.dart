import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_record/application/bloc/health_record_cubit.dart';
import 'package:orionhealth_health/features/health_record/domain/repositories/health_record_repository.dart';
import 'package:health_wallet/health_wallet.dart';

class MockHealthRecordRepository extends Mock implements HealthRecordRepository {}
class MockWalletService extends Mock implements WalletService {}
class MockHealthRecordCubit extends Mock implements HealthRecordCubit {}
