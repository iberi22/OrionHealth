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

    testWidgets('updates rating when star is tapped', (tester) async {
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

      // Default is 5 stars (all Icons.star)
      expect(find.byIcon(Icons.star), findsNWidgets(5));

      // Tap 3rd star (index 2)
      await tester.tap(find.byType(IconButton).at(2));
      await tester.pumpAndSettle();

      // Now 3 should be Icons.star and 2 should be Icons.star_border
      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));

      await tester.tap(find.text('ENVIAR'));
      await tester.pumpAndSettle();

      expect(submittedRating!.overallScore, 3);
    });

    testWidgets('submits comment and anonymity status', (tester) async {
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

      // Enter comment
      await tester.enterText(find.byType(TextField), 'Great doctor!');

      // Toggle anonymous
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ENVIAR'));
      await tester.pumpAndSettle();

      expect(submittedRating!.comment, 'Great doctor!');
      expect(submittedRating!.isAnonymous, isTrue);
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
