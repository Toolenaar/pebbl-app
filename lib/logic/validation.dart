class Validation {
  static bool isValidEmail(String email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    if (email.isEmpty || !RegExp(p).hasMatch(email)) {
      return false;
    }
    return true;
  }

  static bool isValidPassword(String value) {
    if (value.isEmpty) return false;
    return value.length >= 8;
  }

  static bool isValidUsername(String value) {
    if (value.isEmpty) return false;
    return value.length >= 3;
  }

  static bool isValidHandle(String value) {
    if (value.isEmpty) return false;
    String p = r'^(?!.*\.\.)(?!.*\.$)[^\W][\w.]{0,29}$';

    if (value.isEmpty || !RegExp(p).hasMatch(value)) {
      return false;
    }
    return true;
  }
}
