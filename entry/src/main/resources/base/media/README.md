# 蜗牛推箱子美术资源包

这是一套为“蜗牛推箱子”生成的统一风格 2D 游戏资源，整体方向是“森林童话 + 温暖休闲 + 手绘矢量质感”。

## 资源列表

- `snail_player.png`：玩家蜗牛角色，可用于棋盘角色。
- `wood_box.png`：普通木箱。
- `wood_box_deadlock.png`：死角/危险状态木箱。
- `lily_goal.png`：目标点/荷叶码头。
- `moss_wall_tile.png`：苔石墙块。
- `forest_floor_tile.png`：森林地面格。
- `gold_star.png`：通关评级星星。
- `ui_button_primary.png`：金色主按钮底图。
- `ui_button_green.png`：绿色次按钮底图。
- `card_panel_parchment.png`：羊皮纸风格卡片底图。
- `start_page_decoration.png`：启动页藤蔓/荷叶装饰。
- `sparkles.png`：通关、按钮、标题可用的闪光装饰。
- `asset_preview.png`：资源预览图。

## 建议使用位置

把这些 PNG 放入 HarmonyOS 项目的 `entry/src/main/resources/base/media/` 下，然后在 ArkUI 中通过 `$r('app.media.xxx')` 引用。

## 风格注意

- 不建议再混入其他风格差异很大的图标或素材。
- 棋盘元素要保持清晰，尤其是墙、箱子、目标点和蜗牛必须一眼区分。
- 如果用作小尺寸棋盘格，建议优先使用 64px、96px 或 128px 缩放版本测试清晰度。
