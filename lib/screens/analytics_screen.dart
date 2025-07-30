import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../services/analytics_service.dart';
import '../widgets/enhanced_refresh_indicator.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  Map<String, double> _monthlyTrends = {};
  Map<String, Map<String, dynamic>> _categoryAnalysis = {};
  double _spendingPrediction = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      try {
        final trends = await _analyticsService.getMonthlySpendingTrends(authProvider.user!.uid, 6);
        final analysis = await _analyticsService.getCategoryAnalysis(authProvider.user!.uid);
        final prediction = await _analyticsService.getSpendingPrediction(authProvider.user!.uid);
        
        setState(() {
          _monthlyTrends = trends;
          _categoryAnalysis = analysis;
          _spendingPrediction = prediction;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading analytics: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadAnalytics();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : EnhancedRefreshIndicator(
              onRefresh: _loadAnalytics,
              refreshMessage: 'Analytics updated successfully!',
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Spending Prediction Card
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.trending_up, color: colorScheme.primary),
                                const SizedBox(width: 8),
                                Text('Spending Prediction', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Next Month Estimate',
                              style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                            ),
                            Text(
                              'FCFA ${_spendingPrediction.toStringAsFixed(2)}',
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Based on your spending patterns over the last 6 months',
                              style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Monthly Trends Chart
                    if (_monthlyTrends.isNotEmpty) ...[
                      Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Monthly Spending Trends', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 200,
                                child: LineChart(
                                  LineChartData(
                                    gridData: const FlGridData(show: true),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 60,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              'FCFA ${(value / 1000).toStringAsFixed(0)}K',
                                              style: const TextStyle(fontSize: 10),
                                            );
                                          },
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final months = _monthlyTrends.keys.toList();
                                            if (value.toInt() < months.length) {
                                              final monthKey = months[value.toInt()];
                                              final parts = monthKey.split('-');
                                              return Text(
                                                '${parts[1]}/${parts[0].substring(2)}',
                                                style: const TextStyle(fontSize: 10),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    borderData: FlBorderData(show: true),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: _monthlyTrends.entries.toList().asMap().entries.map((entry) {
                                          return FlSpot(entry.key.toDouble(), entry.value.value);
                                        }).toList(),
                                        isCurved: true,
                                        color: colorScheme.primary,
                                        barWidth: 3,
                                        dotData: const FlDotData(show: true),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Category Analysis
                    if (_categoryAnalysis.isNotEmpty) ...[
                      Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Category Breakdown', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 200,
                                child: PieChart(
                                  PieChartData(
                                    sections: _categoryAnalysis.entries.map((entry) {
                                      final total = entry.value['total'] as double;
                                      final grandTotal = _categoryAnalysis.values.fold(0.0, (sum, data) => sum + (data['total'] as double));
                                      final percentage = (total / grandTotal) * 100;
                                      
                                      return PieChartSectionData(
                                        value: total,
                                        title: '${percentage.toStringAsFixed(1)}%',
                                        color: _getCategoryColor(entry.key),
                                        radius: 60,
                                        titleStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    }).toList(),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Legend
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: _categoryAnalysis.entries.map((entry) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(entry.key),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        entry.key,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Category Details
                    if (_categoryAnalysis.isNotEmpty) ...[
                      Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Category Details', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              ..._categoryAnalysis.entries.map((entry) {
                                final data = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(entry.key),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.key,
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              '${data['count']} transactions • Avg: FCFA ${(data['average'] as double).toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'FCFA ${(data['total'] as double).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food & Drinks':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Academics (Books, Fees)':
        return Colors.purple;
      case 'Utilities (Rent, Bills)':
        return Colors.green;
      case 'Personal Care':
        return Colors.pink;
      case 'Entertainment':
        return Colors.red;
      case 'Clothing':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
