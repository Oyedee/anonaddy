import 'package:animations/animations.dart';
import 'package:anonaddy/constants.dart';
import 'package:anonaddy/models/alias/alias_data_model.dart';
import 'package:anonaddy/state_management/alias_state_manager.dart';
import 'package:anonaddy/utilities/confirmation_dialog.dart';
import 'package:anonaddy/utilities/target_platform.dart';
import 'package:anonaddy/widgets/alias_detail_list_tile.dart';
import 'package:anonaddy/widgets/custom_app_bar.dart';
import 'package:anonaddy/widgets/custom_loading_indicator.dart';
import 'package:anonaddy/widgets/recipient_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class AliasDetailScreen extends ConsumerWidget {
  final isIOS = TargetedPlatform().isIOS();
  final confirmationDialog = ConfirmationDialog();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final size = MediaQuery.of(context).size;

    final aliasDataProvider = watch(aliasStateManagerProvider);
    final aliasDataModel = aliasDataProvider.aliasDataModel;
    final switchValue = aliasDataProvider.switchValue;
    final toggleAlias = aliasDataProvider.toggleAlias;
    final isLoading = aliasDataProvider.isLoading;
    final copyOnTap = aliasDataProvider.copyToClipboard;
    final deleteOrRestoreAlias = aliasDataProvider.deleteOrRestoreAlias;
    final editDescription = aliasDataProvider.editDescription;

    final _textEditingController = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 20, bottom: 40),
              child: SvgPicture.asset(
                'assets/images/mailbox.svg',
                height: size.height * 0.2,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: AliasDetailListTile(
                    leadingIconData: Icons.forward_to_inbox,
                    title: aliasDataModel.emailsForwarded,
                    subtitle: 'Emails Forwarded',
                  ),
                ),
                Expanded(
                  child: AliasDetailListTile(
                    leadingIconData: Icons.reply,
                    title: aliasDataModel.emailsReplied,
                    subtitle: 'Emails Replied',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: AliasDetailListTile(
                    leadingIconData: Icons.mark_email_read_outlined,
                    title: aliasDataModel.emailsSent,
                    subtitle: 'Emails Sent',
                  ),
                ),
                Expanded(
                  child: AliasDetailListTile(
                    leadingIconData: Icons.block,
                    title: aliasDataModel.emailsBlocked,
                    subtitle: 'Emails Blocked',
                  ),
                ),
              ],
            ),
            Divider(height: 10),
            Row(
              children: [
                Expanded(
                  child: AliasDetailListTile(
                    leadingIconData: Icons.access_time_outlined,
                    title: aliasDataModel.createdAt,
                    subtitle: 'Created At',
                  ),
                ),
                Expanded(
                  child: aliasDataModel.deletedAt == null
                      ? AliasDetailListTile(
                          leadingIconData: Icons.av_timer_outlined,
                          title: aliasDataModel.updatedAt,
                          subtitle: 'Updated At',
                        )
                      : AliasDetailListTile(
                          leadingIconData: Icons.auto_delete_outlined,
                          title: aliasDataModel.deletedAt,
                          subtitle: 'Deleted At',
                        ),
                )
              ],
            ),
            Divider(height: 10),
            AliasDetailListTile(
              leadingIconData: Icons.alternate_email,
              title: aliasDataModel.email,
              subtitle: 'Email',
              trailingIconData: Icons.copy,
              trailingIconOnPress: () => copyOnTap(aliasDataModel.email),
            ),
            AliasDetailListTile(
              leadingIconData: Icons.flaky_outlined,
              title: 'Alias is ${switchValue ? 'active' : 'inactive'}',
              subtitle: 'Activity',
              trailing: isLoading
                  ? CustomLoadingIndicator().customLoadingIndicator()
                  : Switch.adaptive(
                      value: switchValue,
                      onChanged: (toggle) {
                        toggleAlias(context, aliasDataModel.aliasID);
                      },
                    ),
            ),
            AliasDetailListTile(
              leadingIconData: Icons.comment,
              title: aliasDataModel.emailDescription,
              subtitle: 'Description',
              trailingIconData: Icons.edit,
              trailingIconOnPress: () {
                buildEditDescriptionDialog(
                  context,
                  _textEditingController,
                  editDescription,
                  aliasDataModel,
                );
              },
            ),
            AliasDetailListTile(
              leadingIconData: Icons.check_circle_outline,
              title: aliasDataModel.extension,
              subtitle: 'extension',
              trailingIconData: Icons.edit,
              trailingIconOnPress: () {},
            ),
            aliasDataModel.deletedAt == null
                ? AliasDetailListTile(
                    leadingIconData: Icons.delete_outline,
                    title: 'Delete Alias',
                    subtitle: 'Deleted alias will reject all emails sent to it',
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        buildDeleteAliasDialog(
                          context,
                          deleteOrRestoreAlias,
                          aliasDataModel,
                        );
                      },
                    ),
                  )
                : AliasDetailListTile(
                    leadingIconData: Icons.restore_outlined,
                    title: 'Restore Alias',
                    subtitle: 'Restored alias will be able to receive emails',
                    trailing: IconButton(
                      icon: Icon(Icons.restore_outlined, color: Colors.green),
                      onPressed: () {
                        buildRestoreAliasDialog(
                          context,
                          deleteOrRestoreAlias,
                          aliasDataModel,
                        );
                      },
                    ),
                  ),
            Divider(height: 0),
            if (aliasDataModel.recipients == null)
              Container()
            else
              ExpansionTile(
                initiallyExpanded: true,
                title: Text(
                  'Default recipient',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                children: [
                  if (aliasDataModel.recipients.isEmpty)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('No recipients found'),
                        RaisedButton.icon(
                          icon: Icon(Icons.add),
                          label: Text('Add recipient'),
                          onPressed: () {},
                        ),
                      ],
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: aliasDataModel.recipients.length,
                      itemBuilder: (context, index) {
                        final recipients = aliasDataModel.recipients;
                        return RecipientListTile(
                          recipientDataModel: recipients[index],
                        );
                      },
                    ),
                ],
              ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          ],
        ),
      ),
    );
  }

  Future buildDeleteAliasDialog(BuildContext context,
      Function deleteOrRestoreAlias, AliasDataModel aliasDataModel) {
    deleteAlias() {
      deleteOrRestoreAlias(
        context,
        aliasDataModel.deletedAt,
        aliasDataModel.aliasID,
      );
      Navigator.pop(context);
      Navigator.pop(context);
    }

    return showModal(
      context: context,
      builder: (context) {
        return isIOS
            ? confirmationDialog.iOSAlertDialog(
                context, kDeleteAliasConfirmation, deleteAlias, 'Delete Alias')
            : confirmationDialog.androidAlertDialog(
                context, kDeleteAliasConfirmation, deleteAlias, 'Delete Alias');
      },
    );
  }

  Future buildRestoreAliasDialog(BuildContext context,
      Function deleteOrRestoreAlias, AliasDataModel aliasDataModel) {
    restoreAlias() {
      deleteOrRestoreAlias(
        context,
        aliasDataModel.deletedAt,
        aliasDataModel.aliasID,
      );
      Navigator.pop(context);
      Navigator.pop(context);
    }

    return showModal(
      context: context,
      builder: (context) {
        return isIOS
            ? confirmationDialog.iOSAlertDialog(
                context, kRestoreAliasText, restoreAlias, 'Restore Alias')
            : confirmationDialog.androidAlertDialog(
                context, kRestoreAliasText, restoreAlias, 'Restore Alias');
      },
    );
  }

  Future buildEditDescriptionDialog(
      BuildContext context,
      TextEditingController _textEditingController,
      Function editDescription,
      AliasDataModel aliasDataModel) {
    void editDesc() {
      editDescription(
        context,
        aliasDataModel.aliasID,
        _textEditingController.text.trim(),
      );
      Navigator.pop(context);
    }

    return showModal(
      context: context,
      builder: (context) {
        return isIOS
            ? CupertinoAlertDialog(
                title: Text('Update description'),
                content: CupertinoTextField(
                  autofocus: true,
                  controller: _textEditingController,
                  onEditingComplete: () => editDesc(),
                  placeholder: '${aliasDataModel.emailDescription}',
                ),
                actions: [
                  CupertinoDialogAction(
                    child: Text('Update'),
                    onPressed: () => editDesc(),
                  ),
                  CupertinoDialogAction(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              )
            : AlertDialog(
                title: Text('Update description'),
                content: TextFormField(
                  autofocus: true,
                  controller: _textEditingController,
                  onFieldSubmitted: (toggle) => editDesc(),
                  decoration: kTextFormFieldDecoration.copyWith(
                    hintText: '${aliasDataModel.emailDescription}',
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('Update'),
                    onPressed: () => editDesc(),
                  ),
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              );
      },
    );
  }

  Widget buildAppBar(BuildContext context) {
    final customAppBar = CustomAppBar();

    return customAppBar.androidAppBar(context, 'Alias');

    //todo fix CupertinoNavigationBar causing build failure
    // return isIOS
    //     ? customAppBar.iOSAppBar(context, 'Alias')
    //     : customAppBar.androidAppBar(context, 'Alias');
  }
}
