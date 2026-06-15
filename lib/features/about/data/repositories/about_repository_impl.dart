import '../../domain/entities/about_info.dart';
import '../../domain/repositories/i_about_repository.dart';
import '../datasources/about_local_datasource.dart';

class AboutRepositoryImpl implements IAboutRepository {
  final AboutLocalDataSource _localDataSource;
  AboutRepositoryImpl(this._localDataSource);

  @override
  Future<AboutInfo> getAboutInfo() async {
    final data = _localDataSource.getStaticAboutData();
    final blogPosts = (data['blogPosts'] as List<dynamic>).map((post) => BlogPost(
      title: post['title'] as String, content: post['content'] as String,
      date: post['date'] as String, category: post['category'] as String,
    )).toList();

    return AboutInfo(
      blogPosts: blogPosts,
      missionStatement: data['missionStatement'] as String,
      values: List<String>.from(data['values'] as List),
      activities: List<String>.from(data['activities'] as List),
    );
  }
}
