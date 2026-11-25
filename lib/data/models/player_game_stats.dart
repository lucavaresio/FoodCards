class PlayerGameStats {
  const PlayerGameStats({
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
  }) : assert(matchesPlayed >= 0),
       assert(wins >= 0),
       assert(losses >= 0),
       assert(wins + losses == matchesPlayed);

  const PlayerGameStats.empty() : matchesPlayed = 0, wins = 0, losses = 0;

  final int matchesPlayed;
  final int wins;
  final int losses;

  double get winRate => matchesPlayed == 0 ? 0 : wins / matchesPlayed;

  PlayerGameStats recordResult({required bool won}) => PlayerGameStats(
    matchesPlayed: matchesPlayed + 1,
    wins: wins + (won ? 1 : 0),
    losses: losses + (won ? 0 : 1),
  );

  factory PlayerGameStats.fromJson(Map<String, dynamic> json) {
    final matchesPlayed = json['matchesPlayed'];
    final wins = json['wins'];
    final losses = json['losses'];
    if (matchesPlayed is! int || wins is! int || losses is! int) {
      throw const FormatException('Statistiche partita non valide');
    }
    if (matchesPlayed < 0 ||
        wins < 0 ||
        losses < 0 ||
        wins + losses != matchesPlayed) {
      throw const FormatException('Statistiche partita incoerenti');
    }
    return PlayerGameStats(
      matchesPlayed: matchesPlayed,
      wins: wins,
      losses: losses,
    );
  }

  Map<String, int> toJson() => {
    'matchesPlayed': matchesPlayed,
    'wins': wins,
    'losses': losses,
  };
}
