import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// ─── DESIGN TOKENS ──────────────────────────────────────────────────────────

class _Clr {
  static const primary    = Color(0xFF1E40AF); // Primary Blue
  static const dark       = Color(0xFF1E3A8A); // Dark Blue
  static const mid        = Color(0xFF2563EB); // Mid Blue
  static const medium     = Color(0xFF3B82F6); // Medium Blue
  static const light      = Color(0xFF60A5FA); // Light Blue
  static const lighter    = Color(0xFF93C5FD); // Lighter Blue
  static const scaffoldBg = Color(0xFFF8F9FA); // Very light off-white
  static const surfaceEgg = Color(0xFFEFF6FF); // Blue tint light surface
  static const cardWhite  = Color(0xFFFFFFFF); // Pure White
  static const border     = Color(0xFFDBEAFE); // Blue tint border
  static const gold       = Colors.white; // Secondary White
  static const goldDark   = Color(0xFF1E40AF);
  static const red        = Color(0xFFEF4444);
  static const orange     = Color(0xFF2563EB);
  static const teal       = Color(0xFF3B82F6);
  static const ink        = Color(0xFF111827);
  static const inkMid     = Color(0xFF374151);
  static const inkLight   = Color(0xFF6B7280);
}

const _kThemeGrad = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [_Clr.dark, _Clr.medium],
);
const _kThemeGradLight = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)], // Blue gradients
);

List<BoxShadow> _themeShadow({double blur = 20, double opacity = 0.18}) => [
  BoxShadow(color: _Clr.primary.withOpacity(opacity), blurRadius: blur,
      spreadRadius: 0, offset: const Offset(0, 6)),
];
List<BoxShadow> _cardShadow() => [
  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 2)),
];

// ─────────────────────────────────────────────────────────────────────────────
//  STUDENT ONBOARDING PAGE
// ─────────────────────────────────────────────────────────────────────────────

class StudentOnboardingPage extends StatefulWidget {
  final String userId;
  const StudentOnboardingPage({super.key, required this.userId});

  @override
  State<StudentOnboardingPage> createState() => _StudentOnboardingPageState();
}

