import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../widgets/mission_section.dart';
import '../../application/about_cubit.dart';
import '../../domain/entities/about_info.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AboutCubit>()..loadAboutInfo(),
      child: Scaffold(
        body: BlocBuilder<AboutCubit, AboutState>(
          builder: (context, state) {
            if (state is AboutLoading || state is AboutInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AboutError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is AboutLoaded) {
              final info = state.aboutInfo;
              return CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        MissionSection(
                          missionStatement: info.missionStatement,
                          values: info.values,
                          activities: info.activities,
                        ),
                        const SizedBox(height: 40),
                        _buildBlogHeader(),
                        const SizedBox(height: 16),
                        ...info.blogPosts.map((post) => _BlogTile(post: post)),
                        const SizedBox(height: 40),
                      ]),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background.withValues(alpha: 0.8),
      title: const Text(
        'Sobre OrionHealth',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: const BackButton(),
    );
  }

  Widget _buildBlogHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COMUNIDAD Y NOTICIAS',
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nuestro Blog de Salud',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _BlogTile extends StatelessWidget {
  final BlogPost post;
  const _BlogTile({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassmorphicCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      post.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    post.date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // Post expansion could be implemented here
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Leer más', style: TextStyle(color: AppColors.secondary)),
                    Icon(Icons.arrow_right, color: AppColors.secondary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
