import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';

enum PlaybackOrderMode { sequence, random }

class FeedFilterState {
  final PlaybackOrderMode orderMode;
  final bool hideWatched;

  const FeedFilterState({
    this.orderMode = PlaybackOrderMode.sequence,
    this.hideWatched = true,
  });

  FeedFilterState copyWith({
    PlaybackOrderMode? orderMode,
    bool? hideWatched,
  }) {
    return FeedFilterState(
      orderMode: orderMode ?? this.orderMode,
      hideWatched: hideWatched ?? this.hideWatched,
    );
  }
}

class FeedFilterNotifier extends StateNotifier<FeedFilterState> {
  FeedFilterNotifier() : super(const FeedFilterState());

  void toggleOrderMode() {
    state = state.copyWith(
      orderMode: state.orderMode == PlaybackOrderMode.sequence
          ? PlaybackOrderMode.random
          : PlaybackOrderMode.sequence,
    );
  }

  void setOrderMode(PlaybackOrderMode mode) {
    state = state.copyWith(orderMode: mode);
  }

  void toggleHideWatched() {
    state = state.copyWith(hideWatched: !state.hideWatched);
  }

  void setHideWatched(bool hide) {
    state = state.copyWith(hideWatched: hide);
  }
}

final feedFilterProvider =
    StateNotifierProvider<FeedFilterNotifier, FeedFilterState>(
  (ref) => FeedFilterNotifier(),
);

/// Provides the reactive list of VaultMediaEntity items for the endless PageView.builder
final activeFeedListProvider =
    StreamProvider.family<List<VaultMediaEntity>, FeedFilterState>((ref, filter) {
  final db = ref.watch(databaseProvider);
  return db.watchFeedQueue(hideCompleted: filter.hideWatched).map((items) {
    if (items.isEmpty) return [];
    final list = List<VaultMediaEntity>.from(items);
    if (filter.orderMode == PlaybackOrderMode.random) {
      list.shuffle(Random(42));
    }
    return list;
  });
});
