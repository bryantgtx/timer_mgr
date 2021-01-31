class Ticker {
  Stream<int> startTicking() {
    return Stream.periodic(Duration(seconds: 1), (_) => 1);
  }
}
