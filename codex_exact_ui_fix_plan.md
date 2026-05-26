# Codex 精确修改指令：修复按钮高光不匹配与关卡卡片溢出

## 修改范围

只修改页面 UI 表现，不改玩法逻辑、关卡数据、存档数据、移动规则、音频逻辑。

目标文件：

```text
entry/src/main/ets/pages/Index.ets
entry/src/main/ets/theme/VisualTheme.ets
```

当前仍有两个明显问题：

1. 首页的「继续冒险」「挑战推荐关卡」按钮顶部高光颜色和按钮主体颜色不匹配。
2. 「关卡总览 / 路线总览」里的单个关卡卡片内容溢出，文字、内部小框、星星和提示文字超过该关大方框。

以下指令必须全部执行。

---

## 一、修复首页两个大按钮的颜色问题

### 1. 不要继续直接使用 `ui_button_primary.png` 和 `ui_button_green.png` 作为首页两个大按钮背景

这两个 PNG 资源自带顶部高光、边缘点缀和阴影，导致现在出现：

- 金色按钮顶部高光偏粉橙。
- 绿色按钮顶部高光偏黄。
- 两个按钮的装饰色和主体色不统一。

在 `heroButton(...)` 里删除或禁用下面这种背景图写法：

```ts
Image($r('app.media.ui_button_primary'))
Image($r('app.media.ui_button_green'))
```

改为用 ArkUI 的 `Stack + Blank + Text` 直接绘制按钮。这样颜色完全可控。

### 2. 新增以下颜色辅助函数

把这些函数加到 `Index` 类内部，放在 `heroButton(...)` 附近即可。

```ts
private heroButtonBaseColor(styleIndex: number): string {
  // 0 = 继续冒险 / 主按钮；1 = 挑战推荐关卡 / 次按钮
  return styleIndex === 0 ? '#D99635' : '#2F7A51';
}

private heroButtonBorderColor(styleIndex: number): string {
  return styleIndex === 0 ? '#7B4A16' : '#174B2E';
}

private heroButtonTopHighlightColor(styleIndex: number): string {
  // 主按钮顶部高光：暖奶油黄，不要用粉橙
  // 绿按钮顶部高光：浅叶绿，不要用黄色
  return styleIndex === 0 ? '#FFE6A6' : '#BFE8A6';
}

private heroButtonBottomShadeColor(styleIndex: number): string {
  return styleIndex === 0 ? '#A96620' : '#1E5B3A';
}

private heroButtonTextColor(styleIndex: number): string {
  return styleIndex === 0 ? '#3A2407' : '#FFF7E6';
}

private heroButtonTextShadowColor(styleIndex: number): string {
  return styleIndex === 0 ? '#FFF0B866' : '#0B241866';
}
```

### 3. 把 `heroButton(...)` 整体改成代码绘制按钮

找到当前的：

```ts
@Builder
private heroButton(label: string, styleIndex: number, enabled: boolean, block: boolean, handler: () => void) {
  ...
}
```

将它整体替换为下面的结构。注意：不要放任何 `ui_button_primary` 或 `ui_button_green` 图片。

