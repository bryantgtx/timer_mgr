import 'package:hive/hive.dart';
import 'package:timer_mgr/harvest/harvest_assignment_model.dart';
import 'package:timer_mgr/resources/strings.dart';

class HarvestInfoRepository {
  final Box _box;

  HarvestInfoRepository(this._box);

  HarvestAssignment loadHarvestAssignment() {
    var rawAssignment = _box.get(Strings.harvestHiveAssignmentKey);
    if (rawAssignment == null) return null;
    return HarvestAssignment.fromHive(rawAssignment);
  }

  Future<void> saveHarvestAssignment(HarvestAssignment assignment) async {
    try {
      await _box.put(Strings.harvestHiveAssignmentKey, assignment.toHive());
    }
    catch (e) {
      print("Saving harvest credentials (${assignment.toHive()}) threw exception $e");
    }
  }

  void clear() async {

  }
}