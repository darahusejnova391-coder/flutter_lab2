import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'quadratic_state.dart';

class QuadraticCubit extends Cubit<QuadraticState> {
  QuadraticCubit() : super(QuadraticInitial());

  // Метод для вычисления корней
  void calculate({
    required double a,
    required double b,
    required double c,
    required bool isAgreed,
  }) {
    // Проверка чек-бокса
    if (!isAgreed) {
      emit(QuadraticError('Необходимо согласие на обработку данных'));
      return;
    }

    // Проверка коэффициента a
    if (a == 0) {
      emit(QuadraticError('Коэффициент a не может быть равен 0'));
      return;
    }
    double discriminant = b * b - 4 * a * c;

    String resultText;
    String resultType;

    if (discriminant > 0) {
      double x1 = (-b + math.sqrt(discriminant)) / (2 * a);
      double x2 = (-b - math.sqrt(discriminant)) / (2 * a);
      resultText =
          'Два корня:\nx₁ = ${x1.toStringAsFixed(3)}\nx₂ = ${x2.toStringAsFixed(3)}';
      resultType = 'two';
    } else if (discriminant == 0) {
      double x = -b / (2 * a);
      resultText = 'Один корень:\nx = ${x.toStringAsFixed(3)}';
      resultType = 'one';
    } else {
      resultText = 'Корней нет (D < 0)';
      resultType = 'none';
    }
    emit(QuadraticResult(
      a: a,
      b: b,
      c: c,
      discriminant: discriminant,
      resultText: resultText,
      resultType: resultType,
    ));
  }

  void reset() {
    emit(QuadraticInitial());
  }
}