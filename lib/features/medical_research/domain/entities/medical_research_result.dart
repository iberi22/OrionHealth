import 'package:isar/isar.dart';
import '../models/research_result.dart';

part 'medical_research_result.g.dart';

@collection
class MedicalResearchResult {
  Id id = Isar.autoIncrement;

  late String query;
  late DateTime timestamp;

  // Since ResearchResult is not an Isar collection/embedded,
  // we store its components or a serialized version.
  // For now, let's store the main fields to keep it simple and searchable.
  late List<ResearchResultItem> items;

  MedicalResearchResult({
    required this.query,
    required this.timestamp,
    required this.items,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalResearchResult &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          timestamp == other.timestamp;

  @override
  int get hashCode => query.hashCode ^ timestamp.hashCode;
}

@embedded
class ResearchResultItem {
  late String title;
  late String content;
  late String source;
  late String url;
  late double confidence;

  ResearchResultItem({
    this.title = '',
    this.content = '',
    this.source = '',
    this.url = '',
    this.confidence = 0.0,
  });

  factory ResearchResultItem.fromResearchResult(ResearchResult result) {
    return ResearchResultItem(
      title: result.title,
      content: result.content,
      source: result.source,
      url: result.url,
      confidence: result.confidence,
    );
  }

  ResearchResult toResearchResult() {
    return ResearchResult(
      title: title,
      content: content,
      source: source,
      url: url,
      confidence: confidence,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResearchResultItem &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          source == other.source &&
          url == other.url;

  @override
  int get hashCode => title.hashCode ^ source.hashCode ^ url.hashCode;
}