class _StudentOnboardingPageState extends State<StudentOnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _heroController;
  late Animation<double> _heroScale;
  late Animation<double> _heroFade;

  int _currentStep = 0;
  bool _isSaving = false;

  _DropItem? _selCategory;
  _DropItem? _selInstitution;
  _DropItem? _selCourse;
  _DropItem? _selSemester;
  _DropItem? _selSubjectGroup;

  List<_DropItem> _categories    = [];
  List<_DropItem> _institutions  = [];
  List<_DropItem> _courses       = [];
  List<_DropItem> _semesters     = [];
  List<_DropItem> _subjectGroups = [];

  bool _loadingCat    = true;
  bool _loadingInst   = false;
  bool _loadingCourse = false;
  bool _loadingSem    = false;
  bool _loadingSG     = false;

  bool get _allSelected =>
      _selCategory != null && _selInstitution != null &&
          _selCourse != null && _selSemester != null && _selSubjectGroup != null;

  /// True when the chosen category is School — drives dynamic UI labels for steps 4 & 5.
  bool get _isSchool => _selCategory?.name.toLowerCase().contains('school') ?? false;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _heroScale = CurvedAnimation(parent: _heroController, curve: Curves.elasticOut);
    _heroFade  = CurvedAnimation(parent: _heroController, curve: Curves.easeIn);
    _heroController.forward();
    _loadCategories();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heroController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCat = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('syllabus_nodes').where('parentId', isEqualTo: 'root').get();
      final list = snap.docs.map((d) => _DropItem.fromDoc(d)).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      setState(() { _categories = list; _loadingCat = false; });
    } catch (e) { setState(() => _loadingCat = false); }
  }

  Future<void> _loadChildren(String parentId,
      {required void Function(List<_DropItem>) onLoaded,
        required void Function(bool) setLoading}) async {
    setLoading(true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('syllabus_nodes').where('parentId', isEqualTo: parentId).get();
      final list = snap.docs.map((d) => _DropItem.fromDoc(d)).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      onLoaded(list);
    } catch (_) { onLoaded([]); }
    setLoading(false);
  }

  void _onCategoryChanged(_DropItem? val) {
    setState(() {
      _selCategory = val; _selInstitution = null; _selCourse = null;
      _selSemester = null; _selSubjectGroup = null;
      _institutions = []; _courses = []; _semesters = []; _subjectGroups = [];
    });
    if (val != null) _loadChildren(val.id,
        onLoaded: (l) => setState(() => _institutions = l),
        setLoading: (v) => setState(() => _loadingInst = v));
  }

  void _onInstitutionChanged(_DropItem? val) {
    setState(() {
      _selInstitution = val; _selCourse = null; _selSemester = null;
      _selSubjectGroup = null; _courses = []; _semesters = []; _subjectGroups = [];
    });
    if (val != null) _loadChildren(val.id,
        onLoaded: (l) => setState(() => _courses = l),
        setLoading: (v) => setState(() => _loadingCourse = v));
  }

  void _onCourseChanged(_DropItem? val) {
    setState(() {
      _selCourse = val; _selSemester = null; _selSubjectGroup = null;
      _semesters = []; _subjectGroups = [];
    });
    if (val != null) _loadChildren(val.id,
        onLoaded: (l) => setState(() => _semesters = l),
        setLoading: (v) => setState(() => _loadingSem = v));
  }

  void _onSemesterChanged(_DropItem? val) {
    setState(() { _selSemester = val; _selSubjectGroup = null; _subjectGroups = []; });
    if (val != null) _loadChildren(val.id,
        onLoaded: (l) => setState(() => _subjectGroups = l),
        setLoading: (v) => setState(() => _loadingSG = v));
  }

  void _onSubjectGroupChanged(_DropItem? val) => setState(() => _selSubjectGroup = val);

  void _goToStep(int step) {
    _pageController.animateToPage(step,
        duration: const Duration(milliseconds: 450), curve: Curves.easeInOutCubic);
    setState(() => _currentStep = step);
  }

  Future<void> _saveAndContinue() async {
    if (!_allSelected || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
        'onboarding': {
          'categoryId':      _selCategory!.id,
          'categoryName':    _selCategory!.name,
          'institutionId':   _selInstitution!.id,
          'institutionName': _selInstitution!.name,
          'courseId':        _selCourse!.id,
          'courseName':      _selCourse!.name,
          // ✅ semesterId stored so dashboard can load sibling subject groups
          'semesterId':      _selSemester!.id,
          'semesterName':    _selSemester!.name,
          'subjectGroupId':  _selSubjectGroup!.id,
          'subjectGroupName':_selSubjectGroup!.name,
        },
        'onboardingComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => StudentDashboardPage(
            userId:           widget.userId,
            categoryName:     _selCategory!.name,
            subjectGroupId:   _selSubjectGroup!.id,
            subjectGroupName: _selSubjectGroup!.name,
            // ✅ pass semesterId
            semesterId:       _selSemester!.id,
            semesterName:     _selSemester!.name,
            courseName:       _selCourse!.name,
            institutionName:  _selInstitution!.name,
          ),
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Clr.scaffoldBg,
      body: SafeArea(
        child: Column(children: [
          _buildTopBar(),
          _buildStepRail(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _WelcomePage(heroController: _heroController, onStart: () => _goToStep(1)),
                _StepPage(
                  step: 1, icon: Icons.category_rounded, color: _Clr.primary,
                  title: 'Choose Category', subtitle: 'School, University, or Competitive?',
                  child: _buildDropdown(label: 'Category', icon: Icons.category_rounded,
                      items: _categories, value: _selCategory,
                      loading: _loadingCat, onChanged: _onCategoryChanged),
                  canProceed: _selCategory != null,
                  onNext: () => _goToStep(2), onBack: () => _goToStep(0), isFirst: true,
                ),
                _StepPage(
                  step: 2, icon: Icons.account_balance_rounded, color: _Clr.mid,
                  title: 'Your Institution', subtitle: 'Select your board or university',
                  child: _buildDropdown(label: 'Institution / Board', icon: Icons.account_balance_rounded,
                      items: _institutions, value: _selInstitution, loading: _loadingInst,
                      onChanged: _onInstitutionChanged, dependsOn: _selCategory?.name ?? 'category'),
                  canProceed: _selInstitution != null,
                  onNext: () => _goToStep(3), onBack: () => _goToStep(1),
                ),
                _StepPage(
                  step: 3, icon: Icons.school_rounded, color: _Clr.medium,
                  title: 'Class / Course', subtitle: 'Which course are you enrolled in?',
                  child: _buildDropdown(label: 'Class / Course', icon: Icons.school_rounded,
                      items: _courses, value: _selCourse, loading: _loadingCourse,
                      onChanged: _onCourseChanged, dependsOn: _selInstitution?.name ?? 'institution'),
                  canProceed: _selCourse != null,
                  onNext: () => _goToStep(4), onBack: () => _goToStep(2),
                ),
                _StepPage(
                  step: 4,
                  icon: _isSchool ? Icons.folder_special_rounded : Icons.calendar_today_rounded,
                  color: _Clr.light,
                  title: _isSchool ? 'Subject Group / Stream' : 'Semester',
                  subtitle: _isSchool
                      ? 'Science, Arts, Commerce — pick yours!'
                      : 'Which semester are you currently in?',
                  child: _buildDropdown(
                      label: _isSchool ? 'Subject Group / Stream' : 'Semester',
                      icon: _isSchool ? Icons.folder_special_rounded : Icons.calendar_today_rounded,
                      items: _semesters, value: _selSemester, loading: _loadingSem,
                      onChanged: _onSemesterChanged, dependsOn: _selCourse?.name ?? 'class/course'),
                  canProceed: _selSemester != null,
                  onNext: () => _goToStep(5), onBack: () => _goToStep(3),
                ),
                _StepPage(
                  step: 5,
                  icon: _isSchool ? Icons.calendar_today_rounded : Icons.folder_special_rounded,
                  color: _Clr.lighter,
                  title: _isSchool ? 'Semester' : 'Subject Group',
                  subtitle: _isSchool
                      ? 'Which semester are you currently in?'
                      : 'Major, Minor, Science, Arts — pick yours!',
                  child: _buildDropdown(
                      label: _isSchool ? 'Semester' : 'Subject Group',
                      icon: _isSchool ? Icons.calendar_today_rounded : Icons.folder_special_rounded,
                      items: _subjectGroups, value: _selSubjectGroup, loading: _loadingSG,
                      onChanged: _onSubjectGroupChanged,
                      dependsOn: _isSchool
                          ? (_selSemester?.name ?? 'subject group / stream')
                          : (_selSemester?.name ?? 'semester')),
                  canProceed: _selSubjectGroup != null,
                  onNext: null, onBack: () => _goToStep(4), isLast: true,
                  onSave: _allSelected ? _saveAndContinue : null, isSaving: _isSaving,
                  summary: _buildSummary(),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RichText(
              text: const TextSpan(style: TextStyle(fontFamily: 'Segoe UI'), children: [
                TextSpan(text: "Let's get you\n",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                        color: _Clr.ink, height: 1.2)),
                TextSpan(text: 'set up! 🎓',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                        color: _Clr.primary, height: 1.2)),
              ]),
            ),
            const SizedBox(height: 4),
            const Text('Personalise your learning in 5 quick steps.',
                style: TextStyle(fontSize: 12, color: _Clr.inkLight, height: 1.5)),
          ]),
        ),
        FadeTransition(
          opacity: _heroFade,
          child: ScaleTransition(
            scale: _heroScale,
            child: Container(
              width: 76, height: 76,
              decoration: BoxDecoration(gradient: _kThemeGrad,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: _themeShadow(blur: 24, opacity: 0.35)),
              child: const Stack(alignment: Alignment.center, children: [
                Positioned(top: 14, left: 16,
                    child: Icon(Icons.auto_stories, color: Colors.white, size: 26)),
                Positioned(bottom: 12, right: 13,
                    child: Icon(Icons.star, color: Colors.white54, size: 15)),
                Positioned(top: 12, right: 12,
                    child: Icon(Icons.star, color: Colors.white30, size: 9)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildStepRail() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_currentStep == 0 ? 'Getting Started' : 'Step $_currentStep of 5',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _Clr.primary)),
          Text('${(_currentStep / 5 * 100).toInt()}%',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _Clr.primary)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _currentStep / 5),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => LinearProgressIndicator(
              value: value, minHeight: 7,
              backgroundColor: _Clr.surfaceEgg,
              valueColor: const AlwaysStoppedAnimation(_Clr.primary),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(5, (i) {
            final stepNum = i + 1;
            final isDone   = _currentStep > stepNum;
            final isActive = _currentStep == stepNum;
            final emojis   = ['📚', '🏫', '🎓', '📅', '📂'];
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: isDone ? _Clr.primary : isActive ? _Clr.surfaceEgg : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isDone || isActive ? _Clr.primary : _Clr.border,
                      width: isActive ? 2 : 1),
                  boxShadow: isActive ? _themeShadow(blur: 8, opacity: 0.12) : null,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                      : Text(emojis[i], style: const TextStyle(fontSize: 13)),
                ),
              ),
            );
          }),
        ),
      ]),
    );
  }

  Widget _buildDropdown({
    required String label, required IconData icon,
    required List<_DropItem> items, required _DropItem? value,
    required bool loading, required void Function(_DropItem?) onChanged,
    String? dependsOn,
  }) {
    if (loading) {
      return Container(
        height: 58,
        decoration: BoxDecoration(color: _Clr.surfaceEgg,
            borderRadius: BorderRadius.circular(14), border: Border.all(color: _Clr.border)),
        child: const Center(child: SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: _Clr.primary))),
      );
    }
    if (items.isEmpty && dependsOn != null && value == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF9FBF9),
            borderRadius: BorderRadius.circular(14), border: Border.all(color: _Clr.border)),
        child: Row(children: [
          const Icon(Icons.info_outline, size: 16, color: _Clr.inkLight),
          const SizedBox(width: 8),
          Text('Please select $dependsOn first',
              style: const TextStyle(fontSize: 13, color: _Clr.inkLight)),
        ]),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _Clr.inkMid)),
      const SizedBox(height: 10),
      DropdownButtonFormField<_DropItem>(
        value: value, isExpanded: true,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _Clr.primary, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _Clr.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _Clr.border, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _Clr.primary, width: 2)),
          filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
        hint: Text(items.isEmpty ? 'No options available' : 'Select $label',
            style: const TextStyle(color: _Clr.inkLight, fontSize: 14)),
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item.name, style: const TextStyle(fontSize: 14, color: _Clr.inkMid)),
        )).toList(),
        onChanged: items.isEmpty ? null : onChanged,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(14),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _Clr.primary),
      ),
    ]);
  }

  List<_SummaryItem>? _buildSummary() {
    if (!_allSelected) return null;
    return [
      _SummaryItem(icon: Icons.category_rounded,        label: 'Category',       value: _selCategory!.name),
      _SummaryItem(icon: Icons.account_balance_rounded, label: 'Institution',    value: _selInstitution!.name),
      _SummaryItem(icon: Icons.school_rounded,          label: 'Class / Course', value: _selCourse!.name),
      // For School: step-4 (semesterId field) = Subject Group/Stream; step-5 (subjectGroupId) = Semester
      _SummaryItem(
        icon: _isSchool ? Icons.folder_special_rounded : Icons.calendar_today_rounded,
        label: _isSchool ? 'Subject Group' : 'Semester',
        value: _selSemester!.name,
      ),
      _SummaryItem(
        icon: _isSchool ? Icons.calendar_today_rounded : Icons.folder_special_rounded,
        label: _isSchool ? 'Semester' : 'Subject Group',
        value: _selSubjectGroup!.name,
      ),
    ];
  }
}

