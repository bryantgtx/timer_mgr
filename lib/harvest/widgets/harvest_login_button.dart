import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:timer_mgr/harvest/auth/harvest_auth_bloc.dart';
import 'package:timer_mgr/resources/strings.dart';
import 'package:url_launcher/url_launcher.dart';

final _authorizationEndpoint = Uri.parse('https://id.getharvest.com/oauth2/authorize');
final _tokenEndpoint = Uri.parse('https://id.getharvest.com/api/v2/oauth2/token');

@immutable
class HarvestLoginButton extends StatefulWidget {
  final String harvestClientId;
  final String harvestClientSecret;

  const HarvestLoginButton({
    @required this.harvestClientId,
    @required this.harvestClientSecret,
  });

  @override
  _HarvestLoginButtonState createState() => _HarvestLoginButtonState();
}

class _HarvestLoginButtonState extends State<HarvestLoginButton> {
  HttpServer _redirectServer;

  Future<void> _getOAuth2Client(BuildContext context, Uri redirectUrl) async {
    if (widget.harvestClientId.isEmpty || widget.harvestClientSecret.isEmpty) {
      throw const HarvestLoginException(
          'harvestClientId and harvestClientSecret must be not empty. '
          'See `lib/oauth_creds.dart` for more detail.');
    }
    var grant = oauth2.AuthorizationCodeGrant(
      widget.harvestClientId,
      _authorizationEndpoint,
      _tokenEndpoint,
      secret: widget.harvestClientSecret,
      httpClient: _JsonAcceptingHttpClient(),
      basicAuth: false,
      onCredentialsRefreshed: _handleCredentialRefresh,
    );
    var authorizationUrl =
        grant.getAuthorizationUrl(redirectUrl);

    await _redirect(authorizationUrl);
    var responseQueryParameters = await _listen();
    if (responseQueryParameters['error'] != null) {
      BlocProvider.of<HarvestAuthBloc>(context)
        .add(HarvestAuthLoginFailed(responseQueryParameters['error']));
    }
    else {
      var client =
        await grant.handleAuthorizationResponse(responseQueryParameters);
      var scope = responseQueryParameters["scope"].split(":");
      if (scope.length == 2) {
        BlocProvider.of<HarvestAuthBloc>(context)
          .add(HarvestAuthLoginCompleted(client, scope[1]));
      }
      else {
        throw HarvestLoginException(Strings.harvestInvalidResponse);
      }
    }
    return;
  }

  Future<void> _redirect(Uri authorizationUrl) async {
    var url = authorizationUrl.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw HarvestLoginException('Could not launch $url');
    }
  }

  Future<Map<String, String>> _listen() async {
    try {
      var request = await _redirectServer.first;
      var params = request.uri.queryParameters;
      request.response.statusCode = 200;
      request.response.headers.set('content-type', 'text/html');
      request.response.writeln(params['error'] == null
        ? Strings.harvestAuthenticatedWebMessage
        : Strings.harvestNotAuthenticatedWebMessage);
        request.response.writeln(Strings.harvestOAuthDone);
      await request.response.close();
      await _redirectServer.close();
      _redirectServer = null;
      return params;
    }
    catch (e) {
      // if the user closes the window/tab, the listener handles it . . . poorly
      await _redirectServer.close();
      _redirectServer = null;
    }
    return Map<String, String>();
  }

  void _handleCredentialRefresh(oauth2.Credentials credentials) {
    BlocProvider.of<HarvestAuthBloc>(context).add(HarvestAuthCredentialRefresh(credentials));
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () async {
        await _redirectServer?.close();
        // Harvest requires a specified port
        _redirectServer = await HttpServer.bind('localhost', 56656);
        await _getOAuth2Client(
            context,
            Uri.parse('http://localhost:${_redirectServer.port}/auth')
        );
      },
      child: const Text(Strings.harvestLoginButton),
    );
  }

}

class _JsonAcceptingHttpClient extends http.BaseClient {
  final _httpClient = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return _httpClient.send(request);
  }
}

class HarvestLoginException implements Exception {
  const HarvestLoginException(this.message);
  final String message;
  @override
  String toString() => message;
}