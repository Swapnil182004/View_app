import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));
      
  int count = 0;
  for (var file in files) {
    try {
      var content = file.readAsStringSync();
      var newContent = content
        .replaceAll('0xFFFF8A00', '0xFF2563EB')
        .replaceAll('0xFF1E8E3E', '0xFF1A56DB')
        .replaceAll('0xFF34C48E', '0xFF60A5FA')
        .replaceAll('0xFF145F29', '0xFF1E40AF')
        .replaceAll('0xFFE67E22', '0xFF1D4ED8')
        .replaceAll('0xFFFFBE66', '0xFF93C5FD')
        .replaceAll('0xFF087A54', '0xFF1A56DB');
        
      if (content != newContent) {
        file.writeAsStringSync(newContent);
        print('Updated ${file.path}');
        count++;
      }
    } catch (e) {
      print('Error on ${file.path}: $e');
    }
  }
  print('Total files updated native: $count');
}
