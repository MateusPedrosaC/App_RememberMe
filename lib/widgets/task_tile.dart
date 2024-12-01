import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  final String title; // Nome da tarefa
  final bool isCompleted; // Estado de conclusão da tarefa
  final VoidCallback onToggle; // Callback para alternar estado
  final VoidCallback onDelete; // Callback para deletar tarefa

  const TaskTile({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: isCompleted,
        onChanged: (value) => onToggle(),
      ),
      title: Text(
        title,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: onDelete,
      ),
    );
  }
}
