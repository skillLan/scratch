//
//  SLScratchCardView.swift
//  ScratchDemo
//
//  Created by skill on 2019/4/1.
//  Copyright © 2019 skillLan. All rights reserved.
//  奖项 UI

import UIKit

enum WinningState {
    /// 未中奖
    case notWinning
    /// 中奖了
    case winning
    
    var name: String {
        switch self {
        case .notWinning:
            return "很遗憾，未中奖。"
        case .winning:
            return "恭喜您，中奖啦～"
        }
    }
}

/// 刮刮卡代理协议
@objc protocol SLScratchCardDelegate {
    @objc optional func scratchBegan(point: CGPoint)
    @objc optional func scratchMoved(progress: Float)
    @objc optional func scratchEnded(point: CGPoint)
    @objc optional func scratchCardViewClick(tag: Int)
}

class SLScratchCardView: UIView {
    /// 中奖状态
    var winningState: WinningState = .notWinning
    /// 底层券面图片
    var couponImageView: UIImageView!
    /// 刮刮卡代理对象
    weak var delegate: SLScratchCardDelegate? {
        didSet {
            scratchMask.delegate = delegate
        }
    }
    
    /// 黑色背景图片
    fileprivate var blackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(hex: 0x000000, alpha: 0.5)
        return imageView
    }()
    
    /// 刮奖背景图片
    public var bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "ggk_bg_bottom")
        return imageView
    }()
    
    /// 刮奖结果背景图片
    fileprivate var resultsBGImageView: UIImageView = {
        let imageView = UIImageView()
        //        imageView.contentMode = .scaleAspectFill
        //        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "ggk_img_prize")
        return imageView
    }()
    
    /// 涂层
    var scratchMask: SLScratchMask!
    
    /// 关闭按钮
    fileprivate lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        var image = UIImage(named: "pop_icon_close")
        btn.setImage(image, for: .normal)
        btn.tag = 0
        btn.addTarget(self, action: #selector(buttonEvent), for: .touchUpInside)
        return btn
    }()
    
    /// 中奖标题提示
    public var promptLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        label.textColor = UIColor(hex: 0xffffff)
        label.textAlignment = .center
        label.text = "恭喜您\n获得1张刮刮卡"
        return label
    }()
    
    /// 未中奖
    fileprivate var notWinningLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        label.textColor = UIColor(hex: 0xFF7A07)
        label.text = "谢谢参与"
        label.textAlignment = .center
        return label
    }()

    /// 中奖背景图片
    fileprivate var bgWinningImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "ggk_img_gift")
        return imageView
    }()
    
    /// 大礼包和艾豆中奖提示
    fileprivate var winningLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .medium)
        label.textColor = UIColor(hex: 0xffffff)
        label.textAlignment = .center
        return label
    }()

    /// 底部提示
    fileprivate var groupNumberButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 9.0, weight: .medium)
        btn.setTitleColor(UIColor(hex: 0x999999), for: .normal)
        btn.tag = 1
        btn.addTarget(self, action: #selector(buttonEvent), for: .touchUpInside)
        return btn
    }()
    
    public init(frame: CGRect, state: WinningState) {
        super.init(frame: frame)
        self.frame = UIScreen.main.bounds
        self.winningState = state
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.addSubview(blackImageView)
        blackImageView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        self.addSubview(bgImageView)
        bgImageView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        self.addSubview(resultsBGImageView)
        resultsBGImageView.snp.makeConstraints { (make) in
            make.leading.equalTo(bgImageView.snp.leading).offset(70)
            make.trailing.equalTo(bgImageView.snp.trailing).offset(-70)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(20)
        }
        
        self.addSubview(promptLabel)
        promptLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(resultsBGImageView.snp.top).offset(-15)
            make.leading.equalTo(bgImageView.snp.leading).offset(41)
            make.trailing.equalTo(bgImageView.snp.trailing).offset(-41)
        }
        
        self.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (make) in
            make.top.equalTo(resultsBGImageView.snp.bottom).offset(60)
            make.size.equalTo(CGSize(width: 44, height: 44))
            make.centerX.equalToSuperview()
        }
        
        switch winningState {
        case .notWinning:
            resultNotWinningUI()
        case .winning:
            resultWinningUI()
            config()
        }
    }
    
    func config() {
        winningLabel.text = "100元大礼包"
        let titleString = "可在XX查看"
        groupNumberButton.setTitle(titleString, for: .normal)
    }
    
    /// 未中奖
    func resultNotWinningUI() {
        self.addSubview(notWinningLabel)
        notWinningLabel.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalTo(resultsBGImageView)
        }
        createScratchUI()
    }
    
    /// 中奖了
    func resultWinningUI() {
        
        self.addSubview(groupNumberButton)
        groupNumberButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(resultsBGImageView.snp.bottom).offset(-11)
            make.leading.equalTo(resultsBGImageView.snp.leading).offset(5)
            make.trailing.equalTo(resultsBGImageView.snp.trailing).offset(-5)
        }
        
        self.addSubview(bgWinningImageView)
        bgWinningImageView.snp.makeConstraints { (make) in
            make.top.equalTo(resultsBGImageView.snp.top).offset(16)
            make.bottom.equalTo(groupNumberButton.snp.top).offset(-5)
            make.leading.equalTo(resultsBGImageView.snp.leading).offset(16)
            make.trailing.equalTo(resultsBGImageView.snp.trailing).offset(-16)
        }
        
        self.addSubview(winningLabel)
        winningLabel.snp.makeConstraints { (make) in
            make.center.equalTo(bgWinningImageView)
            make.leading.trailing.equalTo(bgWinningImageView)
        }
        
        createScratchUI()
    }
    
    /// 添加涂层
    func createScratchUI() {
        let frame = CGRect(x: 0, y: 0, width: 0, height: 86)
        scratchMask = SLScratchMask(frame: frame)
        scratchMask.image = UIImage(named: "ggk_img_shave")
        scratchMask.lineWidth = 11
        scratchMask.lineType = .square
        self.addSubview(scratchMask)
        scratchMask.snp.updateConstraints { (make) in
            make.top.leading.equalTo(resultsBGImageView).offset(5)
            make.trailing.bottom.equalTo(resultsBGImageView).offset(-5)
        }
    }
    
    @objc fileprivate func buttonEvent(button: UIButton) {
        if button.tag == 0 {
            removeCurrentView()
        }
        delegate?.scratchCardViewClick?(tag: button.tag)
    }
    
    func removeCurrentView() {
        self.removeFromSuperview()
    }
}
