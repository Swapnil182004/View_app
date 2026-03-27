import 'dart:convert';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_course/src/features/course/data/datasources/account_courses_list.dart';
import 'package:online_course/src/features/course/data/models/section.model.dart';
import 'package:online_course/src/features/course/domain/entities/course.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:rive/rive.dart';
import 'package:http/http.dart' as http;

class CourseDetailBottomBlock extends StatefulWidget {
  const CourseDetailBottomBlock({
    required this.course,
    super.key,
    required this.sectionList,
  });

  final Course course;
  final List<Section> sectionList;

  @override
  State<CourseDetailBottomBlock> createState() =>
      _CourseDetailBottomBlockState();
}

class _CourseDetailBottomBlockState extends State<CourseDetailBottomBlock> {
  late Razorpay _razorpay;

  Map<int, String> pricing = {};
  List<String> selectedForPayment = [];
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
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout(String? pricee) async {
    if (pricee == null) {
      return;
    }

    int price = int.parse(pricee.toString());
    String? orderId = await createRazorpayOrder(price);

    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error: unable to create order'),
          backgroundColor: const Color(0xFFE67E22), // ✅ Orange error
        ),
      );
      return;
    }

    var options = {
      'key': 'rzp_live_q05lvifSYOtDJ7',
      'order_id': orderId,
      'amount': price * 100,
      'name': 'Examplan B',
      'image': 'assets/images/examplan_b_logo.png',
      'description': 'Online Course',
      'theme': {'color': '#305CDE'} // ✅ Emerald Green
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  Future<String?> createRazorpayOrder(int amount) async {
    try {
      var headersList = {
        'Accept': '*/*',
        'User-Agent': 'Flutter Client',
        'Content-Type': 'application/json'
      };

      var body = json.encode({"amount": amount, "currency": "INR"});

      var response = await http.post(
        Uri.parse('https://createrazorpayorder-ebwzua76iq-uc.a.run.app'),
        headers: headersList,
        body: body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        var responseData = json.decode(response.body);
        var orderId = responseData['order']['id'];
        print("Order ID: $orderId");
        return orderId;
      } else {
        print("Error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      _isProcessing = true;
    });

    int status = await addOrUpdateCourse(widget.course.id, selectedForPayment);

    if (status == 200) {
      _showResponse('Payment Successful', response.paymentId);
    } else {
      _showResponse('Payment Failed', response.paymentId);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showResponse('Payment Error', response.message);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showResponse('External wallets are not allowed', null);
  }

  void _showResponse(String status, String? paymentId) {
    setState(() => _isProcessing = false);
    showFlexibleBottomSheet(
      minHeight: 0,
      initHeight: 0.5,
      maxHeight: 1,
      context: context,
      builder: (context, scrollController, bottomSheetOffset) {
        return _buildBottomSheet(context, status, paymentId);
      },
      anchors: [0, 0.5, 1],
      isSafeArea: true,
    );
  }

  Widget _buildBottomSheet(BuildContext context, String message, [String? paymentId]) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          // ✅ FIX: Wrapped Column with SingleChildScrollView to prevent overflow
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success/Error Animation
                SizedBox(
                  height: 180, // Slightly reduced height to save space safely
                  width: 180,
                  child: message.contains('Successful')
                      ? const RiveAnimation.asset('assets/anim/succes.riv')
                      : Container(
                    decoration: BoxDecoration(
                      color: message.contains('Successful')
                          ? const Color(0xFFE8ECF9) // ✅ Light green
                          : const Color(0xFFFFE8DD), // ✅ Light orange
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      message.contains('Successful')
                          ? Icons.check_circle
                          : Icons.error_outline,
                      size: 100,
                      color: message.contains('Successful')
                          ? const Color(0xFF1A56DB) // ✅ Emerald
                          : const Color(0xFFE67E22), // ✅ Orange
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Status Message
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Payment ID
                if (paymentId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Payment ID',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF757575),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          paymentId,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4ED8), // 🔵 Standard
                      foregroundColor: Colors.white, // ✅ White text
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  @override
  Widget build(BuildContext context) {
    bool isloading = false;

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: !_isProcessing
            ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Price Info
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Price",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${widget.course.price}',
                  style: const TextStyle(
                    fontSize: 26,
                    color: Color(0xFF1A56DB), // ✅ Emerald Green
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),

            // Buy Button - Golden with Green Text
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Purchase Option',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Choose a section or buy the complete course',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF757575),
                                ),
                              ),
                              const SizedBox(height: 20),
                              !isloading
                                  ? Column(
                                children: widget.sectionList.map((Section section) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFE0E0E0),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () async {
                                          if (section.title == "All") {
                                            selectedForPayment.addAll(widget.sectionList
                                                .map((section) =>
                                            widget.course.id.toString() +
                                                section.title.toLowerCase()));
                                            openCheckout(widget.course.price);
                                          } else {
                                            isloading = true;
                                            isloading = false;
                                            selectedForPayment.add(
                                                widget.course.id.toString() +
                                                    section.title.toLowerCase());
                                            openCheckout(section.price);
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      section.title,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFF1A1A1A),
                                                      ),
                                                    ),
                                                    if (section.title == "All")
                                                      const Text(
                                                        'Complete course access',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Color(0xFF757575),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '₹${section.title == "All" ? widget.course.price : section.price}',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1A56DB), // ✅ Emerald
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                                  : const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF1A56DB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8), // 🔵 Standard Blue
                  foregroundColor: Colors.white, // ✅ White Text
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  shadowColor: const Color(0xFF1D4ED8).withOpacity(0.4),
                ),
                child: const Text(
                  "Buy Now",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        )
            : const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1A56DB), // ✅ Emerald Green
          ),
        ),
      ),
    );
  }

  Future<void> getPrice() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('id', isEqualTo: widget.course.id)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs[0].data() as Map<String, dynamic>;

      (data['pricing'] as Map<dynamic, dynamic>).forEach((key, value) {
        pricing[int.parse(key)] = value as String;
      });

      setState(() {});
      print(pricing);
    }
  }
}
