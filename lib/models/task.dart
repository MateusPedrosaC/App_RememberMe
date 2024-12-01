class Task {
  final int? id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final bool isCompleted;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.isCompleted = false,
  });

  // Converter para mapa (usado no banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Converter de mapa (usado ao ler do banco de dados)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] == 1,
    );
  }

  // Método para copiar e atualizar valores
  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, description: $description, dueDate: $dueDate, isCompleted: $isCompleted)';
  }
}
