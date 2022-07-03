import 'package:rauschmelder/api/model/party.dart';

enum PartyListingStatus { initial, success, error, loading, joined }

extension PartyListingStatusX on PartyListingStatus {
  bool get isInitial => this == PartyListingStatus.initial;

  bool get isSuccess => this == PartyListingStatus.success;

  bool get isError => this == PartyListingStatus.error;

  bool get isLoading => this == PartyListingStatus.loading;

  bool get isJoined => this == PartyListingStatus.joined;
}

class PartyListingState {
  final List<Party> parties;
  final PartyListingStatus status;
  final Key? joinedParty;

  const PartyListingState({
    this.status = PartyListingStatus.initial,
    List<Party>? parties,
    this.joinedParty,
  }) : parties = parties ?? const [];

  @override
  List<Object?> get props => [status, parties, joinedParty];

  PartyListingState copyWith({
    List<Party>? parties,
    PartyListingStatus? status,
    Key? joinedParty,
  }) {
    return PartyListingState(
      parties: parties ?? this.parties,
      status: status ?? this.status,
      joinedParty: joinedParty ?? this.joinedParty,
    );
  }
}
