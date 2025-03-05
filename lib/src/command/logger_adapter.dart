import 'package:mason/mason.dart';

/// An adapter for Logger that allows easier mocking of interactive methods
/// while still providing access to the original Mason Logger
class LoggerAdapter {
  final Logger _logger;

  LoggerAdapter(this._logger);

  /// Provides direct access to the original Mason Logger
  Logger get originalLogger => _logger;

  /// Delegates logging methods to the original logger
  void info(String message) => _logger.info(message);
  void err(String message) => _logger.err(message);
  void detail(String message) => _logger.detail(message);
  void success(String message) => _logger.success(message);

  /// Mockable implementation of prompt
  String prompt(
    String message, {
    String? defaultValue,
  }) {
    return _logger.prompt(message, defaultValue: defaultValue);
  }

  /// Mockable implementation of confirm
  bool confirm(
    String message, {
    bool? defaultValue,
  }) {
    return _logger.confirm(message, defaultValue: defaultValue ?? false);
  }

  /// Mockable implementation of chooseOne
  String chooseOne<T>(
    String message, {
    required List<String> choices,
    String? defaultValue,
  }) {
    return _logger.chooseOne(message, choices: choices, defaultValue: defaultValue);
  }
}
