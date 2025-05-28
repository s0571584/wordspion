import 'package:equatable/equatable.dart';

class SpyWordSet extends Equatable {
  final String mainWordText;
  final List<SpyWordInfo> spyWords;
  
  const SpyWordSet({
    required this.mainWordText,
    required this.spyWords,
  });

  @override
  List<Object> get props => [mainWordText, spyWords];

  @override
  String toString() {
    return 'SpyWordSet(mainWordText: $mainWordText, spyWords: ${spyWords.length} words)';
  }
}

class SpyWordInfo extends Equatable {
  final String text;
  final String relationshipType;
  final int difficulty;
  final int priority;
  
  const SpyWordInfo({
    required this.text,
    required this.relationshipType,
    required this.difficulty,  
    required this.priority,
  });

  @override
  List<Object> get props => [text, relationshipType, difficulty, priority];

  // Factory method to create from database map
  factory SpyWordInfo.fromMap(Map<String, dynamic> map) {
    return SpyWordInfo(
      text: map['spy_word'] as String,
      relationshipType: map['relationship_type'] as String,
      difficulty: map['difficulty'] as int,
      priority: map['priority'] as int,
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'spy_word': text,
      'relationship_type': relationshipType,
      'difficulty': difficulty,
      'priority': priority,
    };
  }

  @override
  String toString() {
    return 'SpyWordInfo(text: $text, type: $relationshipType, difficulty: $difficulty, priority: $priority)';
  }
}

// Relationship type constants
class SpyWordRelationshipType {
  static const String location = 'location';
  static const String component = 'component';
  static const String tool = 'tool';
  static const String person = 'person';
  static const String action = 'action';
  static const String attribute = 'attribute';
}
