import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_connect_pro/features/candidate_flow/presentation/providers/candidate_flow_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Bookmark & Saved Jobs Feature Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'BM-1: BookmarkedJobsNotifier adds, removes, and checks bookmarks',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(container.read(bookmarkedJobsProvider), isEmpty);
        expect(
          container
              .read(bookmarkedJobsProvider.notifier)
              .isBookmarked('job_01'),
          isFalse,
        );

        // Bookmark job_01
        await container
            .read(bookmarkedJobsProvider.notifier)
            .toggleBookmark('job_01');
        expect(container.read(bookmarkedJobsProvider), contains('job_01'));
        expect(
          container
              .read(bookmarkedJobsProvider.notifier)
              .isBookmarked('job_01'),
          isTrue,
        );

        // Bookmark job_02
        await container
            .read(bookmarkedJobsProvider.notifier)
            .toggleBookmark('job_02');
        expect(
          container.read(bookmarkedJobsProvider),
          containsAll(['job_01', 'job_02']),
        );

        // Toggle job_01 to unbookmark
        await container
            .read(bookmarkedJobsProvider.notifier)
            .toggleBookmark('job_01');
        expect(
          container.read(bookmarkedJobsProvider),
          isNot(contains('job_01')),
        );
        expect(container.read(bookmarkedJobsProvider), contains('job_02'));
      },
    );

    test('BM-2: Bookmarks persist across storage and reload', () async {
      SharedPreferences.setMockInitialValues({
        'bookmarked_job_ids': ['job_saved_1', 'job_saved_2'],
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(bookmarkedJobsProvider.notifier);
      final bookmarked = await notifier.loadFromStorage();
      expect(bookmarked, containsAll(['job_saved_1', 'job_saved_2']));
      expect(
        container.read(bookmarkedJobsProvider),
        containsAll(['job_saved_1', 'job_saved_2']),
      );
    });

    test(
      'BM-3: filteredJobsProvider correctly filters by onlyBookmarked state',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Wait for matchedJobsProvider to complete
        final allJobs = await container.read(matchedJobsProvider.future);
        expect(allJobs, isNotEmpty);
        expect(allJobs.length, greaterThan(1));

        final firstJob = allJobs.first;

        // With no filters, filteredJobsProvider returns all jobs
        final initialFiltered = container.read(filteredJobsProvider).value!;
        expect(initialFiltered.length, equals(allJobs.length));

        // Toggle bookmark filter with no bookmarks -> empty list
        container.read(jobFilterProvider.notifier).toggleBookmarked();
        final filteredEmpty = container.read(filteredJobsProvider).value!;
        expect(filteredEmpty, isEmpty);

        // Bookmark firstJob -> filtered list has exactly firstJob
        await container
            .read(bookmarkedJobsProvider.notifier)
            .toggleBookmark(firstJob.id);
        final filteredWithBookmark = container
            .read(filteredJobsProvider)
            .value!;
        expect(filteredWithBookmark.length, equals(1));
        expect(filteredWithBookmark.first.id, equals(firstJob.id));

        // Toggle bookmark filter off -> all jobs returned again
        container.read(jobFilterProvider.notifier).toggleBookmarked();
        final allJobsRestored = container.read(filteredJobsProvider).value!;
        expect(allJobsRestored.length, equals(allJobs.length));
      },
    );

    testWidgets('BM-4: Bookmark button toggles bookmark state and icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final isBookmarked = ref
                      .watch(bookmarkedJobsProvider)
                      .contains('job_test_01');
                  return IconButton(
                    icon: Icon(
                      isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                    ),
                    onPressed: () {
                      ref
                          .read(bookmarkedJobsProvider.notifier)
                          .toggleBookmark('job_test_01');
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_rounded), findsNothing);

      await tester.tap(find.byIcon(Icons.bookmark_border_rounded));
      await tester.pump();

      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border_rounded), findsNothing);

      await tester.tap(find.byIcon(Icons.bookmark_rounded));
      await tester.pump();

      expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_rounded), findsNothing);
    });
  });
}
