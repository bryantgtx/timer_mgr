import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:timer_mgr/harvest/auth/harvest_auth_repository.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:timer_mgr/harvest/harvest_api.dart';
import 'package:timer_mgr/oauth_creds.dart';
import 'package:timer_mgr/resources/strings.dart';

part 'harvest_auth_state.dart';
part 'harvest_auth_event.dart';

class HarvestAuthBloc extends Bloc<HarvestAuthEvent, HarvestAuthState> {
  final HarvestAuthRepository _repo;
  
  HarvestAuthBloc(this._repo) : 
    assert(_repo != null),
    super(HarvestAuthInitial());

  @override
  Stream<HarvestAuthState> mapEventToState(HarvestAuthEvent event) async* {
    if (event is HarvestAuthStarting) {
      yield* _mapHarvestAuthStarting(event);
    }
    else if (event is HarvestAuthLoginCompleted) {
      yield* _mapHarvestAuthLoginCompleted(event);
    }
    else if (event is HarvestAuthLoginFailed) {
      yield* _mapHarvestAuthLoginFailed(event);
    }
    else if (event is HarvestAuthLogout) {
      yield* _mapHarvestAuthLogout(event);
    }
    else if (event is HarvestAuthCredentialRefresh) {
      yield* _mapHarvestAuthCredentialRefresh(event);
    }
  }

  Stream<HarvestAuthState> _mapHarvestAuthStarting(HarvestAuthStarting event) async* {
    var credentials = _repo.loadCredentials();
    var accountId = _repo.loadAccountId();
    if (credentials == null || accountId == null) {
      yield HarvestAuthNoAuth();
    }
    else {
      var client = _buildClient(credentials);
      HarvestApi().accountId = accountId;
      HarvestApi().client = client;
      yield HarvestAuthComplete();
    }
  }

  Stream<HarvestAuthState> _mapHarvestAuthLoginCompleted(HarvestAuthLoginCompleted event) async* {
    if (event.client == null || event.accountId.isEmpty) {
      yield HarvestAuthFailed(Strings.harvestOAuthGenericFailMessage);
    }
    else {
      await _repo.saveCredentials(event.client.credentials);
      await _repo.saveAccountId(event.accountId);
      HarvestApi().accountId = event.accountId;
      HarvestApi().client = event.client;
    yield HarvestAuthComplete();
    }
  }

  Stream<HarvestAuthState> _mapHarvestAuthLoginFailed(HarvestAuthLoginFailed event) async* {
    yield HarvestAuthFailed(event.errorMessage);
  }

  Stream<HarvestAuthState> _mapHarvestAuthLogout(HarvestAuthLogout event) async* {
    await _repo.clear();
    yield HarvestAuthNoAuth();
  }

  Stream<HarvestAuthState> _mapHarvestAuthCredentialRefresh(HarvestAuthCredentialRefresh event) async* {
    await _repo.saveCredentials(event.credentials);
    var client = _buildClient(event.credentials);
    HarvestApi().client = client;
    yield HarvestAuthComplete();
  }

  oauth2.Client _buildClient(oauth2.Credentials credentials) {
    return oauth2.Client(credentials, 
          identifier: OAuthCredentials.harvestId, 
          secret: OAuthCredentials.harvestSecret,
          basicAuth: false,
          onCredentialsRefreshed: _handleCredentialRefresh,
        );
  }

  void _handleCredentialRefresh(oauth2.Credentials credentials) {
    this.add(HarvestAuthCredentialRefresh(credentials));
  }
}