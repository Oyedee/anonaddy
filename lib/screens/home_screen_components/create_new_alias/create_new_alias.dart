import 'package:anonaddy/global_providers.dart';
import 'package:anonaddy/models/account/account_model.dart';
import 'package:anonaddy/shared_components/bottom_sheet_header.dart';
import 'package:anonaddy/shared_components/constants/material_constants.dart';
import 'package:anonaddy/shared_components/constants/official_anonaddy_strings.dart';
import 'package:anonaddy/shared_components/constants/ui_strings.dart';
import 'package:anonaddy/shared_components/loading_indicator.dart';
import 'package:anonaddy/shared_components/lottie_widget.dart';
import 'package:anonaddy/state_management/create_alias/create_alias_notifier.dart';
import 'package:anonaddy/state_management/domain_options/domain_options_notifier.dart';
import 'package:anonaddy/state_management/domain_options/domain_options_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'alias_domain_selection.dart';
import 'alias_format_selection.dart';
import 'create_alias_recipient_selection.dart';

class CreateNewAlias extends ConsumerWidget {
  CreateNewAlias({Key? key, required this.account}) : super(key: key);
  final Account account;

  final _localPartFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final domainOptionsState = watch(domainOptionsStateNotifier);

    final size = MediaQuery.of(context).size;

    switch (domainOptionsState.status) {
      case DomainOptionsStatus.loading:
        return Container(
          height: size.height * 0.5,
          child: LoadingIndicator(),
        );

      case DomainOptionsStatus.loaded:
        return createAliasWidget(context, domainOptionsState);

      case DomainOptionsStatus.failed:
        final error = domainOptionsState.errorMessage;
        return LottieWidget(
          lottie: 'assets/lottie/errorCone.json',
          label: error.toString(),
          lottieHeight: MediaQuery.of(context).size.height * 0.2,
        );
    }
  }

  Widget createAliasWidget(
      BuildContext context, DomainOptionsState domainOptionsState) {
    final size = MediaQuery.of(context).size;
    final createAliasText =
        'Other aliases e.g. alias@${account.username}.anonaddy.com or .me can also be created automatically when they receive their first email.';

    return Consumer(builder: (context, watch, _) {
      final createAliasState = watch(createAliasNotifier);
      final onPressNotifier = context.read(createAliasNotifier.notifier);

      Future createAlias() async {
        if (!createAliasState.isAliasDomainNull()) {
          if (!createAliasState.isAliasFormatNull()) {
            if (createAliasState.aliasFormat == kCustom) {
              if (_localPartFormKey.currentState!.validate()) {
                await onPressNotifier.createNewAlias();
                Navigator.pop(context);
              }
            } else {
              await onPressNotifier.createNewAlias();
              Navigator.pop(context);
            }
          } else {
            onPressNotifier.setAliasFormatError(true);
          }
        } else {
          onPressNotifier.setAliasDomainError(true);
        }
      }

      return Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BottomSheetHeader(headerLabel: kCreateNewAlias),
              Padding(
                padding:
                    EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(createAliasText),
                    SizedBox(height: size.height * 0.01),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      onChanged: (input) =>
                          onPressNotifier.setDescription(input),
                      decoration: kTextFormFieldDecoration.copyWith(
                        hintText: kDescriptionFieldHint,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                    localPartInputField(
                        context, createAliasState, onPressNotifier),
                    SizedBox(height: size.height * 0.01),
                    aliasDomainFormatDropdown(
                      context: context,
                      title: 'Alias Domain',
                      label: createAliasState.aliasDomain ?? kSelectAliasDomain,
                      isError: createAliasState.isAliasDomainError!,
                      onPress: () {
                        onPressNotifier.setAliasDomainError(false);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(kBottomSheetBorderRadius),
                            ),
                          ),
                          builder: (context) => AliasDomainSelection(
                            domainOptions: domainOptionsState.domainOptions!,
                            setAliasDomain: (domain) {
                              onPressNotifier.setAliasDomain(domain);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                    SizedBox(height: size.height * 0.01),
                    aliasDomainFormatDropdown(
                      context: context,
                      title: 'Alias Format',
                      label: createAliasState.aliasFormat == null
                          ? kSelectAliasFormat
                          : context.read(nicheMethods).correctAliasString(
                              createAliasState.aliasFormat!),
                      isError: createAliasState.isAliasFormatError!,
                      onPress: () {
                        onPressNotifier.setAliasFormatError(false);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(kBottomSheetBorderRadius),
                            ),
                          ),
                          builder: (context) => AliasFormatSelection(
                            setAliasFormat: (format) {
                              onPressNotifier.setAliasFormat(format);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                    buildNote(context, createAliasState),
                    SizedBox(height: size.height * 0.02),
                    recipientsDropdown(context),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(),
                  child: createAliasState.isLoading!
                      ? context
                          .read(customLoadingIndicator)
                          .customLoadingIndicator()
                      : Text(kCreateAlias),
                  onPressed:
                      createAliasState.isLoading! ? () {} : () => createAlias(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget localPartInputField(BuildContext context,
      CreateAliasNotifier createAliasState, onPressNotifier) {
    final size = MediaQuery.of(context).size;
    final aliasFormat = createAliasState.aliasFormat ?? '';

    if (aliasFormat == kCustom) {
      return Column(
        children: [
          SizedBox(height: size.height * 0.01),
          Form(
            key: _localPartFormKey,
            child: TextFormField(
              onChanged: (input) => onPressNotifier.setLocalPart(input),
              validator: (input) =>
                  context.read(formValidator).validateLocalPart(input!),
              textInputAction: TextInputAction.next,
              decoration: kTextFormFieldDecoration.copyWith(
                hintText: kLocalPartFieldHint,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Widget buildNote(BuildContext context, CreateAliasNotifier createAliasState) {
    final aliasFormat = createAliasState.aliasFormat ?? '';
    if (aliasFormat == kCustom) {
      return Text(
        kCreateAliasCustomFieldNote,
        style: Theme.of(context).textTheme.caption,
      );
    }
    return Container();
  }

  Widget aliasDomainFormatDropdown(
      {required BuildContext context,
      required String title,
      required String label,
      required bool isError,
      required Function onPress}) {
    final size = MediaQuery.of(context).size;

    return InkWell(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.01,
          horizontal: 1,
        ),
        decoration: BoxDecoration(
          color: isError ? Colors.redAccent : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Icon(Icons.keyboard_arrow_down_rounded),
              ],
            ),
          ],
        ),
      ),
      onTap: () => onPress(),
    );
  }

  Widget recipientsDropdown(BuildContext context) {
    final createAliasRecipients =
        context.read(createAliasNotifier).createAliasRecipients;
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recipients'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (createAliasRecipients.isEmpty)
                Text('Select recipient(s) (optional)')
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: createAliasRecipients.length,
                    itemBuilder: (context, index) {
                      final recipient = createAliasRecipients[index];
                      return Text(
                        recipient.email,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1!
                            .copyWith(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
              Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ],
      ),
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(kBottomSheetBorderRadius)),
        ),
        builder: (context) => CreateAliasRecipientSelection(),
      ),
    );
  }
}
