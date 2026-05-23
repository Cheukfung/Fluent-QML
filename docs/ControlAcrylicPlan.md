# 控件级亚克力实现方案

## 目标

为 Fluent-QML 增加控件级亚克力材质能力，参考 PyQt-Fluent-Widgets 的实现方式：

```text
背后内容截图
+ 高斯模糊
+ tint 半透明色
+ luminosity 明度层
+ noise 噪声纹理
+ 圆角裁剪
```

第一阶段只建议用于 `Popup`、`Flyout`、`Menu`、`Dialog` 等短暂浮层控件，不建议用于整页背景或高频动画区域。

## PyQt-Fluent-Widgets 的实现方式

PyQt-Fluent-Widgets 的控件亚克力不是简单修改控件 `opacity`，而是快照式亚克力。

核心流程在 `AcrylicBrush` 中：

```python
screen.grabWindow(0, x, y, w, h)
```

抓取控件背后的屏幕区域，然后：

```python
gaussianBlur(image, blurRadius, blurPicSize=...)
```

最后绘制时先画模糊图，再叠加亚克力纹理：

```python
painter.drawPixmap(0, 0, image)
painter.fillRect(device.rect(), QBrush(self.textureImage()))
```

`textureImage()` 内部叠加：

- `luminosityColor`
- `tintColor`
- `noiseImage`

因此它本质上是“显示前抓一张背景快照并模糊”，不是系统 DWM 那种实时材质。

## 为什么不能只用 opacity

`opacity` 会让整个控件透明，包括：

- 文字
- 图标
- 边框
- 阴影
- 子控件

这会导致可读性下降，也不符合 Fluent Acrylic 的视觉层次。真正的亚克力应该只作用在背景材质层上，控件内容仍保持正常不透明。

## 当前项目现状

Fluent-QML 已经具备窗口级背景材质基础：

- `fluentqml/core/theme.py` 中已有 Windows DWM / Win10 Acrylic / Win11 Mica 相关逻辑。
- macOS 已通过 `NSVisualEffectView` 实现窗口级 material。
- `FluentWindowBase.qml` 和 `Window.qml` 已在 backdrop 启用时将窗口背景设为 `transparent`。
- `Popup.qml`、`Flyout.qml`、`Menu.qml`、`Dialog.qml` 等控件已使用 `Theme.currentTheme.colors.backgroundAcrylicColor` 做视觉近似。

因此新增控件级亚克力时，不需要重做窗口 backdrop，而是新增一个专门服务浮层背景的材质组件。

## 推荐技术结构

新增 Python 原生渲染项：

```text
fluentqml/core/acrylic.py
```

核心类：

```text
AcrylicItem(QQuickPaintedItem)
```

暴露给 QML 后，再封装一个 QML 组件：

```text
fluentqml/components/Materials/AcrylicPanel.qml
```

推荐分层：

```text
Python AcrylicItem
负责：抓屏、模糊、缓存、绘制材质

QML AcrylicPanel
负责：主题参数、圆角、边框、控件接入
```

这样普通控件不直接依赖 Python 实现细节，只使用 `AcrylicPanel`。

## AcrylicItem 设计

建议暴露属性：

```qml
AcrylicItem {
    radius: 8
    blurRadius: 30
    maxBlurSize: 450
    tintColor: Qt.rgba(1, 1, 1, 0.7)
    luminosityColor: Qt.rgba(1, 1, 1, 0.18)
    noiseOpacity: 0.03
    borderColor: Qt.rgba(0, 0, 0, 0.06)
    borderWidth: 1
}
```

建议暴露方法：

```qml
acrylic.refresh()
```

`refresh()` 只负责重新抓取背景并重新生成模糊缓存。主题 tint、border 等属性变化只需要触发 repaint，不一定重新抓屏。

## 绘制流程

一次完整刷新流程：

