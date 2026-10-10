import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_connect_pro/core/services/low_memory_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LowMemoryManager & Performance Optimization for <=2GB RAM Devices', () {
    late LowMemoryManager manager;

    setUp(() {
      manager = LowMemoryManager.instance;
      manager.initialize();
    });

    test('Initializes strict image cache bounds for low-RAM devices', () {
      final imageCache = PaintingBinding.instance.imageCache;

      expect(manager.isInitialized, isTrue);
      // Verify image cache is capped at LowMemoryManager specifications
      expect(imageCache.maximumSize, equals(LowMemoryManager.kLowRamMaxImageCacheCount));
      expect(imageCache.maximumSizeBytes, equals(LowMemoryManager.kLowRamMaxImageCacheBytes));
      expect(LowMemoryManager.kLowRamMaxImageCacheBytes, equals(20 * 1024 * 1024)); // 20 MB max
      expect(LowMemoryManager.kLowRamCacheExtent, equals(120.0));
    });

    test('didHaveMemoryPressure purges image cache and increments event counter', () {
      final initialCount = manager.memoryPressureEventsCount;

      // Simulate Android OS TRIM_MEMORY_RUNNING_CRITICAL / TRIM_MEMORY_COMPLETE callback
      manager.didHaveMemoryPressure();

      expect(manager.memoryPressureEventsCount, equals(initialCount + 1));
      final imageCache = PaintingBinding.instance.imageCache;
      expect(imageCache.currentSize, equals(0));
      expect(imageCache.currentSizeBytes, equals(0));
    });

    testWidgets('SmoothListItem wraps widget in RepaintBoundary for GPU texture caching', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothListItem(
              enableRepaintBoundary: true,
              child: Text('Performance Card Content'),
            ),
          ),
        ),
      );

      final boundaryFinder = find.descendant(
        of: find.byType(SmoothListItem),
        matching: find.byType(RepaintBoundary),
      );
      expect(boundaryFinder, findsOneWidget);
      expect(find.text('Performance Card Content'), findsOneWidget);
    });

    testWidgets('SmoothListItem honors enableRepaintBoundary = false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmoothListItem(
              enableRepaintBoundary: false,
              child: Text('Unbounded Item'),
            ),
          ),
        ),
      );

      final boundaryFinder = find.descendant(
        of: find.byType(SmoothListItem),
        matching: find.byType(RepaintBoundary),
      );
      expect(boundaryFinder, findsNothing);
      expect(find.text('Unbounded Item'), findsOneWidget);
    });
  });
}
