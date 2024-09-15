// file: string_extensions.dart
extension SafeSubstring on String {
  String safeSubstring(int start, int end) {
    return this.length > end ? this.substring(start, end) : this;
  }
}
