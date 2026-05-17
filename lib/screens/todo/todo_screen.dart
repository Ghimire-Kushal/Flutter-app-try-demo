import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/todo_provider.dart';
import '../../models/task.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (provider.completed.isNotEmpty)
            TextButton(
              onPressed: () => provider.clearCompleted(),
              child: const Text('Clear done', style: TextStyle(fontSize: 12)),
            ),
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: 'Pending (${provider.pending.length})'),
            Tab(text: 'Done (${provider.completed.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _taskList(context, provider.pending, false),
          _taskList(context, provider.completed, true),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _taskList(BuildContext context, List<Task> tasks, bool isDone) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isDone ? Icons.task_alt_rounded : Icons.checklist_rounded,
                size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(isDone ? 'No completed tasks' : 'No pending tasks',
                style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: tasks.length,
      itemBuilder: (context, i) => _taskTile(context, tasks[i]),
    );
  }

  Widget _taskTile(BuildContext context, Task task) {
    final priorityColors = [Colors.grey, Colors.orange, Colors.red];
    final priorityLabels = ['Low', 'Medium', 'High'];
    final pColor = priorityColors[task.priority.clamp(0, 2)];

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => context.read<TodoProvider>().deleteTask(task.id),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: GestureDetector(
            onTap: () => context.read<TodoProvider>().toggleComplete(task.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted ? Colors.green : Colors.grey[400]!,
                  width: 2,
                ),
                color: task.isCompleted ? Colors.green : Colors.transparent,
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: task.isCompleted ? Colors.grey : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(task.description, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: pColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      priorityLabels[task.priority.clamp(0, 2)],
                      style: TextStyle(fontSize: 10, color: pColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (task.dueDate != null) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.schedule_rounded, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 2),
                    Text(
                      DateFormat('MMM d').format(task.dueDate!),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    int priority = 1;
    DateTime? dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Task title *')),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
              ),
              const SizedBox(height: 12),
              const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _priorityChip(ctx, 'Low', 0, priority, Colors.grey, () => setS(() => priority = 0)),
                  const SizedBox(width: 8),
                  _priorityChip(ctx, 'Medium', 1, priority, Colors.orange, () => setS(() => priority = 1)),
                  const SizedBox(width: 8),
                  _priorityChip(ctx, 'High', 2, priority, Colors.red, () => setS(() => priority = 2)),
                ],
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setS(() => dueDate = picked);
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 16),
                label: Text(dueDate == null
                    ? 'Set due date'
                    : 'Due: ${DateFormat('MMM d, yyyy').format(dueDate!)}'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    context.read<TodoProvider>().addTask(
                      titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      priority: priority,
                      dueDate: dueDate,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priorityChip(BuildContext context, String label, int val, int selected, Color color, VoidCallback onTap) {
    final isSelected = val == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey[300]!),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? color : Colors.grey, fontWeight: FontWeight.w600, fontSize: 12)),
      ),
    );
  }
}
