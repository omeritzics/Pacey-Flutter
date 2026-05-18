import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pacey/l10n/app_localizations.dart';
import '../energy/energy_provider.dart';
import '../tasks/task_provider.dart';
import '../tasks/repeat_schedule.dart';
import '../../core/database/database.dart';
import '../../core/backup/backup_provider.dart';
import '../../core/backup/backup_settings_provider.dart';
import '../../core/database/database_provider.dart';
import '../history/history_page.dart';
import '../gamification/gamification_provider.dart';

import '../settings/settings_page.dart';

String _priorityMenuLabel(AppLocalizations l10n, int level) {
  switch (level) {
    case 1:
      return l10n.priorityHighest;
    case 2:
      return l10n.priorityHigh;
    case 3:
      return l10n.priorityMedium;
    case 4:
      return l10n.priorityLow;
    default:
      return level.toString();
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

String _getDayLabel(BuildContext context, int weekday) {
  final isHe = Localizations.localeOf(context).languageCode == 'he';
  switch (weekday) {
    case DateTime.sunday:
      return isHe ? 'א' : 'S';
    case DateTime.monday:
      return isHe ? 'ב' : 'M';
    case DateTime.tuesday:
      return isHe ? 'ג' : 'T';
    case DateTime.wednesday:
      return isHe ? 'ד' : 'W';
    case DateTime.thursday:
      return isHe ? 'ה' : 'T';
    case DateTime.friday:
      return isHe ? 'ו' : 'F';
    case DateTime.saturday:
      return isHe ? 'ש' : 'S';
    default:
      return '';
  }
}

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _maybeAutoImport(BuildContext context) async {
    final settings = ref.read(backupSettingsProvider);
    if (!settings.isAutoImportEnabled) return;

    final path = settings.autoImportPath;
    final appDb = ref.read(databaseProvider);
    final service = ref.read(backupServiceProvider);
    final result = await service.importFromFolder(appDb, path: path);

    if (!context.mounted || result == null) return;

    final l10n = AppLocalizations.of(context)!;
    final bool imported =
        (result.tasksImported + result.energyLogsImported) != 0;

    if (imported) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.importSuccessful(
              result.tasksImported,
              result.energyLogsImported,
            ),
          ),
        ),
      );
      ref.invalidate(energyLevelProvider);
      ref.invalidate(tasksProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PacingStats?>(pacingStatsProvider, (previous, next) {
      if (previous != null &&
          next != null &&
          next.healingLevel > previous.healingLevel) {
        _confettiController.play();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeAutoImport(context);
    });

    final energyLevel = ref.watch(energyLevelProvider);
    final tasks = ref.watch(filteredTasksProvider);
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(l10n.appTitle),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
                tooltip: l10n.settings,
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: const _HealingProgress(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            l10n.currentEnergy,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          _EnergySelector(
                            key: ValueKey(energyLevel),
                            currentLevel: energyLevel,
                            onChanged: (level) async {
                              final success = await ref
                                  .read(energyLevelProvider.notifier)
                                  .updateLevel(level);

                              if (!success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.alreadyLogged),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.tasksForEnergy(energyLevel),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _showAddTaskDialog(context, ref),
                      ),
                    ],
                  ),
                ),
              ),
              if (tasks.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      l10n.noTasks,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _TaskTile(task: tasks[index]),
                    childCount: tasks.length,
                  ),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
            label: Text(l10n.history),
            icon: const Icon(Icons.history),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    int selectedEnergy = 1;
    int selectedPriority = 4;
    int selectedRepeat = 0;
    final selectedDays = <int>{DateTime.now().weekday};
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.addTask),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
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
                      value: selectedPriority,
                      isExpanded: true,
                      items: [1, 2, 3, 4]
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(_priorityMenuLabel(l10n, p)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedPriority = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.requiredEnergy),
                Slider(
                  value: selectedEnergy.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '$selectedEnergy',
                  onChanged: (value) =>
                      setState(() => selectedEnergy = value.toInt()),
                ),
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.repeatCadence,
                    contentPadding: const EdgeInsets.only(right: 8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedRepeat,
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
                          setState(() => selectedRepeat = value);
                        }
                      },
                    ),
                  ),
                ),
                if (selectedRepeat == 2) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.selectWeekDays,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:
                        [
                          DateTime.sunday,
                          DateTime.monday,
                          DateTime.tuesday,
                          DateTime.wednesday,
                          DateTime.thursday,
                          DateTime.friday,
                          DateTime.saturday,
                        ].map((day) {
                          final isSelected = selectedDays.contains(day);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  if (selectedDays.length > 1) {
                                    selectedDays.remove(day);
                                  }
                                } else {
                                  selectedDays.add(day);
                                }
                              });
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline
                                            .withValues(alpha: 0.5),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _getDayLabel(context, day),
                                style: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
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
                if (titleController.text.isNotEmpty) {
                  final repeatDaysStr = selectedRepeat == 2
                      ? selectedDays.join(',')
                      : null;
                  ref
                      .read(taskActionsProvider)
                      .addTask(
                        titleController.text,
                        selectedEnergy,
                        priority: selectedPriority,
                        repeatInterval: selectedRepeat,
                        repeatDays: repeatDaysStr,
                      );
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.addTask),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnergySelector extends StatelessWidget {
  final int currentLevel;
  final ValueChanged<int> onChanged;

  const _EnergySelector({
    super.key,
    required this.currentLevel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 2.0,
          runSpacing: 4.0,
          children: List.generate(10, (index) {
            final level = index + 1;
            final isLit = level <= currentLevel;

            return InkWell(
              onTap: () => onChanged(level),
              borderRadius: BorderRadius.circular(8),
              splashColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 6.0,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  transform: Matrix4.identity()..scale(isLit ? 1.1 : 1.0),
                  transformAlignment: Alignment.center,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isLit ? 1.0 : 0.4,
                    child: Icon(
                      Icons.bolt,
                      size: 28,
                      color: isLit
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Text(
          '$currentLevel / 10',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _TaskTile extends ConsumerWidget {
  final Task task;

  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final gated = isTaskCompletionGated(
      isCompleted: task.isCompleted,
      repeatInterval: task.repeatInterval,
      nextAllowedCompletionAt: task.nextAllowedCompletionAt,
      now: now,
    );
    String? subtitleText;
    if (gated && task.nextAllowedCompletionAt != null) {
      final formatted = DateFormat.yMMMd(
        Localizations.localeOf(context).toLanguageTag(),
      ).format(task.nextAllowedCompletionAt!);
      subtitleText = l10n.availableAfter(formatted);
    }

    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: gated
            ? null
            : (_) {
                ref.read(taskActionsProvider).toggleTask(task);
              },
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: task.isCompleted ? Colors.grey : null,
        ),
      ),
      subtitle: subtitleText != null
          ? Text(
              subtitleText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            task.requiredEnergy,
            (_) => const Icon(Icons.bolt, size: 16),
          ),
          if (task.repeatInterval != 0) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.repeat,
              size: 16,
              color: Theme.of(context).colorScheme.outline,
            ),
          ],
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 24),
            onPressed: () => _showEditTaskDialog(context, ref, task),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 24),
            onPressed: () => ref.read(taskActionsProvider).deleteTask(task.id),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, WidgetRef ref, Task task) {
    final titleController = TextEditingController(text: task.title);
    int selectedEnergy = task.requiredEnergy;
    int selectedPriority = task.priority;
    int selectedRepeat = task.repeatInterval;
    final selectedDays = <int>{};
    if (task.repeatDays != null && task.repeatDays!.isNotEmpty) {
      selectedDays.addAll(
        task.repeatDays!
            .split(',')
            .map((s) => int.tryParse(s.trim()))
            .whereType<int>(),
      );
    }
    if (selectedDays.isEmpty) {
      selectedDays.add(DateTime.now().weekday);
    }
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.editTask),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
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
                      value: selectedPriority,
                      isExpanded: true,
                      items: [1, 2, 3, 4]
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(_priorityMenuLabel(l10n, p)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedPriority = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.requiredEnergy),
                Slider(
                  value: selectedEnergy.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '$selectedEnergy',
                  onChanged: (value) =>
                      setState(() => selectedEnergy = value.toInt()),
                ),
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.repeatCadence,
                    contentPadding: const EdgeInsets.only(right: 8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedRepeat,
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
                          setState(() => selectedRepeat = value);
                        }
                      },
                    ),
                  ),
                ),
                if (selectedRepeat == 2) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.selectWeekDays,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:
                        [
                          DateTime.sunday,
                          DateTime.monday,
                          DateTime.tuesday,
                          DateTime.wednesday,
                          DateTime.thursday,
                          DateTime.friday,
                          DateTime.saturday,
                        ].map((day) {
                          final isSelected = selectedDays.contains(day);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  if (selectedDays.length > 1) {
                                    selectedDays.remove(day);
                                  }
                                } else {
                                  selectedDays.add(day);
                                }
                              });
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline
                                            .withValues(alpha: 0.5),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _getDayLabel(context, day),
                                style: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
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
                if (titleController.text.isNotEmpty) {
                  final repeatDaysStr = selectedRepeat == 2
                      ? selectedDays.join(',')
                      : null;
                  ref
                      .read(taskActionsProvider)
                      .editTask(
                        task.id,
                        titleController.text,
                        selectedEnergy,
                        priority: selectedPriority,
                        repeatInterval: selectedRepeat,
                        repeatDays: repeatDaysStr,
                      );
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealingProgress extends ConsumerWidget {
  const _HealingProgress();

  String _getLevelName(BuildContext context, int level) {
    final l10n = AppLocalizations.of(context)!;
    if (level <= 5) return l10n.stabilization;
    if (level <= 15) return l10n.strengthening;
    return l10n.expansion;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(pacingStatsProvider);
    final notifier = ref.read(pacingStatsProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    if (stats == null) return const SizedBox.shrink();

    final progress = notifier.getLevelProgress(stats.xp);
    final levelName = _getLevelName(context, stats.healingLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.healingLevel(stats.healingLevel),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              levelName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${stats.xp} XP',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}
