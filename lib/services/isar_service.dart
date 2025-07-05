import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:setpocket/models/settings_model.dart';
import 'package:setpocket/models/text_template.dart';
import 'package:setpocket/models/generation_history.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/models/converter_models/unit_template_model.dart';
import 'package:setpocket/models/converter_models/area_state_model.dart';
import 'package:setpocket/models/converter_models/currency_cache_model.dart';
import 'package:setpocket/models/converter_models/currency_preset_model.dart';
import 'package:setpocket/models/converter_models/currency_state_model.dart';
import 'package:setpocket/models/converter_models/data_state_model.dart';
import 'package:setpocket/models/converter_models/length_state_model.dart';
import 'package:setpocket/models/converter_models/length_preset_model.dart';
import 'package:setpocket/models/converter_models/mass_state_model.dart';
import 'package:setpocket/models/converter_models/number_system_state_model.dart';
import 'package:setpocket/models/converter_models/time_state_model.dart';
import 'package:setpocket/models/converter_models/weight_state_model.dart';
import 'package:setpocket/models/converter_models/volume_state_model.dart';
import 'package:setpocket/models/converter_models/temperature_state_model.dart';
import 'package:setpocket/models/converter_models/speed_state_model.dart';
import 'package:setpocket/models/converter_models/generic_preset_model.dart';
import 'package:setpocket/models/random_models/random_state_models.dart';

class IsarService {
  static late Isar isar;

  IsarService._();

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final schemas = [
      SettingsModelSchema,
      TemplateSchema,
      GenerationHistoryItemSchema,
      UnitTemplateModelSchema,
      P2PUserSchema,
      PairingRequestSchema,
      DataTransferTaskSchema,
      FileTransferRequestSchema,
      P2PDataTransferSettingsSchema,
      P2PFileStorageSettingsSchema,
      AreaStateModelSchema,
      CurrencyCacheModelSchema,
      CurrencyPresetModelSchema,
      CurrencyStateModelSchema,
      DataStateModelSchema,
      LengthStateModelSchema,
      LengthPresetModelSchema,
      MassStateModelSchema,
      NumberSystemStateModelSchema,
      TimeStateModelSchema,
      WeightStateModelSchema,
      VolumeStateModelSchema,
      TemperatureStateModelSchema,
      SpeedStateModelSchema,
      GenericPresetModelSchema,
      NumberGeneratorStateSchema,
      PasswordGeneratorStateSchema,
      DateGeneratorStateSchema,
      ColorGeneratorStateSchema,
      DateTimeGeneratorStateSchema,
      TimeGeneratorStateSchema,
      SimpleGeneratorStateSchema,
      UuidGeneratorStateSchema,
      StringGeneratorStateSchema,
      ListGeneratorStateSchema,
      DiceRollGeneratorStateSchema,
      LatinLetterGeneratorStateSchema,
      PlayingCardGeneratorStateSchema,
    ];

    if (kDebugMode) {
      isar = await Isar.open(
        schemas,
        directory: dir.path,
        inspector: true,
      );
    } else {
      isar = await Isar.open(
        schemas,
        directory: dir.path,
      );
    }
  }

  static Future<void> close() async {
    await isar.close();
  }
}
