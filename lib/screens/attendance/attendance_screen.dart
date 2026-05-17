import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance_subject.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: provider.subjects.isEmpty
          ? _empty(context)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: provider.subjects.length,
              itemBuilder: (context, i) => _subjectCard(context, provider.subjects[i], provider),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSubject(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Subject'),
      ),
    );
  }

  Widget _subjectCard(BuildContext context, AttendanceSubject subject, AttendanceProvider provider) {
    final pct = subject.percentage;
    final safe = subject.isSafe;
    final color = pct >= 75 ? Colors.green : (pct >= 60 ? Colors.orange : Colors.red);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(subject.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${pct.toStringAsFixed(1)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                onPressed: () => provider.deleteSubject(subject.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 6,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${subject.attendedClasses} / ${subject.totalClasses} classes',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const Spacer(),
              if (!safe)
                Text(
                  'Need ${subject.classesNeededFor75} more to reach 75%',
                  style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w500),
                )
              else
                Text(
                  'Can miss ${subject.classesCanMiss} class(es)',
                  style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => provider.markAttended(subject.id),
                  icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.green),
                  label: const Text('Present', style: TextStyle(fontSize: 12, color: Colors.green)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => provider.markAbsent(subject.id),
                  icon: const Icon(Icons.cancel_rounded, size: 16, color: Colors.red),
                  label: const Text('Absent', style: TextStyle(fontSize: 12, color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => _editCounts(context, subject, provider),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12)),
                child: const Icon(Icons.edit_rounded, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.school_outlined, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Text('No subjects added', style: TextStyle(color: Colors.grey[500])),
        const SizedBox(height: 6),
        Text('Tap + to add your first subject', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
      ],
    ),
  );

  void _addSubject(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Subject'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Subject name'),
          onSubmitted: (_) {
            if (ctrl.text.trim().isNotEmpty) {
              context.read<AttendanceProvider>().addSubject(ctrl.text.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                context.read<AttendanceProvider>().addSubject(ctrl.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editCounts(BuildContext context, AttendanceSubject subject, AttendanceProvider provider) {
    final attendedCtrl = TextEditingController(text: '${subject.attendedClasses}');
    final totalCtrl = TextEditingController(text: '${subject.totalClasses}');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit ${subject.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: attendedCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Classes attended'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: totalCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total classes'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final attended = int.tryParse(attendedCtrl.text) ?? subject.attendedClasses;
              final total = int.tryParse(totalCtrl.text) ?? subject.totalClasses;
              provider.updateCounts(subject.id, attended, total);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
