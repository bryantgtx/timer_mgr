import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:timer_mgr/harvest/harvest_api.dart';
import 'package:timer_mgr/harvest/harvest_assignment_model.dart';
import 'package:timer_mgr/harvest/info/harvest_info_repository.dart';

part 'harvest_info_event.dart';
part 'harvest_info_state.dart';

class HarvestInfoBloc extends Bloc<HarvestInfoEvent, HarvestInfoState> {
  final int maxCacheAge = 7;

  final HarvestInfoRepository _repo;
  HarvestInfoBloc(this._repo) : 
    assert(_repo != null),
    super(HarvestInfoNotLoaded());

  @override
  Stream<HarvestInfoState> mapEventToState(
    HarvestInfoEvent event,
  ) async* {
    if (event is HarvestInfoEventLoad) {
      yield* _mapHarvestInfoEventLoad(event);
    }
    else if (event is HarvestInfoEventClear) {
      yield* _mapHarvestInfoEventClear(event);
    }
  }

  Stream<HarvestInfoState> _mapHarvestInfoEventLoad(HarvestInfoEventLoad event) async* {
    yield HarvestInfoLoading();
    try {
      var assignment = event.fromApi ? null : _repo.loadHarvestAssignment();
      // if not found or old, load from API
      if (assignment == null || assignment.createdAt.difference(DateTime.now()).inDays > maxCacheAge) {
        assignment = await HarvestApi().fetchAllProjects();
        await _repo.saveHarvestAssignment(assignment);
      }
      yield HarvestInfoLoaded(assignment);
    }
    catch(e)
    {
      print('Harvest Project fetch failed: $e');
      yield HarvestInfoNotLoaded();
    }
  }

  Stream<HarvestInfoState> _mapHarvestInfoEventClear(HarvestInfoEventClear event) async* {
    yield HarvestInfoNotLoaded();
  }
}