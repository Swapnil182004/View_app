import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── DESIGN TOKENS ──────────────────────────────────────────────────────────
class _Clr {
  static const primary    = Color(0xFF1A56DB); // Brand Blue
  static const dark       = Color(0xFF1E40AF); // Deep Blue
  static const ink        = Color(0xFF1A1A1A);
  static const inkMid     = Color(0xFF374151);
  static const inkLight   = Color(0xFF6B7280);
  static const warn1      = Color(0xFFF59E0B);
  static const warn2      = Color(0xFFEF4444);
  static const warn3      = Color(0xFF7F1D1D);
  static const disqualBg  = Color(0xFF1A0000);
}

class AntiCheatSession {
  final String attemptId;
  final String quizId;
  final String userId;
  int warningCount;
  bool isDisqualified;
  final List<Map<String, dynamic>> violations;
  final DateTime startTime;

  AntiCheatSession({
    required this.attemptId,
    required this.quizId,
    required this.userId,
    this.warningCount = 0,
    this.isDisqualified = false,
    List<Map<String, dynamic>>? violations,
    DateTime? startTime,
  })  : violations = violations ?? [],
        startTime = startTime ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'attemptId': attemptId,
    'quizId': quizId,
    'userId': userId,
    'warningCount': warningCount,
    'isDisqualified': isDisqualified,
    'violations': violations,
    'startTime': startTime.toIso8601String(),
    'lastUpdated': DateTime.now().toIso8601String(),
  };
}

class AntiCheatService {
  static const int maxWarnings = 3;

