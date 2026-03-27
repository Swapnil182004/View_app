import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/foundation.dart';

class QRScannerScreen extends StatefulWidget {
  final String videoId;
  const QRScannerScreen({super.key, required this.videoId});
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  // QRViewController? controller;
  bool isScanned = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (status.isGranted) {
      // Permission granted, allow camera access
      setState(() {});
    } else {
      // Permission denied, show message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Camera permission is required to scan QR codes.")),
      );
    }
  }

  // void _onQRViewCreated(QRViewController controller) {
  //   this.controller = controller;
  //   controller.scannedDataStream.listen((scanData) async {
  //     if (!isScanned) {
  //       setState(() {
  //         isScanned = true; // Ensure QR is scanned only once
  //       });
  //       String qrCodeValue = scanData.code!;

  //       // Assuming the QR code contains the document ID or quickshare code
  //       await _updateQuickshareWithVideoId(qrCodeValue);
  //     }
  //   });
  // }

  Future<void> _updateQuickshareWithVideoId(String qrString) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference docRef =
          firestore.collection('quickshares').doc(qrString);

      // Simulate sharing the videoId
      // Replace with actual videoId logic

      // Update Firestore document
      await docRef.set({
        'videoId': widget.videoId,
        'status': true,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Video ID shared successfully!")),
      );

      Navigator.pop(context);

      setState(() {
        isScanned = false; // Allow scanning again
      });
    } catch (e) {
      debugPrint("Error updating Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to share Video ID. Please try again.")),
      );
      setState(() {
        isScanned = false; // Reset scanning state on failure
      });
    }
  }

  @override
  void dispose() {
    // controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code Scanner"),
      ),
      body: FutureBuilder(
        future: Permission.camera.status,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == PermissionStatus.granted) {
              return Column(
                children: <Widget>[
                  // Expanded(
                  //   flex: 5,
                  //   child: QRView(
                  //     key: qrKey,
                  //     onQRViewCreated: _onQRViewCreated,
                  //   ),
                  // ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: (isScanned)
                          ? const Text("QR Code Scanned!")
                          : const Text("Scan a QR Code"),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text("Camera permission is not granted."),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
