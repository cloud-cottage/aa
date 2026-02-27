import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple example global state provider
final exampleCounterProvider = StateProvider<int>((ref) => 0);
