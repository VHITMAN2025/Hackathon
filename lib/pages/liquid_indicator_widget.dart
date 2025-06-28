import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class LiquidFill extends StatelessWidget {
  final double percent;
  const LiquidFill({required this.percent, super.key});

  @override
  Widget build(BuildContext context) {
    return LiquidLinearProgressIndicator(
      value: percent / 100,
      valueColor: const AlwaysStoppedAnimation(Colors.blue),
      backgroundColor: Colors.grey[200]!,
      borderRadius: 12.0,
      center: Text('${percent.toInt()}%'),
    );
  }
}
class LiquidIndicatorWidget extends StatelessWidget {
  final double percent;
  const LiquidIndicatorWidget({required this.percent, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Progress',
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 16),
          LiquidFill(percent: percent),
        ],
      ),
    );
  }
}