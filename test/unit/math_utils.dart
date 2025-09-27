import 'package:flutter_test/flutter_test.dart';
import 'package:sales_test_app/main.dart';

void main() {
  test('adds two numbers', () {
    // Arrange (input data)
    int a = 2;
    int b = 3;

    // Act (call the function)
    int result = add(a, b);

    // Assert (check result)
    expect(result, 5);
  });
}