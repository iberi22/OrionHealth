// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_calendar/device_calendar.dart' as _i20;
import 'package:dio/dio.dart' as _i31;
import 'package:flutter/services.dart' as _i93;
import 'package:flutter_appauth/flutter_appauth.dart' as _i39;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i41;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_generative_ai/google_generative_ai.dart' as _i43;
import 'package:health/health.dart' as _i45;
import 'package:health_wallet/health_wallet.dart' as _i35;
import 'package:http/http.dart' as _i26;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i61;
import 'package:isar_agent_memory/isar_agent_memory.dart' as _i34;
import 'package:just_audio/just_audio.dart' as _i13;
import 'package:medical_standards/medical_standards.dart' as _i69;
import 'package:shared_preferences/shared_preferences.dart' as _i52;

<<<<<<< HEAD
<<<<<<< HEAD
import '../../features/about/application/about_cubit.dart' as _i141;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i54;
import '../../features/about/domain/usecases/get_about_info_usecase.dart'
    as _i165;
import '../../features/about/infrastructure/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/infrastructure/datasources/about_remote_datasource.dart'
    as _i142;
=======
import '../../features/about/application/about_cubit.dart' as _i143;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i54;
import '../../features/about/domain/usecases/get_about_info_usecase.dart'
    as _i168;
import '../../features/about/infrastructure/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/infrastructure/datasources/about_remote_datasource.dart'
    as _i144;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
import '../../features/about/application/about_cubit.dart' as _i141;
import '../../features/about/domain/repositories/i_about_repository.dart'
    as _i54;
import '../../features/about/domain/usecases/get_about_info_usecase.dart'
    as _i165;
import '../../features/about/infrastructure/datasources/about_local_datasource.dart'
    as _i4;
import '../../features/about/infrastructure/datasources/about_remote_datasource.dart'
    as _i142;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/about/infrastructure/repositories/about_repository_impl.dart'
    as _i55;
import '../../features/allergies/application/allergies_cubit.dart' as _i263;
import '../../features/allergies/application/bloc/allergy_bloc.dart' as _i264;
import '../../features/allergies/data/datasources/allergy_local_datasource.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i143;
=======
    as _i145;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
import '../../features/allergies/data/repositories/allergy_repository_impl.dart'
    as _i227;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i226;
=======
    as _i143;
import '../../features/allergies/data/repositories/allergy_repository_impl.dart'
    as _i226;
import '../../features/allergies/domain/repositories/allergy_repository.dart'
    as _i225;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/allergies/domain/services/allergy_service.dart' as _i6;
import '../../features/allergies/domain/usecases/get_allergies_usecase.dart'
    as _i244;
import '../../features/allergies/domain/usecases/save_allergy_usecase.dart'
    as _i260;
import '../../features/appointments/application/appointments_cubit.dart'
    as _i10;
import '../../features/appointments/application/bloc/appointment_bloc.dart'
    as _i7;
import '../../features/appointments/domain/repositories/appointment_repository.dart'
    as _i8;
import '../../features/appointments/domain/services/appointment_service.dart'
    as _i9;
import '../../features/appointments/domain/usecases/delete_appointment_usecase.dart'
    as _i28;
import '../../features/appointments/domain/usecases/get_all_appointments_usecase.dart'
    as _i44;
import '../../features/appointments/domain/usecases/save_appointment_usecase.dart'
    as _i110;
<<<<<<< HEAD
<<<<<<< HEAD
import '../../features/auth/application/auth_cubit.dart' as _i265;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i228;
=======
import '../../features/auth/application/auth_cubit.dart' as _i264;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i227;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i144;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i146;
<<<<<<< HEAD
import '../../features/auth/domain/auth_service.dart' as _i229;
=======
import '../../features/auth/domain/auth_service.dart' as _i228;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/auth/domain/repositories/auth_repository.dart' as _i145;
import '../../features/auth/domain/usecases/check_session_timeout.dart'
    as _i150;
import '../../features/auth/domain/usecases/get_credentials_usecase.dart'
    as _i171;
<<<<<<< HEAD
import '../../features/auth/domain/usecases/login_usecase.dart' as _i194;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i195;
import '../../features/auth/domain/usecases/save_credentials_usecase.dart'
    as _i207;
import '../../features/auth/domain/usecases/set_pin_usecase.dart' as _i214;
=======
import '../../features/auth/application/auth_cubit.dart' as _i264;
import '../../features/auth/application/bloc/auth_cubit.dart' as _i228;
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i146;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i148;
import '../../features/auth/domain/auth_service.dart' as _i229;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i147;
import '../../features/auth/domain/usecases/check_session_timeout.dart'
    as _i152;
import '../../features/auth/domain/usecases/get_credentials_usecase.dart'
    as _i174;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i196;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i197;
import '../../features/auth/domain/usecases/save_credentials_usecase.dart'
    as _i209;
import '../../features/auth/domain/usecases/set_pin_usecase.dart' as _i216;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
import '../../features/auth/domain/usecases/validate_session_usecase.dart'
    as _i222;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i16;
import '../../features/auth/infrastructure/services/encryption_service.dart'
<<<<<<< HEAD
    as _i163;
=======
    as _i165;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i232;
=======
import '../../features/auth/domain/usecases/login_usecase.dart' as _i193;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i194;
import '../../features/auth/domain/usecases/save_credentials_usecase.dart'
    as _i206;
import '../../features/auth/domain/usecases/set_pin_usecase.dart' as _i213;
import '../../features/auth/domain/usecases/validate_session_usecase.dart'
    as _i221;
import '../../features/auth/infrastructure/services/biometric_service.dart'
    as _i16;
import '../../features/auth/infrastructure/services/encryption_service.dart'
    as _i163;
import '../../features/calendar_import/application/calendar_import_cubit.dart'
    as _i231;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/calendar_import/domain/repositories/calendar_import_repository.dart'
    as _i21;
import '../../features/calendar_import/domain/services/calendar_parser_service.dart'
    as _i23;
import '../../features/calendar_import/domain/usecases/import_calendar_usecase.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i187;
=======
    as _i189;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
    as _i186;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/calendar_import/infrastructure/datasources/calendar_api_datasource.dart'
    as _i19;
import '../../features/calendar_import/infrastructure/repositories/calendar_import_repository_impl.dart'
    as _i22;
import '../../features/calendar_import/infrastructure/services/calendar_parser_service_impl.dart'
    as _i24;
import '../../features/dashboard/application/dashboard_cubit.dart' as _i266;
import '../../features/dashboard/domain/repositories/dashboard_repository.dart'
<<<<<<< HEAD
    as _i234;
=======
    as _i233;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i245;
import '../../features/dashboard/domain/usecases/get_recent_activity_usecase.dart'
    as _i247;
import '../../features/dashboard/infrastructure/datasources/dashboard_local_datasource.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i154;
=======
    as _i156;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
import '../../features/dashboard/infrastructure/datasources/dashboard_remote_datasource.dart'
    as _i27;
import '../../features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart'
    as _i235;
import '../../features/data_sources/application/data_source_cubit.dart'
<<<<<<< HEAD
    as _i267;
import '../../features/data_sources/domain/repositories/data_source_repository.dart'
    as _i236;
import '../../features/data_sources/infrastructure/datasources/file_import_datasource.dart'
    as _i164;
import '../../features/data_sources/infrastructure/datasources/health_connect_datasource.dart'
    as _i182;
=======
    as _i266;
import '../../features/data_sources/domain/repositories/data_source_repository.dart'
    as _i236;
import '../../features/data_sources/infrastructure/datasources/file_import_datasource.dart'
    as _i167;
import '../../features/data_sources/infrastructure/datasources/health_connect_datasource.dart'
    as _i46;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
import '../../features/data_sources/infrastructure/datasources/sensor_api_datasource.dart'
    as _i116;
import '../../features/data_sources/infrastructure/repositories/data_source_repository_impl.dart'
    as _i237;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i231;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
<<<<<<< HEAD
    as _i160;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i212;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i225;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i158;
=======
    as _i162;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i214;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i225;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i160;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
    as _i154;
import '../../features/dashboard/infrastructure/datasources/dashboard_remote_datasource.dart'
    as _i27;
import '../../features/dashboard/infrastructure/repositories/dashboard_repository_impl.dart'
    as _i234;
import '../../features/data_sources/application/data_source_cubit.dart'
    as _i266;
import '../../features/data_sources/domain/repositories/data_source_repository.dart'
    as _i235;
import '../../features/data_sources/infrastructure/datasources/file_import_datasource.dart'
    as _i164;
import '../../features/data_sources/infrastructure/datasources/health_connect_datasource.dart'
    as _i46;
import '../../features/data_sources/infrastructure/datasources/sensor_api_datasource.dart'
    as _i116;
import '../../features/data_sources/infrastructure/repositories/data_source_repository_impl.dart'
    as _i236;
import '../../features/doctor_verification/application/badge_cubit.dart'
    as _i230;
import '../../features/doctor_verification/application/doctor_verification_cubit.dart'
    as _i160;
import '../../features/doctor_verification/application/second_opinion_cubit.dart'
    as _i211;
import '../../features/doctor_verification/application/vouch_cubit.dart'
    as _i224;
import '../../features/doctor_verification/domain/repositories/doctor_profile_repository.dart'
    as _i158;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/doctor_verification/domain/repositories/rating_repository.dart'
    as _i104;
import '../../features/doctor_verification/domain/repositories/second_opinion_repository.dart'
    as _i112;
import '../../features/doctor_verification/domain/repositories/vouch_repository.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i138;
=======
    as _i140;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i230;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i63;
import '../../features/doctor_verification/domain/usecases/get_all_doctors_usecase.dart'
<<<<<<< HEAD
=======
    as _i138;
import '../../features/doctor_verification/domain/services/badge_calculator.dart'
    as _i229;
import '../../features/doctor_verification/domain/services/license_verifier.dart'
    as _i63;
import '../../features/doctor_verification/domain/usecases/get_all_doctors_usecase.dart'
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
    as _i166;
import '../../features/doctor_verification/domain/usecases/get_doctor_profile_usecase.dart'
    as _i172;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i62;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i159;
<<<<<<< HEAD
=======
    as _i169;
import '../../features/doctor_verification/domain/usecases/get_doctor_profile_usecase.dart'
    as _i175;
import '../../features/doctor_verification/infrastructure/datasources/license_registry_local.dart'
    as _i62;
import '../../features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart'
    as _i161;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/doctor_verification/infrastructure/repositories/isar_rating_repository.dart'
    as _i105;
import '../../features/doctor_verification/infrastructure/repositories/isar_second_opinion_repository.dart'
    as _i113;
import '../../features/doctor_verification/infrastructure/repositories/isar_vouch_repository.dart'
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
    as _i139;
import '../../features/email-citas/application/bloc/email_citas_bloc.dart'
    as _i161;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i162;
<<<<<<< HEAD
=======
    as _i141;
import '../../features/email-citas/application/bloc/email_citas_bloc.dart'
    as _i163;
import '../../features/email-citas/application/email_citas_cubit.dart' as _i164;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/email-citas/domain/repositories/email_repository.dart'
    as _i32;
import '../../features/email-citas/domain/usecases/email_citas_usecases.dart'
    as _i124;
import '../../features/email-citas/infrastructure/repositories/email_repository_impl.dart'
    as _i33;
import '../../features/eps_connection/application/bloc/eps_connection_bloc.dart'
    as _i239;
<<<<<<< HEAD
import '../../features/eps_connection/application/bloc/eps_connection_cubit.dart'
    as _i240;
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/eps_connection/domain/repositories/oauth_repository.dart'
    as _i98;
import '../../features/eps_connection/domain/usecases/connect_provider_usecase.dart'
    as _i153;
import '../../features/eps_connection/domain/usecases/disconnect_provider_usecase.dart'
    as _i155;
import '../../features/eps_connection/domain/usecases/get_connections_usecase.dart'
    as _i170;
import '../../features/eps_connection/infrastructure/datasources/oauth_local_datasource.dart'
    as _i97;
import '../../features/eps_connection/infrastructure/repositories/oauth_repository_impl.dart'
    as _i99;
import '../../features/health_data_import/application/bloc/health_import_bloc.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i248;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i249;
import '../../features/health_data_import/domain/repositories/health_data_import_repository.dart'
    as _i183;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i46;
=======
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
    as _i247;
import '../../features/health_data_import/application/health_import_cubit.dart'
    as _i248;
import '../../features/health_data_import/domain/repositories/health_data_import_repository.dart'
    as _i182;
import '../../features/health_data_import/domain/services/health_data_import_service.dart'
    as _i47;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
import '../../features/health_data_import/domain/usecases/health_import_usecases.dart'
    as _i109;
import '../../features/health_data_import/infrastructure/data_source.dart'
    as _i117;
import '../../features/health_data_import/infrastructure/health_data_import_repository_impl.dart'
<<<<<<< HEAD
    as _i184;
=======
    as _i183;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/health_record/application/bloc/health_record_cubit.dart'
    as _i250;
import '../../features/health_record/domain/repositories/health_record_repository.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i185;
=======
    as _i187;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
    as _i184;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/health_record/domain/usecases/get_all_records_usecase.dart'
    as _i243;
import '../../features/health_record/domain/usecases/save_record_usecase.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i209;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i186;
=======
    as _i211;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i188;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
    as _i208;
import '../../features/health_record/infrastructure/repositories/health_record_repository_impl.dart'
    as _i185;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/health_record/infrastructure/services/file_picker_service.dart'
    as _i37;
import '../../features/health_record/infrastructure/services/image_picker_service.dart'
    as _i56;
import '../../features/health_record/infrastructure/services/ocr_service.dart'
    as _i100;
import '../../features/health_sharing/application/sharing_cubit.dart' as _i262;
import '../../features/health_sharing/domain/repositories/sharing_repository.dart'
    as _i121;
