import 'package:brain_nest/common/App_strings.dart';

class ValidationHelper {
  static const String patternEmail =
      r"^([a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$";
  static const String patternName = r'^[a-zA-Z\s]+$';
  static const String patternPassword = r'.{8,}$';
  static const String patternMobileNumber = r'^[0-9]{1,14}$';
  static const String patternAddress = r'^.{5,100}$';

  /// email validation
  static String? validateEmail(String value) {
    RegExp regExp = RegExp(patternEmail);
    if (value.isEmpty) {
      return AppStrings.pleaseEnterEmail;
    }
    if (regExp.hasMatch(value) == false) {
      return AppStrings.pleaseEnterValidEmail;
    }
    return null;
  }
}
