import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fabVisibilityStateNotifier =
    StateNotifierProvider.autoDispose<FabVisibilityState, bool>((ref) {
  final fabStateProvider = ref.read(fabVisibilityProvider);

  ref.onDispose(() {
    fabStateProvider.aliasController.dispose();
    fabStateProvider.searchController.dispose();
  });

  return fabStateProvider;
});

final fabVisibilityProvider = Provider(
  (ref) => FabVisibilityState(ScrollController(), ScrollController()),
);

class FabVisibilityState extends StateNotifier<bool> {
  FabVisibilityState(ScrollController aliasTabController, searchTabController)
      : aliasController = aliasTabController,
        searchController = searchTabController,
        super(true) {
    addListeners(aliasController);
    addListeners(searchController);
  }

  late final ScrollController aliasController;
  late final ScrollController searchController;

  void addListeners(ScrollController controller) {
    controller.addListener(() {
      switch (controller.position.userScrollDirection) {
        case ScrollDirection.idle:
          state = true;
          break;
        case ScrollDirection.forward:
          state = true;
          break;
        case ScrollDirection.reverse:
          state = false;
          break;
      }
    });
  }
}
