import '../../domain/models/research_result.dart';

class ResearchResultDto {
  final String title;
  final String summary;
  final String source;
  final String url;
  final double relevanceScore;

  const ResearchResultDto({
    required this.title, required this.summary, required this.source,
    required this.url, required this.relevanceScore,
  });

  factory ResearchResultDto.fromModel(ResearchResult r) => ResearchResultDto(
    title: r.title, summary: r.summary, source: r.source,
    url: r.url, relevanceScore: r.relevanceScore,
  );

  Map<String, dynamic> toJson() => {
    'title': title, 'summary': summary, 'source': source,
    'url': url, 'relevanceScore': relevanceScore,
  };

  factory ResearchResultDto.fromJson(Map<String, dynamic> j) => ResearchResultDto(
    title: j['title'] as String, summary: j['summary'] as String,
    source: j['source'] as String, url: j['url'] as String,
    relevanceScore: (j['relevanceScore'] as num).toDouble(),
  );
}
