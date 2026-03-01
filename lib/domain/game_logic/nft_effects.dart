import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';
import 'package:aa_doudizhu/domain/game_logic/card_type.dart';
import 'package:aa_doudizhu/data/models/nft_card.dart';

enum NFTEffectType {
  bombDouble,        // 炸弹积分翻倍
  rocketTriple,      // 火箭积分三倍
  springBonus,       // 春天额外奖励
  antiSpringBonus,   // 反春天额外奖励
  cardDrawBonus,     // 额外抽牌优势
  scoreMultiplier,   // 通用积分倍数
}

class NFTEffect {
  final NFTEffectType type;
  final double multiplier;
  final String description;
  final Map<String, dynamic> conditions;

  NFTEffect({
    required this.type,
    required this.multiplier,
    required this.description,
    this.conditions = const {},
  });

  bool isApplicable(List<CardModel> play, GameState state) {
    switch (type) {
      case NFTEffectType.bombDouble:
        final pattern = CardTypeDetector.analyze(play);
        return pattern?.type == CardType.bomb;
      
      case NFTEffectType.rocketTriple:
        final pattern = CardTypeDetector.analyze(play);
        return pattern?.type == CardType.rocket;
      
      case NFTEffectType.springBonus:
        // 春天条件：地主一次性出完所有牌
        final landlord = state.players[state.landlordPlayerId ?? ''];
        if (landlord == null) return false;
        return landlord.role == PlayerRole.landlord && 
               play.length == landlord.handCards.length;
      
      case NFTEffectType.antiSpringBonus:
        // 反春天条件：农民一次性出完所有牌
        final currentPlayer = state.getCurrentPlayer();
        if (currentPlayer == null) return false;
        return currentPlayer.role == PlayerRole.farmer && 
               play.length == currentPlayer.handCards.length;
      
      case NFTEffectType.cardDrawBonus:
        // 抽牌优势：在发牌阶段获得更好的牌
        return state.currentPhase == GamePhase.dealing;
      
      case NFTEffectType.scoreMultiplier:
        // 通用积分倍数：总是适用
        return true;
    }
  }

  double calculateMultiplier(List<CardModel> play, GameState state) {
    if (!isApplicable(play, state)) return 1.0;
    return multiplier;
  }
}

class NFTEffectManager {
  static final Map<String, List<NFTEffect>> _predefinedEffects = {
    'bomb_doubler': [
      NFTEffect(
        type: NFTEffectType.bombDouble,
        multiplier: 2.0,
        description: '炸弹积分翻倍',
      ),
    ],
    'rocket_master': [
      NFTEffect(
        type: NFTEffectType.rocketTriple,
        multiplier: 3.0,
        description: '火箭积分三倍',
      ),
    ],
    'spring_guardian': [
      NFTEffect(
        type: NFTEffectType.springBonus,
        multiplier: 1.5,
        description: '春天额外奖励50%',
      ),
    ],
    'anti_spring_guardian': [
      NFTEffect(
        type: NFTEffectType.antiSpringBonus,
        multiplier: 1.5,
        description: '反春天额外奖励50%',
      ),
    ],
    'lucky_drawer': [
      NFTEffect(
        type: NFTEffectType.cardDrawBonus,
        multiplier: 1.0,
        description: '发牌优势',
      ),
    ],
    'score_amplifier': [
      NFTEffect(
        type: NFTEffectType.scoreMultiplier,
        multiplier: 1.2,
        description: '通用积分提升20%',
      ),
    ],
  };

  static List<NFTEffect> getEffectsForNFT(NFTCard nft) {
    final effectType = nft.metadata['effect_type'] as String?;
    if (effectType == null) return [];
    
    return _predefinedEffects[effectType] ?? [];
  }

  static double calculateTotalMultiplier(
    List<CardModel> play, 
    GameState state, 
    String playerId
  ) {
    final player = state.players[playerId];
    if (player?.activeNFTs.isEmpty ?? true) return 1.0;

    double totalMultiplier = 1.0;
    
    for (final nft in player!.activeNFTs) {
      final effects = getEffectsForNFT(nft);
      for (final effect in effects) {
        totalMultiplier *= effect.calculateMultiplier(play, state);
      }
    }
    
    return totalMultiplier;
  }

  static List<String> getActiveEffectDescriptions(
    List<CardModel> play, 
    GameState state, 
    String playerId
  ) {
    final player = state.players[playerId];
    if (player?.activeNFTs.isEmpty ?? true) return [];

    final descriptions = <String>[];
    
    for (final nft in player!.activeNFTs) {
      final effects = getEffectsForNFT(nft);
      for (final effect in effects) {
        if (effect.isApplicable(play, state)) {
          descriptions.add(effect.description);
        }
      }
    }
    
    return descriptions;
  }

  static NFTCard createBombDoublerNFT({
    required String tokenId,
    required String contractAddress,
    required String ownerAddress,
  }) {
    return NFTCard(
      tokenId: tokenId,
      contractAddress: contractAddress,
      ownerAddress: ownerAddress,
      metadata: {
        'effect_type': 'bomb_doubler',
        'name': '炸弹大师',
        'description': '当你打出炸弹时，积分翻倍',
        'image': 'assets/nft/bomb_doubler.png',
      },
      mintedAt: DateTime.now(),
    );
  }

  static NFTCard createRocketMasterNFT({
    required String tokenId,
    required String contractAddress,
    required String ownerAddress,
  }) {
    return NFTCard(
      tokenId: tokenId,
      contractAddress: contractAddress,
      ownerAddress: ownerAddress,
      metadata: {
        'effect_type': 'rocket_master',
        'name': '火箭之王',
        'description': '当你打出火箭时，积分三倍',
        'image': 'assets/nft/rocket_master.png',
      },
      mintedAt: DateTime.now(),
    );
  }

  static NFTCard createSpringGuardianNFT({
    required String tokenId,
    required String contractAddress,
    required String ownerAddress,
  }) {
    return NFTCard(
      tokenId: tokenId,
      contractAddress: contractAddress,
      ownerAddress: ownerAddress,
      metadata: {
        'effect_type': 'spring_guardian',
        'name': '春天守护者',
        'description': '春天胜利时额外获得50%积分',
        'image': 'assets/nft/spring_guardian.png',
      },
      mintedAt: DateTime.now(),
    );
  }
}
