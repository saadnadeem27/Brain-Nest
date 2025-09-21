import 'package:get_storage/get_storage.dart';

class LocalStorageKeys {
  ///patient and provider
  static String baseURL = 'url';
  static String token = 'token';
  static String userRole = 'userRole';
  static String preAuthToken = 'preAuthToken';
  static String userDetails = 'userDetails';
}

class LocalStorage {
  static GetStorage localStorage = GetStorage();

  static read({required String key}) {
    return localStorage.read(key);
  }

  static readAll({required List<String> list}) {
    return list.map((key) => localStorage.read(key));
  }

  static write({required String key, required dynamic data}) {
    localStorage.write(key, data);
  }

  static writeAll({required Map<String, dynamic> map}) {
    map.forEach((key, value) {
      localStorage.write(key, value);
    });
  }

  static delete({required String key}) {
    return localStorage.remove(key);
  }

  static deleteAll() {
    return localStorage.erase();
  }

  static getAllKeys() {
    return localStorage.getKeys();
  }
}
