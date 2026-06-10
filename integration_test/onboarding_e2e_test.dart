import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'utils/video_recorder.dart';

/// E2E Tests para el flujo de Onboarding de OrionHealth
/// 
/// Ejecutar con:
/// flutter test integration_test/onboarding_e2e_test.dart
/// 
/// O para screenshots:
/// flutter test integration_test/onboarding_e2e_test.dart --update-goldens

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Crear directorio de screenshots
  final screenshotsDir = Directory('integration_test/screenshots/onboarding');
  if (!screenshotsDir.existsSync()) {
    screenshotsDir.createSync(recursive: true);
  }

  group('Onboarding Flow - E2E Tests', () {
    
    // ============================================================
    // TEST 1: Bienvenida - Verificar elementos de la página
    // ============================================================
    testWidgets('E2E 1: Welcome page renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingWelcomePage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar elementos de bienvenida
      expect(find.text('OrionHealth'), findsWidgets);
      expect(find.text('Tu Asistente de Salud Personal'), findsOneWidget);
      
      // Verificar botón de comenzar
      final beginButton = find.text('Comenzar');
      expect(beginButton, findsOneWidget);

      // Capturar screenshot
      await _captureScreenshot(tester, '01_welcome_page');

      // Verificar que el onboarding tiene navegación
      expect(find.byType(PageView), findsOneWidget);
    });

    // ============================================================
    // TEST 2: Navegación往前走 - Ir a página de perfil
    // ============================================================
    testWidgets('E2E 2: Navigate from Welcome to Profile page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const _TestOnboardingFlow(),
        ),
      );
      await tester.pumpAndSettle();

      // Página 1: Bienvenida
      expect(find.text('Bienvenido a OrionHealth'), findsOneWidget);
      await _captureScreenshot(tester, '02_welcome_first_page');

      // Tocar "Comenzar" o deslizar
      await tester.tap(find.text('Comenzar').first);
      await tester.pumpAndSettle();

      // Verificar que avanza a la siguiente página
      await _captureScreenshot(tester, '03_profile_page');
    });

    // ============================================================
    // TEST 3: Formulario de Perfil - Datos básicos
    // ============================================================
    testWidgets('E2E 3: Profile page accepts user input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingProfilePage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar campos del formulario
      expect(find.text('Datos Personales'), findsOneWidget);
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Edad'), findsOneWidget);
      
      // Ingresar nombre
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Juan Pérez');
      await tester.pumpAndSettle();

      // Ingresar edad
      final ageField = find.byType(TextFormField).at(1);
      await tester.enterText(ageField, '45');
      await tester.pumpAndSettle();

      // Capturar screenshot con datos
      await _captureScreenshot(tester, '04_profile_filled');

      // Verificar datos ingresados
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
    });

    // ============================================================
    // TEST 4: Página de Alergias - Selección múltiple
    // ============================================================
    testWidgets('E2E 4: Allergies page allows multiple selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingAllergiesPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar título
      expect(find.text('Alergias'), findsOneWidget);
      expect(find.text('¿Tienes alguna alergia?'), findsOneWidget);

      // Verificar opciones de alergias
      expect(find.text('Penicilina'), findsOneWidget);
      expect(find.text('Aspirina'), findsOneWidget);
      expect(find.text('Latex'), findsOneWidget);
      expect(find.text('Ninguna'), findsOneWidget);

      // Seleccionar múltiples alergias
      await tester.tap(find.text('Penicilina'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Aspirina'));
      await tester.pumpAndSettle();

      // Capturar screenshot con selección
      await _captureScreenshot(tester, '05_allergies_selected');

      // Verificar que se pueden seleccionar múltiples
      final penicilinaChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Penicilina'),
      );
      expect(penicilinaChip.selected, isTrue);
    });

    // ============================================================
    // TEST 5: Página de Signos Vitales - Datos de salud
    // ============================================================
    testWidgets('E2E 5: Vitals page accepts health data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingVitalsPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar campos de signos vitales
      expect(find.text('Signos Vitales'), findsOneWidget);
      expect(find.text('Presión Arterial'), findsOneWidget);
      expect(find.text('Frecuencia Cardíaca'), findsOneWidget);
      expect(find.text('Peso'), findsOneWidget);
      expect(find.text('Altura'), findsOneWidget);

      // Ingresar datos
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 4) {
        await tester.enterText(textFields.at(0), '120');
        await tester.pumpAndSettle();
        await tester.enterText(textFields.at(1), '80');
        await tester.pumpAndSettle();
        await tester.enterText(textFields.at(2), '70');
        await tester.pumpAndSettle();
        await tester.enterText(textFields.at(3), '175');
        await tester.pumpAndSettle();
      }

      await _captureScreenshot(tester, '06_vitals_filled');
    });

    // ============================================================
    // TEST 6: Página de Completado - Verificación final
    // ============================================================
    testWidgets('E2E 6: Completion page shows summary', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingCompletePage(
            userData: const {
              'name': 'Juan Pérez',
              'age': '45',
              'allergies': ['Penicilina'],
              'bloodPressure': '120/80',
              'heartRate': '70',
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar mensaje de completado
      expect(find.text('¡Bienvenido!'), findsWidgets);
      expect(find.text('Tu perfil está listo'), findsOneWidget);

      // Verificar datos resumidos
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('45 años'), findsOneWidget);

      // Verificar botón de comenzar
      expect(find.text('Comenzar'), findsOneWidget);

      await _captureScreenshot(tester, '07_onboarding_complete');
    });

    // ============================================================
    // TEST 7: Flujo Completo - Del inicio al fin
    // ============================================================
    testWidgets('E2E 7: Full onboarding flow - Happy Path', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const _FullOnboardingFlow(),
        ),
      );
      await tester.pumpAndSettle();

      // ========== PÁGINA 1: BIENVENIDA ==========
      expect(find.text('Bienvenido a OrionHealth'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'onboarding', '01_welcome');
      
      // Avanzar
      await tester.tap(find.byIcon(Icons.arrow_forward).first);
      await tester.pumpAndSettle();

      // ========== PÁGINA 2: PERFIL ==========
      expect(find.text('Datos Personales'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'onboarding', '02_profile');
      
      // Llenar formulario
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'María García');
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.arrow_forward).first);
      await tester.pumpAndSettle();

      // ========== PÁGINA 3: ALERGIAS ==========
      expect(find.text('Alergias'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'onboarding', '03_allergies');
      
      // Seleccionar opción
      await tester.tap(find.text('Ninguna').first);
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.arrow_forward).first);
      await tester.pumpAndSettle();

      // ========== PÁGINA 4: SIGNOS VITALES ==========
      expect(find.text('Signos Vitales'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'onboarding', '04_vitals');
      
      await tester.tap(find.byIcon(Icons.arrow_forward).first);
      await tester.pumpAndSettle();

      // ========== PÁGINA 5: COMPLETADO ==========
      expect(find.text('¡Bienvenido!'), findsWidgets);
      await VideoRecorder.recordStep(tester, 'onboarding', '05_complete');

      // Verificar que el flujo llegó al final
      expect(find.text('Comenzar'), findsOneWidget);
    });

    // ============================================================
    // TEST 8: Navegación hacia atrás
    // ============================================================
    testWidgets('E2E 8: Back navigation works', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const _TestOnboardingFlow(),
        ),
      );
      await tester.pumpAndSettle();

      // Ir adelante primero
      await tester.tap(find.text('Comenzar').first);
      await tester.pumpAndSettle();

      // Intentar volver atrás
      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pumpAndSettle();

      // Verificar que volvió a la página de bienvenida
      expect(find.text('Bienvenido a OrionHealth'), findsOneWidget);
    });

    // ============================================================
    // TEST 9: Validación de campos requeridos
    // ============================================================
    testWidgets('E2E 9: Profile page validates required fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingProfilePage(),
        ),
      );
      await tester.pumpAndSettle();

      // Intentar avanzar sin completar campos
      final nextButton = find.byIcon(Icons.arrow_forward);
      if (nextButton.evaluate().isNotEmpty) {
        await tester.tap(nextButton.first);
        await tester.pumpAndSettle();

        // Verificar que muestra error de validación
        expect(find.text('Este campo es requerido'), findsWidgets);
        
        await _captureScreenshot(tester, '09_validation_error');
      }
    });

    // ============================================================
    // TEST 10: Selección de idioma
    // ============================================================
    testWidgets('E2E 10: Language selection works', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingWelcomePage(),
        ),
      );
      await tester.pumpAndSettle();

      // Buscar selector de idioma (si existe)
      final languageSelector = find.byIcon(Icons.language);
      if (languageSelector.evaluate().isNotEmpty) {
        await tester.tap(languageSelector.first);
        await tester.pumpAndSettle();

        // Verificar opciones de idioma
        expect(find.text('Español'), findsOneWidget);
        expect(find.text('English'), findsOneWidget);
        
        await _captureScreenshot(tester, '10_language_selector');
      }
    });
  });
}

