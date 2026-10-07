import 'package:flutter/material.dart';
import 'dart:math' as math; // Импортируем математику для sqrt

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Квадратные уравнения',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const InputScreen(),
    );
  }
}

// ============ ПЕРВЫЙ ЭКРАН ============
class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  // Контроллеры для полей ввода
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _cController = TextEditingController();

  // Состояние чек-бокса
  bool _isAgreed = false;

  // Ключ для формы (для валидации)
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Освобождаем ресурсы
    _aController.dispose();
    _bController.dispose();
    _cController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Хусейнова Дарья Анатольевна'), 
        backgroundColor: const Color.fromARGB(255, 223, 144, 209),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Введите коэффициенты уравнения ax² + bx + c = 0',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Поле ввода a
              TextFormField(
                controller: _aController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Коэффициент a',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calculate),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите коэффициент a';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Введите корректное число';
                  }
                  if (double.parse(value) == 0) {
                    return 'Коэффициент a не может быть равен 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Поле ввода b
              TextFormField(
                controller: _bController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Коэффициент b',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calculate),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите коэффициент b';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Введите корректное число';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Поле ввода c
              TextFormField(
                controller: _cController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Коэффициент c',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calculate),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите коэффициент c';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Введите корректное число';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Чек-бокс согласия
              CheckboxListTile(
                title: const Text('Согласен на обработку данных'),
                value: _isAgreed,
                onChanged: (bool? value) {
                  setState(() {
                    _isAgreed = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 20),

              // Кнопка "Вычислить"
              ElevatedButton(
                onPressed: () {
                  // Валидация формы
                  if (_formKey.currentState!.validate()) {
                    // Проверка чек-бокса
                    if (!_isAgreed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Необходимо согласие на обработку данных'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Получаем значения
                    double a = double.parse(_aController.text);
                    double b = double.parse(_bController.text);
                    double c = double.parse(_cController.text);

                    // Переходим на второй экран, передавая данные
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultScreen(a: a, b: b, c: c),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Вычислить корни',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ ВТОРОЙ ЭКРАН ============
class ResultScreen extends StatelessWidget {
  final double a;
  final double b;
  final double c;

  const ResultScreen({
    super.key,
    required this.a,
    required this.b,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    // Вычисляем дискриминант
    double discriminant = b * b - 4 * a * c;

    String resultText;
    IconData resultIcon;
    Color resultColor;

    if (discriminant > 0) {
      // Два корня
      double x1 = (-b + math.sqrt(discriminant)) / (2 * a);
      double x2 = (-b - math.sqrt(discriminant)) / (2 * a);
      resultText = 'Уравнение имеет два корня:\n\nx₁ = ${x1.toStringAsFixed(3)}\n\nx₂ = ${x2.toStringAsFixed(3)}';
      resultIcon = Icons.check_circle;
      resultColor = Colors.green;
    } else if (discriminant == 0) {
      // Один корень
      double x = -b / (2 * a);
      resultText = 'Уравнение имеет один корень:\n\nx = ${x.toStringAsFixed(3)}';
      resultIcon = Icons.info;
      resultColor = Colors.orange;
    } else {
      // Корней нет
      resultText = 'Уравнение не имеет действительных корней\n\n(D < 0)';
      resultIcon = Icons.cancel;
      resultColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Результат'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Отображение введенных коэффициентов
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Введённые коэффициенты:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('a = $a,  b = $b,  c = $c', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      'Дискриминант D = ${discriminant.toStringAsFixed(3)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Иконка результата
            Icon(resultIcon, size: 80, color: resultColor),

            const SizedBox(height: 20),

            // Текст результата
            Text(
              resultText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: resultColor,
              ),
            ),

            const SizedBox(height: 40),

            // Кнопка "Назад"
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Вернуться назад'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
