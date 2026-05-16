import ctypes
import platform
import sys
import time
from ctypes import c_void_p

import darkdetect
from PySide6.QtCore import QObject, QThread, Signal, Slot

from .config import (
    DEFAULT_CONFIG,
    BackdropEffect,
    FluentQMLConfig,
    is_macos,
    is_win10,
    is_win11,
    is_windows,
)


def check_darkdetect_support():
    system = platform.system()
    if system == "Darwin":
        mac_ver = platform.mac_ver()[0]
        major, minor, *_ = map(int, mac_ver.split("."))
        return (major == 10 and minor >= 14) or major > 10

    if system == "Windows":
        return platform.release() >= "10"
    return False


ACCENT_STATES = {"acrylic": 3, "mica": 2, "tabbed": 4, "none": 0}

ACCENT_SUPPORT = {
    "acrylic": is_win10(),
    "mica": is_win11(),
    "tabbed": is_win10(),
    "none": True,
}

MACOS_BACKDROP_EFFECTS = {"system", "hud", "none"}


class ACCENT_POLICY(ctypes.Structure):
    _fields_ = [
        ("AccentState", ctypes.c_int),
        ("AccentFlags", ctypes.c_int),
        ("GradientColor", ctypes.c_int),
        ("AnimationId", ctypes.c_int),
    ]


class WINDOWCOMPOSITIONATTRIBDATA(ctypes.Structure):
    _fields_ = [
        ("Attrib", ctypes.c_int),
        ("pvData", ctypes.c_void_p),
        ("cbData", ctypes.c_size_t),
    ]


class ThemeListener(QThread):
    """
    监听系统颜色模式
    """

    themeChanged = Signal(str)

    def run(self):
        last_theme = darkdetect.theme()
        while True:
            current_theme = darkdetect.theme()
            if current_theme != last_theme:
                last_theme = current_theme
                self.themeChanged.emit(current_theme)
                print(f"Theme changed: {current_theme}")
            time.sleep(1)

    def stop(self):
        self.terminate()


