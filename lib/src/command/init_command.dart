import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';

import 'flutter_ddd_init_bundle.dart';

/// {@macro init_command}
class InitCommand extends Command<int> {
  /// Initializes the init command with the logger.
  InitCommand({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  String get description => 'Initializes the basic requirements for a DDD architected project.';

  /// The name of the command.
  static const String commandName = 'init';

  @override
  String get name => commandName;

  @override
  Future<int> run() async {
    final bundle = flutterDddInitBundle; // Your Mason bundle for DDD setup
    final generator = await MasonGenerator.fromBundle(bundle);

    // Collect variables from the user
    final vars = <String, dynamic>{};

    // Ask for the feature name
    vars['project_name'] = _logger.prompt(
      'What is the name of the project?',
      defaultValue: 'example_feature',
    );

    // Ask if secure storage is required
    vars['uses_secure_storage'] = _logger.confirm(
      'Will this feature use secure storage?',
      defaultValue: false,
    );

    // Ask about state management
    vars['uses_state_management'] = _logger.confirm(
      'Do you want to use state management for this feature?',
      defaultValue: true,
    );

    if (vars['uses_state_management'] == true) {
      vars['state_management_library'] = _logger.chooseOne(
        'Which state management library do you want to use?',
        choices: ['riverpod', 'provider', 'bloc', 'getx', 'none'],
        defaultValue: 'riverpod',
      );
    } else {
      vars['state_management_library'] = 'none';
    }

    // Ask for HTTP client preference
    vars['http_client'] = _logger.chooseOne(
      'Which HTTP client library do you want to use?',
      choices: ['dio', 'http'],
      defaultValue: 'dio',
    );

    // Ask if environment modes are required
    vars['uses_env_mode'] = _logger.confirm(
      'Do you want to use environment modes (e.g., dev, prod)?',
      defaultValue: true,
    );

    if (vars['uses_env_mode'] == true) {
      final envModes = _logger.prompt(
        'Enter the environment modes to include (comma-separated):',
        defaultValue: 'dev,prod',
      );
      vars['env_modes'] = envModes.split(',').map((e) => e.trim()).toList();
    }

    vars['enable_logging'] = _logger.confirm(
      'Do you want to enable logging?',
      defaultValue: true,
    );

    vars['navigation_library'] = _logger.chooseOne(
      'Which navigation library to use?',
      choices: ['go_router', 'auto_route'],
      defaultValue: 'auto_route',
    );

    vars['enable_testing'] = _logger.confirm(
      'Enable testing setup?',
      defaultValue: true,
    );

    vars['testing_library'] = _logger.chooseOne(
      'Which testing library to use?',
      choices: ['flutter_test', 'mockito', 'bloc_test'],
      defaultValue: 'auto_route',
    );

    vars['enable_navigation'] = _logger.confirm(
      'Use a navigation library?',
      defaultValue: true,
    );
    // Log the initialization start
    _logger.info('👨‍🔧 Initializing the project for DDD architecture...');

    // Execute Mason generator with collected variables
    await generator.hooks.preGen(
      vars: vars,
      onVarsChanged: (v) => vars.addAll(v),
      logger: _logger,
    );

    await generator.generate(
      DirectoryGeneratorTarget(Directory.current),
      vars: vars,
      logger: _logger,
    );

    await generator.hooks.postGen(
      vars: vars,
      onVarsChanged: (v) => vars.addAll(v),
      logger: _logger,
    );

    // Log the successful initialization
    _logger.success(
      '✅ Initialization completed successfully! '
      'The project structure and dependencies are set up for DDD architecture.',
    );

    return ExitCode.success.code;
  }
}
