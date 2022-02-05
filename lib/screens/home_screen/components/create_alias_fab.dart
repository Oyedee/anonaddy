import 'package:anonaddy/screens/create_alias/create_alias.dart';
import 'package:anonaddy/screens/home_screen/components/animated_fab.dart';
import 'package:anonaddy/shared_components/constants/material_constants.dart';
import 'package:anonaddy/shared_components/constants/ui_strings.dart';
import 'package:anonaddy/state_management/account/account_notifier.dart';
import 'package:anonaddy/state_management/account/account_state.dart';
import 'package:anonaddy/state_management/alias_state/fab_visibility_state.dart';
import 'package:anonaddy/utilities/niche_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class CreateAliasFAB extends StatelessWidget {
  const CreateAliasFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, _) {
        final showFab = watch(fabVisibilityStateNotifier);

        return AnimatedFab(
          showFab: showFab,
          child: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              final accountState = context.read(accountStateNotifier);

              switch (accountState.status) {
                case AccountStatus.loading:
                  NicheMethod.showToast(kLoadingText);
                  break;

                case AccountStatus.loaded:
                  showCupertinoModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(kBottomSheetBorderRadius),
                      ),
                    ),
                    builder: (context) => const CreateAlias(),
                  );
                  break;

                case AccountStatus.failed:
                  NicheMethod.showToast(kLoadAccountDataFailed);
                  break;
              }
            },
          ),
        );
      },
    );
  }
}
