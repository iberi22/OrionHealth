import 'dart:convert';
import 'package:archive/archive.dart';
import 'models.dart';
import 'validation.dart';

const deepLinkLimitBytes = 8192;
const decodedPayloadLimitBytes = 1024 * 1024;

class DeepLinkSizeError implements Exception {
  const DeepLinkSizeError(this.payloadBytes);
  final int payloadBytes;
  int get limitBytes => deepLinkLimitBytes;
  @override
  String toString() =>
      'Deep link payload is $payloadBytes bytes (maximum $deepLinkLimitBytes); use .swalhealth.json file export.';
}

List<Envelope> _records(dynamic input) {
  if (input is! List)
    throw ContractValidationError(['/: expected array of records']);
  final errors = <String>[];
  for (var i = 0; i < input.length; i++) {
    errors.addAll(validateRecord(input[i]).errors.map((e) => '[$i]$e'));
  }
  if (errors.isNotEmpty) throw ContractValidationError(errors);
  return List.unmodifiable(
    input.map((e) => Envelope.fromJson(Map<String, dynamic>.from(e as Map))),
  );
}

/// Wire format is an array of complete records with no wrapper.
String toFile(List<Envelope> records) {
  final checked = _records(records.map((e) => e.toJson()).toList());
  return '${const JsonEncoder.withIndent('  ').convert(checked.map((e) => e.toJson()).toList())}\n';
}

List<Envelope> fromFile(String text) {
  dynamic parsed;
  try {
    parsed = jsonDecode(text);
  } on FormatException {
    throw ContractValidationError(['/: malformed JSON']);
  }
  return _records(parsed);
}

void _sizeGuard(String payload) {
  final size = utf8.encode(payload).length;
  if (size > deepLinkLimitBytes) throw DeepLinkSizeError(size);
}

void _protocol(Uri uri) {
  if (uri.scheme != 'https' && uri.scheme != 'orionhealth') {
    throw ContractValidationError(['/url: expected https: or orionhealth:']);
  }
}

String _base64url(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');
List<int> _unbase64url(String value) {
  if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(value) || value.length % 4 == 1) {
    throw ContractValidationError(['/p: invalid base64url']);
  }
  List<int> bytes;
  try {
    bytes = base64Url.decode(base64Url.normalize(value));
  } on FormatException {
    throw ContractValidationError(['/p: invalid base64url']);
  }
  if (_base64url(bytes) != value)
    throw ContractValidationError(['/p: noncanonical base64url']);
  return bytes;
}

/// Emits gzip on native and web. HTTPS uses the fragment for privacy.
Uri encodeDeepLink(List<Envelope> records, Object base) {
  final checked = _records(records.map((e) => e.toJson()).toList());
  final bytes = utf8.encode(
    jsonEncode(checked.map((e) => e.toJson()).toList()),
  );
  final payload = _base64url(GZipEncoder().encode(bytes));
  _sizeGuard(payload);
  final uri = base is Uri ? base : Uri.parse(base as String);
  _protocol(uri);
  final query = Map<String, dynamic>.from(uri.queryParametersAll)..remove('p');
  final fragment = Map<String, dynamic>.from(
    Uri(query: uri.fragment).queryParametersAll,
  )..remove('p');
  if (uri.scheme == 'https') {
    fragment['p'] = payload;
  } else {
    query['p'] = payload;
  }
  return uri.replace(
    queryParameters: query,
    fragment: Uri(queryParameters: fragment).query,
  );
}

/// Decodes TS gzip payloads and the `j.` uncompressed fallback.
List<Envelope> decodeDeepLink(Uri uri) {
  _protocol(uri);
  final carriers = [
    ...(Uri(query: uri.fragment).queryParametersAll['p'] ?? <String>[]),
    ...(uri.queryParametersAll['p'] ?? <String>[]),
  ];
  if (carriers.length != 1 || carriers.single.isEmpty) {
    throw ContractValidationError(['/p: exactly one payload required']);
  }
  final payload = carriers.single;
  _sizeGuard(payload);
  final raw = payload.startsWith('j.');
  final bytes = _unbase64url(raw ? payload.substring(2) : payload);
  List<int> decoded = bytes;
  if (!raw) {
    try {
      // Pure Dart streaming inflation interrupts expansion before allocating
      // more than 1 MiB of output, with identical behavior on web and native.
      final output = _BoundedOutput();
      if (!const GZipDecoderWeb().decodeStream(
        InputMemoryStream(bytes),
        output,
        verify: true,
      )) {
        throw ContractValidationError(['/p: invalid gzip payload']);
      }
      decoded = output.getBytes();
    } on ContractValidationError {
      rethrow;
    } catch (_) {
      throw ContractValidationError(['/p: invalid gzip payload']);
    }
  }
  String text;
  try {
    text = utf8.decode(decoded);
  } on FormatException {
    throw ContractValidationError(['/p: invalid UTF-8']);
  }
  return fromFile(text);
}

class _BoundedOutput extends OutputMemoryStream {
  void _guard(int additional) {
    if (length + additional > decodedPayloadLimitBytes) {
      throw ContractValidationError([
        '/p: decoded payload exceeds 1 MiB; use file export',
      ]);
    }
  }

  @override
  void writeByte(int value) {
    _guard(1);
    super.writeByte(value);
  }

  @override
  void writeBytes(List<int> bytes, {int? length}) {
    _guard(length ?? bytes.length);
    super.writeBytes(bytes, length: length);
  }

  @override
  void writeStream(InputStream stream) {
    _guard(stream.length);
    super.writeStream(stream);
  }

  @override
  void writeBackReference(int distance, int count) {
    _guard(count);
    super.writeBackReference(distance, count);
  }
}
