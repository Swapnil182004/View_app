import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';



/// Represents PdfViewer for Navigation
class PdfViewer extends StatefulWidget {
  final String url;

  const PdfViewer({super.key, required this.url});
  @override
  _PdfViewer createState() => _PdfViewer();
}

class _PdfViewer extends State<PdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final _noScreenshot = NoScreenshot.instance;

  @override
  void initState() {
    super.initState();
    _preventScreenShot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: Colors.white,
              semanticLabel: 'Bookmark',
            ),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.url,
      
      ),
    );
  }
  void _preventScreenShot() async{
    final result = await _noScreenshot.screenshotOff();
    print(result);
  }
}
