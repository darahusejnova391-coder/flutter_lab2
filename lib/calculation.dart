class Calculation {
  final int? id;
  final double a;
  final double b;
  final double c;
  final double discriminant;
  final String result;
  final String dateTime;

  Calculation({
    this.id,
    required this.a,
    required this.b,
    required this.c,
    required this.discriminant,
    required this.result,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'a': a,
      'b': b,
      'c': c,
      'discriminant': discriminant,
      'result': result,
      'dateTime': dateTime,
    };
  }

  factory Calculation.fromMap(Map<String, dynamic> map) {
    return Calculation(
      id: map['id'] as int?,
      a: (map['a'] as num).toDouble(),
      b: (map['b'] as num).toDouble(),
      c: (map['c'] as num).toDouble(),
      discriminant: (map['discriminant'] as num).toDouble(),
      result: map['result'] as String,
      dateTime: map['dateTime'] as String,
    );
  }
}