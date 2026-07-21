import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:online_course/core/utils/app_constant.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();

  factory PaymentService() {
    return _instance;
  }

  PaymentService._internal();

  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onFailure;
  Function(ExternalWalletResponse)? onExternalWallet;

  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _razorpay = Razorpay();
    this.onSuccess = onSuccess;
    this.onFailure = onFailure;
    this.onExternalWallet = onExternalWallet;

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  Future<void> openCheckout({
    required String name,
    required String description,
    required int amount, // In INR (not paise)
    String? orderId,
  }) async {
    final options = {
      'key': AppConstant.razorpayKeyId,
      'amount': amount * 100, // Converts INR to Paise
      'name': name,
      'description': description,
      'order_id': orderId,
      'theme': {'color': '#1A56DB'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error opening Razorpay checkout: $e");
    }
  }

  Future<String?> createOrder(int amount) async {
    try {
      debugPrint("--- CUSTOM RAZORPAY DEBUG ---");
      debugPrint("Attempting order creation for amount: ₹$amount");
      
      // 1. TRY BACKEND FIRST (RECOMMENDED)
      final response = await http.post(
        Uri.parse(AppConstant.razorpayOrderUrl),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: json.encode({'amount': amount, 'currency': 'INR'}),
      );

      debugPrint("Backend Status: ${response.statusCode}");
      debugPrint("Backend Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return data['order']['id'];
      }
      
      // 2. FALLBACK: DIRECT RAZORPAY API CALL (Bypassing potentially broken backend)
      debugPrint("Fallback to Direct Razorpay API...");
      final auth = 'Basic ${base64Encode(utf8.encode('${AppConstant.razorpayKeyId}:${AppConstant.razorpayKeySecret}'))}';
      
      final directResponse = await http.post(
        Uri.parse('https://api.razorpay.com/v1/orders'),
        headers: {
          'Authorization': auth,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount * 100, // INR to Paise
          'currency': 'INR',
          'receipt': 'receipt_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      debugPrint("Direct API Status: ${directResponse.statusCode}");
      debugPrint("Direct API Body: ${directResponse.body}");

      if (directResponse.statusCode >= 200 && directResponse.statusCode < 300) {
        final data = json.decode(directResponse.body);
        return data['id'];
      }
    } catch (e) {
      debugPrint("CRITICAL ERROR in Order Creation: $e");
    }
    return null;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onFailure?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onExternalWallet?.call(response);
  }
}
