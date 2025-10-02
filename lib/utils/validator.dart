class Validator {
  static String? validateKKUMail(String? value) {
    if (value!.isEmpty) {
      return "Email is required";
    }

    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@(kku\.ac\.th|kkumail\.com)$');

    if (!regex.hasMatch(value)) {
      return "Enter a valid KKU mail (@kku.ac.th or @kkumail.com)";
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 6) return "At least 6 characters";
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return "Username is required";
    return null;
  }

  static String? validateConfirmPassword(String? v1, String? v2) {
    if (v2!.trim().isEmpty) {
      return "Confirm password is required";
    }
    if (v1!.trim() != v2.trim()) {
      return "Password not matching";
    }
    return null;
  }
}
