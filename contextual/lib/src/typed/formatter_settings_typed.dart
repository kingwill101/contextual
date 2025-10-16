import 'package:dart_mappable/dart_mappable.dart';
import '../format/formatter_settings.dart' as core;

part 'formatter_settings_typed.mapper.dart';

@MappableClass()
class FormatterSettings with FormatterSettingsMappable {
  final bool includeInterpolation;

  const FormatterSettings({this.includeInterpolation = true});

  core.FormatterSettings toCore() => core.FormatterSettings(
    includeTimestamp: true,
    includeLevel: true,
    includePrefix: true,
    includeContext: true,
  );
}
