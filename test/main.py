import sys

from PySide6.QtWidgets import QApplication

from fluentqml import FluentQMLWindow, Theme

if __name__ == "__main__":
    app = QApplication(sys.argv)

    window2 = FluentQMLWindow("test3.qml")
    window2.setTheme(Theme.Auto)

    sys.exit(app.exec())
