//
//  EXPopMenuView.swift
//  Chainup
//
//  Created by cwd on 2022/7/27.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit

public enum PopMenuType {
    case top
    case delete
    case add
}

public class PopMenuItem: NSObject{
    public var name: String = ""
    var tilteFont: UIFont = UIFont.Ex.Harmony(size: 14, weight: .medium)
    public var type: PopMenuType = .add
}

public class EXPopMenuView: UIView {
    static let memuView = EXPopMenuView()
    open class var shared: EXPopMenuView {
        return memuView
    }
    private let topBottomMargin: CGFloat = 8 //上下间距
    private let btnH: CGFloat = 18 //内容高度
    
    var arrowSize: CGSize = CGSize(width: 6, height: 6) //箭头大小
    var popover = EXPopover()
    public var dismissend : EXComVoidBlock?
    public var willDismissHandler:(() -> ())? {
        get { popover.willDismissHandler }
        set { popover.willDismissHandler = newValue }
    }
    var magin: CGFloat = 4
    public typealias ClickViewBlock = (PopMenuItem) -> ()
    var clickViewBlock : ClickViewBlock?
    var show = false
    var acionItems = [PopMenuItem]()
    var btnItems = [UIButton]()
    lazy var containerView : UIStackView = {
        let view = EXStackView()
        view.separatorConfiguration = .init(color: .Ex.fill4,
                                            width: 0.5,
                                            height: btnH + topBottomMargin * 2,
                                            cornerRadius: 0)
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 10
        view.layer.cornerRadius = 4
        return view
    }()
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topBottomMargin)
            make.height.equalTo(btnH)
            make.centerX.equalToSuperview()
        }
    }
    
    func setMenuData(_ models :[PopMenuItem]) -> CGRect{
        containerView.removeAllArrangedSubviews()
        btnItems.removeAll()
        var width:CGFloat = 0
        for index in 0..<models.count{
            let model = models[index]
            let button = UIButton()
            button.setTitle(model.name, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(itemClick(btn:)), for: .touchUpInside)
            button.tag = index
            let font = model.tilteFont
            button.titleLabel?.font = font
            containerView.addArrangedSubview(button)
            let w = model.name.textSizeWithFont(font, width: 300).width + 10
            width += w
            button.snp.makeConstraints { make in
                make.width.equalTo(w)
            }
            btnItems.append(button)
        }
        let  total = topBottomMargin * 2 + btnH
        return CGRect(x: 0, y: 0, width: width + 30, height: total)
    }
    
    
    @objc func itemClick(btn: UIButton){
        print(btn.tag)
        self.clickViewBlock?(self.acionItems[btn.tag])
        self.popover.dismiss()
    }
    
    public func pop(fromView:UIView,acionItem:[PopMenuItem], callBack: @escaping ClickViewBlock, customConfigurationBlock:((EXPopover)->Void)? = nil){
         if self.show {
             return
         }
        self.show = true
        self.acionItems = acionItem
        popover = EXPopover(options: EXPopover.commonTradePopOption, showHandler: nil, dismissHandler: nil)
        popover.margin = self.magin
        popover.showBlackOverlay = false
        popover.popoverType = .up //方向 以及箭头 的高度，需要调整内部底部或顶部间距，跟箭头高度一致
        popover.arrowSize = self.arrowSize
        popover.popoverColor =  UIColor.Ex.fill8
        popover.didDismissHandler = { [weak self] in
             self?.show = false
             self?.dismissend?()
        }
        let rect = self.setMenuData(acionItem)
        self.frame = rect
        self.clickViewBlock = callBack
        customConfigurationBlock?(popover)
        popover.show(self, fromView: fromView)
    }
    
    public func dismiss(animated:Bool = true) {
        popover.dismiss(animated: animated)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //用了扩大按钮的点击范围无效， 按钮超出父类点击事件处理,左半边, 第一个按钮响应，右半边, 第二个按钮响应
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if let view = view {
            if view == self || view.isKind(of: UIStackView.self){
                if btnItems.count == 1 {
                    return btnItems[0]
                }else if btnItems.count == 2 {
                    let frame = self.frame
                    let leftHalf = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width / 2, height: frame.size.width)
                    if leftHalf.contains(point){
                        return btnItems[0]
                    }else{
                        return btnItems[1]
                    }
                }
            }
        }
        return super.hitTest(point, with: event)
    }
}

/// 引导的使用

public class PopGuideItem : NSObject{
    public var title: String = "" //标题
    public var subTitle: String = "" //副标题
    public var textColor: UIColor = UIColor.white
    public var tilteFont: UIFont = UIFont.Ex.Harmony(size: 14, weight: .medium)
    public var subtitleFont: UIFont = UIFont.Ex.Harmony(size: 12, weight: .medium)
    public var popoverType:EXPopoverType = .down //popview 在 指定视图的方向
    public var arrowSize: CGSize = CGSize(width: 6, height: 6) //箭头大小
    public var formView: UIView? // 从哪里弹出的view
    public var maxWidth: CGFloat = 0 //最大宽度限制
    public var offset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

}

