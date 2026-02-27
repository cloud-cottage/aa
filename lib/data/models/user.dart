class User {
  final String userId;
  final String displayName;
  final String? email;
  final String? walletAddress;
  int goldBalance;
  List<String> nftOwnedTokenIds;

  User({required this.userId, required this.displayName, this.email, this.walletAddress, this.goldBalance = 0, List<String>? nftOwnedTokenIds})
      : nftOwnedTokenIds = nftOwnedTokenIds ?? [];

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'walletAddress': walletAddress,
      'goldBalance': goldBalance,
      'nftOwnedTokenIds': nftOwnedTokenIds,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      displayName: json['displayName'],
      email: json['email'],
      walletAddress: json['walletAddress'],
      goldBalance: json['goldBalance'] ?? 0,
      nftOwnedTokenIds: List<String>.from(json['nftOwnedTokenIds'] ?? []),
    );
  }
}
