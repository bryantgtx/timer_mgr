import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;

abstract class ApiService {
  get rootUrl;

  set client(oauth2.Client value);

  bool responseOkay(http.BaseResponse response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }  
}

class ApiServiceException implements Exception {
  final String message;
  final int statusCode;
  const ApiServiceException(this.statusCode, this.message);

  @override
  String toString() => 'Status $statusCode: $message';
}