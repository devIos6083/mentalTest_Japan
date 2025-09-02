import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mental_test/detail/detail_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class QuestionPage extends StatefulWidget {
  final String question;
  const QuestionPage({super.key, required this.question});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage>
    with TickerProviderStateMixin {
  String title = "";
  int selectNumber = -1;
  late AnimationController _progressController;
  late AnimationController _cardController;
  late Animation<double> _progressAnimation;

  Future<String> loadAsset(String fileName) async {
    return await rootBundle.loadString('res/api/$fileName.json');
  }

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _progressController.forward();
    _cardController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF74b9ff), // 밝은 파랑
              Color(0xFFa8e6cf), // 연한 민트그린
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<String>(
            future: loadAsset(widget.question),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return _buildLoadingScreen();
              } else if (snapshot.hasError) {
                return _buildErrorScreen(snapshot.error.toString());
              }

              Map<String, dynamic> questions = json.decode(snapshot.data!);
              title = questions['title']?.toString() ?? "テスト";

              return _buildQuestionContent(questions);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '質問を準備中...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(Map<String, dynamic> questions) {
    List<dynamic> selects = questions['selects'] ?? [];
    String questionText = questions['question']?.toString() ?? "";

    return Column(
      children: [
        // 🔝 ヘッダー部分
        _buildHeader(),

        // 📝 質問セクション
        _buildQuestionSection(questionText),

        // 🎯 選択肢セクション
        Expanded(child: _buildOptionsSection(selects)),

        // ⬇️ ボタンセクション
        _buildBottomButton(questions),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 🔙 戻るボタン
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(22),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          const SizedBox(width: 16),

          // 📊 プログレスバー
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 📄 質問番号
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '1/1',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(String questionText) {
    return SlideTransition(
      position: _cardController.drive(
        Tween(
          begin: const Offset(0, -0.5),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // 🎯 アイコン
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(height: 20),

            // 📖 タイトル
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // 🔍 質問文
            Text(
              questionText,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF4A5568),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection(List<dynamic> selects) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: selects.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: _buildOptionCard(selects, index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOptionCard(List<dynamic> selects, int index) {
    bool isSelected = selectNumber == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              selectNumber = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF667eea)
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0xFF667eea).withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 4),
                  blurRadius: isSelected ? 15 : 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // 🔘 ラジオボタン
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF667eea)
                          : const Color(0xFFCBD5E0),
                      width: 2,
                    ),
                    color: isSelected
                        ? const Color(0xFF667eea)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),

                const SizedBox(width: 16),

                // 📝 選択肢テキスト
                Expanded(
                  child: Text(
                    selects[index].toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF2D3748)
                          : const Color(0xFF4A5568),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(Map<String, dynamic> questions) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 💡 ヒントテキスト
          if (selectNumber == -1)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '答えを選択してください',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // 🔄 結果ボタン
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: selectNumber >= 0
                  ? () => _handleResult(questions)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectNumber >= 0
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                foregroundColor: selectNumber >= 0
                    ? const Color(0xFF667eea)
                    : Colors.white,
                elevation: selectNumber >= 0 ? 8 : 0,
                shadowColor: const Color(0xFF667eea).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '結果を見る',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selectNumber >= 0
                          ? const Color(0xFF667eea)
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: selectNumber >= 0
                        ? const Color(0xFF667eea)
                        : Colors.white.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResult(Map<String, dynamic> questions) async {
    try {
      // 🎵 触覚フィードバック
      HapticFeedback.mediumImpact();

      await FirebaseAnalytics.instance.logEvent(
        name: 'personal_select',
        parameters: {'test_name': title, 'select': selectNumber},
      );

      // 🔒 安全なデータ処理
      String questionText = title;
      String answerText = "結果を処理中...";

      if (questions.containsKey('answer') &&
          questions['answer'] != null &&
          questions['answer'] is List &&
          selectNumber < (questions['answer'] as List).length) {
        answerText = questions['answer'][selectNumber].toString();
      } else {
        answerText = "選択された回答: ${questions['selects'][selectNumber]}";
      }

      await Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return DetailPage(question: questionText, answer: answerText);
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation.drive(
                  Tween(
                    begin: 0.8,
                    end: 1.0,
                  ).chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      print('結果処理エラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('結果の処理中にエラーが発生しました'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

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
}
