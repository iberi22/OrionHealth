const { execFileSync } = require('child_process');

const issues = [
  {
    title: 'fix: unskip 2 wifi_direct_service network tests',
    label: 'jules',
    body: 'After fix #476, remove skip:true from the two transfer tests in test/features/health_sharing/infrastructure/wifi_direct_service_test.dart'
  },
  {
    title: 'feat: sync feature - add Domain layer',
    label: 'jules',
    body: 'Create Domain entities + repositories for sync feature.\nCurrently sync is all data/ without clean architecture.\n\nArchivos:\n- lib/features/sync/domain/sync_service.dart (new)\n- lib/features/sync/domain/sync_repository.dart (new)\n\nMigrate data layer logic to match clean architecture pattern.'
  },
  {
    title: 'feat: home feature - add Infrastructure layer',
    label: 'jules',
    body: 'Agregar Infrastructure layer para HomeCubit + servicios.\n\nArchivos:\n- lib/features/home/infrastructure/home_repository_impl.dart (new)\n\nCurrently home has Domain + Application + Presentation. Missing Infrastructure.'
  },
  {
    title: 'feat: onboarding - add Infrastructure layer',
    label: 'jules',
    body: 'Agregar Infrastructure layer para persistencia de onboarding.\n\nArchivos:\n- lib/features/onboarding/infrastructure/ (new directory)\n- lib/features/onboarding/infrastructure/onboarding_repository_impl.dart (new)\n\nCurrently onboarding tiene Domain + Application + Presentation. Missing Infrastructure.'
  },
  {
    title: 'feat: add tests for settings feature',
    label: 'jules',
    body: 'Add unit tests for settings feature:\n- LLM config entities\n- LLM settings cubit\n- LLM settings state\n- LLM settings repository (impl)\n\nArchivos:\n- test/features/settings/domain/entities/llm_config_test.dart (new)\n- test/features/settings/application/llm_settings_cubit_test.dart (new)\n- test/features/settings/application/llm_settings_state_test.dart (new)\n- test/features/settings/infrastructure/repositories/llm_settings_repository_impl_test.dart (new)'
  },
  {
    title: 'feat: add tests for user_profile feature',
    label: 'jules',
    body: 'Add unit tests for user_profile feature:\n- UserProfileCubit\n- UserProfileState\n- UserProfileRepository (impl)\n\nArchivos:\n- test/features/user_profile/application/user_profile_cubit_test.dart (new)\n- test/features/user_profile/infrastructure/user_profile_repository_impl_test.dart (new)'
  },
  {
    title: 'docs: update ORIONHEALTH-ROADMAP.md',
    label: 'jules',
    body: 'Roadmap está desactualizado (menciona v1.0.0 pero proyecto está en v0.8.1).\n\nArchivos:\n- docs/ORIONHEALTH-ROADMAP.md\n\nActualizar milestones y features completadas (Phases 3-6).'
  },
  {
    title: 'docs: update ARCHITECTURE.md',
    label: 'jules',
    body: 'ARCHITECTURE.md menciona health_report que ya no existe. Fue reemplazado por health_record.\n\nArchivos:\n- docs/ARCHITECTURE.md\n\nActualizar referencias a health_report -> health_record. Revisar diagramas de capas.'
  }
];

async function main() {
  for (const issue of issues) {
    try {
      const args = ['issue','create','--repo','iberi22/OrionHealth','--title', issue.title, '--label', issue.label, '--body', issue.body];
      console.log('Creating:', issue.title);
      const out = execFileSync('gh', args, { encoding: 'utf8', timeout: 15000 });
      console.log('  OK:', out.trim());
    } catch(e) {
      console.log('  FAIL:', e.message.substring(0, 80));
    }
  }
  console.log('Done.');
}
main();
