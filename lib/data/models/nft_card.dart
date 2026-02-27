class NFTCard {
  final String tokenId;
  final String contractAddress;
  final String ownerAddress;
  final Map<String, dynamic> metadata;
  final DateTime mintedAt;

  NFTCard({required this.tokenId, required this.contractAddress, required this.ownerAddress, required this.metadata, required this.mintedAt});

  Map<String, dynamic> toJson() {
    return {
      'tokenId': tokenId,
      'contractAddress': contractAddress,
      'ownerAddress': ownerAddress,
      'metadata': metadata,
      'mintedAt': mintedAt.toIso8601String(),
    };
  }

  factory NFTCard.fromJson(Map<String, dynamic> json) {
    return NFTCard(
      tokenId: json['tokenId'],
      contractAddress: json['contractAddress'],
      ownerAddress: json['ownerAddress'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      mintedAt: DateTime.parse(json['mintedAt']),
    );
  }
}
