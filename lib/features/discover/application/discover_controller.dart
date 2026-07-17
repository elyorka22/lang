import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/mock_data.dart';
import '../../../shared/models/conversation.dart';

/// Circular language / country chip under Discover search.
class LanguageFlagFilter {
  const LanguageFlagFilter({
    required this.id,
    required this.flag,
    required this.label,
    required this.languageCode,
    required this.countryCode,
  });

  final String id;
  final String flag;
  final String label;

  /// Matches [ChatConversation.languageCodes] (es, de…).
  final String languageCode;
  final String countryCode;

  static const all = LanguageFlagFilter(
    id: 'all',
    flag: '🌐',
    label: 'All',
    languageCode: '',
    countryCode: '',
  );

  static const filters = <LanguageFlagFilter>[
    all,
    LanguageFlagFilter(
      id: 'es',
      flag: '🇪🇸',
      label: 'ES',
      languageCode: 'es',
      countryCode: 'ES',
    ),
    LanguageFlagFilter(
      id: 'de',
      flag: '🇩🇪',
      label: 'DE',
      languageCode: 'de',
      countryCode: 'DE',
    ),
    LanguageFlagFilter(
      id: 'fr',
      flag: '🇫🇷',
      label: 'FR',
      languageCode: 'fr',
      countryCode: 'FR',
    ),
    LanguageFlagFilter(
      id: 'en',
      flag: '🇬🇧',
      label: 'EN',
      languageCode: 'en',
      countryCode: 'GB',
    ),
    LanguageFlagFilter(
      id: 'pt',
      flag: '🇧🇷',
      label: 'PT',
      languageCode: 'pt',
      countryCode: 'BR',
    ),
    LanguageFlagFilter(
      id: 'ja',
      flag: '🇯🇵',
      label: 'JA',
      languageCode: 'ja',
      countryCode: 'JP',
    ),
    LanguageFlagFilter(
      id: 'it',
      flag: '🇮🇹',
      label: 'IT',
      languageCode: 'it',
      countryCode: 'IT',
    ),
    LanguageFlagFilter(
      id: 'ko',
      flag: '🇰🇷',
      label: 'KO',
      languageCode: 'ko',
      countryCode: 'KR',
    ),
  ];
}

class DiscoverState {
  const DiscoverState({
    this.groups = const [],
    this.selectedLanguageId = 'all',
    this.isLoading = false,
    this.query = '',
  });

  final List<ChatConversation> groups;
  final String selectedLanguageId;
  final bool isLoading;
  final String query;

  LanguageFlagFilter get selectedFilter {
    for (final f in LanguageFlagFilter.filters) {
      if (f.id == selectedLanguageId) return f;
    }
    return LanguageFlagFilter.all;
  }

  DiscoverState copyWith({
    List<ChatConversation>? groups,
    String? selectedLanguageId,
    bool? isLoading,
    String? query,
  }) {
    return DiscoverState(
      groups: groups ?? this.groups,
      selectedLanguageId: selectedLanguageId ?? this.selectedLanguageId,
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
    await Future<void>.delayed(const Duration(milliseconds: 200));
    state = state.copyWith(
      groups: _apply(MockData.discoverGroups()),
      isLoading: false,
    );
  }

  void setQuery(String q) {
    state = state.copyWith(
      query: q,
      groups: _apply(MockData.discoverGroups(), q: q),
    );
  }

  void setLanguageFilter(String filterId) {
    state = state.copyWith(
      selectedLanguageId: filterId,
      groups: _apply(
        MockData.discoverGroups(),
        languageId: filterId,
      ),
    );
  }

  List<ChatConversation> _apply(
    List<ChatConversation> source, {
    String? q,
    String? languageId,
  }) {
    final query = (q ?? state.query).toLowerCase().trim();
    final langId = languageId ?? state.selectedLanguageId;
    LanguageFlagFilter filter = LanguageFlagFilter.all;
    for (final f in LanguageFlagFilter.filters) {
      if (f.id == langId) filter = f;
    }

    return source.where((g) {
      if (!g.isGroup) return false;
      if (filter.languageCode.isNotEmpty) {
        final codes = g.languageCodes.map((c) => c.toLowerCase()).toList();
        if (!codes.contains(filter.languageCode)) return false;
      }
      if (query.isNotEmpty) {
        final title = (g.title ?? '').toLowerCase();
        final desc = g.description.toLowerCase();
        if (!title.contains(query) && !desc.contains(query)) return false;
      }
      return true;
    }).toList();
  }
}