// ─── STEP PAGE ────────────────────────────────────────────────────────────────

class _StepPage extends StatelessWidget {
  final int step;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget child;
  final bool canProceed;
  final VoidCallback? onNext;
  final VoidCallback onBack;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onSave;
  final bool isSaving;
  final List<_SummaryItem>? summary;

  const _StepPage({
    required this.step, required this.icon, required this.color,
    required this.title, required this.subtitle, required this.child,
    required this.canProceed, required this.onNext, required this.onBack,
    this.isFirst = false, this.isLast = false, this.onSave,
    this.isSaving = false, this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: color.withOpacity(0.25))),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: _Clr.ink)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: _Clr.inkLight)),
          ])),
        ]),
        const SizedBox(height: 22),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _Clr.border, width: 1.5), boxShadow: _cardShadow()),
          padding: const EdgeInsets.all(20),
          child: child,
        ),
        if (isLast && summary != null) ...[
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(gradient: _kThemeGrad,
                borderRadius: BorderRadius.circular(22),
                boxShadow: _themeShadow(blur: 28, opacity: 0.28)),
            padding: const EdgeInsets.all(22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.checklist_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Your Selection Summary',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
              ]),
              const SizedBox(height: 16),
              ...summary!.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(s.icon, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.label, style: TextStyle(color: Colors.white.withOpacity(0.65),
                        fontSize: 10, fontWeight: FontWeight.w600)),
                    Text(s.value, style: const TextStyle(color: Colors.white,
                        fontSize: 13, fontWeight: FontWeight.w700)),
                  ])),
                ]),
              )),
            ]),
          ),
        ],
        const SizedBox(height: 28),
        Row(children: [
          if (!isFirst) ...[
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _Clr.primary,
                  side: const BorderSide(color: _Clr.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 3,
            child: isLast
                ? FilledButton.icon(
              onPressed: (onSave != null && !isSaving) ? onSave : null,
              icon: isSaving
                  ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.rocket_launch_rounded, size: 16),
              label: Text(isSaving ? 'Saving...' : 'Save & Continue'),
              style: FilledButton.styleFrom(
                backgroundColor: _Clr.primary,
                disabledBackgroundColor: _Clr.primary.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            )
                : FilledButton.icon(
              onPressed: canProceed ? onNext : null,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Next'),
              style: FilledButton.styleFrom(
                backgroundColor: _Clr.primary,
                disabledBackgroundColor: _Clr.primary.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ─── WELCOME PAGE ─────────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  final AnimationController heroController;
  final VoidCallback onStart;
  const _WelcomePage({required this.heroController, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 6),
        ScaleTransition(
          scale: CurvedAnimation(parent: heroController, curve: Curves.easeOut),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 36),
            decoration: BoxDecoration(gradient: _kThemeGrad,
                borderRadius: BorderRadius.circular(28),
                boxShadow: _themeShadow(blur: 32, opacity: 0.32)),
            child: Column(children: [
              Stack(alignment: Alignment.center, children: [
                Container(width: 96, height: 96,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.18), width: 2))),
                Container(width: 72, height: 72,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.14),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 38)),
                Positioned(bottom: 2, right: 6,
                    child: Container(width: 26, height: 26,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [_Clr.gold, _Clr.goldDark]),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.star_rounded, size: 14, color: Colors.white))),
              ]),
              const SizedBox(height: 22),
              const Text('Welcome, Scholar! 👋',
                  style: TextStyle(color: Colors.white, fontSize: 24,
                      fontWeight: FontWeight.w900, letterSpacing: -0.3)),
              const SizedBox(height: 10),
              Text("We'll guide you through 5 quick steps to personalise your dashboard.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 13, height: 1.55)),
            ]),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _Clr.border, width: 1.5),
              boxShadow: _cardShadow()),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("What you'll select:",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _Clr.ink)),
            const SizedBox(height: 16),
            ..._OnboardingStep.all.asMap().entries.map((entry) {
              final idx = entry.key; final step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(children: [
                  Container(width: 40, height: 40,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [_Clr.primary.withOpacity(0.15), _Clr.surfaceEgg]),
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(step.emoji, style: const TextStyle(fontSize: 17)))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(step.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _Clr.ink)),
                    Text(step.desc, style: const TextStyle(fontSize: 11, color: _Clr.inkLight)),
                  ])),
                  Container(width: 22, height: 22,
                      decoration: const BoxDecoration(color: _Clr.primary, shape: BoxShape.circle),
                      child: Center(child: Text('${idx + 1}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)))),
                ]),
              );
            }),
          ]),
        ),
        const SizedBox(height: 26),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text("Let's Begin!", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            style: FilledButton.styleFrom(
              backgroundColor: _Clr.primary,
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── DATA HELPERS ─────────────────────────────────────────────────────────────

class _OnboardingStep {
  final String emoji; final String label; final String desc;
  const _OnboardingStep(this.emoji, this.label, this.desc);
  static const all = [
    _OnboardingStep('📚', 'Category',      'School, University, or Competitive'),
    _OnboardingStep('🏫', 'Institution',   'Your board or university name'),
    _OnboardingStep('🎓', 'Class / Course','Your current class or degree'),
    _OnboardingStep('📅', 'Semester',      'Current semester or term'),
    _OnboardingStep('📂', 'Subject Group', 'Major, Minor, Science, Arts…'),
  ];
}

class _DropItem {
  final String id; final String name; final String? subtitle;
  const _DropItem({required this.id, required this.name, this.subtitle});

  factory _DropItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return _DropItem(id: doc.id, name: data['name'] ?? '', subtitle: data['subtitle']);
  }

  @override bool operator ==(Object other) => other is _DropItem && other.id == id;
  @override int get hashCode => id.hashCode;
}

class _SummaryItem {
  final IconData icon; final String label; final String value;
  const _SummaryItem({required this.icon, required this.label, required this.value});
}

// ─────────────────────────────────────────────────────────────────────────────
//  STUDENT DASHBOARD PAGE
// ─────────────────────────────────────────────────────────────────────────────

class StudentDashboardPage extends StatefulWidget {
  final String userId;
  final String categoryName;
  final String subjectGroupId;
  final String subjectGroupName;
  // ✅ semesterId added — used to load all sibling subject groups
  final String semesterId;
  final String semesterName;
  final String courseName;
  final String institutionName;

  const StudentDashboardPage({
    super.key,
    required this.userId,
    required this.categoryName,
    required this.subjectGroupId,
    required this.subjectGroupName,
    required this.semesterId,
    required this.semesterName,
    required this.courseName,
    required this.institutionName,
  });

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  /// True when the enrolled category is School — drives dynamic profile & header labels.
  bool get _isSchool => widget.categoryName.toLowerCase().contains('school');

  // ── Subject Group Switcher State ─────────────────────────────────────────
  /// All subject groups that live under the same semester
  List<_SubjectGroupOption> _allSubjectGroups = [];
  /// The group currently being browsed (starts as the enrolled one)
  late String _activeSubjectGroupId;
  late String _activeSubjectGroupName;
  bool _loadingGroups = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _activeSubjectGroupId   = widget.subjectGroupId;
    _activeSubjectGroupName = widget.subjectGroupName;
    _loadAllSubjectGroups();
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  // ── Load sibling subject groups from Firestore ────────────────────────────
  Future<void> _loadAllSubjectGroups() async {
    if (widget.semesterId.isEmpty) {
      setState(() => _loadingGroups = false);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('syllabus_nodes')
          .where('parentId', isEqualTo: widget.semesterId)
          .get();
      final groups = snap.docs
          .map((d) => _SubjectGroupOption(
        id: d.id,
        name: (d.data() as Map<String, dynamic>)['name'] ?? '',
      ))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      setState(() { _allSubjectGroups = groups; _loadingGroups = false; });
    } catch (_) {
      setState(() => _loadingGroups = false);
    }
  }

  // ── Save selected subject group to Firestore ──────────────────────────────
  Future<void> _saveSubjectGroupChange(String newId, String newName) async {
    setState(() {
      _activeSubjectGroupId   = newId;
      _activeSubjectGroupName = newName;
    });
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'onboarding.subjectGroupId':   newId,
        'onboarding.subjectGroupName': newName,
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Clr.scaffoldBg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: _Clr.dark,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Colors.white),
                  onPressed: () => _showChangeSettings(context)),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _DashboardHeroHeader(
                categoryName:     widget.categoryName,
                institutionName:  widget.institutionName,
                subjectGroupName: _activeSubjectGroupName,
                courseName:       widget.courseName,
                semesterName:     widget.semesterName,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                color: _Clr.dark,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.book_rounded, size: 16),
                        const SizedBox(width: 6),
                        Text(_activeSubjectGroupName.length > 14
                            ? '${_activeSubjectGroupName.substring(0, 14)}…'
                            : _activeSubjectGroupName),
                      ]),
                    ),
                    const Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.person_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('My Profile'),
                    ])),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSubjectsTab(),
            _buildProfileTab(),
          ],
        ),
      ),
    );
  }

  // ── SUBJECTS TAB ──────────────────────────────────────────────────────────
  Widget _buildSubjectsTab() {
    return Column(children: [
      // ✅ Subject Group Switcher chips row — hidden for School (curriculum is fixed)
      if (!_isSchool && !_loadingGroups && _allSubjectGroups.length > 1)
        _SubjectGroupSwitcher(
          groups: _allSubjectGroups,
          activeId: _activeSubjectGroupId,
          enrolledId: widget.subjectGroupId,
          onSelect: (group) => setState(() {
            _activeSubjectGroupId   = group.id;
            _activeSubjectGroupName = group.name;
          }),
        ),

      // Search bar
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search subjects...',
            hintStyle: const TextStyle(color: _Clr.inkLight, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: _Clr.primary, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(icon: const Icon(Icons.close, color: _Clr.inkLight, size: 18),
                onPressed: () => setState(() => _searchQuery = ''))
                : null,
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _Clr.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _Clr.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _Clr.primary, width: 2)),
          ),
        ),
      ),

      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          // ✅ query uses _activeSubjectGroupId so switching chips refreshes subjects
          stream: FirebaseFirestore.instance.collection('syllabus_nodes')
              .where('parentId', isEqualTo: _activeSubjectGroupId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: _Clr.primary));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptySubjects();
            }
            var docs = snapshot.data!.docs;
            if (_searchQuery.isNotEmpty) {
              docs = docs.where((d) {
                final name = ((d.data() as Map)['name'] ?? '').toString().toLowerCase();
                return name.contains(_searchQuery);
              }).toList();
            }
            if (docs.isEmpty) {
              return const Center(child: Text('No subjects match your search.',
                  style: TextStyle(color: _Clr.inkLight)));
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final data = docs[i].data() as Map<String, dynamic>;
                int videoCount = (data['videos'] as List?)?.length ?? 0;
                int pdfCount   = (data['pdfs'] as List?)?.length ?? 0;
                int qnaCount   = 0;
                for (final f in (data['videoFolders'] as List? ?? [])) {
                  videoCount += ((f as Map)['videos'] as List?)?.length ?? 0;
                }
                for (final f in (data['pdfFolders'] as List? ?? [])) {
                  pdfCount += ((f as Map)['pdfs'] as List?)?.length ?? 0;
                }
                for (final f in (data['qnaFolders'] as List? ?? [])) {
                  qnaCount += ((f as Map)['qnas'] as List?)?.length ?? 0;
                }
                return _SubjectCard(
                  id: docs[i].id, name: data['name'] ?? '',
                  subtitle: data['subtitle'],
                  isPremium: data['isPremium'] ?? false,
                  price: (data['price'] ?? 0).toDouble(),
                  videoCount: videoCount, pdfCount: pdfCount, qnaCount: qnaCount,
                  iconCode: data['iconCode'] ?? Icons.book.codePoint,
                );
              },
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildEmptySubjects() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(gradient: _kThemeGradLight,
                shape: BoxShape.circle, boxShadow: _themeShadow(blur: 20)),
            child: const Icon(Icons.book_outlined, size: 44, color: Colors.white),
          ),
          const SizedBox(height: 22),
          const Text('No Subjects Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _Clr.ink)),
          const SizedBox(height: 8),
          Text("No subjects found in $_activeSubjectGroupName yet.\nCheck back soon!",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _Clr.inkLight, height: 1.5)),
        ]),
      ),
    );
  }

  // ── PROFILE TAB ───────────────────────────────────────────────────────────
  Widget _buildProfileTab() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
      builder: (context, snapshot) {
        Map<String, dynamic> onboarding = {};
        if (snapshot.hasData && snapshot.data?.data() != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data['onboarding'] != null) {
            onboarding = Map<String, dynamic>.from(data['onboarding'] as Map);
          }
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            // Profile hero card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(gradient: _kThemeGrad,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: _themeShadow(blur: 24, opacity: 0.26)),
              child: Row(children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Student Profile',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                  const SizedBox(height: 3),
                  Text(widget.userId,
                      style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 10),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
              ]),
            ),
            const SizedBox(height: 16),

            // Enrolment Details card
            Container(
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _Clr.border, width: 1.5),
                  boxShadow: _cardShadow()),
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.verified_rounded, color: _Clr.primary, size: 18),
                  const SizedBox(width: 8),
                  const Text('Enrolment Details',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _Clr.ink)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showChangeSettings(context),
                    child: const Text('Change',
                        style: TextStyle(fontSize: 12, color: _Clr.primary, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const Divider(height: 22, color: _Clr.border),
                _ProfileRow(icon: Icons.category_rounded,
                    label: 'Category', value: onboarding['categoryName']?.toString() ?? ''),
                _ProfileRow(icon: Icons.account_balance_rounded,
                    label: 'Institution', value: onboarding['institutionName']?.toString() ?? widget.institutionName),
                _ProfileRow(icon: Icons.school_rounded,
                    label: 'Class / Course', value: onboarding['courseName']?.toString() ?? widget.courseName),
                _ProfileRow(icon: Icons.calendar_today_rounded,
                    // For School: semesterName field stores Subject Group/Stream (e.g. SCIENCE)
                    label: _isSchool ? 'Subject Group' : 'Semester',
                    value: onboarding['semesterName']?.toString() ?? widget.semesterName),

                // ✅ Subject Group / Semester row — Change button hidden for School
                // For School: subjectGroupName field stores the Semester (e.g. CLASS XI - 1ST SEMESTER)
                if (_isSchool)
                  _ProfileRow(
                    icon: Icons.folder_special_rounded,
                    label: 'Semester',
                    value: _activeSubjectGroupName,
                  )
                else
                  _ProfileRowWithAction(
                    icon: Icons.folder_special_rounded,
                    label: 'Subject Group',
                    value: _activeSubjectGroupName,
                    actionLabel: 'Change',
                    onAction: () => _showChangeSubjectGroupSheet(context),
                  ),
              ]),
            ),
            const SizedBox(height: 14),

            // Stats row
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('syllabus_nodes')
                  .where('parentId', isEqualTo: _activeSubjectGroupId).snapshots(),
              builder: (_, snap) {
                final count     = snap.data?.docs.length ?? 0;
                final premCount = snap.data?.docs.where((d) =>
                (d.data() as Map)['isPremium'] == true).length ?? 0;
                return Row(children: [
                  Expanded(child: _StatCard(icon: Icons.book_rounded,
                      value: '$count', label: 'Subjects', color: _Clr.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(icon: Icons.lock_open_rounded,
                      value: '${count - premCount}', label: 'Free', color: _Clr.lighter)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(icon: Icons.workspace_premium,
                      value: '$premCount', label: 'Premium', color: _Clr.goldDark)),
                ]);
              },
            ),
          ],
        );
      },
    );
  }

  // ── Change Subject Group Bottom Sheet ─────────────────────────────────────
  void _showChangeSubjectGroupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 16, left: 20, right: 20,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Drag handle
            Container(width: 44, height: 4,
                decoration: BoxDecoration(color: _Clr.border, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 20),

            // Header
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _Clr.surfaceEgg, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.folder_special_rounded, color: _Clr.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Change Subject Group',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _Clr.ink)),
                Text(
                  // For School: semesterName holds the stream (e.g. SCIENCE), not a semester
                    _isSchool
                        ? 'Stream: ${widget.semesterName}'
                        : 'Semester: ${widget.semesterName}',
                    style: const TextStyle(fontSize: 12, color: _Clr.inkLight)),
              ])),
            ]),
            const SizedBox(height: 6),

            // Info banner
            Container(
              margin: const EdgeInsets.symmetric(vertical: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _Clr.surfaceEgg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _Clr.border)),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded, color: _Clr.primary, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text(
                  'Your semester and course stay unchanged.\nOnly the subject group view will update.',
                  style: TextStyle(fontSize: 12, color: _Clr.inkMid, height: 1.45),
                )),
              ]),
            ),

            // Subject group options list
            if (_loadingGroups)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: _Clr.primary),
              )
            else if (_allSubjectGroups.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('No subject groups found.', style: TextStyle(color: _Clr.inkLight)),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _allSubjectGroups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final group = _allSubjectGroups[i];
                    final isActive   = group.id == _activeSubjectGroupId;
                    final isEnrolled = group.id == widget.subjectGroupId;
                    return GestureDetector(
                      onTap: () async {
                        await _saveSubjectGroupChange(group.id, group.name);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isActive ? _Clr.primary : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isActive ? _Clr.primary : _Clr.border,
                            width: isActive ? 0 : 1.5,
                          ),
                          boxShadow: isActive ? _themeShadow(blur: 12, opacity: 0.2) : _cardShadow(),
                        ),
                        child: Row(children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white.withOpacity(0.2)
                                  : _Clr.surfaceEgg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.folder_special_rounded,
                                color: isActive ? Colors.white : _Clr.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(group.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 14,
                                  color: isActive ? Colors.white : _Clr.ink,
                                )),
                            if (isEnrolled)
                              Container(
                                margin: const EdgeInsets.only(top: 3),
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.white.withOpacity(0.25)
                                      : _Clr.surfaceEgg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Your enrolled group',
                                    style: TextStyle(
                                      fontSize: 10, fontWeight: FontWeight.w700,
                                      color: isActive ? Colors.white : _Clr.primary,
                                    )),
                              ),
                          ])),
                          if (isActive)
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20)
                          else
                            Icon(Icons.chevron_right_rounded, color: _Clr.border, size: 20),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  void _showChangeSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: _Clr.surfaceEgg, shape: BoxShape.circle),
          child: const Icon(Icons.tune_rounded, color: _Clr.primary, size: 26),
        ),
        title: const Text('Change Enrolment', textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: _Clr.ink)),
        content: const Text(
          'Do you want to go back and change your class or subject group selection?',
          textAlign: TextAlign.center,
          style: TextStyle(color: _Clr.inkLight, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: _Clr.inkLight))),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // ✅ Mark onboarding incomplete FIRST so DashboardLoader shows the
              // form if the user exits the app before finishing re-selection.
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .update({'onboardingComplete': false});
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (_) => StudentOnboardingPage(userId: widget.userId)));
              }
            },
            style: FilledButton.styleFrom(backgroundColor: _Clr.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Re-select'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SUBJECT GROUP OPTION MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _SubjectGroupOption {
  final String id;
  final String name;
  const _SubjectGroupOption({required this.id, required this.name});
}

