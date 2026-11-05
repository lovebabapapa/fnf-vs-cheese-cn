# Friday Night Funkin' - VS Cheese（中文汉化版）

> **本仓库是 [VS Cheese: The Full Ass Update](https://gamebanana.com/mods/301107)（uniimations 制作）的 fork，
> 在其基础上完成了完整的简体中文汉化，并重新编译为 Windows 可执行版本。**

---

## ⚠️ AI 使用声明

**本汉化项目大量使用了 AI（大语言模型）辅助完成**，在此明确声明：

- **翻译工作**：全部对话（149 句）、成就描述、界面文本、标语等中文译文由 AI 生成初稿，经人工校对修改后定稿
- **工程实现**：Psych Engine 0.3.2 → 现代工具链的移植编译、源码级汉化补丁（CJK 渲染支持、UI 字符串替换等）、字体图集生成管线，均在 AI 辅助下完成
- **视频字幕**：时间轴由 AI 语音识别（Whisper）初识别，人工校对
- **修正与验收**：所有修复均经过人工逐项目视验收（游戏内实际测试）

使用本仓库的翻译成果时，请知晓上述情况；译文质量以游戏内实际效果为准。

---

## 汉化内容

| 范围 | 说明 |
|---|---|
| 剧情对话 | 149 句全部汉化（含 SHIT 难度特殊对话的"原味"保留） |
| 过场视频 | 4 部剧情视频硬烧中英双语字幕 |
| 曲目中途字幕 | Cheese 的演出字幕全部汉化 |
| 引擎 UI | 主菜单/暂停/设置页（含全部选项描述）/按键设置 |
| 成就 | 32 个成就的名称与描述 |
| 标语 | 标题屏 47 条玩梗标语 |
| 歌名 | 显示为 `English(中文)` 格式，曲作者保留英文 |
| 图片素材 | 主菜单按钮、评级图、演出图（系统错误/蓝屏彩蛋）等重绘或替换 |
| 字体 | 对话/HUD 使用 [得意黑 (Smiley Sans)](https://github.com/atelier-anchor/smiley-sans)（SIL OFL）；菜单图集渲染使用[小瀨字體P SC](https://github.com/ButTaiwan/cjktables)（OFL） |

**保持原文**：难度名（Easy/Normal/Hard/VIP）、Credits 页人物引言、部分原作 shitpost 内容。

## 已知限制

- 周卡片大字（TUTORIAL / WEEK 1）与曲目标题图（TRACKLIST）为原版图片，未重绘
- 人名保留英文原文（Cheese、Suzuki、Dearest 等）
- 引擎底层文本（版本号等）保持英文

## 编译

本项目使用 **Haxe 4.2.5 + OpenFL 9.1.0 + Lime 7.9.0 + HXCPP 4.2.1** 编译（原 2021 年依赖组合在
新版库下无法通过类型检查）：

```bash
haxelib install flixel 4.10.0
haxelib install flixel-addons 2.11.0
haxelib install flixel-ui 2.4.0
haxelib install openfl 9.1.0
haxelib install lime 7.9.0
haxelib install hxcpp 4.2.1
haxelib install linc_luajit 0.0.4
haxelib install actuate 1.9.0
haxelib install systools 1.1.0
haxelib install discord_rpc 1.0.0
# extension-webm 需要 Kade 系 fork（带 fuck/changePlaying API）：
haxelib git extension-webm https://github.com/GrowtopiaFli/extension-webm

lime build windows
```

需要 MSVC（VS2019+ Build Tools，含 Windows SDK）。
编译细节与踩坑记录见本仓库 commit 历史。

### ⚠️ 编译常见坑（先看这里）

- **UTF-8 BOM**：本仓库部分含中文的 `.hx` 文件**必须带 UTF-8 BOM**（文件开头 3 字节 `EF BB BF`），
  否则 Haxe 编译器按错误编码解析中文直接报错。如果克隆后编译报"invalid characters"之类的错，
  给对应文件补上 BOM 即可（任何能"另存为 UTF-8 with BOM"的编辑器都行，VS Code 右下角点编码可切换）。
- **换行符**：仓库内 LF / CRLF 混用，Windows 下 git 建议设置 `core.autocrlf=false` 再编译，
  避免无意义的全文件 diff。
- **extension-webm**：必须用上面的 GrowtopiaFli fork（官方 0.0.5 缺 `fuck`/`changePlaying` API，
  本项目源码依赖它们）；克隆后需要自行编译 ndll：
  `haxelib run hxcpp <haxelib路径>/extension-webm/0,0,6/project/Build.xml -Dwindows -DHXCPP_M64`
- **discord_rpc**：haxelib 官方包不含原生 lib，需要从
  [Aidan63/linc_discord-rpc](https://github.com/Aidan63/linc_discord-rpc)（含子模块）把 `lib/`
  复制进 haxelib 的 discord_rpc 目录。

---

## 原版说明（Psych Engine）

Engine originally used on [Mind Games Mod](https://gamebanana.com/mods/301107), intended to be a fix for the vanilla version's many issues while keeping the casual play aspect of it. Also aiming to be an easier alternative to newbie coders.

## Credits:

* Shadow Mario - Coding
* RiverOaken - Arts and Animations

### Special Thanks
* Keoiki - Note Splash Animations

---

## Original Mod Credits / 原模组制作组

* **uniimations** — 美术、动画、音乐、谱面（Cheese 的作者）
* **potionion** — 背景美术、重绘
* **BlueCheese** — 剧本、配音、角色设计
* **OiSuzuki**、**Dansilot** — 配音
* 详见游戏内 Credits 页面

**Original mod**: https://gamebanana.com/mods/623510
**License**: Apache 2.0（见 LICENSE 文件）

---

*本汉化版本与原作团队无官方关联；游玩原版请支持上述原作者。*
