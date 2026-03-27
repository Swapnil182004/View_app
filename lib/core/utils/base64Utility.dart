import 'dart:convert';

class Base64Utility {
  /// Encodes the input string to Base64 format.
  static String encode(String input) {
    try {
      final bytes = utf8.encode(input); // Convert input to bytes
      final base64Str = base64.encode(bytes); // Encode bytes to Base64 string
      return base64Str;
    } catch (e) {
      print('Error encoding to Base64: $e');
      return '';
    }
  }

  /// Decodes the input Base64 string to its original format.
  static String decode(String base64Str) {
    try {
      final bytes = base64.decode(base64Str); // Decode Base64 string to bytes
      final decodedStr = utf8.decode(bytes); // Convert bytes to string
      return decodedStr;
    } catch (e) {
      print('Error decoding from Base64: $e');
      return '';
    }
  }
}
