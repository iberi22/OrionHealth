import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../application/bloc/user_profile_cubit.dart';
import '../../domain/entities/user_profile.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isEditing = false;

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
              return _isEditing
                  ? _EditProfileView(
                      userProfile: state.userProfile,
                      onCancel: () => setState(() => _isEditing = false),
                      onSave: () => setState(() => _isEditing = false),
                    )
                  : _UserProfileView(
                      userProfile: state.userProfile,
                      onEdit: () => setState(() => _isEditing = true),
                    );
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
  final VoidCallback onEdit;
  const _UserProfileView({required this.userProfile, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'PERFIL',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: CyberTheme.primary,
            ),
          ),
          centerTitle: true,
          pinned: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: CyberTheme.secondary),
              onPressed: onEdit,
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 24),
                _ProfileHeader(userProfile: userProfile),
                const SizedBox(height: 32),
                _Section(
                  title: 'Información Personal',
                  children: [
                    _InfoTile(
                      icon: Icons.person,
                      title: 'Nombre Completo',
                      subtitle: userProfile.name ?? 'No definido',
                    ),
                    _InfoTile(
                      icon: Icons.cake,
                      title: 'Fecha de Nacimiento',
                      subtitle: userProfile.birthDate != null
                          ? DateFormat('dd/MM/yyyy').format(userProfile.birthDate!)
                          : 'No definida',
                    ),
                    _InfoTile(
                      icon: Icons.bloodtype,
                      title: 'Tipo de Sangre',
                      subtitle: userProfile.bloodType ?? 'No definido',
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
                      trailing: Switch(
                        value: false,
                        onChanged: (v) {},
                        activeColor: CyberTheme.primary,
                      ),
                    ),
                    const _InfoTile(
                      icon: Icons.lock,
                      title: 'Cifrado Local',
                      subtitle: 'Activo (AES-256)',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.redAccent.withOpacity(0.8)),
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

class _EditProfileView extends StatefulWidget {
  final UserProfile userProfile;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _EditProfileView({
    required this.userProfile,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _bloodTypeController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.name);
    _bloodTypeController = TextEditingController(text: widget.userProfile.bloodType);
    _selectedDate = widget.userProfile.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bloodTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDITAR PERFIL'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nombre', style: TextStyle(color: CyberTheme.secondary)),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Tu nombre',
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Fecha de Nacimiento', style: TextStyle(color: CyberTheme.secondary)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime(1990),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null
                          ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                          : 'Seleccionar fecha',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Tipo de Sangre', style: TextStyle(color: CyberTheme.secondary)),
            TextField(
              controller: _bloodTypeController,
              decoration: const InputDecoration(
                hintText: 'Ej: O+',
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CyberTheme.primary,
                foregroundColor: CyberTheme.backgroundDark,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final updatedProfile = widget.userProfile
                  ..name = _nameController.text
                  ..bloodType = _bloodTypeController.text
                  ..birthDate = _selectedDate;
                context.read<UserProfileCubit>().saveUserProfile(updatedProfile);
                widget.onSave();
              },
              child: const Text('GUARDAR CAMBIOS', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
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
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CyberTheme.surfaceDark,
            border: Border.all(color: CyberTheme.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: CyberTheme.primary.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.person, size: 60, color: CyberTheme.primary),
        ),
        const SizedBox(height: 16),
        Text(
          userProfile.name ?? 'Usuario',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'ID: ${userProfile.id}',
          style: const TextStyle(fontSize: 14, color: CyberTheme.secondary),
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
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white70,
            ),
          ),
        ),
        GlassmorphicCard(
          child: Column(
            children: ListTile.divideTiles(
              context: context,
              tiles: children,
              color: Colors.white.withOpacity(0.05),
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
      leading: Icon(icon, color: CyberTheme.secondary, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16))
          : null,
      trailing: trailing,
    );
  }
}