import '../../features/health_sharing/domain/usecases/cancel_sharing_usecase.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i148;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i216;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i217;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i147;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i17;
import '../../features/health_sharing/infrastructure/datasources/health_sharing_local_datasource.dart'
    as _i47;
=======
    as _i150;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i218;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i219;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i149;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i17;
import '../../features/health_sharing/infrastructure/datasources/health_sharing_local_datasource.dart'
    as _i48;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
    as _i148;
import '../../features/health_sharing/domain/usecases/start_listening_usecase.dart'
    as _i215;
import '../../features/health_sharing/domain/usecases/start_sharing_usecase.dart'
    as _i216;
import '../../features/health_sharing/infrastructure/ble_sharing_service.dart'
    as _i147;
import '../../features/health_sharing/infrastructure/ble_wrapper.dart' as _i17;
import '../../features/health_sharing/infrastructure/datasources/health_sharing_local_datasource.dart'
    as _i48;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/health_sharing/infrastructure/datasources/health_sharing_remote_datasource.dart'
    as _i48;
import '../../features/health_sharing/infrastructure/nfc_handler.dart' as _i92;
import '../../features/health_sharing/infrastructure/nfc_sharing_service.dart'
    as _i94;
import '../../features/health_sharing/infrastructure/repositories/health_sharing_repository_impl.dart'
    as _i122;
import '../../features/health_sharing/infrastructure/wifi_direct_service.dart'
    as _i140;
<<<<<<< HEAD
import '../../features/home/application/home_cubit.dart' as _i270;
import '../../features/home/domain/repositories/home_repository.dart' as _i251;
=======
import '../../features/home/application/home_cubit.dart' as _i269;
import '../../features/home/domain/repositories/home_repository.dart' as _i250;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/home/domain/usecases/get_health_summary_usecase.dart'
    as _i268;
import '../../features/home/infrastructure/datasources/health_summary_datasource.dart'
    as _i49;
import '../../features/home/infrastructure/datasources/home_local_datasource.dart'
    as _i51;
import '../../features/home/infrastructure/datasources/home_remote_datasource.dart'
    as _i53;
import '../../features/home/infrastructure/repositories/home_repository_impl.dart'
    as _i252;
import '../../features/local_agent/application/use_cases/smart_search_use_case.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i215;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i149;
=======
    as _i217;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i151;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
    as _i214;
import '../../features/local_agent/data/datasources/chat_message_local_datasource.dart'
    as _i149;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/local_agent/data/datasources/local_model_local_datasource.dart'
    as _i68;
import '../../features/local_agent/domain/repositories/medical_knowledge_repository.dart'
    as _i70;
import '../../features/local_agent/domain/services/llm_adapter.dart' as _i64;
import '../../features/local_agent/domain/services/vector_store_service.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i131;
import '../../features/local_agent/domain/usecases/get_chat_history_usecase.dart'
    as _i169;
=======
    as _i133;
import '../../features/local_agent/domain/usecases/get_chat_history_usecase.dart'
    as _i172;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
    as _i131;
import '../../features/local_agent/domain/usecases/get_chat_history_usecase.dart'
    as _i168;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/local_agent/domain/usecases/send_chat_message_usecase.dart'
    as _i115;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_adapter.dart'
    as _i66;
import '../../features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart'
    as _i40;
import '../../features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i188;
=======
    as _i191;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i42;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i189;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
<<<<<<< HEAD
    as _i66;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i192;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i191;
=======
    as _i65;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i194;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i193;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
    as _i187;
import '../../features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart'
    as _i42;
import '../../features/local_agent/infrastructure/adapters/mock_llm_adapter.dart'
    as _i188;
import '../../features/local_agent/infrastructure/adapters/openai_compatible_adapter.dart'
    as _i66;
import '../../features/local_agent/infrastructure/gemma_llm_service.dart'
    as _i191;
import '../../features/local_agent/infrastructure/llm_service.dart' as _i190;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/local_agent/infrastructure/rag_llm_service.dart'
    as _i253;
import '../../features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i71;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i72;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
    as _i132;
=======
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
    as _i72;
import '../../features/local_agent/infrastructure/repositories/json_medical_knowledge_repository.dart'
    as _i71;
import '../../features/local_agent/infrastructure/services/isar_vector_store_service.dart'
<<<<<<< HEAD
    as _i134;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i190;
=======
    as _i132;
import '../../features/local_agent/infrastructure/services/llm_adapter_factory.dart'
    as _i189;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/local_agent/infrastructure/services/local_llm_service.dart'
    as _i67;
import '../../features/local_agent/infrastructure/services/medical_indexing_service.dart'
    as _i271;
import '../../features/local_agent/infrastructure/services/model_download_service.dart'
    as _i85;
import '../../features/local_agent/infrastructure/services/patient_context_indexer.dart'
    as _i258;
import '../../features/medical_research/application/medical_research_cubit.dart'
    as _i272;
import '../../features/medical_research/domain/repositories/medical_research_repository.dart'
    as _i254;
import '../../features/medical_research/domain/services/medical_scraper_service.dart'
    as _i73;
import '../../features/medical_research/domain/services/medical_standards_service.dart'
    as _i75;
import '../../features/medical_research/domain/services/medical_web_search_service.dart'
    as _i77;
import '../../features/medical_research/domain/usecases/get_research_history.dart'
    as _i269;
import '../../features/medical_research/domain/usecases/search_medical_research.dart'
    as _i261;
import '../../features/medical_research/infrastructure/bot_bypass_handler.dart'
    as _i18;
import '../../features/medical_research/infrastructure/medical_research_service.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i196;
=======
    as _i198;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
    as _i195;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/medical_research/infrastructure/medical_scraper_service_impl.dart'
    as _i74;
import '../../features/medical_research/infrastructure/medical_standards_service_impl.dart'
    as _i76;
import '../../features/medical_research/infrastructure/medical_web_search_service_impl.dart'
    as _i78;
import '../../features/medical_research/infrastructure/repositories/medical_research_repository_impl.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i255;
import '../../features/medications/application/bloc/medication_bloc.dart'
    as _i256;
import '../../features/medications/application/medications_cubit.dart' as _i199;
import '../../features/medications/domain/repositories/medication_adherence_repository.dart'
    as _i79;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i197;
=======
    as _i254;
import '../../features/medications/application/bloc/medication_bloc.dart'
    as _i255;
import '../../features/medications/application/medications_cubit.dart' as _i201;
import '../../features/medications/domain/repositories/medication_adherence_repository.dart'
    as _i79;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i199;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
    as _i254;
import '../../features/medications/application/bloc/medication_bloc.dart'
    as _i255;
import '../../features/medications/application/medications_cubit.dart' as _i198;
import '../../features/medications/domain/repositories/medication_adherence_repository.dart'
    as _i79;
import '../../features/medications/domain/repositories/medication_repository.dart'
    as _i196;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/medications/domain/usecases/get_all_medications_usecase.dart'
    as _i242;
import '../../features/medications/domain/usecases/save_medication_usecase.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i208;
import '../../features/medications/infrastructure/datasources/adherence_sqlite_datasource.dart'
    as _i5;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i198;
=======
    as _i210;
import '../../features/medications/infrastructure/datasources/adherence_sqlite_datasource.dart'
    as _i5;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i200;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
    as _i207;
import '../../features/medications/infrastructure/datasources/adherence_sqlite_datasource.dart'
    as _i5;
import '../../features/medications/infrastructure/repositories/isar_medication_repository.dart'
    as _i197;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/medications/infrastructure/repositories/sqlite_medication_adherence_repository.dart'
    as _i80;
import '../../features/medications/infrastructure/services/pharmacy_api_service.dart'
    as _i101;
import '../../features/medications/infrastructure/services/rxnorm_api_service.dart'
    as _i102;
<<<<<<< HEAD
<<<<<<< HEAD
import '../../features/meditation/application/meditation_cubit.dart' as _i200;
=======
import '../../features/meditation/application/meditation_cubit.dart' as _i199;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i82;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i151;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i175;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i177;
<<<<<<< HEAD
=======
import '../../features/meditation/application/meditation_cubit.dart' as _i202;
import '../../features/meditation/domain/repositories/meditation_repository.dart'
    as _i82;
import '../../features/meditation/domain/usecases/complete_session_usecase.dart'
    as _i153;
import '../../features/meditation/domain/usecases/get_progress_usecase.dart'
    as _i178;
import '../../features/meditation/domain/usecases/get_scripts_usecase.dart'
    as _i180;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/meditation/domain/usecases/recommend_script_usecase.dart'
    as _i106;
import '../../features/meditation/domain/usecases/start_session_usecase.dart'
    as _i123;
import '../../features/meditation/infrastructure/datasources/meditation_local_datasource.dart'
    as _i81;
import '../../features/meditation/infrastructure/repositories/meditation_repository_impl.dart'
    as _i83;
<<<<<<< HEAD
<<<<<<< HEAD
import '../../features/network/application/network_cubit.dart' as _i201;
=======
import '../../features/network/application/network_cubit.dart' as _i200;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/network/domain/repositories/network_peer_repository.dart'
    as _i88;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i180;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i179;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i181;
<<<<<<< HEAD
=======
import '../../features/network/application/network_cubit.dart' as _i203;
import '../../features/network/domain/repositories/network_peer_repository.dart'
    as _i88;
import '../../features/network/governance/domain/repositories/governance_repository.dart'
    as _i183;
import '../../features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart'
    as _i182;
import '../../features/network/governance/infrastructure/repositories/governance_repository_impl.dart'
    as _i184;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/network/incentives/domain/repositories/incentive_repository.dart'
    as _i58;
import '../../features/network/incentives/infrastructure/datasources/incentive_datasource.dart'
    as _i57;
import '../../features/network/incentives/infrastructure/repositories/incentive_repository_impl.dart'
    as _i59;
import '../../features/network/infrastructure/datasources/network_p2p_api.dart'
    as _i87;
import '../../features/network/infrastructure/repositories/network_peer_repository_impl.dart'
    as _i89;
import '../../features/network/network_health/application/network_health_cubit.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i202;
=======
    as _i201;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/network/network_health/domain/repositories/network_repository.dart'
    as _i90;
import '../../features/network/network_health/domain/usecases/connect_node.dart'
    as _i152;
import '../../features/network/network_health/domain/usecases/get_network_health.dart'
    as _i173;
import '../../features/network/network_health/domain/usecases/get_node_stats.dart'
    as _i174;
<<<<<<< HEAD
=======
    as _i204;
import '../../features/network/network_health/domain/repositories/network_repository.dart'
    as _i90;
import '../../features/network/network_health/domain/usecases/connect_node.dart'
    as _i154;
import '../../features/network/network_health/domain/usecases/get_network_health.dart'
    as _i176;
import '../../features/network/network_health/domain/usecases/get_node_stats.dart'
    as _i177;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/network/network_health/infrastructure/datasources/network_datasource.dart'
    as _i86;
import '../../features/network/network_health/infrastructure/repositories/network_repository_impl.dart'
    as _i91;
<<<<<<< HEAD
<<<<<<< HEAD
import '../../features/onboarding/application/onboarding_cubit.dart' as _i257;
import '../../features/onboarding/application/sync_cubit.dart' as _i218;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i203;
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart'
    as _i233;
import '../../features/onboarding/domain/usecases/get_onboarding_profile_usecase.dart'
    as _i246;
import '../../features/onboarding/infrastructure/repositories/onboarding_repository_impl.dart'
    as _i204;
import '../../features/reports/application/bloc/report_bloc.dart' as _i259;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i107;
import '../../features/reports/domain/services/report_generation_service.dart'
    as _i205;
import '../../features/reports/domain/usecases/get_reports_usecase.dart'
    as _i176;
=======
import '../../features/onboarding/application/onboarding_cubit.dart' as _i256;
import '../../features/onboarding/application/sync_cubit.dart' as _i220;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i205;
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart'
    as _i233;
import '../../features/onboarding/domain/usecases/get_onboarding_profile_usecase.dart'
    as _i245;
import '../../features/onboarding/infrastructure/repositories/onboarding_repository_impl.dart'
    as _i206;
=======
import '../../features/onboarding/application/onboarding_cubit.dart' as _i256;
import '../../features/onboarding/application/sync_cubit.dart' as _i217;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i202;
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart'
    as _i232;
import '../../features/onboarding/domain/usecases/get_onboarding_profile_usecase.dart'
    as _i245;
import '../../features/onboarding/infrastructure/repositories/onboarding_repository_impl.dart'
    as _i203;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/reports/application/bloc/report_bloc.dart' as _i258;
import '../../features/reports/domain/repositories/report_repository.dart'
    as _i107;
import '../../features/reports/domain/services/report_generation_service.dart'
<<<<<<< HEAD
    as _i207;
import '../../features/reports/domain/usecases/get_reports_usecase.dart'
    as _i179;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
    as _i204;
import '../../features/reports/domain/usecases/get_reports_usecase.dart'
    as _i176;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/reports/domain/usecases/save_report_usecase.dart'
    as _i111;
import '../../features/reports/infrastructure/repositories/isar_report_repository.dart'
    as _i108;
import '../../features/reports/infrastructure/services/gemma_report_generation_service.dart'
<<<<<<< HEAD
<<<<<<< HEAD
    as _i206;
=======
    as _i208;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i84;
import '../../features/settings/application/llm_settings_cubit.dart' as _i193;
=======
    as _i205;
import '../../features/reports/infrastructure/services/mock_report_generation_service.dart'
    as _i84;
import '../../features/settings/application/llm_settings_cubit.dart' as _i192;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i119;
import '../../features/settings/domain/services/device_capability_service.dart'
    as _i29;
import '../../features/settings/infrastructure/datasources/settings_local_datasource.dart'
    as _i118;
import '../../features/settings/infrastructure/repositories/settings_repository_impl.dart'
    as _i120;
