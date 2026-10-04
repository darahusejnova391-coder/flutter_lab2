import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Лабораторная работа',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. AppBar с указанием ФИО
      appBar: AppBar(
        title: const Text('Хусейнова Дарья Анатольевна'), 
      ),
      // 2. Тело экрана - Column с прокруткой
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Контейнер 1
            Container(
              margin: const EdgeInsets.all(10),
              height: 150,
              width: double.infinity,
              child: Image.asset('assets/1.jpg.jpg', fit: BoxFit.cover),
            ),
            // Контейнер 2
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              height: 150,
              width: double.infinity,
              child: Image.asset('assets/2.jpg.jpg', fit: BoxFit.cover),
            ),
            // Контейнер 3
            Container(
              margin: const EdgeInsets.only(left: 30, right: 10, top: 10, bottom: 10),
              height: 150,
              width: double.infinity,
              child: Image.asset('assets/3.jpg.jpg', fit: BoxFit.cover),
            ),
            // Контейнер 4
            Container(
              margin: const EdgeInsets.all(15),
              height: 150,
              width: double.infinity,
              child: Image.asset('assets/4.jpg.jpg', fit: BoxFit.cover),
            ),
            // Контейнер 5
            Container(
              margin: const EdgeInsets.all(5),
              height: 150,
              width: double.infinity,
              child: Image.asset('assets/5.jpg.jpg', fit: BoxFit.cover),
            ),
            // Контейнер 6
            Container(
              margin: const EdgeInsets.all(25),
              height: 150,
              width: double.infinity,
              child: Image.asset('assets/photo.png.png', fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }
}