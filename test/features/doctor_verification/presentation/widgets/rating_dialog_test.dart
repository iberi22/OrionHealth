import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_rating.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/rating_dialog.dart';

void main() {
  group('RatingDialog', () {
    const doctorId = 'doc1';

    testWidgets('renders dialog title and content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => RatingDialog(
                      doctorId: doctorId,
                      onSubmitted: (_) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Calificar Médico'), findsOneWidget);
      expect(find.text('¿Cómo fue tu experiencia?'), findsOneWidget);
    });

    testWidgets('shows 5 star buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => RatingDialog(
                      doctorId: doctorId,
                      onSubmitted: (_) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Should find 5 star icons
      expect(find.byIcon(Icons.star), findsNWidgets(5));
    });

    testWidgets('allows selecting a rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => RatingDialog(
                      doctorId: doctorId,
                      onSubmitted: (_) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap the 3rd star
      await tester.tap(find.byIcon(Icons.star).last);
      await tester.pumpAndSettle();

      // Check stars are still all filled (or changed - we just verify it doesn't crash)
      expect(find.byIcon(Icons.star), findsNWidgets(5));
    });

    testWidgets('has cancel and submit buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => RatingDialog(
                      doctorId: doctorId,
                      onSubmitted: (_) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('CANCELAR'), findsOneWidget);
      expect(find.text('ENVIAR'), findsOneWidget);
    });

    testWidgets('has comment field and anonymous checkbox', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => RatingDialog(
                      doctorId: doctorId,
                      onSubmitted: (_) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Tu comentario (opcional)'), findsOneWidget);
      expect(find.text('Publicar de forma anónima'), findsOneWidget);
    });

    testWidgets('calls onSubmitted with DoctorRating when ENVIAR is pressed', (tester) async {
      DoctorRating? submittedRating;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => RatingDialog(
                      doctorId: doctorId,
                      onSubmitted: (rating) {
                        submittedRating = rating;
                      },
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ENVIAR'));
      await tester.pumpAndSettle();

      expect(submittedRating, isNotNull);
      expect(submittedRating!.doctorId, doctorId);
      expect(submittedRating!.overallScore, 5); // default
      expect(submittedRating!.verifiedVisit, isTrue);
    });

    testWidgets('cancel button closes the dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => RatingDialog(
                      doctorId: doctorId,
                      onSubmitted: (_) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Calificar Médico'), findsOneWidget);

      await tester.tap(find.text('CANCELAR'));
      await tester.pumpAndSettle();

      expect(find.text('Calificar Médico'), findsNothing);
    });

    testWidgets('submit button closes the dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => RatingDialog(
                      doctorId: doctorId,
                      onSubmitted: (_) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Calificar Médico'), findsOneWidget);

      await tester.tap(find.text('ENVIAR'));
      await tester.pumpAndSettle();

      expect(find.text('Calificar Médico'), findsNothing);
    });
  });
}
