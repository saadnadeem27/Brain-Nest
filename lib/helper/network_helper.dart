import 'dart:async';
import 'dart:io';

///
/// This class checks if device has internet connectivity or not
///
class NetworkManager {
  static final NetworkManager shared = NetworkManager._internal();

  NetworkManager._internal();

  factory NetworkManager() {
    return shared;
  }

  Future<bool> isConnected() async {
    try {
      final List<InternetAddress> result =
          await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
}
