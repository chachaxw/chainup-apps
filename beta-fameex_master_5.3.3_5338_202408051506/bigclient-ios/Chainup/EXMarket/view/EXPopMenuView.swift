//
//  EXPopMenuView.swift
//  Chainup
//
//  Created by cwd on 2022/7/27.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit


enum PopMenuType {
case top
case delete
case add
}

class PopMenuItem{
    var name: String = ""
    var tilteFont: UIFont = UIFont.ThemeFont.BodyMedium
    var type: PopMenuType = .add
}

let ArrowScale:CGFloat = 28 / 24  //Width/Height
class EXPopMenuView: UIView {
    static let memuView = EXPopMenuView()
    open class var shared: EXPopMenuView {
        return memuView
    }
    private let topBottomMargin: CGFloat = 8 //Distance between top and bottom
    private let btnH: CGFloat = 18 //Content height
    
    var arrowSize: CGSize = CGSize(width: 6, height: 6) //ARROW size
    var popover = EXPopover()
    var dismissend : EXComVoidBlock?
    var magin: CGFloat = 4
    typealias ClickViewBlock = (PopMenuItem) -> ()
    var clickViewBlock : ClickViewBlock?
    var show = false
    var acionItems = [PopMenuItem]()
    var btnItems = [UIButton]()
    lazy var containerView : UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 10
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    //Arrows are processed using images, and the arrows drawn at the bottom are too sharp
    lazy var arrowImage: UIImageView = {
        let arrow = UIImageView()
        arrow.contentMode = .scaleAspectFit
        arrow.image =  UIImage(named: "arrow_down_black")
        return arrow
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        addSubview(arrowImage)
        containerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topBottomMargin)
            make.height.equalTo(btnH)
//            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        arrowImage.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            let h  = self.arrowSize.height * 1.2
            let w = h * ArrowScale
            make.width.equalTo(w)
            make.height.equalTo(h)
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
    
    func pop(fromView:UIView,acionItem:[PopMenuItem], callBack: @escaping ClickViewBlock){
         if self.show {
             return
         }
        self.show = true
        self.acionItems = acionItem
        popover = EXPopover(options: EXPopover.commonTradePopOption, showHandler: nil, dismissHandler: nil)
        popover.margin = self.magin
        popover.showBlackOverlay = false
        popover.popoverType = .up //The direction and the height of the arrow need to be adjusted to match the height of the arrow by adjusting the internal bottom or top spacing
        popover.arrowSize = self.arrowSize
        popover.popoverColor =  UIColor.extColorWithHex("#303133")
        popover.didDismissHandler = { [weak self] in
             self?.show = false
             self?.dismissend?()
        }
        let rect = self.setMenuData(acionItem)
        self.frame = rect
        self.clickViewBlock = callBack
        popover.show(self, fromView: fromView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //The click range of the expanded button is invalid. The button exceeds the parent class click event processing, with the left half responding to the first button and the right half responding to the second button
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
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
class PopGuideItem{
    var title: String = "" //title
    var subTitle: String = "" //Subtitle
    var textColor: UIColor = UIColor.white
    var tilteFont: UIFont = UIFont.ThemeFont.BodyBold
    var subtitleFont: UIFont = UIFont.ThemeFont.SecondaryBold
    var popoverType:EXPopoverType = .down //Popview in the specified view direction
    var arrowSize: CGSize = CGSize(width: 6, height: 6) //ARROW size
    var formView: UIView? //Where did the view pop up from
    var maxWidth: CGFloat = 0 //Maximum width limit
    var offset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var showSubTitle = true
}

class EXPopGuidManger{
    
    static let shared = EXPopGuidManger()
    private init() {} //Privatization initialization method to prevent external instances from being directly created through init
    var isShowing: Bool = false //
    var guideItems = [PopGuideItem]() //Cannot be empty
    var finshCallBack: EXComVoidBlock?
    lazy var pop: EXPopover = {
        let popover = EXPopover(options: EXPopover.commonTradePopOption, showHandler: nil, dismissHandler: nil)
         popover.sideEdge = 16 //Screen edge spacing
         popover.showBlackOverlay = false
         popover.popoverType = .up //The direction and the height of the arrow need to be adjusted to match the height of the arrow by adjusting the internal bottom or top spacing
         popover.arrowSize = CGSize(width: 6, height: 6)
         popover.popoverColor = UIColor.ThemeView.highlight
        return popover
    }()
    
    
    func strartPop(){
        
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
}

class EXPopGuidItemView: UIView {
    //Left and right spacing
    static let marginLeftRight:CGFloat = 16
    //Distance between top and bottom
    static let marginTopBottom: CGFloat = 12
    static let itemsSpacing: CGFloat = 8 //Sub view spacing
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
            case .down://Adjusting the layout
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

    
    ///Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.numberOfLines = 0
        label.ext_UseAutoLayout()
        return label
    }()
    ///Sub name
    lazy var subTitleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.SecondaryBold, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.right)
        label.numberOfLines = 0
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
    
    //Calculate the size displayed on the interface
    class func getFrame(item:PopGuideItem,popoverType:EXPopoverType) -> CGRect{
        var contentH: CGFloat = 0
        var width: CGFloat = Device_W
        if item.maxWidth > 0 { //Limited maximum width
            width = item.maxWidth
        }
        let contentW = width - EXPopGuidItemView.marginLeftRight * 2
        let titleSize = item.title.textSizeWithFont(item.tilteFont, width: contentW)
        contentH += titleSize.height
        if item.subTitle.isEmpty == false{
            contentH += EXPopGuidItemView.itemsSpacing
            let subTitleSize = item.subTitle.textSizeWithFont(item.subtitleFont, width: contentW)
            contentH += subTitleSize.height
        }
        contentH += EXPopGuidItemView.marginTopBottom * 2
        if item.maxWidth == 0 {//Unrestricted width based on text width+left and right spacing
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


    
    
    
    
    
    



