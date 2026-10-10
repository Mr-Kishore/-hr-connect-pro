import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// LowMemoryManager optimizes the Flutter engine, image decoding cache,
/// and widget render pipelines for devices with <= 2 GB RAM (such as Android Go,
/// entry-level smartphones, and resource-constrained environments).
class LowMemoryManager with WidgetsBindingObserver {
  static final LowMemoryManager instance = LowMemoryManager._internal();

  LowMemoryManager._internal();

  bool _isInitialized = false;
  int _memoryPressureEventsCount = 0;

  int get memoryPressureEventsCount => _memoryPressureEventsCount;
  bool get isInitialized => _isInitialized;

  /// Default image cache budget for low-RAM mobile devices:
  /// Standard Flutter defaults (1000 images / 100 MB) trigger Android Low Memory Killer (LMK).
  /// Restricted to 60 images and 20 MB max heap allocation.
  static const int kLowRamMaxImageCacheCount = 60;
  static const int kLowRamMaxImageCacheBytes = 20 * 1024 * 1024; // 20 MB

  /// Recommended cache extent for low-RAM scrolling viewports (default is 250.0).
  /// A tighter extent (120.0) reduces retained offscreen widget hierarchies in RAM.
  static const double kLowRamCacheExtent = 120.0;

  /// Initialize engine memory constraints and bind to system memory pressure callbacks.
  void initialize() {
    if (_isInitialized) return;

    // Apply strict image cache bounds to prevent Out-Of-Memory (OOM) on <2GB RAM
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = kLowRamMaxImageCacheCount;
    imageCache.maximumSizeBytes = kLowRamMaxImageCacheBytes;

    // Register observer to receive OS trim-memory callbacks
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;

    if (kDebugMode) {
      debugPrint(
        '[LOW_MEMORY_MANAGER] Initialized: ImageCache capped at '
        '$kLowRamMaxImageCacheCount images / '
        '${(kLowRamMaxImageCacheBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
      );
    }
  }

  /// System memory pressure callback triggered by Android OS
  /// (e.g. TRIM_MEMORY_RUNNING_CRITICAL, TRIM_MEMORY_MODERATE, or iOS didReceiveMemoryWarning).
  @override
  void didHaveMemoryPressure() {
    _memoryPressureEventsCount++;

    // Purge cached images and decoded bitmap rasters immediately to prevent process termination
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear();
    imageCache.clearLiveImages();

    if (kDebugMode) {
      debugPrint(
        '[LOW_MEMORY_MANAGER] System Memory Pressure signal received (#$_memoryPressureEventsCount). '
        'Evicted image cache and bitmap buffers.',
      );
    }
  }

  /// Clean up observer on shutdown
  void dispose() {
    if (_isInitialized) {
      WidgetsBinding.instance.removeObserver(this);
      _isInitialized = false;
    }
  }
}

/// Helper wrapper that conditionally wraps heavy list cards in a [RepaintBoundary].
/// On budget GPUs, RepaintBoundary caches the card texture in an isolated layer,
/// preventing the entire viewport from re-rasterizing on every scroll delta.
class SmoothListItem extends StatelessWidget {
  final Widget child;
  final bool enableRepaintBoundary;

  const SmoothListItem({
    super.key,
    required this.child,
    this.enableRepaintBoundary = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enableRepaintBoundary) return child;
    return RepaintBoundary(child: child);
  }
}
