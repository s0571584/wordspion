import 'package:equatable/equatable.dart';

/// Represents the score result for a player in a single round
class RoundScoreResult extends Equatable {
  final String playerId;
  final String playerName;
  final int scoreChange;
  final int totalScore;
  final bool isSpy;
  final String reason;

  const RoundScoreResult({
    required this.playerId,
    required this.playerName,
    required this.scoreChange,
    required this.totalScore,
    required this.isSpy,
    this.reason = '',
  });

  @override
  List<Object> get props => [
        playerId,
        playerName,
        scoreChange,
        totalScore,
        isSpy,
        reason,
      ];

  factory RoundScoreResult.fromMap(Map<String, dynamic> map) {
    return RoundScoreResult(
      playerId: map['player_id'] as String,
      playerName: map['player_name'] as String,
      scoreChange: map['score_change'] as int,
      totalScore: map['total_score'] as int,
      isSpy: map['is_spy'] == 1,
      reason: map['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'player_id': playerId,
      'player_name': playerName,
      'score_change': scoreChange,
      'total_score': totalScore,
      'is_spy': isSpy ? 1 : 0,
      'reason': reason,
    };
  }

  RoundScoreResult copyWith({
    String? playerId,
    String? playerName,
    int? scoreChange,
    int? totalScore,
    bool? isSpy,
    String? reason,
  }) {
    return RoundScoreResult(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      scoreChange: scoreChange ?? this.scoreChange,
      totalScore: totalScore ?? this.totalScore,
      isSpy: isSpy ?? this.isSpy,
      reason: reason ?? this.reason,
    );
  }

  @override
  String toString() {
    return 'RoundScoreResult(playerId: $playerId, playerName: $playerName, scoreChange: $scoreChange, totalScore: $totalScore, isSpy: $isSpy, reason: $reason)';
  }
}
