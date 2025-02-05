import 'dart:io';

import 'package:mason/mason.dart';
import 'package:yaml_magic/yaml_magic.dart';

void run(HookContext context) async {
  final logger = context.logger;
  logger.info('🔄 Configuring project setup... ');

  //* get user =-selected variables
  final stateManagment = context.vars['state_management_library'] ?? 'riverpod';
  final httpClient = context.vars['http_client'] ?? 'dio';
  final enableLogging = context.vars['enable_logging'] == true;
  final loggingLibrary = context.vars['logging_library'] ?? 'logger';
  final enableDI = context.vars['enable_dependency_injection'] == true;
  final diLibrary = context.vars['dependency_injection_library'] ?? 'get_it';
  final enableNavigation = context.vars['enable_navigation'] == true;
  final navigationLibrary = context.vars['navigation_library'] ?? 'auto_route';

  //* update pubspec.yaml
  _addDependencies([
    if (stateManagment == 'riverpod') 'flutter_riverpod',
    if (stateManagment == 'provider') 'provider',
    if (stateManagment == 'bloc') 'flutter_bloc',
    if (stateManagment == 'getx') 'get',
    if (httpClient == 'dio') 'dio',
    if (httpClient == 'http') 'http',
    if (enableLogging) loggingLibrary,
    if (enableDI) diLibrary,
    if (enableNavigation) navigationLibrary,
  ], logger);

  final devDependencies = [
    'auto_route_generator',
    'build_runner',
    'custom_lint',
    'envied_generator',
    'flutter_gen_runner',
    'freezed',
    'json_serializable',
    'lint',
  ];
  final yaml = YamlMagic.load('pubspec.yaml');

  yaml.map.putIfAbsent('flutter', () => {}).putIfAbsent('generate', () => true);

  await yaml.save();

  final progress = logger.progress('Running build_runner');

  progress.update('Running build_runner');
  _addDevDependencies(devDependencies, logger);

  await Process.run(
    'dart',
    [
      'run',
      'build_runner',
      'clean',
    ],
    runInShell: Platform.isWindows,
  );

  await Process.run(
    'dart',
    [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ],
    runInShell: Platform.isWindows,
  );
  progress.complete('build_runner completed');
}

void _addDependencies(List<String> packages, Logger logger) {
  for (var package in packages) {
    if (package.isNotEmpty) {
      logger.info('📦 Adding dependency: $package...');
      Process.run(
        'flutter',
        ['pub', 'add', package],
        runInShell: Platform.isWindows,
      ).then((result) {
        if (result.exitCode != 0) {
          logger.warn('Failed to add dependency: $package');
          logger.warn(result.stderr);
          return;
        }
        logger.alert(result.stdout);
        logger.info('✅ Added dependency: $package');
      });
    }
  }
}

void _addDevDependencies(List<String> packages, Logger logger) {
  for (var package in packages) {
    if (package.isNotEmpty) {
      logger.info('📦 Adding dev_dependency: $package...');
      Process.run(
        'flutter',
        ['pub', 'add', '--dev', package],
        runInShell: Platform.isWindows,
      ).then((result) {
        if (result.exitCode != 0) {
          logger.warn('Failed to add dev_dependency: $package');
          logger.warn(result.stderr);
          return;
        }
        logger.alert(result.stdout);
        logger.info('✅ Added dev_dependency: $package');
      });
    }
  }
}
