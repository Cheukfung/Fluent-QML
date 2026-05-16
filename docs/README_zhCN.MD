<div align="center">
<img src="../docs/img/logo.svg" alt="FluentQML Logo" width="18%">
<h1>FluentQML</h1>
<p>面向 PySide6 和 Qt Quick 的 Fluent Design 组件库。</p>

**中文** | [English](../README.md)

</div>

> [!IMPORTANT]
> 本项目是基于 [RinUI](https://github.com/RinLit-233-shiroko/Rin-UI) 的二次开发。RinUI 采用 MIT 许可证，本仓库会保留原项目的版权声明。

## 项目概览

FluentQML 是一个 PySide6 + QML 组件库，用于构建具有 Fluent Design 风格的桌面应用界面。它提供可复用的 Qt Quick 控件、窗口框架、主题管理、图标支持、翻译资源加载，以及展示组件用法的 Gallery 示例应用。

这个项目适合希望使用 QML 编写界面，同时使用 Python 负责应用启动、窗口管理、配置和平台集成的开发者。

## 相比 RinUI

FluentQML 目前有如下特性：

- 支持 macOS 原生窗口材质：System、HUD、None。
- 改进 macOS 窗口处理，包括原生标题栏集成和更平滑的窗口拖动。
- 支持 Windows 11 Snap Layout，自定义窗口也能触发系统贴靠布局。
- 将 QML、字体、图片和翻译文件编译进 Qt qrc 资源，方便 PyPI 包安装后加载。
- 发布、资源构建和 Gallery 打包脚本改为跨平台 Python 实现。
- 修复 CalendarDatePicker、Expander 圆角、页面刷新和配置路径等问题。

## 特性

- 常见桌面 UI 场景的 Fluent 风格 Qt Quick 控件
- 带标题栏和导航布局的自定义应用窗口
- 浅色、深色和自动主题切换
- 主题色和背景效果支持
- Fluent System Icons 集成
- 面向应用本地化的翻译资源加载
- 覆盖控件、布局、导航、弹窗、菜单和输入组件的 Gallery 示例
- 面向 PyInstaller 打包的 hook 支持

## 预览

![FluentQML Gallery](../docs/img/img.png)

## 安装

包发布到 PyPI 后，可以通过 pip 安装：

```bash
pip install fluentqml
```

本地开发时，可以直接安装当前仓库：

```bash
git clone https://github.com/Cheukfung/fluentqml.git
cd fluentqml
uv sync
```

如果不使用 `uv`，可以手动安装运行依赖：

```bash
pip install PySide6 darkdetect
```

## 快速开始

创建一个 QML 文件，例如 `main.qml`：

```qml
import QtQuick
import FluentQML

FluentWindow {
    visible: true
    width: 900
    height: 600
    title: "FluentQML App"

    Text {
        anchors.centerIn: parent
        text: "Hello FluentQML"
    }
}
```

使用 Python 启动：

```python
import sys

from PySide6.QtWidgets import QApplication
from fluentqml import FluentQMLWindow

app = QApplication(sys.argv)
window = FluentQMLWindow("main.qml")
sys.exit(app.exec())
```

QML 模块名是 `FluentQML`，Python 包名是 `fluentqml`。

## Gallery

在仓库根目录运行 Gallery：

```bash
uv run python examples/gallery.py
```

如果你自行管理依赖，也可以运行：

```bash
python examples/gallery.py
```

在正式文档完善前，Gallery 是查看可用控件和复制可运行用法的最好入口。

## 项目结构

```text
fluentqml/              Python 包、QML 模块、资源和打包 hook
examples/               Gallery 应用和组件使用示例
docs/                   图片和文档草稿
scripts/                资源生成和发布辅助脚本
test/                   小型 QML 加载实验
```

## 开发

修改 QML、字体、图片或翻译文件后，需要重新生成 Qt 资源包：

```bash
uv run python scripts/build_fluentqml_qrc.py
```

运行 lint 检查：

```bash
uv run ruff check .
```

更新库本体翻译：

```bash
uv run python scripts/update_ts.py library
```

更新 Gallery 翻译：

```bash
uv run python scripts/update_ts.py gallery
```

使用 PyInstaller 打包 Gallery 应用：

```bash
uv run python scripts/package_gallery.py
```

构建发布产物：

```bash
uv run python scripts/release.py build
```

发布脚本会清理 `dist/`、重新生成 `fluentqml_rc.py`、构建 sdist 和 wheel、检查 wheel 中是否包含 `fluentqml/fluentqml_rc.py`、确认原始 QML 资源没有误打进 wheel，并运行 `twine check`。

上传已构建的产物到 TestPyPI：

```bash
uv run python scripts/release.py upload-testpypi
```

在 TestPyPI 安装验证通过后，再上传同一批产物到正式 PyPI：

```bash
uv run python scripts/release.py upload-pypi
```

项目中的命名约定：

- Python import：`from fluentqml import FluentQMLWindow`
- QML import：`import FluentQML`
- Qt 资源前缀：`qrc:/FluentQML`
- 生成的资源模块：`fluentqml.fluentqml_rc`

## 致谢

FluentQML 使用并参考了 Qt 与 Fluent 生态中的资源和设计：

- [PySide6 and Qt Quick](https://www.qt.io/)
- [Fluent Design System](https://fluent2.microsoft.design/)
- [Fluent UI System Icons](https://github.com/microsoft/fluentui-system-icons/)
- [WinUI 3 Gallery](https://github.com/microsoft/WinUI-Gallery)

## 许可证

FluentQML 采用 MIT 许可证发布。完整许可内容请查看 [LICENSE](../LICENSE)。

Copyright (c) 2026 Cheukfung
