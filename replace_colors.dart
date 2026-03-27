import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  for (final file in files) {
    if (file.path.contains('theme.dart') || file.path.contains('app_color.dart')) continue;
    
    try {
      String content = file.readAsStringSync();
      String newContent = content
          .replaceAll('0xFF1E8E3E', '0xFF1A56DB')
          .replaceAll('0xFF34C48E', '0xFF60A5FA')
          .replaceAll('0xFF087A54', '0xFF1E40AF')
          .replaceAll('0xff1e8e3e', '0xFF1A56DB')
          .replaceAll('0xff34c48e', '0xFF60A5FA')
          .replaceAll('0xff087a54', '0xFF1E40AF');
          
      if (content != newContent) {
        file.writeAsStringSync(newContent);
        print('Updated ${file.path}');
      }
    } catch (e) {
      print('Error on ${file.path}: $e');
    }
  }
}
