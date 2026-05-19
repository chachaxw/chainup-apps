extension StringExt on String {
  bool isNullOrEmpty() {
    String str = trim();
    return str.isEmpty || str.toUpperCase() == "NULL";
  }
}