import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timer_mgr/app.dart';
import 'package:timer_mgr/harvest/auth/harvest_auth_bloc.dart';
import 'package:timer_mgr/harvest/auth/harvest_auth_repository.dart';
import 'package:timer_mgr/harvest/info/harvest_info_bloc.dart';
import 'package:timer_mgr/resources/strings.dart';
import 'package:timer_mgr/work_timer_list/work_timer_list_bloc.dart';
import 'package:timer_mgr/work_timer_list/work_timer_repository.dart';

import 'harvest/info/harvest_info_repository.dart';

void main(List<String> args) async {
 await Hive.initFlutter();
  final timerBox = await Hive.openBox(Strings.hiveTimerBoxName);
  final oauthBox = await Hive.openBox(Strings.oAuthCredsBoxName);
  final harvestInfoBox = await Hive.openBox(Strings.harvestHiveAssignmentBoxName);
  runApp(MultiBlocProvider(
      providers: [
        BlocProvider<WorkTimerListBloc>(
          create: (_)=> WorkTimerListBloc(repo: WorkTimerRepository(timerBox))
                          ..add(WorkTimerListLoad()),
          lazy: false,
        ), 
        BlocProvider<HarvestAuthBloc>(
          create: (_)=> HarvestAuthBloc(HarvestAuthRepository(oauthBox))
                          ..add(HarvestAuthStarting()),
          lazy: false,
        ), 
        BlocProvider<HarvestInfoBloc>(
          create: (_)=> HarvestInfoBloc(HarvestInfoRepository(harvestInfoBox)),
        ), 
     ], 
      child:  TimerApp(args),
    )
  );
}
