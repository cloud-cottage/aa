class User {
  final String userId;
  final String displayName;
  final String? email;
  final String? walletAddress;
  int goldBalance;
  List<String> nftOwnedTokenIds;
  final String? avatarPath;

  User({
    required this.userId, 
    required this.displayName, 
    this.email, 
    this.walletAddress, 
    this.goldBalance = 0, 
    List<String>? nftOwnedTokenIds,
    this.avatarPath,
  }) : nftOwnedTokenIds = nftOwnedTokenIds ?? [];

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'walletAddress': walletAddress,
      'goldBalance': goldBalance,
      'nftOwnedTokenIds': nftOwnedTokenIds,
      'avatarPath': avatarPath,
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
      avatarPath: json['avatarPath'],
    );
  }
}
