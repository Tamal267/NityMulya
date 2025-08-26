void main() {
  // Test the parsing logic
  String testPrice = "65.00";

  // First try parsing as int
  final intParsed = int.tryParse(testPrice);
  print('int.tryParse("$testPrice") = $intParsed');

  // Try parsing as double then convert to int
  final doubleParsed = double.tryParse(testPrice);
  print('double.tryParse("$testPrice") = $doubleParsed');
  if (doubleParsed != null) {
    print('doubleParsed.toInt() = ${doubleParsed.toInt()}');
  }
}
