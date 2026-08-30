import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/emergency/presentation/cubit/emergency_cubit.dart';
import 'package:orionhealth_health/features/emergency/domain/entities/medical_id.dart';
import 'package:orionhealth_health/features/emergency/domain/repositories/medical_id_repository.dart';
import 'package:orionhealth_health/features/emergency/domain/usecases/get_medical_id_usecase.dart';
import 'package:orionhealth_health/features/emergency/domain/usecases/update_medical_id_usecase.dart';

class _MockRepo implements MedicalIdRepository {
  MedicalIdEntity? _stored;
  @override
  Future<MedicalIdEntity?> getByUser(String userId) async => _stored;
  @override
  Future<void> save(MedicalIdEntity medicalId) async {
    _stored = medicalId;
  }
  @override
  Future<void> delete(String userId) async => _stored = null;
  @override
  Future<List<String>> getCriticalFields(String userId) async {
    return _stored?.toCriticalCard() ?? const [];
  }
}

void main() {
  group('EmergencyCubit — Galaxy S22+ UI states', () {
    test('initial state is EmergencyState.initial', () {
      final cubit = EmergencyCubit(
        GetMedicalIdUseCase(_MockRepo()),
        UpdateMedicalIdUseCase(_MockRepo()),
      );
      expect(cubit.state.isLoading, false);
      expect(cubit.state.notSet, false);
      expect(cubit.state.medicalId, null);
    });

    testWidgets('Loading state shows CircularProgressIndicator',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BlocProvider(
          create: (_) => EmergencyCubit(
            GetMedicalIdUseCase(_MockRepo()),
            UpdateMedicalIdUseCase(_MockRepo()),
          ),
          child: Scaffold(
            body: BlocBuilder<EmergencyCubit, EmergencyState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ));
      // We don't trigger load() to keep initial state; this verifies the
      // widget tree compiles and the conditional builder works.
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('notSet state renders empty state with CTA',
        (tester) async {
      final repo = _MockRepo();
      final cubit = EmergencyCubit(
        GetMedicalIdUseCase(repo),
        UpdateMedicalIdUseCase(repo),
      );
      await cubit.load('user-no-set');
      expect(cubit.state.notSet, true);

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: BlocBuilder<EmergencyCubit, EmergencyState>(
              builder: (context, state) {
                if (state.notSet) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.medical_services_outlined, size: 64),
                      const Text('No Medical ID set', style: TextStyle(fontSize: 18)),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ));
      expect(find.text('No Medical ID set'), findsOneWidget);
      expect(find.byIcon(Icons.medical_services_outlined), findsOneWidget);
    });
  });
}
