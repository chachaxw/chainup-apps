//
//  EXButton.swift
//  Chainup
//
//  Created by liuxuan on2020/3/7.
//  Copyright ©2020 zewu wang. All rights reserved.
//

import UIKit

@IBDesignable
open class EXButton: RepeatButton,LoadingAnimation {
    
    public var activityIndicator: LoadingView  { get {return self.loading}}
    public var loading = LoadingView.init(frame: CGRect(x: 0, y: 0, width: 26, height: 26))
    public var storedTitleColor:UIColor?

    @IBInspectable public var locationString: String? {
        didSet{
            self.setTitle(locationString?.localized(), for: .normal)
        }
    }
    
    @IBInspectable
    public var _selectStyle:Int = 0{
        didSet {
            selectStyle = EXButtonStyles(rawValue: _selectStyle) ?? .defultColor
        }
    }
    public var selectStyle:EXButtonStyles = EXButtonStyles.defultColor{
        didSet {
            self.color = selectStyle.color
            self.disabledColor = selectStyle.disabledColor
            self.selectedColor = selectStyle.selectedColor
            self.highlightedColor = selectStyle.highlightedColor
            if storedTitleColor != nil{
                self.setTitleColor(storedTitleColor, for: .normal)
                self.setTitleColor(storedTitleColor, for: .selected)
                self.setTitleColor(storedTitleColor, for: .highlighted)
                self.setTitleColor(.Ex.text2, for: .disabled)
            }else{
                self.setTitleColor(selectStyle.titleColor, for: .normal)
                self.setTitleColor(selectStyle.titleSelectColor, for: .selected)
                self.setTitleColor(selectStyle.titleSelectColor, for: .highlighted)
                self.setTitleColor(.Ex.text2, for: .disabled)
            }

            self.corneradius = selectStyle.cornerRadius
            addBorder()
            setNeedsDisplay()
        }
    }
    
    override public var isSelected: Bool{
        didSet{
            addBorder()
        }
    }
    override public var isEnabled: Bool{
        didSet{
            addBorder()
        }
    }
    public func addBorder(){
        if selectStyle == .defultColorBlueLine{
            if self.state == .disabled {
                self.layer.borderWidth = 0
            }else{
                self.layer.borderWidth = selectStyle.borderWidth
                self.layer.borderColor = selectStyle.borderColor?.cgColor
            }
        }
    }
    
    public var color: UIColor = .Ex.main1 {
        didSet {
            self.updateBackgroundImages()
            setNeedsDisplay()
        }
    }
    
    public var highlightedColor: UIColor = UIColor.ThemeLabel.colorHighlight.overlayWhite() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var selectedColor: UIColor = .Ex.main1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var disabledColor: UIColor = .Ex.fill3 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var cornerRadius: CGFloat = 4 {
        didSet {
            
            setNeedsDisplay()
        }
    }
    
    public func clearColors() {
        self.color = UIColor.clear
        self.highlightedColor = UIColor.clear
        self.disabledColor = UIColor.clear
        self.selectedColor = UIColor.clear
        
    }
    
    @IBInspectable
    public var ibcolor :String = "" {
        didSet {
            if !ibcolor.isEmpty {
                color = UIColor.themeColor(keyPath: ibcolor)
                setNeedsDisplay()
            }
        }
    }
    
    @IBInspectable
    public var ibHighlight:String = "" {
        didSet {
            highlightedColor = UIColor.themeColor(keyPath: ibHighlight)
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var ibselected :String = "" {
        didSet {
            if !ibselected.isEmpty {
                selectedColor = UIColor.themeColor(keyPath: ibselected)
                setNeedsDisplay()
            }
        }
    }
    
    @IBInspectable
    public var ibdisable :String = "" {
        didSet {
            if !ibdisable.isEmpty {
                disabledColor = UIColor.themeColor(keyPath: ibdisable)
                setNeedsDisplay()
            }
        }
    }


    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setNeedsDisplay()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
        setNeedsDisplay()
    }
    
    
    open override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        if self.storedTitleColor == nil {
            self.storedTitleColor = color
        }
        super.setTitleColor(color, for: state)
    }
    
    override open func draw(_ rect: CGRect) {
        updateBackgroundImages()
        super.draw(rect)
    }
    
    fileprivate func configure() {
        setFont()
        adjustsImageWhenDisabled = false
        adjustsImageWhenHighlighted = false
    }
    
    fileprivate func updateBackgroundImages() {
        
        let highlightedImage = ButtonStyles.highlightedButtonImage(color: highlightedColor, shadowHeight: 0, shadowColor: .clear, cornerRadius: cornerRadius, buttonPressDepth: 0)
        let normalImage = ButtonStyles.buttonImage(color: color, shadowHeight: 0, shadowColor: .clear, cornerRadius: cornerRadius)
        let selectedImage = ButtonStyles.buttonImage(color: selectedColor, shadowHeight: 0, shadowColor: .clear, cornerRadius: cornerRadius)
        let disabledImage = ButtonStyles.buttonImage(color: disabledColor, shadowHeight: 0, shadowColor: .clear, cornerRadius: cornerRadius)
        
        setBackgroundImage(normalImage, for: .normal)
        setBackgroundImage(highlightedImage, for: .highlighted)
        setBackgroundImage(selectedImage, for: .selected)
        setBackgroundImage(disabledImage, for: .disabled)
    }
    
    public func setFont(_ font : UIFont = .Ex.medium(14)){
        self.titleLabel?.font = font
    }
    
    public func isAnimating() {
        self.setTitleColor(UIColor.clear, for: .normal)
    }
    
    public func animationStopped() {
        if let titlec = self.storedTitleColor {
            self.setTitleColor(titlec, for: .normal)
        }
    }
}

