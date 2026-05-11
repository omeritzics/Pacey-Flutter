import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:energy_pacing/l10n/app_localizations.dart';
import '../energy/energy_provider.dart';
import '../tasks/task_provider.dart';
import '../../core/database/database.dart';
import '../history/history_page.dart';
import '../gamification/gamification_provider.dart';

import 'package:energy_pacing/core/localization/locale_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energyLevel = ref.watch(energyLevelProvider);
    final tasks = ref.watch(filteredTasksProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          TextButton.icon(
            onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
            icon: const Icon(Icons.language, size: 20),
            label: Text(locale.languageCode == 'en' ? 'עברית' : 'English'),
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
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    int selectedEnergy = 1;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.addTask),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: l10n.taskTitle),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Text(l10n.energyCost),
              Slider(
                value: selectedEnergy.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: '$selectedEnergy',
                onChanged: (value) =>
                    setState(() => selectedEnergy = value.toInt()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  ref
                      .read(taskActionsProvider)
                      .addTask(titleController.text, selectedEnergy);
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
            final isFilled = level <= currentLevel;
            return GestureDetector(
              onTap: () => onChanged(level),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Text(
                  '⚡',
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: isFilled ? 'Noto Color Emoji' : 'Noto Emoji',
                    // Fallback for visual clarity if fonts aren't perfectly distinct
                    color: isFilled ? null : Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
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
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (_) {
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            task.energyCost,
            (_) => const Text(
              '⚡',
              style: TextStyle(fontSize: 14, fontFamily: 'Noto Color Emoji'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => ref.read(taskActionsProvider).deleteTask(task.id),
          ),
        ],
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
