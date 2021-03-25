import 'package:anonaddy/models/alias/alias_data_model.dart';
import 'package:anonaddy/screens/alias_tab/alias_detailed_screen.dart';
import 'package:anonaddy/state_management/alias_state_manager.dart';
import 'package:anonaddy/widgets/alias_list_tile_leading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'custom_page_route.dart';

class AliasListTile extends ConsumerWidget {
  const AliasListTile({Key key, this.aliasData}) : super(key: key);
  final AliasDataModel aliasData;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final aliasState = watch(aliasStateManagerProvider);
    final copyAlias = aliasState.copyToClipboard;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aliasDataProvider = context.read(aliasStateManagerProvider);

    Color themedColor() {
      return isDark ? Colors.white : Colors.grey;
    }

    bool isDeleted(dynamic input) {
      return input == null ? false : true;
    }

    return InkWell(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          children: [
            AliasListTileLeading(
              isDeleted: isDeleted(aliasData.deletedAt),
              isActive: aliasData.isAliasActive,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${aliasData.email}',
                    style: TextStyle(
                      color: isDeleted(aliasData.deletedAt)
                          ? Colors.grey
                          : isDark
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                  Text(
                    '${aliasData.emailDescription}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.copy, color: themedColor()),
              onPressed: isDeleted(aliasData.deletedAt)
                  ? null
                  : () => copyAlias(aliasData.email),
            ),
          ],
        ),
      ),
      onTap: () {
        aliasDataProvider.aliasDataModel = aliasData;
        aliasDataProvider.switchValue = aliasData.isAliasActive;

        Navigator.push(
          context,
          CustomPageRoute().customPageRouteBuilder(AliasDetailScreen()),
        );
      },
    );
  }
}
