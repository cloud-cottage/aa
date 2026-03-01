import 'package:aa_doudizhu/data/models/room.dart';
import 'package:aa_doudizhu/data/models/user.dart';
import 'package:aa_doudizhu/domain/game_logic/game_state.dart';
import 'package:aa_doudizhu/domain/game_logic/ai.dart';
import 'package:aa_doudizhu/domain/game_logic/card.dart';
import 'dart:async';

enum RoomEvent {
  playerJoined,
  playerLeft,
  playerDisconnected,
  playerReconnected,
  aiReplacedPlayer,
  gameStarted,
  gameFinished,
  roomDestroyed,
}

class RoomEventInfo {
  final RoomEvent type;
  final String roomId;
  final String? playerId;
  final Map<String, dynamic> data;

  RoomEventInfo({
    required this.type,
    required this.roomId,
    this.playerId,
    this.data = const {},
  });
}

class RoomManager {
  static final RoomManager _instance = RoomManager._internal();
  factory RoomManager() => _instance;
  RoomManager._internal();

  final Map<String, Room> _rooms = {};
  final Map<String, GameState> _gameStates = {};
  final StreamController<RoomEventInfo> _eventController = StreamController.broadcast();
  
  // 等待超时设置（秒）
  static const int _waitTimeout = 30;
  static const int _reconnectTimeout = 60;
  
  // 定时器管理
  final Map<String, Timer> _waitTimers = {};
  final Map<String, Timer> _reconnectTimers = {};

  Stream<RoomEventInfo> get eventStream => _eventController.stream;

  // 获取游戏状态（供GameEngine使用）
  Map<String, GameState> get gameStates => _gameStates;

  // 创建房间
  Room createRoom({
    required String roomId,
    required String hostUserId,
    String? entryTokenId,
  }) {
    final room = Room(
      roomId: roomId,
      hostUserId: hostUserId,
      players: [hostUserId],
      entryTokenId: entryTokenId,
    );
    
    _rooms[roomId] = room;
    _eventController.add(RoomEventInfo(
      type: RoomEvent.playerJoined,
      roomId: roomId,
      playerId: hostUserId,
    ));
    
    return room;
  }

  // 加入房间
  bool joinRoom(String roomId, String userId) {
    final room = _rooms[roomId];
    if (room == null) return false;
    
    if (room.players.length >= 3) return false; // 房间已满
    if (room.players.contains(userId)) return false; // 已在房间中
    
    room.players.add(userId);
    room.playerConnected[userId] = true;
    
    _eventController.add(RoomEventInfo(
      type: RoomEvent.playerJoined,
      roomId: roomId,
      playerId: userId,
    ));
    
    // 如果房间满了，开始游戏或启动等待计时器
    if (room.players.length == 3) {
      _startGameOrWaitTimer(roomId);
    }
    
    return true;
  }

  // 离开房间
  bool leaveRoom(String roomId, String userId) {
    final room = _rooms[roomId];
    if (room == null) return false;
    
    if (!room.players.contains(userId)) return false;
    
    // 移除玩家
    room.players.remove(userId);
    room.playerConnected.remove(userId);
    
    // 如果是游戏进行中，用AI替换
    final gameState = _gameStates[roomId];
    if (gameState != null && gameState.currentPhase != GamePhase.waiting) {
      _replaceWithAI(roomId, userId);
    } else {
      // 等待阶段直接移除
      _eventController.add(RoomEventInfo(
        type: RoomEvent.playerLeft,
        roomId: roomId,
        playerId: userId,
      ));
      
      // 如果房间空了，销毁房间
      if (room.players.isEmpty) {
        _destroyRoom(roomId);
      }
    }
    
    return true;
  }

  // 玩家断线
  void playerDisconnected(String roomId, String userId) {
    final room = _rooms[roomId];
    if (room == null) return;
    
    room.setPlayerDisconnected(userId);
    
    _eventController.add(RoomEventInfo(
      type: RoomEvent.playerDisconnected,
      roomId: roomId,
      playerId: userId,
    ));
    
    // 启动重连计时器
    _startReconnectTimer(roomId, userId);
  }

  // 玩家重连
  void playerReconnected(String roomId, String userId) {
    final room = _rooms[roomId];
    if (room == null) return;
    
    room.playerConnected[userId] = true;
    
    // 取消重连计时器
    _cancelReconnectTimer(roomId, userId);
    
    _eventController.add(RoomEventInfo(
      type: RoomEvent.playerReconnected,
      roomId: roomId,
      playerId: userId,
    ));
  }

  // 开始游戏
  void startGame(String roomId) {
    final room = _rooms[roomId];
    if (room == null) return;
    
    room.state = 'playing';
    
    // 创建游戏状态
    final gameState = _createInitialGameState(room);
    _gameStates[roomId] = gameState;
    
    // 取消所有计时器
    _cancelWaitTimer(roomId);
    _cancelAllReconnectTimers(roomId);
    
    _eventController.add(RoomEventInfo(
      type: RoomEvent.gameStarted,
      roomId: roomId,
    ));
  }

  // 结束游戏
  void finishGame(String roomId) {
    final room = _rooms[roomId];
    if (room == null) return;
    
    room.state = 'finished';
    
    _eventController.add(RoomEventInfo(
      type: RoomEvent.gameFinished,
      roomId: roomId,
    ));
  }

  // 获取房间
  Room? getRoom(String roomId) {
    return _rooms[roomId];
  }

  // 获取游戏状态
  GameState? getGameState(String roomId) {
    return _gameStates[roomId];
  }

