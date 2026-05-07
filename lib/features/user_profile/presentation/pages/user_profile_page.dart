import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/health_sharing/presentation/pages/receive_page.dart';
import '../../../../features/health_sharing/presentation/pages/share_page.dart';
import '../../../../features/about/presentation/pages/about_page.dart';
import '../../../../features/settings/presentation/pages/llm_settings_page.dart';
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

class _UserProfileView extends StatefulWidget {
  final UserProfile userProfile;
  const _UserProfileView({required this.userProfile});

  @override
  State<_UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<_UserProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _ageController;
  late TextEditingController _bloodTypeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.name);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _phoneController = TextEditingController(text: widget.userProfile.phoneNumber);
    _weightController = TextEditingController(text: widget.userProfile.weight?.toString());
    _heightController = TextEditingController(text: widget.userProfile.height?.toString());
    _ageController = TextEditingController(text: widget.userProfile.age?.toString());
    _bloodTypeController = TextEditingController(text: widget.userProfile.bloodType);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _bloodTypeController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final updatedProfile = widget.userProfile.copyWith(
      name: _nameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      weight: double.tryParse(_weightController.text),
      height: double.tryParse(_heightController.text),
      age: int.tryParse(_ageController.text),
      bloodType: _bloodTypeController.text,
    );
    context.read<UserProfileCubit>().saveUserProfile(updatedProfile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil guardado')),
    );
  }

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
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          pinned: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: CyberTheme.primary),
              onPressed: _saveProfile,
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 24),
                _ProfileHeader(userProfile: widget.userProfile),
                const SizedBox(height: 32),
                _Section(
                  title: 'Datos Personales',
                  children: [
                    _EditTile(
                      icon: Icons.person,
                      label: 'Nombre Completo',
                      controller: _nameController,
                    ),
                    _EditTile(
                      icon: Icons.email,
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _EditTile(
                      icon: Icons.call,
                      label: 'Número de Contacto',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _Section(
                  title: 'Métricas',
                  children: [
                    _EditTile(
                      icon: Icons.monitor_weight,
                      label: 'Peso',
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      suffixText: 'kg',
                    ),
                    _EditTile(
                      icon: Icons.height,
                      label: 'Altura',
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      suffixText: 'cm',
                    ),
                    _EditTile(
                      icon: Icons.cake,
                      label: 'Edad',
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      suffixText: 'años',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _Section(
                  title: 'Detalles Médicos',
                  children: [
                    _EditTile(
                      icon: Icons.bloodtype,
                      label: 'Tipo de Sangre',
                      controller: _bloodTypeController,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _Section(
                  title: 'Intercambio de Datos BLE',
                  children: [
                    _InfoTile(
                      icon: Icons.bluetooth_audio,
                      title: 'Compartir mis Datos',
                      subtitle: 'Enviar historial al médico',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SharePage(),
                          ),
                        );
                      },
                    ),
                    _InfoTile(
                      icon: Icons.download_for_offline,
                      title: 'Recibir Datos',
                      subtitle: 'Modo receptor (Médico)',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReceivePage(),
                          ),
                        );
                      },
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
                    _InfoTile(
                      icon: Icons.smart_toy,
                      title: 'Configuración de LLM',
                      subtitle: 'Modelo de IA y preferencias',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LlmSettingsPage(),
                          ),
                        );
                      },
                    ),
                    _InfoTile(
                      icon: Icons.info_outline,
                      title: 'Sobre OrionHealth',
                      subtitle: 'Nuestra misión y visión',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutPage(),
                          ),
                        );
                      },
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
                    _InfoTile(
                      icon: Icons.cloud_off,
                      title: 'Permitir llamadas a APIs en la nube',
                      subtitle: 'Anonimización activa si está ON',
                      trailing: Switch(
                        value: widget.userProfile.allowCloudApi,
                        onChanged: (v) {
                          context.read<UserProfileCubit>().saveUserProfile(
                                widget.userProfile.copyWith(allowCloudApi: v),
                              );
                        },
                      ),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _saveProfile,
                  child: const Text('Guardar Cambios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: CyberTheme.secondary.withValues(alpha: 0.8)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
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
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuAIpUPoUs4Oykl6RpdGHalhqjetooQ-sZ9LobLpgbAVOnhYpaq8N5vqWkwgyY-cwthjBPnowELtGGRPqp12k_sBKhk9r7bW6YJUQtkoABO21_fgw5CmQOHkZHg4bwR4J3Ib9VVx_cMtcEqRsl2k7jkw26FOnsrjgs9XHtK8O9g-VGixxrv0pXd_frqH_xsPyWS6rXzsNUlO_BSRmHdplSNegvbJxMUdDddekMquxJ3gn2_oK2Z4ToEq_mHl-FAK5E-ejgnRZzRJt7_M"),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: CyberTheme.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: CyberTheme.primary.withValues(alpha: 0.3),
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
        Text(
          userProfile.email ?? 'alex.damon@orion.health',
          style: const TextStyle(fontSize: 16, color: CyberTheme.secondary),
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
          padding: EdgeInsets.zero,
          child: Column(
            children: ListTile.divideTiles(
              context: context,
              tiles: children,
              color: Colors.white.withValues(alpha: 0.1),
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
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: CyberTheme.secondary),
      title: Text(title),
      onTap: onTap,
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(color: Colors.white.withValues(alpha: 0.7)))
          : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: Colors.white54) : null),
    );
  }
}

class _EditTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? suffixText;

  const _EditTile({
    required this.icon,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: CyberTheme.secondary),
      title: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          border: InputBorder.none,
          suffixText: suffixText,
          suffixStyle: const TextStyle(color: CyberTheme.primary),
        ),
      ),
    );
  }
}
