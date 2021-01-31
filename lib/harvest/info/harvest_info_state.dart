part of 'harvest_info_bloc.dart';

abstract class HarvestInfoState extends Equatable {
  const HarvestInfoState();
  
  @override
  List<Object> get props => [];
}

class HarvestInfoNotLoaded extends HarvestInfoState {}

class HarvestInfoLoading extends HarvestInfoState {}

class HarvestInfoLoaded extends HarvestInfoState {
  final HarvestAssignment assignment;
  HarvestInfoLoaded(this.assignment);
}