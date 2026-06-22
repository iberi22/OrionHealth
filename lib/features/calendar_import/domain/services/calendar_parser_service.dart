// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import '../../domain/entities/calendar_event.dart';

abstract class CalendarParserService {
  /// Parses an ICS (iCalendar) string and returns medical events.
  List<CalendarEvent> parseIcs(String icsContent);

  /// Parses a CSV string and returns medical events.
  List<CalendarEvent> parseCsv(String csvContent);
}
