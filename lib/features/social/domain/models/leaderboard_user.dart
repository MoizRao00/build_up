class LeaderboardUser {
  final String id;
  final String displayName;
  final int totalSteps;
  final String photoUrl;

  const LeaderboardUser({
    required this.id,
    required this.displayName,
    required this.totalSteps,
    this.photoUrl = '',
  });

  factory LeaderboardUser.fromFirestore(Map<String, dynamic> json, String id) {
    return LeaderboardUser(
      id: id,
      displayName: json['displayName'] ?? 'Unknown User',
      totalSteps: json['totalSteps'] ?? 0,
      photoUrl: json['photoUrl'] ?? '',
    );
  }
}