import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/trend_analytics_entity.dart';

class AdvancedTrendChart extends StatefulWidget {
  final TrendAnalyticsEntity trendData;
  final String chartType; // 'line', 'bar', 'area'
  final bool showComparison;
  final VoidCallback? onPeriodTap;

  const AdvancedTrendChart({
    Key? key,
    required this.trendData,
    this.chartType = 'line',
    this.showComparison = false,
    this.onPeriodTap,
  }) : super(key: key);

  @override
  State<AdvancedTrendChart> createState() => _AdvancedTrendChartState();
}

class _AdvancedTrendChartState extends State<AdvancedTrendChart> {
  int touchedIndex = -1;
  bool showProjection = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 16),
            _buildChart(isDark),
            const SizedBox(height: 16),
            _buildSummaryStats(theme),
            if (widget.trendData.insights.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInsights(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getPeriodDisplayName()} Trend Analizi',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatDate(widget.trendData.startDate)} - ${_formatDate(widget.trendData.endDate)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildChartTypeButton('line', Icons.show_chart),
            const SizedBox(width: 8),
            _buildChartTypeButton('bar', Icons.bar_chart),
            const SizedBox(width: 8),
            _buildChartTypeButton('area', Icons.area_chart),
          ],
        ),
      ],
    );
  }

  Widget _buildChartTypeButton(String type, IconData icon) {
    final isSelected = widget.chartType == type;
    return GestureDetector(
      onTap: () {
        // Bu özellik parent widget'da handle edilmeli
        if (widget.onPeriodTap != null) {
          widget.onPeriodTap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.getInputBorderColor(context),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : AppColors.getTextSecondaryColor(context),
        ),
      ),
    );
  }

  Widget _buildChart(bool isDark) {
    return SizedBox(
      height: 250,
      child: AnimatedSwitcher(
        duration: 300.ms,
        child: widget.chartType == 'bar' 
            ? _buildBarChart(isDark)
            : _buildLineChart(isDark),
      ),
    );
  }

  Widget _buildLineChart(bool isDark) {
    if (widget.trendData.dataPoints.isEmpty) {
      return const Center(child: Text('Veri bulunamadı'));
    }

    final spots = widget.trendData.dataPoints.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.amount / 1000); // K cinsinden
    }).toList();

    final maxY = widget.trendData.dataPoints
        .map((point) => point.amount)
        .reduce((a, b) => a > b ? a : b) / 1000;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxY / 5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.getInputBorderColor(context).withOpacity(0.3),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: AppColors.getInputBorderColor(context).withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.trendData.dataPoints.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      widget.trendData.dataPoints[index].label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.getTextSecondaryColor(context),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(0)}K',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.getTextSecondaryColor(context),
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: AppColors.getInputBorderColor(context).withOpacity(0.3),
          ),
        ),
        minX: 0,
        maxX: (widget.trendData.dataPoints.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: touchedIndex == index ? 6 : 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: widget.chartType == 'area',
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
            setState(() {
              if (touchResponse != null && 
                  touchResponse.lineBarSpots != null && 
                  touchResponse.lineBarSpots!.isNotEmpty) {
                touchedIndex = touchResponse.lineBarSpots!.first.spotIndex;
              } else {
                touchedIndex = -1;
              }
            });
          },
          getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((spotIndex) {
              return TouchedSpotIndicatorData(
                FlLine(color: AppColors.primary, strokeWidth: 2),
                FlDotData(
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 8,
                      color: AppColors.primary,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: AppColors.getSurfaceColor(context),
            tooltipBorder: BorderSide(
              color: AppColors.getInputBorderColor(context),
            ),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final index = barSpot.spotIndex;
                final dataPoint = widget.trendData.dataPoints[index];
                
                return LineTooltipItem(
                  '${dataPoint.label}\n₺${dataPoint.amount.toStringAsFixed(0)}\n${dataPoint.transactionCount} işlem',
                  AppTextStyles.bodySmall.copyWith(
                    color: AppColors.getTextPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(bool isDark) {
    if (widget.trendData.dataPoints.isEmpty) {
      return const Center(child: Text('Veri bulunamadı'));
    }

    final maxY = widget.trendData.dataPoints
        .map((point) => point.amount)
        .reduce((a, b) => a > b ? a : b) / 1000;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.1,
        barTouchData: BarTouchData(
          touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
            setState(() {
              if (response != null && response.spot != null) {
                touchedIndex = response.spot!.touchedBarGroupIndex;
              } else {
                touchedIndex = -1;
              }
            });
          },
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: AppColors.getSurfaceColor(context),
            tooltipBorder: BorderSide(
              color: AppColors.getInputBorderColor(context),
            ),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dataPoint = widget.trendData.dataPoints[groupIndex];
              return BarTooltipItem(
                '${dataPoint.label}\n₺${dataPoint.amount.toStringAsFixed(0)}',
                AppTextStyles.bodySmall.copyWith(
                  color: AppColors.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.trendData.dataPoints.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      widget.trendData.dataPoints[index].label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.getTextSecondaryColor(context),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: maxY / 5,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${value.toStringAsFixed(0)}K',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.getTextSecondaryColor(context),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: widget.trendData.dataPoints.asMap().entries.map((entry) {
          final index = entry.key;
          final dataPoint = entry.value;
          final isTouched = index == touchedIndex;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: dataPoint.amount / 1000,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: isTouched ? 22 : 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
        gridData: const FlGridData(show: false),
      ),
    );
  }

  Widget _buildSummaryStats(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.getCardBorderColor(context),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem(
                'Toplam',
                '₺${widget.trendData.summary.totalAmount.toStringAsFixed(0)}',
                theme,
              ),
              _buildStatItem(
                'Ortalama',
                '₺${widget.trendData.summary.averageAmount.toStringAsFixed(0)}',
                theme,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem(
                'Trend',
                widget.trendData.summary.changeText,
                theme,
                color: _getTrendColor(),
              ),
              _buildStatItem(
                'İşlem',
                '${widget.trendData.summary.totalTransactions}',
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, ThemeData theme, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.getTextSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.getTextPrimaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Önemli Gözlemler',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.trendData.insights.take(2).map((insight) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getInsightColor(insight.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getInsightColor(insight.type).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getInsightIcon(insight.type),
                  size: 20,
                  color: _getInsightColor(insight.type),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        insight.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getTrendColor() {
    switch (widget.trendData.summary.direction) {
      case TrendDirection.increasing:
        return AppColors.error;
      case TrendDirection.decreasing:
        return AppColors.success;
      case TrendDirection.stable:
        return AppColors.info;
    }
  }

  Color _getInsightColor(TrendInsightType type) {
    switch (type) {
      case TrendInsightType.highSpending:
      case TrendInsightType.budgetWarning:
        return AppColors.error;
      case TrendInsightType.savingsOpportunity:
      case TrendInsightType.lowSpending:
        return AppColors.success;
      case TrendInsightType.unusualSpike:
      case TrendInsightType.steadyGrowth:
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  IconData _getInsightIcon(TrendInsightType type) {
    switch (type) {
      case TrendInsightType.highSpending:
        return Icons.trending_up;
      case TrendInsightType.lowSpending:
      case TrendInsightType.savingsOpportunity:
        return Icons.trending_down;
      case TrendInsightType.unusualSpike:
        return Icons.warning_outlined;
      case TrendInsightType.steadyGrowth:
        return Icons.show_chart;
      case TrendInsightType.categoryDominance:
        return Icons.pie_chart;
      case TrendInsightType.budgetWarning:
        return Icons.error_outline;
      case TrendInsightType.seasonalPattern:
        return Icons.refresh;
    }
  }

  String _getPeriodDisplayName() {
    switch (widget.trendData.period) {
      case 'monthly':
        return 'Aylık';
      case 'weekly':
        return 'Haftalık';
      case 'yearly':
        return 'Yıllık';
      default:
        return 'Dönemsel';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}