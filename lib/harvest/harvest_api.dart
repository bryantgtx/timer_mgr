import 'dart:convert';

import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;
import 'package:timer_mgr/harvest/harvest_assignment_model.dart';
import 'package:timer_mgr/services/api_service.dart';

class HarvestApi extends ApiService {
  Map _harvestHeaders = Map<String, String>();
  oauth2.Client _client;

  static final HarvestApi _harvestApi =
      HarvestApi._constructor();

  factory HarvestApi() {
    return _harvestApi;
  }
  HarvestApi._constructor();

  @override
  get rootUrl => 'https://api.harvestapp.com/v2';

  @override
  set client(oauth2.Client value) => _client = value;

  set accountId(String value) {
    _harvestHeaders["Harvest-Account-Id"] = value;
  }

  String get accountId => _harvestHeaders["Harvest-Account-Id"] ?? '';

  Future<HarvestAssignment> fetchAllProjects() async {
    final path = '$rootUrl/users/me/project_assignments';
    http.Response response;
    try {
      response = await _client.get(path, headers: _harvestHeaders);
      if (responseOkay(response)) {
        var result = json.decode(response.body);
        return HarvestAssignment.fromApi(result);
      }
    }
    catch(e) {
      rethrow;
    }
    throw ApiServiceException(response.statusCode, response.reasonPhrase);
  }

  Future<bool> submitTimeEntry({int projectId, int taskId, double hours, DateTime spentDate, String description}) async {
    final path = '$rootUrl/time_entries';
    final body = jsonEncode(<String, dynamic>{
      'project_id': projectId,
      'task_id': taskId,
      'spent_date': spentDate.toIso8601String(),
      'hours': hours,
      'notes': description,
    });
    var headers = Map<String, String>.from(_harvestHeaders);
    headers['content-type'] = 'application/json';
    http.Response response = await _client.post(path, headers: headers, body: body);
    return responseOkay(response);
  }
}
