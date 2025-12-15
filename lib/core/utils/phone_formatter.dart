import 'package:flutter/services.dart';

/// Utility class for phone number formatting
/// Formats phone numbers as (XXX) XXX-XXXX
class PhoneFormatter {
  /// Formats a raw phone number string (digits only) to (XXX) XXX-XXXX format
  /// Returns the formatted string or the original if less than 10 digits
  static String format(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return '';

    // Extract only digits
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length < 10) {
      // Return partial formatting for incomplete numbers
      if (digits.isEmpty) return '';
      if (digits.length <= 3) return '(${digits}';
      if (digits.length <= 6) {
        return '(${digits.substring(0, 3)}) ${digits.substring(3)}';
      }
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }

    // Full 10-digit format
    final areaCode = digits.substring(0, 3);
    final prefix = digits.substring(3, 6);
    final lineNumber = digits.substring(6, 10);

    return '($areaCode) $prefix-$lineNumber';
  }

  /// Extracts only digits from a formatted phone number
  /// Returns a string of digits only (max 10)
  static String extractDigits(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return '';
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    // Limit to 10 digits
    return digits.length > 10 ? digits.substring(0, 10) : digits;
  }

  /// Checks if a phone number has exactly 10 digits
  static bool isValid(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return false;
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return digits.length == 10;
  }

  /// Checks if a phone number is empty or has exactly 10 digits (valid for optional fields)
  static bool isValidOrEmpty(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return true;
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return digits.isEmpty || digits.length == 10;
  }
}

/// A TextInputFormatter that formats phone numbers as (XXX) XXX-XXXX
/// and only allows numeric input
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extract only digits from the new value
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 10 digits
    final limitedDigits = digitsOnly.length > 10
        ? digitsOnly.substring(0, 10)
        : digitsOnly;

    // Format the number
    String formatted = '';
    int cursorPosition = 0;

    if (limitedDigits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Build formatted string
    if (limitedDigits.length <= 3) {
      formatted = '(${limitedDigits}';
      cursorPosition = formatted.length;
    } else if (limitedDigits.length <= 6) {
      formatted =
          '(${limitedDigits.substring(0, 3)}) ${limitedDigits.substring(3)}';
      cursorPosition = formatted.length;
    } else {
      formatted =
          '(${limitedDigits.substring(0, 3)}) ${limitedDigits.substring(3, 6)}-${limitedDigits.substring(6)}';
      cursorPosition = formatted.length;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
