part of 'harvest_auth_bloc.dart';

@immutable
abstract class HarvestAuthEvent extends Equatable {
  const HarvestAuthEvent();
  
  @override
  List<Object> get props => [];
}

class HarvestAuthStarting extends HarvestAuthEvent {}

class HarvestAuthLoginCompleted extends HarvestAuthEvent {
  final oauth2.Client client;
  final String accountId;
  HarvestAuthLoginCompleted(this.client, this.accountId);
}

class HarvestAuthLoginFailed extends HarvestAuthEvent {
  final String errorMessage;
  HarvestAuthLoginFailed(this.errorMessage);
}

class HarvestAuthCredentialRefresh extends HarvestAuthEvent {
  final oauth2.Credentials credentials;
  HarvestAuthCredentialRefresh(this.credentials);
}

class HarvestAuthLogout extends HarvestAuthEvent {}
