import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  HomeScreenState createState() => HomeScreenState(); // Tornado público
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = today.add(const Duration(days: 2));

    final tabs = [
      "Hoje (${DateFormat('dd/MM').format(today)})",
      "Amanhã (${DateFormat('dd/MM').format(tomorrow)})",
      "${DateFormat('EEEE', 'pt_BR').format(dayAfterTomorrow).capitalize()} (${DateFormat('dd/MM').format(dayAfterTomorrow)})",
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lista de Tarefas"),
          actions: [
            IconButton(
              icon: Icon(
                widget.isDarkMode ? Icons.brightness_7 : Icons.brightness_2,
              ),
              onPressed: widget.onToggleTheme,
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Implementar funcionalidade de busca
              },
            ),
          ],
          bottom: TabBar(
            tabs: tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        body: TabBarView(
          children: [
            _buildTaskListView(context, today),
            _buildTaskListView(context, tomorrow),
            _buildTaskListView(context, dayAfterTomorrow),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.pushNamed(context, '/add_edit_task');
            if (result == true && mounted) {
              setState(() {}); // Atualiza a lista de tarefas após adicionar uma nova
            }
          },
          tooltip: 'Adicionar Tarefa',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTaskListView(BuildContext context, DateTime date) {
    return FutureBuilder<List<Task>>(
      future: DatabaseService.instance.getTasksForDate(date),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Erro ao carregar tarefas: ${snapshot.error}",
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(task.dueDate)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _deleteTask(task);
                  },
                ),
              );
            },
          );
        } else {
          return _buildEmptyTaskView(DateFormat('EEEE', 'pt_BR').format(date).capitalize());
        }
      },
    );
  }

  Future<void> _deleteTask(Task task) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmação"),
        content: const Text("Você deseja excluir esta tarefa?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      await DatabaseService.instance.deleteTask(task.id!);

      if (!mounted) return; // Verifica se o widget ainda está montado

      setState(() {}); // Atualiza a lista após deletar

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tarefa '${task.title}' excluída com sucesso!")),
      );
    }
  }

  Widget _buildEmptyTaskView(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt_outlined,
            size: 100,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 16),
          Text(
            "Nenhuma tarefa para $tabName",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
