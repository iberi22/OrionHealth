// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/services/calendar_parser_service.dart';
import '../utils/calendar_parser.dart';

@LazySingleton(as: CalendarParserService)
class CalendarParserServiceImpl implements CalendarParserService {
  final CalendarParser _parser;

  CalendarParserServiceImpl() : _parser = CalendarParser();

  @override
  List<CalendarEvent> parseIcs(String icsContent) {
    return _parser.parseIcs(icsContent);
  }

  @override
  List<CalendarEvent> parseCsv(String csvContent) {
    return _parser.parseCsv(csvContent);
  }
}
