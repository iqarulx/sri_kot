import '/constants/constants.dart';

class FormValidation {
  // Common Validation Function
  String? commonValidation({
    required String? input,
    required bool isMandatory,
    required String formName,
    required bool isOnlyCharter,
  }) {
    if (input == null) {
      if (isMandatory) {
        return "$formName is must";
      }
    } else {
      input = input.trim();
      if (isMandatory || input.isNotEmpty) {
        if (input.isEmpty) {
          return "$formName is must";
        } else if (isOnlyCharter) {
          if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]').hasMatch(input)) {
            return "$formName is characters only allowed";
          }
        }
      }
    }
    return null;
  }

  String? emailValidation(
      {required String input, required labelName, required bool isMandatory}) {
    input = input.trim();
    String? error;
    if (isMandatory || input.isNotEmpty) {
      RegExp emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
      if (!emailRegex.hasMatch(input)) {
        error = 'Please enter a valid email address';
      }
    }
    return error;
  }

  String? gstValidation({required String input, required bool isMandatory}) {
    input = input.trim();
    String? error;

    final gstRegex =
        RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[0-9]{1}[Z]{1}[0-9A-Z]{1}$');

    if (isMandatory) {
      if (input.isEmpty) {
        error = "GST No is must";
      } else if (!gstRegex.hasMatch(input)) {
        error = 'Invalid GST number format';
      }
    }

    return error;
  }

  String? passwordValidation(
      {required String input, required int minLength, required int maxLength}) {
    input = input.trim();
    if (input.isEmpty) {
      return "Password is must";
    } else if (input.length < minLength) {
      return "Password at least $minLength characters long";
    } else if (!RegExp(r'[A-Z]').hasMatch(input)) {
      return PasswordError.upperCase.message;
    } else if (!RegExp(r'[a-z]').hasMatch(input)) {
      return PasswordError.lowerCase.message;
    } else if (!RegExp(r'[0-9]').hasMatch(input)) {
      return PasswordError.digit.message;
    } else if (!RegExp(r'[!@#\$&*~]').hasMatch(input)) {
      return PasswordError.specialCharacter.message;
    } else if (!RegExp(r'.{8,}').hasMatch(input)) {
      return PasswordError.eigthCharacter.message;
    } else {
      return null;
    }
  }

  String? aadhaarValidation(String input, bool isMandatory) {
    input = input.trim();
    input = input.replaceAll(RegExp(r"\s+"), "");
    if (isMandatory || input.isNotEmpty) {
      if (input.isEmpty) {
        return "Aadhaar is must";
      } else if (!RegExp(r'^[2-9]{1}[0-9]{3}[0-9]{4}[0-9]{4}$')
          .hasMatch(input)) {
        return "Aadhaar is Not Valid";
      }
    }
    return null;
  }

  String? panValidation(String input, bool isMandatory) {
    input = input.trim();
    input = input.replaceAll(RegExp(r"\s+"), ""); // Remove any whitespace
    if (isMandatory || input.isNotEmpty) {
      if (input.isEmpty) {
        return "PAN is required";
      } else if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(input)) {
        return "PAN is not valid";
      }
    }
    return null;
  }

  String? addressValidation(String input, bool isMandatory) {
    input = input.trim();
    input = input.replaceAll(RegExp(r"\s+"), "");
    if (isMandatory || input.isNotEmpty) {
      if (input.isEmpty) {
        //@#&()-_[]'":;.,/
      }
    }
    return null;
  }

  String? phoneValidation({
    required String input,
    required bool isMandatory,
    required String labelName,
  }) {
    input = input.trim().replaceAll(RegExp(r"\s+"), "");

    if (isMandatory) {
      if (input.isNotEmpty) {
        // Check for exactly 10 digits
        if (!RegExp(r'^\d{10}$').hasMatch(input)) {
          return "$labelName must be exactly 10 digits";
        }
      } else {
        return "$labelName is required";
      }
    }

    return null;
  }

  String? hsnCodeValidation({
    required String input,
    required bool isMandatory,
  }) {
    input = input.trim().replaceAll(RegExp(r"\s+"), "");

    if (isMandatory) {
      // if (input.isNotEmpty) {
      //   if (!RegExp(r'^\d{1,7}$').hasMatch(input)) {
      //     return "HSN must be less than 8 digits";
      //   }
      // } else {
      return "HSN is required";
      // }
    }

    return null;
  }

  String? pincodeValidation({
    required String input,
    required bool isMandatory,
  }) {
    input = input.trim().replaceAll(RegExp(r"\s+"), "");

    if (isMandatory) {
      if (input.isNotEmpty) {
        // Check for exactly 10 digits
        if (!RegExp(r'^\d{6}$').hasMatch(input)) {
          return "Pincode must be exactly 6 digits";
        }
      } else {
        return "Pincode is required";
      }
    }

    return null;
  }

  String? dateValidation({required String input, required String labelName}) {
    if (input.isEmpty) {
      return "$labelName is must";
    }
    return null;
  }
}
