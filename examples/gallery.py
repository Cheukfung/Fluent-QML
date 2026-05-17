import sys
from datetime import datetime
from pathlib import Path

import gallery_rc  # noqa: F401
from PySide6.QtCore import QLocale, QObject, Qt, QTranslator, Slot
from PySide6.QtGui import QGuiApplication
from PySide6.QtWidgets import QApplication

import fluentqml
from config import cfg
from fluentqml import FluentQMLTranslator, FluentQMLWindow, __version__

SCRIPT_DIR = Path(__file__).parent.absolute()
PROJECT_ROOT = SCRIPT_DIR.parent
GALLERY_RESOURCE_PREFIX = "qrc:/FluentQMLGallery"
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))


class Gallery(FluentQMLWindow):
    def __init__(self):
        super().__init__(f"{GALLERY_RESOURCE_PREFIX}/gallery.qml")
        self.setIcon(f"{GALLERY_RESOURCE_PREFIX}/assets/gallery.png")

        self.backend = Backend()
        self.backend.setBackendParent(self)
        self.setProperty(
            "title", f"FluentQML Gallery {datetime.now().year}"
        )  # 前后端交互示例

        self.engine.rootContext().setContextProperty("Backend", self.backend)  # 注入


class Backend(QObject):
    def setBackendParent(self, parent):
        self.parent = parent

    @Slot(result=str)
    def getVersion(self):
        return __version__

    @Slot(str)
    def copyToClipboard(self, text):
        clipboard = QGuiApplication.clipboard()
        clipboard.setText(text)
        print(f"Copied: {text}")

    @Slot(result=str)
    def getLanguage(self):
        return cfg["language"]

    @Slot(result=str)
    def getSystemLanguage(self):
        return QLocale.system().name()

    @Slot(str)
    def setLanguage(self, lang: str):  # sample: zh_CN; en_US
        global ui_translator, translator

        cfg["language"] = lang
        cfg.save_config()
        ui_translator = FluentQMLTranslator(QLocale(lang))
        translator = QTranslator()
        translator.load(f":/FluentQMLGallery/languages/{lang}.qm")
        QApplication.instance().removeTranslator(ui_translator)
        QApplication.instance().removeTranslator(translator)
        QApplication.instance().installTranslator(ui_translator)
        QApplication.instance().installTranslator(translator)
        self.parent.engine.retranslate()


if __name__ == "__main__":
    print(fluentqml.__file__)
    QGuiApplication.setHighDpiScaleFactorRoundingPolicy(
        Qt.HighDpiScaleFactorRoundingPolicy.PassThrough
    )
    app = QApplication(sys.argv)

    # i18n
    lang = cfg["language"]
    ui_translator = FluentQMLTranslator(QLocale(lang))
    app.installTranslator(ui_translator)
    translator = QTranslator()
    if translator.load(f":/FluentQMLGallery/languages/{lang}.qm"):
        app.installTranslator(translator)

    gallery = Gallery()

    app.aboutToQuit.connect(cfg.save_config)
    app.exec()
    # app = QGuiApplication([])

    # 创建 QML 引擎
    # engine = QQmlApplicationEngine()
    # # engine.addImportPath(str(Path(__file__).parent.parent / "fluentqml"))
    # print(engine.importPathList())
    #
    # # 加载 QML 文件
    # engine.load("gallery.qml")
    #
    #
    # # 启动应用
    # app.exec()
    # create_qml_app("gallery.qml")