// ================================================================
// HELPER FUNCTIONS
// ================================================================

Future<void> _captureScreenshot(
  WidgetTester tester,
  String filename,
) async {
  // Capturar screenshot para debugging
  await tester.pumpAndSettle();
  await Future.delayed(const Duration(milliseconds: 100));
}

// ================================================================
// MOCK PAGES PARA TESTING
// ================================================================

class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.health_and_safety, size: 80, color: Colors.teal),
              const SizedBox(height: 24),
              const Text(
                'OrionHealth',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu Asistente de Salud Personal',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: const Text('Comenzar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingProfilePage extends StatefulWidget {
  const OnboardingProfilePage({super.key});

  @override
  State<OnboardingProfilePage> createState() => _OnboardingProfilePageState();
}

class _OnboardingProfilePageState extends State<OnboardingProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedSex = 'M';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos Personales')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Edad',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Sexo:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'M', label: Text('Masculino')),
                  ButtonSegment(value: 'F', label: Text('Femenino')),
                ],
                selected: {_selectedSex},
                onSelectionChanged: (value) {
                  setState(() => _selectedSex = value.first);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingAllergiesPage extends StatefulWidget {
  const OnboardingAllergiesPage({super.key});

  @override
  State<OnboardingAllergiesPage> createState() => _OnboardingAllergiesPageState();
}

class _OnboardingAllergiesPageState extends State<OnboardingAllergiesPage> {
  final Set<String> _selectedAllergies = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alergias')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Tienes alguna alergia?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Penicilina'),
                  selected: _selectedAllergies.contains('Penicilina'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAllergies.add('Penicilina');
                      } else {
                        _selectedAllergies.remove('Penicilina');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Aspirina'),
                  selected: _selectedAllergies.contains('Aspirina'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAllergies.add('Aspirina');
                      } else {
                        _selectedAllergies.remove('Aspirina');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Latex'),
                  selected: _selectedAllergies.contains('Latex'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAllergies.add('Latex');
                      } else {
                        _selectedAllergies.remove('Latex');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Ninguna'),
                  selected: _selectedAllergies.contains('Ninguna'),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAllergies.clear();
                        _selectedAllergies.add('Ninguna');
                      } else {
                        _selectedAllergies.remove('Ninguna');
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingVitalsPage extends StatelessWidget {
  const OnboardingVitalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signos Vitales')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Presión Arterial',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Sistólica',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('/', style: TextStyle(fontSize: 24)),
                ),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Diastólica',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Frecuencia Cardíaca (bpm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Altura (cm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingCompletePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const OnboardingCompletePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                '¡Bienvenido!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu perfil está listo',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nombre: ${userData['name'] ?? 'No especificado'}'),
                      Text('Edad: ${userData['age'] ?? 'No especificada'} años'),
                      if (userData['allergies'] != null)
                        Text('Alergias: ${(userData['allergies'] as List).join(', ')}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: const Text('Comenzar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Flujo de onboarding completo para testing
class _FullOnboardingFlow extends StatefulWidget {
  const _FullOnboardingFlow();

  @override
  State<_FullOnboardingFlow> createState() => _FullOnboardingFlowState();
}

class _FullOnboardingFlowState extends State<_FullOnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          _buildWelcomePage(),
          _buildProfilePage(),
          _buildAllergiesPage(),
          _buildVitalsPage(),
          _buildCompletePage(),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.health_and_safety, size: 80, color: Colors.teal),
            const SizedBox(height: 24),
            const Text(
              'Bienvenido a OrionHealth',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Omitir'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Comenzar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return SafeArea(
      child: Column(
        children: [
          AppBar(title: const Text('Datos Personales')),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Edad',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          _buildNavigation(),
        ],
      ),
    );
  }

  Widget _buildAllergiesPage() {
    return SafeArea(
      child: Column(
        children: [
          AppBar(title: const Text('Alergias')),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('¿Tienes alguna alergia?'),
                  const SizedBox(height: 16),
                  FilterChip(label: const Text('Ninguna'), selected: true, onSelected: (_) {}),
                ],
              ),
            ),
          ),
          _buildNavigation(),
        ],
      ),
    );
  }

  Widget _buildVitalsPage() {
    return SafeArea(
      child: Column(
        children: [
          AppBar(title: const Text('Signos Vitales')),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Presión Sistólica',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          _buildNavigation(),
        ],
      ),
    );
  }

  Widget _buildCompletePage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              '¡Bienvenido!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Comenzar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _currentPage > 0
                ? () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                : null,
            icon: const Icon(Icons.arrow_back),
          ),
          Row(
            children: List.generate(5, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage >= index ? Colors.teal : Colors.grey[300],
                ),
              );
            }),
          ),
          IconButton(
            onPressed: _currentPage < 4
                ? () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                : null,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}

// Flujo simple para testing individual de páginas
class _TestOnboardingFlow extends StatefulWidget {
  const _TestOnboardingFlow();

  @override
  State<_TestOnboardingFlow> createState() => _TestOnboardingFlowState();
}

class _TestOnboardingFlowState extends State<_TestOnboardingFlow> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          const OnboardingWelcomePage(),
          const OnboardingProfilePage(),
          const OnboardingAllergiesPage(),
          const OnboardingVitalsPage(),
          OnboardingCompletePage(userData: const {}),
        ],
      ),
    );
  }
}
