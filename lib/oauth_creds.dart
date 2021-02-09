class OAuthCredentials {
  static var args = Map<String, String>();
  static get harvestId => args['harvestId'] != null 
    ? args['harvestId']
    : const String.fromEnvironment('harvestId');
  static get harvestSecret => args['harvestSecret'] != null 
    ? args['harvestSecret']
    : const String.fromEnvironment('harvestSecret');
}
