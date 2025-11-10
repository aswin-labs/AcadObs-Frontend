import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_floating_action_button.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Prediction extends StatelessWidget {
  const Prediction({super.key});

  @override
  Widget build(BuildContext context) {
    final scores = [1, 3, 4, 4, 1, 5, 5, 1, 1];
    return Scaffold(
      appBar: CommonAppBar(title: 'AI Prediction', isBackButton: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 10),
              CustomDropdown(
                dropdownKey: 'prediction_type',
                label: 'enter prediction type',
                icon: Icons.gesture,
                items: ['linear', 'regression'],
              ),
              SizedBox(height: 20),
              CustomDropdown(
                dropdownKey: 'Subject',
                label: 'select Subject',
                icon: Icons.gesture,
                items: ['english', 'maths'],
              ),

              SizedBox(height: 20),

              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    child: Icon(Icons.functions, color: Colors.brown),
                  ),
                  SizedBox(width: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mathematics",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 14,
                                color: Colors.black54,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Mr. Smith",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.brown, Colors.brown.shade100],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.all(16),

                  width: 500,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.podcasts, size: 25),
                          SizedBox(width: 10),
                          Text(
                            'AI Predicted Next Internal',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      Text(
                        '87/100',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Based on Attandance,Homeworks & previous exams',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Internal Exam Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(height: 160, child: InternalExamProgressChart()),
                  ],
                ),
              ),

              SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Homework Performance (Avg: 4.4/5)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 5,
                          minY: 0,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine:
                                (value) => FlLine(
                                  color: Colors.grey.withAlpha(30),
                                  strokeWidth: 1,
                                ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= scores.length) {
                                    return const SizedBox();
                                  }
                                  return Text(
                                    "${value.toInt() + 1}",
                                    style: const TextStyle(fontSize: 11),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(scores.length, (index) {
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: scores[index].toDouble(),
                                  color: Colors.deepPurpleAccent,
                                  width: 26,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ],
                              showingTooltipIndicators: [0],
                            );
                          }),
                          barTouchData: BarTouchData(
                            enabled: false,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) => null,
                            ),
                          ),
                          extraLinesData: ExtraLinesData(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: CommonFloatingActionButton(
        onPressed: () {},
        text: "Predict",
      ),
    );
  }
}

class InternalExamProgressChart extends StatelessWidget {
  const InternalExamProgressChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: 25,
          verticalInterval: 1,
          getDrawingHorizontalLine:
              (value) =>
                  FlLine(color: Colors.grey.withAlpha(51), strokeWidth: 2),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 20,
            ),
          ),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 40),
              FlSpot(1, 60),
              FlSpot(2, 60),
              FlSpot(3, 90),
              FlSpot(4, 90),
              FlSpot(5, 60),
              FlSpot(6, 80),
            ],
            isCurved: true,
            color: Colors.brown,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