```text
1. 获取控件在窗口内的位置
2. 映射到屏幕全局坐标
3. 获取当前屏幕和 devicePixelRatio
4. 根据控件尺寸计算抓屏区域
5. 使用 QScreen.grabWindow(0, x, y, width, height) 抓屏
6. 将截图缩放到 maxBlurSize 限制内
7. 对缩放后的图片执行 Gaussian Blur
8. 缓存 blurredPixmap
9. 调用 update() 触发重绘
10. paint() 中按圆角裁剪区域
11. 绘制 blurredPixmap
12. 叠加 tintColor
13. 叠加 luminosityColor
14. 叠加 noise texture
15. 绘制 border
```

## QML 使用方式

推荐由 `AcrylicPanel.qml` 封装：

```qml
AcrylicPanel {
    anchors.fill: parent
    radius: Theme.currentTheme.appearance.windowRadius
    blurRadius: Theme.controlAcrylicBlurRadius
    tintColor: Theme.isDark()
        ? Qt.rgba(0.125, 0.125, 0.125, 0.78)
        : Qt.rgba(1, 1, 1, 0.70)
    luminosityColor: Theme.isDark()
        ? Qt.rgba(0, 0, 0, 0)
        : Qt.rgba(1, 1, 1, 0.18)
    noiseOpacity: 0.03
}
```

控件背景结构示例：

```qml
background: Item {
    AcrylicPanel {
        id: acrylic
        anchors.fill: parent
        radius: Theme.currentTheme.appearance.windowRadius
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.currentTheme.appearance.windowRadius
        color: "transparent"
        border.color: Theme.currentTheme.colors.flyoutBorderColor
    }
}
```

边框可以放在 `AcrylicPanel` 内，也可以由外层 `Rectangle` 单独负责。建议第一版放在 `AcrylicPanel` 内，避免每个控件重复写边框逻辑。

## 刷新时机

推荐刷新点：

- `Component.onCompleted`
- `onVisibleChanged: if (visible) Qt.callLater(acrylic.refresh)`
- `onWidthChanged` / `onHeightChanged`，但需要 debounce
- popup/flyout/menu 打开前或打开后的第一帧
- 控件跨屏或窗口移动结束后

不推荐刷新点：

- `onXChanged` 每次刷新
- `onYChanged` 每次刷新
- 滚动时持续刷新
- 窗口拖动时持续刷新
- 动画每帧刷新

建议 debounce：

```text
80ms - 120ms
```

## 性能风险

性能开销主要来自：

- 抓屏
- 高斯模糊
- 高 DPI 下的大尺寸图像处理

绘制缓存后的模糊图和纹理相对便宜。

高风险场景：

- 大面积控件，例如整页背景
- 多个亚克力控件同时打开
- resize 或动画期间频繁刷新
- blurRadius 太大
- 高 DPI 下直接模糊物理像素大图

## 性能控制策略

建议默认参数：

```text
blurRadius: 24 - 35
maxBlurSize: 450
noiseOpacity: 0.02 - 0.04
refresh debounce: 80ms - 120ms
```

关键策略：

- 先缩小截图，再模糊。
- 绘制时再将模糊图拉伸到控件尺寸。
- 显示前或显示后第一帧刷新一次。
- resize 后 debounce 刷新。
- 主题色变化只更新 tint，不重新抓屏。
- 同一控件未移动、未 resize、未修改 blurRadius 时复用缓存。

缓存 key 可包含：

```text
screenName
globalRect
itemSize
devicePixelRatio
blurRadius
maxBlurSize
```

## 主题参数建议

亮色主题：

```text
tintColor: rgba(255, 255, 255, 0.62 - 0.72)
luminosityColor: rgba(255, 255, 255, 0.12 - 0.22)
borderColor: rgba(0, 0, 0, 0.06)
noiseOpacity: 0.03
```

暗色主题：

```text
tintColor: rgba(32, 32, 32, 0.72 - 0.82)
luminosityColor: rgba(0, 0, 0, 0)
borderColor: rgba(255, 255, 255, 0.08)
noiseOpacity: 0.03
```

这与 PyQt-Fluent-Widgets 中常见参数接近：

```text
Light tint: QColor(255, 255, 255, 160 - 180)
Dark tint: QColor(32, 32, 32, 200)
```

