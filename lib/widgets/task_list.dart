import 'package:flutter/material.dart';
import 'package:app_remember_me/models/task.dart'; // Importa o modelo de tarefa
import 'package:app_remember_me/widgets/task_tile.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks; // Lista de tarefas usando o modelo Task
  final Function(Task) onDelete; // Callback para deletar uma tarefa
  final Function(Task) onToggleComplete; // Callback para alternar conclusão

  const TaskList({
    super.key,
    required this.tasks,
    required this.onDelete,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskTile(
          title: task.title, // Título da tarefa
          isCompleted: task.isCompleted, // Estado da tarefa
          onToggle: () => onToggleComplete(task), // Callback para alternar estado
          onDelete: () => onDelete(task), // Callback para deletar tarefa
        );
      },
    );
  }
}
