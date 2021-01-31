import 'package:flutter/material.dart';
import 'package:timer_mgr/harvest/harvest_assignment_model.dart';
import 'package:timer_mgr/harvest/harvest_timer_task.dart';
import 'package:timer_mgr/resources/strings.dart';
import 'package:timer_mgr/work_timer/work_timer_model.dart';

class HarvestAssignmentWidget extends StatefulWidget {
  final HarvestAssignment assignment;
  final WorkTimer workTimer;
  final Function(HarvestTimerTask) onTaskSelected;
  HarvestAssignmentWidget(this.assignment, this.workTimer, this.onTaskSelected);

  @override
  _HarvestAssignmentState createState() => _HarvestAssignmentState();
}

class _HarvestAssignmentState extends State<HarvestAssignmentWidget> {
  HarvestClient _client;
  HarvestProject _project;
  HarvestTask _task;

  Widget _clientDropdown() {
    return DropdownButton(
      hint: Text(Strings.harvestSelectClientPrompt),
      value: _client,
      items: widget.assignment.clients.map((e) {
        return DropdownMenuItem(
          child: Text(e.name),
          value: e,
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _project = null;
          _task = null;
          _client = newValue;
        });
      },
    );
  }

  Widget _projectDropdown() {
    return _client != null 
      ? DropdownButton(
          hint: Text(Strings.harvestSelectProjectPrompt),
          value: _project,
          items: _client.projects.map((e) {
            return DropdownMenuItem(
              child: Text(e.name),
              value: e,
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _task = null;
              _project = newValue;
            });
          },
        )
      : SizedBox.shrink();

  }

  Widget _taskDropdown() {
    return _project != null 
      ? DropdownButton(
          hint: Text(Strings.harvestSelectTaskPrompt),
          value: _task,
          items: _project.tasks.map((e) {
            return DropdownMenuItem(
              child: Text(e.name),
              value: e,
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _task = newValue;
              widget.onTaskSelected(
                HarvestTimerTask(
                  projectId: _project.id,
                  taskId: _task.id,
                  token: '${_client.name}: ${_project.name} (${_task.name})'
                )
              );
            });
          },
        )
      : SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _clientDropdown(),
        _projectDropdown(),
        _taskDropdown(),
      ],

    );
    
  }
}
