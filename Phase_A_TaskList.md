Phase A – 实现骨架任务清单 (不可执行代码的落地草案)

- 目标
  - 搭建 Flutter 跨端项目的基础架构，建立数据模型与规则引擎接口，完成最小 UI 框架与本地存储骨架。

- 产出物
  - 项目骨架、核心数据模型、规则引擎接口、单机 UI 框架、可测试的草案单元测试。 

- 关键文件与目录（已创建）
  - pubspec.yaml、lib/main.dart、lib/core/theme.dart、lib/core/constants.dart
  - lib/domain/game_logic/card.dart、rule_checker.dart、game_state.dart、ai.dart
  - lib/data/models/user.dart、room.dart、nft_card.dart
  - lib/presentation/screens/home_screen.dart、room_screen.dart
  - lib/data/services/firebase_service.dart、lib/data/repositories/repository.dart

- 任务分解（按排序优先级）
  1. 项目架构与依赖
     - 确认 Flutter 版本、Dart 版本、Riverpod、Hive 的版本边界
     - 设定初步代码结构：lib/core, lib/domain, lib/data, lib/presentation, lib/router
  2. 数据模型草案
     - Card/牌型、User、Room、NFTCard 的字段及序列化/反序列化接口
     - 本地存储盒模型的初始定义
  3. 斗地主规则引擎接口
     - 定义 CardModel、RuleChecker、GameState 的最小字段与接口
     - 暴露 isLegalPlay、canBeat、calculateScore 等方法的签名
  4. 单机 AI 框架雏形
     - AIEngine 的接口，简单随机策略占位
  5. UI 框架与导航
     - 启动页、主菜单、房间入口、简易牌桌占位 UI
  6. 本地存储骨架
     - Hive 的 Box 名称定义、简单的键值对缓存接口
  7. 测试计划与文档
     - Phase A 测试覆盖点、单元测试示例、接口测试思路

- 时间与风险
  - 预估总耗时 8–14 天，视团队产出速率
  - 风险点：UI/风格落地、跨端一致性、未来 NFT 与区块链接入的复杂度

- 下一步（确认后执行）
  - 如果你同意当前骨架，进入 Phase A 的第一轮具体待办任务分解与分配。
