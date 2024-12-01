import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/task.dart';
import '../services/database_service.dart';

class AddEditTaskScreen extends StatefulWidget {
  const AddEditTaskScreen({super.key, required this.isDarkMode});
  final bool isDarkMode;

  @override
  AddEditTaskScreenState createState() => AddEditTaskScreenState();
}

class AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  void _listen() async {
    if (!_isListening && await _speech.initialize()) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _taskController.text = result.recognizedWords;
        });
      });
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _saveTask() async {
    if (_taskController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O título da tarefa é obrigatório!")),
      );
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione uma data e hora!")),
      );
      return;
    }

    final dueDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final task = Task(
      title: _taskController.text,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : "Sem descrição",
      dueDate: dueDate,
      isCompleted: false,
    );

    final taskId = await DatabaseService.instance.addTask(task);

    if (taskId != -1 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tarefa salva com sucesso!")),
      );
      Navigator.pop(context, true); // Retorna para a tela anterior
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao salvar a tarefa.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nova tarefa"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "O que será feito?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: "Título da tarefa",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  onPressed: _listen,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Descrição (opcional)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_selectedDate == null
                  ? "Data não definida"
                  : "${_selectedDate!.day.toString().padLeft(2, '0')}/"
                      "${_selectedDate!.month.toString().padLeft(2, '0')}/"
                      "${_selectedDate!.year}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  locale: const Locale('pt', 'BR'),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            ListTile(
              title: Text(_selectedTime == null
                  ? "Hora não definida"
                  : "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}"),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (context, child) {
                    return Localizations.override(
                      context: context,
                      locale: const Locale('pt', 'BR'),
                      child: child,
                    );
                  },
                );
                if (pickedTime != null) {
                  setState(() {
                    _selectedTime = pickedTime;
                  });
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveTask,
        child: const Icon(Icons.check),
      ),
    );
  }
}
