import 'dart:math' as math;
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  FILE: home/widgets/syllabus_promo_banner.dart
//
//  DESIGN: Full-bleed swipeable PageView banner. Each page = one subject
//  category with its own vivid color world, large emoji illustration, bold
//  left-side headline, and a solid CTA. Auto-advances every 4s.
//  Inspired by: Unacademy, PhonePe, Zepto home banners.
//
//  Zero overflow — fixed SizedBox height of 168, all content clipped.
//
//  USAGE in home.dart (between HomeCategory and HomeFeatureBlock):
//    SliverToBoxAdapter(
//      child: SyllabusPromoBanner(onEnrollTap: _handleSyllabusEnroll),
//    ),
// ═══════════════════════════════════════════════════════════════════════════════

class SyllabusPromoBanner extends StatefulWidget {
  final VoidCallback? onEnrollTap;
  const SyllabusPromoBanner({Key? key, this.onEnrollTap}) : super(key: key);

  @override
  State<SyllabusPromoBanner> createState() => _SyllabusPromoBannerState();
}

class _SyllabusPromoBannerState extends State<SyllabusPromoBanner>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;

  // CTA heartbeat
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Entrance slide-up
  late AnimationController _entCtrl;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  // Blob glow breathe
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  static const _slides = [
    _Slide.school,
    _Slide.university,
    _Slide.competitive,
  ];

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.055)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _entCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 680))
      ..forward();
    _slideAnim = Tween<double>(begin: 28, end: 0)
        .animate(CurvedAnimation(parent: _entCtrl, curve: Curves.easeOutCubic));
    _fadeAnim =
        CurvedAnimation(parent: _entCtrl, curve: Curves.easeOut);

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _glowAnim =
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);

    _scheduleNext();
  }

  void _scheduleNext() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      final next = (_page + 1) % _slides.length;
      _pageCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 480),
          curve: Curves.easeInOut);
      _scheduleNext();
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _pulseCtrl.dispose();
    _entCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideAnim, _fadeAnim]),
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _slideAnim.value),
        child: Opacity(
          opacity: _fadeAnim.value,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: _buildShell(),
          ),
        ),
      ),
    );
  }

  Widget _buildShell() {
    final s = _slides[_page];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: s.accent.withOpacity(0.32),
              blurRadius: 28,
              offset: const Offset(0, 12),
              spreadRadius: -5),
          const BoxShadow(
              color: Color(0xBB000000),
              blurRadius: 12,
              offset: Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        // ✅ Fixed height — no overflow possible
        child: SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: _slides.length,
            itemBuilder: (_, i) => _buildPage(_slides[i]),
          ),
        ),
      ),
    );
  }

  // ── One banner page ──────────────────────────────────────────────────────────
  Widget _buildPage(_Slide s) {
    return Stack(
      children: [
        // Background (gradient + dot grid)
        Positioned.fill(child: CustomPaint(painter: _BgPainter(slide: s))),

        // Right: glowing blob + giant emoji
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 162,
          child: _buildVisual(s),
        ),

        // Left: text + CTA
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          right: 152,
          child: _buildCopy(s),
        ),

        // Bottom-left dot indicators
        Positioned(
          bottom: 12,
          left: 20,
          child: _buildDots(),
        ),
      ],
    );
  }

  // ── Right visual half ─────────────────────────────────────────────────────────
  Widget _buildVisual(_Slide s) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Blob glow painted behind emoji
          Positioned.fill(
            child: CustomPaint(
              painter: _BlobPainter(accent: s.accent, t: _glowAnim.value),
            ),
          ),
          // Big emoji centered
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Shadow behind emoji for depth
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: s.accent.withOpacity(0.28 + _glowAnim.value * 0.14),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                    color: s.accent.withOpacity(0.10),
                    border: Border.all(
                      color: s.accent.withOpacity(0.22),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(s.emoji, style: const TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 6),
                // Pill tag
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: s.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: s.accent.withOpacity(0.30), width: 0.8),
                  ),
                  child: Text(
                    s.tag,
                    style: TextStyle(
                      color: s.accent,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Left copy half ────────────────────────────────────────────────────────────
  Widget _buildCopy(_Slide s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 4, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Eyebrow
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: s.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  s.eyebrow,
                  style: TextStyle(
                    color: s.accent,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // Heading
          Text(
            s.heading,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.18,
              letterSpacing: -0.4,
            ),
          ),

          const SizedBox(height: 4),

          // Sub
          Text(
            s.sub,
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontSize: 10,
              height: 1.45,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          // CTA
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) => Transform.scale(
              scale: _pulseAnim.value,
              alignment: Alignment.centerLeft,
              child: child,
            ),
            child: GestureDetector(
              onTap: widget.onEnrollTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 420),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: s.accent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: s.accent.withOpacity(0.42),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enroll Free',
                      style: TextStyle(
                        color: Color(0xFF071209),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded,
                        color: Color(0xFF071209), size: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dot indicators ────────────────────────────────────────────────────────────
  Widget _buildDots() {
    final accent = _slides[_page].accent;
    return Row(
      children: List.generate(_slides.length, (i) {
        final on = i == _page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          margin: const EdgeInsets.only(right: 5),
          width: on ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: on ? accent : Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  SLIDE DATA
// ═══════════════════════════════════════════════════════════════════════════════

class _Slide {
  final String eyebrow;
  final String heading;
  final String sub;
  final String emoji;
  final String tag;
  final Color accent;
  final List<Color> bgColors;

  const _Slide({
    required this.eyebrow,
    required this.heading,
    required this.sub,
    required this.emoji,
    required this.tag,
    required this.accent,
    required this.bgColors,
  });

  static const school = _Slide(
    eyebrow: 'SCHOOL · CBSE · STATE',
    heading: 'Class I–XII\nComplete\nSyllabus',
    sub: 'Notes, videos & PYQs\nchapter-by-chapter.',
    emoji: '🏫',
    tag: 'CLASS I – XII',
    accent: Color(0xFF5EE89A),
    bgColors: [Color(0xFF081C0F), Color(0xFF0F2E1A), Color(0xFF061209)],
  );

  static const university = _Slide(
    eyebrow: 'UNIVERSITY · UG · PG',
    heading: 'Semester-\nwise Notes\n& Videos',
    sub: 'Engineering, Arts, Science\n& Commerce — all boards.',
    emoji: '🎓',
    tag: 'UG · PG · PhD',
    accent: Color(0xFF72D4F5),
    bgColors: [Color(0xFF061018), Color(0xFF0A1C2E), Color(0xFF040B14)],
  );

  static const competitive = _Slide(
    eyebrow: 'UPSC · SSC · WBCS · JEE',
    heading: 'Crack Your\nDream Exam\nWith Us',
    sub: 'PYQs, strategy notes &\nsubject-wise material.',
    emoji: '🏆',
    tag: 'GOVT EXAMS',
    accent: Color(0xFFFFD95A),
    bgColors: [Color(0xFF1A1200), Color(0xFF2C2000), Color(0xFF110E00)],
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
//  PAINTERS
// ═══════════════════════════════════════════════════════════════════════════════

/// Rich dark background with gradient + subtle dot grid on the left half
class _BgPainter extends CustomPainter {
  final _Slide slide;
  const _BgPainter({required this.slide});

  @override
  void paint(Canvas canvas, Size size) {
    // Main gradient
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: slide.bgColors,
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Dot grid (left 58% only)
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.04);
    const gap = 20.0;
    final maxX = size.width * 0.58;
    for (double x = gap; x < maxX; x += gap) {
      for (double y = gap; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.1, dotPaint);
      }
    }

    // Vertical separator between left and right
    canvas.drawLine(
      Offset(size.width * 0.60, 14),
      Offset(size.width * 0.60, size.height - 14),
      Paint()
        ..color = Colors.white.withOpacity(0.07)
        ..strokeWidth = 0.8,
    );

    // Subtle top edge highlight
    canvas.drawLine(
      Offset.zero,
      Offset(size.width, 0),
      Paint()
        ..color = slide.accent.withOpacity(0.18)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_BgPainter o) => o.slide != o.slide;
}

/// Animated radial glow blob behind the right-side emoji
class _BlobPainter extends CustomPainter {
  final Color accent;
  final double t; // 0..1 animated

  const _BlobPainter({required this.accent, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.52;
    final cy = size.height * 0.44;

    // Outer diffuse halo
    final r1 = size.width * (0.60 + t * 0.07);
    canvas.drawCircle(
      Offset(cx, cy),
      r1,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withOpacity(0.18 + t * 0.08),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r1))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 24 + t * 12),
    );

    // Inner solid disc
    final r2 = size.width * 0.28;
    canvas.drawCircle(
      Offset(cx, cy),
      r2,
      Paint()
        ..color = accent.withOpacity(0.07 + t * 0.04),
    );

    // Ring 1
    canvas.drawCircle(
      Offset(cx, cy),
      r2 * 1.35,
      Paint()
        ..color = accent.withOpacity(0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    // Ring 2
    canvas.drawCircle(
      Offset(cx, cy),
      r2 * 1.80,
      Paint()
        ..color = accent.withOpacity(0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    // Decorative arc (3/4 circle, rotated)
    final arcRect = Rect.fromCircle(
        center: Offset(cx, cy), radius: r2 * 2.1);
    canvas.drawArc(
      arcRect,
      -math.pi / 4,
      math.pi * 1.5,
      false,
      Paint()
        ..color = accent.withOpacity(0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_BlobPainter o) => o.t != t || o.accent != accent;
}
