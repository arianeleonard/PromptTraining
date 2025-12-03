class PromptEvaluation {
  final int score; // 1..10
  final String explanation;

  const PromptEvaluation({required this.score, required this.explanation});

  factory PromptEvaluation.fromJson(Map<String, dynamic> json) {
    final rawScore = json['score'];
    int parsedScore;
    if (rawScore is int) {
      parsedScore = rawScore;
    } else if (rawScore is double) {
      parsedScore = rawScore.round();
    } else if (rawScore is String) {
      parsedScore = int.tryParse(rawScore) ?? 0;
    } else {
      parsedScore = 0;
    }
    parsedScore = parsedScore.clamp(1, 10);

    final explanation = (json['explanation'] ?? '').toString();
    return PromptEvaluation(score: parsedScore, explanation: explanation);
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'explanation': explanation,
      };
}
