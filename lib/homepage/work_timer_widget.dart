import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timer_mgr/homepage/timer_info_widget.dart';
import 'package:timer_mgr/resources/strings.dart';
import 'package:timer_mgr/services/time_functions.dart';
import 'package:timer_mgr/widgets/sliding_switch.dart';
import 'package:timer_mgr/work_timer/work_timer_bloc.dart';
import 'package:timer_mgr/work_timer/work_timer_model.dart';
import 'package:timer_mgr/work_timer_list/work_timer_list_bloc.dart';

enum ContextMenuOptions { edit, delete }

class WorkTimerWidget extends StatefulWidget {
  final WorkTimer workTimer;

  WorkTimerWidget(this.workTimer, {Key key}) : super(key: key);

  @override
  _WorkTimerWidgetState createState() => _WorkTimerWidgetState();
}


class _WorkTimerWidgetState extends State<WorkTimerWidget> {
  final double maxComponentHeight = 35.0;
  final double iconHeight = 24.0;
  final TextEditingController durationCtrlr = TextEditingController();
  final focusDuration = FocusNode();
  bool isEntryMode = false;

  String convertDecimalTime(String value) {
    return value.contains(':')
      ? value
      : TimeFunctions.timeFormatFromHours(double.parse(value));
  }

  @override
  void initState() {
    super.initState();
    focusDuration.addListener(() {
      if (!focusDuration.hasFocus) {
        durationCtrlr.text = convertDecimalTime(durationCtrlr.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var contextMenuItems = <PopupMenuEntry<ContextMenuOptions>>[
      PopupMenuItem(
        value: ContextMenuOptions.edit,
        child: Text(Strings.workTimerWidget_MenuEdit),
      ),
      PopupMenuItem(
        value: ContextMenuOptions.delete,
        child: Text(Strings.workTimerWidget_MenuDelete),
      ),
    ];

    List<Widget> timerModeControls(WorkTimerReadyState state) {
      return <Widget>[
        IconButton(
          icon: Icon(Icons.play_arrow),
          iconSize: iconHeight,
          tooltip: Strings.workTimerWidget_PlayHint,
          onPressed: state is WorkTimerReadyState || state is WorkTimerPausedState
          ? () => BlocProvider.of<WorkTimerBloc>(context).add(WorkTimerStart())
          : null,
        ),
        IconButton(
          icon: Icon(Icons.stop),
          iconSize: iconHeight,
          tooltip: Strings.workTimerWidget_StopHint,
          onPressed: state is WorkTimerRunningState || state is WorkTimerPausedState
            ? () => BlocProvider.of<WorkTimerBloc>(context).add(WorkTimerStop())
            : null,
        ),
        IconButton(
          icon: Icon(Icons.pause),
          iconSize: iconHeight,
          tooltip: Strings.workTimerWidget_PauseHint,
          onPressed: state is WorkTimerRunningState
            ? () => BlocProvider.of<WorkTimerBloc>(context).add(WorkTimerPause())
            : null,
        ),
      ];
    }

    void onDurationSubmit() {
      // Just clicking the submit button does not trigger the loss of focus, so need
      // to duplicate that conversion
      durationCtrlr.text = convertDecimalTime(durationCtrlr.text);
      int duration = TimeFunctions.parseSeconds(durationCtrlr.text);
      if (duration > 0) {
        BlocProvider.of<WorkTimerBloc>(context)
          ..add(WorkTimerTicked(duration: duration))
          ..add(WorkTimerStop());
      }
      durationCtrlr.text = '';
    }

    List<Widget> timeDisplayControls(WorkTimerReadyState state) {
      if (isEntryMode) {
        return <Widget>[
          SizedBox(
            width: 75,
            height: maxComponentHeight,
            child: TextField(
              controller: durationCtrlr,
              focusNode: focusDuration,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: Strings.workTimerWidget_durationLabel,
              )
            ),
          ),
          IconButton(
            icon: Icon(Icons.input),
            iconSize: iconHeight,
            tooltip: Strings.workTimerWidget_submitTimeHint,
            onPressed: state is WorkTimerReadyState
            ? onDurationSubmit
            : null,
            ),
        ];
      }
      else {
        return <Widget>[
          Text("${TimeFunctions.timeFormatFromSeconds(state.timer.elapsed)}"),
          ...timerModeControls(state),
        ];
      }
    }

    Future<void> contextMenuSelected(ContextMenuOptions option) async {
      print("selected $option from context menu");
      switch (option) {
        case ContextMenuOptions.delete:
          BlocProvider.of<WorkTimerListBloc>(context).add(WorkTimerListRemove(id: widget.workTimer.id));
          break;
        case ContextMenuOptions.edit:
          var result = await showDialog(
            context: context,
            builder: (_) => TimerInfoWidget(workTimer: widget.workTimer,),
          );

          if (result != null) {
            if (result is WorkTimer) {
              BlocProvider.of<WorkTimerListBloc>(context).add(WorkTimerListUpdate(timer: result));
            }
            else if (result is String) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result),
                        duration: Duration(seconds: 2))
              );
            }
          }
          break;
      }
    }

    return BlocBuilder<WorkTimerBloc, WorkTimerReadyState>(
      builder: (context, state) {
        // put the container that defines the card inside a row, else the width in the Container will have no effect
        return Row(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(5, 5), 
                  ),
                ],
              ),
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
              width: 500,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.workTimer.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ...timeDisplayControls(state),
                  SizedBox(width:15),
                  SlidingSwitch(
                    value: isEntryMode, 
                    textOff: Strings.workTimerWidget_timerHint,
                    textOn: Strings.workTimerWidget_inputHint,
                    iconOff: Icons.hourglass_empty,
                    iconOn: Icons.input,
                    width: 100,
                    height: maxComponentHeight,
                    contentSize: iconHeight,
                    onChanged: (bool value) {
                      setState(() {
                        isEntryMode = value;
                      });
                    }
                  ),
                  SizedBox(width:15),
                  PopupMenuButton<ContextMenuOptions>(
                    tooltip: Strings.workTimerWidget_timerMenuHint,
                    onSelected: contextMenuSelected,
                    itemBuilder: (BuildContext context) => contextMenuItems,
                  )
                ],
              ),
            ),
          ]
        );
      },
    );
  }
}