// ─────────────────────────────────────────────────────────────────────────────
//  SUBJECT GROUP SWITCHER  (horizontal chips row in Subjects tab)
// ─────────────────────────────────────────────────────────────────────────────

class _SubjectGroupSwitcher extends StatelessWidget {
  final List<_SubjectGroupOption> groups;
  final String activeId;
  final String enrolledId;
  final void Function(_SubjectGroupOption) onSelect;

  const _SubjectGroupSwitcher({
    required this.groups,
    required this.activeId,
    required this.enrolledId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Label
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Row(children: [
          Icon(Icons.folder_special_rounded, size: 14, color: _Clr.primary),
          SizedBox(width: 6),
          Text('Subject Groups',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _Clr.inkMid)),
        ]),
      ),
      // Scrollable chips
      SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: groups.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) {
            final group    = groups[i];
            final isActive   = group.id == activeId;
            final isEnrolled = group.id == enrolledId;

            return GestureDetector(
              onTap: () => onSelect(group),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isActive ? _Clr.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? _Clr.primary : _Clr.border,
                    width: 1.5,
                  ),
                  boxShadow: isActive ? _themeShadow(blur: 10, opacity: 0.22) : _cardShadow(),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (isEnrolled) ...[
                    Icon(Icons.person_pin_rounded,
                        size: 13, color: isActive ? Colors.white : _Clr.primary),
                    const SizedBox(width: 4),
                  ],
                  Text(group.name,
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : _Clr.inkMid,
                      )),
                  if (isActive) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                  ],
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 4),
      const Divider(height: 1, color: _Clr.border, indent: 16, endIndent: 16),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DASHBOARD HERO HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardHeroHeader extends StatelessWidget {
  final String categoryName;
  final String institutionName;
  final String subjectGroupName;
  final String courseName;
  final String semesterName;

  const _DashboardHeroHeader({
    required this.categoryName, required this.institutionName,
    required this.subjectGroupName, required this.courseName,
    required this.semesterName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_Clr.dark, _Clr.mid, _Clr.medium], stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(children: [
        Positioned(right: -30, top: -30,
            child: Container(width: 180, height: 180,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), shape: BoxShape.circle))),
        Positioned(right: 60, bottom: 30,
            child: Container(width: 80, height: 80,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), shape: BoxShape.circle))),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 76),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              const Text('YOUR ENROLMENT',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
              const SizedBox(height: 6),
              Text(subjectGroupName,
                  style: const TextStyle(color: Colors.white, fontSize: 28,
                      fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.15)),
              const SizedBox(height: 16),
              Wrap(spacing: 8, runSpacing: 10, children: [
                if (categoryName.isNotEmpty) _DashChip(icon: Icons.category_rounded, label: categoryName),
                if (institutionName.isNotEmpty) _DashChip(icon: Icons.account_balance_rounded, label: institutionName),
                if (courseName.isNotEmpty) _DashChip(icon: Icons.school_rounded, label: courseName),
                if (semesterName.isNotEmpty)
                  _DashChip(
                    // For School: semesterName field = Subject Group/Stream (e.g. SCIENCE)
                    icon: categoryName.toLowerCase().contains('school')
                        ? Icons.folder_special_rounded
                        : Icons.calendar_today_rounded,
                    label: categoryName.toLowerCase().contains('school')
                        ? semesterName   // show SCIENCE as-is — it's the stream, not a semester
                        : (semesterName.toLowerCase().contains('sem')
                        ? semesterName : 'Semester $semesterName'),
                  ),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DASHBOARD LOADER
// ─────────────────────────────────────────────────────────────────────────────

class DashboardLoader extends StatelessWidget {
  const DashboardLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
          backgroundColor: _Clr.scaffoldBg,
          body: Center(child: CircularProgressIndicator(color: _Clr.primary)));
    }
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              backgroundColor: _Clr.scaffoldBg,
              body: Center(child: CircularProgressIndicator(color: _Clr.primary)));
        }
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final onboarding = data?['onboarding'] as Map<String, dynamic>? ?? {};
        if (data?['onboardingComplete'] != true) {
          return StudentOnboardingPage(userId: user.uid);
        }
        return StudentDashboardPage(
          userId:           user.uid,
          categoryName:     onboarding['categoryName']?.toString() ?? '',
          subjectGroupId:   onboarding['subjectGroupId']?.toString() ?? '',
          subjectGroupName: onboarding['subjectGroupName']?.toString() ?? 'My Subjects',
          // ✅ semesterId now passed through
          semesterId:       onboarding['semesterId']?.toString() ?? '',
          semesterName:     onboarding['semesterName']?.toString() ?? '',
          courseName:       onboarding['courseName']?.toString() ?? '',
          institutionName:  onboarding['institutionName']?.toString() ?? '',
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _DashChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DashChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 40),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: _Clr.gold),
        const SizedBox(width: 6),
        Flexible(child: Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
            maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PROFILE ROW WITH OPTIONAL ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileRowWithAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String actionLabel;
  final VoidCallback onAction;

  const _ProfileRowWithAction({
    required this.icon, required this.label, required this.value,
    required this.actionLabel, required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(color: _Clr.surfaceEgg,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Icon(icon, color: _Clr.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10, color: _Clr.inkLight, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _Clr.ink)),
        ])),
        // ✅ Change button right beside the subject group value
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: _Clr.surfaceEgg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(actionLabel,
              style: const TextStyle(fontSize: 11, color: _Clr.primary, fontWeight: FontWeight.w800)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SUBJECT CARD
// ─────────────────────────────────────────────────────────────────────────────

class _SubjectCard extends StatelessWidget {
  final String id, name;
  final String? subtitle;
  final bool isPremium;
  final double price;
  final int videoCount, pdfCount, qnaCount, iconCode;

  const _SubjectCard({
    required this.id, required this.name, this.subtitle,
    required this.isPremium, required this.price,
    required this.videoCount, required this.pdfCount,
    this.qnaCount = 0, required this.iconCode,
  });

  @override
  Widget build(BuildContext context) {
    final icon = IconData(iconCode, fontFamily: 'MaterialIcons');
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users').doc(FirebaseAuth.instance.currentUser?.uid).get(),
      builder: (context, snapshot) {
        bool hasAccess = !isPremium;
        if (snapshot.hasData && snapshot.data?.data() != null) {
          final List purchased =
              (snapshot.data!.data() as Map<String, dynamic>)['purchased_subjects'] ?? [];
          if (purchased.contains(id)) hasAccess = true;
        }
        return GestureDetector(
          onTap: () async {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return;
            final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
            final List purchased =
                (userDoc.data() as Map<String, dynamic>)['purchased_subjects'] ?? [];
            if (!isPremium || purchased.contains(id)) {
              if (context.mounted) {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => FreeSubjectDetailsScreen(subjectId: id, subjectName: name)));
              }
            } else {
              if (context.mounted) {
                showModalBottomSheet(
                  context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
                  builder: (_) => PremiumPaymentBottomSheet(subjectId: id, subjectName: name, price: price),
                );
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isPremium ? _Clr.gold.withOpacity(0.6) : _Clr.border,
                  width: isPremium ? 1.5 : 1),
              boxShadow: isPremium
                  ? [BoxShadow(color: _Clr.gold.withOpacity(0.12), blurRadius: 14, offset: const Offset(0, 4))]
                  : _cardShadow(),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: isPremium
                      ? [_Clr.gold, _Clr.goldDark] : [_Clr.primary, _Clr.lighter]),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: isPremium ? _Clr.gold.withOpacity(0.12) : _Clr.surfaceEgg,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isPremium ? _Clr.gold.withOpacity(0.4) : _Clr.border),
                    ),
                    child: Icon(icon, color: isPremium ? _Clr.goldDark : _Clr.primary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(name, style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15, color: _Clr.ink))),
                      if (isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: _Clr.gold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _Clr.gold.withOpacity(0.6), width: 0.8)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.workspace_premium_rounded, size: 11, color: _Clr.goldDark),
                            const SizedBox(width: 3),
                            Text('₹${price.toInt()}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _Clr.goldDark)),
                          ]),
                        ),
                    ]),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(subtitle!, style: const TextStyle(fontSize: 11, color: _Clr.inkLight)),
                    ],
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        _ContentBadge(icon: Icons.play_circle_rounded, label: '$videoCount videos', color: _Clr.red),
                        const SizedBox(width: 8),
                        _ContentBadge(icon: Icons.picture_as_pdf_rounded, label: '$pdfCount PDFs', color: _Clr.orange),
                        const SizedBox(width: 8),
                        _ContentBadge(icon: Icons.quiz_rounded, label: '$qnaCount Q&As', color: _Clr.teal),
                      ]),
                    ),
                  ])),
                  const SizedBox(width: 8),
                  Icon(hasAccess ? Icons.chevron_right_rounded : Icons.lock_rounded,
                      color: hasAccess ? _Clr.border : _Clr.goldDark, size: 22),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAYMENT BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class PremiumPaymentBottomSheet extends StatefulWidget {
  final String subjectId, subjectName;
  final double price;
  const PremiumPaymentBottomSheet({super.key, required this.subjectId,
    required this.subjectName, required this.price});

  @override
  State<PremiumPaymentBottomSheet> createState() => _PremiumPaymentBottomSheetState();
}