<<<<<<< HEAD
import '../../features/sync/application/sync_cubit.dart' as _i241;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i125;
import '../../features/sync/domain/services/distributed_storage_service.dart'
<<<<<<< HEAD
    as _i156;
import '../../features/sync/domain/services/node_discovery_service.dart'
    as _i95;
import '../../features/sync/domain/services/sync_service.dart' as _i219;
=======
    as _i158;
import '../../features/sync/domain/services/node_discovery_service.dart'
    as _i95;
import '../../features/sync/domain/services/sync_service.dart' as _i127;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i238;
=======
import '../../features/sync/application/sync_cubit.dart' as _i240;
import '../../features/sync/domain/repositories/sync_repository.dart' as _i125;
import '../../features/sync/domain/services/distributed_storage_service.dart'
    as _i156;
import '../../features/sync/domain/services/node_discovery_service.dart'
    as _i95;
import '../../features/sync/domain/services/sync_service.dart' as _i218;
import '../../features/sync/domain/usecases/distributed_cache_usecase.dart'
    as _i237;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/sync/infrastructure/datasources/filecoin_datasource.dart'
    as _i38;
import '../../features/sync/infrastructure/datasources/ipfs_datasource.dart'
    as _i60;
import '../../features/sync/infrastructure/repositories/sync_repository_impl.dart'
    as _i126;
import '../../features/sync/infrastructure/services/fhir_client.dart' as _i36;
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i157;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i96;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
<<<<<<< HEAD
=======
    as _i219;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
    as _i220;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i221;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i127;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i128;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i130;
import '../../features/user_profile/domain/usecases/get_user_profile_usecase.dart'
    as _i178;
import '../../features/user_profile/domain/usecases/save_user_profile_usecase.dart'
<<<<<<< HEAD
    as _i210;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i129;
import '../../features/vitals/application/bloc/vital_sign_bloc.dart' as _i223;
=======
    as _i209;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i129;
import '../../features/vitals/application/bloc/vital_sign_bloc.dart' as _i222;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/vitals/application/vitals_cubit.dart' as _i135;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i133;
import '../../features/vitals/domain/usecases/get_all_vital_signs_usecase.dart'
    as _i167;
import '../../features/vitals/domain/usecases/save_vital_signs_usecase.dart'
<<<<<<< HEAD
    as _i211;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i134;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i224;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i136;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i168;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i213;
=======
    as _i210;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i134;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i223;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i136;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i169;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i212;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i25;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i137;
<<<<<<< HEAD
=======
import '../../features/sync/infrastructure/services/ipfs_service.dart' as _i159;
import '../../features/sync/infrastructure/services/node_discovery_service.dart'
    as _i96;
import '../../features/sync/infrastructure/services/sync_service_impl.dart'
    as _i128;
import '../../features/user_profile/application/bloc/user_profile_cubit.dart'
    as _i221;
import '../../features/user_profile/data/datasources/user_profile_local_datasource.dart'
    as _i129;
import '../../features/user_profile/domain/repositories/user_profile_repository.dart'
    as _i130;
import '../../features/user_profile/domain/services/user_profile_service.dart'
    as _i132;
import '../../features/user_profile/domain/usecases/get_user_profile_usecase.dart'
    as _i181;
import '../../features/user_profile/domain/usecases/save_user_profile_usecase.dart'
    as _i212;
import '../../features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart'
    as _i131;
import '../../features/vitals/application/bloc/vital_sign_bloc.dart' as _i223;
import '../../features/vitals/application/vitals_cubit.dart' as _i137;
import '../../features/vitals/domain/repositories/vital_sign_repository.dart'
    as _i135;
import '../../features/vitals/domain/usecases/get_all_vital_signs_usecase.dart'
    as _i170;
import '../../features/vitals/domain/usecases/save_vital_signs_usecase.dart'
    as _i213;
import '../../features/vitals/infrastructure/repositories/vital_sign_repository_impl.dart'
    as _i136;
import '../../features/voice_chat/application/voice_chat_cubit.dart' as _i224;
import '../../features/voice_chat/domain/repositories/voice_chat_repository.dart'
    as _i138;
import '../../features/voice_chat/domain/usecases/get_chat_history_usecase.dart'
    as _i171;
import '../../features/voice_chat/domain/usecases/send_message_usecase.dart'
    as _i215;
import '../../features/voice_chat/infrastructure/datasources/chat_ai_datasource.dart'
    as _i25;
import '../../features/voice_chat/infrastructure/repositories/voice_chat_repository_impl.dart'
    as _i139;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../logging/audit_logger.dart' as _i15;
import '../services/aicore_service.dart' as _i3;
import '../services/asr/asr_service.dart' as _i11;
import '../services/audio/audio_player_service.dart' as _i12;
import '../services/audio/audio_recorder_service.dart' as _i14;
<<<<<<< HEAD
<<<<<<< HEAD
import '../services/device_capability_service.dart' as _i30;
=======
import '../services/device_capability_service.dart' as _i29;
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
import '../services/device_capability_service.dart' as _i30;
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
import '../services/privacy_anonymizer.dart' as _i103;
import '../services/secure_storage_service.dart' as _i114;
import '../utils/health_wrapper.dart' as _i50;
import 'database_module.dart' as _i276;
import 'fhir_module.dart' as _i277;
import 'memory_module.dart' as _i275;
import 'network_module.dart' as _i274;
import 'service_module.dart' as _i273;

const String _desktop = 'desktop';
const String _test = 'test';
const String _mobile = 'mobile';

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final serviceModule = _$ServiceModule();
    final networkModule = _$NetworkModule();
    final memoryModule = _$MemoryModule();
    final databaseModule = _$DatabaseModule();
    final fhirModule = _$FhirModule();
    gh.lazySingleton<_i3.AIService>(() => _i3.AIService());
    gh.lazySingleton<_i4.AboutLocalDataSource>(
        () => _i4.AboutLocalDataSource());
    gh.lazySingleton<_i5.AdherenceSqliteDatasource>(
        () => _i5.AdherenceSqliteDatasource());
    gh.lazySingleton<_i3.AgentMemoryService>(() => _i3.AgentMemoryService());
    gh.lazySingleton<_i6.AllergyService>(() => _i6.AllergyService());
    gh.factory<_i7.AppointmentBloc>(
        () => _i7.AppointmentBloc(gh<_i8.AppointmentRepository>()));
    gh.lazySingleton<_i9.AppointmentService>(() => _i9.AppointmentService());
    gh.factory<_i10.AppointmentsCubit>(
        () => _i10.AppointmentsCubit(gh<_i8.AppointmentRepository>()));
    gh.lazySingleton<_i11.AsrService>(() => _i11.AsrService());
    gh.lazySingleton<_i12.AudioService>(() => _i12.AudioService(
          player: gh<_i13.AudioPlayer>(),
          recorder: gh<_i14.AudioRecorderService>(),
        ));
    gh.lazySingleton<_i15.AuditLogger>(() => _i15.AuditLogger());
    gh.lazySingleton<_i16.BiometricService>(() => _i16.BiometricService());
    gh.lazySingleton<_i17.BleWrapper>(() => _i17.BleWrapper());
    gh.lazySingleton<_i18.BotBypassHandler>(() => _i18.BotBypassHandler());
    gh.factory<_i19.CalendarApiDatasource>(() => _i19.CalendarApiDatasource(
        deviceCalendarPlugin: gh<_i20.DeviceCalendarPlugin>()));
    gh.lazySingleton<_i21.CalendarImportRepository>(() =>
        _i22.CalendarImportRepositoryImpl(gh<_i19.CalendarApiDatasource>()));
    gh.lazySingleton<_i23.CalendarParserService>(
        () => _i24.CalendarParserServiceImpl());
    gh.lazySingleton<_i25.ChatAiDatasource>(() => _i25.ChatAiDatasource(
          gh<_i3.AIService>(),
          gh<_i11.AsrService>(),
          gh<_i3.AgentMemoryService>(),
        ));
    gh.lazySingleton<_i26.Client>(() => serviceModule.httpClient);
    gh.lazySingleton<_i27.DashboardRemoteDataSource>(
        () => _i27.DashboardRemoteDataSourceImpl());
    gh.factory<_i28.DeleteAppointmentUseCase>(
        () => _i28.DeleteAppointmentUseCase(gh<_i8.AppointmentRepository>()));
    gh.lazySingleton<_i29.DeviceCapabilityService>(
        () => _i29.DeviceCapabilityService());
    gh.lazySingleton<_i30.DeviceCapabilityService>(
        () => _i30.DeviceCapabilityService());
    gh.lazySingleton<_i31.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i32.EmailRepository>(() => _i33.EmailRepositoryImpl(
          gh<_i26.Client>(),
          gh<_i20.DeviceCalendarPlugin>(),
        ));
    gh.lazySingleton<_i34.EmbeddingsAdapter>(
        () => memoryModule.embeddingsAdapter);
    gh.lazySingleton<_i35.EncryptionService>(
        () => databaseModule.walletEncryptionService);
    gh.lazySingleton<_i36.FhirClient>(() => fhirModule.fhirClient);
    gh.lazySingleton<_i37.FilePickerService>(
        () => _i37.FilePickerServiceImpl());
    gh.lazySingleton<_i38.FilecoinDatasource>(() => _i38.FilecoinDatasource());
    gh.lazySingleton<_i39.FlutterAppAuth>(() => serviceModule.appAuth);
    gh.lazySingleton<_i40.FlutterGemmaWrapper>(
        () => _i40.FlutterGemmaWrapper());
    gh.lazySingleton<_i41.FlutterSecureStorage>(() => serviceModule.storage);
    gh.lazySingleton<_i42.GeminiModelWrapper>(
        () => _i42.GeminiModelWrapper(gh<_i43.GenerativeModel>()));
    gh.factory<_i44.GetAllAppointmentsUseCase>(
        () => _i44.GetAllAppointmentsUseCase(gh<_i8.AppointmentRepository>()));
    gh.lazySingleton<_i45.Health>(() => serviceModule.health);
    gh.lazySingleton<_i46.HealthDataImportService>(
        () => _i46.HealthDataImportService());
    gh.lazySingleton<_i47.HealthSharingLocalDataSource>(
        () => _i47.HealthSharingLocalDataSource());
    gh.lazySingleton<_i48.HealthSharingRemoteDataSource>(
        () => _i48.HealthSharingRemoteDataSource(gh<_i31.Dio>()));
    gh.factory<_i49.HealthSummaryDatasource>(
        () => _i49.HealthSummaryDatasource());
    gh.lazySingleton<_i50.HealthWrapper>(() => serviceModule.healthWrapper);
    gh.factory<_i51.HomeLocalDataSource>(
        () => _i51.HomeLocalDataSource(gh<_i52.SharedPreferences>()));
    gh.factory<_i53.HomeRemoteDataSource>(
        () => _i53.HomeRemoteDataSource(gh<_i31.Dio>()));
    gh.lazySingleton<_i54.IAboutRepository>(
        () => _i55.AboutRepositoryImpl(gh<_i4.AboutLocalDataSource>()));
    gh.lazySingleton<_i56.ImagePickerService>(
        () => _i56.ImagePickerServiceImpl());
    gh.lazySingleton<_i57.IncentiveDatasource>(
        () => _i57.IncentiveDatasource());
    gh.lazySingleton<_i58.IncentiveRepository>(
        () => _i59.IncentiveRepositoryImpl(gh<_i57.IncentiveDatasource>()));
    gh.lazySingleton<_i60.IpfsDatasource>(
        () => _i60.IpfsDatasource(gh<_i31.Dio>()));
    await gh.factoryAsync<_i61.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingletonAsync<_i62.LicenseRegistryLocalDataSource>(() {
      final i = _i62.LicenseRegistryLocalDataSource(gh<_i61.Isar>());
      return i.load().then((_) => i);
    });
    gh.lazySingletonAsync<_i63.LicenseVerifier>(() async =>
        _i63.LicenseVerifier(
            await getAsync<_i62.LicenseRegistryLocalDataSource>()));
    gh.lazySingleton<_i64.LlmAdapter>(
      () => _i65.OpenaiCompatibleAdapter(),
      instanceName: 'openai',
    );
    gh.lazySingleton<_i64.LlmAdapter>(
      () => _i66.FlutterGemmaAdapter(wrapper: gh<_i40.FlutterGemmaWrapper>()),
      instanceName: 'gemma',
    );
    gh.lazySingleton<_i67.LocalLlmService>(() => _i67.LocalLlmService());
    gh.lazySingleton<_i68.LocalModelLocalDataSource>(
        () => _i68.LocalModelLocalDataSource());
    gh.lazySingleton<_i69.MedicalContextProvider>(
        () => networkModule.medicalContextProvider);
