//
//  HudHelper.swift
//  shen
//
//  Created by 沈凯强 on 2021/01/01.
//  Copyright © 2021 mn. All rights reserved.
//

import UIKit

public class HudHelper {

    /// 提示文字,一定时间后消失
    public class func showNotice(title:String?, addTo view:UIView? = nil) {
        var view = view
        if view == nil {
            let vc = UIApplication.shared.keyWindow?.rootViewController
            view = vc?.view
        }
        guard let superview = view else {
            return
        }
        let hud = SKProgressHUD.showHUD(addedTo: superview)
        // 指示器类型选择
        hud.visualView?.indicatorMode = .none
        hud.visualView?.textView?.detailLabel?.text = title
        hud.hideHUD(after: 1.5)
    }
    /// 状态提示,需要手动隐藏
    public class func showLoading(addTo view:UIView?, title:String = "正在加载", detailTitle:String? = nil) {
        var view = view
        if view == nil {
            let vc = UIApplication.shared.keyWindow?.rootViewController
            view = vc?.view
        }
        guard let superview = view else {
            return
        }
        let hud = SKProgressHUD.showHUD(addedTo: superview)
        // 指示器类型选择
        hud.visualView?.indicatorMode = .circleGradientIndicator
        hud.visualView?.textView?.label?.text = title
        hud.visualView?.textView?.detailLabel?.text = detailTitle
    }
    
    public class func hideLoading(in view:UIView?) {
        var view = view
        if view == nil {
            let vc = UIApplication.shared.keyWindow?.rootViewController
            view = vc?.view
        }
        guard let superview = view else {
            return
        }
        SKProgressHUD.hideHUD(in: superview)
    }
}
/*SKProgressHUD 使用说明:
 SKProgressHUD 是最外层的透明view,frame与superview的frame相等,主要用于控制 HUD 的动画(animationType),显示与隐藏
 SKHudVisualView 是中间的可视部分,包括指示器视图和文本视图,可以设置展示风格(visualStyle),指示器的类型(indicatorMode),内外边距(margin/padding),偏移量(offset)等
 SKHudTextView 可视部分的文本视图,有三个控件,从上到下依次为 label,detailLabel,button
 SKHudCircleView 不停旋转的圆环View,可用于展示状态
 使用方法之一:
 let hud = SKProgressHUD.showHUD(addedTo: view, animated: true)
 hud.visualView?.label?.text = "标题"
 hud.visualView?.detailLabel?.text = "详细标题详细标标题题详细标题详细标题详细细标题详细标标题题详细标题详细标题详细详细标题详细标标题题详细标题详细标题详细详细标题详细标标题题详细标题详细标题详细详细标题详细标标题题详细标题详细标题详细细标题详细标标题题详细标题详细标题详细详细标题详细标标题题详细标题详细标题详细详细标题详细标标题题详细标题详细标题详细详细标题详细标标题题详细标题详细标题详细细标题详细标标题题详细标题详细标题详细详细标题详细标标题题详细标题详细标题详细详细标题详细标标题题详细标题详细标题详细详细标题详细标标题题详细标题详细标题详细"
 hud.visualView?.button?.setTitle("button action", for: .normal)
 hud.visualView?.button?.addTarget(target:Any?, action: Selector, for: UIControlEvents)
 
 */
