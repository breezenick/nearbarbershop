import 'package:flutter_riverpod/flutter_riverpod.dart';

class DistanceNotifier extends StateNotifier<double> {
  DistanceNotifier() : super(1.0); // Initial state

  void updateDistance(double newDistance) {
    state = newDistance;
  }
}

final distanceProvider = StateNotifierProvider<DistanceNotifier, double>((ref) {
  return DistanceNotifier();
});
