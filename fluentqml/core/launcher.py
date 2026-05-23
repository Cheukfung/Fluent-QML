import sys
from ctypes import c_void_p
from pathlib import Path
from typing import Optional, Union

from PySide6.QtCore import QCoreApplication, QObject, QTimer, QUrl
from PySide6.QtGui import QIcon
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType
from PySide6.QtQuick import QQuickWindow
from PySide6.QtWidgets import QApplication

from .acrylic import AcrylicItem
from .config import FLUENTQML_QML_IMPORT_PATH, BackdropEffect, Theme, is_windows
from .theme import ThemeManager

qmlRegisterType(AcrylicItem, "FluentQML", 1, 0, "AcrylicItem")


def _ascii(s) -> str:
    try:
        return str(s).encode("ascii", "backslashreplace").decode("ascii")
    except Exception:
        try:
            return repr(s).encode("ascii", "backslashreplace").decode("ascii")
        except Exception:
            return ""


class FluentQMLWindow:
    def __init__(self, qml_path: Optional[Union[str, Path]] = None):
        """
        Create an application window with FluentQML.
        If qml_path is provided, it will automatically load the specified QML file.
        :param qml_path: str or Path, QML file path (eg = "path/to/main.qml")
        """
        super().__init__()
        self.windows: list[QQuickWindow] = []
        if hasattr(self, "_initialized") and self._initialized:
            return

        self.root_window: Optional[QObject] = None
        self.engine = QQmlApplicationEngine()
        self.theme_manager = ThemeManager()
        self.win_event_filter = None
        self.win_event_manager = None
        self._mac_objc = None
        self._mac_appkit = None
        # Fine-tune native macOS traffic-light position.
        self._mac_traffic_lights_offset_x = 10
        self._mac_traffic_lights_offset_down = 10
        self._mac_traffic_lights_right_margin = 20
        self._mac_traffic_lights_retry_interval_ms = 50
        self._mac_traffic_lights_max_retries = 8
        self._mac_traffic_lights_original_y = {}
        self.qml_path = qml_path
        self._initialized = True

        print("FluentQMLWindow Initializing")

        # 退出清理
        app_instance = QCoreApplication.instance()
        if not app_instance:
            msg = "QApplication must be created before FluentQMLWindow."
            raise RuntimeError(msg)

        app_instance.aboutToQuit.connect(self.theme_manager.clean_up)

        if qml_path is not None:
            self.load(qml_path)

    def load(self, qml_path: Optional[Union[str, Path]] = None) -> None:
        """
        Load the QML file and set up the application window.
        :param qml_path:
        :return:
        """
        # FluentQML 模块
        print("UI Module Path: " + _ascii(FLUENTQML_QML_IMPORT_PATH))

        if qml_path is None:
            msg = "QML path must be provided to load the window."
            raise ValueError(msg)
        qml_url = QUrl(str(qml_path))
        if qml_url.scheme() == "qrc":
            self.engine.addImportPath(FLUENTQML_QML_IMPORT_PATH)
            self.qml_path = qml_url
        else:
            self.qml_path = Path(qml_path)
            if not self.qml_path.exists():
                msg = f"Cannot find QML file: {self.qml_path}"
                raise FileNotFoundError(msg)
            self.engine.addImportPath(FLUENTQML_QML_IMPORT_PATH)

        # 主题管理器
        self.engine.rootContext().setContextProperty("ThemeManager", self.theme_manager)
        try:
            self.engine.load(self.qml_path)
        except Exception as e:
            print("Cannot Load QML file: " + _ascii(e))

        if not self.engine.rootObjects():
            msg = "Error loading QML file: " + _ascii(self.qml_path)
            raise RuntimeError(msg)

        # 窗口设置
        root_window = self.engine.rootObjects()[0]
        self.root_window = root_window
        all_windows = [root_window] + root_window.findChildren(QQuickWindow)
        self.windows = [w for w in all_windows if w.property("isFluentQMLWindow")]

        for window in self.windows:
            self.theme_manager.set_window(window)

        # 窗口句柄管理
        self._window_handle_setup()
        self._setup_macos_native_window()

        self._print_startup_info()

    def _window_handle_setup(self) -> None:
        """
        set up the window handle. (Only available on Windows platform)
        :return:
        """
        if not is_windows():
            return

        from .window import WinEventFilter, WinEventManager

        self.win_event_manager = WinEventManager()
        self.win_event_filter = WinEventFilter(self.windows, self.win_event_manager)

        app_instance = QApplication.instance()
        app_instance.installNativeEventFilter(self.win_event_filter)
        self.engine.rootContext().setContextProperty(
            "WinEventManager", self.win_event_manager
        )
        self._apply_windows_effects()

    def _setup_macos_native_window(self) -> None:
        """Apply macOS native titlebar tweaks for custom title content."""
        if sys.platform != "darwin":
            return
        if QApplication.platformName() != "cocoa":
            return

        try:
            import AppKit
            import objc
        except Exception as err:
            print("Cannot enable native macOS titlebar integration: " + _ascii(err))
            self._disable_native_mac_frame()
            return

        self._mac_appkit = AppKit
        self._mac_objc = objc

        for window in self.windows:
            if not window.property("useNativeMacFrame"):
                continue

            self._apply_macos_window_style(window)
            effect_type = (
                self.theme_manager.get_backdrop_effect() or BackdropEffect.None_.value
            )
            self.theme_manager.apply_backdrop_effect(effect_type)
            window.visibleChanged.connect(
                lambda visible, w=window: self._on_macos_window_visible_changed(
                    w, visible
                )
            )
            window.widthChanged.connect(
                lambda *_, w=window: self._on_macos_window_width_changed(w)
            )
            window.heightChanged.connect(
                lambda *_, w=window: self._on_macos_window_width_changed(w)
            )
            alignment_changed = getattr(
                window, "macTrafficLightsRightAlignedChanged", None
            )
            if alignment_changed:
                alignment_changed.connect(
                    lambda *_, w=window: self._on_macos_window_width_changed(w)
                )

    def _on_macos_window_visible_changed(
        self, window: QQuickWindow, visible: bool
    ) -> None:
        if visible and window.property("useNativeMacFrame"):
            window.setProperty("_fluentqmlMacTrafficLightsShiftApplied", False)
            window.setProperty("_fluentqmlMacTrafficLightsShiftRetryCount", 0)
            self._apply_macos_window_style(window)
            effect_type = (
                self.theme_manager.get_backdrop_effect() or BackdropEffect.None_.value
            )
            self.theme_manager.apply_backdrop_effect(effect_type)

    def _on_macos_window_width_changed(self, window: QQuickWindow) -> None:
        if not window.property("useNativeMacFrame"):
            return
        if not window.property("macTrafficLightsRightAligned"):
            return
        window.setProperty("_fluentqmlMacTrafficLightsShiftApplied", False)
        self._schedule_macos_traffic_light_shift(window, retry_count=0)

    def _disable_native_mac_frame(self) -> None:
        for window in self.windows:
            if window.property("useNativeMacFrame"):
                window.setProperty("useNativeMacFrame", False)

    def _apply_macos_window_style(self, window: QQuickWindow) -> None:
        if not self._mac_objc or not self._mac_appkit:
            return

        try:
            ns_view = self._mac_objc.objc_object(c_void_p=c_void_p(int(window.winId())))
            ns_window = ns_view.window() if ns_view else None
            if not ns_window:
                return

            # Hide the system title visuals and keep traffic lights in place.
            ns_window.setTitleVisibility_(self._mac_appkit.NSWindowTitleHidden)
            ns_window.setTitlebarAppearsTransparent_(True)
            ns_window.setMovableByWindowBackground_(False)
            style_mask = int(ns_window.styleMask()) | int(
                self._mac_appkit.NSWindowStyleMaskFullSizeContentView
            )
            ns_window.setStyleMask_(style_mask)
            if window.property("macTrafficLightsRightAligned"):
                self._queue_macos_traffic_light_repositions(window)
            else:
                self._schedule_macos_traffic_light_shift(window, retry_count=0)
        except Exception as err:
            print("Failed to apply macOS native titlebar style: " + _ascii(err))
            window.setProperty("useNativeMacFrame", False)

    def _queue_macos_traffic_light_repositions(self, window: QQuickWindow) -> None:
        for delay_ms in (0, 50, 150, 300, 600):
            QTimer.singleShot(
                delay_ms,
                lambda w=window: self._force_macos_traffic_light_reposition(w),
            )

    def _force_macos_traffic_light_reposition(self, window: QQuickWindow) -> None:
        if not window.property("useNativeMacFrame"):
            return
        window.setProperty("_fluentqmlMacTrafficLightsShiftApplied", False)
        self._schedule_macos_traffic_light_shift(window, retry_count=0)

    def _schedule_macos_traffic_light_shift(
        self, window: QQuickWindow, retry_count: int
    ) -> None:
        if window.property("_fluentqmlMacTrafficLightsShiftApplied"):
            return

        moved = self._shift_macos_traffic_lights_once(window)
        if moved:
            window.setProperty("_fluentqmlMacTrafficLightsShiftApplied", True)
            window.setProperty("_fluentqmlMacTrafficLightsShiftRetryCount", retry_count)
            return

        if retry_count >= self._mac_traffic_lights_max_retries:
            return

        next_retry = retry_count + 1
        window.setProperty("_fluentqmlMacTrafficLightsShiftRetryCount", next_retry)
        QTimer.singleShot(
            self._mac_traffic_lights_retry_interval_ms,
            lambda w=window, c=next_retry: self._schedule_macos_traffic_light_shift(
                w, c
            ),
        )

    def _shift_macos_traffic_lights_once(self, window: QQuickWindow) -> bool:
        if not self._mac_objc or not self._mac_appkit:
            return False

        try:
            ns_view = self._mac_objc.objc_object(c_void_p=c_void_p(int(window.winId())))
            ns_window = ns_view.window() if ns_view else None
            if not ns_window:
                return False

            close_button = ns_window.standardWindowButton_(
                self._mac_appkit.NSWindowCloseButton
            )
            minimize_button = ns_window.standardWindowButton_(
                self._mac_appkit.NSWindowMiniaturizeButton
            )
            zoom_button = ns_window.standardWindowButton_(
                self._mac_appkit.NSWindowZoomButton
            )
            buttons = [
                btn for btn in (close_button, minimize_button, zoom_button) if btn
            ]
            if not buttons:
                return False

            if window.property("macTrafficLightsRightAligned"):
                close_frame = close_button.frame()
                minimize_frame = minimize_button.frame()
                zoom_frame = zoom_button.frame()
                spacing = (
                    minimize_frame.origin.x
                    - close_frame.origin.x
                    - close_frame.size.width
                )
                if spacing <= 0:
                    spacing = (
                        zoom_frame.origin.x
                        - minimize_frame.origin.x
                        - minimize_frame.size.width
                    )
                if spacing <= 0:
                    spacing = 8

                button_host = close_button.superview()
                if not button_host:
                    return False

                group_width = (
                    close_frame.size.width
                    + minimize_frame.size.width
                    + zoom_frame.size.width
                    + spacing * 2
                )
                parent_view = button_host.superview() or ns_window.contentView()
                if parent_view:
                    parent_width = parent_view.bounds().size.width
                    host_frame = button_host.frame()
                    if parent_width > host_frame.size.width:
                        button_host.setFrameOrigin_((0, host_frame.origin.y))
                        button_host.setFrameSize_(
                            (parent_width, host_frame.size.height)
                        )

                host_width = button_host.bounds().size.width
                if host_width <= group_width and parent_view:
                    host_width = parent_view.bounds().size.width
                if host_width <= group_width:
                    content_view = ns_window.contentView()
                    if content_view:
                        host_width = content_view.bounds().size.width
                start_x = (
                    host_width - group_width - self._mac_traffic_lights_right_margin
                )
                window_key = int(window.winId())
                original_y = self._mac_traffic_lights_original_y.setdefault(
                    window_key,
                    {
                        "close": close_frame.origin.y,
                        "minimize": minimize_frame.origin.y,
                        "zoom": zoom_frame.origin.y,
                    },
                )
                y_offset = self._mac_traffic_lights_offset_down

                close_button.setFrameOrigin_((start_x, original_y["close"] - y_offset))
                minimize_button.setFrameOrigin_(
                    (
                        start_x + close_frame.size.width + spacing,
                        original_y["minimize"] - y_offset,
                    )
                )
                zoom_button.setFrameOrigin_(
                    (
                        start_x
                        + close_frame.size.width
                        + spacing
                        + minimize_frame.size.width
                        + spacing,
                        original_y["zoom"] - y_offset,
                    )
                )
                self._refresh_macos_traffic_light_hit_testing(
                    ns_window, button_host, buttons
                )
                return True

            # Move the shared container first to preserve native spacing.
            button_host = (
                close_button.superview() if close_button else buttons[0].superview()
            )
            if button_host:
                host_frame = button_host.frame()
                origin_x = host_frame.origin.x + self._mac_traffic_lights_offset_x
                button_host.setFrameOrigin_(
                    (
                        origin_x,
                        host_frame.origin.y - self._mac_traffic_lights_offset_down,
                    )
                )
                return True

            for button in buttons:
                frame = button.frame()
                button.setFrameOrigin_(
                    (
                        frame.origin.x + self._mac_traffic_lights_offset_x,
                        frame.origin.y - self._mac_traffic_lights_offset_down,
                    )
                )
        except Exception as err:
            print("Failed to shift macOS traffic lights: " + _ascii(err))
            return False
        else:
            return True

    def _refresh_macos_traffic_light_hit_testing(
        self, ns_window, button_host, buttons
    ) -> None:
        views = [button_host, *buttons]
        content_view = ns_window.contentView()
        if content_view:
            views.append(content_view)

        for view in views:
            if not view:
                continue
            if view.respondsToSelector_("setNeedsLayout:"):
                view.setNeedsLayout_(True)
            if view.respondsToSelector_("layoutSubtreeIfNeeded"):
                view.layoutSubtreeIfNeeded()
            if view.respondsToSelector_("setNeedsDisplay:"):
                view.setNeedsDisplay_(True)
            if view.respondsToSelector_("updateTrackingAreas"):
                view.updateTrackingAreas()

    def setIcon(self, path: Optional[Union[str, Path]] = None) -> None:
        """
        Sets the icon for the application.
        :param path: str or Path, icon file path (eg = "path/to/icon.png")
        :return:
        """
        app_instance = QApplication.instance()
        if path is None:
            msg = "Icon path must be provided."
            raise ValueError(msg)
        icon_url = QUrl(str(path))
        if icon_url.scheme() == "qrc":
            icon_path = f":{icon_url.path()}"
            window_icon_url = icon_url
        else:
            icon_path = Path(path).as_posix()
            window_icon_url = QUrl.fromLocalFile(icon_path)
        if app_instance and self.root_window is not None:
            app_instance.setWindowIcon(QIcon(icon_path))  # 设置应用程序图标
            self.root_window.setProperty("icon", window_icon_url)
        else:
            msg = "Cannot set icon before QApplication is created."
            raise RuntimeError(msg)

    def _apply_windows_effects(self) -> None:
        """
        Apply Windows effects to the window.
        :return:
        """
        if is_windows():
            effect_type = (
                self.theme_manager.get_backdrop_effect() or BackdropEffect.None_.value
            )
            self.theme_manager.apply_backdrop_effect(effect_type)
            self.theme_manager.apply_window_effects()

    # func名称遵循 Qt 命名规范
    def setBackdropEffect(self, effect: BackdropEffect) -> None:
        """
        Sets the backdrop effect for the window. (Only available on Windows)
        :param effect: BackdropEffect, type of backdrop effect（Acrylic, Mica, Tabbed, None_）
        :return:
        """
        if not is_windows() and effect != BackdropEffect.None_:
            msg = "Only can set backdrop effect on Windows platform."
            raise OSError(msg)
        self.theme_manager.apply_backdrop_effect(effect.value)

    def setTheme(self, theme: Theme) -> None:
        """
        Sets the theme for the window.
        :param theme: Theme, type of theme（Auto, Dark, Light）
        :return:
        """
        self.theme_manager.toggle_theme(theme.value)

    def __getattr__(self, name) -> QObject:
        """获取 QML 窗口属性"""
        try:
            root = object.__getattribute__(self, "root_window")
            return getattr(root, name)
        except AttributeError as err:
            msg = f"\"FluentQMLWindow\" object has no attribute '{name}', you need to load() qml at first."
            raise AttributeError(msg) from err

    def _print_startup_info(self) -> None:
        border = "=" * 40
        print("\n" + border)
        print("FluentQMLWindow Loaded Successfully!")
        print("QML File Path: " + _ascii(self.qml_path))
        print("Current Theme: " + _ascii(self.theme_manager.current_theme))
        print("Backdrop Effect: " + _ascii(self.theme_manager.get_backdrop_effect()))
        print("OS: " + _ascii(sys.platform))
        print(border + "\n")


if __name__ == "__main__":
    # 新用法，应该更规范了捏
    app = QApplication(sys.argv)
    example = FluentQMLWindow("../../examples/gallery.qml")
    sys.exit(app.exec())
