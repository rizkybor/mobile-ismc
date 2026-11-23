import 'package:flutter/material.dart';

import '../../../domain/order_tracking.dart';
import '../tracking_text.dart';

/// Progres 7 segmen kecil (kartu order di Beranda & daftar Lacak).
class MiniProgress extends StatelessWidget {
  const MiniProgress({super.key, required this.tracking, this.height = 6});
  final OrderTracking tracking;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < tracking.steps.length; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          Expanded(
            child: Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height),
                color: tracking.steps[i].state == TrackState.todo
                    ? stepStateColor(
                        context,
                        TrackState.todo,
                      ).withValues(alpha: 0.25)
                    : stepStateColor(context, tracking.steps[i].state),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
