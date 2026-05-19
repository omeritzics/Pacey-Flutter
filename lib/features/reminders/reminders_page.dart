import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pacey/l10n/app_localizations.dart';
import 'reminders_provider.dart';
import 'notification_service.dart';

class RemindersPage extends ConsumerStatefulWidget {
  const RemindersPage({super.key});

  @override
  ConsumerState<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends ConsumerState<RemindersPage> {
  @override
  void initState() {
    super.initState();
    // Proactively request permissions when entering this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(remindersProvider);
    final notifier = ref.read(remindersProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reminders),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          _ReminderTile(
            title: l10n.morningReminder,
            description: l10n.morningReminderDescription,
            setting: state.morning,
            icon: Icons.wb_sunny_outlined,
            onChanged: (val) => notifier.updateMorning(enabled: val),
            onTimeTap: () => _pickTime(
              context,
              state.morning.hour,
              state.morning.minute,
              (h, m) => notifier.updateMorning(hour: h, minute: m),
            ),
          ),
          const Divider(),
          _ReminderTile(
            title: l10n.afternoonReminder,
            description: l10n.afternoonReminderDescription,
            setting: state.afternoon,
            icon: Icons.light_mode,
            onChanged: (val) => notifier.updateAfternoon(enabled: val),
            onTimeTap: () => _pickTime(
              context,
              state.afternoon.hour,
              state.afternoon.minute,
              (h, m) => notifier.updateAfternoon(hour: h, minute: m),
            ),
          ),
          const Divider(),
          _ReminderTile(
            title: l10n.eveningReminder,
            description: l10n.eveningReminderDescription,
            setting: state.evening,
            icon: Icons.nights_stay_outlined,
            onChanged: (val) => notifier.updateEvening(enabled: val),
            onTimeTap: () => _pickTime(
              context,
              state.evening.hour,
              state.evening.minute,
              (h, m) => notifier.updateEvening(hour: h, minute: m),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    int currentHour,
    int currentMinute,
    void Function(int hour, int minute) onSelected,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
    );
    if (picked != null) {
      onSelected(picked.hour, picked.minute);
    }
  }
}

class _ReminderTile extends StatelessWidget {
  final String title;
  final String description;
  final ReminderSetting setting;
  final IconData icon;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTimeTap;

  const _ReminderTile({
    required this.title,
    required this.description,
    required this.setting,
    required this.icon,
    required this.onChanged,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeStr = '${setting.hour.toString().padLeft(2, '0')}:${setting.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Text(description),
            value: setting.enabled,
            onChanged: onChanged,
            secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: setting.enabled
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 40), // indent past the icon
                            Text(
                              l10n.reminderTime,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: onTimeTap,
                          icon: const Icon(Icons.access_time, size: 18),
                          label: Text(
                            timeStr,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
