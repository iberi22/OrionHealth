import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Reports Flow - E2E Tests', () {
    testWidgets('E2E: Generate and View Report', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: _MockReportsPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'reports', '01_list');

      // Generate
      await tester.tap(find.text('Generar Reporte Mensual'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'reports', '02_generating');

      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Reporte Noviembre 2023'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'reports', '03_generated');

      // View
      await tester.tap(find.text('Reporte Noviembre 2023'));
      await tester.pumpAndSettle();
      expect(find.text('Detalle de Reporte'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'reports', '04_view_detail');
    });
  });
}

class _MockReportsPage extends StatefulWidget {
  const _MockReportsPage({super.key});
  @override
  State<_MockReportsPage> createState() => _MockReportsPageState();
}

class _MockReportsPageState extends State<_MockReportsPage> {
  List<String> reports = ['Reporte Octubre 2023'];
  bool _isLoading = false;
  bool _isDetail = false;

  @override
  Widget build(BuildContext context) {
    if (_isDetail) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Reporte'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _isDetail = false))),
        body: const Center(child: Text('Gráficos de salud y métricas')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes de Salud')),
      body: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, i) => ListTile(title: Text(reports[i]), onTap: () => setState(() => _isDetail = true)),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
          ? const LinearProgressIndicator()
          : ElevatedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    setState(() {
                      reports.insert(0, 'Reporte Noviembre 2023');
                      _isLoading = false;
                    });
                  }
                });
              },
              child: const Text('Generar Reporte Mensual'),
            ),
      ),
    );
  }
}
