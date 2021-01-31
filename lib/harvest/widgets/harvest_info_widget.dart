import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timer_mgr/harvest/auth/harvest_auth_bloc.dart';
import 'package:timer_mgr/harvest/harvest_assignment_model.dart';
import 'package:timer_mgr/harvest/harvest_timer_task.dart';
import 'package:timer_mgr/harvest/info/harvest_info_bloc.dart';
import 'package:timer_mgr/harvest/widgets/harvest_assignment_widget.dart';
import 'package:timer_mgr/resources/strings.dart';
import 'package:timer_mgr/work_timer/work_timer_model.dart';

class HarvestInfoWidget extends StatefulWidget {
  final WorkTimer workTimer;
  HarvestInfoWidget(this.workTimer);

  @override
  _HarvestInfoWidgetState createState() => _HarvestInfoWidgetState();

}

class _HarvestInfoWidgetState extends State<HarvestInfoWidget> {
  List<HarvestProject> selectedProjects = [];
  List<HarvestTimerTask> timerTasks = [];

  Widget _titleBar() {
    var titleText = Strings.harvestTaskSelectTitle;

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

  List<Widget> buildWidgetList(HarvestInfoState state) {
    List<Widget> widgets = [];
    if (state is HarvestInfoNotLoaded) {
      BlocProvider.of<HarvestInfoBloc>(context)
        .add(HarvestInfoEventLoad());
      widgets.add(Text(Strings.harvestInfoLoading));
    }
    else if (state is HarvestInfoLoaded) {
      widgets.add(RaisedButton(
        onPressed: () async {
          BlocProvider.of<HarvestInfoBloc>(context)
            .add(HarvestInfoEventLoad(fromApi: true));
        },
        child: const Text(Strings.harvestInfoRefresh),
      ));
      widgets.add(
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: HarvestAssignmentWidget(state.assignment, widget.workTimer, (timerTask) {
              Navigator.pop(context, timerTask);
            }),
          ),
        )
      );
    }
    else {
      widgets.add(Row(
          children: <Widget> [
            Text(Strings.harvestInfoLoading),
            SizedBox(width: 10),
            CircularProgressIndicator(),
          ]
        ),
      );
    }
    widgets.add(RaisedButton(
      onPressed: () async {
        BlocProvider.of<HarvestAuthBloc>(context)
          .add(HarvestAuthLogout());
      },
      child: const Text(Strings.harvestLogoutButton),
    ));

    return widgets;
  }

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget> [
        RaisedButton(
          child: Text(Strings.harvestCancelSelectTask),
          onPressed: () => Navigator.pop(context),
        ),
      //   RaisedButton(
      //     child: Text(Strings.harvestSelectTask),
      //     onPressed: timerTasks.length > 0
      //       ? () => Navigator.pop(context, timerTasks)
      //       : null,
      //   ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HarvestInfoBloc, HarvestInfoState>(
      builder: (context, state) {
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
                        ...buildWidgetList(state),
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
    );
  }
}