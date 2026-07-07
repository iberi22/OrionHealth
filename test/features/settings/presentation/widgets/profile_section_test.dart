import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/settings/presentation/widgets/profile_section.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';

void main() {
  Widget wrapWithMaterial(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('ProfileSection Widget Tests', () {
    final testProfile = UserProfile(
      name: 'John Doe',
      email: 'john.doe@example.com',
    );

    testWidgets('renders profile data correctly', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        ProfileSection(
          userProfile: testProfile,
          isDarkMode: true,
        ),
      ));

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);
    });

    testWidgets('triggers onEditPressed when edit button is tapped', (WidgetTester tester) async {
      bool editPressed = false;
      await tester.pumpWidget(wrapWithMaterial(
        ProfileSection(
          userProfile: testProfile,
          isDarkMode: true,
          onEditPressed: () => editPressed = true,
        ),
      ));

      await tester.tap(find.byKey(const Key('edit_profile_button')));
      expect(editPressed, isTrue);
    });

    testWidgets('triggers onDarkModeChanged when switch is toggled', (WidgetTester tester) async {
      bool darkModeValue = false;
      await tester.pumpWidget(wrapWithMaterial(
        ProfileSection(
          userProfile: testProfile,
          isDarkMode: false,
          onDarkModeChanged: (value) => darkModeValue = value,
        ),
      ));

      await tester.tap(find.byKey(const Key('dark_mode_switch')));
      await tester.pump();

      expect(darkModeValue, isTrue);
    });

    testWidgets('shows placeholders when userProfile is null', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        const ProfileSection(
          userProfile: null,
          isDarkMode: true,
        ),
      ));

      expect(find.text('Usuario'), findsOneWidget);
      expect(find.text('Sin correo electrónico'), findsOneWidget);
    });

    testWidgets('shows placeholders when profile fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        ProfileSection(
          userProfile: UserProfile(),
          isDarkMode: true,
        ),
      ));

      expect(find.text('Usuario'), findsOneWidget);
      expect(find.text('Sin correo electrónico'), findsOneWidget);
    });

    testWidgets('reflects dark mode state in the switch', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterial(
        ProfileSection(
          userProfile: testProfile,
          isDarkMode: true,
        ),
      ));

      final Switch darkSwitch = tester.widget(find.byKey(const Key('dark_mode_switch')));
      expect(darkSwitch.value, isTrue);

      await tester.pumpWidget(wrapWithMaterial(
        ProfileSection(
          userProfile: testProfile,
          isDarkMode: false,
        ),
      ));

      final Switch lightSwitch = tester.widget(find.byKey(const Key('dark_mode_switch')));
      expect(lightSwitch.value, isFalse);
    });

    group('Image Rendering', () {
      testWidgets('renders NetworkImage when avatarUrl is provided', (tester) async {
        final profileWithAvatar = UserProfile(
          name: 'John Doe',
          email: 'john.doe@example.com',
          avatarUrl: 'https://example.com/avatar.png',
        );

        await tester.pumpWidget(wrapWithMaterial(
          ProfileSection(
            userProfile: profileWithAvatar,
            isDarkMode: true,
          ),
        ));

        final containerFinder = find.byKey(const Key('profile_avatar_container'));
        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration as BoxDecoration;
        final image = decoration.image!.image;

        expect(image, isA<NetworkImage>());
        expect((image as NetworkImage).url, 'https://example.com/avatar.png');

        // Clear exceptions caused by NetworkImage failing to load in tests
        tester.binding.takeException();
      });

      testWidgets('renders AssetImage when avatarUrl is null', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          ProfileSection(
            userProfile: UserProfile(),
            isDarkMode: true,
          ),
        ));

        final containerFinder = find.byKey(const Key('profile_avatar_container'));
        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration as BoxDecoration;
        final image = decoration.image!.image;

        expect(image, isA<AssetImage>());
        expect((image as AssetImage).assetName, 'assets/images/user_placeholder.png');
      });
    });
  });
}