```ts
@Builder
private heroButton(label: string, styleIndex: number, enabled: boolean, block: boolean, handler: () => void) {
  if (block) {
    Stack() {
      Blank()
        .width('100%')
        .height('100%')
        .backgroundColor(this.heroButtonBaseColor(styleIndex))
        .border({ width: 2, color: this.heroButtonBorderColor(styleIndex) })
        .borderRadius(Radius.button)

      Column() {
        Blank()
          .width('84%')
          .height(5)
          .backgroundColor(this.heroButtonTopHighlightColor(styleIndex))
          .borderRadius(999)
          .opacity(enabled ? 0.95 : 0.28)

        Blank()
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding({ top: 7 })
      .alignItems(HorizontalAlign.Center)

      Column() {
        Blank()
          .layoutWeight(1)

        Blank()
          .width('90%')
          .height(4)
          .backgroundColor(this.heroButtonBottomShadeColor(styleIndex))
          .borderRadius(999)
          .opacity(enabled ? 0.28 : 0.12)
      }
      .width('100%')
      .height('100%')
      .padding({ bottom: 5 })
      .alignItems(HorizontalAlign.Center)

      Text(label)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.heroButtonTextColor(styleIndex))
        .textAlign(TextAlign.Center)
        .shadow({ radius: 3, color: this.heroButtonTextShadowColor(styleIndex), offsetX: 0, offsetY: 1 })
    }
    .width('100%')
    .height(60)
    .opacity(enabled ? 1 : 0.42)
    .shadow({ radius: Shadow.primaryRadius, color: Colors.blackPrimaryShadow, offsetX: 0, offsetY: Shadow.primaryOffsetY })
    .onClick(() => {
      if (enabled) {
        handler();
      }
    })
  } else {
    Stack() {
      Blank()
        .width('100%')
        .height('100%')
        .backgroundColor(this.heroButtonBaseColor(styleIndex))
        .border({ width: 2, color: this.heroButtonBorderColor(styleIndex) })
        .borderRadius(Radius.button)

      Column() {
        Blank()
          .width('84%')
          .height(5)
          .backgroundColor(this.heroButtonTopHighlightColor(styleIndex))
          .borderRadius(999)
          .opacity(enabled ? 0.95 : 0.28)

        Blank()
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding({ top: 7 })
      .alignItems(HorizontalAlign.Center)

      Column() {
        Blank()
          .layoutWeight(1)

        Blank()
          .width('90%')
          .height(4)
          .backgroundColor(this.heroButtonBottomShadeColor(styleIndex))
          .borderRadius(999)
          .opacity(enabled ? 0.28 : 0.12)
      }
      .width('100%')
      .height('100%')
      .padding({ bottom: 5 })
      .alignItems(HorizontalAlign.Center)

      Text(label)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.heroButtonTextColor(styleIndex))
        .textAlign(TextAlign.Center)
        .shadow({ radius: 3, color: this.heroButtonTextShadowColor(styleIndex), offsetX: 0, offsetY: 1 })
    }
    .layoutWeight(1)
    .height(60)
    .opacity(enabled ? 1 : 0.42)
    .shadow({ radius: Shadow.primaryRadius, color: Colors.blackPrimaryShadow, offsetX: 0, offsetY: Shadow.primaryOffsetY })
    .onClick(() => {
      if (enabled) {
        handler();
      }
    })
  }
}
```

### 4. 按钮颜色验收标准

修改后截图中应该满足：

- 「继续冒险」主体色是橙金色 `#D99635`。
- 「继续冒险」顶部高光是奶油黄 `#FFE6A6`。
- 「继续冒险」边框是深棕色 `#7B4A16`。
- 「挑战推荐关卡」主体色是森林绿 `#2F7A51`。
- 「挑战推荐关卡」顶部高光是浅叶绿 `#BFE8A6`。
- 「挑战推荐关卡」边框是深绿 `#174B2E`。
- 绿色按钮上不允许出现黄色、橙色、粉色高光。
- 两个按钮上不再出现左右小圆点装饰。

---

## 二、修复关卡卡片内容溢出

### 1. 关卡卡片不要再用固定高度的 `card_panel_parchment.png` 做内层背景

当前截图里「第 1 关 / Garden Gate」上方有一条棕色横线压住文字，底部提示文字也超过内层方框。这通常是因为内层卡片用了固定大小的图片背景，内容高度变化后就会溢出。

在 `levelCard(...)` 中删除或禁用下面这种写法：

```ts
Image($r('app.media.card_panel_parchment'))
```

关卡卡片改为纯 ArkUI 自适应背景：

```ts
.backgroundColor(Colors.paper)
.border({ width: 1, color: Colors.paperLine })
.borderRadius(22)
.shadow({ radius: 12, color: '#00000022', offsetX: 0, offsetY: 5 })
```

不要给关卡卡片设置固定高度。不要使用 `.height(180)`、`.height(200)` 这类固定高度。让卡片随内容自动撑开。

### 2. 首页「关卡总览」在小屏幕下必须使用紧凑卡片

