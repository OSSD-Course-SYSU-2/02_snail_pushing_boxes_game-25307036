# Codex 直接执行方案：修复 3 个 UI 细节问题

## 目标

只修复以下 3 个页面美感问题，不改玩法逻辑、不改关卡数据、不改存档结构、不改移动规则：

1. “路线总览”中每一关卡片的文字和内部小方框会超过该关的大方框。
2. “继续冒险”“挑战推荐关卡”两个按钮的高光修饰和按钮底色不匹配。
3. 方向键箭头样式不统一，左右箭头出现蓝色 emoji 风格，上下箭头是普通文本风格。

主要修改文件：

```text
entry/src/main/ets/pages/Index.ets
```

必要时只允许给下面文件补充少量颜色常量：

```text
entry/src/main/ets/theme/VisualTheme.ets
```

---

## 问题 1：修复“路线总览”每关内容溢出

### 原因判断

当前“路线总览”复用了通用 `levelCard(levelIndex, true)`。这个卡片内部仍然有较多内容：关卡编号、英文关卡名、难度 pill、状态 pill、三个 `metaCard` 小方框、提示文字、操作提示。

在游玩页右侧窄栏或移动端窄屏下，`Row` 不会自动换行，三个 `metaCard` 和右侧 pill 容易横向挤出外层大方框。

### 修改原则

“路线总览”不要继续使用完整关卡卡片。它应该使用专门的紧凑卡片：

- 不再使用三个内部小方框。
- 改成一行短文本：`目标 1箱 · 标杆 3步 · 纪录 3星`。
- 关卡名最多显示一行，超出省略。
- pill 放在下一行或右侧，但不能挤压标题。
- 每个卡片宽度固定为 `100%`，内部所有元素不得使用会撑破容器的固定宽度。

### 具体改法

#### 1. 修改 `levelRailCard()` 中的 ForEach

找到类似代码：

```ts
ForEach(this.levelIndices(), (levelIndex: number) => {
  this.levelCard(levelIndex, true)
}, (levelIndex: number) => `rail-level-${levelIndex}`)
```

替换为：

```ts
ForEach(this.levelIndices(), (levelIndex: number) => {
  this.railLevelCard(levelIndex)
}, (levelIndex: number) => `rail-level-${levelIndex}`)
```

#### 2. 新增 `railLevelCard` 专用卡片

把下面代码放在 `levelRailCard()` 后面，或者放在 `levelCard()` 前面：

```ts
@Builder
private railLevelCard(levelIndex: number) {
  Column({ space: 8 }) {
    Row({ space: 8 }) {
      Text(`第 ${levelIndex + 1} 关`)
        .fontSize(11)
        .fontColor(Colors.textMutedDark)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      this.railPill(this.levelStateLabel(levelIndex), this.levelStateColor(levelIndex))
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)

    Text(SNAIL_LEVELS[levelIndex].name)
      .fontSize(15)
      .fontWeight(FontWeight.Bold)
      .fontColor(Colors.textDark)
      .width('100%')
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })

    Text(this.railLevelMetaText(levelIndex))
      .fontSize(11)
      .fontColor(Colors.textBrown)
      .lineHeight(16)
      .width('100%')
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })

    Row({ space: 6 }) {
      this.railPill(SNAIL_LEVELS[levelIndex].difficulty, this.difficultyColor(SNAIL_LEVELS[levelIndex].difficulty))

      Text(this.levelActionHint(levelIndex))
        .fontSize(11)
        .fontColor(Colors.successDark)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }
  .alignItems(HorizontalAlign.Start)
  .width('100%')
  .padding({ left: 12, right: 12, top: 12, bottom: 12 })
  .backgroundColor(this.levelCardBackground(levelIndex))
  .border({ width: 1, color: Colors.paperLine })
  .borderRadius(16)
  .shadow({ radius: 8, color: '#00000018', offsetX: 0, offsetY: 3 })
  .onClick(() => this.openLevel(levelIndex))
}
```

#### 3. 新增路线总览专用小 pill

```ts
@Builder
private railPill(label: string, color: string) {
  Text(label)
    .fontSize(10)
    .fontWeight(FontWeight.Medium)
    .fontColor(Colors.title)
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .backgroundColor(color)
    .borderRadius(Radius.pill)
    .maxLines(1)
    .textOverflow({ overflow: TextOverflow.Ellipsis })
}
```

#### 4. 新增路线总览元信息文本

```ts
private railLevelMetaText(levelIndex: number): string {
  return `目标 ${this.levelGoalCount(levelIndex)}箱 · 标杆 ${SNAIL_LEVELS[levelIndex].parMoves}步 · 纪录 ${this.levelRecordShortLabel(levelIndex)}`;
}
```

#### 5. 不要在路线总览中继续使用 `metaCard`

`metaCard` 是较大的内部信息方框，适合首页“关卡总览”，不适合窄栏“路线总览”。

