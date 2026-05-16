cd ..
.venv\Scripts\pyinstaller.exe ^
  --icon=examples/assets/gallery.ico ^
  --noconsole ^
  --contents-directory="." ^
  --add-data="fluentqml;fluentqml" ^
  --add-data="examples/assets;assets" ^
  --add-data="examples/components;components" ^
  --add-data="examples/languages;languages" ^
  --add-data="examples/pages;pages" ^
  --add-data="examples/gallery.qml;." ^
  --paths=. ^
  examples/gallery.py