class ThemeManager(QObject):
    themeChanged = Signal(str)
    backdropChanged = Signal(str)
    windows = []  # 窗口句柄们（
    _instance = None

    # DWM 常量保持不变
    DWMWA_USE_IMMERSIVE_DARK_MODE = 20
    DWMWA_WINDOW_CORNER_PREFERENCE = 33
    DWMWA_NCRENDERING_POLICY = 2
    DWMNCRENDERINGPOLICY_ENABLED = 2
    DWMWA_SYSTEMBACKDROP_TYPE = 38
    WCA_ACCENT_POLICY = 19

    # 圆角
    DWMWCP_DEFAULT = 0
    DWMWCP_DONOTROUND = 1
    DWMWCP_ROUND = 2
    DWMWCP_ROUNDSMALL = 3

    def clean_up(self):
        """
        清理资源并停止主题监听。
        """
        if self.listener:
            FluentQMLConfig.save_config()
            print("Save config.")
            self.listener.stop()
            self.listener.wait()  # 等待线程结束
            print("Theme listener stopped.")

    def __new__(cls, *args, **kwargs):
        """
        单例管理，共享主题状态
        :param args:
        :param kwargs:
        """
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self):
        if hasattr(self, "_initialized") and self._initialized:
            return
        self._initialized = True
        super().__init__()
        self.theme_dict = {"Light": 0, "Dark": 1}
        self.windows = []
        self.qt_windows = []
        self._mac_visual_effect_views = {}

        self.listener = None  # 监听线程
        self.current_theme = DEFAULT_CONFIG["theme"]["current_theme"]  # 当前主题
        self.is_darkdetect_supported = check_darkdetect_support()

        try:
            self.current_theme = FluentQMLConfig["theme"]["current_theme"]
        except Exception as e:
            print(f"Failed to load config because of {e}, using default config")

        self._normalize_backdrop_effect()
        self.start_listener()

    def _backdrop_effect_config_key(self):
        return "macos_backdrop_effect" if is_macos() else "backdrop_effect"

    def _normalize_backdrop_effect(self):
        config_key = self._backdrop_effect_config_key()
        effect_type = FluentQMLConfig[config_key]
        if is_macos():
            supported_effects = MACOS_BACKDROP_EFFECTS
            default_effect = DEFAULT_CONFIG["macos_backdrop_effect"]
        elif is_windows():
            supported_effects = set(ACCENT_STATES)
            default_effect = DEFAULT_CONFIG["backdrop_effect"]
        else:
            supported_effects = {BackdropEffect.None_.value}
            default_effect = BackdropEffect.None_.value

        if effect_type not in supported_effects:
            FluentQMLConfig[config_key] = default_effect

    def start_listener(self):
        if not self.is_darkdetect_supported:
            print("darkdetect not supported on this platform")
            return
        self.listener = ThemeListener()
        self.listener.themeChanged.connect(self._handle_system_theme)
        self.listener.start()

    def set_window(self, window):  # 绑定窗口句柄
        hwnd = int(window.winId())
        if hwnd not in self.windows:
            self.windows.append(hwnd)
        if window not in self.qt_windows:
            self.qt_windows.append(window)
        print(f"Window handle set: {hwnd}")

    def _handle_system_theme(self):
        if self.current_theme == "Auto":
            self._update_window_theme()
            self.themeChanged.emit(self._actual_theme())
        else:
            # 保持当前背景效果不变
            self._update_window_theme()

    @Slot(str)
    def apply_backdrop_effect(self, effect_type: str):
        """
        应用背景效果
        :param effect_type: str, 背景效果类型（acrylic, mica, tabbed, system, hud, none）
        """
        if is_macos():
            return self._apply_macos_backdrop_effect(effect_type)

        self._update_window_theme()
        if not is_windows() or not self.windows:
            print(f'Cannot apply effect "{effect_type}" on this platform')
            return -2  # 非 windows或未绑定窗口
        self.backdropChanged.emit(effect_type)

        accent_state = ACCENT_STATES.get(effect_type, 0)
        if not ACCENT_SUPPORT.get(effect_type, False):
            print(f'Effect "{effect_type}" not supported on this platform')
            return -1  # 效果不支持

        for hwnd in self.windows:
            if is_win11():
                ctypes.windll.dwmapi.DwmSetWindowAttribute(
                    hwnd,
                    self.DWMWA_SYSTEMBACKDROP_TYPE,
                    ctypes.byref(ctypes.c_int(accent_state)),
                    ctypes.sizeof(ctypes.c_int),
                )
            elif is_win10() and effect_type == BackdropEffect.Acrylic.value:
                self._apply_win10_effect(effect_type, hwnd)

        FluentQMLConfig["backdrop_effect"] = effect_type
        # print(
        #     f"Applied \"{effect_type.strip().capitalize()}\" effect with "
        #     f"{platform.system() + '11' if is_win11() else '10'}"
        # )
        return 0  # 成功

    def _apply_macos_backdrop_effect(self, effect_type: str):
        if not self.qt_windows:
            print(f'Cannot apply effect "{effect_type}" before window is bound')
            return -2
        if effect_type not in MACOS_BACKDROP_EFFECTS:
            print(f'Effect "{effect_type}" not supported on macOS')
            return -1

        try:
            import AppKit
            import objc
        except Exception as err:
            print(f'Cannot apply macOS effect "{effect_type}": {err}')
            return -2

        material_by_effect = self._macos_material_by_effect(AppKit)
        appearance = self._macos_appearance(AppKit)

        applied_any = any(
            self._apply_macos_backdrop_to_window(
                window,
                effect_type,
                AppKit,
                objc,
                material_by_effect,
                appearance,
            )
            for window in self.qt_windows
        )

        if not applied_any:
            print(f'Cannot apply effect "{effect_type}" on visible macOS windows')
            return -2

        self.backdropChanged.emit(effect_type)
        FluentQMLConfig["macos_backdrop_effect"] = effect_type
        return 0

    def _apply_macos_backdrop_to_window(
        self,
        window,
        effect_type: str,
        appkit,
        objc,
        material_by_effect: dict,
        appearance,
    ):
        if not window.property("useNativeMacFrame"):
            return False

        window_key, qt_view, ns_window = self._macos_window_handles(window, objc)
        if not ns_window:
            return False

        self._prepare_macos_backdrop_window(qt_view, ns_window, appkit, appearance)
        if effect_type == BackdropEffect.None_.value:
            self._remove_macos_visual_effect_view(window_key)
            return True

        visual_effect_view = self._ensure_macos_visual_effect_view(
            window_key,
            qt_view,
            ns_window,
            appkit,
        )
        visual_effect_view.setMaterial_(material_by_effect[effect_type])
        visual_effect_view.setBlendingMode_(
            appkit.NSVisualEffectBlendingModeBehindWindow
        )
        visual_effect_view.setState_(appkit.NSVisualEffectStateActive)
        visual_effect_view.setAppearance_(appearance)
        return True

    def _macos_window_handles(self, window, objc):
        window_key = int(window.winId())
        qt_view = objc.objc_object(c_void_p=c_void_p(window_key))
        ns_window = qt_view.window() if qt_view else None
        return window_key, qt_view, ns_window

    def _prepare_macos_backdrop_window(self, qt_view, ns_window, appkit, appearance):
        ns_window.setOpaque_(False)
        ns_window.setBackgroundColor_(appkit.NSColor.clearColor())
        ns_window.setAppearance_(appearance)
        qt_view.setWantsLayer_(True)
        qt_layer = qt_view.layer()
        if qt_layer:
            qt_layer.setOpaque_(False)

    def _remove_macos_visual_effect_view(self, window_key: int):
        visual_effect_view = self._mac_visual_effect_views.pop(window_key, None)
        if visual_effect_view:
            visual_effect_view.removeFromSuperview()

    def _ensure_macos_visual_effect_view(self, window_key: int, qt_view, ns_window, appkit):
        qt_superview = qt_view.superview()
        parent_view = qt_superview or ns_window.contentView()
        visual_effect_view = self._mac_visual_effect_views.get(window_key)
        if visual_effect_view is None:
            visual_effect_view = appkit.NSVisualEffectView.alloc().initWithFrame_(
                parent_view.bounds()
            )
            visual_effect_view.setAutoresizingMask_(
                appkit.NSViewWidthSizable | appkit.NSViewHeightSizable
            )
            parent_view.addSubview_positioned_relativeTo_(
                visual_effect_view,
                appkit.NSWindowBelow,
                qt_view if qt_superview else None,
            )
            self._mac_visual_effect_views[window_key] = visual_effect_view

        visual_effect_view.setFrame_(parent_view.bounds())
        return visual_effect_view

    def _macos_material_by_effect(self, appkit):
        return {
            BackdropEffect.System.value: appkit.NSVisualEffectMaterialUnderWindowBackground,
            BackdropEffect.Hud.value: appkit.NSVisualEffectMaterialHUDWindow,
        }

    def _macos_appearance(self, appkit):
        appearance_name = (
            appkit.NSAppearanceNameDarkAqua
            if self.is_dark_theme()
            else appkit.NSAppearanceNameAqua
        )
        return appkit.NSAppearance.appearanceNamed_(appearance_name)

    def _apply_win10_effect(self, effect_type, hwnd):
        """
        应用 Windows 10 背景效果
        :param effect_type: str, 背景效果类型（acrylic, tabbed(actually blur)
        """
        backdrop_color = FluentQMLConfig["win10_feat"][
            "backdrop_dark" if self.is_dark_theme() else "backdrop_light"
        ]

        accent = ACCENT_POLICY()
        accent.AccentState = ACCENT_STATES[effect_type]
        accent.AccentFlags = 2
        accent.GradientColor = backdrop_color
        data = WINDOWCOMPOSITIONATTRIBDATA()
        data.Attrib = self.WCA_ACCENT_POLICY
        data.pvData = ctypes.cast(ctypes.pointer(accent), ctypes.c_void_p)
        data.cbData = ctypes.sizeof(accent)

        try:
            set_window_composition = ctypes.windll.user32.SetWindowCompositionAttribute
            set_window_composition(hwnd, ctypes.byref(data))
        except Exception as e:
            print(f"Failed to apply acrylic on Win10: {e}")

    def apply_window_effects(self):  # 启用圆角阴影
        if sys.platform != "win32" or not self.windows:
            return

        dwm = ctypes.windll.dwmapi

        # 启用非客户端渲染策略（让窗口边框具备阴影）
        ncrp = ctypes.c_int(self.DWMNCRENDERINGPOLICY_ENABLED)
        for hwnd in self.windows:
            dwm.DwmSetWindowAttribute(
                hwnd,
                self.DWMWA_NCRENDERING_POLICY,
                ctypes.byref(ncrp),
                ctypes.sizeof(ncrp),
            )

            # 启用圆角效果
            corner_preference = ctypes.c_int(self.DWMWCP_ROUND)
            dwm.DwmSetWindowAttribute(
                hwnd,
                self.DWMWA_WINDOW_CORNER_PREFERENCE,
                ctypes.byref(corner_preference),
                ctypes.sizeof(corner_preference),
            )
        # print("Enabled Rounded and Shadows")

    def _update_window_theme(self):  # 更新窗口的颜色模式
        if is_macos():
            self._normalize_backdrop_effect()
            effect_type = FluentQMLConfig["macos_backdrop_effect"]
            if effect_type in MACOS_BACKDROP_EFFECTS:
                self._apply_macos_backdrop_effect(effect_type)
            return

        if sys.platform != "win32" or not self.windows:
            return
        actual_theme = self._actual_theme()
        for hwnd in self.windows:
            if is_win11():
                ctypes.windll.dwmapi.DwmSetWindowAttribute(
                    hwnd,
                    self.DWMWA_USE_IMMERSIVE_DARK_MODE,
                    ctypes.byref(ctypes.c_int(self.theme_dict[actual_theme])),
                    ctypes.sizeof(ctypes.c_int),
                )
            elif (
                is_win10()
                and FluentQMLConfig["backdrop_effect"] == BackdropEffect.Acrylic.value
            ):
                self._apply_win10_effect(FluentQMLConfig["backdrop_effect"], hwnd)
            else:
                print(f"Cannot apply backdrop on {platform.system()}")

        # print(f"Window theme updated to {actual_theme}")

    def is_dark_theme(self):
        """是否为暗黑主题"""
        return self._actual_theme() == "Dark"

    def _actual_theme(self):
        """实际应用的主题"""
        if self.current_theme == "Auto":
            return (
                darkdetect.theme() or "Light"
                if self.is_darkdetect_supported
                else "Light"
            )
        return self.current_theme

    @Slot(str)
    def toggle_theme(self, theme: str):  # 切换主题
        if theme not in ["Auto", "Light", "Dark"]:  # 三状态
            return
        if self.current_theme != theme:
            print(f"Switching to '{theme}' theme")
            self.current_theme = theme
            FluentQMLConfig["theme"]["current_theme"] = theme
            self._update_window_theme()
            self.themeChanged.emit(self._actual_theme())

    @Slot(result=str)
    def get_theme(self):
        return self._actual_theme()

    @Slot(result=str)
    def get_theme_name(self):
        """获取当前主题名称"""
        return self.current_theme

    @Slot(result=str)
    def get_backdrop_effect(self):
        """获取当前背景效果"""
        self._normalize_backdrop_effect()
        return FluentQMLConfig[self._backdrop_effect_config_key()]

    @Slot(str)
    def set_theme_color(self, color):
        """设置当前主题颜色"""
        FluentQMLConfig["theme_color"] = color
        FluentQMLConfig.save_config()

    @Slot(result=str)
    def get_theme_color(self):
        """获取当前主题颜色"""
        return FluentQMLConfig["theme_color"]
