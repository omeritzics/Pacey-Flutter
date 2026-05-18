import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../tasks/task_provider.dart';

class _AddTaskDialog extends ConsumerStatefulWidget {
  final Task? task;

  const _AddTaskDialog(this.task);

  @override
  ConsumerState<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<_AddTaskDialog> {
  late final TextEditingController _titleController;
  late int _selectedEnergy;
  late int _selectedPriority;
  late int _selectedRepeat;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _selectedEnergy = widget.task?.requiredEnergy ?? 1;
    _selectedPriority = widget.task?.priority ?? 4;
    _selectedRepeat = widget.task?.repeatInterval ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.task == null ? l10n.addTask : l10n.editTask),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: l10n.taskTitle),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.taskPriority,
                contentPadding: const EdgeInsets.only(right: 8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedPriority,
                  isExpanded: true,
                  items: [1, 2, 3, 4]
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(_priorityLabel(l10n, p)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPriority = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.requiredEnergy),
            Slider(
              value: _selectedEnergy.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_selectedEnergy',
              onChanged: (value) =>
                  setState(() => _selectedEnergy = value.toInt()),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.repeatCadence,
                contentPadding: const EdgeInsets.only(right: 8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedRepeat,
                  isExpanded: true,
                  items: [0, 1, 2, 3]
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(_repeatCadenceLabel(l10n, c)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRepeat = value);
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.repeatCadenceHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              if (widget.task == null) {
                ref
                    .read(taskActionsProvider)
                    .addTask(
                      _titleController.text,
                      _selectedEnergy,
                      priority: _selectedPriority,
                      repeatInterval: _selectedRepeat,
                    );
              } else {
                ref
                    .read(taskActionsProvider)
                    .editTask(
                      widget.task!.id,
                      _titleController.text,
                      _selectedEnergy,
                      priority: _selectedPriority,
                      repeatInterval: _selectedRepeat,
                    );
              }
              Navigator.pop(context);
            }
          },
          child: Text(widget.task == null ? l10n.addTask : l10n.save),
        ),
      ],
    );
  }

  String _priorityLabel(AppLocalizations l10n, int level) {
    switch (level) {
      case 1:
        return l10n.priorityHighest;
      case 2:
        return l10n.priorityHigh;
      case 3:
        return l10n.priorityMedium;
      default:
        return l10n.priorityLow;
    }
  }

  String _repeatCadenceLabel(AppLocalizations l10n, int code) {
    switch (code) {
      case 0:
        return l10n.repeatOff;
      case 1:
        return l10n.repeatDaily;
      case 2:
        return l10n.repeatWeekly;
      case 3:
        return l10n.repeatMonthly;
      default:
        return l10n.repeatOff;
    }
  }
}