class _PremiumPaymentBottomSheetState extends State<PremiumPaymentBottomSheet> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() { _razorpay.clear(); super.dispose(); }

  void openCheckout() async {
    setState(() => _isProcessing = true);
    final orderId = await createRazorpayOrder(widget.price.toInt());
    if (orderId == null) {
      setState(() => _isProcessing = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Unable to connect to payment gateway'),
              backgroundColor: _Clr.orange));
      return;
    }
    final options = {
      'key': 'rzp_live_q05lvifSYOtDJ7',
      'order_id': orderId,
      'amount': (widget.price * 100).toInt(),
      'name': 'Examplan B',
      'image': 'assets/images/examplan_b_logo.png',
      'description': widget.subjectName,
      'theme': {'color': '#305CDE'},
    };
    try { _razorpay.open(options); } catch (e) { setState(() => _isProcessing = false); }
  }

  Future<String?> createRazorpayOrder(int amount) async {
    try {
      final response = await http.post(
        Uri.parse('https://createrazorpayorder-ebwzua76iq-uc.a.run.app'),
        headers: {'Accept': '*/*', 'User-Agent': 'Flutter Client', 'Content-Type': 'application/json'},
        body: json.encode({'amount': amount, 'currency': 'INR'}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body)['order']['id'];
      }
    } catch (_) {}
    return null;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {'purchased_subjects': FieldValue.arrayUnion([widget.subjectId])},
          SetOptions(merge: true));
    }
    _showStatusDialog('Payment Successful!', response.paymentId, true);
  }

  void _handlePaymentError(PaymentFailureResponse response) =>
      _showStatusDialog('Payment Failed', response.message, false);

  void _handleExternalWallet(ExternalWalletResponse response) =>
      _showStatusDialog('Notice', 'External wallets are not currently supported.', false);

  void _showStatusDialog(String title, String? id, bool isSuccess) {
    setState(() => _isProcessing = false);
    showDialog(
      context: context, barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
                color: isSuccess ? _Clr.surfaceEgg : const Color(0xFFFFE8DD),
                shape: BoxShape.circle),
            child: Icon(isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                size: 44, color: isSuccess ? _Clr.primary : Colors.orange),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _Clr.ink),
              textAlign: TextAlign.center),
          if (id != null) ...[
            const SizedBox(height: 6),
            Text('ID: $id', style: const TextStyle(fontSize: 11, color: _Clr.inkLight), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
              style: FilledButton.styleFrom(backgroundColor: _Clr.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
      child: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 44, height: 4,
              decoration: BoxDecoration(color: _Clr.border, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 22),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFF8E1), Color(0xFFFFF3CD)]),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _Clr.gold.withOpacity(0.4))),
              child: const Icon(Icons.workspace_premium_rounded, color: _Clr.goldDark, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Unlock Premium Course',
                  style: TextStyle(fontSize: 12, color: _Clr.inkLight, fontWeight: FontWeight.w600)),
              Text(widget.subjectName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _Clr.ink)),
            ])),
          ]),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_Clr.surfaceEgg, Colors.white]),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _Clr.border)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total Amount',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _Clr.inkMid)),
              Text('₹${widget.price.toInt()}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                      color: _Clr.primary, letterSpacing: -0.5)),
            ]),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF9FBF9), borderRadius: BorderRadius.circular(14)),
            child: const Column(children: [
              _FeatureRow(icon: Icons.play_circle_outline, text: 'Full video lesson access'),
              SizedBox(height: 8),
              _FeatureRow(icon: Icons.picture_as_pdf_outlined, text: 'All PDF exercise sheets'),
              SizedBox(height: 8),
              _FeatureRow(icon: Icons.quiz_outlined, text: 'Q&A bank with answers'),
              SizedBox(height: 8),
              _FeatureRow(icon: Icons.all_inclusive_rounded, text: 'Lifetime access — pay once'),
            ]),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : openCheckout,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _Clr.gold, foregroundColor: _Clr.dark,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0),
              child: _isProcessing
                  ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _Clr.dark))
                  : const Text('Pay Securely & Unlock Now',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FREE SUBJECT DETAILS SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class FreeSubjectDetailsScreen extends StatefulWidget {
  final String subjectId, subjectName;
  const FreeSubjectDetailsScreen({super.key, required this.subjectId, required this.subjectName});

  @override
  State<FreeSubjectDetailsScreen> createState() => _FreeSubjectDetailsScreenState();
}

class _FreeSubjectDetailsScreenState extends State<FreeSubjectDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _loadData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('syllabus_nodes').doc(widget.subjectId).get();
      if (mounted) setState(() { _data = doc.data() as Map<String, dynamic>?; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Clr.scaffoldBg,
      appBar: AppBar(
        backgroundColor: _Clr.dark, foregroundColor: Colors.white, elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            widget.subjectName,
            style: const TextStyle(
              color: Colors.white, // ✅ Added black color here
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const Text(
            'Subject Resources',
            style: TextStyle(fontSize: 11, color: Colors.white60),
          ),
        ]),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white, indicatorWeight: 3,
          labelColor: Colors.white, unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(icon: Icon(Icons.play_circle_outline, size: 18), text: 'Lessons'),
            Tab(icon: Icon(Icons.picture_as_pdf_outlined, size: 18), text: 'Exercises'),
            Tab(icon: Icon(Icons.quiz_outlined, size: 18), text: 'Q & A'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _Clr.primary))
          : _data == null
          ? const Center(child: Text('No resources found.', style: TextStyle(color: _Clr.inkLight)))
          : TabBarView(
        controller: _tabController,
        children: [_buildVideoTab(), _buildPdfTab(), _buildQnaTab()],
      ),
    );
  }

  Widget _buildVideoTab() {
    final data = _data!;
    final flatVideos = (data['videos'] as List<dynamic>? ?? [])
        .map((v) => Map<String, dynamic>.from(v as Map)).toList();
    final folders = (data['videoFolders'] as List<dynamic>? ?? [])
        .map((f) => Map<String, dynamic>.from(f as Map)).toList();
    final allFolders = [
      if (flatVideos.isNotEmpty) {'name': 'All Videos', 'videos': flatVideos},
      ...folders,
    ];
    if (allFolders.isEmpty) return const _ContentEmpty(
        icon: Icons.video_library_outlined, message: 'No video lessons available yet');
    return ListView.separated(
      padding: const EdgeInsets.all(16), itemCount: allFolders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final folder = allFolders[i];
        final videos = (folder['videos'] as List<dynamic>? ?? [])
            .map((v) => Map<String, dynamic>.from(v as Map)).toList();
        return _ContentFolderCard(
            folderName: folder['name'] ?? 'Folder', itemCount: videos.length,
            color: _Clr.red, icon: Icons.video_library_rounded,
            onTap: () => _pushFolderContent(
                title: folder['name'] ?? 'Folder', child: _VideoListContent(videos: videos)));
      },
    );
  }

  Widget _buildPdfTab() {
    final data = _data!;
    final flatPdfs = (data['pdfs'] as List<dynamic>? ?? [])
        .map((p) => Map<String, dynamic>.from(p as Map)).toList();
    final folders = (data['pdfFolders'] as List<dynamic>? ?? [])
        .map((f) => Map<String, dynamic>.from(f as Map)).toList();
    final allFolders = [
      if (flatPdfs.isNotEmpty) {'name': 'All PDFs', 'pdfs': flatPdfs},
      ...folders,
    ];
    if (allFolders.isEmpty) return const _ContentEmpty(
        icon: Icons.picture_as_pdf_outlined, message: 'No PDF exercises available yet');
    return ListView.separated(
      padding: const EdgeInsets.all(16), itemCount: allFolders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final folder = allFolders[i];
        final pdfs = (folder['pdfs'] as List<dynamic>? ?? [])
            .map((p) => Map<String, dynamic>.from(p as Map)).toList();
        return _ContentFolderCard(
            folderName: folder['name'] ?? 'Folder', itemCount: pdfs.length,
            color: _Clr.orange, icon: Icons.picture_as_pdf_rounded,
            onTap: () => _pushFolderContent(
                title: folder['name'] ?? 'Folder', child: _PdfListContent(pdfs: pdfs)));
      },
    );
  }

  Widget _buildQnaTab() {
    final data = _data!;
    final folders = (data['qnaFolders'] as List<dynamic>? ?? [])
        .map((f) => Map<String, dynamic>.from(f as Map)).toList();
    if (folders.isEmpty) return const _ContentEmpty(
        icon: Icons.quiz_outlined, message: 'No Q&A available yet');
    return ListView.separated(
      padding: const EdgeInsets.all(16), itemCount: folders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final folder = folders[i];
        final qnas = (folder['qnas'] as List<dynamic>? ?? [])
            .map((q) => Map<String, dynamic>.from(q as Map)).toList();
        return _ContentFolderCard(
            folderName: folder['name'] ?? 'Folder', itemCount: qnas.length,
            color: _Clr.teal, icon: Icons.quiz_rounded,
            onTap: () => _pushFolderContent(
                title: folder['name'] ?? 'Folder', child: _QnaListContent(qnas: qnas)));
      },
    );
  }

  void _pushFolderContent({required String title, required Widget child}) {
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => _FolderContentPage(title: title, child: child)));
  }
}

