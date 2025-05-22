import 'package:wortspion/blocs/round/round_state.dart';
import 'package:wortspion/data/models/round_score_result.dart';

/// Simple state manager for round results that need to be passed between screens
class RoundResultsState {
  static RoundResultsState? _instance;
  
  factory RoundResultsState() {
    _instance ??= RoundResultsState._internal();
    return _instance!;
  }
  
  RoundResultsState._internal();
  
  String? gameId;
  int? roundNumber;
  int? totalRounds;
  List<RoundScoreResult> scoreResults = [];
  List<PlayerRoleInfo> playerRoles = [];
  String secretWord = '';
  bool impostorsWon = false;
  bool wordGuessed = false;
  
  void setRoundResults({
    required String gameId,
    required int roundNumber,
    required int totalRounds,
    required List<RoundScoreResult> scoreResults,
    required List<PlayerRoleInfo> playerRoles,
    required String secretWord,
    required bool impostorsWon,
    required bool wordGuessed,
  }) {
    this.gameId = gameId;
    this.roundNumber = roundNumber;
    this.totalRounds = totalRounds;
    this.scoreResults = scoreResults;
    this.playerRoles = playerRoles;
    this.secretWord = secretWord;
    this.impostorsWon = impostorsWon;
    this.wordGuessed = wordGuessed;
  }
  
  void clear() {
    gameId = null;
    roundNumber = null;
    totalRounds = null;
    scoreResults = [];
    playerRoles = [];
    secretWord = '';
    impostorsWon = false;
    wordGuessed = false;
  }
}