## 平台策略

### Windows

- 窗口级材质继续使用现有 DWM/backdrop 实现。
- 控件级材质使用快照式抓屏模糊。
- 浮层抓屏时要避免抓到自身，建议在浮层显示前、透明阶段，或显示后第一帧但背景层尚未绘制时刷新。

### macOS

- 窗口级材质继续使用现有 `NSVisualEffectView`。
- 控件级第一版仍使用快照式抓屏模糊。
- 如果未来追求原生控件材质，可研究给浮层挂局部 `NSVisualEffectView`，但 QML 集成复杂度更高，第一版不建议。

### Linux

- X11 下通常可以尝试快照式抓屏。
- Wayland 下抓屏可能受限。
- 不支持时应显式报错或关闭控件级亚克力，不静默伪装成成功。

## 配置建议

可以新增配置项：

```json
{
    "control_acrylic_enabled": true,
    "control_acrylic_blur_radius": 30,
    "control_acrylic_max_size": 450,
    "control_acrylic_noise_opacity": 0.03
}
```

QML 侧可暴露：

```qml
Theme.controlsAcrylicEnabled
Theme.controlAcrylicBlurRadius
Theme.controlAcrylicMaxSize
Theme.controlAcrylicNoiseOpacity
```

注意：按照项目约定，代码实现时不要做静默兜底。配置关闭和平台不支持是两种不同状态，应明确区分。

## 第一阶段接入范围

建议按以下顺序接入：

```text
1. Popup
2. Menu
3. Flyout
4. Dialog
5. PickerView
```

对应文件：

- `fluentqml/components/DialogsAndFlyouts/Popup.qml`
- `fluentqml/components/MenusAndToolbars/Menu.qml`
- `fluentqml/components/DialogsAndFlyouts/Flyout.qml`
- `fluentqml/components/DialogsAndFlyouts/Dialog.qml`
- `fluentqml/components/DateAndTime/PickerView.qml`

这些组件目前已经使用 `backgroundAcrylicColor`，适合替换为统一的 `AcrylicPanel`。

## 验收标准

功能验收：

- `Popup` / `Menu` / `Flyout` / `Dialog` 打开时能看到背后内容被模糊。
- 文字、图标、边框、阴影不随背景一起透明。
- Light / Dark 主题切换后 tint 正确变化。
- resize 后背景区域重新匹配。
- 多屏幕下抓取当前控件所在屏幕。
- 高 DPI 下没有坐标偏移和尺寸错位。

性能验收：

- 小型浮层首次刷新无明显卡顿。
- 大多数浮层刷新目标控制在 16ms - 40ms。
- resize debounce 后不出现连续卡顿。
- 打开多个菜单或弹窗时不会明显阻塞 UI。

异常验收：

- 平台不支持抓屏时给出明确错误。
- 依赖缺失时给出明确错误。
- 不静默退化为普通背景并假装亚克力成功。

## 推荐实施顺序

```text
1. 实现 AcrylicItem，先用固定参数验证抓屏和绘制。
2. 加入 blurRadius、maxBlurSize、radius、tintColor、luminosityColor、noiseOpacity 等属性。
3. 加入 refresh() 方法和缓存。
4. 加入 resize debounce。
5. 封装 AcrylicPanel.qml。
6. 接入 Popup.qml。
7. 接入 Menu.qml、Flyout.qml、Dialog.qml。
8. 验证 Light / Dark、高 DPI、多屏、窗口移动。
9. 加入配置项和设置页开关。
10. 再考虑是否扩展到更多控件。
```

## 总结

Fluent-QML 可以实现控件级亚克力。推荐实现方式与 PyQt-Fluent-Widgets 一致，采用快照式亚克力，而不是控件透明度模拟。

性能是可控的，前提是：

- 只用于浮层控件。
- 不做每帧实时刷新。
- 限制模糊输入图尺寸。
- 使用缓存。
- resize 和显示时机做 debounce。

第一版应优先把能力做成统一的 `AcrylicItem` 和 `AcrylicPanel`，再逐步替换现有浮层控件背景。
