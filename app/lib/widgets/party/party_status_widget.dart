import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rauschmelder/widgets/party/bloc/party_listing_bloc.dart';
import 'package:rauschmelder/widgets/party/bloc/party_listing_state.dart';
import 'package:styled_widget/styled_widget.dart';

import '../card.dart';

class PartyStatus extends StatelessWidget {
  const PartyStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PartyListingBloc, PartyListingState>(
      builder: (context, state) {
        var partiesCount = state.parties.length;
        String text = "";

        if (state.status.isSuccess) {
          if (partiesCount > 0) {
            text =
            "$partiesCount Parties in der Nähe. Tritt bei!";
          } else {
            text =
            "Keine Party in der Nähe. Jetzt eine erstellen!";
          }
        } else if(state.status.isError || state.status.isInitial) {
          text = "Jetzt einer Party beitreten oder eine erstellen!";
        }

        return <Widget>[
          Text(text)
              .textColor(Colors.white)
              .fontSize(15),
          const Icon(LineIcons.angleRight)
              .iconColor(Colors.white)
        ]
            .toRow(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween)
            .padding(left: 12, right: 12, bottom: 12, top: 155)
            .parent(({required child}) =>
            StyledCard(
              color: Colors.blueGrey.shade200,
              child: child,))
            .gestures(
          onTap: () => print("join parties"),
        );
      },
    );
  }
}