  static Future<int> recordViolation({required AntiCheatSession session, required String violationType}) async {
    session.warningCount++;
    final violation = {
      'type': violationType,
      'warningNumber': session.warningCount,
      'timestamp': DateTime.now().toIso8601String(),
    };
    session.violations.add(violation);

    if (session.warningCount >= maxWarnings) session.isDisqualified = true;

    try {
      await FirebaseFirestore.instance.collection('quiz_attempts').doc(session.attemptId).set(session.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[AntiCheat] Firestore write error: $e');
    }
    return session.warningCount;
  }

  static Future<void> disqualify({required AntiCheatSession session}) async {
    session.isDisqualified = true;
    try {
      await FirebaseFirestore.instance.collection('quiz_attempts').doc(session.attemptId).set({
        ...session.toMap(),
        'result': 'DISQUALIFIED',
        'disqualifiedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('users').doc(session.userId).collection('disqualifications').add({
        'quizId': session.quizId,
        'attemptId': session.attemptId,
        'reason': 'Exceeded $maxWarnings app-switch warnings',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[AntiCheat] Disqualify write error: $e');
    }
  }
}

class AntiCheatQuizWrapper extends StatefulWidget {
  final Widget child;
  final String quizId;
  final String quizTitle;
  final VoidCallback? onDisqualified;

  const AntiCheatQuizWrapper({Key? key, required this.child, required this.quizId, required this.quizTitle, this.onDisqualified}) : super(key: key);

  @override
  State<AntiCheatQuizWrapper> createState() => _AntiCheatQuizWrapperState();
}

class _AntiCheatQuizWrapperState extends State<AntiCheatQuizWrapper> with WidgetsBindingObserver {
  late AntiCheatSession _session;
  bool _isExamActive = true;
  bool _showingWarning = false;
  DateTime? _pausedAt;
  static const int _minViolationMs = 800;

  @override
  void initState() {
    super.initState();
    _initSession();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  void _initSession() {
    final user = FirebaseAuth.instance.currentUser;
    _session = AntiCheatSession(
      attemptId: '${user?.uid ?? 'anon'}_${widget.quizId}_${DateTime.now().millisecondsSinceEpoch}',
      quizId: widget.quizId,
      userId: user?.uid ?? 'anonymous',
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isExamActive || _showingWarning) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      _pausedAt = DateTime.now();
    }
    if (state == AppLifecycleState.resumed && _pausedAt != null) {
      final awayMs = DateTime.now().difference(_pausedAt!).inMilliseconds;
      _pausedAt = null;
      if (awayMs >= _minViolationMs) _handleViolation('APP_SWITCHED');
    }
  }

  Future<void> _handleViolation(String type) async {
    if (!_isExamActive || _showingWarning) return;
    setState(() => _showingWarning = true);

    final warningNumber = await AntiCheatService.recordViolation(session: _session, violationType: type);

    if (!mounted) return;

    if (warningNumber >= AntiCheatService.maxWarnings) {
      await AntiCheatService.disqualify(session: _session);
      setState(() { _isExamActive = false; _showingWarning = false; });
      if (mounted) _showDisqualificationOverlay();
    } else {
      await _showWarningDialog(warningNumber);
      if (mounted) setState(() => _showingWarning = false);
    }
  }

  Future<void> _showWarningDialog(int warningNumber) async {
    final remaining = AntiCheatService.maxWarnings - warningNumber;
    final Color warnColor = warningNumber == 1 ? _Clr.warn1 : warningNumber == 2 ? _Clr.warn2 : _Clr.warn3;

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (ctx) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _WarningDialog(warningNumber: warningNumber, remaining: remaining, warnColor: warnColor, quizTitle: widget.quizTitle, onContinue: () => Navigator.pop(ctx)),
          ),
        ),
      ),
    );
  }

  void _showDisqualificationOverlay() {
    widget.onDisqualified?.call();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => _DisqualificationScreen(quizTitle: widget.quizTitle, session: _session),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isExamActive) {
          _showExitAttemptDialog();
          return false;
        }
        return true;
      },
      // ✅ FIX: Changed from Stack to Column. It now pushes the AppBar down neatly!
      child: Column(
        children: [
          if (_isExamActive)
            Container(
              color: _session.warningCount > 0 ? (_session.warningCount >= 2 ? _Clr.warn2 : _Clr.warn1) : _Clr.dark,
              width: double.infinity,
              child: SafeArea(
                bottom: false,
                child: _AntiCheatStatusBar(
                  warningCount: _session.warningCount,
                  maxWarnings: AntiCheatService.maxWarnings,
                ),
              ),
            ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  void _showExitAttemptDialog() {
    showDialog(context: context, builder: (ctx) => _ExitConfirmDialog(onExit: () { Navigator.pop(ctx); Navigator.pop(context); }, onStay: () => Navigator.pop(ctx)));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SEAMLESS TOP BANNER STATUS BAR
// ─────────────────────────────────────────────────────────────────────────────
class _AntiCheatStatusBar extends StatefulWidget {
  final int warningCount;
  final int maxWarnings;
  const _AntiCheatStatusBar({required this.warningCount, required this.maxWarnings});

  @override
  State<_AntiCheatStatusBar> createState() => _AntiCheatStatusBarState();
}

class _AntiCheatStatusBarState extends State<_AntiCheatStatusBar> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _pulse = Tween(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.15), width: 1)),
      ),
      child: Row(children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Opacity(opacity: _pulse.value, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle))),
        ),
        const SizedBox(width: 8),
        const Text('EXAM IN PROGRESS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
        const Spacer(),
        Row(
          children: List.generate(widget.maxWarnings, (i) {
            final filled = i < widget.warningCount;
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Container(
                width: 14, height: 14,
                decoration: BoxDecoration(
                  color: filled ? Colors.white : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                ),
                child: filled ? const Icon(Icons.close, size: 10, color: Color(0xFFEF4444)) : null,
              ),
            );
          }),
        ),
        const SizedBox(width: 8),
        Text('${widget.warningCount}/${widget.maxWarnings}', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  WARNING DIALOG & DISQUALIFICATION SCREENS (Unchanged below here)
// ─────────────────────────────────────────────────────────────────────────────
class _WarningDialog extends StatefulWidget {
  final int warningNumber;
  final int remaining;
  final Color warnColor;
  final String quizTitle;
  final VoidCallback onContinue;
  const _WarningDialog({required this.warningNumber, required this.remaining, required this.warnColor, required this.quizTitle, required this.onContinue});

  @override
  State<_WarningDialog> createState() => _WarningDialogState();
}

class _WarningDialogState extends State<_WarningDialog> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _shake;
  int _countdown = 5;
  Timer? _timer;
  bool _canDismiss = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _shake = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.4)));
    _ctrl.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _countdown--;
        if (_countdown <= 0) { _canDismiss = true; t.cancel(); }
      });
    });
  }

  @override
  void dispose() { _ctrl.dispose(); _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.translate(offset: Offset(_shake.value, 0), child: ScaleTransition(scale: _scale, child: child)),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: widget.warnColor.withOpacity(0.35), blurRadius: 40, offset: const Offset(0, 12))]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 8, decoration: BoxDecoration(color: widget.warnColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(28)))),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  children: [
                    _WarningIcon(color: widget.warnColor, number: widget.warningNumber),
                    const SizedBox(height: 22),
                    Text(widget.warningNumber == 1 ? 'First Warning!' : 'Warning ${widget.warningNumber} of ${AntiCheatService.maxWarnings}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: widget.warnColor, letterSpacing: -0.3)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: widget.warnColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: widget.warnColor.withOpacity(0.3))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.quiz_rounded, size: 12, color: widget.warnColor), const SizedBox(width: 6), Text(widget.quizTitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: widget.warnColor))]),
                    ),
                    const SizedBox(height: 18),
                    const Text('You left the exam screen. This is a violation of exam integrity rules.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: _Clr.inkMid, height: 1.5)),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: widget.remaining == 1 ? const Color(0xFFFFEEEE) : const Color(0xFFFFF8E6), borderRadius: BorderRadius.circular(14), border: Border.all(color: widget.remaining == 1 ? const Color(0xFFEF4444).withOpacity(0.4) : _Clr.warn1.withOpacity(0.4))),
                      child: Row(children: [
                        Icon(widget.remaining == 1 ? Icons.dangerous_rounded : Icons.info_rounded, size: 20, color: widget.remaining == 1 ? const Color(0xFFEF4444) : _Clr.warn1),
                        const SizedBox(width: 10),
                        Expanded(child: Text(widget.remaining == 1 ? '⚠️ FINAL WARNING! One more violation and you will be DISQUALIFIED from this exam.' : 'You have ${widget.remaining} warning${widget.remaining == 1 ? '' : 's'} remaining before disqualification.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: widget.remaining == 1 ? const Color(0xFFEF4444) : _Clr.inkMid, height: 1.4))),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _canDismiss
                            ? FilledButton.icon(key: const ValueKey('ready'), onPressed: widget.onContinue, icon: const Icon(Icons.arrow_forward_rounded, size: 18), label: const Text('I understand — Resume Exam', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)), style: FilledButton.styleFrom(backgroundColor: widget.warnColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))
                            : FilledButton(key: const ValueKey('waiting'), onPressed: null, style: FilledButton.styleFrom(disabledBackgroundColor: widget.warnColor.withOpacity(0.25), disabledForegroundColor: widget.warnColor.withOpacity(0.7), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: widget.warnColor.withOpacity(0.7))), const SizedBox(width: 10), Text('Please read carefully... ($_countdown)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: widget.warnColor.withOpacity(0.8)))])),
                      ),
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
}

class _WarningIcon extends StatefulWidget {
  final Color color;
  final int number;
  const _WarningIcon({required this.color, required this.number});
  @override
  State<_WarningIcon> createState() => _WarningIconState();
}

class _WarningIconState extends State<_WarningIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _ringScale = Tween(begin: 0.8, end: 1.6).animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));
    _ringOpacity = Tween(begin: 0.6, end: 0.0).animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ringCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90, height: 90,
      child: Stack(alignment: Alignment.center, children: [
        AnimatedBuilder(
          animation: _ringCtrl,
          builder: (_, __) => Transform.scale(scale: _ringScale.value, child: Opacity(opacity: _ringOpacity.value, child: Container(width: 70, height: 70, decoration: BoxDecoration(color: widget.color.withOpacity(0.3), shape: BoxShape.circle)))),
        ),
        Container(width: 70, height: 70, decoration: BoxDecoration(gradient: RadialGradient(colors: [widget.color.withOpacity(0.2), widget.color.withOpacity(0.08)]), shape: BoxShape.circle, border: Border.all(color: widget.color.withOpacity(0.4), width: 2)), child: Icon(Icons.warning_amber_rounded, size: 38, color: widget.color)),
        Positioned(top: 4, right: 4, child: Container(width: 24, height: 24, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: Center(child: Text('${widget.number}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900))))),
      ]),
    );
  }
}

class _DisqualificationScreen extends StatefulWidget {
  final String quizTitle;
  final AntiCheatSession session;
  const _DisqualificationScreen({required this.quizTitle, required this.session});

  @override
  State<_DisqualificationScreen> createState() => _DisqualificationScreenState();
}

class _DisqualificationScreenState extends State<_DisqualificationScreen> with TickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late AnimationController _shakeCtrl;
  late Animation<double> _iconScale;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _mainCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _iconScale = CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut));
    _contentFade = CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeIn));
    _contentSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic)));
    _mainCtrl.forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() { _mainCtrl.dispose(); _shakeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: _Clr.disqualBg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                ScaleTransition(scale: _iconScale, child: _DisqualIcon()),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _contentFade,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: Column(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4))), child: const Text('DISQUALIFIED', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2.0))),
                      const SizedBox(height: 18),
                      const Text('Exam Terminated', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      const SizedBox(height: 12),
                      Text('You have been disqualified from\n"${widget.quizTitle}"', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 14, height: 1.5)),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF2A0000), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.25))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(children: [Icon(Icons.gavel_rounded, color: Color(0xFFEF4444), size: 18), SizedBox(width: 8), Text('Violation Record', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800))]),
                            const SizedBox(height: 14),
                            ...widget.session.violations.asMap().entries.map((e) {
                              final v = e.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: 22, height: 22, decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: Center(child: Text('${e.key + 1}', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.w900)))),
                                    const SizedBox(width: 10),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_violationLabel(v['type'] ?? ''), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)), Text(_formatTimestamp(v['timestamp'] ?? ''), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10))])),
                                  ],
                                ),
                              );
                            }),
                            const Divider(color: Color(0x33EF4444), height: 20),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Attempt ID', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)), Text(widget.session.attemptId.length > 22 ? '...${widget.session.attemptId.substring(widget.session.attemptId.length - 18)}' : widget.session.attemptId, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontFamily: 'monospace'))]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.08))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Why was I disqualified?', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text('Leaving the exam screen during an active test is considered a breach of exam integrity. After ${AntiCheatService.maxWarnings} violations, the system automatically disqualifies the attempt.', style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12, height: 1.6)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity, height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/quiz');
                          },
                          icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white70),
                          label: const Text('Return to Exams', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 15)),
                          style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _violationLabel(String type) {
    switch (type) {
      case 'APP_SWITCHED':   return 'Left exam screen (app minimised)';
      case 'BACKGROUND':     return 'App sent to background';
      case 'HOME_PRESSED':   return 'Home button pressed';
      default:               return 'Unknown violation: $type';
    }
  }

  String _formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (_) { return iso; }
  }
}

