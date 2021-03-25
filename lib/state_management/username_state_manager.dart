import 'package:anonaddy/state_management/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

final usernameStateManagerProvider =
    ChangeNotifierProvider((ref) => UsernameStateManager());

class UsernameStateManager extends ChangeNotifier {
  final usernameFormKey = GlobalKey<FormState>();

  Future<void> createNewUsername(BuildContext context, String username,
      TextEditingController textEditController) async {
    if (usernameFormKey.currentState.validate()) {
      await context
          .read(usernameServiceProvider)
          .createNewUsername(username)
          .then((value) {
        print(value);
        showToast('Username added successfully!');
        Navigator.pop(context);
      }).catchError((error) {
        showToast(error.toString());
      });
      textEditController.clear();
    }
  }

  Future<void> deleteUsername(BuildContext context, String usernameID) async {
    Navigator.pop(context);
    await context
        .read(usernameServiceProvider)
        .deleteUsername(usernameID)
        .then((value) {
      Navigator.pop(context);
      showToast('Username deleted successfully!');
    }).catchError((error) {
      showToast(error.toString());
    });
  }

  showToast(String input) {
    Fluttertoast.showToast(
      msg: input,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[600],
    );
  }
}
