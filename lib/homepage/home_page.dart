import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timer_mgr/homepage/timer_info_widget.dart';
import 'package:timer_mgr/homepage/timer_listener.dart';
import 'package:timer_mgr/resources/strings.dart';
import 'package:timer_mgr/work_timer/work_timer_bloc.dart';
import 'package:timer_mgr/services/ticker.dart';
import 'package:timer_mgr/work_timer/work_timer_model.dart';
import 'package:timer_mgr/homepage/work_timer_widget.dart';
import 'package:timer_mgr/work_timer_list/work_timer_list_bloc.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void _createWorkTimer() async {
    var result = await showDialog(
      context: context,
      builder: (_) => TimerInfoWidget(),
    );
    //timer = WorkTimer("Timer ${_timers.length+1}", "testing");
    if (result != null) {
      if (result is WorkTimer) {
        BlocProvider.of<WorkTimerListBloc>(context).add(WorkTimerListAdd(timer: result));
      }
      else if (result is String) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result),
                  duration: Duration(seconds: 2))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget itemBuilder(BuildContext context, int index) {
      var state = BlocProvider.of<WorkTimerListBloc>(context).state as WorkTimerListReady;
      var bloc = WorkTimerBloc(workTimer: state.timers[index], ticker: Ticker());
      var provider = BlocProvider<WorkTimerBloc>(
        create: (context) => bloc..add(WorkTimerReset()),
        child: WorkTimerWidget(state.timers[index]),
        lazy: false,
      );
      WorkTimerListener().addBloc(bloc);

      return provider;
    }
    
    return BlocBuilder<WorkTimerListBloc, WorkTimerListState>(
      builder: (context, state) {
        if (state is WorkTimerListReady) {
          WorkTimerListener().clear();
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: ListView.builder(
                itemCount: state.timers.length,
                itemBuilder: itemBuilder
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _createWorkTimer,
              tooltip: Strings.homePage_FabHint,
              child: Icon(Icons.add),
            ), 
          );
        }

        return CircularProgressIndicator();
      }
    );
    
  }
}