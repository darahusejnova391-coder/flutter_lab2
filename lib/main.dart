// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'quadratic_cubit.dart';
import 'quadratic_state.dart';
import 'calculation.dart';

void main() {
  // Если запущено в браузере — переключаем фабрику на web-версию
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
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
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // Загружаем сохранённые данные из SharedPreferences
  Future<void> _loadSavedData() async {
    final cubit = context.read<QuadraticCubit>();
    final coeffs = await cubit.loadLastCoefficients();
    final agreed = await cubit.loadIsAgreed();
    if (!mounted) return;
    setState(() {
      if (coeffs['a'] != null) _aController.text = coeffs['a'].toString();
      if (coeffs['b'] != null) _bController.text = coeffs['b'].toString();
      if (coeffs['c'] != null) _cController.text = coeffs['c'].toString();
      _isAgreed = agreed;
    });
  }

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
        // Кнопка истории в leading
        leading: IconButton(
          icon: const Icon(Icons.history),
          tooltip: 'История расчётов',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (_) => HistoryCubit()..loadHistory(),
                  child: const HistoryScreen(),
                ),
              ),
            );
          },
        ),
        title: const Text('Хусейнова Дарья Анатольевна'), 
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<QuadraticCubit, QuadraticState>(
        listener: (context, state) {
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
          if (state is QuadraticInitial || state is QuadraticError) {
            return _buildInputForm();
          }
          if (state is QuadraticResult) {
            return _buildResultView(state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

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

  Widget _buildResultView(QuadraticResult state) {
    IconData icon;
    Color color;
    if (state.resultType == 'two') {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (state.resultType == 'one') {
      icon = Icons.info;
      color = const Color.fromARGB(255, 227, 30, 155);
    } else {
      icon = Icons.cancel;
      color = const Color.fromARGB(255, 214, 201, 200);
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
                  const Text('Введённые коэффициенты:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('a = ${state.a},  b = ${state.b},  c = ${state.c}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                      'Дискриминант D = ${state.discriminant.toStringAsFixed(3)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
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
            onPressed: () => context.read<QuadraticCubit>().reset(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Вернуться назад'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ ЭКРАН ИСТОРИИ ============
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История расчётов'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HistoryEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('История пуста',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }
          if (state is HistoryLoaded) {
            final records = state.calculations as List<Calculation>;
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.pink.shade100,
                      child: Text('${r.id}',
                          style: const TextStyle(color: Colors.black)),
                    ),
                    title: Text('${r.a}x² + ${r.b}x + ${r.c} = 0'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Дискриминант: ${r.discriminant.toStringAsFixed(3)}'),
                        Text('Результат: ${r.result}'),
                        Text(r.dateTime,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}