enum EXButtonColor{
    public static var greenColor            = UIColor.Ex.rise1
    public static var highlightedGreenColor = UIColor.Ex.rise2
    public static var redColor              = UIColor.Ex.fall1
    public static var highlightedRedColor   = UIColor.Ex.fall2
    public static var blueColor             = UIColor.Ex.main1
    public static var blueTextColor         = UIColor.Ex.main4
    public static var highlightedBlueColor  = UIColor.Ex.main2
}

public enum EXButtonStyles:Int {
    // 只能在尾部增加
    case defultColor                        = 0     // 只有文字 灰色
    case up                                 = 1
    case down                               = 2
    case blueColor                          = 3
    case defultColorBlueLine                = 4     // 文字蓝 边线蓝,6.0改为灰色
    case lightColor                         = 5     // 文字灰 背景浅
    case lightBlueColor                     = 6     // 文字蓝 背景浅
    case clearBlueColor                     = 7     // 文字默认灰选中蓝 背景透明
    case blueTextColor                      = 8     // 文字蓝 背景透明
    case onlyImage                          = 9     // 只有图
    public var color:UIColor{
        switch self{
        case .up:  if EXKLineManager.isGreen(){return EXButtonColor.greenColor}else {return EXButtonColor.redColor}
        case .down:if EXKLineManager.isGreen(){return EXButtonColor.redColor  }else {return EXButtonColor.greenColor}
        case .blueColor:                            return EXButtonColor.blueColor
        case .defultColorBlueLine:                  return UIColor.ThemeView.card2
        case .defultColor:                          return UIColor.ThemeView.bg
        case .lightColor,.lightBlueColor:           return UIColor.ThemeBtn.normal
        case .clearBlueColor,.blueTextColor:        return UIColor.clear
        default:
            return .clear
        }
    }
    
    public var highlightedColor:UIColor{
        switch self{
        case .up:  if EXKLineManager.isGreen() {return EXButtonColor.highlightedGreenColor} else {return EXButtonColor.highlightedRedColor}
        case .down:if EXKLineManager.isGreen() {return EXButtonColor.highlightedRedColor}   else {return EXButtonColor.highlightedGreenColor}
        case .blueColor:                            return EXButtonColor.highlightedBlueColor
            
        case .defultColor:                          return UIColor.ThemeView.bg
        case .defultColorBlueLine:
            return UIColor.ThemeView.bgTab
        case .lightColor:
            return UIColor.ThemeBtn.touch
        case .lightBlueColor:  return UIColor.ThemeBtn.highlight
        case .clearBlueColor,.blueTextColor:                       return UIColor.clear
        default:
            return UIColor.clear
            
        }
    }
    public var selectedColor:UIColor{
        return highlightedColor
    }
    
    public var titleColor:UIColor {
        switch self{
        case .up,.down: return UIColor.white
        case .blueColor:           return .Ex.text4
        case .defultColorBlueLine: return .Ex.text1
        case .lightBlueColor:      return EXButtonColor.blueColor
        case .blueTextColor:       return .Ex.main1
        default :                  return UIColor.ThemeBtn.title
        }
    }
    public var titleSelectColor:UIColor {
        switch self{
        case .clearBlueColor:                       return UIColor.ThemeLabel.colorHighlight
        case .onlyImage:                            return .clear
        default :                                   return titleColor
        }
    }
    public var disabledColor:UIColor{
        switch self{
        default : return UIColor.ThemeBtn.disable
        }
    }
    public var cornerRadius:CGFloat{
        switch self{
        default : return 4
        }
    }
    public var borderWidth:CGFloat{
        switch self{
//        case .defultColorBlueLine:return 1
        default : return 0
        }
    }
    public var borderColor:UIColor?{
        switch self{
//        case .defultColorBlueLine:return EXButtonColor.blueColor
        default : return nil
        }
    }
    

    public mutating func next() {
        switch self {
        case .defultColor:
            self = .up
        case .up:
            self = .down
        case .down:
            self = .blueColor
        case .blueColor:
            self = .defultColorBlueLine
        case .defultColorBlueLine:
            self = .lightColor
        case .lightColor:
            self = .lightBlueColor
        case .lightBlueColor:
            self = .clearBlueColor
        case .clearBlueColor:
            self = .blueTextColor
        default:
            self = .defultColor
        }
    }


}


import RxSwift

public class EXCountdownButton: UIButton {
    ///
    public private(set) var isCountingdown:Bool = false {
        didSet {
            isEnabled = !isCountingdown
        }
    }
    ///
    private var timerDispose: Disposable?
    ///
    public func startCountdown(from:Int = 60, to:Int = 0, step:Int = 1) {
        if isCountingdown { return }
        isCountingdown = true
        guard from > to, step > 0, step <= from - to else { return }
        timerDispose = Observable<Int>.interval(.seconds(step), scheduler: MainScheduler.instance)
            .map({ from - ($0 + 1) * step })
            .take(until: { $0 <= to })
            .subscribe(onNext: { [weak self] seconds in
                self?.updateTitle(seconds: seconds)
            }, onCompleted: { [weak self] in
                self?.stopCountdown()
            })
        timerDispose?.disposed(by: disposeBag)
    }
    /// update title when counting down, if counting-down stopped, the second will be 0
    public var titleUpdater:((EXCountdownButton,Int)->Void)?
    ///
    private func updateTitle(seconds:Int) {
        guard let titleUpdater = titleUpdater else { return }
        titleUpdater(self,seconds)
    }
    ///
    public func stopCountdown() {
        guard isCountingdown else { return }
        timerDispose?.dispose()
        timerDispose = nil
        isCountingdown = false
        updateTitle(seconds: 0)
    }
}