// ─── FOLDER CONTENT PAGE ─────────────────────────────────────────────────────

class _FolderContentPage extends StatelessWidget {
  final String title;
  final Widget child;
  const _FolderContentPage({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Clr.scaffoldBg,
      appBar: AppBar(
        backgroundColor: _Clr.dark, foregroundColor: Colors.white,
        leading: const BackButton(color: Colors.white),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const Text('Folder Contents', style: TextStyle(fontSize: 11, color: Colors.white60)),
        ]),
      ),
      body: child,
    );
  }
}

// ─── VIDEO / PDF / Q&A LIST CONTENTS ─────────────────────────────────────────

class _VideoListContent extends StatelessWidget {
  final List<Map<String, dynamic>> videos;
  const _VideoListContent({required this.videos});

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return const _ContentEmpty(
        icon: Icons.video_library_outlined, message: 'No videos in this folder');
    return ListView.separated(
      padding: const EdgeInsets.all(16), itemCount: videos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final v = videos[i];
        return _ResourceTile(
          icon: Icons.play_circle_filled_rounded, iconColor: _Clr.red,
          title: v['title'] ?? 'Video Lesson', subtitle: v['duration'] ?? 'N/A',
          onTap: () => Navigator.push(ctx, MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(url: v['url'], title: v['title']))),
        );
      },
    );
  }
}

