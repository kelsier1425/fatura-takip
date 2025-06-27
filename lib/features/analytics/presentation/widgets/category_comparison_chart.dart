import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/category_comparison_entity.dart';

class CategoryComparisonChart extends StatefulWidget {
  final CategoryComparisonEntity comparisonData;
  final VoidCallback? onChartTypeChange;
  final Function(String)? onCategorySelect;

  const CategoryComparisonChart({
    Key? key,
    required this.comparisonData,
    this.onChartTypeChange,
    this.onCategorySelect,
  }) : super(key: key);

  @override
  State<CategoryComparisonChart> createState() => _CategoryComparisonChartState();
}

class _CategoryComparisonChartState extends State<CategoryComparisonChart> {
  int touchedIndex = -1;
  String selectedCategoryId = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 16),
            _buildChart(),
            const SizedBox(height: 16),
            _buildLegend(theme),
            if (widget.comparisonData.insights.isNotEmpty) ...[
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
                widget.comparisonData.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.comparisonData.categories.length} kategori • ₺${widget.comparisonData.summary.totalAmount.toStringAsFixed(0)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildChartTypeButton(ComparisonType.pie, Icons.pie_chart),
            const SizedBox(width: 8),
            _buildChartTypeButton(ComparisonType.bar, Icons.bar_chart),
            const SizedBox(width: 8),
            _buildChartTypeButton(ComparisonType.line, Icons.show_chart),
          ],
        ),
      ],
    );
  }

  Widget _buildChartTypeButton(ComparisonType type, IconData icon) {
    final isSelected = widget.comparisonData.type == type;
    return GestureDetector(
      onTap: () {
        if (!isSelected && widget.onChartTypeChange != null) {
          widget.onChartTypeChange!();
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

  Widget _buildChart() {
    return SizedBox(
      height: 300,
      child: AnimatedSwitcher(
        duration: 300.ms,
        child: _buildChartByType(),
      ),
    );
  }

  Widget _buildChartByType() {
    switch (widget.comparisonData.type) {
      case ComparisonType.pie:
        return _buildPieChart();
      case ComparisonType.bar:
        return _buildBarChart();
      case ComparisonType.line:
        return _buildLineChart();
      case ComparisonType.stacked:
        return _buildStackedChart();
      case ComparisonType.radar:
        return _buildRadarChart();
      default:
        return _buildPieChart();
    }
  }

  Widget _buildPieChart() {
    if (widget.comparisonData.categories.isEmpty) {
      return const Center(child: Text('Veri bulunamadı'));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 60,
        sections: widget.comparisonData.categories.asMap().entries.map((entry) {
          final index = entry.key;
          final categoryData = entry.value;
          final isTouched = index == touchedIndex;
          final fontSize = isTouched ? 16.0 : 14.0;
          final radius = isTouched ? 130.0 : 110.0;

          return PieChartSectionData(
            color: Color(categoryData.colorValue),
            value: categoryData.totalAmount,
            title: '${categoryData.percentage.toStringAsFixed(1)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: isTouched
                ? Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          categoryData.categoryName,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₺${categoryData.totalAmount.toStringAsFixed(0)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
            badgePositionPercentageOffset: 1.3,
          );
        }).toList(),
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
            setState(() {
              if (response != null && response.touchedSection != null) {
                final newIndex = response.touchedSection!.touchedSectionIndex;
                if (newIndex >= 0 && newIndex < widget.comparisonData.categories.length) {
                  touchedIndex = newIndex;
                  final categoryData = widget.comparisonData.categories[touchedIndex];
                  selectedCategoryId = categoryData.categoryId;
                } else {
                  touchedIndex = -1;
                  selectedCategoryId = '';
                }
              } else {
                touchedIndex = -1;
                selectedCategoryId = '';
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (widget.comparisonData.categories.isEmpty) {
      return const Center(child: Text('Veri bulunamadı'));
    }

    final maxAmount = widget.comparisonData.categories
        .map((cat) => cat.totalAmount)
        .reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxAmount * 1.1,
        barTouchData: BarTouchData(
          touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
            setState(() {
              if (response != null && response.spot != null) {
                final newIndex = response.spot!.touchedBarGroupIndex;
                if (newIndex >= 0 && newIndex < widget.comparisonData.categories.length) {
                  touchedIndex = newIndex;
                  final categoryData = widget.comparisonData.categories[touchedIndex];
                  selectedCategoryId = categoryData.categoryId;
                } else {
                  touchedIndex = -1;
                  selectedCategoryId = '';
                }
              } else {
                touchedIndex = -1;
                selectedCategoryId = '';
              }
            });
          },
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: AppColors.getSurfaceColor(context),
            tooltipBorder: BorderSide(
              color: AppColors.getInputBorderColor(context),
            ),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final categoryData = widget.comparisonData.categories[groupIndex];
              return BarTooltipItem(
                '${categoryData.categoryName}\n₺${categoryData.totalAmount.toStringAsFixed(0)}\n${categoryData.transactionCount} işlem',
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
                if (index >= 0 && index < widget.comparisonData.categories.length) {
                  final categoryName = widget.comparisonData.categories[index].categoryName;
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        categoryName.length > 8 ? '${categoryName.substring(0, 8)}...' : categoryName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.getTextSecondaryColor(context),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 60,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '₺${(value / 1000).toStringAsFixed(0)}K',
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
        barGroups: widget.comparisonData.categories.asMap().entries.map((entry) {
          final index = entry.key;
          final categoryData = entry.value;
          final isTouched = index == touchedIndex;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: categoryData.totalAmount,
                color: Color(categoryData.colorValue),
                width: isTouched ? 22 : 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxAmount / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.getInputBorderColor(context).withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    if (widget.comparisonData.categories.isEmpty || 
        widget.comparisonData.categories.first.timeSeries.isEmpty) {
      return const Center(child: Text('Zaman serisi verisi bulunamadı'));
    }

    final maxAmount = widget.comparisonData.categories
        .expand((cat) => cat.timeSeries.map((ts) => ts.amount))
        .fold(0.0, (max, amount) => amount > max ? amount : max);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxAmount / 5,
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
                if (index >= 0 && 
                    widget.comparisonData.categories.isNotEmpty &&
                    index < widget.comparisonData.categories.first.timeSeries.length) {
                  final date = widget.comparisonData.categories.first.timeSeries[index].date;
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${date.month}/${date.day}',
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
              interval: maxAmount / 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₺${(value / 1000).toStringAsFixed(0)}K',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.getTextSecondaryColor(context),
                  ),
                );
              },
              reservedSize: 50,
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
        maxX: (widget.comparisonData.categories.first.timeSeries.length - 1).toDouble(),
        minY: 0,
        maxY: maxAmount * 1.1,
        lineBarsData: widget.comparisonData.categories.take(5).map((categoryData) {
          final spots = categoryData.timeSeries.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.amount);
          }).toList();

          return LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Color(categoryData.colorValue),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Color(categoryData.colorValue),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStackedChart() {
    // Placeholder for stacked chart implementation
    return const Center(
      child: Text('Yığılmış grafik yakında gelecek'),
    );
  }

  Widget _buildRadarChart() {
    // Placeholder for radar chart implementation
    return const Center(
      child: Text('Radar grafik yakında gelecek'),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: widget.comparisonData.categories.take(6).map((categoryData) {
        final isSelected = categoryData.categoryId == selectedCategoryId;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCategoryId = isSelected ? '' : categoryData.categoryId;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Color(categoryData.colorValue).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? Color(categoryData.colorValue)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(categoryData.colorValue),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  categoryData.categoryName,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Color(categoryData.colorValue)
                        : AppColors.getTextSecondaryColor(context),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '₺${categoryData.totalAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimaryColor(context),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInsights(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori İçgörüleri',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.comparisonData.insights.take(3).map((insight) {
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
                if (insight.actionText != null)
                  TextButton(
                    onPressed: () {
                      // TODO: Implement action
                    },
                    child: Text(
                      insight.actionText!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _getInsightColor(insight.type),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getInsightColor(CategoryInsightType type) {
    switch (type) {
      case CategoryInsightType.dominance:
      case CategoryInsightType.imbalance:
        return AppColors.warning;
      case CategoryInsightType.balance:
      case CategoryInsightType.costEfficiency:
        return AppColors.success;
      case CategoryInsightType.categoryGrowth:
      case CategoryInsightType.budgetAlert:
        return AppColors.error;
      case CategoryInsightType.categoryDecline:
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  IconData _getInsightIcon(CategoryInsightType type) {
    switch (type) {
      case CategoryInsightType.dominance:
        return Icons.trending_up;
      case CategoryInsightType.balance:
        return Icons.balance;
      case CategoryInsightType.imbalance:
        return Icons.warning_outlined;
      case CategoryInsightType.categoryGrowth:
        return Icons.show_chart;
      case CategoryInsightType.categoryDecline:
        return Icons.trending_down;
      case CategoryInsightType.costEfficiency:
        return Icons.savings_outlined;
      case CategoryInsightType.budgetAlert:
        return Icons.error_outline;
      default:
        return Icons.insights;
    }
  }
}