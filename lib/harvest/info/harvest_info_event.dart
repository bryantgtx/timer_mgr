part of 'harvest_info_bloc.dart';

abstract class HarvestInfoEvent extends Equatable {
  const HarvestInfoEvent();

  @override
  List<Object> get props => [];
}

class HarvestInfoEventLoad extends HarvestInfoEvent {
  final bool fromApi;
  HarvestInfoEventLoad({this.fromApi=false});
}

class HarvestInfoEventClear extends HarvestInfoEvent {}