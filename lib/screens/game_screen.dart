import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/citizen_generator.dart';
import '../data/save_manager.dart';

class P {
  static const wood = Color(0xFF2B1D12);
  static const woodLight = Color(0xFF3D2817);
  static const woodDark = Color(0xFF1A1109);

  static const paperWhite = Color(0xFFF0E8D8);
  static const paperBlue = Color(0xFFD8E0E8);
  static const paperGreen = Color(0xFFDDE8D8);
  static const paperYellow = Color(0xFFF0E8C8);

  static const paperLine = Color(0xFFB8B0A0);
  static const paperBorder = Color(0xFF8B7355);

  static const ink = Color(0xFF1A1A1A);
  static const inkBlue = Color(0xFF1E3A5F);
  static const inkRed = Color(0xFF8B1A1A);

  static const accept = Color(0xFF4A9B6F);
  static const reject = Color(0xFFC0392B);

  static const dim = Color(0xFF8B7355);
  static const white = Color(0xFFF0E8D8);
  static const gold = Color(0xFFD4AF37);
}

class GameScreen extends StatefulWidget {
  final bool startFromSave;
  const GameScreen({super.key, required this.startFromSave});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _score = 0;
  int _citizenId = 1;
  late Citizen _citizen;
  int _papersSeen = 0;
  bool _showResult = false;
  String _resultText = '';
  bool _resultCorrect = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.startFromSave) {
      _score = await SaveManager.getSavedScore();
      _citizenId = await SaveManager.getSavedCitizen();
    }
    _citizen = generateCitizen(_citizenId);
    setState(() {});
  }

  void _decide(bool approve) {
    HapticFeedback.mediumImpact();

    // هل القرار صح؟
    final shouldApprove = !_citizen.hasError;
    final correct = approve == shouldApprove;

    setState(() {
      _showResult = true;
      _resultCorrect = correct;
      if (correct) {
        _score++;
        _resultText = 'قرار صح! +1';
      } else {
        _score--;
        _resultText = 'قرار غلط! -1';
        if (_citizen.hasError) {
          _resultText += '\n(${_citizen.errorDescription})';
        } else {
          _resultText += '\n(مفيش مشكلة في الأوراق)';
        }
      }
    });

    // حفظ التقدم
    SaveManager.saveGame(
      score: _score,
      citizen: _citizenId,
    );

    // بعد ثانية ونص → مواطن جديد
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _showResult = false;
        _citizenId++;
        _citizen = generateCitizen(_citizenId);
      });
    });
  }

  void _exit() {
    // حفظ قبل الخروج
    SaveManager.saveGame(
      score: _score,
      citizen: _citizenId,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: P.wood,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [P.woodLight, P.wood, P.woodDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ═══ الشريط العلوي ═══
              _buildTopBar(),

              // ═══ المحتوى ═══
              Expanded(
                child: Row(
                  children: [
                    // ───── الشمال: أوراق المواطن ─────
                    Expanded(
                      flex: 3,
                      child: _buildPapersArea(),
                    ),
                    // ───── اليمين: المواطن + القرارات ─────
                    Expanded(
                      flex: 2,
                      child: _buildCitizenArea(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══ الشريط العلوي ═══
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // زر خروج
          GestureDetector(
            onTap: _exit,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: P.inkRed,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.exit_to_app, color: P.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'خروج',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: P.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          // النقاط
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: P.paperWhite,
              border: Border.all(color: P.paperBorder, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: P.inkRed,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'النقاط: $_score',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: P.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // رقم المواطن
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: P.paperBlue,
              border: Border.all(color: P.paperBorder, width: 1.5),
            ),
            child: Text(
              'المواطن: $_citizenId',
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: P.inkBlue,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Nour Eldin',
            style: TextStyle(
              color: P.dim.withOpacity(0.7),
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  // ═══ منطقة الأوراق ═══
  Widget _buildPapersArea() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 8, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: P.woodDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: P.woodLight),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _citizen.papers.map((p) => _buildPaper(p)).toList(),
        ),
      ),
    );
  }

  Widget _buildPaper(Paper paper) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: P.paperWhite,
        border: Border.all(color: P.paperBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paper.title,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: P.inkRed,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Container(height: 1, color: P.paperLine),
          const SizedBox(height: 8),
          Text(
            paper.content,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: P.ink,
              fontSize: 10,
              height: 1.6,
            ),
          ),
          if (paper.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: P.inkRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                '⚠ ${paper.note}',
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: P.inkRed,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══ منطقة المواطن + القرارات ═══
  Widget _buildCitizenArea() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: P.paperWhite,
        border: Border.all(color: P.paperBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(3, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ───── المواطن ─────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: P.inkRed, width: 2),
                ),
                child: Text(
                  _citizen.name.substring(0, 1),
                  style: const TextStyle(
                    color: P.inkRed,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _citizen.name,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: P.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${_citizen.age} سنة • ${_citizen.job}',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: P.inkBlue,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: P.paperLine),
          const SizedBox(height: 8),
          // ───── كلام المواطن ─────
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: P.paperYellow,
              border: Border.all(color: P.paperLine),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              '"${_citizen.speech}"',
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: P.inkBlue,
                fontSize: 11,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // ───── نوع الرخصة ─────
          Text(
            'المطلوب: ${_citizen.licenseType}',
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: P.ink,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // ───── النتيجة أو الأزرار ─────
          if (_showResult)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _resultCorrect
                    ? P.accept.withOpacity(0.15)
                    : P.reject.withOpacity(0.15),
                border: Border.all(
                  color: _resultCorrect ? P.accept : P.reject,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _resultText,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _resultCorrect ? P.accept : P.reject,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.5,
                ),
              ),
            )
          else
            Row(
              children: [
                // زر موافق
                Expanded(
                  child: _buildActionButton(
                    label: 'موافق',
                    icon: Icons.check,
                    color: P.accept,
                    onTap: () => _decide(true),
                  ),
                ),
                const SizedBox(width: 8),
                // زر مرفوض
                Expanded(
                  child: _buildActionButton(
                    label: 'مرفوض',
                    icon: Icons.close,
                    color: P.reject,
                    onTap: () => _decide(false),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: P.white, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: P.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}