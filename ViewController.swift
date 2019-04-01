//
//  ViewController.swift
//  ScratchDemo
//
//  Created by skill on 2019/4/1.
//  Copyright © 2019 skillLan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var scratchCardView: SLScratchCardView!
    
    /// 中奖
    var state: WinningState = .notWinning
    
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for button in buttons {
            button.layer.cornerRadius = button.bounds.height / 2
            button.layer.borderWidth = 0.5
            button.layer.borderColor = button.tag == 0 ? UIColor.gray.cgColor : UIColor.red.cgColor
        }
    }

    /// 按钮事件
    ///
    /// - Parameter sender: 当前按钮
    @IBAction func buttonClick(_ sender: UIButton) {
        self.state = sender.tag == 0 ? .notWinning : .winning
        createScratchCardView(state: self.state)
    }
    
    /// 刮奖UI
    ///
    /// - Parameter state: 中奖状态
    func createScratchCardView(state: WinningState) {
        //创建刮刮卡组件
        let scratchCard = SLScratchCardView(frame: UIScreen.main.bounds, state: state)
        //设置代理
        scratchCard.delegate = self
        self.scratchCardView = scratchCard
        self.view.addSubview(scratchCard)
    }

}

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
        // 一下根据实际情况来
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