class _PdfListContent extends StatelessWidget {
  final List<Map<String, dynamic>> pdfs;
  const _PdfListContent({required this.pdfs});

  @override
  Widget build(BuildContext context) {
    if (pdfs.isEmpty) return const _ContentEmpty(
        icon: Icons.picture_as_pdf_outlined, message: 'No PDFs in this folder');
    return ListView.separated(
      padding: const EdgeInsets.all(16), itemCount: pdfs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final p = pdfs[i];
        return _ResourceTile(
          icon: Icons.picture_as_pdf_rounded, iconColor: _Clr.orange,
          title: p['title'] ?? 'PDF Document', subtitle: p['fileName'] ?? '',
          onTap: () => Navigator.push(ctx, MaterialPageRoute(
              builder: (_) => PdfViewerScreen(url: p['url'], title: p['title']))),
        );
      },
    );
  }
}

class _QnaListContent extends StatelessWidget {
  final List<Map<String, dynamic>> qnas;
  const _QnaListContent({required this.qnas});

  @override
  Widget build(BuildContext context) {
    if (qnas.isEmpty) return const _ContentEmpty(
        icon: Icons.quiz_outlined, message: 'No questions in this folder');
    return ListView.separated(
      padding: const EdgeInsets.all(16), itemCount: qnas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final q = qnas[i];
        return _StudentQnaCard(index: i, question: q['question'] ?? '',
            answers: List<String>.from(q['answers'] ?? []));
      },
    );
  }
}

