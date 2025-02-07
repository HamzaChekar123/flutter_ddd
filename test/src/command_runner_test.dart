import 'package:args/command_runner.dart';
import 'package:flutter_ddd/src/command/command_runner.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';
// ignore: depend_on_referenced_packages
import 'package:mason_logger/mason_logger.dart';

class _MockLogger extends Mock implements Logger {}

void main() {
  group("Futter Command runner ", () {
    late Logger logger;
    late FlutterDddCommandRunner commandRunner;

    setUp(() {
      logger = _MockLogger();
      commandRunner = FlutterDddCommandRunner(logger: logger);
    });

    test('can be instantiated without an explicit analytics/logger instance', () async {
      final commandRunner = FlutterDddCommandRunner();
      expect(commandRunner, isNotNull);
      expect(commandRunner, isA<FlutterDddCommandRunner>());
    });

    test('handles FormatException', () async {
      const exception = FormatException('oops!');
      var isFirstInvocation = true;
      when(() => logger.info(any())).thenAnswer((_) {
        if (isFirstInvocation) {
          isFirstInvocation = false;
          throw exception;
        }
      });
      final result = await commandRunner.run(['--version']);
      expect(result, equals(ExitCode.usage.code));
      verify(() => logger.err(exception.message)).called(1);
      verify(() => logger.info(commandRunner.usage)).called(1);
    });

    test('handles UsageException', () async {
      final exception = UsageException('oops!', 'exception usage');
      var isFirstInvocation = true;
      when(() => logger.info(any())).thenAnswer((_) {
        if (isFirstInvocation) {
          isFirstInvocation = false;
          throw exception;
        }
      });
      final result = await commandRunner.run(['--version']);
      expect(result, equals(ExitCode.usage.code));
      verify(() => logger.err(exception.message)).called(1);
      verify(() => logger.info('exception usage')).called(1);
    });
  });
}
