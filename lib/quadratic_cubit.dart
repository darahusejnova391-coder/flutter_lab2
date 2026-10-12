// lib/quadratic_cubit.dart

import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quadratic_state.dart';
import 'calculation.dart';
import 'database_service.dart';

class QuadraticCubit extends Cubit<QuadraticState> {
  final DatabaseService _dbService = DatabaseService();

  QuadraticCubit() : super(QuadraticInitial());

  Future<void> calculate({
    required double a,
    required double b,
    required double c,
    required bool isAgreed,
  }) async {
    if (!isAgreed) {
      emit(QuadraticError('Необходимо согласие на обработку данных'));
      return;
    }
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
      resultText = 'x₁ = ${x1.toStringAsFixed(3)}, x₂ = ${x2.toStringAsFixed(3)}';
      resultType = 'two';
    } else if (discriminant == 0) {
      double x = -b / (2 * a);
      resultText = 'x = ${x.toStringAsFixed(3)}';
      resultType = 'one';
    } else {
      resultText = 'Корней нет (D < 0)';
      resultType = 'none';
    }

    final now = DateTime.now();
    final dateStr =
        '${now.day}.${now.month}.${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    await _dbService.insertCalculation(Calculation(
      a: a,
      b: b,
      c: c,
      discriminant: discriminant,
      result: resultText,
      dateTime: dateStr,
    ));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_a', a);
    await prefs.setDouble('last_b', b);
    await prefs.setDouble('last_c', c);
    await prefs.setBool('is_agreed', isAgreed);

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

  Future<Map<String, double?>> loadLastCoefficients() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'a': prefs.getDouble('last_a'),
      'b': prefs.getDouble('last_b'),
      'c': prefs.getDouble('last_c'),
    };
  }

  Future<bool> loadIsAgreed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_agreed') ?? false;
  }
}

// ============ КУБИТ ДЛЯ ИСТОРИИ ============
class HistoryCubit extends Cubit<HistoryState> {
  final DatabaseService _dbService = DatabaseService();

  HistoryCubit() : super(HistoryLoading());

  Future<void> loadHistory() async {
    emit(HistoryLoading());
    final records = await _dbService.getCalculations();
    if (records.isEmpty) {
      emit(HistoryEmpty());
    } else {
      emit(HistoryLoaded(records));
    }
  }
}