// ─── STUDENT Q&A CARD ─────────────────────────────────────────────────────────

class _StudentQnaCard extends StatefulWidget {
  final int index;
  final String question;
  final List<String> answers;
  const _StudentQnaCard({required this.index, required this.question, required this.answers});

  @override
  State<_StudentQnaCard> createState() => _StudentQnaCardState();
}

class _StudentQnaCardState extends State<_StudentQnaCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animCtrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _expandAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _animCtrl.forward() : _animCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _expanded ? _Clr.teal.withOpacity(0.4) : _Clr.border, width: 1.5),
          boxShadow: _expanded
              ? [BoxShadow(color: _Clr.teal.withOpacity(0.1), blurRadius: 14, offset: const Offset(0, 4))]
              : _cardShadow(),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_Clr.teal, Color(0xFF00695C)]),
                    borderRadius: BorderRadius.circular(9)),
                child: Center(child: Text('Q${widget.index + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(widget.question,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: _Clr.ink, height: 1.4))),
              const SizedBox(width: 8),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnim),
                child: const Icon(Icons.keyboard_arrow_down_rounded, color: _Clr.teal, size: 22),
              ),
            ]),
          ),
          if (!_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(58, 0, 16, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _Clr.teal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _Clr.teal.withOpacity(0.25))),
                child: Text('${widget.answers.length} answer${widget.answers.length == 1 ? '' : 's'}',
                    style: const TextStyle(fontSize: 11, color: _Clr.teal, fontWeight: FontWeight.w700)),
              ),
            ),
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Column(children: [
              const Divider(height: 1, color: _Clr.border),
              if (widget.answers.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('No answers added yet.',
                      style: TextStyle(color: _Clr.inkLight.withOpacity(0.6), fontSize: 13)),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: widget.answers.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          width: 22, height: 22,
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [_Clr.lighter, _Clr.primary]),
                              shape: BoxShape.circle),
                          child: Center(child: Text('${entry.key + 1}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(entry.value,
                            style: const TextStyle(fontSize: 13, color: _Clr.inkMid, height: 1.5))),
                      ]),
                    )).toList(),
                  ),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── YOUTUBE / PDF PLAYER SCREENS ─────────────────────────────────────────────

class VideoPlayerScreen extends StatefulWidget {
  final String url, title;
  const VideoPlayerScreen({super.key, required this.url, required this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.url) ?? '';
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black, foregroundColor: Colors.white,
        leading: const BackButton(color: Colors.white),
        title: Text(widget.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ),
      body: Center(child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: _Clr.primary)),
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String url, title;
  const PdfViewerScreen({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _Clr.dark, foregroundColor: Colors.white,
        leading: const BackButton(color: Colors.white),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
      ),
      body: SfPdfViewer.network(url),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  REMAINING SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _ContentBadge extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _ContentBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _ContentFolderCard extends StatelessWidget {
  final String folderName; final int itemCount;
  final Color color; final IconData icon; final VoidCallback onTap;
  const _ContentFolderCard({required this.folderName, required this.itemCount,
    required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.25)),
            boxShadow: [BoxShadow(color: color.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))]),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.09)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(folderName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _Clr.ink)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('$itemCount item${itemCount == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
              ),
            ])),
            Icon(Icons.arrow_forward_ios_rounded, size: 15, color: color.withOpacity(0.7)),
          ]),
        ),
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  final IconData icon; final Color iconColor;
  final String title, subtitle; final VoidCallback onTap;
  const _ResourceTile({required this.icon, required this.iconColor,
    required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _Clr.border), boxShadow: _cardShadow()),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _Clr.ink)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: _Clr.inkLight)),
          trailing: Icon(Icons.chevron_right_rounded, color: iconColor.withOpacity(0.6)),
        ),
      ),
    );
  }
}

class _ContentEmpty extends StatelessWidget {
  final IconData icon; final String message;
  const _ContentEmpty({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(color: _Clr.surfaceEgg, shape: BoxShape.circle),
            child: Icon(icon, size: 44, color: _Clr.border)),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: _Clr.inkLight, fontSize: 14, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon; final String text;
  const _FeatureRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 28, height: 28,
          decoration: BoxDecoration(color: _Clr.surfaceEgg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 15, color: _Clr.primary)),
      const SizedBox(width: 10),
      Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _Clr.inkMid)),
    ]);
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon; final String label, value;
  const _ProfileRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Container(width: 36, height: 36,
            decoration: const BoxDecoration(color: _Clr.surfaceEgg,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Icon(icon, color: _Clr.primary, size: 16)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10, color: _Clr.inkLight, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _Clr.ink)),
        ])),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String value, label; final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _Clr.border), boxShadow: _cardShadow()),
      child: Column(children: [
        Container(width: 38, height: 38,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: _Clr.inkLight, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
