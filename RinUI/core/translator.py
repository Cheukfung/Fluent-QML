from typing import Union

from PySide6.QtCore import QLocale, QTranslator

from .config import RINUI_RESOURCE_PREFIX


class RinUITranslator(QTranslator):
    """
    RinUI i18n translator.
    :param locale: QLocale, optional, default is system locale
    """

    def __init__(
        self, locale: QLocale = QLocale.system().name(), parent=None
    ):  # follow system
        super().__init__(parent)
        self.load(locale or QLocale())

    def load(self, locale: Union[QLocale, str]) -> bool:
        """
        Load translation file for the given locale.
        :param locale: QLocale, the locale to load (eg = QLocale(QLocale.Chinese, QLocale.China), QLocale("zh_CN"))
        :return: bool
        """
        qlocale = locale if isinstance(locale, QLocale) else QLocale(locale)
        print(f"🌏 Current locale: {qlocale.name()}")
        path = f"{RINUI_RESOURCE_PREFIX}/languages/{qlocale.name()}.qm"
        if not super().load(path):
            print(f'Language file "{path}" not found. Fallback to default (en_US)')
            path = f"{RINUI_RESOURCE_PREFIX}/languages/en_US.qm"
            QLocale().setDefault(QLocale("en_US"))
            loaded = super().load(path)
        else:
            loaded = True

        QLocale().setDefault(qlocale)
        return loaded
