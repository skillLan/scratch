//
//  SLScratchMask.swift
//  ScratchDemo
//
//  Created by skill on 2019/4/1.
//  Copyright © 2019 skillLan. All rights reserved.
//
//  刮奖涂层

import UIKit
import SnapKit

class SLScratchMask: UIImageView {

    weak var delegate: SLScratchCardDelegate?
    // 线条形状
    var lineType: CGLineCap!
    // 线条粗细
    var lineWidth: CGFloat!
    // 保存上一次停留的位置
    var lastPoint: CGPoint?
    
    /// 中奖标题提示
    fileprivate var promptLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        label.textColor = UIColor(hex: 0x999999)
        label.textAlignment = .center
        label.text = "刮我中大奖"
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 当前视图可交互
        isUserInteractionEnabled = true
        
        self.addSubview(promptLabel)
        promptLabel.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 触摸开始
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 多点触摸只考虑第一点
        guard  let touch = touches.first else {
            return
        }
        self.promptLabel.isHidden = true
        // 保存当前点坐标
        lastPoint = touch.location(in: self)
        
        // 调用相应的代理方法
        delegate?.scratchBegan?(point: lastPoint!)
    }
    
    /// 滑动
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 多点触摸只考虑第一点
        guard  let touch = touches.first, let point = lastPoint, let img = image else {
            return
        }
        
        // 获取最新触摸点坐标
        let newPoint = touch.location(in: self)
        // 清除两点间的涂层
        eraseMask(fromPoint: point, toPoint: newPoint)
        // 保存最新触摸点坐标，供下次使用
        lastPoint = newPoint
        
        //计算刮开面积的百分比
        let progress = getAlphaPixelPercent(img: img)
        // 调用相应的代理方法
        delegate?.scratchMoved?(progress: progress)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 多点触摸只考虑第一点
        guard  touches.first != nil else {
            return
        }
        
        // 调用相应的代理方法
        delegate?.scratchEnded?(point: lastPoint!)
    }
    
    //清除两点间的涂层
    func eraseMask(fromPoint: CGPoint, toPoint: CGPoint) {
        // 根据size大小创建一个基于位图的图形上下文
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, UIScreen.main.scale)
        
        // 先将图片绘制到上下文中
        image?.draw(in: self.bounds)
        
        // 再绘制线条
        let path = CGMutablePath()
        path.move(to: fromPoint)
        path.addLine(to: toPoint)
        
        let context = UIGraphicsGetCurrentContext()!
        context.setShouldAntialias(true)
        context.setLineCap(lineType)
        context.setLineWidth(lineWidth)
        context.setBlendMode(.clear) // 混合模式设为清除
        context.addPath(path)
        context.strokePath()
        
        // 将二者混合后的图片显示出来
        image = UIGraphicsGetImageFromCurrentImageContext()
        // 结束图形上下文
        UIGraphicsEndImageContext()
    }
    
    /// 获取透明像素占总像素的百分比
    private func getAlphaPixelPercent(img: UIImage) -> Float {
        // 计算像素总个数
        let width = Int(img.size.width)
        let height = Int(img.size.height)
        let bitmapByteCount = width * height
        
        // 得到所有像素数据
        let pixelData = UnsafeMutablePointer<UInt8>.allocate(capacity: bitmapByteCount)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: pixelData,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: width,
                                space: colorSpace,
                                bitmapInfo: CGBitmapInfo(rawValue:
                                    CGImageAlphaInfo.alphaOnly.rawValue).rawValue)!
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.clear(rect)
        context.draw(img.cgImage!, in: rect)
        
        // 计算透明像素个数
        var alphaPixelCount = 0
        for x in 0...Int(width) {
            for y in 0...Int(height) {
                if pixelData[y * width + x] == 0 {
                    alphaPixelCount += 1
                }
            }
        }
        free(pixelData)
        return Float(alphaPixelCount) / Float(bitmapByteCount)
    }

}

// MARK: - 颜色十六进制转换
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
    
    convenience init(hex: Int, alpha: CGFloat) {
        self.init(red: CGFloat((hex >> 16) & 0xff) / 255.0, green: CGFloat((hex >> 8) & 0xff) / 255.0, blue: CGFloat(hex & 0xff) / 255.0, alpha: alpha)
    }
    
    // 返回随机颜色
    class var randomColor: UIColor {
        get {
            let red = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue = CGFloat(arc4random()%256)/255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
    
    convenience init(hexStr: String ,alpha: CGFloat = 1) {
        let newStr = hexStr.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: newStr)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        self.init(red: CGFloat(r) / 0xff ,green: CGFloat(g) / 0xff ,blue: CGFloat(b) / 0xff, alpha: 1)
    }
}
