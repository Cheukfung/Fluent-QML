from __future__ import annotations

import random

from PySide6.QtCore import Property, QPoint, QPointF, QRectF, Qt, Signal, Slot
from PySide6.QtGui import (
    QColor,
    QGuiApplication,
    QImage,
    QPainter,
    QPainterPath,
    QPixmap,
)
from PySide6.QtQuick import QQuickPaintedItem


class AcrylicItem(QQuickPaintedItem):
    """Paints a snapshot-based acrylic material for QML controls."""

    blurRadiusChanged = Signal()
    maxBlurSizeChanged = Signal()
    radiusChanged = Signal()
    tintColorChanged = Signal()
    luminosityColorChanged = Signal()
    noiseOpacityChanged = Signal()
    borderColorChanged = Signal()
    borderWidthChanged = Signal()
    errorStringChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setAntialiasing(True)
        self.setOpaquePainting(False)
        self._blur_radius = 30
        self._max_blur_size = 450
        self._radius = 8.0
        self._tint_color = QColor(255, 255, 255, 178)
        self._luminosity_color = QColor(255, 255, 255, 46)
        self._noise_opacity = 0.03
        self._border_color = QColor(0, 0, 0, 16)
        self._border_width = 1.0
        self._error_string = ""
        self._blurred_pixmap = QPixmap()
        self._noise_image = self._create_noise_image()
        self.widthChanged.connect(self._clear_cache)
        self.heightChanged.connect(self._clear_cache)

    def _clear_cache(self):
        self._blurred_pixmap = QPixmap()
        self.update()

    @Slot()
    def refresh(self):
        platform_name = QGuiApplication.platformName()
        if platform_name in {"offscreen", "minimal", "minimalegl"}:
            self._set_error(
                f'Cannot refresh acrylic on the "{platform_name}" Qt platform.'
            )
            return

        window = self.window()
        if window is None:
            self._set_error("Cannot refresh acrylic before the item has a window.")
            return

        width = max(1, round(self.width()))
        height = max(1, round(self.height()))
        scene_pos = self.mapToScene(QPointF(0, 0))
        global_pos = window.mapToGlobal(
            QPoint(round(scene_pos.x()), round(scene_pos.y()))
        )

        screen = QGuiApplication.screenAt(global_pos) or window.screen()
        if screen is None:
            self._set_error("Cannot refresh acrylic because no screen is available.")
            return

        screen_geometry = screen.geometry()
        pixmap = screen.grabWindow(
            0,
            global_pos.x() - screen_geometry.x(),
            global_pos.y() - screen_geometry.y(),
            width,
            height,
        )
        if pixmap.isNull():
            self._set_error("Cannot refresh acrylic because screen capture failed.")
            return

        self._set_error("")
        self._blurred_pixmap = self._blur_pixmap(self._scaled_for_blur(pixmap))
        self.update()

    def paint(self, painter: QPainter):
        bounds = QRectF(0, 0, self.width(), self.height())
        if bounds.isEmpty():
            return

        painter.save()
        painter.setRenderHint(QPainter.Antialiasing, True)
        clip_path = QPainterPath()
        clip_path.addRoundedRect(bounds, self._radius, self._radius)
        painter.setClipPath(clip_path)

        if not self._blurred_pixmap.isNull():
            painter.drawPixmap(
                bounds, self._blurred_pixmap, QRectF(self._blurred_pixmap.rect())
            )

        painter.fillRect(bounds, self._luminosity_color)
        painter.fillRect(bounds, self._tint_color)
        painter.setOpacity(self._noise_opacity)
        painter.drawTiledPixmap(bounds, QPixmap.fromImage(self._noise_image))
        painter.setOpacity(1)

        if self._border_width > 0:
            pen = painter.pen()
            pen.setColor(self._border_color)
            pen.setWidthF(self._border_width)
            painter.setPen(pen)
            painter.setBrush(Qt.NoBrush)
            inset = self._border_width / 2
            border_rect = bounds.adjusted(inset, inset, -inset, -inset)
            painter.drawRoundedRect(border_rect, self._radius, self._radius)

        painter.restore()

    def _scaled_for_blur(self, pixmap: QPixmap) -> QPixmap:
        if self._max_blur_size <= 0:
            return pixmap

        size = pixmap.size()
        longest_side = max(size.width(), size.height())
        if longest_side <= self._max_blur_size:
            return pixmap

        return pixmap.scaled(
            self._max_blur_size,
            self._max_blur_size,
            Qt.KeepAspectRatio,
            Qt.SmoothTransformation,
        )

    def _blur_pixmap(self, pixmap: QPixmap) -> QPixmap:
        if self._blur_radius <= 0:
            return pixmap

        source_size = pixmap.size()
        blur_scale = max(0.08, min(0.85, 1 / (1 + self._blur_radius / 6)))
        small_width = max(1, round(source_size.width() * blur_scale))
        small_height = max(1, round(source_size.height() * blur_scale))
        passes = max(1, min(4, self._blur_radius // 12 + 1))

        image = pixmap.toImage().convertToFormat(QImage.Format_ARGB32_Premultiplied)
        for _ in range(passes):
            image = image.scaled(
                small_width,
                small_height,
                Qt.IgnoreAspectRatio,
                Qt.SmoothTransformation,
            ).scaled(
                source_size,
                Qt.IgnoreAspectRatio,
                Qt.SmoothTransformation,
            )

        return QPixmap.fromImage(image)

    def _create_noise_image(self) -> QImage:
        image = QImage(64, 64, QImage.Format_ARGB32_Premultiplied)
        rng = random.Random(20260522)
        for y in range(image.height()):
            for x in range(image.width()):
                value = rng.randrange(176, 256)
                image.setPixelColor(x, y, QColor(value, value, value, 255))
        return image

    def _set_error(self, message: str):
        if self._error_string == message:
            return
        self._error_string = message
        self.errorStringChanged.emit()

    def getBlurRadius(self):
        return self._blur_radius

    def setBlurRadius(self, value):
        value = max(0, int(value))
        if self._blur_radius == value:
            return
        self._blur_radius = value
        self._clear_cache()
        self.blurRadiusChanged.emit()

    def getMaxBlurSize(self):
        return self._max_blur_size

    def setMaxBlurSize(self, value):
        value = max(1, int(value))
        if self._max_blur_size == value:
            return
        self._max_blur_size = value
        self._clear_cache()
        self.maxBlurSizeChanged.emit()

    def getRadius(self):
        return self._radius

    def setRadius(self, value):
        value = max(0.0, float(value))
        if self._radius == value:
            return
        self._radius = value
        self.update()
        self.radiusChanged.emit()

    def getTintColor(self):
        return self._tint_color

    def setTintColor(self, value):
        color = QColor(value)
        if self._tint_color == color:
            return
        self._tint_color = color
        self.update()
        self.tintColorChanged.emit()

    def getLuminosityColor(self):
        return self._luminosity_color

    def setLuminosityColor(self, value):
        color = QColor(value)
        if self._luminosity_color == color:
            return
        self._luminosity_color = color
        self.update()
        self.luminosityColorChanged.emit()

    def getNoiseOpacity(self):
        return self._noise_opacity

    def setNoiseOpacity(self, value):
        value = min(1.0, max(0.0, float(value)))
        if self._noise_opacity == value:
            return
        self._noise_opacity = value
        self.update()
        self.noiseOpacityChanged.emit()

    def getBorderColor(self):
        return self._border_color

    def setBorderColor(self, value):
        color = QColor(value)
        if self._border_color == color:
            return
        self._border_color = color
        self.update()
        self.borderColorChanged.emit()

    def getBorderWidth(self):
        return self._border_width

    def setBorderWidth(self, value):
        value = max(0.0, float(value))
        if self._border_width == value:
            return
        self._border_width = value
        self.update()
        self.borderWidthChanged.emit()

    def getErrorString(self):
        return self._error_string

    blurRadius = Property(int, getBlurRadius, setBlurRadius, notify=blurRadiusChanged)
    maxBlurSize = Property(
        int, getMaxBlurSize, setMaxBlurSize, notify=maxBlurSizeChanged
    )
    radius = Property(float, getRadius, setRadius, notify=radiusChanged)
    tintColor = Property(QColor, getTintColor, setTintColor, notify=tintColorChanged)
    luminosityColor = Property(
        QColor,
        getLuminosityColor,
        setLuminosityColor,
        notify=luminosityColorChanged,
    )
    noiseOpacity = Property(
        float,
        getNoiseOpacity,
        setNoiseOpacity,
        notify=noiseOpacityChanged,
    )
    borderColor = Property(
        QColor, getBorderColor, setBorderColor, notify=borderColorChanged
    )
    borderWidth = Property(
        float, getBorderWidth, setBorderWidth, notify=borderWidthChanged
    )
    errorString = Property(str, getErrorString, notify=errorStringChanged)
