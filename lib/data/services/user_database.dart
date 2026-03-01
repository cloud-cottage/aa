import 'dart:math';
import 'package:aa_doudizhu/data/models/user.dart';
import 'package:aa_doudizhu/data/models/nft_card.dart';

class UserDatabase {
  static final UserDatabase _instance = UserDatabase._internal();
  factory UserDatabase() => _instance;
  UserDatabase._internal();

  final List<User> _users = [];
  final Random _random = Random();

  void initialize() {
    if (_users.isNotEmpty) return;
    
    _users.addAll(_generateUsers());
  }

  List<User> _generateUsers() {
    final users = <User>[];
    
    // 80个用户的用户名和昵称映射
    final userData = [
      {'username': 'happyboy1969', 'nickname': '轻舞飞扬'},
      {'username': 'tigerwood1972', 'nickname': '往事如烟'},
      {'username': 'lonelyman1975', 'nickname': '寂寞成瘾'},
      {'username': 'roseheart1978', 'nickname': '玫瑰人生'},
      {'username': 'bluedream1980', 'nickname': '笑忘书'},
      {'username': 'princecharming', 'nickname': '忧郁王子'},
      {'username': 'angelwings77', 'nickname': '折翼天使'},
      {'username': 'crystalprincess', 'nickname': '水晶公主'},
      {'username': 'sunnysky1976', 'nickname': '阳光男孩'},
      {'username': 'autumnrain', 'nickname': '八月未央'},
      {'username': 'moonriver', 'nickname': '人生若只如初见'},
      {'username': 'starsky', 'nickname': '海是冰封的心'},
      {'username': 'bigfish1973', 'nickname': '海带'},
      {'username': 'swordman', 'nickname': '谢青山催白发'},
      {'username': 'hero1982', 'nickname': '不谓侠'},
      {'username': 'kirito2009', 'nickname': '桐人'},
      {'username': 'nightwish', 'nickname': '夜的第七章'},
      {'username': 'jaychou', 'nickname': '发如雪'},
      {'username': 'jjlin', 'nickname': '小酒窝'},
      {'username': 'huayao', 'nickname': '花田错'},
      {'username': 'zhuangzhou', 'nickname': '莊生曉夢'},
      {'username': 'libai1985', 'nickname': '淡朱唇'},
      {'username': 'tangyin', 'nickname': '风雪添作酒'},
      {'username': 'wangwei', 'nickname': '秋风画冷屏'},
      {'username': 'fishbird', 'nickname': '鱼书雁信'},
      {'username': 'mooncatcher', 'nickname': '月亮是被我弄弯的'},
      {'username': 'peipeizhu', 'nickname': '野猪佩奇'},
      {'username': 'kindergarten', 'nickname': '幼稚园扛把子'},
      {'username': 'piggyride', 'nickname': '骑猪去兜风'},
      {'username': 'diamondhands', 'nickname': '有钳任性'},
      {'username': 'deerdream', 'nickname': '鹿尾鱼酿旧事酒'},
      {'username': 'dreamcollector', 'nickname': '夢境收藏家'},
      {'username': 'muxi1988', 'nickname': '沐西'},
      {'username': 'hongshenlvqian', 'nickname': '红深绿浅'},
      {'username': 'pokemon', 'nickname': '皮卡丘'},
      {'username': 'conan', 'nickname': '工藤新一'},
      {'username': 'roronoa', 'nickname': '索隆'},
      {'username': 'nami1989', 'nickname': '娜美'},
      {'username': 'wotemma', 'nickname': '我特麼'},
      {'username': 'niubility', 'nickname': '牛bility'},
      {'username': 'xiaohuihui', 'nickname': '灰太狼'},
      {'username': 'xiyangyang', 'nickname': '喜羊羊'},
      {'username': 'meiyangyang', 'nickname': '美羊羊'},
      {'username': 'lanyangyang', 'nickname': '懒羊羊'},
      {'username': 'canzui', 'nickname': '殘蒛哋羙婯'},
      {'username': 'yirandute', 'nickname': '畩嘫毐特'},
      {'username': 'huoxutiantian', 'nickname': '戓'戓汻、冭兲浈'},
      {'username': 'aijiejie', 'nickname': '愛妳壹萬年'},
      {'username': 'xinsui', 'nickname': '鈊瀡伱愛'},
      {'username': 'xiaogongzhu', 'nickname': '尛芞厷註'},
      {'username': 'spaceman', 'nickname': '宇宙飛行士'},
      {'username': 'dandelion', 'nickname': '莴苣亚族毛毛球'},
      {'username': 'pineapple', 'nickname': '立交桥菠萝战士'},
      {'username': 'iebrowser', 'nickname': 'ic浏览器'},
      {'username': 'neijuan', 'nickname': 'ic浏览器（内卷版）'},
      {'username': 'bailanban', 'nickname': 'ic浏览器（摆烂版）'},
      {'username': 'doushabao', 'nickname': '逗沙包'},
      {'username': 'babu', 'nickname': '八不戒'},
      {'username': 'panghu', 'nickname': '胖虎'},
      {'username': 'daxiong', 'nickname': '大雄'},
      {'username': 'doraemon', 'nickname': '哆啦A梦'},
      {'username': 'yitiaoyu', 'nickname': '一条咸鱼'},
      {'username': 'tangyuan', 'nickname': '汤圆'},
      {'username': 'mantou', 'nickname': '馒头'},
      {'username': 'jiaozi', 'nickname': '饺子'},
      {'username': 'hunshui', 'nickname': '浑水摸鱼'},
      {'username': 'zhuangsi', 'nickname': '装死'},
      {'username': 'kaixin', 'nickname': '开心就好'},
      {'username': 'suibian', 'nickname': '随便'},
      {'username': 'doufu', 'nickname': '豆腐'},
      {'username': 'xiaolongbao', 'nickname': '小笼包'},
      {'username': 'hotpot', 'nickname': '火锅'},
      {'username': 'malatang', 'nickname': '麻辣烫'},
      {'username': 'qingsong', 'nickname': '轻松熊'},
      {'username': 'kuma', 'nickname': '熊本熊'},
      {'username': 'hellokitty', 'nickname': 'HelloKitty'},
      {'username': 'walle', 'nickname': '瓦力'},
      {'username': 'eva', 'nickname': '伊娃'},
      {'username': 'baymax', 'nickname': '大白'},
      {'username': 'dora', 'nickname': '朵拉'},
    ];
    
    // 头像文件列表（从assets/avatars文件夹获取）
    final avatarFiles = [
      '2.jpg', '3.jpg', '4.jpg', '5.jpg', '6.jpg', '7.jpg', '8.jpg', '9.jpg',
      '11.jpg', '13.jpg', '15.jpg', '16.jpg', '18.jpg', '19.jpg', '21.jpg', '23.jpg',
      '24.jpg', '25.jpg', '26.jpg', '27.jpg', '28.jpg', '29.jpg', '30.jpg', '32.jpg',
      '34.jpg', '35.jpg', '36.jpg', '37.jpg', '38.jpg', '39.jpg', '40.jpg', '42.jpg',
      '43.jpg', '44.jpg', '45.jpg', '46.jpg', '47.jpg', '48.jpg', '49.jpg', '50.jpg',
      '51.jpg', '52.jpg', '53.jpg', '54.jpg', '55.jpg', '56.jpg', '57.jpg', '58.jpg',
      '59.jpg', '60.jpg', '61.jpg', '62.jpg', '63.jpg', '64.jpg', '65.jpg', '67.jpg',
      '68.jpg', '69.jpg', '70.jpg', '71.jpg', '72.jpg', '78.jpg', '82.jpg', '84.jpg',
      '87.jpg', '88.jpg', '90.jpg', '94.jpg', '96.jpg'
    ];
    
    // 随机打乱头像列表
    final shuffledAvatars = List<String>.from(avatarFiles)..shuffle(_random);
    
    final domains = ['qq.com', '163.com', 'gmail.com', 'outlook.com', '126.com'];
    
    for (int i = 0; i < userData.length; i++) {
      final userInfo = userData[i];
      final username = userInfo['username']!;
      final nickname = userInfo['nickname']!;
      final userId = 'user_${(i + 1).toString().padLeft(3, '0')}';
      
      // 随机生成邮箱
      final email = '$username@${domains[_random.nextInt(domains.length)]}';
      
      // 随机生成钱包地址
      final walletAddress = '0x${_generateHexString(40)}';
      
      // 随机金币余额 (100-10000)
      final goldBalance = 100 + _random.nextInt(9900);
      
      // 随机NFT数量 (0-5)
      final nftCount = _random.nextInt(6);
      final nftOwnedTokenIds = List.generate(nftCount, (index) => 'nft_${_random.nextInt(1000).toString().padLeft(4, '0')}');
      
      // 分配头像
      final avatarFile = shuffledAvatars[i];
      
      users.add(User(
        userId: userId,
        displayName: nickname,
        email: email,
        walletAddress: walletAddress,
        goldBalance: goldBalance,
        nftOwnedTokenIds: nftOwnedTokenIds,
        avatarPath: 'assets/avatars/$avatarFile',
      ));
    }
    
    return users;
  }

  String _generateHexString(int length) {
    final chars = '0123456789abcdef';
    String result = '';
    for (int i = 0; i < length; i++) {
      result += chars[_random.nextInt(chars.length)];
    }
    return result;
  }

  // 随机获取一个用户
  User getRandomUser() {
    if (_users.isEmpty) {
      initialize();
    }
    return _users[_random.nextInt(_users.length)];
  }

  // 根据ID获取用户
  User? getUserById(String userId) {
    if (_users.isEmpty) {
      initialize();
    }
    try {
      return _users.firstWhere((user) => user.userId == userId);
    } catch (e) {
      return null;
    }
  }

  // 获取所有用户
  List<User> getAllUsers() {
    if (_users.isEmpty) {
      initialize();
    }
    return List.from(_users);
  }

  // 获取指定数量的随机用户
  List<User> getRandomUsers(int count) {
    if (_users.isEmpty) {
      initialize();
    }
    
    if (count >= _users.length) {
      return List.from(_users);
    }
    
    final shuffled = List<User>.from(_users)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  // 根据金币余额排序获取用户
  List<User> getUsersByGoldBalance({bool descending = true}) {
    if (_users.isEmpty) {
      initialize();
    }
    
    final sorted = List<User>.from(_users);
    sorted.sort((a, b) => descending 
      ? b.goldBalance.compareTo(a.goldBalance)
      : a.goldBalance.compareTo(b.goldBalance)
    );
    return sorted;
  }

  // 获取拥有NFT的用户
  List<User> getUsersWithNFTs() {
    if (_users.isEmpty) {
      initialize();
    }
    
    return _users.where((user) => user.nftOwnedTokenIds.isNotEmpty).toList();
  }

  // 获取指定金币范围内的用户
  List<User> getUsersByGoldRange(int minGold, int maxGold) {
    if (_users.isEmpty) {
      initialize();
    }
    
    return _users.where((user) => 
      user.goldBalance >= minGold && user.goldBalance <= maxGold
    ).toList();
  }

  // 搜索用户（按显示名或用户名）
  List<User> searchUsers(String query) {
    if (_users.isEmpty) {
      initialize();
    }
    
    final lowerQuery = query.toLowerCase();
    return _users.where((user) => 
      user.displayName.toLowerCase().contains(lowerQuery) ||
      user.email?.toLowerCase().contains(lowerQuery) == true
    ).toList();
  }

  // 按用户名搜索
  List<User> searchByUsername(String query) {
    if (_users.isEmpty) {
      initialize();
    }
    
    final lowerQuery = query.toLowerCase();
    return _users.where((user) => 
      user.email?.toLowerCase().contains(lowerQuery) == true
    ).toList();
  }

  // 获取用户统计信息
  Map<String, dynamic> getStatistics() {
    if (_users.isEmpty) {
      initialize();
    }
    
    final totalUsers = _users.length;
    final totalGold = _users.fold<int>(0, (sum, user) => sum + user.goldBalance);
    final usersWithNFT = _users.where((user) => user.nftOwnedTokenIds.isNotEmpty).length;
    final avgGold = totalGold / totalUsers;
    
    return {
      'totalUsers': totalUsers,
      'totalGold': totalGold,
      'usersWithNFT': usersWithNFT,
      'averageGold': avgGold.round(),
      'maxGold': _users.fold<int>(0, (max, user) => math.max(max, user.goldBalance)),
      'minGold': _users.fold<int>(999999, (min, user) => math.min(min, user.goldBalance)),
    };
  }

  // 为游戏随机选择玩家身份
  User selectPlayerIdentity() {
    // 优先选择金币较多的用户，提高游戏体验
    final wealthyUsers = getUsersByGoldRange(1000, 10000);
    
    if (wealthyUsers.isNotEmpty) {
      return wealthyUsers[_random.nextInt(wealthyUsers.length)];
    }
    
    return getRandomUser();
  }

  // 为房间选择合适的玩家
  List<User> selectRoomPlayers(int playerCount, {int minGold = 500}) {
    final eligibleUsers = getUsersByGoldRange(minGold, 99999);
    
    if (eligibleUsers.length < playerCount) {
      return getRandomUsers(playerCount);
    }
    
    final shuffled = List<User>.from(eligibleUsers)..shuffle(_random);
    return shuffled.take(playerCount).toList();
  }

  // 根据用户名获取用户
  User? getUserByUsername(String username) {
    if (_users.isEmpty) {
      initialize();
    }
    try {
      return _users.firstWhere((user) => 
        user.email?.split('@').first == username
      );
    } catch (e) {
      return null;
    }
  }

  // 获取特定用户（用于演示）
  User? getUserByIndex(int index) {
    if (_users.isEmpty) {
      initialize();
    }
    if (index < 0 || index >= _users.length) {
      return null;
    }
    return _users[index];
  }
}
