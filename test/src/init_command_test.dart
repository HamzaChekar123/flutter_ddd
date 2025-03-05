import 'package:flutter_ddd/src/command/command.dart';
import 'package:flutter_ddd/src/command/flutter_ddd_init_bundle.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mocks and Fakes
class MockLogger extends Mock implements Logger {}

class MockMasonGenerator extends Mock implements MasonGenerator {}

class FakeGeneratorTarget extends Fake implements GeneratorTarget {}

class FakeMasonBundle extends Fake implements MasonBundle {}

void main() {
  // Register fallback values before tests
  setUpAll(() {
    registerFallbackValue(FakeGeneratorTarget());
    registerFallbackValue(const <String, dynamic>{});
    registerFallbackValue(FakeMasonBundle());
  });

  group('InitCommand', () {
    late InitCommand initCommand;
    late MockLogger mockLogger;
    late MockMasonGenerator mockGenerator;

    setUp(() {
      mockLogger = MockLogger();
      mockGenerator = MockMasonGenerator();

      // Setup default mock behaviors
      when(() => mockLogger.prompt(any(), defaultValue: any(named: 'defaultValue'))).thenReturn('example_project');
      when(() => mockLogger.confirm(any(), defaultValue: any(named: 'defaultValue'))).thenReturn(true);
      when(() => mockLogger.chooseOne(any(), choices: any(named: 'choices'), defaultValue: any(named: 'defaultValue')))
          .thenReturn('riverpod');

      // Setup generator mocks
      when(() => mockGenerator.hooks).thenReturn(const GeneratorHooks());
      when(() => mockGenerator.generate(any(), vars: any(named: 'vars'), logger: any(named: 'logger')))
          .thenAnswer((_) async => []);

      initCommand = InitCommand(logger: mockLogger);
    });

    test('command properties are correct', () {
      expect(initCommand.name, 'init');
      expect(initCommand.description, 'Initializes the basic requirements for a DDD architected project.');
    });

    test('run method collects project configuration correctly', () async {
      // Setup expectations for various method calls
      when(() => mockLogger.success(any())).thenReturn(null);

      // Mock MasonGenerator creation
      when(() => MasonGenerator.fromBundle(flutterDddInitBundle)).thenAnswer((_) async => mockGenerator);

      final exitCode = await initCommand.run();

      // Verify configuration collection
      verify(() => mockLogger.prompt('What is the name of the project?', defaultValue: 'example_feature')).called(1);

      verify(() => mockLogger.confirm('Will this feature use secure storage?', defaultValue: false)).called(1);

      verify(() => mockLogger.confirm('Do you want to use state management for this feature?', defaultValue: true))
          .called(1);

      // Verify generator methods were called
      verify(() => mockGenerator.hooks.preGen(
          vars: any(named: 'vars'),
          onVarsChanged: any(named: 'onVarsChanged'),
          logger: any(named: 'logger'))).called(1);

      verify(() => mockGenerator.generate(any(), vars: any(named: 'vars'), logger: any(named: 'logger'))).called(1);

      verify(() => mockGenerator.hooks.postGen(
          vars: any(named: 'vars'),
          onVarsChanged: any(named: 'onVarsChanged'),
          logger: any(named: 'logger'))).called(1);

      expect(exitCode, ExitCode.success.code);
    });

    test('handles state management selection when not using state management', () async {
      // Mock no state management
      when(() => mockLogger.confirm('Do you want to use state management for this feature?', defaultValue: true))
          .thenReturn(false);

      // Mock MasonGenerator creation
      when(() => MasonGenerator.fromBundle(flutterDddInitBundle)).thenAnswer((_) async => mockGenerator);
      when(() => mockLogger.success(any())).thenReturn(null);

      // Capture the vars passed to generate method
      Map<String, dynamic>? capturedVars;
      when(() => mockGenerator.generate(any(), vars: any(named: 'vars'), logger: any(named: 'logger')))
          .thenAnswer((invocation) {
        capturedVars = invocation.namedArguments[#vars] as Map<String, dynamic>?;
        return Future.value([]);
      });

      final exitCode = await initCommand.run();

      // Assert that state management library is set to 'none'
      expect(capturedVars?['state_management_library'], equals('none'));
      expect(exitCode, ExitCode.success.code);
    });

    test('handles environment modes configuration', () async {
      // Mock environment modes configuration
      when(() => mockLogger.confirm('Do you want to use environment modes (e.g., dev, prod)?', defaultValue: true))
          .thenReturn(true);
      when(() =>
              mockLogger.prompt('Enter the environment modes to include (comma-separated):', defaultValue: 'dev,prod'))
          .thenReturn('dev,staging,prod');

      // Mock MasonGenerator creation
      when(() => MasonGenerator.fromBundle(flutterDddInitBundle)).thenAnswer((_) async => mockGenerator);
      when(() => mockLogger.success(any())).thenReturn(null);

      // Capture the vars passed to generate method
      Map<String, dynamic>? capturedVars;
      when(() => mockGenerator.generate(any(), vars: any(named: 'vars'), logger: any(named: 'logger')))
          .thenAnswer((invocation) {
        capturedVars = invocation.namedArguments[#vars] as Map<String, dynamic>?;
        return Future.value([]);
      });

      final exitCode = await initCommand.run();

      // Assert environment modes are correctly processed
      expect(capturedVars?['env_modes'], isA<List<String>>());
      expect(capturedVars?['env_modes'], containsAll(['dev', 'staging', 'prod']));
      expect(exitCode, ExitCode.success.code);
    });
  });
}
