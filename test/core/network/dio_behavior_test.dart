// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Does validateCertificate get called for valid certificates?', () async {
    final dio = Dio();
    bool called = false;
    final adapter = IOHttpClientAdapter();
    adapter.validateCertificate = (cert, host, port) {
      called = true;
      return true;
    };
    dio.httpClientAdapter = adapter;

    try {
      await dio.get('https://www.google.com');
    } catch (e) {
      // Ignore errors, we just want to see if the callback was hit
    }

    print('validateCertificate called: $called');
  });
}
