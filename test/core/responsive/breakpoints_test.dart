import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/responsive/breakpoints.dart';

void main() {
  group('Breakpoints', () {
    test('isMobile returns true for width < 600', () {
      expect(Breakpoints.isMobile(375), isTrue);
      expect(Breakpoints.isMobile(599), isTrue);
      expect(Breakpoints.isMobile(600), isFalse);
    });

    test('isTablet returns true for width >= 600 and width < 1024', () {
      expect(Breakpoints.isTablet(600), isTrue);

      expect(Breakpoints.isTablet(1023), isTrue);
      expect(Breakpoints.isTablet(599), isFalse);
      expect(Breakpoints.isTablet(1024), isFalse);
    });

    test('isDesktop returns true for width >= 1024', () {
      expect(Breakpoints.isDesktop(1024), isTrue);
      expect(Breakpoints.isDesktop(1920), isTrue);
      expect(Breakpoints.isDesktop(1023), isFalse);
    });
  });
}
