import os

dir_path = r"c:\Users\SWAPNIL\Documents\Digontom Projects\OnlineTeachingApp-main\lib"
print(f"Starting in {dir_path}")
count = 0
for root, dirs, files in os.walk(dir_path):
    for f in files:
        if f.endswith('.dart') and 'theme.dart' not in f and 'app_color.dart' not in f:
            path = os.path.join(root, f)
            try:
                with open(path, 'r', encoding='utf-8') as file:
                    content = file.read()
                if '0xFF1E8E3E' in content or '0xFF34C48E' in content:
                    content = content.replace('0xFF1E8E3E', '0xFF1A56DB')
                    content = content.replace('0xFF34C48E', '0xFF60A5FA')
                    with open(path, 'w', encoding='utf-8') as file:
                        file.write(content)
                    count += 1
            except Exception as e:
                print(f"Error {path}: {e}")
print(f"Replaced in {count} files")
