import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../application/bloc/user_profile_cubit.dart';
import '../../domain/entities/user_profile.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<UserProfileCubit>()..loadUserProfile(),
      child: Scaffold(
        body: BlocBuilder<UserProfileCubit, UserProfileState>(
          builder: (context, state) {
            if (state is UserProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserProfileLoaded) {
              return _UserProfileView(userProfile: state.userProfile);
            } else if (state is UserProfileError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Iniciando...'));
          },
        ),
      ),
    );
  }
}

class _UserProfileView extends StatelessWidget {
  final UserProfile userProfile;
  const _UserProfileView({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          leading: const Icon(Icons.arrow_back_ios_new),
          title: Text(
            'Perfil del Usuario',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          pinned: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 24),
              _ProfileHeader(userProfile: userProfile),
              const SizedBox(height: 32),
              _Section(
                title: 'Información Personal',
                children: [
                  _InfoTile(
                    icon: Icons.person,
                    title: 'Nombre Completo',
                    subtitle: userProfile.name,
                  ),
                  const _InfoTile(
                    icon: Icons.cake,
                    title: 'Fecha de Nacimiento',
                    subtitle: '15 de Agosto, 1988',
                  ),
                  const _InfoTile(
                    icon: Icons.call,
                    title: 'Número de Contacto',
                    subtitle: '+1 (555) 123-4567',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _Section(
                title: 'Preferencias de la App',
                children: [
                  _InfoTile(
                    icon: Icons.notifications,
                    title: 'Notificaciones Push',
                    trailing: Switch(value: true, onChanged: (v) {}),
                  ),
                  const _InfoTile(
                    icon: Icons.dark_mode,
                    title: 'Tema',
                    subtitle: 'Modo Oscuro',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _Section(
                title: 'Privacidad y Seguridad',
                children: [
                  _InfoTile(
                    icon: Icons.fingerprint,
                    title: 'Autenticación Biométrica',
                    trailing: Switch(value: false, onChanged: (v) {}),
                  ),
                  const _InfoTile(
                    icon: Icons.password,
                    title: 'Cambiar Contraseña',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberTheme.primary,
                  foregroundColor: CyberTheme.backgroundDark,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // In a real app, you would collect data from editing screens
                  // For now, just save the existing profile to show functionality
                  context.read<UserProfileCubit>().saveUserProfile(userProfile);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Perfil guardado')),
                  );
                },
                child: const Text(
                  'Guardar Cambios',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    color: CyberTheme.secondary.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile userProfile;
  const _ProfileHeader({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 128,
          width: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: NetworkImage(
                "https://lh3.googleusercontent.com/aida-public/AB6AXuAIpUPoUs4Oykl6RpdGHalhqjetooQ-sZ9LobLpgbAVOnhYpaq8N5vqWkwgyY-cwthjBPnowELtGGRPqp12k_sBKhk9r7bW6YJUQtkoABO21_fgw5CmQOHkZHg4bwR4J3Ib9VVx_cMtcEqRsl2k7jkw26FOnsrjgs9XHtK8O9g-VGixxrv0pXd_frqH_xsPyWS6rXzsNUlO_BSRmHdplSNegvbJxMUdDddekMquxJ3gn2_oK2Z4ToEq_mHl-FAK5E-ejgnRZzRJt7_M",
              ),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: CyberTheme.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: CyberTheme.primary.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userProfile.name ?? 'Usuario',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'alex.damon@orion.health',
          style: TextStyle(fontSize: 16, color: CyberTheme.secondary),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        GlassmorphicCard(
          child: Column(
            children: ListTile.divideTiles(
              context: context,
              tiles: children,
              color: Colors.white.withOpacity(0.1),
            ).toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _InfoTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: CyberTheme.secondary),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            )
          : null,
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: Colors.white54),
    );
  }
}
