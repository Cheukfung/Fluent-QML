from PySide6.QtCore import Qt
from PySide6.QtGui import QGuiApplication

# HiDPI support: keep fractional scale factors to avoid blurry text.
if hasattr(Qt, "HighDpiScaleFactorRoundingPolicy"):
	QGuiApplication.setHighDpiScaleFactorRoundingPolicy(
		Qt.HighDpiScaleFactorRoundingPolicy.PassThrough
	)

from . import fluentqml_rc
from .core import *

__version__ = "0.3.0"
__author__ = "Cheukfung"
