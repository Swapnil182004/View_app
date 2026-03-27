import os

directory = 'lib'
replacements = {
    '0xFFFF8A00': '0xFF2563EB',
    '0xFF1E8E3E': '0xFF1A56DB',
    '0xFF34C48E': '0xFF60A5FA',
    '0xFF145F29': '0xFF1E40AF',
    '0xFFE67E22': '0xFF1D4ED8',
    '0xFFFFBE66': '0xFF93C5FD',
    '0xFF087A54': '0xFF1A56DB'
}

count = 0
for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content = content
            for old_hex, new_hex in replacements.items():
                new_content = new_content.replace(old_hex, new_hex)
            
            if new_content != content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                count += 1
                print(f"Updated {filepath}")

print(f"Total files updated: {count}")