找到 `levelOverviewCard()` 里的：

```ts
ForEach(this.levelIndices(), (levelIndex: number) => {
  this.levelCard(levelIndex, false)
}, (levelIndex: number) => `home-level-${levelIndex}`)
```

改成：

```ts
ForEach(this.levelIndices(), (levelIndex: number) => {
  this.levelCard(levelIndex, this.isCompactLayout())
}, (levelIndex: number) => `home-level-${levelIndex}`)
```

这样手机宽度下不会继续展示完整大卡片布局。

### 3. `levelCard(...)` 中的 3 个内部小方框只允许在宽屏完整卡片里显示

找到 `levelCard(levelIndex: number, compact: boolean)` 里类似下面的区域：

```ts
Row({ space: 8 }) {
  this.metaCard('目标', `${this.levelGoalCount(levelIndex)} 箱`)
  this.metaCard('标杆', `${SNAIL_LEVELS[levelIndex].parMoves} 步`)
  this.metaCard('纪录', this.levelRecordShortLabel(levelIndex))
}
.width('100%')
```

改成：

```ts
if (!compact && !this.isCompactLayout()) {
  Row({ space: 8 }) {
    this.metaCard('目标', `${this.levelGoalCount(levelIndex)} 箱`)
    this.metaCard('标杆', `${SNAIL_LEVELS[levelIndex].parMoves} 步`)
    this.metaCard('纪录', this.levelRecordShortLabel(levelIndex))
  }
  .width('100%')
} else {
  Text(`目标 ${this.levelGoalCount(levelIndex)} 箱 · 标杆 ${SNAIL_LEVELS[levelIndex].parMoves} 步 · 纪录 ${this.levelRecordShortLabel(levelIndex)}`)
    .fontSize(12)
    .fontWeight(FontWeight.Medium)
    .fontColor(Colors.textBrown)
    .maxLines(1)
    .textOverflow({ overflow: TextOverflow.Ellipsis })
    .width('100%')
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
    .backgroundColor('#FFF4D7')
    .border({ width: 1, color: '#E1B987' })
    .borderRadius(14)
}
```

这一步是关键：手机和右侧窄栏不要再放三个横向小方框，否则必然挤出。

### 4. 给关卡卡片所有长文本加最大行数和省略号

在 `levelCard(...)` 中修改以下文本。

关卡编号：

```ts
Text(`第 ${levelIndex + 1} 关`)
  .fontSize(12)
  .fontColor(Colors.textMutedDark)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
```

关卡名：

```ts
Text(SNAIL_LEVELS[levelIndex].name)
  .fontSize(compact || this.isCompactLayout() ? 18 : 20)
  .fontWeight(FontWeight.Bold)
  .fontColor(Colors.textDark)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
```

副标题：

```ts
Text(SNAIL_LEVELS[levelIndex].subtitle)
  .fontSize(13)
  .lineHeight(20)
  .fontColor(Colors.textBrown)
  .maxLines(compact || this.isCompactLayout() ? 2 : 3)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .width('100%')
```

提示：

```ts
Text(SNAIL_LEVELS[levelIndex].hint)
  .fontSize(12)
  .lineHeight(18)
  .fontColor(Colors.successDark)
  .maxLines(compact || this.isCompactLayout() ? 2 : 3)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .width('100%')
```

操作提示：

```ts
Text(this.levelActionHint(levelIndex))
  .fontSize(12)
  .fontColor(Colors.successDark)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .width('100%')
```

### 5. 缩小状态胶囊，避免右侧两个胶囊挤压标题

如果 `levelCard(...)` 右侧有两个竖排胶囊：难度、通关状态，请把它们控制在固定宽度内。

在右侧胶囊容器上加：

```ts
.width(72)
.alignItems(HorizontalAlign.End)
```

并且胶囊文字加：

```ts
.maxLines(1)
.textOverflow({ overflow: TextOverflow.Ellipsis })
```

如果当前 `pill(...)` 是通用组件，不要全局缩小所有 pill。为关卡卡片新增一个小胶囊：

