import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/auth/presentation/pages/receive_medical_data_page.dart';
import '../../../../features/auth/presentation/pages/share_medical_data_page.dart';
import '../../../../features/about/presentation/pages/about_page.dart';
import '../../../../features/settings/presentation/pages/llm_settings_page.dart';
import '../../../../features/network/network_health/presentation/pages/network_health_page.dart';
import '../../../../features/health_data_import/presentation/pages/health_import_page.dart';
import '../../../../features/medications/presentation/pages/medications_page.dart';
import '../../../../features/allergies/presentation/pages/allergies_page.dart';
import '../../../../features/appointments/presentation/pages/appointments_page.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/bloc/user_profile_cubit.dart';
import '../../domain/entities/user_profile.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_section.dart';
import '../widgets/profile_info_tile.dart';

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
                ProfileHeader(userProfile: userProfile),
                const SizedBox.shrink(),
                const SizedBox(height: 32),
                ProfileSection(
                  title: AppLocalizations.of(context)!.personalInfo,
                  children: [
                    ProfileInfoTile(
                      icon: Icons.person,
                      title: AppLocalizations.of(context)!.fullName,
                      subtitle: userProfile.name,
                    ),
                    ProfileInfoTile(
                      icon: Icons.cake,
                      title: AppLocalizations.of(context)!.birthDate,
                      subtitle: '15 de Agosto, 1988',
                    ),
                    ProfileInfoTile(
                      icon: Icons.call,
                      title: AppLocalizations.of(context)!.contactNumber,
                      subtitle: '+1 (555) 123-4567',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ProfileSection(
                  title: AppLocalizations.of(context)!.medicalInformation,
                  children: [
                    ProfileInfoTile(
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
                    ProfileInfoTile(
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
                    ProfileInfoTile(
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
                    ProfileInfoTile(
                      icon: Icons.hub_outlined,
                      title: AppLocalizations.of(context)!.networkHealth,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NetworkHealthPage(),
                          ),
                        );
                      },
                    ),
                    ProfileInfoTile(
                      icon: Icons.import_export,
                      title: AppLocalizations.of(context)!.importData,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HealthImportPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ProfileSection(
                  title: AppLocalizations.of(context)!.bleDataExchange,
                  children: [
                    ProfileInfoTile(
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
                    ProfileInfoTile(
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
                ProfileSection(
                  title: AppLocalizations.of(context)!.appPreferences,
                  children: [
                    ProfileInfoTile(
                      icon: Icons.notifications,
                      title: AppLocalizations.of(context)!.pushNotifications,
                      trailing: Switch(value: true, onChanged: (v) {}),
                    ),
                    ProfileInfoTile(
                      icon: Icons.dark_mode,
                      title: AppLocalizations.of(context)!.theme,
                      subtitle: 'Dark Mode',
                    ),
                    ProfileInfoTile(
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
                    ProfileInfoTile(
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
                ProfileSection(
                  title: AppLocalizations.of(context)!.privacySecurity,
                  children: [
                    ProfileInfoTile(
                      icon: Icons.fingerprint,
                      title: AppLocalizations.of(context)!.biometricAuth,
                      trailing: Switch(value: false, onChanged: (v) {}),
                    ),
                    ProfileInfoTile(
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
                    ProfileInfoTile(
                      icon: Icons.password,
                      title: AppLocalizations.of(context)!.changePassword,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
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
