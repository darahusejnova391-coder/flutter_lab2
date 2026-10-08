abstract class QuadraticState {}
class QuadraticInitial extends QuadraticState {}
class QuadraticResult extends QuadraticState {
  final double a;
  final double b;
  final double c;
  final double discriminant;
  final String resultText;
  final String resultType; // 'two', 'one', 'none'

  QuadraticResult({
    required this.a,
    required this.b,
    required this.c,
    required this.discriminant,
    required this.resultText,
    required this.resultType,
  });
}
class QuadraticError extends QuadraticState {
  final String message;
  QuadraticError(this.message);
}
