import 'package:equatable/equatable.dart';

class BlogPost extends Equatable {
  final String title;
  final String content;
  final String date;
  final String category;

  const BlogPost({
    required this.title,
    required this.content,
    required this.date,
    required this.category,
  });

  @override
  List<Object?> get props => [title, content, date, category];
}

class AboutInfo extends Equatable {
  final List<BlogPost> blogPosts;
  final String missionStatement;
  final List<String> values;
  final List<String> activities;

  const AboutInfo({
    required this.blogPosts,
    required this.missionStatement,
    required this.values,
    required this.activities,
  });

  @override
  List<Object?> get props => [blogPosts, missionStatement, values, activities];
}
