import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/database/database_provider.dart';
import '../../core/database/database.dart';
import 'package:intl/intl.dart';

import 'package:pacey/l10n/app_localizations.dart';

enum _HistoryFilter { last7Days, last30Days, allTime }

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  _HistoryFilter _filter = _HistoryFilter.last7Days;

  Future<List<EnergyLog>> _fetchLogs(
    AppDatabase appDb,
    _HistoryFilter filter,
  ) async {
    final db = await appDb.database;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (filter == _HistoryFilter.last7Days) {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      whereClause = 'timestamp >= ?';
      whereArgs = [sevenDaysAgo.millisecondsSinceEpoch];
    } else if (filter == _HistoryFilter.last30Days) {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      whereClause = 'timestamp >= ?';
      whereArgs = [thirtyDaysAgo.millisecondsSinceEpoch];
    }

    final rows = await db.query(
      'energy_logs',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
    );
    return rows.map(EnergyLog.fromMap).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appDb = ref.watch(databaseProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.history), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<_HistoryFilter>(
                segments: [
                  ButtonSegment<_HistoryFilter>(
                    value: _HistoryFilter.last7Days,
                    label: Text(
                      l10n.last7Days,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  ButtonSegment<_HistoryFilter>(
                    value: _HistoryFilter.last30Days,
                    label: Text(
                      l10n.last30Days,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  ButtonSegment<_HistoryFilter>(
                    value: _HistoryFilter.allTime,
                    label: Text(
                      l10n.allTime,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
                selected: {_filter},
                onSelectionChanged: (Set<_HistoryFilter> newSelection) {
                  setState(() {
                    _filter = newSelection.first;
                  });
                },
                showSelectedIcon: false,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<EnergyLog>>(
              key: ValueKey(_filter),
              future: _fetchLogs(appDb, _filter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(l10n.noHistory));
                }

                final logs = snapshot.data!.reversed.toList();

                return SingleChildScrollView(
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
                            maxX: logs.length > 1
                                ? logs.length.toDouble() - 1
                                : 1.0,
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
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final log = logs[logs.length - 1 - index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                '${log.level}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            title: Text(l10n.energyUpdate),
                            subtitle: Text(
                              DateFormat(
                                'MMM dd, HH:mm',
                                locale,
                              ).format(log.timestamp),
                            ),
                            trailing: const Icon(Icons.bolt, size: 24),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