因此不要把 `metaCard` 放进 `railLevelCard`。

### 验收标准

- “路线总览”中每一关的大方框内部不再出现 3 个小方框。
- 关卡名过长时只显示一行，并以省略号收尾。
- 右侧窄栏、移动端竖屏下，任何文字和 pill 都不能超出卡片边界。
- 首页“关卡总览”的完整卡片可以保持原样，不受影响。

---

## 问题 2：修复首页两个主按钮高光和底色不匹配

### 原因判断

`继续冒险` 和 `挑战推荐关卡` 现在使用了不同按钮底图或底色，但高光修饰很可能共用同一种浅黄色/金色高光。

结果是：

- 黄色按钮的高光是合理的。
- 绿色按钮上出现黄色高光，会显得脏、不协调。

### 修改原则

按钮高光必须跟随按钮类型：

- 主按钮 `继续冒险`：金色按钮，使用暖黄色高光。
- 次按钮 `挑战推荐关卡`：绿色按钮，使用浅绿色高光。
- 不要让绿色按钮叠加金色高光。
- 如果按钮底图 `ui_button_primary.png` 和 `ui_button_green.png` 自带高光，代码里就只保留非常弱的顶部柔光，不再额外叠加大面积装饰。

### 具体改法

#### 1. 找到 `heroButton(...)`

当前调用大概率是：

```ts
this.heroButton(this.hasAnyRecord() ? '继续冒险' : '开始游戏', 0, true, true, () => this.continueAdventure())
this.heroButton('挑战推荐关卡', 1, true, true, () => this.playRecommendedLevel())
```

保留调用方式不变。

#### 2. 替换 `heroButton` 内部实现

把 `heroButton` 中不区分类型的高光颜色删除，改成按 `style` 分支处理。

推荐实现：

```ts
@Builder
private heroButton(label: string, style: number, enabled: boolean, block: boolean, handler: () => void) {
  if (block) {
    Stack({ alignContent: Alignment.Center }) {
      this.heroButtonBackground(style)
      this.heroButtonTopHighlight(style)
      this.heroButtonLabel(label, style)
    }
    .width('100%')
    .height(58)
    .opacity(enabled ? 1 : 0.45)
    .shadow({ radius: Shadow.primaryRadius, color: Colors.blackPrimaryShadow, offsetX: 0, offsetY: Shadow.primaryOffsetY })
    .onClick(() => {
      if (enabled) {
        handler();
      }
    })
  } else {
    Stack({ alignContent: Alignment.Center }) {
      this.heroButtonBackground(style)
      this.heroButtonTopHighlight(style)
      this.heroButtonLabel(label, style)
    }
    .layoutWeight(1)
    .height(58)
    .opacity(enabled ? 1 : 0.45)
    .shadow({ radius: Shadow.primaryRadius, color: Colors.blackPrimaryShadow, offsetX: 0, offsetY: Shadow.primaryOffsetY })
    .onClick(() => {
      if (enabled) {
        handler();
      }
    })
  }
}
```

#### 3. 新增按钮背景 builder

```ts
@Builder
private heroButtonBackground(style: number) {
  if (style === 0) {
    Image($r('app.media.ui_button_primary'))
      .width('100%')
      .height('100%')
      .objectFit(ImageFit.Fill)
  } else {
    Image($r('app.media.ui_button_green'))
      .width('100%')
      .height('100%')
      .objectFit(ImageFit.Fill)
  }
}
```

#### 4. 新增按钮顶部高光 builder

```ts
@Builder
private heroButtonTopHighlight(style: number) {
  Column() {
    Blank()
      .width('76%')
      .height(7)
      .backgroundColor(style === 0 ? '#FFF3B899' : '#D7F2BC66')
      .borderRadius(Radius.pill)
      .margin({ top: 9 })

    Blank()
      .layoutWeight(1)
  }
  .width('100%')
  .height('100%')
  .alignItems(HorizontalAlign.Center)
}
```

#### 5. 新增按钮文字 builder

```ts
@Builder
private heroButtonLabel(label: string, style: number) {
  Text(label)
    .fontSize(17)
    .fontWeight(FontWeight.Bold)
    .fontColor(style === 0 ? '#3A2407' : Colors.title)
    .shadow({
      radius: 3,
      color: style === 0 ? '#FFF3B866' : '#0A2B1855',
      offsetX: 0,
      offsetY: 1
    })
}
```

### 验收标准

- `继续冒险` 是金黄色按钮，顶部高光是浅黄色。
- `挑战推荐关卡` 是绿色按钮，顶部高光是浅绿色或柔和白绿光。
- 绿色按钮上不能出现明显金黄色高光。
- 两个按钮的圆角、阴影、文字大小保持一致。

---

## 问题 3：统一方向键箭头样式

### 原因判断

左右方向键很可能使用了带 emoji 变体的字符，例如：

