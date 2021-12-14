import 'dart:developer';

import 'package:anonaddy/global_providers.dart';
import 'package:anonaddy/models/alias/alias.dart';
import 'package:anonaddy/services/search/search_service.dart';
import 'package:anonaddy/state_management/alias_state/alias_tab_notifier.dart';
import 'package:anonaddy/state_management/search/search_result/search_result_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchResultStateNotifier =
    StateNotifierProvider<SearchResultNotifier, SearchResultState>((ref) {
  return SearchResultNotifier(
    searchService: ref.read(searchService),
    aliasTabState: ref.read(aliasTabStateNotifier.notifier),
    controller: TextEditingController(),
  );
});

class SearchResultNotifier extends StateNotifier<SearchResultState> {
  SearchResultNotifier({
    required this.searchService,
    required this.aliasTabState,
    required this.controller,
  }) : super(SearchResultState.initial(controller, true));

  final SearchService searchService;
  final AliasTabNotifier aliasTabState;
  final TextEditingController controller;

  /// Updates UI state
  _updateState(SearchResultState newState) {
    log('_updateState: ' + newState.toString());
    if (mounted) state = newState;
  }

  /// Fetches [Alias]es matching [searchKeyword] and sets [SearchResult]
  /// with matching list of aliases
  Future<void> searchAliases() async {
    _updateState(
      state.copyWith(status: SearchResultStatus.Loading),
    );

    try {
      /// Extract [searchKeyword] from text controller
      final searchKeyword = state.searchController!.text.trim();

      /// Fetches matching aliases from AnonAddy servers
      final matchingAliases = await searchService.fetchMatchingAliases(
          searchKeyword, state.includeDeleted!);

      /// Structure new state
      final newState = state.copyWith(
          status: SearchResultStatus.Loaded, aliases: matchingAliases);

      /// Trigger a UI update with the new state
      _updateState(newState);
    } catch (error) {
      final newState = state.copyWith(
        status: SearchResultStatus.Failed,
        errorMessage: error.toString(),
      );
      _updateState(newState);
    }
  }

  /// Searches through locally available aliases which is 100 aliases after
  /// AnonAddy implemented pagination
  void searchAliasesLocally() {
    final matchingAliases = <Alias>[];

    if (state.searchController != null) {
      final text = state.searchController!.text.trim();
      final aliases = aliasTabState.getAliases() ?? [];

      aliases.forEach((element) {
        final filterByEmail =
            element.email.toLowerCase().contains(text.toLowerCase());
        if (element.description == null) {
          if (filterByEmail) {
            matchingAliases.add(element);
          }
        } else {
          final filterByDescription =
              element.description!.toLowerCase().contains(text.toLowerCase());

          if (filterByEmail || filterByDescription) {
            matchingAliases.add(element);
          }
        }
      });
    }

    final newState = state.copyWith(
        status: SearchResultStatus.Limited, aliases: matchingAliases);
    _updateState(newState);
  }

  /// Controls [showCloseIcon] visibility
  void toggleCloseIcon() {
    if (state.searchController != null) {
      final toggle = state.searchController!.text.isNotEmpty;
      final newState = state.copyWith(showCloseIcon: toggle);
      _updateState(newState);
    }
  }

  /// Controls [includeDeleted] visibility
  void toggleIncludeDeleted(bool toggle) {
    final newState = state.copyWith(includeDeleted: toggle);
    _updateState(newState);
  }

  /// Resets [SearchState] to initial state
  void closeSearch() {
    if (state.searchController != null) {
      state.searchController!.clear();

      _updateState(
        SearchResultState.initial(controller, state.includeDeleted!),
      );
    }
  }
}
