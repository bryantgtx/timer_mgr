part of 'harvest_auth_bloc.dart';

@immutable
abstract class HarvestAuthState extends Equatable {
  const HarvestAuthState();
  
  @override
  List<Object> get props => [];
}

class HarvestAuthInitial extends HarvestAuthState {}

class HarvestAuthNoAuth extends HarvestAuthState {}

class HarvestAuthComplete extends HarvestAuthState {}

class HarvestAuthFailed extends HarvestAuthState {
  final String errorMsg;
  HarvestAuthFailed(this.errorMsg);
  
  @override
  List<Object> get props => [errorMsg];
}