```ts
'◀️'
'▶️'
```

这两个字符串里包含 `FE0F` emoji 变体选择符，所以在部分系统上会被渲染成蓝色 emoji 小方块。上下箭头如果是普通文本字符，就会出现样式不统一。

### 修改原则

不要使用 emoji 箭头。统一使用纯文本箭头，并用 `Text` 自己绘制，不直接把 emoji 字符交给 `Button` 默认渲染。

推荐统一使用：

```text
↑  ←  ↓  →
```

这四个是纯文本箭头，最不容易被系统渲染成彩色 emoji。

### 具体改法

#### 1. 修改 `directionPad()` 中传入的箭头

找到类似代码：

```ts
this.directionButton('上', () => this.moveSnail(-1, 0))
this.directionButton('左', () => this.moveSnail(0, -1))
this.directionButton('下', () => this.moveSnail(1, 0))
this.directionButton('右', () => this.moveSnail(0, 1))
```

或者：

```ts
this.directionButton('▲', ...)
this.directionButton('◀️', ...)
this.directionButton('▼', ...)
this.directionButton('▶️', ...)
```

统一替换成：

```ts
this.directionButton('↑', () => this.moveSnail(-1, 0))
this.directionButton('←', () => this.moveSnail(0, -1))
this.directionButton('↓', () => this.moveSnail(1, 0))
this.directionButton('→', () => this.moveSnail(0, 1))
```

不要使用 `◀️` 和 `▶️`。

如果一定想保留三角箭头，则只能使用无 emoji 变体的字符：

```ts
'▲'
'◀'
'▼'
'▶'
```

注意：`'◀'` 是一个字符，`'◀️'` 是两个字符，后者包含 emoji 变体，不能使用。

#### 2. 替换 `directionButton` 实现

不要再使用系统 `Button(label)` 来直接显示箭头。改用 `Stack + Text`，避免系统自动把字符渲染成 emoji。

推荐实现：

```ts
@Builder
private directionButton(arrow: string, handler: () => void) {
  Stack({ alignContent: Alignment.Center }) {
    Image($r('app.media.ui_button_green'))
      .width('100%')
      .height('100%')
      .objectFit(ImageFit.Fill)
      .opacity(0.92)

    Column() {
      Blank()
        .width('54%')
        .height(5)
        .backgroundColor('#D7F2BC55')
        .borderRadius(Radius.pill)
        .margin({ top: 7 })

      Blank()
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)

    Text(arrow)
      .fontSize(28)
      .fontWeight(FontWeight.Bold)
      .fontColor(Colors.title)
      .fontFamily('HarmonyOS Sans SC')
      .textAlign(TextAlign.Center)
  }
  .width(this.directionButtonWidth())
  .height(this.directionButtonHeight())
  .borderRadius(18)
  .shadow({ radius: Shadow.buttonRadius, color: Colors.blackButtonShadow, offsetX: 0, offsetY: Shadow.buttonOffsetY })
  .onClick(() => handler())
}
```

#### 3. 新增方向键尺寸函数

```ts
private directionButtonWidth(): number {
  return this.isCompactLayout() ? 64 : 68;
}

private directionButtonHeight(): number {
  return this.isCompactLayout() ? 54 : 56;
}
```

#### 4. 修改 `directionPadWidth()`

把原来的固定写法：

```ts
private directionPadWidth(): number {
  return 72 * 3 + 8 * 2;
}
```

替换为：

```ts
private directionPadWidth(): number {
  return this.directionButtonWidth() * 3 + 8 * 2;
}
```

#### 5. 修改方向键占位 Blank 的尺寸

如果 `directionPad()` 中有用于占位的 `Blank()`，不要继续写死 `72` 和 `48`，改成：

```ts
Blank()
  .width(this.directionButtonWidth())
  .height(this.directionButtonHeight())
```

### 验收标准

- 四个方向键都是同一种字体样式。
- 左右箭头不再显示蓝色 emoji 图标。
- 四个按钮大小一致、圆角一致、阴影一致、高光一致。
- 方向键整体仍然居中，三列宽度计算正确。

---

## 最终验收截图要求

Codex 完成后请重点检查以下页面：

1. 首页：确认 `继续冒险` 和 `挑战推荐关卡` 的高光颜色分别匹配金色、绿色按钮。
2. 游玩页棋盘下方方向键：确认四个箭头风格完全统一，没有蓝色 emoji。
3. 游玩页“路线总览”：确认每个关卡卡片内容不再溢出大方框。
4. 窄屏截图：确认路线总览、按钮、方向键都不会横向撑破页面。

---

## 禁止改动

不要改以下内容：

- `SNAIL_LEVELS` 关卡数据。
- `SokobanLogic` 移动、推箱、死角判断逻辑。
- 存档结构和 `SAVE_KEY`。
- 背景音乐和通关音效逻辑。
- 通关评级算法。
