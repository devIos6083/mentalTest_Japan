import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:mental_test/main/question_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// 🇯🇵 モダンなメインページ - 最新トレンドのUI
class MainlistPage extends StatefulWidget {
  const MainlistPage({super.key});

  @override
  State<MainlistPage> createState() => _MainlistPageState();
}

class _MainlistPageState extends State<MainlistPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Future<String> loadAssets() async {
    return await rootBundle.loadString('res/api/list.json');
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 グラデーション背景
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea), // 柔らかい青紫
              Color(0xFF764ba2), // 深い紫
              Color(0xFFf093fb), // ピンク
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<String>(
            future: loadAssets(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return _buildLoadingScreen();

                case ConnectionState.done:
                  if (snapshot.hasData) {
                    Map<String, dynamic> list = jsonDecode(snapshot.data!);
                    return _buildMainContent(list);
                  } else if (snapshot.hasError) {
                    return _buildErrorScreen(snapshot.error.toString());
                  } else {
                    return _buildNoDataScreen();
                  }

                default:
                  return _buildNoDataScreen();
              }
            },
          ),
        ),
      ),
    );
  }

  // ⏳ ローディング画面
  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'テストを準備中...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 メインコンテンツ
  Widget _buildMainContent(Map<String, dynamic> list) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          // 🎨 モダンなアプリバー
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                '心理テスト',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black12],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.psychology,
                    size: 60,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),

          // 📝 サブタイトル
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'あなたの隠れた性格を発見しよう！',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${list['count']}つのテストから選んでください',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // 🎴 テストカード一覧
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return TweenAnimationBuilder(
                  duration: Duration(milliseconds: 600 + (index * 200)),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: _buildTestCard(list, index),
                      ),
                    );
                  },
                );
              }, childCount: list['count']),
            ),
          ),

          // 🔽 下部の余白
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // 🎴 テストカードウィジェット
  Widget _buildTestCard(Map<String, dynamic> list, int index) {
    final cardColors = [
      [const Color(0xFF74b9ff), const Color(0xFFa29bfe)], // 밝은 파랑→보라
      [const Color(0xFFfd79a8), const Color(0xFFe84393)], // 밝은 핑크
      [const Color(0xFF00cec9), const Color(0xFF55a3ff)], // 밝은 청록→파랑
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 6,
        shadowColor: Colors.black12,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onTestCardTap(list, index),
          child: Container(
            height: 100, // 120에서 100으로 축소
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: cardColors[index % cardColors.length],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // 🎨 배경패턴
                Positioned(
                  right: -15,
                  top: -15,
                  child: Icon(
                    _getIconForIndex(index),
                    size: 80, // 100에서 80으로 축소
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),

                // 📄 텍스트 콘텐츠
                Padding(
                  padding: const EdgeInsets.all(16), // 20에서 16으로 축소
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        // Text 오버플로우 방지
                        child: Text(
                          list['questions'][index]['title'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16, // 18에서 16으로 축소
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                          maxLines: 2, // 최대 2줄로 제한
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4), // 8에서 4로 축소
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '所要時間: 1分',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10, // 12에서 10으로 축소
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 16, // 18에서 16으로 축소
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🎯 テストカードタップ処理
  Future<void> _onTestCardTap(Map<String, dynamic> list, int index) async {
    try {
      // 🎵 触覚フィードバック
      HapticFeedback.lightImpact();

      await FirebaseAnalytics.instance.logEvent(
        name: 'test_click',
        parameters: {'test_name': list['questions'][index]['title'].toString()},
      );

      await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return QuestionPage(
              question: list['questions'][index]['file'].toString(),
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } catch (e) {
      print('テストページ遷移エラー: $e');
    }
  }

  // 🎨 インデックスに応じたアイコン
  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.psychology;
      case 1:
        return Icons.favorite;
      case 2:
        return Icons.pets;
      default:
        return Icons.quiz;
    }
  }

  // ❌ エラー画面
  Widget _buildErrorScreen(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.white70),
          const SizedBox(height: 20),
          const Text(
            'エラーが発生しました',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            error,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 📭 データなし画面
  Widget _buildNoDataScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.white70),
          SizedBox(height: 20),
          Text(
            'データが見つかりません',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
