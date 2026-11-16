import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:ubuntu_flavor/ubuntu_flavor.dart';
import 'package:ubuntu_logger/ubuntu_logger.dart';
import 'package:ubuntu_provision/ubuntu_provision.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

final _log = Logger('flavor_provider');

class FlavorService {
  @visibleForTesting
  const FlavorService(this.flavor, {String? distroName})
      : _distroName = distroName;

  static Future<FlavorService> load() async {
    final flavor = await FlavorService._loadFlavor();
    final configured =
        await getService<ConfigService>().get<String>('distro-name');
    final name = configured?.trim();
    return FlavorService(
      flavor,
      distroName: (name?.isNotEmpty ?? false) ? name : null,
    );
  }

  final UbuntuFlavor flavor;
  final String? _distroName;

  /// The name of the distribution to show in the UI.
  ///
  /// Defaults to the flavor's display name when not overridden in the
  /// whitelabel config.
  String get distroName => _distroName ?? flavor.displayName;

  static Future<UbuntuFlavor> _loadFlavor() async {
    final configService = getService<ConfigService>();
    final configFlavorName = await configService.get<String>('flavor');

    if (configFlavorName?.isNotEmpty ?? false) {
      final configFlavor = UbuntuFlavor.fromName(configFlavorName!);
      if (configFlavor != UbuntuFlavor.unknown) {
        _log.info('Using flavor from config: $configFlavor');
        return configFlavor;
      } else {
        final validFlavorsNames = UbuntuFlavor.values
            .whereNot((f) => f == UbuntuFlavor.unknown)
            .map((f) => f.name)
            .toList();
        _log.warning('Unknown flavor found in config: $configFlavorName. '
            'Valid flavors are: $validFlavorsNames');
      }
    }

    _log.info('Using default flavor: ${UbuntuFlavor.ubuntu}');
    return UbuntuFlavor.ubuntu;
  }
}
