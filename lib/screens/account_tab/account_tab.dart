import 'package:anonaddy/screens/account_tab/main_account_card.dart';
import 'package:flutter/material.dart';

import 'additional_username.dart';
import 'domains.dart';

class AccountTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4),
      child: Column(
        children: [
          MainAccount(),
          AdditionalUsername(),
          Domains(),
        ],
      ),
    );
  }
}
