import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ubuntu_flavor/ubuntu_flavor.dart';
import 'package:ubuntu_provision/ubuntu_provision.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '../test_utils.mocks.dart';

void main() {
  group('load flavor', () {
    final testCases = [
      (
        displayName: 'valid config',
        configFlavorName: 'studio',
        expectedFlavor: UbuntuFlavor.studio,
      ),
      (
        displayName: 'unknown flavor in config',
        configFlavorName: 'kubuntux',
        expectedFlavor: UbuntuFlavor.ubuntu,
      ),
      (
        displayName: 'empty config and unknown flavor from detection',
        configFlavorName: null,
        expectedFlavor: UbuntuFlavor.ubuntu,
      ),
    ];

    tearDown(resetAllServices);

    for (final testCase in testCases) {
      test(testCase.displayName, () async {
        final configService = MockConfigService();
        when(configService.get<String>('flavor'))
            .thenAnswer((_) async => testCase.configFlavorName);
        when(configService.get<String>('distro-name'))
            .thenAnswer((_) async => null);
        registerMockService<ConfigService>(configService);

        final flavor = (await FlavorService.load()).flavor;
        expect(flavor, equals(testCase.expectedFlavor));
      });
    }
  });

  group('load distro name', () {
    final testCases = [
      (
        displayName: 'distro name from config',
        configDistroName: 'ZhenTo',
        expectedName: 'ZhenTo',
      ),
      (
        displayName: 'blank distro name falls back to flavor',
        configDistroName: '   ',
        expectedName: 'Ubuntu',
      ),
      (
        displayName: 'missing distro name falls back to flavor',
        configDistroName: null,
        expectedName: 'Ubuntu',
      ),
    ];

    tearDown(resetAllServices);

    for (final testCase in testCases) {
      test(testCase.displayName, () async {
        final configService = MockConfigService();
        when(configService.get<String>('flavor'))
            .thenAnswer((_) async => 'ubuntu');
        when(configService.get<String>('distro-name'))
            .thenAnswer((_) async => testCase.configDistroName);
        registerMockService<ConfigService>(configService);

        final distroName = (await FlavorService.load()).distroName;
        expect(distroName, equals(testCase.expectedName));
      });
    }
  });
}
