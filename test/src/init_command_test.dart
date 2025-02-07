import 'package:flutter_ddd/src/command/command_runner.dart';

import 'package:mason_logger/mason_logger.dart';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

void main() {
  group("Init Command", () {
    late Logger logger;
    late FlutterDddCommandRunner commandRunner;

    setUp(() {
      logger = _MockLogger();
      commandRunner = FlutterDddCommandRunner(logger: logger);

      when(() => logger.prompt(any(), defaultValue: any(named: 'defaultValue'))).thenReturn('test_feature');

      // ✅ Ensure `confirm()` returns true by default
      when(() => logger.confirm(any(), defaultValue: any(named: 'defaultValue'))).thenReturn(true);

      // ✅ Ensure `chooseOne()` returns a valid choice
      when(() => logger.chooseOne(
            any(),
            choices: any(named: 'choices'),
            defaultValue: any(named: 'defaultValue'),
          )).thenReturn('riverpod');
    });

    test('runs successfully', () async {
      when(() => logger.prompt(any(), defaultValue: any(named: 'defaultValue'))).thenReturn('test_feature');
      when(() => logger.confirm(any(), defaultValue: any(named: 'defaultValue'))).thenReturn(true);
      when(() => logger.chooseOne(any(), choices: any(named: 'choices'), defaultValue: any(named: 'defaultValue')))
          .thenReturn('riverpod');

      final exitCode = await commandRunner.run(['init']);
      expect(exitCode, ExitCode.success.code);

      verify(() => logger.info(any(that: contains('Initializing the project for DDD architecture...')))).called(1);
      verify(() => logger.success(any(that: contains('Initialization completed successfully')))).called(1);
    });
  });
}
