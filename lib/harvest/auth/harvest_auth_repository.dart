import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:oauth2/oauth2.dart';
import 'package:timer_mgr/resources/strings.dart';

class HarvestAuthRepository {
  final JsonCodec codec;
  final Box _box;

  const HarvestAuthRepository(this._box, [this.codec = json]);

  Credentials loadCredentials() {
    var rawCreds = _box.get(Strings.harvestHiveCredentialsKey);
    if (rawCreds == null) return null;
    return Credentials.fromJson(rawCreds);
  }

  String loadAccountId() {
    return _box.get(Strings.harvestHiveAccountIdKey);
  }

  Future<void> saveCredentials(Credentials credentials) async {
    try {
      await _box.put(Strings.harvestHiveCredentialsKey, credentials.toJson());
    }
    catch (e) {
      print("Saving harvest credentials (${credentials.toJson()}) threw exception $e");
    }
  }

  Future<void> saveAccountId(String accountId) async {
    try {
      await _box.put(Strings.harvestHiveAccountIdKey, accountId);
    }
    catch (e) {
      print("Saving harvest accountd ($accountId) threw exception $e");
    }
  }

  Future<void> clear() async {
    await _box.delete(Strings.harvestHiveCredentialsKey);
    await _box.delete(Strings.harvestHiveAccountIdKey);
  }
}