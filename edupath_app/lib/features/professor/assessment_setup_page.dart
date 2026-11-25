import 'package:flutter/material.dart';

class AssessmentSetup {
  const AssessmentSetup({
    required this.title,
    required this.durationMinutes,
    required this.startsAt,
    required this.endsAt,
  });

  final String title;
  final int durationMinutes;
  final DateTime startsAt;
  final DateTime endsAt;
}

class AssessmentSetupPage extends StatefulWidget {
  const AssessmentSetupPage({
    super.key,
    required this.assessmentLabel,
    required this.initialTitle,
  });

  final String assessmentLabel;
  final String initialTitle;

  @override
  State<AssessmentSetupPage> createState() => _AssessmentSetupPageState();
}

class _AssessmentSetupPageState extends State<AssessmentSetupPage> {
  late final TextEditingController _titleController;
  final _durationController = TextEditingController(text: '60');
  late DateTime _startsAt;
  late DateTime _endsAt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _startsAt = DateTime.now().add(const Duration(hours: 1));
    _endsAt = _startsAt.add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(bool isStart) async {
    final value = isStart ? _startsAt : _endsAt;
    final date = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(value));
    if (time == null) return;
    setState(() {
      final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isStart) {
        _startsAt = selected;
      } else {
        _endsAt = selected;
      }
    });
  }

  void _continue() {
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;
    if (_titleController.text.trim().isEmpty || duration <= 0 || !_endsAt.isAfter(_startsAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title, a valid duration, and an end time after the start time.')),
      );
      return;
    }
    Navigator.pop(
      context,
      AssessmentSetup(
        title: _titleController.text.trim(),
        durationMinutes: duration,
        startsAt: _startsAt,
        endsAt: _endsAt,
      ),
    );
  }

  String _format(DateTime value) =>
      '${value.month}/${value.day}/${value.year} ${TimeOfDay.fromDateTime(value).format(context)}';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Set up ${widget.assessmentLabel}')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Availability and timing', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Students can take the assessment only during the availability window.'),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Assessment name', prefixIcon: Icon(Icons.title_rounded)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Time allowed (minutes)', prefixIcon: Icon(Icons.timer_outlined)),
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.play_circle_outline_rounded),
                title: const Text('Starts'),
                subtitle: Text(_format(_startsAt)),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: () => _pickDateTime(true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.stop_circle_outlined),
                title: const Text('Ends'),
                subtitle: Text(_format(_endsAt)),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: () => _pickDateTime(false),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _continue,
                icon: const Icon(Icons.check_rounded),
                label: Text('Save ${widget.assessmentLabel} setup'),
              ),
            ],
          ),
        ),
      );
}
