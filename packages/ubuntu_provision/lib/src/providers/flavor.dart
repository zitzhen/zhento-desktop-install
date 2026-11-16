import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_flavor/ubuntu_flavor.dart';
import 'package:ubuntu_provision/services.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

/// A provider that provides the flavor of the app.
///
/// The flavor is never changed after the config file is read during the
/// start-up of the app.
final flavorProvider = Provider(
  (_) => tryGetService<FlavorService>()?.flavor ?? UbuntuFlavor.ubuntu,
);

/// A provider that provides the distribution name shown in the UI.
///
/// This can be overridden with `distro-name` in the whitelabel config and
/// falls back to the flavor's display name.
final distroNameProvider = Provider<String>(
  (_) =>
      tryGetService<FlavorService>()?.distroName ??
      UbuntuFlavor.ubuntu.displayName,
);