```ts
@Builder
private levelSmallPill(label: string, color: string) {
  Text(label)
    .fontSize(12)
    .fontWeight(FontWeight.Bold)
    .fontColor(Colors.white)
    .textAlign(TextAlign.Center)
    .maxLines(1)
    .textOverflow({ overflow: TextOverflow.Ellipsis })
    .width(62)
    .height(30)
    .backgroundColor(color)
    .border({ width: 1, color: Colors.gold })
    .borderRadius(999)
}
```

然后在 `levelCard(...)` 里用：

```ts
this.levelSmallPill(SNAIL_LEVELS[levelIndex].difficulty, this.difficultyColor(SNAIL_LEVELS[levelIndex].difficulty))
this.levelSmallPill(this.levelStateLabel(levelIndex), this.levelStateColor(levelIndex))
```

不要用普通 `pill(...)`。

### 6. 卡片整体推荐样式

把 `levelCard(...)` 最外层样式调整为：

```ts
.width('100%')
.padding(compact || this.isCompactLayout() ? 14 : 18)
.backgroundColor(Colors.paper)
.border({ width: 1, color: Colors.paperLine })
.borderRadius(22)
.shadow({ radius: 12, color: '#00000022', offsetX: 0, offsetY: 5 })
.clip(true)
.onClick(() => this.openLevel(levelIndex))
```

注意：

- 不要设置固定 `.height(...)`。
- 不要再在卡片内部叠一层固定高度的图片背景。
- `.clip(true)` 可以防止星星、荷叶装饰、提示文字视觉上跑出圆角边界。
- 内层布局必须 `.width('100%')`。

---

## 三、路线总览右侧窄栏必须使用专用简化卡片

如果 `levelRailCard()` 当前还在调用：

```ts
this.levelCard(levelIndex, true)
```

请替换为：

```ts
this.railLevelCard(levelIndex)
```

新增以下 builder：

```ts
@Builder
private railLevelCard(levelIndex: number) {
  Column({ space: 8 }) {
    Row({ space: 8 }) {
      Column({ space: 3 }) {
        Text(`第 ${levelIndex + 1} 关`)
          .fontSize(11)
          .fontColor(Colors.textMutedDark)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(SNAIL_LEVELS[levelIndex].name)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textDark)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      this.levelSmallPill(this.levelStateLabel(levelIndex), this.levelStateColor(levelIndex))
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)

    Text(`目标 ${this.levelGoalCount(levelIndex)} 箱 · 标杆 ${SNAIL_LEVELS[levelIndex].parMoves} 步 · 纪录 ${this.levelRecordShortLabel(levelIndex)}`)
      .fontSize(12)
      .fontColor(Colors.textBrown)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .width('100%')

    Text(this.levelActionHint(levelIndex))
      .fontSize(12)
      .fontColor(Colors.successDark)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .width('100%')
  }
  .width('100%')
  .padding(12)
  .backgroundColor(this.levelCardBackground(levelIndex))
  .border({ width: 1, color: Colors.paperLine })
  .borderRadius(18)
  .clip(true)
  .onClick(() => this.openLevel(levelIndex))
}
```

这张卡不要显示：

- 3 个内部小方框。
- 关卡长副标题。
- 大星星区域。
- 装饰荷叶、蜗牛、木箱图标。

右侧路线总览只需要短信息，不要复用首页大卡片。

---

## 四、最终验收

修改完成后检查截图。

首页按钮：

- 金色按钮高光必须是 `#FFE6A6`。
- 绿色按钮高光必须是 `#BFE8A6`。
- 绿色按钮不能出现黄色、橙色、粉色横线。
- 两个按钮不再出现和主体不匹配的小圆点装饰。

关卡卡片：

- 「第 1 关」不被顶部横线压住。
- `Garden Gate` 不被状态胶囊挤压。
- 三个内部小方框在手机或右侧窄栏中不出现，改为一行短文本。
- 绿色提示文字和“点击重玩并刷新成绩”必须在该关卡片内部。
- 任何星星、图标、文字都不能跑出卡片圆角。
- 卡片不能设置固定高度，必须根据内容自动撑开。
