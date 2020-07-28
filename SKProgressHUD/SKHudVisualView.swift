//
//  SKHudVisualView.swift
//  shen
//
//  Created by 沈凯强 on 2021/01/01.
//  Copyright © 2021 mn. All rights reserved.
//

import UIKit
/// HUD中间的可视部分视图
class SKHudVisualView: UIView {

    // 指示器显示模式
    enum SKHUDIndicatorMode {
        /// 默认模式,使用系统自带的指示器(UIActivityIndicatorView) ,不能显示进度,只能不停地转呀转
        case defaultIndicator
        /// 自定义的圆形的指示器,,不能显示进度,只能不停地转呀转
        case circleGradientIndicator
        /// 不显示指示器,只显示文字
        case none
    }
    // 指示器显示模式,默认指示器是菊花
    var indicatorMode:SKHUDIndicatorMode = .defaultIndicator {
        didSet {
            if indicatorMode != oldValue {
                updateIndicators() // 重新设置指示器
            }
        }
    }
    // 自定义指示器视图
    private var indicatorView:UIView?
    // 中间可视部分的背景颜色和文字颜色风格
    enum SKHUDVisualStyle {
        /// default style, white HUD with black text, HUD background will be blurred
        case light
        /// black HUD and white text, HUD background will be blurred
        case dark
    }
    /// 中间可视部分的背景颜色和文字颜色风格
    var visualStyle:SKHUDVisualStyle = .dark {
        didSet {
            updateVisualColor()
        }
    }
    // 文本视图
    var textView:SKHudTextView?
    // 外边距,默认为20
    private let bezelMargin:CGFloat = 20
    // 内边距,默认为20
    private let bezelPadding:CGFloat = 20
    
    // The minimum size of the HUD bezel. Defaults to CGSizeZero (no minimum size).
    private let minSize = CGSize.init(width: 150, height: 70)
    
    // 中间的提示框呈方形显示,默认 false
    var isSquare = false {
        didSet {
            updateSubviewsFrame() // 重新布局子视图
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        textView = SKHudTextView.init()
        addSubview(textView!)
        updateVisualColor()
        updateIndicators()
        registerForKVO()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        unregisterForKVO()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSubviewsFrame()
    }
    // MARK:-- KVO
    private func registerForKVO() {
        let keypath = "text"
        textView?.label?.addObserver(self, forKeyPath: keypath, options: .new, context: nil)
        textView?.detailLabel?.addObserver(self, forKeyPath: keypath, options: .new, context: nil)
        textView?.button?.titleLabel?.addObserver(self, forKeyPath: keypath, options: .new, context: nil)
    }
    private func unregisterForKVO() {
        let keypath = "text"
        textView?.label?.removeObserver(self, forKeyPath: keypath)
        textView?.detailLabel?.removeObserver(self, forKeyPath: keypath)
        textView?.button?.titleLabel?.removeObserver(self, forKeyPath: keypath)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        updateSubviewsFrame()
    }
    
}
// MARK:-- 设置指示器
private extension SKHudVisualView {
    func updateIndicators() {
        // 初始化的时候进来,indicator是空的,对空对象发送消息返回的布尔值是NO,为在初始化完毕后,用户可能会设置mode属性,那时还会进入这个方法,所以这两个布尔变量除了第一次以外是有用的
        switch indicatorMode {
        case .defaultIndicator:
            if !(indicatorView is UIActivityIndicatorView) {
                // 默认第一次会进入到这里,对nil发送消息不会发生什么事, 为什么要removeFromSuperview呢,因为这方法并不会只进入一次, 不排除有些情况下先改变了mode到其他模式,之后又改回来了,这时候如果不移除,SKProgressHUD就会残留子控件在subviews里,虽然界面并不会显示它
                indicatorView?.removeFromSuperview()
                // 使用系统自带的巨大白色菊花
                indicatorView = UIActivityIndicatorView.init(style: .whiteLarge)
                let temp = indicatorView as! UIActivityIndicatorView
                temp.startAnimating()
                addSubview(indicatorView!)
            }
        case .circleGradientIndicator:
            indicatorView?.removeFromSuperview()
            indicatorView = SKHudCircleView.init()
            addSubview(indicatorView!)
        case .none:
            indicatorView?.removeFromSuperview()
            indicatorView = nil
        }
        
        layoutSubviews() // 刷新布局
        updateVisualColor()
    }
    
    func updateVisualColor() {
        var color = UIColor.black
        var bgColor = UIColor.init(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        if visualStyle == .dark {
            color = UIColor.white
            bgColor = UIColor.init(red: 45/255, green: 45/255, blue: 45/255, alpha: 1)
        }
        backgroundColor = bgColor
        textView?.label?.textColor = color
        textView?.detailLabel?.textColor = color
        textView?.button?.setTitleColor(color, for: .normal)
        if indicatorView is SKHudCircleView {
            let temp = indicatorView as! SKHudCircleView
            temp.strokeColor = color
        } else {
            indicatorView?.tintColor = color
        }
    }
}
// MARK:--updateSubviewsFrame
private extension SKHudVisualView {
    // 重新布局子视图
    func updateSubviewsFrame() {
        guard let superview = superview else {
            return
        }
        // 获取边框视图 bezelView 的可用 size
        let usableWidth = superview.frame.width - bezelMargin*2 - bezelPadding*2
        let usableHeight = superview.frame.height - bezelMargin*2 - bezelPadding*2
        if usableWidth <= 0 || usableHeight <= 0{
            return
        }
        let topSpace = bezelPadding
        // 先确定所有子视图的 size, 根据子视图的 size 调整自身的 frame, 最后再确定子视图的 frame
        var indicatorMaxY = topSpace
        var indicatorSize = CGSize.zero
        if let indicator = indicatorView {
            indicatorSize = CGSize.init(width: 37, height: 37)
            indicator.frame.size = indicatorSize
            indicator.frame.origin.y = topSpace
            indicatorMaxY = indicator.frame.maxY
        }
        
        var statusSize = CGSize.zero
        if let textView = textView {
           statusSize = textView.sizeThatFits(CGSize.init(width: usableWidth, height: usableHeight-indicatorMaxY))
        }
        textView?.frame.size = statusSize
        textView?.frame.origin.y = indicatorMaxY
        
        let widthArr:[CGFloat] = [indicatorSize.width,statusSize.width]
        var maxWidth:CGFloat = 0
        for wi in widthArr {
            maxWidth = CGFloat.minimum(usableWidth, wi)
        }
        let maxHeight = indicatorSize.height + statusSize.height
        
        // 获取控件的最大宽度
        var newSelfWidth = maxWidth + bezelPadding*2
        var newSelfHeight = maxHeight + bezelPadding*2
        // 如果设置了视图显示的最小 size
        if minSize.equalTo(CGSize.zero) == false {
            newSelfWidth = CGFloat.maximum(newSelfWidth, minSize.width)
            newSelfHeight = CGFloat.maximum(newSelfHeight, minSize.height)
        }
        
        // 如果设置视图是正方形显示
        if isSquare {
            newSelfWidth = CGFloat.maximum(newSelfWidth, newSelfHeight)
            newSelfHeight = CGFloat.maximum(newSelfWidth, newSelfHeight)
        }
        frame.size = CGSize.init(width: newSelfWidth, height: newSelfHeight)
        center = superview.center
        
        indicatorView?.center.x = frame.width/2
        textView?.center.x = frame.width/2
    }
}
