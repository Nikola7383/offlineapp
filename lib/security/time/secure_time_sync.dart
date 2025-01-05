class SecureTimeSync {
  final List<String> _trustedTimeSources = [];

  Future<DateTime> getSecureTime() async {
    List<DateTime> times = [];

    // Prikupljanje vremena iz više izvora
    for (var source in _trustedTimeSources) {
      times.add(await _getTimeFromSource(source));
    }

    // Median time za zaštitu od manipulacije
    return _calculateMedianTime(times);
  }
}