class _DisqualIcon extends StatefulWidget {
  @override
  State<_DisqualIcon> createState() => _DisqualIconState();
}

class _DisqualIconState extends State<_DisqualIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _outerRing;
  late Animation<double> _outerOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
    _outerRing = Tween(begin: 0.9, end: 1.5).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _outerOpacity = Tween(begin: 0.5, end: 0.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140, height: 140,
      child: Stack(alignment: Alignment.center, children: [
        AnimatedBuilder(animation: _ctrl, builder: (_, __) => Transform.scale(scale: _outerRing.value, child: Opacity(opacity: _outerOpacity.value, child: Container(width: 120, height: 120, decoration: BoxDecoration(border: Border.all(color: const Color(0xFFEF4444), width: 3), shape: BoxShape.circle))))),
        Container(width: 110, height: 110, decoration: BoxDecoration(gradient: RadialGradient(colors: [const Color(0xFF7F1D1D), const Color(0xFF450A0A)]), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.5), width: 2), boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.4), blurRadius: 30, spreadRadius: 5)]), child: const Icon(Icons.gavel_rounded, color: Color(0xFFEF4444), size: 52)),
      ]),
    );
  }
}

class _ExitConfirmDialog extends StatelessWidget {
  final VoidCallback onExit;
  final VoidCallback onStay;
  const _ExitConfirmDialog({required this.onExit, required this.onStay});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10))]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(height: 6, decoration: const BoxDecoration(color: Color(0xFFEF4444), borderRadius: BorderRadius.vertical(top: Radius.circular(24)))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Container(width: 64, height: 64, decoration: const BoxDecoration(color: Color(0xFFFFEEEE), shape: BoxShape.circle), child: const Icon(Icons.exit_to_app_rounded, color: Color(0xFFEF4444), size: 32)),
              const SizedBox(height: 16),
              const Text('Exit Exam?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _Clr.ink)),
              const SizedBox(height: 8),
              const Text('Exiting now will end your exam attempt. This action cannot be undone.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: _Clr.inkLight, height: 1.5)),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: onStay, style: OutlinedButton.styleFrom(foregroundColor: _Clr.primary, side: const BorderSide(color: _Clr.primary, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 13)), child: const Text('Keep Going', style: TextStyle(fontWeight: FontWeight.w800)))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: onExit, style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 13)), child: const Text('Exit Exam', style: TextStyle(fontWeight: FontWeight.w800)))),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
