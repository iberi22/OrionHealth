import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/auth/presentation/pages/receive_medical_data_page.dart';
import '../../../../features/auth/presentation/pages/share_medical_data_page.dart';
import '../../../../features/about/presentation/pages/about_page.dart';
import '../../../../features/settings/presentation/pages/llm_settings_page.dart';
import '../../../../features/medications/presentation/pages/medications_page.dart';
import '../../../../features/allergies/presentation/pages/allergies_page.dart';
import '../../../../features/appointments/presentation/pages/appointments_page.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
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
              return Center(child: Text('${AppLocalizations.of(context)!.error}: ${state.message}'));
            }
            return Center(child: Text(AppLocalizations.of(context)!.loading));
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
            AppLocalizations.of(context)!.profileTitle,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          pinned: true,
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
                  title: AppLocalizations.of(context)!.personalInfo,
                  children: [
                    _InfoTile(
                      icon: Icons.person,
                      title: AppLocalizations.of(context)!.fullName,
                      subtitle: userProfile.name,
                    ),
                    _InfoTile(
                      icon: Icons.cake,
                      title: AppLocalizations.of(context)!.birthDate,
                      subtitle: '15 de Agosto, 1988',
                    ),
                    _InfoTile(
                      icon: Icons.call,
                      title: AppLocalizations.of(context)!.contactNumber,
                      subtitle: '+1 (555) 123-4567',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _Section(
                  title: AppLocalizations.of(context)!.medicalInformation,
                  children: [
                    _InfoTile(
                      icon: Icons.medication,
                      title: AppLocalizations.of(context)!.medications,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MedicationsPage(),
                          ),
                        );
                      },
                    ),
                    _InfoTile(
                      icon: Icons.warning_amber_rounded,
                      title: AppLocalizations.of(context)!.allergies,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllergiesPage(),
                          ),
                        );
                      },
                    ),
                    _InfoTile(
                      icon: Icons.event,
                      title: AppLocalizations.of(context)!.appointments,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppointmentsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _Section(
                  title: AppLocalizations.of(context)!.bleDataExchange,
                  children: [
                    _InfoTile(
                      icon: Icons.bluetooth_audio,
                      title: AppLocalizations.of(context)!.shareMyData,
                      subtitle: AppLocalizations.of(context)!.sendHistoryToDoctor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShareMedicalDataPage(),
                          ),
                        );
                      },
                    ),
                    _InfoTile(
                      icon: Icons.download_for_offline,
                      title: AppLocalizations.of(context)!.receiveData,
                      subtitle: AppLocalizations.of(context)!.receiverMode,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReceiveMedicalDataPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _Section(
                  title: AppLocalizations.of(context)!.appPreferences,
                  children: [
                    _InfoTile(
                      icon: Icons.notifications,
                      title: AppLocalizations.of(context)!.pushNotifications,
                      trailing: Switch(value: true, onChanged: (v) {}),
                    ),
                    _InfoTile(
                      icon: Icons.dark_mode,
                      title: AppLocalizations.of(context)!.theme,
                      subtitle: 'Dark Mode',
                    ),
                    _InfoTile(
                      icon: Icons.smart_toy,
                      title: AppLocalizations.of(context)!.llmSettings,
                      subtitle: AppLocalizations.of(context)!.aiModelPreferences,
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
                      title: AppLocalizations.of(context)!.aboutOrionHealth,
                      subtitle: AppLocalizations.of(context)!.ourMissionVision,
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
                  title: AppLocalizations.of(context)!.privacySecurity,
                  children: [
                    _InfoTile(
                      icon: Icons.fingerprint,
                      title: AppLocalizations.of(context)!.biometricAuth,
                      trailing: Switch(value: false, onChanged: (v) {}),
                    ),
                    _InfoTile(
                      icon: Icons.cloud_off,
                      title: AppLocalizations.of(context)!.allowCloudApi,
                      subtitle: AppLocalizations.of(context)!.anonymizationActive,
                      trailing: Switch(
                        value: userProfile.allowCloudApi,
                        onChanged: (v) {
                          context.read<UserProfileCubit>().saveUserProfile(
                                userProfile.copyWith(allowCloudApi: v),
                              );
                        },
                      ),
                    ),
                    _InfoTile(
                      icon: Icons.password,
                      title: AppLocalizations.of(context)!.changePassword,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // In a real app, you would collect data from editing screens
                    // For now, just save the existing profile to show functionality
                    context.read<UserProfileCubit>().saveUserProfile(userProfile);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.profileSaved)),
                    );
                  },
                  child: SizedBox(
                    width: double.infinity,
                    child: Center(child: Text(AppLocalizations.of(context)!.saveChanges)),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      AppLocalizations.of(context)!.logOut,
                      style: TextStyle(color: AppColors.secondary.withValues(alpha: 0.8)),
                    ),
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
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
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
          style: TextStyle(fontSize: 16, color: AppColors.secondary),
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
      leading: Icon(icon, color: AppColors.secondary),
      title: Text(title),
      onTap: onTap,
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(color: Colors.white.withValues(alpha: 0.7)))
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.white54),
    );
  }
}
