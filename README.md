# 刮奖组件

一个使用 Swift 实现类似支付宝刮奖功能。

## 演示

![演示](.github/example.gif)

## 使用

```swift
func createScratchCardView(state: WinningState) {
    //创建刮刮卡组件
    let scratchCard = SLScratchCardView(frame: UIScreen.main.bounds, state: state)
    //设置代理
    scratchCard.delegate = self
    self.scratchCardView = scratchCard
    self.view.addSubview(scratchCard)
}
```
实现 `SLScratchCardDelegate` 协议：

```swift
extension ViewController: SLScratchCardDelegate {
    /// 滑动开始
    func scratchBegan(point: CGPoint) {
        print("开始刮奖：\(point)")
    }
    
    /// 滑动过程
    func scratchMoved(progress: Float) {
        let currentProgress = progress * 100
        print("当前进度：\(progress)")
        // 显示百分比
        let percent = String(format: "%.1f", progress * 100)
        print("刮开了：\(percent)%")
        // 以下根据实际情况来
        if currentProgress > 5 {
            self.scratchCardView.promptLabel.text = self.state.name
        }
        // 刮开 20%,就全部刮掉
        if currentProgress > 20 {
            self.scratchCardView.scratchMask.isHidden = true
        }
    }
    
    /// 滑动结束
    func scratchEnded(point: CGPoint) {
        print("停止刮奖：\(point)")
    }
}
```

## License

使用 MIT 协议开源
