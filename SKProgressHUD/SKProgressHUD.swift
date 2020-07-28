//
//  SKProgressHUD.swift
//  shen
//
//  Created by 沈凯强 on 2021/01/01.
//  Copyright © 2021 mn. All rights reserved.
//

import UIKit

protocol SKProgressHUDDelegate:class {
    func SKProgressHUDWasHidden(HUD:SKProgressHUD)
}
/// 加载框
class SKProgressHUD:UIView {

    // 动画效果
    enum HUDAnimationType {
        /// 默认效果,只有透明度变化的动画效果
        case fade
        /// 透明度变化+形变效果
        case zoom
    }
    /// 动画,默认只改变透明度
    var animationType:HUDAnimationType = .fade
    // 代理
    weak var delegate:SKProgressHUDDelegate?
    // 基本视图,包含标签和指示器的视图。
    var visualView:SKHudVisualView?
    // GCD 计时器,需要设置全局变量引用, 否则不会调用事件
    private var sourceTimer: DispatchSourceTimer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 使背景颜色为透明
        backgroundColor = UIColor.clear
        // 即使用户创建了一个hud,并调用了addSubview方法,没有调用show也是不能显示的.在这之前要使hud隐藏并且不能接受触摸事件,透明度为0(小于等于0.01),相当于hidden,无法响应触摸事件
        alpha = 0
        // UI 布局
        visualView = SKHudVisualView.init(frame: frame)
        addSubview(visualView!)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        visualView?.frame = frame
    }
    // 确保在主线程展示
    private func mainThreadAssert() {
        assert(Thread.isMainThread, "SKProgressHUD needs to be accessed on the main thread")
    }
    // 在需要拦截的 view 中重写 hitTest 方法改变第一响应者
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 如果在当前 view 中 直接返回 self 这样自身就成为了第一响应者 subViews 不再能够接受到响应事件
        if self.point(inside: point, with: event) {
            return self
        }
        return nil
    }
}
// MARK:--对外的接口,显示与隐藏
extension SKProgressHUD {
    class func showHUD(addedTo view:UIView) -> SKProgressHUD {
        let hud = SKProgressHUD.init(frame: view.bounds)
        view.addSubview(hud)
        hud.showHUD()
        return hud
    }
    class func hideHUD(in view:UIView) {
        let temparr = SKProgressHUD.HUDIsExist(in: view)
        for hud in temparr {
            hud?.hideHUD()
        }
    }
    class func HUDIsExist(in view:UIView) -> [SKProgressHUD?] {
        var temparr:[SKProgressHUD?] = Array.init()
        for sub in view.subviews {
            if sub is SKProgressHUD {
                let hhh = sub as? SKProgressHUD
                temparr.append(hhh)
            }
        }
        return temparr
    }
    // 显示
    private func showHUD() {
        mainThreadAssert()
        // 取消延迟操作
        sourceTimer?.cancel()
        animateAction(isShow: true,completion: nil)
    }
    // 隐藏
    private func hideHUD() {
        mainThreadAssert()
        weak var weakself = self
        animateAction(isShow: false, completion: { () in
            weakself?.done()
        })
    }
    func done() {
        sourceTimer?.cancel()
        removeFromSuperview()
        // 调用代理
        delegate?.SKProgressHUDWasHidden(HUD: self)
    }
    // 延迟一定时间后,隐藏
    func hideHUD(after seconds:Float) {
        // GCD 倒计时方法
        var countdown = Int(seconds*1000)
        let queue = DispatchQueue.global()
        sourceTimer = DispatchSource.makeTimerSource(flags: [], queue: queue)
        sourceTimer?.schedule(deadline: .now(), repeating: DispatchTimeInterval.milliseconds(100))
        sourceTimer?.resume()
        weak var weakself = self
        sourceTimer?.setEventHandler {
            countdown -= 100
            DispatchQueue.main.async {
                if countdown == 0 {
                    weakself?.sourceTimer?.cancel()
                    weakself?.hideHUD()
                }
            }
        }
    }
}
// MARK:--动画
private extension SKProgressHUD {
    func animateAction(isShow:Bool,completion:(()->Void)?) {
        let small = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        if animationType == .zoom {
            // zoom 产生放大/缩小效果,再恢复到原状, 要注意的是,形变的是整个`ProgressHUD`,而不是中间可视部分
            if isShow {
                // CGAffineTransformConcat是两个矩阵相乘,与之等价的设置方式是:
                transform = CGAffineTransform.identity.concatenating(small)
            } else {
                transform = CGAffineTransform.identity
            }
        }
                
        weak var weakself = self
        UIView.animate(withDuration: 0.3, animations: {
            weakself?.alpha = isShow ? 1 : 0
            // 从形变状态回到初始状态
            if weakself?.animationType == .zoom {
                if isShow {
                    weakself?.transform = CGAffineTransform.identity
                } else {
                    weakself?.transform = CGAffineTransform.identity.concatenating(small)
                }
            }
        }, completion:{ isfinsh in
            weakself?.transform = CGAffineTransform.identity
            completion?()
        })
    }
}
