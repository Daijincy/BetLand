# BetLand

全自定义灵动岛 iOS App · iOS 26 Liquid Glass · ActivityKit 实时活动 · 自用签名

> 非越狱、自用签名（TrollStore / AltStore / 免费 Apple ID 自签），不上架 App Store。
> 构建产物为**未签名 IPA**，由 GitHub Actions 云编译产出，下载后自行签名安装。

---

## 功能

- 灵动岛**展开面板**：官方 ActivityKit 上限内（宽 ~371pt × 高 160pt）自由调节，四区（leading / trailing / bottom / center）自定义控件
- 灵动岛**胶囊**：系统锁定物理容器，内部视觉可自定义（文字 / 图标 / 配色 / 视觉宽度模拟）
- **布局编辑器**：液态玻璃画布，拖拽摆放文字 / 图标 / 进度条 / 计时器组件，缩放、透明度、删除
- **实时活动**：前台高频刷新 + APNs 离线更新接口（自用可自建推送后端），官方 8h / 12h 上限
- **UI**：App 内全部控件基于 iOS 26 `glassEffect` / `GlassEffectContainer` 液态玻璃原生 API

## 官方硬限制（绕不开）

| 项目 | 限制 |
|---|---|
| 灵动岛展示时长 | ≤ 8 小时，系统强制销毁 |
| 锁屏展示时长 | ≤ 12 小时，之后不再更新 |
| 单次更新载荷 | ≤ 4 KB |
| 胶囊物理尺寸 | 由 SpringBoard 锁定，只能自定义内部视觉 |
| 液态玻璃 API | 仅主 App 可用；Widget / ActivityKit 不支持，灵动岛用系统材质对齐风格 |

## 云编译（GitHub Actions）

推送 `main` 分支或手动触发 `workflow_dispatch` 即开始编译：

1. Actions → **Build BetLand (unsigned IPA)** → Run workflow
2. 编译完成后进入该次 run 的底部 **Artifacts**，下载 `BetLand-unsigned.ipa`
3. 自签安装：
   - **TrollStore**：直接导入 IPA 安装（自动注入 entitlements）
   - **AltStore / Sideloadly / 爱思助手**：用免费 Apple ID 签名安装（Live Activities entitlement 由工具处理，免费账号可用）
   - 自签免费账号证书 7 天过期，需重新签名

> 本仓库不发布 Release / Tag（"正式版"），只通过 Actions Artifact 产出开发包。

## 本地开发

需要 Xcode 26（iOS 26 SDK）与 [XcodeGen](https://github.com/yonaskolb/XcodeGen)：

```bash
brew install xcodegen
xcodegen generate
open BetLand.xcodeproj
```

- Scheme：`BetLand`（含 `BetLandWidget` extension）
- Target：iOS 26.0，iPhone（灵动岛机型 iPhone 14 Pro 及以上）
- Live Activities entitlement 已配置：`com.apple.developer.usernotifications.live-activities`

## 工程结构

```
project.yml                # XcodeGen 工程定义（唯一工程来源）
BetLand/                   # 主 App
  Views/Components/        # 液态玻璃组件库（GlassCard / GlassButton / GlassSlider / GlassToggle）
  Views/                   # 首页 / 布局编辑器 / 设置
  Models/                  # IslandConfig（@Observable 全局配置）
  Services/                # LiveActivityManager（创建/更新/结束）
BetLandWidget/             # Widget Extension（仅承载实时活动）
BetLandShared/             # BetLandAttributes（App 与 Widget 共享）
.github/workflows/build.yml # 云编译流水线
```

## Roadmap（未发布正式版前）

- [x] 工程骨架 + 云编译流水线
- [x] 液态玻璃全局 UI 与组件库
- [x] 布局编辑器雏形（拖拽 / 缩放 / 透明度）
- [x] ActivityKit 实时活动（胶囊 / 展开 / 锁屏三态）
- [ ] 多套布局预设保存与导入（SwiftData）
- [ ] APNs Live Activity 推送后端示例
- [ ] 实时预览：真机运行中同步编辑器改动
- [ ] App 图标与启动屏

## License

MIT