public class EXPopGuidManger{
    
    public static let shared = EXPopGuidManger()
    private init() {}
    var isShowing: Bool = false //
    public var guideItems = [PopGuideItem]() //不能为空
    public var finshCallBack: EXComVoidBlock?
    public func strartPop(){
        
        if self.guideItems.count == 0 {
            self.finshCallBack?()
            return
        }
        if self.isShowing == true{
            return
        }
        self.isShowing = true
        let item  = self.guideItems.first!
        if item.formView == nil {
            return
        }
        let frame = EXPopGuidItemView.getFrame(item: item, popoverType:item.popoverType)
        let guide = EXPopGuidItemView(frame: frame)
        guide.item = item
        guide.tapCallBack = {  [weak self] in
            self?.pop.dismiss()
        }
        self.pop.arrowSize = item.arrowSize
        self.pop.popoverType = item.popoverType
        self.pop.didDismissHandler = { [weak self] in
            self?.isShowing = false
            if self?.guideItems.count ?? 0 > 0 {
                self?.guideItems.removeFirst()
                self?.strartPop()
            }

            
        }
        pop.show(guide, fromView: item.formView!)
    }
    
    
    lazy var pop: EXPopover = {
        let popover = EXPopover(options: EXPopover.commonTradePopOption, showHandler: nil, dismissHandler: nil)
         popover.sideEdge = 16 //屏幕边缘间距
         popover.showBlackOverlay = false
         popover.popoverType = .up //方向 以及箭头 的高度，需要调整内部底部或顶部间距，跟箭头高度一致
         popover.arrowSize = CGSize(width: 6, height: 6)
        popover.popoverColor = UIColor.Ex.main1 //UIColor.ThemeView.highlight
        return popover
    }()
    
    
}

class EXPopGuidItemView: UIView {
    //左右间距
    static let marginLeftRight:CGFloat = 16
    //上下间距
    static let marginTopBottom: CGFloat = 12
    static let itemsSpacing: CGFloat = 8 //子view 间距
    var tapCallBack: EXComVoidBlock?
    var item: PopGuideItem = PopGuideItem()  {
        didSet{
            titleLabel.text = item.title
            titleLabel.font = item.tilteFont
            subTitleLabel.text = item.subTitle
            subTitleLabel.font = item.subtitleFont
            titleLabel.textColor = item.textColor
            subTitleLabel.textColor = item.textColor
            var topMagin = EXPopGuidItemView.marginTopBottom
            switch item.popoverType{
            case .down:// 调整布局
                topMagin += item.arrowSize.height
                titleLabel.snp.updateConstraints { make in
                    make.top.equalToSuperview().offset(topMagin)
                }
            case .up:
                
                break
            default:
                break
            }
        }
    }

    
    ///名称
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.Ex.Harmony(size: 14, weight: .medium), textColor: UIColor.Ex.text2, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.ext_UseAutoLayout()
        return label
    }()
    ///子名称
    lazy var subTitleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.Ex.Harmony(size: 12, weight: .medium), textColor: UIColor.Ex.text2, alignment: NSTextAlignment.right)
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.ext_UseAutoLayout()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        self.addSubViews([titleLabel,subTitleLabel])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(EXPopGuidItemView.marginTopBottom)
            make.left.equalToSuperview().offset(EXPopGuidItemView.marginLeftRight)
            make.right.equalToSuperview().offset(-EXPopGuidItemView.marginLeftRight)
            make.centerX.equalToSuperview()
        }
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(EXPopGuidItemView.itemsSpacing)
            make.right.equalToSuperview().offset(-EXPopGuidItemView.marginLeftRight)
        }
    }
    
    //计算界面显示的大小
    class func getFrame(item:PopGuideItem,popoverType:EXPopoverType) -> CGRect{
        var contentH: CGFloat = 0
        var width: CGFloat = Device_W
        if item.maxWidth > 0 { //限制了最大宽度
            width = item.maxWidth
        }
        let contentW = width - EXPopGuidItemView.marginLeftRight * 2
        let titleSize = item.title.textSizeWithFont(item.tilteFont, width: contentW)
        contentH += titleSize.height
        contentH += EXPopGuidItemView.itemsSpacing
        let subTitleSize = item.subTitle.textSizeWithFont(item.subtitleFont, width: contentW)
        contentH += subTitleSize.height
        contentH += EXPopGuidItemView.marginTopBottom * 2
        if item.maxWidth == 0 {//未限制宽度 根据文字宽度  + 左右间距
            width = titleSize.width + EXPopGuidItemView.marginLeftRight * 2
        }
        return CGRect(x: 0, y: 0, width: width, height: contentH)
        
    }
    
    @objc func click(){
        self.tapCallBack?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


    
    
    
    
    
    


