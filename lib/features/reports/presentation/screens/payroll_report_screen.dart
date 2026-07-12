import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/payroll_repository.dart';
import '../../domain/models/payroll_record.dart';

// Provide a state for the selected date
final payrollDateProvider = NotifierProvider<PayrollDateNotifier, DateTime>(() => PayrollDateNotifier());

class PayrollDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void updateDate(DateTime date) {
    state = date;
  }
}

class PayrollReportScreen extends ConsumerWidget {
  const PayrollReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(payrollDateProvider);
    final payrollAsync = ref.watch(payrollProvider(selectedDate));
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Payroll (Hazira)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2023),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                ref.read(payrollDateProvider.notifier).updateDate(date);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(payrollProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryHeader(context, selectedDate, payrollAsync, currencyFormatter),
          Expanded(
            child: payrollAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
              data: (records) {
                if (records.isEmpty) {
                  return const Center(child: Text('No workers found for this date.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return _buildWorkerCard(context, record, currencyFormatter);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, DateTime date, AsyncValue<List<PayrollRecord>> payrollAsync, NumberFormat currencyFormatter) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.primaryContainer,
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Text(
              DateFormat('EEEE, MMM d, yyyy').format(date),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            payrollAsync.maybeWhen(
              data: (records) {
                final totalWages = records.fold<double>(0, (sum, item) => sum + item.totalWage);
                final workersPresent = records.where((r) => r.isPresent).length;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryItem(context, 'Total Payout', currencyFormatter.format(totalWages)),
                    _buildSummaryItem(context, 'Workers Present', '$workersPresent / ${records.length}'),
                  ],
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkerCard(BuildContext context, PayrollRecord record, NumberFormat currencyFormatter) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.workerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${record.workerId} • Gang ${record.gangId}',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: record.isPresent ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    record.isPresent ? 'Present' : 'Absent',
                    style: TextStyle(
                      color: record.isPresent ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (record.isPresent) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailCol('Base Wage', currencyFormatter.format(record.baseWage)),
                  _buildDetailCol('Plucked', '${record.totalKg} kg'),
                  _buildDetailCol('Incentive', currencyFormatter.format(record.incentiveWage), isHighlight: record.incentiveWage > 0),
                  _buildDetailCol('Total', currencyFormatter.format(record.totalWage), isHighlight: true),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCol(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isHighlight ? Colors.green[700] : null,
          ),
        ),
      ],
    );
  }
}
