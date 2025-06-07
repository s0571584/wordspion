import 'package:equatable/equatable.dart';

enum RoundState {
  roleAssignment,
  roleReveal,
  discussion,
  voting,
  resolution,
  completed,
}

class MultiplayerRound extends Equatable {
  final String id;
  final String roomId;
  final int roundNumber;
  final String mainWordId;
  final String decoyWordId;
  final String categoryId;
  final RoundState roundState;
  final DateTime startedAt;
  final DateTime? discussionStartedAt;
  final DateTime? votingStartedAt;
  final DateTime? completedAt;
  final bool? impostorsWon;
  final bool wordGuessed;
  final Map<String, int>? scores;

  const MultiplayerRound({
    required this.id,
    required this.roomId,
    required this.roundNumber,
    required this.mainWordId,
    required this.decoyWordId,
    required this.categoryId,
    this.roundState = RoundState.roleAssignment,
    required this.startedAt,
    this.discussionStartedAt,
    this.votingStartedAt,
    this.completedAt,
    this.impostorsWon,
    this.wordGuessed = false,
    this.scores,
  });

  factory MultiplayerRound.fromJson(Map<String, dynamic> json) {
    return MultiplayerRound(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      roundNumber: json['round_number'] as int,
      mainWordId: json['main_word_id'] as String,
      decoyWordId: json['decoy_word_id'] as String,
      categoryId: json['category_id'] as String,
      roundState: _parseRoundState(json['round_state'] as String?),
      startedAt: DateTime.parse(json['started_at'] as String),
      discussionStartedAt: json['discussion_started_at'] != null
          ? DateTime.parse(json['discussion_started_at'] as String)
          : null,
      votingStartedAt: json['voting_started_at'] != null
          ? DateTime.parse(json['voting_started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      impostorsWon: json['impostors_won'] as bool?,
      wordGuessed: json['word_guessed'] as bool? ?? false,
      scores: json['scores'] != null 
          ? Map<String, int>.from(json['scores'] as Map)
          : null,
    );
  }

  static RoundState _parseRoundState(String? state) {
    switch (state) {
      case 'role_assignment':
        return RoundState.roleAssignment;
      case 'role_reveal':
        return RoundState.roleReveal;
      case 'discussion':
        return RoundState.discussion;
      case 'voting':
        return RoundState.voting;
      case 'resolution':
        return RoundState.resolution;
      case 'completed':
        return RoundState.completed;
      default:
        return RoundState.roleAssignment;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'round_number': roundNumber,
      'main_word_id': mainWordId,
      'decoy_word_id': decoyWordId,
      'category_id': categoryId,
      'round_state': _roundStateToString(roundState),
      'started_at': startedAt.toIso8601String(),
      'discussion_started_at': discussionStartedAt?.toIso8601String(),
      'voting_started_at': votingStartedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'impostors_won': impostorsWon,
      'word_guessed': wordGuessed,
    };
  }

  static String _roundStateToString(RoundState state) {
    switch (state) {
      case RoundState.roleAssignment:
        return 'role_assignment';
      case RoundState.roleReveal:
        return 'role_reveal';
      case RoundState.discussion:
        return 'discussion';
      case RoundState.voting:
        return 'voting';
      case RoundState.resolution:
        return 'resolution';
      case RoundState.completed:
        return 'completed';
    }
  }

  MultiplayerRound copyWith({
    String? id,
    String? roomId,
    int? roundNumber,
    String? mainWordId,
    String? decoyWordId,
    String? categoryId,
    RoundState? roundState,
    DateTime? startedAt,
    DateTime? discussionStartedAt,
    DateTime? votingStartedAt,
    DateTime? completedAt,
    bool? impostorsWon,
    bool? wordGuessed,
    Map<String, int>? scores,
  }) {
    return MultiplayerRound(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      roundNumber: roundNumber ?? this.roundNumber,
      mainWordId: mainWordId ?? this.mainWordId,
      decoyWordId: decoyWordId ?? this.decoyWordId,
      categoryId: categoryId ?? this.categoryId,
      roundState: roundState ?? this.roundState,
      startedAt: startedAt ?? this.startedAt,
      discussionStartedAt: discussionStartedAt ?? this.discussionStartedAt,
      votingStartedAt: votingStartedAt ?? this.votingStartedAt,
      completedAt: completedAt ?? this.completedAt,
      impostorsWon: impostorsWon ?? this.impostorsWon,
      wordGuessed: wordGuessed ?? this.wordGuessed,
      scores: scores ?? this.scores,
    );
  }

  bool get isCompleted => roundState == RoundState.completed;
  bool get isInProgress => roundState != RoundState.completed;
  bool get canStartDiscussion => roundState == RoundState.roleReveal;
  bool get canStartVoting => roundState == RoundState.discussion;

  Duration? get discussionDuration {
    if (discussionStartedAt == null) return null;
    final endTime = votingStartedAt ?? DateTime.now();
    return endTime.difference(discussionStartedAt!);
  }

  Duration? get votingDuration {
    if (votingStartedAt == null) return null;
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(votingStartedAt!);
  }

  @override
  List<Object?> get props => [
        id,
        roomId,
        roundNumber,
        mainWordId,
        decoyWordId,
        categoryId,
        roundState,
        startedAt,
        discussionStartedAt,
        votingStartedAt,
        completedAt,
        impostorsWon,
        wordGuessed,
        scores,
      ];
}