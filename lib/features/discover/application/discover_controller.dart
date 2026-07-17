import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/mock_data.dart';
import '../../../shared/models/user_profile.dart';

class DiscoverFilters {
  const DiscoverFilters({
    this.nativeLanguage,
    this.learningLanguage,
    this.country,
    this.level,
    this.onlineOnly = false,
    this.minAge,
    this.maxAge,
    this.interest,
  });

  final String? nativeLanguage;
  final String? learningLanguage;
  final String? country;
  final String? level;
  final bool onlineOnly;
  final int? minAge;
  final int? maxAge;
  final String? interest;

  DiscoverFilters copyWith({
    String? nativeLanguage,
    String? learningLanguage,
    String? country,
    String? level,
    bool? onlineOnly,
    int? minAge,
    int? maxAge,
    String? interest,
    bool clearNative = false,
    bool clearLearning = false,
  }) {
    return DiscoverFilters(
      nativeLanguage:
          clearNative ? null : (nativeLanguage ?? this.nativeLanguage),
      learningLanguage:
          clearLearning ? null : (learningLanguage ?? this.learningLanguage),
      country: country ?? this.country,
      level: level ?? this.level,
      onlineOnly: onlineOnly ?? this.onlineOnly,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      interest: interest ?? this.interest,
    );
  }
}

class DiscoverState {
  const DiscoverState({
    this.users = const [],
    this.filters = const DiscoverFilters(),
    this.isGrid = false,
    this.isLoading = false,
    this.query = '',
  });

  final List<UserProfile> users;
  final DiscoverFilters filters;
  final bool isGrid;
  final bool isLoading;
  final String query;

  DiscoverState copyWith({
    List<UserProfile>? users,
    DiscoverFilters? filters,
    bool? isGrid,
    bool? isLoading,
    String? query,
  }) {
    return DiscoverState(
      users: users ?? this.users,
      filters: filters ?? this.filters,
      isGrid: isGrid ?? this.isGrid,
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
    );
  }
}

final discoverControllerProvider =
    StateNotifierProvider<DiscoverController, DiscoverState>((ref) {
  return DiscoverController()..load();
});

class DiscoverController extends StateNotifier<DiscoverState> {
  DiscoverController() : super(const DiscoverState(isLoading: true));

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    state = state.copyWith(users: _apply(MockData.users), isLoading: false);
  }

  void setQuery(String q) {
    state = state.copyWith(query: q, users: _apply(MockData.users, q: q));
  }

  void setFilters(DiscoverFilters filters) {
    state = state.copyWith(
      filters: filters,
      users: _apply(MockData.users, filters: filters),
    );
  }

  void toggleView() {
    state = state.copyWith(isGrid: !state.isGrid);
  }

  List<UserProfile> _apply(
    List<UserProfile> source, {
    String? q,
    DiscoverFilters? filters,
  }) {
    final query = (q ?? state.query).toLowerCase();
    final f = filters ?? state.filters;
    return source.where((u) {
      if (f.onlineOnly && u.status != OnlineStatus.online) return false;
      if (f.nativeLanguage != null && u.nativeLanguage != f.nativeLanguage) {
        return false;
      }
      if (f.learningLanguage != null &&
          !u.learningLanguages.any((l) => l.name == f.learningLanguage)) {
        return false;
      }
      if (f.country != null && u.country != f.country) return false;
      if (query.isNotEmpty &&
          !u.displayName.toLowerCase().contains(query) &&
          !u.username.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
  }
}
