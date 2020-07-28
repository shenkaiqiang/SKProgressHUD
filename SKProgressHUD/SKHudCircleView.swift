//
//  SKHudCircleView.swift
//  shen
//
//  Created by 沈凯强 on 2021/01/01.
//  Copyright © 2021 mn. All rights reserved.
//

import UIKit
/// 不停旋转的圆环View,可用于展示状态
class SKHudCircleView: UIView {

    private var gradientLayer:CALayer?
    /// 路径颜色
    var strokeColor:UIColor? {
        didSet {
            updateGradientCircleLayer()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        strokeColor = UIColor.black
        updateGradientCircleLayer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateGradientCircleLayer), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // 圆形渐变色指示器,旋转
    @objc private func updateGradientCircleLayer() {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
        
        gradientLayer = SKGradientCircleLayer.init(circleSize:frame.size, circleCenter: CGPoint.init(x: frame.width/2, y: frame.height/2), from: UIColor.clear, to: strokeColor, lineWidth: 2)
        layer.addSublayer(gradientLayer!)
        let animtion = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animtion.duration = 1
        animtion.isRemovedOnCompletion = true
        animtion.fromValue = -CGFloat.pi/2
        animtion.toValue = CGFloat.pi*3/2
        animtion.repeatCount = Float.greatestFiniteMagnitude
        layer.add(animtion, forKey: nil)
    }
}

/// 渐变色的圆环layer
private class SKGradientCircleLayer: CALayer {
    
    convenience init(circleSize:CGSize, circleCenter:CGPoint, from startColor:UIColor?,to endColor:UIColor?, lineWidth:CGFloat) {
        self.init()
        bounds = CGRect.init(x: 0, y: 0, width: circleSize.width, height: circleSize.height)
        position = circleCenter
        let point00 = CGPoint.init(x: 0, y: 0),point10 = CGPoint.init(x: 1, y: 0),point11 = CGPoint.init(x: 1, y: 1),point01 = CGPoint.init(x: 0, y: 1)
        let startPoints = [point00,point10,point11,point01]
        let endPoints = [point11,point01,point00,point10]
        let positions = getPositions(bounds: bounds)
        let colors = getGradientColors(from: startColor, to: endColor, count: positions.count)
        for index in 0..<positions.count {
            let graint = CAGradientLayer.init()
            graint.bounds = CGRect.init(x: 0, y: 0, width: bounds.width/2, height: bounds.height/2)
            graint.position = positions[index]
            let color1 = colors[index]
            let color2 = colors[index+1]
            graint.colors = [color1.cgColor,color2.cgColor]
            let point1:NSNumber = 0
            let point2:NSNumber = 1
            graint.locations = [point1,point2]
            graint.startPoint = startPoints[index]
            graint.endPoint = endPoints[index]
            addSublayer(graint)
            // Set mask
            let shapelayer = CAShapeLayer.init()
            let rect = CGRect.init(x: 0, y: 0, width: bounds.width-lineWidth*2, height: bounds.height-lineWidth*2)
            shapelayer.bounds = rect
            shapelayer.position = CGPoint.init(x: bounds.width/2, y: bounds.height/2)
            shapelayer.fillColor = UIColor.clear.cgColor
            shapelayer.strokeColor = UIColor.black.cgColor
            shapelayer.lineWidth = lineWidth
            shapelayer.lineCap = CAShapeLayerLineCap.round
            shapelayer.path = UIBezierPath.init(roundedRect: rect, cornerRadius: rect.width/2).cgPath
            shapelayer.strokeStart = 0.015
            shapelayer.strokeEnd = 0.985
            mask = shapelayer
        }
    }
    
    private func getPositions(bounds:CGRect) -> [CGPoint] {
        let width = bounds.width
        let height = bounds.height
        let xPoint = width/4
        let yPoint = height/4
        let first = CGPoint.init(x: xPoint*3, y: yPoint*1)
        let second = CGPoint.init(x: xPoint*3, y: yPoint*3)
        let third = CGPoint.init(x: xPoint*1, y: yPoint*3)
        let fourth = CGPoint.init(x: xPoint*1, y: yPoint*1)
        return [first,second,third,fourth]
    }
    private func getGradientColors(from startColor:UIColor?,to endColor:UIColor?,count:Int) -> [UIColor] {
        var fromR:CGFloat = 0,fromG:CGFloat = 0,fromB:CGFloat = 0,fromAlpha:CGFloat = 0
        startColor?.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromAlpha)
        var endR:CGFloat = 0,endG:CGFloat = 0,endB:CGFloat = 0,endAlpha:CGFloat = 0
        endColor?.getRed(&endR, green: &endG, blue: &endB, alpha: &endAlpha)
        var colors:[UIColor] = Array.init()
        for index in 0...count {
            let r = fromR + (endR-fromR)/CGFloat(count) * CGFloat(index)
            let g = fromG + (endG-fromG)/CGFloat(count) * CGFloat(index)
            let b = fromB + (endB-fromB)/CGFloat(count) * CGFloat(index)
            let alpha = fromAlpha + (endAlpha-fromAlpha)/CGFloat(count) * CGFloat(index)
            let color = UIColor.init(red: r, green: g, blue: b, alpha: alpha)
            colors.append(color)
        }
        return colors
    }
}