  // 获取所有活跃房间
  List<Room> getActiveRooms() {
    return _rooms.values.where((room) => room.state != 'finished').toList();
  }

  // 私有方法：开始游戏或等待计时器
  void _startGameOrWaitTimer(String roomId) {
    final room = _rooms[roomId];
    if (room == null) return;
    
    // 检查是否所有玩家都已连接
    final allConnected = room.players.every((playerId) => room.isPlayerConnected(playerId));
    
    if (allConnected) {
      startGame(roomId);
    } else {
      // 启动等待计时器
      _startWaitTimer(roomId);
    }
  }

  // 启动等待计时器
  void _startWaitTimer(String roomId) {
    _cancelWaitTimer(roomId); // 取消之前的计时器
    
    _waitTimers[roomId] = Timer(Duration(seconds: _waitTimeout), () {
      final room = _rooms[roomId];
      if (room != null && room.state == 'waiting') {
        // 用AI填充未连接的玩家
        _fillMissingPlayersWithAI(roomId);
        startGame(roomId);
      }
    });
  }

  // 取消等待计时器
  void _cancelWaitTimer(String roomId) {
    final timer = _waitTimers.remove(roomId);
    timer?.cancel();
  }

  // 启动重连计时器
  void _startReconnectTimer(String roomId, String userId) {
    final key = '${roomId}_$userId';
    _cancelReconnectTimer(roomId, userId); // 取消之前的计时器
    
    _reconnectTimers[key] = Timer(Duration(seconds: _reconnectTimeout), () {
      final room = _rooms[roomId];
      if (room != null) {
        // 超时未重连，用AI替换
        _replaceWithAI(roomId, userId);
      }
    });
  }

  // 取消重连计时器
  void _cancelReconnectTimer(String roomId, String userId) {
    final key = '${roomId}_$userId';
    final timer = _reconnectTimers.remove(key);
    timer?.cancel();
  }

  // 取消所有重连计时器
  void _cancelAllReconnectTimers(String roomId) {
    final keysToRemove = <String>[];
    for (final key in _reconnectTimers.keys) {
      if (key.startsWith('${roomId}_')) {
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      final timer = _reconnectTimers.remove(key);
      timer?.cancel();
    }
  }

  // 用AI填充缺失的玩家
  void _fillMissingPlayersWithAI(String roomId) {
    final room = _rooms[roomId];
    if (room == null) return;
    
    for (int i = 0; i < room.players.length; i++) {
      final playerId = room.players[i];
      if (!room.isPlayerConnected(playerId)) {
        final aiPlayerId = AIManager.generateAIPlayerId(playerId);
        room.players[i] = aiPlayerId;
        room.playerConnected[aiPlayerId] = true;
        room.playerConnected.remove(playerId);
        
        _eventController.add(RoomEventInfo(
          type: RoomEvent.aiReplacedPlayer,
          roomId: roomId,
          playerId: playerId,
          data: {'aiPlayerId': aiPlayerId},
        ));
      }
    }
  }

  // 用AI替换玩家
  void _replaceWithAI(String roomId, String userId) {
    final room = _rooms[roomId];
    if (room == null) return;
    
    room.replaceWithBot(userId);
    
    _eventController.add(RoomEventInfo(
      type: RoomEvent.aiReplacedPlayer,
      roomId: roomId,
      playerId: userId,
    ));
    
    // 更新游戏状态
    final gameState = _gameStates[roomId];
    if (gameState != null) {
      final aiPlayerId = AIManager.generateAIPlayerId(userId);
      final playerState = gameState.players[userId];
      if (playerState != null) {
        final aiPlayerState = playerState.copyWith(
          userId: aiPlayerId,
          isAI: true,
          isConnected: true,
          user: null,
        );
        
        final updatedPlayers = Map<String, PlayerState>.from(gameState.players);
        updatedPlayers.remove(userId);
        updatedPlayers[aiPlayerId] = aiPlayerState;
        
        _gameStates[roomId] = gameState.copyWith(players: updatedPlayers);
        
        // 如果当前轮到该玩家，更新当前玩家ID
        if (gameState.currentTurnPlayerId == userId) {
          _gameStates[roomId] = _gameStates[roomId]!.copyWith(
            currentTurnPlayerId: aiPlayerId,
          );
        }
      }
    }
  }

  // 创建初始游戏状态
  GameState _createInitialGameState(Room room) {
    final players = <String, PlayerState>{};
    
    for (final playerId in room.players) {
      players[playerId] = PlayerState(
        userId: playerId,
        handCards: [],
        isAI: AIManager.isAIPlayer(playerId),
        isConnected: room.isPlayerConnected(playerId),
      );
    }
    
    return GameState(
      roomId: room.roomId,
      players: players,
      currentTurnPlayerId: room.players.first,
      currentPhase: GamePhase.waiting,
    );
  }

  // 销毁房间
  void _destroyRoom(String roomId) {
    _cancelWaitTimer(roomId);
    _cancelAllReconnectTimers(roomId);
    
    _rooms.remove(roomId);
    _gameStates.remove(roomId);
    
    _eventController.add(RoomEventInfo(
      type: RoomEvent.roomDestroyed,
      roomId: roomId,
    ));
  }

  // 清理资源
  void dispose() {
    for (final timer in _waitTimers.values) {
      timer.cancel();
    }
    for (final timer in _reconnectTimers.values) {
      timer.cancel();
    }
    
    _waitTimers.clear();
    _reconnectTimers.clear();
    _rooms.clear();
    _gameStates.clear();
    
    _eventController.close();
  }
}
