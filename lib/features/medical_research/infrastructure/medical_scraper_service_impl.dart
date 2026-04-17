import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../domain/models/research_result.dart';
import '../domain/services/medical_scraper_service.dart';
import 'bot_bypass_handler.dart';

@LazySingleton(as: MedicalScraperService)
class MedicalScraperServiceImpl implements MedicalScraperService {
  final Dio _dio;
  final BotBypassHandler _botBypassHandler;

  MedicalScraperServiceImpl(this._dio, this._botBypassHandler);

  @override
  Future<ResearchResult?> scrape(String url) async {
    try {
      await _botBypassHandler.waitHumanTime();

      final response = await _dio.get(
        url,
        options: Options(headers: _botBypassHandler.getHeaders()),
      );

      if (response.statusCode == 200) {
        // Simple extraction for now - in a real app, use a proper HTML parser like 'html' package
        final html = response.data.toString();

        // Extract title
        final titleMatch = RegExp(r'<title>(.*?)</title>').firstMatch(html);
        final title = titleMatch?.group(1) ?? 'Scraped Content';

        // Extract meta description or some body text as content
        final metaDescMatch = RegExp(r'<meta name="description" content="(.*?)">').firstMatch(html);
        final content = metaDescMatch?.group(1) ?? 'Content extracted from $url';

        return ResearchResult(
          title: title,
          content: content,
          source: _extractSource(url),
          url: url,
        );
      }
    } catch (e) {
      // Log error
    }
    return null;
  }

  String _extractSource(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (_) {
      return 'Web';
    }
  }
}
