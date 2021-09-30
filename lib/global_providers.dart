import 'package:anonaddy/models/app_version/app_version_model.dart';
import 'package:anonaddy/models/failed_deliveries/failed_deliveries_model.dart';
import 'package:anonaddy/services/access_token/access_token_service.dart';
import 'package:anonaddy/services/account/account_service.dart';
import 'package:anonaddy/services/alias/alias_service.dart';
import 'package:anonaddy/services/app_version/app_version_service.dart';
import 'package:anonaddy/services/biometric_auth/biometric_auth_service.dart';
import 'package:anonaddy/services/changelog_service/changelog_service.dart';
import 'package:anonaddy/services/data_storage/offline_data_storage.dart';
import 'package:anonaddy/services/data_storage/search_history_storage.dart';
import 'package:anonaddy/services/data_storage/settings_data_storage.dart';
import 'package:anonaddy/services/domain/domains_service.dart';
import 'package:anonaddy/services/domain_options/domain_options_service.dart';
import 'package:anonaddy/services/failed_deliveries/failed_deliveries_service.dart';
import 'package:anonaddy/services/recipient/recipient_service.dart';
import 'package:anonaddy/services/username/username_service.dart';
import 'package:anonaddy/shared_components/custom_loading_indicator.dart';
import 'package:anonaddy/state_management/domain_state_manager.dart';
import 'package:anonaddy/utilities/confirmation_dialog.dart';
import 'package:anonaddy/utilities/form_validator.dart';
import 'package:anonaddy/utilities/niche_method.dart';
import 'package:anonaddy/utilities/target_platform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info/package_info.dart';

import 'state_management/alias_state_manager.dart';
import 'state_management/login_state_manager.dart';
import 'state_management/recipient_state_manager.dart';
import 'state_management/settings_state_manager.dart';
import 'state_management/username_state_manager.dart';

/// Class Providers
final flutterSecureStorage = Provider((ref) => FlutterSecureStorage());

final biometricAuthService =
    Provider((ref) => BiometricAuthService(LocalAuthentication()));

final offlineDataProvider = Provider<OfflineData>((ref) {
  final secureStorage = ref.read(flutterSecureStorage);
  return OfflineData(secureStorage);
});

final accessTokenService = Provider<AccessTokenService>((ref) {
  final secureStorage = ref.read(flutterSecureStorage);
  return AccessTokenService(secureStorage);
});

final changelogService = Provider<ChangelogService>((ref) {
  final secureStorage = ref.read(flutterSecureStorage);
  return ChangelogService(secureStorage);
});

final usernameService = Provider<UsernameService>((ref) {
  final accessToken = ref.read(accessTokenService);
  return UsernameService(accessToken);
});

final accountService = Provider<AccountService>((ref) {
  final accessToken = ref.read(accessTokenService);
  return AccountService(accessToken);
});

final aliasService = Provider<AliasService>((ref) {
  final accessToken = ref.read(accessTokenService);
  return AliasService(accessToken);
});

final domainOptionsService = Provider<DomainOptionsService>((ref) {
  final accessToken = ref.read(accessTokenService);
  return DomainOptionsService(accessToken);
});

final recipientService = Provider<RecipientService>((ref) {
  final accessToken = ref.read(accessTokenService);
  return RecipientService(accessToken);
});

final domainService = Provider<DomainsService>((ref) {
  final accessToken = ref.read(accessTokenService);
  return DomainsService(accessToken);
});

final appVersionService = Provider<AppVersionService>((ref) {
  final accessToken = ref.read(accessTokenService);
  return AppVersionService(accessToken);
});

final failedDeliveriesService = Provider<FailedDeliveriesService>((ref) {
  final accessToken = ref.read(accessTokenService);
  return FailedDeliveriesService(accessToken);
});

final nicheMethods = Provider<NicheMethod>((ref) => NicheMethod());

final formValidator = Provider<FormValidator>((ref) => FormValidator());

final targetedPlatform =
    Provider<TargetedPlatform>((ref) => TargetedPlatform());

final confirmationDialog =
    Provider<ConfirmationDialog>((ref) => ConfirmationDialog());

final customLoadingIndicator = Provider<CustomLoadingIndicator>((ref) {
  final isIOS = ref.read(targetedPlatform).isIOS();
  return CustomLoadingIndicator(isIOS);
});

final settingsDataStorage = Provider<SettingsDataStorage>((ref) {
  final secureStorage = ref.read(flutterSecureStorage);
  return SettingsDataStorage(secureStorage);
});

final searchHistoryStorage = Provider<SearchHistoryStorage>((ref) {
  final secureStorage = ref.read(flutterSecureStorage);
  return SearchHistoryStorage(secureStorage);
});

/// Notifier Providers
final aliasStateManagerProvider = ChangeNotifierProvider((ref) {
  final service = ref.read(aliasService);
  final methods = ref.read(nicheMethods);

  return AliasStateManager(
    aliasService: service,
    nicheMethod: methods,
  );
});

final usernameStateManagerProvider = ChangeNotifierProvider((ref) {
  final services = ref.read(usernameService);
  final methods = ref.read(nicheMethods);

  return UsernameStateManager(
    usernameService: services,
    showToast: methods.showToast,
  );
});

final recipientStateManagerProvider = ChangeNotifierProvider((ref) {
  final services = ref.read(recipientService);
  final methods = ref.read(nicheMethods);

  return RecipientStateManager(
    recipientService: services,
    showToast: methods.showToast,
  );
});

final settingsStateManagerProvider = ChangeNotifierProvider((ref) {
  final settingStorage = ref.read(settingsDataStorage);
  return SettingsStateManager(settingsStorage: settingStorage);
});

final domainStateManagerProvider = ChangeNotifierProvider((ref) {
  final services = ref.read(domainService);
  final methods = ref.read(nicheMethods);

  return DomainStateManager(
    domainService: services,
    showToast: methods.showToast,
  );
});

/// Future Providers
final packageInfoProvider =
    FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

final appVersionProvider = FutureProvider.autoDispose<AppVersion>((ref) async {
  return await ref.read(appVersionService).getAppVersionData();
});

final failedDeliveriesProvider =
    FutureProvider.autoDispose<FailedDeliveriesModel>((ref) async {
  return await ref.read(failedDeliveriesService).getFailedDeliveries();
});
