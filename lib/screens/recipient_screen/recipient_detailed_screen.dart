import 'package:animations/animations.dart';
import 'package:anonaddy/models/recipient/recipient_data_model.dart';
import 'package:anonaddy/state_management/recipient_state_manager.dart';
import 'package:anonaddy/utilities/confirmation_dialog.dart';
import 'package:anonaddy/utilities/target_platform.dart';
import 'package:anonaddy/widgets/alias_detail_list_tile.dart';
import 'package:anonaddy/widgets/alias_list_tile.dart';
import 'package:anonaddy/widgets/custom_app_bar.dart';
import 'package:anonaddy/widgets/custom_loading_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants.dart';

class RecipientDetailedScreen extends ConsumerWidget {
  RecipientDetailedScreen({this.recipientData});

  final RecipientDataModel recipientData;

  final isIOS = TargetedPlatform().isIOS();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final size = MediaQuery.of(context).size;

    final recipientStateProvider = watch(recipientStateManagerProvider);
    final encryptionSwitch = recipientStateProvider.encryptionSwitch;
    final isLoading = recipientStateProvider.isLoading;
    final copyOnTap = recipientStateProvider.copyOnTap;
    final toggleEncryption = recipientStateProvider.toggleEncryption;
    final addPublicGPGKey = recipientStateProvider.addPublicGPGKey;
    final removePublicGPGKey = recipientStateProvider.removePublicGPGKey;
    final verifyEmail = recipientStateProvider.verifyEmail;
    final removeRecipient = recipientStateProvider.removeRecipient;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 20, bottom: 50),
              child: SvgPicture.asset(
                'assets/images/envelope.svg',
                height: size.height * 0.2,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: AliasDetailListTile(
                    leadingIconData: Icons.access_time_outlined,
                    title: recipientData.createdAt,
                    subtitle: 'Created At',
                  ),
                ),
                Expanded(
                  child: AliasDetailListTile(
                    leadingIconData: Icons.av_timer_outlined,
                    title: recipientData.updatedAt,
                    subtitle: 'Updated at',
                  ),
                )
              ],
            ),
            Divider(height: 10),
            AliasDetailListTile(
              leadingIconData: Icons.email_outlined,
              title: recipientData.email,
              subtitle: 'Recipient Email',
              trailing: IconButton(
                icon: Icon(Icons.copy),
                onPressed: () => copyOnTap(recipientData.email),
              ),
            ),
            AliasDetailListTile(
              leadingIconData: Icons.delete_outline,
              title: recipientData.email,
              subtitle: 'Delete recipient',
              trailing: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                onPressed: () => buildRemoveRecipient(context, removeRecipient),
              ),
            ),
            AliasDetailListTile(
              leadingIconData: Icons.fingerprint_outlined,
              title: recipientData.fingerprint == null
                  ? 'No fingerprint found'
                  : '${recipientData.fingerprint}',
              subtitle: 'GPG Key Fingerprint',
              trailing: recipientData.fingerprint == null
                  ? IconButton(
                      icon: Icon(Icons.add_circle_outline_outlined),
                      onPressed: () => buildAddPGPKeyDialog(
                          context, recipientData, addPublicGPGKey),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.delete_outline_outlined,
                        color: Colors.red,
                      ),
                      onPressed: () =>
                          buildRemovePGPKeyDialog(context, removePublicGPGKey),
                    ),
            ),
            AliasDetailListTile(
              leadingIconData: encryptionSwitch ? Icons.lock : Icons.lock_open,
              leadingIconColor: encryptionSwitch ? Colors.green : null,
              title: '${encryptionSwitch ? 'Encrypted' : 'Not Encrypted'}',
              subtitle: 'Encryption',
              trailing: recipientData.fingerprint == null
                  ? null
                  : isLoading
                      ? CustomLoadingIndicator().customLoadingIndicator()
                      : Switch.adaptive(
                          value: encryptionSwitch,
                          onChanged: (toggle) =>
                              toggleEncryption(context, recipientData.id),
                        ),
            ),
            recipientData.emailVerifiedAt == null
                ? AliasDetailListTile(
                    leadingIconData: Icons.verified_outlined,
                    title: recipientData.emailVerifiedAt == null ? 'No' : 'Yes',
                    subtitle: 'Is Email Verified?',
                    trailing: recipientData.emailVerifiedAt == null
                        ? ElevatedButton(
                            child: Text('Verify now!'),
                            onPressed: () =>
                                verifyEmail(context, recipientData.id),
                          )
                        : null,
                  )
                : Container(),
            SizedBox(height: 10),
            Divider(height: 0),
            if (recipientData.aliases == null)
              Container()
            else if (recipientData.emailVerifiedAt == null)
              Container(
                height: size.height * 0.05,
                width: double.infinity,
                color: Colors.amber,
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_outlined, color: Colors.black),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(kUnverifiedRecipient,
                          style: TextStyle(color: Colors.black)),
                    ),
                    Container(),
                  ],
                ),
              )
            else
              ExpansionTile(
                initiallyExpanded: true,
                title: Text(
                  'Associated Aliases',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                childrenPadding: EdgeInsets.symmetric(horizontal: 12),
                children: [
                  if (recipientData.aliases.isEmpty)
                    Text('No aliases found')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: recipientData.aliases.length,
                      itemBuilder: (context, index) {
                        return AliasListTile(
                          aliasData: recipientData.aliases[index],
                        );
                      },
                    ),
                ],
              ),
            SizedBox(height: size.height * 0.01),
          ],
        ),
      ),
    );
  }

  Future buildRemovePGPKeyDialog(
      BuildContext context, Function removePublicGPGKey) {
    final confirmationDialog = ConfirmationDialog();

    void removePublicKey() {
      removePublicGPGKey(context, recipientData.id);
    }

    return showModal(
      context: context,
      builder: (context) {
        return isIOS
            ? confirmationDialog.iOSAlertDialog(
                context,
                kRemoveRecipientPublicKeyBody,
                removePublicKey,
                'Remove Public Key')
            : confirmationDialog.androidAlertDialog(
                context,
                kRemoveRecipientPublicKeyBody,
                removePublicKey,
                'Remove Public Key');
      },
    );
  }

  Future buildAddPGPKeyDialog(BuildContext context,
      RecipientDataModel recipientData, Function addPublicGPGKey) {
    final _texEditingController = TextEditingController();

    void addPublicKey() {
      addPublicGPGKey(context, recipientData.id, _texEditingController.text);
      _texEditingController.clear();
    }

    return showModal(
      context: context,
      builder: (context) {
        return isIOS
            ? CupertinoAlertDialog(
                title: Text('Add Public GPG Key'),
                content: Column(
                  children: [
                    Text(kEnterPublicKeyData),
                    SizedBox(height: 5),
                    CupertinoTextField(
                      autofocus: true,
                      controller: _texEditingController,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () => addPublicKey(),
                      placeholder: kPublicGPGKeyHintText,
                      minLines: 3,
                      maxLines: 8,
                    ),
                  ],
                ),
                actions: [
                  CupertinoDialogAction(
                    child: Text('Add Key'),
                    onPressed: () => addPublicKey(),
                  ),
                  CupertinoDialogAction(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              )
            : AlertDialog(
                title: Text('Add Public GPG Key'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(kEnterPublicKeyData),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: _texEditingController,
                      minLines: 3,
                      maxLines: 8,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (submit) => addPublicKey(),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(5),
                        hintText: kPublicGPGKeyHintText,
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kBlueNavyColor),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text('Add Key'),
                    onPressed: () => addPublicGPGKey(
                        context, recipientData.id, _texEditingController.text),
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

  Future buildRemoveRecipient(BuildContext context, Function removeRecipient) {
    final confirmationDialog = ConfirmationDialog();

    void remove() {
      removeRecipient(context, recipientData.id);
      Navigator.pop(context);
    }

    return showModal(
      context: context,
      builder: (context) {
        return isIOS
            ? confirmationDialog.iOSAlertDialog(
                context, kDeleteRecipientDialogText, remove, 'Delete recipient')
            : confirmationDialog.androidAlertDialog(context,
                kDeleteRecipientDialogText, remove, 'Delete recipient');
      },
    );
  }

  Widget buildAppBar(BuildContext context) {
    final customAppBar = CustomAppBar();

    return customAppBar.androidAppBar(context, 'Recipient');

    //todo fix CupertinoNavigationBar causing build failure
    // return isIOS
    //     ? customAppBar.iOSAppBar(context, 'Recipient')
    //     : customAppBar.androidAppBar(context, 'Recipient');
  }
}