<<<<<<< HEAD
    gh.factory<_i70.MedicalKnowledgeRepository>(
<<<<<<< HEAD
      () => _i71.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
    gh.factory<_i70.MedicalKnowledgeRepository>(
      () => _i72.JsonMedicalKnowledgeRepository(),
=======
      () => _i71.JsonMedicalKnowledgeRepository(),
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
    gh.factory<_i70.MedicalKnowledgeRepository>(
      () => _i71.JsonMedicalKnowledgeRepository(),
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
      registerFor: {
        _desktop,
        _test,
      },
    );
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
    gh.factory<_i70.MedicalKnowledgeRepository>(
      () => _i72.AssetMedicalKnowledgeRepository(),
      registerFor: {_mobile},
    );
<<<<<<< HEAD
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
    gh.lazySingleton<_i73.MedicalScraperService>(
        () => _i74.MedicalScraperServiceImpl(
              gh<_i31.Dio>(),
              gh<_i18.BotBypassHandler>(),
            ));
    gh.lazySingleton<_i75.MedicalStandardsService>(() =>
        _i76.MedicalStandardsServiceImpl(gh<_i69.MedicalContextProvider>()));
    gh.lazySingleton<_i77.MedicalWebSearchService>(
        () => _i78.MedicalWebSearchServiceImpl(gh<_i31.Dio>()));
    gh.lazySingleton<_i79.MedicationAdherenceRepository>(() =>
        _i80.SqliteMedicationAdherenceRepository(
            gh<_i5.AdherenceSqliteDatasource>()));
    gh.lazySingleton<_i81.MeditationLocalDataSource>(
        () => _i81.MeditationLocalDataSource());
    gh.lazySingleton<_i82.MeditationRepository>(() =>
        _i83.MeditationRepositoryImpl(gh<_i81.MeditationLocalDataSource>()));
    await gh.lazySingletonAsync<_i34.MemoryGraph>(
      () => memoryModule.memoryGraph(
        gh<_i61.Isar>(),
        gh<_i34.EmbeddingsAdapter>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i84.MockReportGenerationService>(
      () => _i84.MockReportGenerationService(),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i85.ModelDownloadService>(
        () => _i85.ModelDownloadService());
    gh.lazySingleton<_i86.NetworkDatasource>(
        () => _i86.NetworkDatasourceImpl(gh<_i31.Dio>()));
    gh.lazySingleton<_i87.NetworkP2PApi>(() => _i87.NetworkP2PApiImpl());
    gh.lazySingleton<_i88.NetworkPeerRepository>(
        () => _i89.NetworkPeerRepositoryImpl(gh<_i61.Isar>()));
    gh.lazySingleton<_i90.NetworkRepository>(
        () => _i91.NetworkRepositoryImpl(gh<_i86.NetworkDatasource>()));
    gh.lazySingleton<_i92.NfcHandler>(
        () => _i92.NfcHandler(channel: gh<_i93.MethodChannel>()));
    gh.lazySingleton<_i94.NfcSharingService>(
        () => _i94.NfcSharingService(gh<_i92.NfcHandler>()));
    gh.lazySingleton<_i95.NodeDiscoveryService>(
        () => _i96.NodeDiscoveryService());
    gh.lazySingleton<_i97.OAuthLocalDataSource>(
        () => _i97.OAuthLocalDataSource(gh<_i41.FlutterSecureStorage>()));
    gh.lazySingleton<_i98.OAuthRepository>(() => _i99.OAuthRepositoryImpl(
          gh<_i97.OAuthLocalDataSource>(),
          gh<_i31.Dio>(),
          gh<_i39.FlutterAppAuth>(),
        ));
    gh.lazySingleton<_i100.OcrService>(() => _i100.MlKitOcrService());
    gh.lazySingleton<_i101.PharmacyApiService>(
        () => _i102.RxNormApiService(gh<_i31.Dio>()));
    gh.lazySingleton<_i103.PromptScrubber>(
        () => _i103.PromptScrubber(gh<_i61.Isar>()));
    gh.lazySingleton<_i104.RatingRepository>(
        () => _i105.IsarRatingRepository(gh<_i61.Isar>()));
    gh.lazySingleton<_i106.RecommendScriptUseCase>(
        () => _i106.RecommendScriptUseCase(gh<_i82.MeditationRepository>()));
    gh.lazySingleton<_i107.ReportRepository>(
        () => _i108.IsarReportRepository(gh<_i61.Isar>()));
    gh.factory<_i109.RequestHealthAuthUseCase>(() =>
        _i109.RequestHealthAuthUseCase(gh<_i46.HealthDataImportService>()));
    gh.factory<_i110.SaveAppointmentUseCase>(
        () => _i110.SaveAppointmentUseCase(gh<_i8.AppointmentRepository>()));
    gh.factory<_i111.SaveReportUseCase>(
        () => _i111.SaveReportUseCase(gh<_i107.ReportRepository>()));
    gh.lazySingleton<_i112.SecondOpinionRepository>(
        () => _i113.IsarSecondOpinionRepository(gh<_i61.Isar>()));
    gh.lazySingleton<_i114.SecureStorageService>(() =>
        _i114.SecureStorageServiceImpl(
            storage: gh<_i41.FlutterSecureStorage>()));
    gh.factory<_i115.SendChatMessageUseCase>(() => _i115.SendChatMessageUseCase(
          gh<_i64.LlmAdapter>(),
          gh<_i70.MedicalKnowledgeRepository>(),
        ));
    gh.lazySingleton<_i116.SensorApiDataSource>(
        () => _i116.SensorApiDataSourceImpl(gh<_i50.HealthWrapper>()));
    gh.lazySingleton<_i117.SensorHealthDataSource>(
        () => _i117.SensorHealthDataSourceImpl());
    gh.lazySingleton<_i118.SettingsLocalDataSource>(
        () => _i118.SettingsLocalDataSource(gh<_i61.Isar>()));
    gh.lazySingleton<_i119.SettingsRepository>(() =>
        _i120.SettingsRepositoryImpl(gh<_i118.SettingsLocalDataSource>()));
    gh.lazySingleton<_i121.SharingRepository>(() =>
        _i122.HealthSharingRepositoryImpl(
            gh<_i47.HealthSharingLocalDataSource>()));
    gh.lazySingleton<_i123.StartSessionUseCase>(
        () => _i123.StartSessionUseCase(gh<_i82.MeditationRepository>()));
    gh.factory<_i124.SyncEmailAppointmentsUseCase>(
        () => _i124.SyncEmailAppointmentsUseCase(gh<_i32.EmailRepository>()));
    gh.lazySingleton<_i125.SyncRepository>(() => _i126.SyncRepositoryImpl(
          gh<_i36.FhirClient>(),
          gh<_i61.Isar>(),
          gh<_i41.FlutterSecureStorage>(),
          gh<_i95.NodeDiscoveryService>(),
        ));
    gh.lazySingleton<_i69.SyncService>(() => networkModule.syncService);
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
    gh.lazySingleton<_i127.UserProfileLocalDataSource>(
        () => _i127.UserProfileLocalDataSource(gh<_i61.Isar>()));
    gh.lazySingleton<_i128.UserProfileRepository>(
        () => _i129.UserProfileRepositoryImpl(gh<_i61.Isar>()));
    gh.lazySingleton<_i130.UserProfileService>(
        () => _i130.UserProfileService(gh<_i128.UserProfileRepository>()));
    gh.lazySingleton<_i131.VectorStoreService>(
        () => _i132.IsarVectorStoreService(
<<<<<<< HEAD
              gh<_i34.MemoryGraph>(),
              gh<_i70.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i133.VitalSignRepository>(
        () => _i134.VitalSignRepositoryImpl(gh<_i61.Isar>()));
    gh.factory<_i135.VitalsCubit>(
        () => _i135.VitalsCubit(gh<_i133.VitalSignRepository>()));
    gh.lazySingleton<_i136.VoiceChatRepository>(
        () => _i137.VoiceChatRepositoryImpl(gh<_i25.ChatAiDatasource>()));
    gh.lazySingleton<_i138.VouchRepository>(
        () => _i139.IsarVouchRepository(gh<_i61.Isar>()));
=======
    gh.lazySingleton<_i127.SyncService>(() => _i128.SyncServiceImpl(
          gh<_i125.SyncRepository>(),
          gh<_i69.SyncService>(),
        ));
    gh.lazySingleton<_i129.UserProfileLocalDataSource>(
        () => _i129.UserProfileLocalDataSource(gh<_i61.Isar>()));
    gh.lazySingleton<_i130.UserProfileRepository>(
        () => _i131.UserProfileRepositoryImpl(gh<_i61.Isar>()));
    gh.lazySingleton<_i132.UserProfileService>(
        () => _i132.UserProfileService(gh<_i130.UserProfileRepository>()));
    gh.lazySingleton<_i133.VectorStoreService>(
        () => _i134.IsarVectorStoreService(
              gh<_i34.MemoryGraph>(),
              gh<_i70.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i135.VitalSignRepository>(
        () => _i136.VitalSignRepositoryImpl(gh<_i61.Isar>()));
    gh.factory<_i137.VitalsCubit>(
        () => _i137.VitalsCubit(gh<_i135.VitalSignRepository>()));
    gh.lazySingleton<_i138.VoiceChatRepository>(
        () => _i139.VoiceChatRepositoryImpl(gh<_i25.ChatAiDatasource>()));
    gh.lazySingleton<_i140.VouchRepository>(
        () => _i141.IsarVouchRepository(gh<_i61.Isar>()));
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
              gh<_i34.MemoryGraph>(),
              gh<_i70.MedicalKnowledgeRepository>(),
            ));
    gh.lazySingleton<_i133.VitalSignRepository>(
        () => _i134.VitalSignRepositoryImpl(gh<_i61.Isar>()));
    gh.factory<_i135.VitalsCubit>(
        () => _i135.VitalsCubit(gh<_i133.VitalSignRepository>()));
    gh.lazySingleton<_i136.VoiceChatRepository>(
        () => _i137.VoiceChatRepositoryImpl(gh<_i25.ChatAiDatasource>()));
    gh.lazySingleton<_i138.VouchRepository>(
        () => _i139.IsarVouchRepository(gh<_i61.Isar>()));
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
    gh.lazySingleton<_i35.WalletService>(() => databaseModule.walletService(
          gh<_i61.Isar>(),
          gh<_i35.EncryptionService>(),
        ));
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
    gh.lazySingleton<_i140.WifiDirectService>(() => _i140.WifiDirectService());
    gh.factory<_i141.AboutCubit>(
        () => _i141.AboutCubit(gh<_i54.IAboutRepository>()));
    gh.lazySingleton<_i142.AboutRemoteDataSource>(
        () => _i142.AboutRemoteDataSource(gh<_i31.Dio>()));
    gh.lazySingleton<_i143.AllergyLocalDataSource>(
        () => _i143.AllergyLocalDataSource(gh<_i61.Isar>()));
    gh.lazySingleton<_i144.AuthLocalDataSource>(
        () => _i144.AuthLocalDataSource(gh<_i61.Isar>()));
    gh.lazySingleton<_i145.AuthRepository>(() => _i146.AuthRepositoryImpl(
          gh<_i144.AuthLocalDataSource>(),
<<<<<<< HEAD
          gh<_i114.SecureStorageService>(),
        ));
    gh.lazySingleton<_i147.BleSharingService>(
        () => _i147.BleSharingService(gh<_i17.BleWrapper>()));
    gh.lazySingleton<_i148.CancelSharingUseCase>(
        () => _i148.CancelSharingUseCase(
              gh<_i147.BleSharingService>(),
              gh<_i94.NfcSharingService>(),
              gh<_i140.WifiDirectService>(),
            ));
    gh.lazySingleton<_i149.ChatMessageLocalDataSource>(
        () => _i149.ChatMessageLocalDataSource(gh<_i61.Isar>()));
    gh.factory<_i150.CheckSessionTimeoutUseCase>(
        () => _i150.CheckSessionTimeoutUseCase(gh<_i145.AuthRepository>()));
    gh.lazySingleton<_i151.CompleteSessionUseCase>(
        () => _i151.CompleteSessionUseCase(gh<_i82.MeditationRepository>()));
=======
    gh.lazySingleton<_i142.WifiDirectService>(() => _i142.WifiDirectService());
    gh.factory<_i143.AboutCubit>(
        () => _i143.AboutCubit(gh<_i54.IAboutRepository>()));
    gh.lazySingleton<_i144.AboutRemoteDataSource>(
        () => _i144.AboutRemoteDataSource(gh<_i31.Dio>()));
    gh.lazySingleton<_i145.AllergyLocalDataSource>(
        () => _i145.AllergyLocalDataSource(gh<_i61.Isar>()));
    gh.lazySingleton<_i146.AuthLocalDataSource>(
        () => _i146.AuthLocalDataSource(gh<_i61.Isar>()));
    gh.lazySingleton<_i147.AuthRepository>(() => _i148.AuthRepositoryImpl(
          gh<_i146.AuthLocalDataSource>(),
          gh<_i114.SecureStorageService>(),
        ));
    gh.lazySingleton<_i149.BleSharingService>(
        () => _i149.BleSharingService(gh<_i17.BleWrapper>()));
    gh.lazySingleton<_i150.CancelSharingUseCase>(
        () => _i150.CancelSharingUseCase(
              gh<_i149.BleSharingService>(),
              gh<_i94.NfcSharingService>(),
              gh<_i142.WifiDirectService>(),
            ));
    gh.lazySingleton<_i151.ChatMessageLocalDataSource>(
        () => _i151.ChatMessageLocalDataSource(gh<_i61.Isar>()));
    gh.factory<_i152.CheckSessionTimeoutUseCase>(
        () => _i152.CheckSessionTimeoutUseCase(gh<_i147.AuthRepository>()));
    gh.lazySingleton<_i153.CompleteSessionUseCase>(
        () => _i153.CompleteSessionUseCase(gh<_i82.MeditationRepository>()));
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
          gh<_i114.SecureStorageService>(),
        ));
    gh.lazySingleton<_i147.BleSharingService>(
        () => _i147.BleSharingService(gh<_i17.BleWrapper>()));
    gh.lazySingleton<_i148.CancelSharingUseCase>(
        () => _i148.CancelSharingUseCase(
              gh<_i147.BleSharingService>(),
              gh<_i94.NfcSharingService>(),
              gh<_i140.WifiDirectService>(),
            ));
    gh.lazySingleton<_i149.ChatMessageLocalDataSource>(
        () => _i149.ChatMessageLocalDataSource(gh<_i61.Isar>()));
    gh.factory<_i150.CheckSessionTimeoutUseCase>(
        () => _i150.CheckSessionTimeoutUseCase(gh<_i145.AuthRepository>()));
    gh.lazySingleton<_i151.CompleteSessionUseCase>(
        () => _i151.CompleteSessionUseCase(gh<_i82.MeditationRepository>()));
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
    gh.factory<_i124.ConnectEmailProviderUseCase>(
        () => _i124.ConnectEmailProviderUseCase(gh<_i32.EmailRepository>()));
    gh.lazySingleton<_i152.ConnectNode>(
        () => _i152.ConnectNode(gh<_i90.NetworkRepository>()));
    gh.factory<_i153.ConnectProviderUseCase>(() => _i153.ConnectProviderUseCase(
          gh<_i98.OAuthRepository>(),
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
          gh<_i128.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i154.DashboardLocalDataSource>(
        () => _i154.DashboardLocalDataSource(gh<_i61.Isar>()));
    gh.factory<_i155.DisconnectProviderUseCase>(
        () => _i155.DisconnectProviderUseCase(
<<<<<<< HEAD
              gh<_i98.OAuthRepository>(),
              gh<_i128.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i156.DistributedStorageService>(() => _i157.IpfsService(
          gh<_i60.IpfsDatasource>(),
          gh<_i38.FilecoinDatasource>(),
        ));
    gh.lazySingleton<_i158.DoctorProfileRepository>(
        () => _i159.IsarDoctorProfileRepository(gh<_i61.Isar>()));
    gh.factoryAsync<_i160.DoctorVerificationCubit>(
        () async => _i160.DoctorVerificationCubit(
              gh<_i158.DoctorProfileRepository>(),
              gh<_i104.RatingRepository>(),
              await getAsync<_i63.LicenseVerifier>(),
            ));
    gh.factory<_i161.EmailCitasBloc>(() => _i161.EmailCitasBloc(
=======
          gh<_i130.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i156.DashboardLocalDataSource>(
        () => _i156.DashboardLocalDataSource(gh<_i61.Isar>()));
    gh.factory<_i157.DisconnectProviderUseCase>(
        () => _i157.DisconnectProviderUseCase(
              gh<_i98.OAuthRepository>(),
              gh<_i130.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i158.DistributedStorageService>(() => _i159.IpfsService(
          gh<_i60.IpfsDatasource>(),
          gh<_i38.FilecoinDatasource>(),
        ));
    gh.lazySingleton<_i160.DoctorProfileRepository>(
        () => _i161.IsarDoctorProfileRepository(gh<_i61.Isar>()));
    gh.factoryAsync<_i162.DoctorVerificationCubit>(
        () async => _i162.DoctorVerificationCubit(
              gh<_i160.DoctorProfileRepository>(),
              gh<_i104.RatingRepository>(),
              await getAsync<_i63.LicenseVerifier>(),
            ));
    gh.factory<_i163.EmailCitasBloc>(() => _i163.EmailCitasBloc(
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
              gh<_i98.OAuthRepository>(),
              gh<_i128.UserProfileRepository>(),
            ));
    gh.lazySingleton<_i156.DistributedStorageService>(() => _i157.IpfsService(
          gh<_i60.IpfsDatasource>(),
          gh<_i38.FilecoinDatasource>(),
        ));
    gh.lazySingleton<_i158.DoctorProfileRepository>(
        () => _i159.IsarDoctorProfileRepository(gh<_i61.Isar>()));
    gh.factoryAsync<_i160.DoctorVerificationCubit>(
        () async => _i160.DoctorVerificationCubit(
              gh<_i158.DoctorProfileRepository>(),
              gh<_i104.RatingRepository>(),
              await getAsync<_i63.LicenseVerifier>(),
            ));
    gh.factory<_i161.EmailCitasBloc>(() => _i161.EmailCitasBloc(
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
          gh<_i124.ConnectEmailProviderUseCase>(),
          gh<_i124.SyncEmailAppointmentsUseCase>(),
          gh<_i32.EmailRepository>(),
          gh<_i8.AppointmentRepository>(),
        ));
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
    gh.factory<_i162.EmailCitasCubit>(() => _i162.EmailCitasCubit(
          gh<_i32.EmailRepository>(),
          gh<_i8.AppointmentRepository>(),
        ));
    gh.lazySingleton<_i163.EncryptionService>(
        () => _i163.EncryptionService(gh<_i114.SecureStorageService>()));
<<<<<<< HEAD
=======
    gh.factory<_i164.EmailCitasCubit>(() => _i164.EmailCitasCubit(
          gh<_i32.EmailRepository>(),
          gh<_i8.AppointmentRepository>(),
        ));
    gh.lazySingleton<_i165.EncryptionService>(
        () => _i165.EncryptionService(gh<_i114.SecureStorageService>()));
    gh.factory<_i166.FhirSyncCubit>(() => _i166.FhirSyncCubit(
          gh<_i127.SyncService>(),
          gh<_i95.NodeDiscoveryService>(),
        ));
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
    gh.lazySingleton<_i117.FileHealthDataSource>(
        () => _i117.FileHealthDataSourceImpl(
              gh<_i37.FilePickerService>(),
              gh<_i100.OcrService>(),
            ));
<<<<<<< HEAD
<<<<<<< HEAD
    gh.lazySingleton<_i164.FileImportDataSource>(
        () => _i164.FileImportDataSourceImpl(
              gh<_i37.FilePickerService>(),
              gh<_i100.OcrService>(),
            ));
    gh.factory<_i165.GetAboutInfoUseCase>(
        () => _i165.GetAboutInfoUseCase(gh<_i54.IAboutRepository>()));
    gh.factory<_i166.GetAllDoctorsUseCase>(
        () => _i166.GetAllDoctorsUseCase(gh<_i158.DoctorProfileRepository>()));
    gh.factory<_i167.GetAllVitalSignsUseCase>(
        () => _i167.GetAllVitalSignsUseCase(gh<_i133.VitalSignRepository>()));
    gh.factory<_i109.GetAvailableSourcesUseCase>(() =>
        _i109.GetAvailableSourcesUseCase(gh<_i46.HealthDataImportService>()));
    gh.factory<_i168.GetChatHistoryUseCase>(
        () => _i168.GetChatHistoryUseCase(gh<_i136.VoiceChatRepository>()));
    gh.factory<_i169.GetChatHistoryUseCase>(
        () => _i169.GetChatHistoryUseCase(gh<_i131.VectorStoreService>()));
    gh.factory<_i170.GetConnectionsUseCase>(
        () => _i170.GetConnectionsUseCase(gh<_i98.OAuthRepository>()));
    gh.factory<_i171.GetCredentialsUseCase>(
        () => _i171.GetCredentialsUseCase(gh<_i145.AuthRepository>()));
    gh.factory<_i172.GetDoctorProfileUseCase>(() =>
        _i172.GetDoctorProfileUseCase(gh<_i158.DoctorProfileRepository>()));
    gh.lazySingleton<_i173.GetNetworkHealth>(
        () => _i173.GetNetworkHealth(gh<_i90.NetworkRepository>()));
    gh.lazySingleton<_i174.GetNodeStats>(
        () => _i174.GetNodeStats(gh<_i90.NetworkRepository>()));
    gh.lazySingleton<_i175.GetProgressUseCase>(
        () => _i175.GetProgressUseCase(gh<_i82.MeditationRepository>()));
    gh.factory<_i176.GetReportsUseCase>(
        () => _i176.GetReportsUseCase(gh<_i107.ReportRepository>()));
    gh.lazySingleton<_i177.GetScriptsUseCase>(
        () => _i177.GetScriptsUseCase(gh<_i82.MeditationRepository>()));
    gh.factory<_i178.GetUserProfileUseCase>(
        () => _i178.GetUserProfileUseCase(gh<_i128.UserProfileRepository>()));
    gh.lazySingleton<_i179.GovernanceIpfsDatasource>(
        () => _i179.GovernanceIpfsDatasource(gh<_i60.IpfsDatasource>()));
    gh.lazySingleton<_i180.GovernanceRepository>(() =>
        _i181.GovernanceRepositoryImpl(gh<_i179.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i182.HealthConnectDataSource>(
        () => _i182.HealthConnectDataSourceImpl(gh<_i50.HealthWrapper>()));
    gh.lazySingleton<_i183.HealthDataImportRepository>(
        () => _i184.HealthDataImportRepositoryImpl(
              gh<_i117.SensorHealthDataSource>(),
              gh<_i117.FileHealthDataSource>(),
            ));
    gh.lazySingleton<_i185.HealthRecordRepository>(
        () => _i186.HealthRecordRepositoryImpl(gh<_i61.Isar>()));
    gh.factory<_i187.ImportCalendarUseCase>(() => _i187.ImportCalendarUseCase(
          gh<_i21.CalendarImportRepository>(),
          gh<_i8.AppointmentRepository>(),
          gh<_i128.UserProfileRepository>(),
        ));
    gh.factory<_i109.ImportHealthDataUseCase>(
        () => _i109.ImportHealthDataUseCase(
              gh<_i46.HealthDataImportService>(),
              gh<_i133.VitalSignRepository>(),
            ));
=======
    gh.lazySingleton<_i167.FileImportDataSource>(
        () => _i167.FileImportDataSourceImpl(
              gh<_i37.FilePickerService>(),
              gh<_i100.OcrService>(),
            ));
    gh.factory<_i168.GetAboutInfoUseCase>(
        () => _i168.GetAboutInfoUseCase(gh<_i54.IAboutRepository>()));
    gh.factory<_i169.GetAllDoctorsUseCase>(
        () => _i169.GetAllDoctorsUseCase(gh<_i160.DoctorProfileRepository>()));
    gh.factory<_i170.GetAllVitalSignsUseCase>(
        () => _i170.GetAllVitalSignsUseCase(gh<_i135.VitalSignRepository>()));
    gh.factory<_i109.GetAvailableSourcesUseCase>(() =>
        _i109.GetAvailableSourcesUseCase(gh<_i47.HealthDataImportService>()));
    gh.factory<_i171.GetChatHistoryUseCase>(
        () => _i171.GetChatHistoryUseCase(gh<_i138.VoiceChatRepository>()));
    gh.factory<_i172.GetChatHistoryUseCase>(
        () => _i172.GetChatHistoryUseCase(gh<_i133.VectorStoreService>()));
    gh.factory<_i173.GetConnectionsUseCase>(
        () => _i173.GetConnectionsUseCase(gh<_i98.OAuthRepository>()));
    gh.factory<_i174.GetCredentialsUseCase>(
        () => _i174.GetCredentialsUseCase(gh<_i147.AuthRepository>()));
    gh.factory<_i175.GetDoctorProfileUseCase>(() =>
        _i175.GetDoctorProfileUseCase(gh<_i160.DoctorProfileRepository>()));
    gh.lazySingleton<_i176.GetNetworkHealth>(
        () => _i176.GetNetworkHealth(gh<_i90.NetworkRepository>()));
    gh.lazySingleton<_i177.GetNodeStats>(
        () => _i177.GetNodeStats(gh<_i90.NetworkRepository>()));
    gh.lazySingleton<_i178.GetProgressUseCase>(
        () => _i178.GetProgressUseCase(gh<_i82.MeditationRepository>()));
    gh.factory<_i179.GetReportsUseCase>(
        () => _i179.GetReportsUseCase(gh<_i107.ReportRepository>()));
    gh.lazySingleton<_i180.GetScriptsUseCase>(
        () => _i180.GetScriptsUseCase(gh<_i82.MeditationRepository>()));
    gh.factory<_i181.GetUserProfileUseCase>(
        () => _i181.GetUserProfileUseCase(gh<_i130.UserProfileRepository>()));
    gh.lazySingleton<_i182.GovernanceIpfsDatasource>(
        () => _i182.GovernanceIpfsDatasource(gh<_i60.IpfsDatasource>()));
    gh.lazySingleton<_i183.GovernanceRepository>(() =>
        _i184.GovernanceRepositoryImpl(gh<_i182.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i185.HealthDataImportRepository>(
        () => _i186.HealthDataImportRepositoryImpl(
              gh<_i117.SensorHealthDataSource>(),
              gh<_i117.FileHealthDataSource>(),
            ));
    gh.lazySingleton<_i187.HealthRecordRepository>(
        () => _i188.HealthRecordRepositoryImpl(gh<_i61.Isar>()));
    gh.factory<_i189.ImportCalendarUseCase>(() => _i189.ImportCalendarUseCase(
          gh<_i21.CalendarImportRepository>(),
          gh<_i8.AppointmentRepository>(),
          gh<_i130.UserProfileRepository>(),
=======
    gh.lazySingleton<_i164.FileImportDataSource>(
        () => _i164.FileImportDataSourceImpl(
              gh<_i37.FilePickerService>(),
              gh<_i100.OcrService>(),
            ));
    gh.factory<_i165.GetAboutInfoUseCase>(
        () => _i165.GetAboutInfoUseCase(gh<_i54.IAboutRepository>()));
    gh.factory<_i166.GetAllDoctorsUseCase>(
        () => _i166.GetAllDoctorsUseCase(gh<_i158.DoctorProfileRepository>()));
    gh.factory<_i167.GetAllVitalSignsUseCase>(
        () => _i167.GetAllVitalSignsUseCase(gh<_i133.VitalSignRepository>()));
    gh.factory<_i109.GetAvailableSourcesUseCase>(() =>
        _i109.GetAvailableSourcesUseCase(gh<_i47.HealthDataImportService>()));
    gh.factory<_i168.GetChatHistoryUseCase>(
        () => _i168.GetChatHistoryUseCase(gh<_i131.VectorStoreService>()));
    gh.factory<_i169.GetChatHistoryUseCase>(
        () => _i169.GetChatHistoryUseCase(gh<_i136.VoiceChatRepository>()));
    gh.factory<_i170.GetConnectionsUseCase>(
        () => _i170.GetConnectionsUseCase(gh<_i98.OAuthRepository>()));
    gh.factory<_i171.GetCredentialsUseCase>(
        () => _i171.GetCredentialsUseCase(gh<_i145.AuthRepository>()));
    gh.factory<_i172.GetDoctorProfileUseCase>(() =>
        _i172.GetDoctorProfileUseCase(gh<_i158.DoctorProfileRepository>()));
    gh.lazySingleton<_i173.GetNetworkHealth>(
        () => _i173.GetNetworkHealth(gh<_i90.NetworkRepository>()));
    gh.lazySingleton<_i174.GetNodeStats>(
        () => _i174.GetNodeStats(gh<_i90.NetworkRepository>()));
    gh.lazySingleton<_i175.GetProgressUseCase>(
        () => _i175.GetProgressUseCase(gh<_i82.MeditationRepository>()));
    gh.factory<_i176.GetReportsUseCase>(
        () => _i176.GetReportsUseCase(gh<_i107.ReportRepository>()));
    gh.lazySingleton<_i177.GetScriptsUseCase>(
        () => _i177.GetScriptsUseCase(gh<_i82.MeditationRepository>()));
    gh.factory<_i178.GetUserProfileUseCase>(
        () => _i178.GetUserProfileUseCase(gh<_i128.UserProfileRepository>()));
    gh.lazySingleton<_i179.GovernanceIpfsDatasource>(
        () => _i179.GovernanceIpfsDatasource(gh<_i60.IpfsDatasource>()));
    gh.lazySingleton<_i180.GovernanceRepository>(() =>
        _i181.GovernanceRepositoryImpl(gh<_i179.GovernanceIpfsDatasource>()));
    gh.lazySingleton<_i182.HealthDataImportRepository>(
        () => _i183.HealthDataImportRepositoryImpl(
              gh<_i117.SensorHealthDataSource>(),
              gh<_i117.FileHealthDataSource>(),
            ));
    gh.lazySingleton<_i184.HealthRecordRepository>(
        () => _i185.HealthRecordRepositoryImpl(gh<_i61.Isar>()));
    gh.factory<_i186.ImportCalendarUseCase>(() => _i186.ImportCalendarUseCase(
          gh<_i21.CalendarImportRepository>(),
          gh<_i8.AppointmentRepository>(),
          gh<_i128.UserProfileRepository>(),
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
        ));
    gh.factory<_i109.ImportHealthDataUseCase>(
        () => _i109.ImportHealthDataUseCase(
              gh<_i47.HealthDataImportService>(),
<<<<<<< HEAD
              gh<_i135.VitalSignRepository>(),
            ));
    gh.factory<_i64.LlmAdapter>(
      () => _i190.MockLlmAdapter(gh<_i103.PromptScrubber>()),
      instanceName: 'mock',
    );
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
    gh.lazySingleton<_i64.LlmAdapter>(
      () => _i188.GeminiLlmAdapter(
=======
              gh<_i133.VitalSignRepository>(),
            ));
    gh.lazySingleton<_i64.LlmAdapter>(
      () => _i187.GeminiLlmAdapter(
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
        scrubber: gh<_i103.PromptScrubber>(),
        userProfileRepository: gh<_i128.UserProfileRepository>(),
        modelWrapper: gh<_i42.GeminiModelWrapper>(),
      ),
      instanceName: 'gemini',
    );
<<<<<<< HEAD
<<<<<<< HEAD
    gh.factory<_i64.LlmAdapter>(
      () => _i189.MockLlmAdapter(gh<_i103.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i190.LlmAdapterFactory>(
        () => _i190.LlmAdapterFactory(gh<_i119.SettingsRepository>()));
    gh.lazySingleton<_i191.LlmService>(() => _i192.GemmaLlmService(
=======
    gh.factory<_i64.LlmAdapter>(
      () => _i188.MockLlmAdapter(gh<_i103.PromptScrubber>()),
      instanceName: 'mock',
    );
    gh.lazySingleton<_i189.LlmAdapterFactory>(
        () => _i189.LlmAdapterFactory(gh<_i119.SettingsRepository>()));
    gh.lazySingleton<_i190.LlmService>(() => _i191.GemmaLlmService(
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
          gh<_i131.VectorStoreService>(),
          gh<_i128.UserProfileRepository>(),
          gh<_i64.LlmAdapter>(instanceName: 'gemma'),
        ));
<<<<<<< HEAD
    gh.factory<_i193.LlmSettingsCubit>(() => _i193.LlmSettingsCubit(
=======
    gh.factory<_i192.LlmSettingsCubit>(() => _i192.LlmSettingsCubit(
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
          gh<_i119.SettingsRepository>(),
          gh<_i29.DeviceCapabilityService>(),
          gh<_i64.LlmAdapter>(instanceName: 'gemma'),
        ));
<<<<<<< HEAD
    gh.factory<_i194.LoginUseCase>(() => _i194.LoginUseCase(
=======
    gh.factory<_i193.LoginUseCase>(() => _i193.LoginUseCase(
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
          gh<_i145.AuthRepository>(),
          gh<_i163.EncryptionService>(),
          gh<_i16.BiometricService>(),
        ));
<<<<<<< HEAD
    gh.factory<_i195.LogoutUseCase>(
        () => _i195.LogoutUseCase(gh<_i145.AuthRepository>()));
    gh.lazySingleton<_i196.MedicalResearchService>(
        () => _i196.MedicalResearchService(
              gh<_i77.MedicalWebSearchService>(),
              gh<_i73.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i197.MedicationRepository>(
        () => _i198.IsarMedicationRepository(
              gh<_i61.Isar>(),
              gh<_i101.PharmacyApiService>(),
            ));
    gh.factory<_i199.MedicationsCubit>(
        () => _i199.MedicationsCubit(gh<_i197.MedicationRepository>()));
    gh.factory<_i200.MeditationCubit>(() => _i200.MeditationCubit(
=======
    gh.factory<_i194.LogoutUseCase>(
        () => _i194.LogoutUseCase(gh<_i145.AuthRepository>()));
    gh.lazySingleton<_i195.MedicalResearchService>(
        () => _i195.MedicalResearchService(
              gh<_i77.MedicalWebSearchService>(),
              gh<_i73.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i196.MedicationRepository>(
        () => _i197.IsarMedicationRepository(
              gh<_i61.Isar>(),
              gh<_i101.PharmacyApiService>(),
            ));
    gh.factory<_i198.MedicationsCubit>(
        () => _i198.MedicationsCubit(gh<_i196.MedicationRepository>()));
    gh.factory<_i199.MeditationCubit>(() => _i199.MeditationCubit(
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
          gh<_i106.RecommendScriptUseCase>(),
          gh<_i123.StartSessionUseCase>(),
          gh<_i151.CompleteSessionUseCase>(),
          gh<_i175.GetProgressUseCase>(),
          gh<_i12.AudioService>(),
        ));
<<<<<<< HEAD
    gh.factory<_i201.NetworkCubit>(() => _i201.NetworkCubit(
          gh<_i88.NetworkPeerRepository>(),
          gh<_i87.NetworkP2PApi>(),
        ));
    gh.factory<_i202.NetworkHealthCubit>(() => _i202.NetworkHealthCubit(
=======
    gh.factory<_i200.NetworkCubit>(() => _i200.NetworkCubit(
          gh<_i88.NetworkPeerRepository>(),
          gh<_i87.NetworkP2PApi>(),
        ));
    gh.factory<_i201.NetworkHealthCubit>(() => _i201.NetworkHealthCubit(
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
          gh<_i173.GetNetworkHealth>(),
          gh<_i152.ConnectNode>(),
          gh<_i90.NetworkRepository>(),
        ));
<<<<<<< HEAD
    gh.lazySingleton<_i203.OnboardingRepository>(() =>
        _i204.OnboardingRepositoryImpl(gh<_i128.UserProfileRepository>()));
    gh.lazySingleton<_i205.ReportGenerationService>(
        () => _i206.GemmaReportGenerationService(
=======
    gh.lazySingleton<_i192.LlmAdapterFactory>(
        () => _i192.LlmAdapterFactory(gh<_i119.SettingsRepository>()));
    gh.lazySingleton<_i193.LlmService>(() => _i194.GemmaLlmService(
          gh<_i133.VectorStoreService>(),
          gh<_i130.UserProfileRepository>(),
          gh<_i64.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i195.LlmSettingsCubit>(() => _i195.LlmSettingsCubit(
          gh<_i119.SettingsRepository>(),
          gh<_i30.DeviceCapabilityService>(),
          gh<_i64.LlmAdapter>(instanceName: 'gemma'),
        ));
    gh.factory<_i196.LoginUseCase>(() => _i196.LoginUseCase(
          gh<_i147.AuthRepository>(),
          gh<_i165.EncryptionService>(),
          gh<_i16.BiometricService>(),
        ));
    gh.factory<_i197.LogoutUseCase>(
        () => _i197.LogoutUseCase(gh<_i147.AuthRepository>()));
    gh.lazySingleton<_i198.MedicalResearchService>(
        () => _i198.MedicalResearchService(
              gh<_i77.MedicalWebSearchService>(),
              gh<_i73.MedicalScraperService>(),
            ));
    gh.lazySingleton<_i199.MedicationRepository>(
        () => _i200.IsarMedicationRepository(
              gh<_i61.Isar>(),
              gh<_i101.PharmacyApiService>(),
            ));
    gh.factory<_i201.MedicationsCubit>(
        () => _i201.MedicationsCubit(gh<_i199.MedicationRepository>()));
    gh.factory<_i202.MeditationCubit>(() => _i202.MeditationCubit(
          gh<_i106.RecommendScriptUseCase>(),
          gh<_i123.StartSessionUseCase>(),
          gh<_i153.CompleteSessionUseCase>(),
          gh<_i178.GetProgressUseCase>(),
          gh<_i12.AudioService>(),
        ));
    gh.factory<_i203.NetworkCubit>(() => _i203.NetworkCubit(
          gh<_i88.NetworkPeerRepository>(),
          gh<_i87.NetworkP2PApi>(),
        ));
    gh.factory<_i204.NetworkHealthCubit>(() => _i204.NetworkHealthCubit(
          gh<_i176.GetNetworkHealth>(),
          gh<_i154.ConnectNode>(),
          gh<_i90.NetworkRepository>(),
        ));
    gh.lazySingleton<_i205.OnboardingRepository>(() =>
        _i206.OnboardingRepositoryImpl(gh<_i130.UserProfileRepository>()));
    gh.lazySingleton<_i207.ReportGenerationService>(
        () => _i208.GemmaReportGenerationService(
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
    gh.lazySingleton<_i202.OnboardingRepository>(() =>
        _i203.OnboardingRepositoryImpl(gh<_i128.UserProfileRepository>()));
    gh.lazySingleton<_i204.ReportGenerationService>(
        () => _i205.GemmaReportGenerationService(
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
              gh<_i64.LlmAdapter>(instanceName: 'gemma'),
              gh<_i131.VectorStoreService>(),
              gh<_i128.UserProfileRepository>(),
              gh<_i103.PromptScrubber>(),
            ));
<<<<<<< HEAD
<<<<<<< HEAD
    gh.factory<_i207.SaveCredentialsUseCase>(
        () => _i207.SaveCredentialsUseCase(gh<_i145.AuthRepository>()));
    gh.factory<_i208.SaveMedicationUseCase>(
        () => _i208.SaveMedicationUseCase(gh<_i197.MedicationRepository>()));
    gh.factory<_i209.SaveRecordUseCase>(
        () => _i209.SaveRecordUseCase(gh<_i185.HealthRecordRepository>()));
    gh.factory<_i210.SaveUserProfileUseCase>(
        () => _i210.SaveUserProfileUseCase(gh<_i128.UserProfileRepository>()));
    gh.factory<_i211.SaveVitalSignsUseCase>(
        () => _i211.SaveVitalSignsUseCase(gh<_i133.VitalSignRepository>()));
    gh.factory<_i212.SecondOpinionCubit>(
        () => _i212.SecondOpinionCubit(gh<_i112.SecondOpinionRepository>()));
    gh.factory<_i213.SendMessageUseCase>(
        () => _i213.SendMessageUseCase(gh<_i136.VoiceChatRepository>()));
    gh.factory<_i214.SetPinUseCase>(() => _i214.SetPinUseCase(
          gh<_i145.AuthRepository>(),
          gh<_i163.EncryptionService>(),
        ));
    gh.lazySingleton<_i215.SmartSearchUseCase>(
        () => _i215.SmartSearchUseCase(gh<_i131.VectorStoreService>()));
    gh.lazySingleton<_i216.StartListeningUseCase>(
        () => _i216.StartListeningUseCase(
=======
    gh.factory<_i206.SaveCredentialsUseCase>(
        () => _i206.SaveCredentialsUseCase(gh<_i145.AuthRepository>()));
    gh.factory<_i207.SaveMedicationUseCase>(
        () => _i207.SaveMedicationUseCase(gh<_i196.MedicationRepository>()));
    gh.factory<_i208.SaveRecordUseCase>(
        () => _i208.SaveRecordUseCase(gh<_i184.HealthRecordRepository>()));
    gh.factory<_i209.SaveUserProfileUseCase>(
        () => _i209.SaveUserProfileUseCase(gh<_i128.UserProfileRepository>()));
    gh.factory<_i210.SaveVitalSignsUseCase>(
        () => _i210.SaveVitalSignsUseCase(gh<_i133.VitalSignRepository>()));
    gh.factory<_i211.SecondOpinionCubit>(
        () => _i211.SecondOpinionCubit(gh<_i112.SecondOpinionRepository>()));
    gh.factory<_i212.SendMessageUseCase>(
        () => _i212.SendMessageUseCase(gh<_i136.VoiceChatRepository>()));
    gh.factory<_i213.SetPinUseCase>(() => _i213.SetPinUseCase(
          gh<_i145.AuthRepository>(),
          gh<_i163.EncryptionService>(),
        ));
    gh.lazySingleton<_i214.SmartSearchUseCase>(
        () => _i214.SmartSearchUseCase(gh<_i131.VectorStoreService>()));
    gh.lazySingleton<_i215.StartListeningUseCase>(
        () => _i215.StartListeningUseCase(
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
              gh<_i147.BleSharingService>(),
              gh<_i94.NfcSharingService>(),
              gh<_i140.WifiDirectService>(),
            ));
<<<<<<< HEAD
    gh.lazySingleton<_i217.StartSharingUseCase>(() => _i217.StartSharingUseCase(
=======
    gh.lazySingleton<_i216.StartSharingUseCase>(() => _i216.StartSharingUseCase(
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
          gh<_i147.BleSharingService>(),
          gh<_i94.NfcSharingService>(),
          gh<_i140.WifiDirectService>(),
        ));
<<<<<<< HEAD
    gh.factory<_i218.SyncCubit>(() => _i218.SyncCubit(
          gh<_i69.SyncService>(),
          gh<_i131.VectorStoreService>(),
        ));
    gh.lazySingleton<_i219.SyncService>(() => _i220.SyncServiceImpl(
          gh<_i125.SyncRepository>(),
          gh<_i69.SyncService>(),
=======
    gh.factory<_i209.SaveCredentialsUseCase>(
        () => _i209.SaveCredentialsUseCase(gh<_i147.AuthRepository>()));
    gh.factory<_i210.SaveMedicationUseCase>(
        () => _i210.SaveMedicationUseCase(gh<_i199.MedicationRepository>()));
    gh.factory<_i211.SaveRecordUseCase>(
        () => _i211.SaveRecordUseCase(gh<_i187.HealthRecordRepository>()));
    gh.factory<_i212.SaveUserProfileUseCase>(
        () => _i212.SaveUserProfileUseCase(gh<_i130.UserProfileRepository>()));
    gh.factory<_i213.SaveVitalSignsUseCase>(
        () => _i213.SaveVitalSignsUseCase(gh<_i135.VitalSignRepository>()));
    gh.factory<_i214.SecondOpinionCubit>(
        () => _i214.SecondOpinionCubit(gh<_i112.SecondOpinionRepository>()));
    gh.factory<_i215.SendMessageUseCase>(
        () => _i215.SendMessageUseCase(gh<_i138.VoiceChatRepository>()));
    gh.factory<_i216.SetPinUseCase>(() => _i216.SetPinUseCase(
          gh<_i147.AuthRepository>(),
          gh<_i165.EncryptionService>(),
        ));
    gh.lazySingleton<_i217.SmartSearchUseCase>(
        () => _i217.SmartSearchUseCase(gh<_i133.VectorStoreService>()));
    gh.lazySingleton<_i218.StartListeningUseCase>(
        () => _i218.StartListeningUseCase(
              gh<_i149.BleSharingService>(),
              gh<_i94.NfcSharingService>(),
              gh<_i142.WifiDirectService>(),
            ));
    gh.lazySingleton<_i219.StartSharingUseCase>(() => _i219.StartSharingUseCase(
          gh<_i149.BleSharingService>(),
          gh<_i94.NfcSharingService>(),
          gh<_i142.WifiDirectService>(),
        ));
    gh.factory<_i220.SyncCubit>(() => _i220.SyncCubit(
          gh<_i69.SyncService>(),
          gh<_i133.VectorStoreService>(),
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
        ));
    gh.factory<_i221.UserProfileCubit>(
        () => _i221.UserProfileCubit(gh<_i128.UserProfileRepository>()));
    gh.factory<_i222.ValidateSessionUseCase>(
        () => _i222.ValidateSessionUseCase(gh<_i145.AuthRepository>()));
    gh.factory<_i223.VitalSignBloc>(
        () => _i223.VitalSignBloc(gh<_i133.VitalSignRepository>()));
    gh.factory<_i224.VoiceChatCubit>(() => _i224.VoiceChatCubit(
<<<<<<< HEAD
          gh<_i213.SendMessageUseCase>(),
          gh<_i168.GetChatHistoryUseCase>(),
          gh<_i136.VoiceChatRepository>(),
=======
          gh<_i215.SendMessageUseCase>(),
          gh<_i171.GetChatHistoryUseCase>(),
          gh<_i138.VoiceChatRepository>(),
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
          gh<_i12.AudioService>(),
        ));
    gh.factory<_i225.VouchCubit>(
        () => _i225.VouchCubit(gh<_i138.VouchRepository>()));
    gh.lazySingleton<_i226.AllergyRepository>(() => _i227.AllergyRepositoryImpl(
<<<<<<< HEAD
          gh<_i143.AllergyLocalDataSource>(),
          encryptionService: gh<_i163.EncryptionService>(),
        ));
    gh.factory<_i228.AuthCubit>(() => _i228.AuthCubit(
          gh<_i145.AuthRepository>(),
          gh<_i16.BiometricService>(),
          gh<_i194.LoginUseCase>(),
          gh<_i195.LogoutUseCase>(),
          gh<_i222.ValidateSessionUseCase>(),
          gh<_i214.SetPinUseCase>(),
          gh<_i150.CheckSessionTimeoutUseCase>(),
=======
          gh<_i145.AllergyLocalDataSource>(),
          encryptionService: gh<_i165.EncryptionService>(),
        ));
    gh.factory<_i228.AuthCubit>(() => _i228.AuthCubit(
          gh<_i147.AuthRepository>(),
          gh<_i16.BiometricService>(),
          gh<_i196.LoginUseCase>(),
          gh<_i197.LogoutUseCase>(),
          gh<_i222.ValidateSessionUseCase>(),
          gh<_i216.SetPinUseCase>(),
          gh<_i152.CheckSessionTimeoutUseCase>(),
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
        ));
    gh.lazySingleton<_i229.AuthService>(
        () => _i229.AuthServiceImpl(gh<_i163.EncryptionService>()));
    gh.lazySingleton<_i230.BadgeCalculator>(() => _i230.BadgeCalculator(
          gh<_i158.DoctorProfileRepository>(),
          gh<_i104.RatingRepository>(),
<<<<<<< HEAD
          gh<_i138.VouchRepository>(),
=======
          gh<_i140.VouchRepository>(),
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
        ));
    gh.factory<_i231.BadgeCubit>(
        () => _i231.BadgeCubit(gh<_i230.BadgeCalculator>()));
    gh.factory<_i232.CalendarImportCubit>(() => _i232.CalendarImportCubit(
          gh<_i21.CalendarImportRepository>(),
<<<<<<< HEAD
          gh<_i187.ImportCalendarUseCase>(),
=======
          gh<_i189.ImportCalendarUseCase>(),
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
        ));
    gh.factory<_i233.CompleteOnboardingUseCase>(() =>
        _i233.CompleteOnboardingUseCase(gh<_i203.OnboardingRepository>()));
    gh.lazySingleton<_i234.DashboardRepository>(
        () => _i235.DashboardRepositoryImpl(
              gh<_i27.DashboardRemoteDataSource>(),
<<<<<<< HEAD
              gh<_i133.VitalSignRepository>(),
              gh<_i197.MedicationRepository>(),
=======
              gh<_i135.VitalSignRepository>(),
              gh<_i199.MedicationRepository>(),
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
              gh<_i107.ReportRepository>(),
            ));
    gh.lazySingleton<_i236.DataSourceRepository>(
        () => _i237.DataSourceRepositoryImpl(
              gh<_i116.SensorApiDataSource>(),
<<<<<<< HEAD
              gh<_i164.FileImportDataSource>(),
              gh<_i182.HealthConnectDataSource>(),
=======
              gh<_i167.FileImportDataSource>(),
              gh<_i46.HealthConnectDataSource>(),
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
            ));
    gh.lazySingleton<_i238.DistributedCacheUsecase>(() =>
        _i238.DistributedCacheUsecase(gh<_i156.DistributedStorageService>()));
    gh.factory<_i239.EpsConnectionBloc>(() => _i239.EpsConnectionBloc(
<<<<<<< HEAD
=======
    gh.factory<_i217.SyncCubit>(() => _i217.SyncCubit(
          gh<_i69.SyncService>(),
          gh<_i131.VectorStoreService>(),
        ));
    gh.lazySingleton<_i218.SyncService>(() => _i219.SyncServiceImpl(
          gh<_i125.SyncRepository>(),
          gh<_i69.SyncService>(),
        ));
    gh.factory<_i220.UserProfileCubit>(
        () => _i220.UserProfileCubit(gh<_i128.UserProfileRepository>()));
    gh.factory<_i221.ValidateSessionUseCase>(
        () => _i221.ValidateSessionUseCase(gh<_i145.AuthRepository>()));
    gh.factory<_i222.VitalSignBloc>(
        () => _i222.VitalSignBloc(gh<_i133.VitalSignRepository>()));
    gh.factory<_i223.VoiceChatCubit>(() => _i223.VoiceChatCubit(
          gh<_i212.SendMessageUseCase>(),
          gh<_i169.GetChatHistoryUseCase>(),
          gh<_i136.VoiceChatRepository>(),
          gh<_i12.AudioService>(),
        ));
    gh.factory<_i224.VouchCubit>(
        () => _i224.VouchCubit(gh<_i138.VouchRepository>()));
    gh.lazySingleton<_i225.AllergyRepository>(() => _i226.AllergyRepositoryImpl(
          gh<_i143.AllergyLocalDataSource>(),
          encryptionService: gh<_i163.EncryptionService>(),
        ));
    gh.factory<_i227.AuthCubit>(() => _i227.AuthCubit(
          gh<_i145.AuthRepository>(),
          gh<_i16.BiometricService>(),
          gh<_i193.LoginUseCase>(),
          gh<_i194.LogoutUseCase>(),
          gh<_i221.ValidateSessionUseCase>(),
          gh<_i213.SetPinUseCase>(),
          gh<_i150.CheckSessionTimeoutUseCase>(),
        ));
    gh.lazySingleton<_i228.AuthService>(
        () => _i228.AuthServiceImpl(gh<_i163.EncryptionService>()));
    gh.lazySingleton<_i229.BadgeCalculator>(() => _i229.BadgeCalculator(
          gh<_i158.DoctorProfileRepository>(),
          gh<_i104.RatingRepository>(),
          gh<_i138.VouchRepository>(),
        ));
    gh.factory<_i230.BadgeCubit>(
        () => _i230.BadgeCubit(gh<_i229.BadgeCalculator>()));
    gh.factory<_i231.CalendarImportCubit>(() => _i231.CalendarImportCubit(
          gh<_i21.CalendarImportRepository>(),
          gh<_i186.ImportCalendarUseCase>(),
        ));
    gh.factory<_i232.CompleteOnboardingUseCase>(() =>
        _i232.CompleteOnboardingUseCase(gh<_i202.OnboardingRepository>()));
    gh.lazySingleton<_i233.DashboardRepository>(
        () => _i234.DashboardRepositoryImpl(
              gh<_i27.DashboardRemoteDataSource>(),
              gh<_i133.VitalSignRepository>(),
              gh<_i196.MedicationRepository>(),
              gh<_i107.ReportRepository>(),
            ));
    gh.lazySingleton<_i235.DataSourceRepository>(
        () => _i236.DataSourceRepositoryImpl(
              gh<_i116.SensorApiDataSource>(),
              gh<_i164.FileImportDataSource>(),
              gh<_i46.HealthConnectDataSource>(),
            ));
    gh.lazySingleton<_i237.DistributedCacheUsecase>(() =>
        _i237.DistributedCacheUsecase(gh<_i156.DistributedStorageService>()));
    gh.factory<_i238.EpsConnectionBloc>(() => _i238.EpsConnectionBloc(
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
          gh<_i170.GetConnectionsUseCase>(),
          gh<_i153.ConnectProviderUseCase>(),
          gh<_i155.DisconnectProviderUseCase>(),
        ));
<<<<<<< HEAD
    gh.factory<_i240.EpsConnectionCubit>(() => _i240.EpsConnectionCubit(
=======
    gh.factory<_i239.EpsConnectionCubit>(() => _i239.EpsConnectionCubit(
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
          gh<_i170.GetConnectionsUseCase>(),
          gh<_i153.ConnectProviderUseCase>(),
          gh<_i155.DisconnectProviderUseCase>(),
        ));
<<<<<<< HEAD
    gh.factory<_i241.FhirSyncCubit>(() => _i241.FhirSyncCubit(
          gh<_i219.SyncService>(),
          gh<_i95.NodeDiscoveryService>(),
        ));
    gh.factory<_i242.GetAllMedicationsUseCase>(
        () => _i242.GetAllMedicationsUseCase(gh<_i197.MedicationRepository>()));
    gh.factory<_i243.GetAllRecordsUseCase>(
        () => _i243.GetAllRecordsUseCase(gh<_i185.HealthRecordRepository>()));
    gh.factory<_i244.GetAllergiesUseCase>(
        () => _i244.GetAllergiesUseCase(gh<_i226.AllergyRepository>()));
    gh.factory<_i245.GetDashboardStatsUseCase>(
        () => _i245.GetDashboardStatsUseCase(gh<_i234.DashboardRepository>()));
    gh.factory<_i246.GetOnboardingProfileUseCase>(() =>
        _i246.GetOnboardingProfileUseCase(gh<_i203.OnboardingRepository>()));
    gh.factory<_i247.GetRecentActivityUseCase>(
        () => _i247.GetRecentActivityUseCase(gh<_i234.DashboardRepository>()));
    gh.factory<_i248.HealthImportBloc>(() => _i248.HealthImportBloc(
=======
          gh<_i173.GetConnectionsUseCase>(),
          gh<_i155.ConnectProviderUseCase>(),
          gh<_i157.DisconnectProviderUseCase>(),
        ));
    gh.factory<_i240.EpsConnectionCubit>(() => _i240.EpsConnectionCubit(
          gh<_i173.GetConnectionsUseCase>(),
          gh<_i155.ConnectProviderUseCase>(),
          gh<_i157.DisconnectProviderUseCase>(),
        ));
=======
    gh.factory<_i240.FhirSyncCubit>(() => _i240.FhirSyncCubit(
          gh<_i218.SyncService>(),
          gh<_i95.NodeDiscoveryService>(),
        ));
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
    gh.factory<_i241.GetAllMedicationsUseCase>(
        () => _i241.GetAllMedicationsUseCase(gh<_i196.MedicationRepository>()));
    gh.factory<_i242.GetAllRecordsUseCase>(
        () => _i242.GetAllRecordsUseCase(gh<_i184.HealthRecordRepository>()));
    gh.factory<_i243.GetAllergiesUseCase>(
        () => _i243.GetAllergiesUseCase(gh<_i225.AllergyRepository>()));
    gh.factory<_i244.GetDashboardStatsUseCase>(
        () => _i244.GetDashboardStatsUseCase(gh<_i233.DashboardRepository>()));
    gh.factory<_i245.GetOnboardingProfileUseCase>(() =>
        _i245.GetOnboardingProfileUseCase(gh<_i202.OnboardingRepository>()));
    gh.factory<_i246.GetRecentActivityUseCase>(
        () => _i246.GetRecentActivityUseCase(gh<_i233.DashboardRepository>()));
    gh.factory<_i247.HealthImportBloc>(() => _i247.HealthImportBloc(
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
          gh<_i109.GetAvailableSourcesUseCase>(),
          gh<_i109.RequestHealthAuthUseCase>(),
          gh<_i109.ImportHealthDataUseCase>(),
        ));
<<<<<<< HEAD
<<<<<<< HEAD
    gh.factory<_i249.HealthImportCubit>(() => _i249.HealthImportCubit(
=======
    gh.factory<_i248.HealthImportCubit>(() => _i248.HealthImportCubit(
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
    gh.factory<_i248.HealthImportCubit>(() => _i248.HealthImportCubit(
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
          gh<_i109.GetAvailableSourcesUseCase>(),
          gh<_i109.RequestHealthAuthUseCase>(),
          gh<_i109.ImportHealthDataUseCase>(),
        ));
<<<<<<< HEAD
<<<<<<< HEAD
    gh.factory<_i250.HealthRecordCubit>(() => _i250.HealthRecordCubit(
          gh<_i185.HealthRecordRepository>(),
=======
    gh.factory<_i249.HealthRecordCubit>(() => _i249.HealthRecordCubit(
          gh<_i184.HealthRecordRepository>(),
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
          gh<_i37.FilePickerService>(),
          gh<_i56.ImagePickerService>(),
          gh<_i100.OcrService>(),
          gh<_i131.VectorStoreService>(),
        ));
<<<<<<< HEAD
    gh.lazySingleton<_i251.HomeRepository>(() => _i252.HomeRepositoryImpl(
          gh<_i133.VitalSignRepository>(),
          gh<_i8.AppointmentRepository>(),
          gh<_i197.MedicationRepository>(),
          gh<_i51.HomeLocalDataSource>(),
          gh<_i53.HomeRemoteDataSource>(),
          gh<_i49.HealthSummaryDatasource>(),
        ));
    gh.lazySingleton<_i191.LlmService>(
      () => _i253.RagLlmService(
        gh<_i131.VectorStoreService>(),
        gh<_i196.MedicalResearchService>(),
        gh<_i128.UserProfileRepository>(),
=======
    gh.factory<_i249.HealthRecordCubit>(() => _i249.HealthRecordCubit(
          gh<_i187.HealthRecordRepository>(),
          gh<_i37.FilePickerService>(),
          gh<_i56.ImagePickerService>(),
          gh<_i100.OcrService>(),
          gh<_i133.VectorStoreService>(),
        ));
    gh.lazySingleton<_i250.HomeRepository>(() => _i251.HomeRepositoryImpl(
          gh<_i135.VitalSignRepository>(),
          gh<_i8.AppointmentRepository>(),
          gh<_i199.MedicationRepository>(),
=======
    gh.lazySingleton<_i250.HomeRepository>(() => _i251.HomeRepositoryImpl(
          gh<_i133.VitalSignRepository>(),
          gh<_i8.AppointmentRepository>(),
          gh<_i196.MedicationRepository>(),
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
          gh<_i51.HomeLocalDataSource>(),
          gh<_i53.HomeRemoteDataSource>(),
          gh<_i50.HealthSummaryDatasource>(),
        ));
<<<<<<< HEAD
    gh.lazySingleton<_i193.LlmService>(
      () => _i252.RagLlmService(
        gh<_i133.VectorStoreService>(),
        gh<_i198.MedicalResearchService>(),
        gh<_i130.UserProfileRepository>(),
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
    gh.lazySingleton<_i190.LlmService>(
      () => _i252.RagLlmService(
        gh<_i131.VectorStoreService>(),
        gh<_i195.MedicalResearchService>(),
        gh<_i128.UserProfileRepository>(),
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
        gh<_i64.LlmAdapter>(instanceName: 'gemma'),
      ),
      instanceName: 'rag',
    );
<<<<<<< HEAD
<<<<<<< HEAD
    gh.lazySingleton<_i254.MedicalResearchRepository>(
        () => _i255.MedicalResearchRepositoryImpl(
              gh<_i196.MedicalResearchService>(),
              gh<_i61.Isar>(),
            ));
    gh.factory<_i256.MedicationBloc>(
        () => _i256.MedicationBloc(gh<_i197.MedicationRepository>()));
    gh.factory<_i257.OnboardingCubit>(
        () => _i257.OnboardingCubit(gh<_i203.OnboardingRepository>()));
    gh.lazySingleton<_i258.PatientContextIndexer>(
      () => _i258.PatientContextIndexer(
        gh<_i61.Isar>(),
        gh<_i131.VectorStoreService>(),
        gh<_i185.HealthRecordRepository>(),
        gh<_i197.MedicationRepository>(),
=======
    gh.lazySingleton<_i253.MedicalResearchRepository>(
        () => _i254.MedicalResearchRepositoryImpl(
              gh<_i198.MedicalResearchService>(),
=======
    gh.lazySingleton<_i253.MedicalResearchRepository>(
        () => _i254.MedicalResearchRepositoryImpl(
              gh<_i195.MedicalResearchService>(),
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
              gh<_i61.Isar>(),
            ));
    gh.factory<_i255.MedicationBloc>(
        () => _i255.MedicationBloc(gh<_i196.MedicationRepository>()));
    gh.factory<_i256.OnboardingCubit>(
        () => _i256.OnboardingCubit(gh<_i202.OnboardingRepository>()));
    gh.lazySingleton<_i257.PatientContextIndexer>(
      () => _i257.PatientContextIndexer(
        gh<_i61.Isar>(),
<<<<<<< HEAD
        gh<_i133.VectorStoreService>(),
        gh<_i187.HealthRecordRepository>(),
        gh<_i199.MedicationRepository>(),
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
        gh<_i226.AllergyRepository>(),
=======
        gh<_i131.VectorStoreService>(),
        gh<_i184.HealthRecordRepository>(),
        gh<_i196.MedicationRepository>(),
        gh<_i225.AllergyRepository>(),
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
        gh<_i133.VitalSignRepository>(),
        gh<_i8.AppointmentRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
<<<<<<< HEAD
<<<<<<< HEAD
    gh.factory<_i259.ReportBloc>(() => _i259.ReportBloc(
          gh<_i107.ReportRepository>(),
          gh<_i205.ReportGenerationService>(),
        ));
    gh.factory<_i260.SaveAllergyUseCase>(
        () => _i260.SaveAllergyUseCase(gh<_i226.AllergyRepository>()));
    gh.factory<_i261.SearchMedicalResearch>(() =>
        _i261.SearchMedicalResearch(gh<_i254.MedicalResearchRepository>()));
    gh.factory<_i262.SharingCubit>(() => _i262.SharingCubit(
          bleService: gh<_i147.BleSharingService>(),
          nfcService: gh<_i94.NfcSharingService>(),
          wifiService: gh<_i140.WifiDirectService>(),
          startSharingUseCase: gh<_i217.StartSharingUseCase>(),
          startListeningUseCase: gh<_i216.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i148.CancelSharingUseCase>(),
          walletService: gh<_i35.WalletService>(),
          walletEncryption: gh<_i35.EncryptionService>(),
        ));
    gh.factory<_i263.AllergiesCubit>(
        () => _i263.AllergiesCubit(gh<_i226.AllergyRepository>()));
    gh.factory<_i264.AllergyBloc>(
        () => _i264.AllergyBloc(gh<_i226.AllergyRepository>()));
    gh.factory<_i265.AuthCubit>(() => _i265.AuthCubit(gh<_i229.AuthService>()));
    gh.factory<_i266.DashboardCubit>(() => _i266.DashboardCubit(
          gh<_i245.GetDashboardStatsUseCase>(),
          gh<_i247.GetRecentActivityUseCase>(),
        ));
    gh.factory<_i267.DataSourceCubit>(
        () => _i267.DataSourceCubit(gh<_i236.DataSourceRepository>()));
    gh.factory<_i268.GetHealthSummaryUseCase>(
        () => _i268.GetHealthSummaryUseCase(gh<_i251.HomeRepository>()));
    gh.factory<_i269.GetResearchHistory>(
        () => _i269.GetResearchHistory(gh<_i254.MedicalResearchRepository>()));
    gh.factory<_i270.HomeCubit>(() => _i270.HomeCubit(
          gh<_i268.GetHealthSummaryUseCase>(),
          gh<_i251.HomeRepository>(),
        ));
    gh.lazySingleton<_i271.MedicalIndexingService>(
        () => _i271.MedicalIndexingService(
=======
    gh.factory<_i258.ReportBloc>(() => _i258.ReportBloc(
          gh<_i107.ReportRepository>(),
          gh<_i207.ReportGenerationService>(),
=======
    gh.factory<_i258.ReportBloc>(() => _i258.ReportBloc(
          gh<_i107.ReportRepository>(),
          gh<_i204.ReportGenerationService>(),
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
        ));
    gh.factory<_i259.SaveAllergyUseCase>(
        () => _i259.SaveAllergyUseCase(gh<_i225.AllergyRepository>()));
    gh.factory<_i260.SearchMedicalResearch>(() =>
        _i260.SearchMedicalResearch(gh<_i253.MedicalResearchRepository>()));
    gh.factory<_i261.SharingCubit>(() => _i261.SharingCubit(
          bleService: gh<_i147.BleSharingService>(),
          nfcService: gh<_i94.NfcSharingService>(),
<<<<<<< HEAD
          wifiService: gh<_i142.WifiDirectService>(),
          startSharingUseCase: gh<_i219.StartSharingUseCase>(),
          startListeningUseCase: gh<_i218.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i150.CancelSharingUseCase>(),
=======
          wifiService: gh<_i140.WifiDirectService>(),
          startSharingUseCase: gh<_i216.StartSharingUseCase>(),
          startListeningUseCase: gh<_i215.StartListeningUseCase>(),
          cancelSharingUseCase: gh<_i148.CancelSharingUseCase>(),
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
          walletService: gh<_i35.WalletService>(),
          walletEncryption: gh<_i35.EncryptionService>(),
        ));
    gh.factory<_i262.AllergiesCubit>(
        () => _i262.AllergiesCubit(gh<_i225.AllergyRepository>()));
    gh.factory<_i263.AllergyBloc>(
        () => _i263.AllergyBloc(gh<_i225.AllergyRepository>()));
    gh.factory<_i264.AuthCubit>(() => _i264.AuthCubit(gh<_i228.AuthService>()));
    gh.factory<_i265.DashboardCubit>(() => _i265.DashboardCubit(
          gh<_i244.GetDashboardStatsUseCase>(),
          gh<_i246.GetRecentActivityUseCase>(),
        ));
    gh.factory<_i266.DataSourceCubit>(
        () => _i266.DataSourceCubit(gh<_i235.DataSourceRepository>()));
    gh.factory<_i267.GetHealthSummaryUseCase>(
        () => _i267.GetHealthSummaryUseCase(gh<_i250.HomeRepository>()));
    gh.factory<_i268.GetResearchHistory>(
        () => _i268.GetResearchHistory(gh<_i253.MedicalResearchRepository>()));
    gh.factory<_i269.HomeCubit>(() => _i269.HomeCubit(
          gh<_i267.GetHealthSummaryUseCase>(),
          gh<_i250.HomeRepository>(),
        ));
    gh.lazySingleton<_i270.MedicalIndexingService>(
        () => _i270.MedicalIndexingService(
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
              gh<_i70.MedicalKnowledgeRepository>(),
              gh<_i131.VectorStoreService>(),
<<<<<<< HEAD
              gh<_i258.PatientContextIndexer>(),
=======
              gh<_i257.PatientContextIndexer>(),
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
            ));
    gh.factory<_i272.MedicalResearchCubit>(() => _i272.MedicalResearchCubit(
          gh<_i261.SearchMedicalResearch>(),
          gh<_i269.GetResearchHistory>(),
          gh<_i75.MedicalStandardsService>(),
        ));
    return this;
  }
}

class _$ServiceModule extends _i273.ServiceModule {}

class _$NetworkModule extends _i274.NetworkModule {}

<<<<<<< HEAD
class _$MemoryModule extends _i275.MemoryModule {}

class _$DatabaseModule extends _i276.DatabaseModule {}

class _$FhirModule extends _i277.FhirModule {}
=======
class _$MemoryModule extends _i274.MemoryModule {}

class _$DatabaseModule extends _i275.DatabaseModule {}

class _$FhirModule extends _i276.FhirModule {}
<<<<<<< HEAD
>>>>>>> origin/fix/resolve-flutter-warnings-9378330091415961273
=======
>>>>>>> origin/fix/analyze-warnings-and-errors-13650026634091576366
