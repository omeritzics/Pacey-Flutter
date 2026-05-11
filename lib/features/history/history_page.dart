import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database_provider.dart';
import '../../core/database/database.dart';
import 'package:intl/intl.dart';

import 'package:energy_pacing/l10n/app_localizations.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.history), centerTitle: true),
      body: FutureBuilder<List<EnergyLog>>(
        future:
            (db.select(db.energyLogs)
                  ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
                  ..limit(50))
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(l10n.noHistory));
          }

          final logs = snapshot.data!.reversed.toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: logs.length.toDouble() - 1,
                      minY: 1,
                      maxY: 10,
                      lineBarsData: [
                        LineChartBarData(
                          spots: logs.asMap().entries.map((e) {
                            return FlSpot(
                              e.key.toDouble(),
                              e.value.level.toDouble(),
                            );
                          }).toList(),
                          isCurved: true,
                          color: Theme.of(context).colorScheme.primary,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[logs.length - 1 - index];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${log.level}')),
                        title: Text(l10n.energyUpdate),
                        subtitle: Text(
                          DateFormat('MMM dd, HH:mm', locale).format(log.timestamp),
                        ),
                        trailing: const Text('⚡', style: TextStyle(fontSize: 18)),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
