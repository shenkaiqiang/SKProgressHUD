//
//  SKHudTextView.swift
//  shen
//
//  Created by 沈凯强 on 2021/01/01.
//  Copyright © 2021 mn. All rights reserved.
//

import UIKit
/// HUD的文字部分的视图
class SKHudTextView: UIView {

    private let labelFont = UIFont.boldSystemFont(ofSize: 16)
    private let detailLabelFont = UIFont.boldSystemFont(ofSize: 12)
    private let buttonFont = UIFont.boldSystemFont(ofSize: 12)
    private let textLineSpace:CGFloat = 2
    
    // 文本标签,位于活动指示器下方,根据文本内容自动调整大小
    var label:UILabel! {
        didSet {
            layoutSubviews() // 重新布局子视图
        }
    }
    // 详细文本标签,位于文本标签下方,可多行显示
    var detailLabel:UILabel! {
        didSet {
            layoutSubviews() // 重新布局子视图
        }
    }
    // 点击事件按钮,位于标签下方,只有添加了 target 时才可见.
    var button:UIButton! {
        didSet {
            layoutSubviews() // 重新布局子视图
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 创建基本视图(背景视图,标签等)
        label = UILabel.init()
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = .center
        label.font = labelFont
        label.isOpaque = false
        label.backgroundColor = UIColor.clear
        addSubview(label!)
        
        detailLabel = UILabel.init()
        detailLabel.adjustsFontSizeToFitWidth = false
        detailLabel.textAlignment = .center
        detailLabel.font = detailLabelFont
        detailLabel.isOpaque = false
        detailLabel.backgroundColor = UIColor.clear
        detailLabel.numberOfLines = 0
        addSubview(detailLabel!)
        
        button = UIButton.init(type: .custom)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = buttonFont
        addSubview(button!)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
       _ = updateSubviewsFrame(width: frame.width,height: frame.height)
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let newSize = updateSubviewsFrame(width: size.width, height: size.height)
        return newSize
    }
}

// MARK: --layout
private extension SKHudTextView {
    func updateSubviewsFrame(width:CGFloat,height:CGFloat) -> CGSize {
        if width <= 0 || height <= 0{
            return CGSize.zero
        }
        let topSpace:CGFloat = 0
        // 先确定所有子视图的 size,
        let labSize = getNewSize(view: label, limitWidth: width, limitHeight: height)
        let detailSize = getNewSize(view: detailLabel, limitWidth: width, limitHeight: height)
        var btnSize = getNewSize(view: button, limitWidth: width, limitHeight: height)
        let btnTitleIsNil = (button.titleLabel?.text == nil || button.titleLabel?.text?.isEmpty == true) ? true : false
        if button.imageView?.image == nil && btnTitleIsNil {
            btnSize = CGSize.zero
        }
        // 根据子视图的 size 确定自身的 frame,
        var maxWidth:CGFloat = 0
        let widthArr = [labSize.width,detailSize.width,btnSize.width]
        for wi in widthArr {
            maxWidth = CGFloat.maximum(maxWidth, wi)
        }
        
        let maxHeight = CGFloat.minimum(height, (labSize.height + detailSize.height + btnSize.height+textLineSpace))
        // 最后再确定子视图的 frame
        let labelWidth = CGFloat.minimum(labSize.width, maxWidth)
        let labelHeight = CGFloat.minimum(labSize.height, maxHeight)
        let labelY = topSpace
        label.frame.size = CGSize.init(width: labelWidth, height: labelHeight)
        label.frame.origin.y = labelY
        label.center.x = maxWidth/2
        
        let btnWidth = CGFloat.minimum(btnSize.width, maxWidth)
        let btnHeight = CGFloat.minimum(btnSize.height, maxHeight-labelHeight)
        let btnY = maxHeight - btnHeight
        button.frame.size = CGSize.init(width: btnWidth, height: btnHeight)
        button.frame.origin.y = btnY
        button.center.x = maxWidth/2
        
        let detailWidth = CGFloat.minimum(detailSize.width, maxWidth)
        let detailHeight = CGFloat.minimum(detailSize.height, maxHeight-labelHeight-btnHeight-textLineSpace)
        let detailY = label.frame.maxY + textLineSpace
        detailLabel.frame.size = CGSize.init(width: detailWidth, height: detailHeight)
        detailLabel.frame.origin.y = detailY
        detailLabel.center.x = maxWidth/2
        
        return CGSize.init(width: maxWidth, height: maxHeight)
    }
    func getNewSize(view:UIView, limitWidth:CGFloat,limitHeight:CGFloat) -> CGSize {
        var newsize = view.sizeThatFits(CGSize.init(width: limitWidth, height: limitHeight))
        newsize.width = CGFloat.minimum(newsize.width, limitWidth)
        newsize.height = CGFloat.minimum(newsize.height, limitHeight)
        return newsize
    }
}
