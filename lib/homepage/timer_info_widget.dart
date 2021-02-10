import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timer_mgr/harvest/auth/harvest_auth_bloc.dart';
import 'package:timer_mgr/harvest/widgets/harvest_info_widget.dart';
import 'package:timer_mgr/harvest/widgets/harvest_login_button.dart';
import 'package:timer_mgr/oauth_creds.dart';
import 'package:timer_mgr/resources/strings.dart';
import 'package:timer_mgr/work_timer/work_timer_model.dart';
import 'package:timer_mgr/work_timer/work_timer_task.dart';

class TimerInfoWidget extends StatefulWidget {
  final WorkTimer workTimer;
  TimerInfoWidget({Key key, this.workTimer}) : super(key: key);

  @override
  _TimerInfoWidgetState createState() => _TimerInfoWidgetState(workTimer);
}

class _TimerInfoWidgetState extends State<TimerInfoWidget> {
  final TextEditingController nameCtrlr = TextEditingController();
  final TextEditingController descriptionCtrlr = TextEditingController();
  bool enableCreate = false;
  List<WorkTimerTask> _tasks = [];

  _TimerInfoWidgetState(WorkTimer workTimer) {
    if (workTimer != null) {
      _tasks = List<WorkTimerTask>.from(workTimer.tasks);
    }
  }

  WorkTimer _validateFields() {
    if (nameCtrlr.text.isNotEmpty) {
      if (widget.workTimer == null) {
        return WorkTimer(name: nameCtrlr.text, description: descriptionCtrlr.text, tasks: _tasks);
      }
      return widget.workTimer.copyWith(
        name: nameCtrlr.text, 
        description: descriptionCtrlr.text,
        tasks: _tasks,
      );
    }
    return null;
  }

  void _onSubmit() {
    var timer = _validateFields();
    if (timer != null) {
      Navigator.pop(context, timer);
    }
  }

  Widget _titleBar() {
    var titleText = widget.workTimer == null 
      ? Strings.workTimerInfo_CreateTitle
      : Strings.workTimerInfo_EditTitle;

    return Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
      child: Text(
        titleText,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  List<Widget> _timerFieldWidgets() {
    if (widget.workTimer != null) {
      nameCtrlr.text = widget.workTimer.name;
      nameCtrlr.selection = TextSelection.fromPosition(TextPosition(offset: nameCtrlr.text.length));
      descriptionCtrlr.text = widget.workTimer.description;
      descriptionCtrlr.selection = TextSelection.fromPosition(TextPosition(offset: descriptionCtrlr.text.length));
    }

    var nameWidget = TextField(
      controller: nameCtrlr,
      onChanged: (value) {
        if (enableCreate != value.isNotEmpty) {
          setState(() {
            enableCreate = value.isNotEmpty;
          });
        }
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: Strings.workTimerInfo_TimerNameLabel,
      )
    );

    var descriptionWidget = TextField(
      controller: descriptionCtrlr,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: Strings.workTimerInfo_TimerDescriptionLabel,
      )
    );

    var tasksWidget = _tasks.length > 0
      ? Text(_tasks.map((e) => e.displayToken).join('; '))
      : Text(Strings.workTimerInfo_NoTasks);

    return <Widget> [
      nameWidget,
      SizedBox(height: 10),
      descriptionWidget,
      SizedBox(height: 10),
      tasksWidget,
      SizedBox(height: 10),
    ];
  }

  Widget _harvestInfo() {
    return BlocBuilder<HarvestAuthBloc, HarvestAuthState>(
      builder: (context, state) {
        Widget harvestWidget;
        if (state is HarvestAuthFailed) {
          harvestWidget = Row(
            children: <Widget>[
              Text(state.errorMsg),
              SizedBox(width: 10),
              HarvestLoginButton(
                harvestClientId: OAuthCredentials.harvestId, 
                harvestClientSecret: OAuthCredentials.harvestSecret
              ),
            ]
          );

        }
        else if (state is HarvestAuthNoAuth) {
          harvestWidget = HarvestLoginButton(
                harvestClientId: OAuthCredentials.harvestId, 
                harvestClientSecret: OAuthCredentials.harvestSecret
              );
        }
        else if (state is HarvestAuthComplete) {
          harvestWidget = MaterialButton(
            color: Colors.blueGrey,
            child: Text(Strings.harvestSelectTask),
            onPressed: () async {
              // Open the harvest task dialog
              var result = await showDialog(
                context: context,
                builder: (_) => HarvestInfoWidget(widget.workTimer),
              );
              if (result != null && result is WorkTimerTask) {
                setState(() {
                  _tasks.add(result);
                  enableCreate = true;
                });
              }
            }
          );
        }

        return Container(
          width: double.infinity,
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
          padding: EdgeInsets.all(15),
          child: harvestWidget,
        );
      },
    );
  }

  List<Widget> _thirdPartyTimecards() {
    return <Widget>[
      _harvestInfo(),
    ];
  }

  Widget _buttons() {
    var submitButtonText = Strings.workTimerInfo_SubmitButtonCreate;
    var cancelMessageText = Strings.workTimerInfo_CreateCancelMessage;
    if (widget.workTimer != null) {
      submitButtonText = Strings.workTimerInfo_SubmitButtonEdit;
      cancelMessageText = Strings.workTimerInfo_EditCancelMessage;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget> [
        ElevatedButton(
          child: Text(Strings.workTimerInfo_CancelButton),
          onPressed: () => Navigator.pop(context, cancelMessageText),
        ),
        ElevatedButton(
          child: Text(submitButtonText),
          onPressed: enableCreate
            ? _onSubmit
            : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.zero, 
          topRight: Radius.zero,
          bottomLeft: Radius.circular(20.0), 
          bottomRight: Radius.circular(20.0)
        )
      ),
      child: Column(
          children: <Widget>[
            _titleBar(),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(15),
                child: Column( 
                  children: <Widget>[
                    ..._timerFieldWidgets(),
                    ..._thirdPartyTimecards(),
                    SizedBox(height: 10),
                    _buttons(),
                  ],
                ),
              ),
            ),
          ]
        ),
    );
  }
}