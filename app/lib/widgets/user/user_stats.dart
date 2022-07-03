import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'drunken_status.dart';
import 'user_state.dart';
import '../card.dart';

class UserStats extends StatelessWidget {
  final UserModel model;
  const UserStats({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _buildUserStatsItem(String value, String text) => <Widget>[
      Text(value).fontSize(20).textColor(Colors.white).padding(bottom: 5),
      Text(text).textColor(Colors.white.withOpacity(0.6)).fontSize(12),
    ].toColumn();

    Widget _buildUserStats() {
      return <Widget>[
        _buildUserStatsItem('2th', 'Place'),
        _buildUserStatsItem('10', 'Total Drinks'),
        _buildUserStatsItem('2h', 'Since last drink'),
        _buildUserStatsItem('30', 'Attended Parties'),
      ]
          .toRow(mainAxisAlignment: MainAxisAlignment.spaceAround)
          .padding(vertical: 12);
    }

    return <Widget>[
      DrunkenStatus(model: model).padding(left: 12, top: 12, right: 12),
      _buildUserStats()
    ].toColumn(mainAxisAlignment: MainAxisAlignment.spaceAround)
        .parent(({required child}) => StyledCard(child: child));

  }
}