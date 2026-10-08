import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'quadratic_cubit.dart';
import 'quadratic_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Квадратные уравнения',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: BlocProvider(
        create: (context) => QuadraticCubit(),
        child: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _cController = TextEditingController();
  bool _isAgreed = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
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
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<QuadraticCubit, QuadraticState>(
        listener: (context, state) {
          // Показываем ошибку через SnackBar
          if (state is QuadraticError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // Если состояние — начальное или ошибка, показываем форму
          if (state is QuadraticInitial || state is QuadraticError) {
            return _buildInputForm();
          }
          // Если состояние — результат, показываем результат
          if (state is QuadraticResult) {
            return _buildResultView(state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // Форма ввода
  Widget _buildInputForm() {
    return Padding(
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
            _buildNumberField(_aController, 'Коэффициент a', true),
            const SizedBox(height: 16),
            _buildNumberField(_bController, 'Коэффициент b', false),
            const SizedBox(height: 16),
            _buildNumberField(_cController, 'Коэффициент c', false),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Согласен на обработку данных'),
              value: _isAgreed,
              onChanged: (v) => setState(() => _isAgreed = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<QuadraticCubit>().calculate(
                        a: double.parse(_aController.text),
                        b: double.parse(_bController.text),
                        c: double.parse(_cController.text),
                        isAgreed: _isAgreed,
                      );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
              child:
                  const Text('Вычислить корни', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  // Поле ввода
  Widget _buildNumberField(
      TextEditingController controller, String label, bool isA) {
    return TextFormField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.calculate),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Введите $label';
        if (double.tryParse(value) == null) return 'Введите корректное число';
        if (isA && double.parse(value) == 0) {
          return 'Коэффициент a не может быть 0';
        }
        return null;
      },
    );
  }

  // Экран результата
  Widget _buildResultView(QuadraticResult state) {
    IconData icon;
    Color color;
    if (state.resultType == 'two') {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (state.resultType == 'one') {
      icon = Icons.info;
      color = Colors.orange;
    } else {
      icon = Icons.cancel;
      color = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  Text(
                    'a = ${state.a},  b = ${state.b},  c = ${state.c}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Дискриминант D = ${state.discriminant.toStringAsFixed(3)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Icon(icon, size: 80, color: color),
          const SizedBox(height: 20),
          Text(
            state.resultText,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              context.read<QuadraticCubit>().reset();
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Вернуться назад'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color.fromARGB(255, 236, 147, 177),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}