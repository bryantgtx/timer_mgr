class OAuthCredentials {
  static get harvestId => const String.fromEnvironment("harvestId");
  static get harvestSecret => const String.fromEnvironment("harvestSecret");
}
