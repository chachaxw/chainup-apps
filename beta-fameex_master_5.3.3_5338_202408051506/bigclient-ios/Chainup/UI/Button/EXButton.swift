//
//  EXButton.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

@IBDesignable
class EXButton: RepeatButton,LoadingAnimation {
    
    var activityIndicator: LoadingView  { get {return self.loading}}
    var loading = LoadingView.init(frame: CGRect(x: 0, y: 0, width: 26, height: 26))
    var storedTitleColor:UIColor?

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
            self.highlightedColor = selectStyle.selectedColor
            if storedTitleColor != nil{
                self.setTitleColor(storedTitleColor, for: .normal)
                self.setTitleColor(storedTitleColor, for: .selected)
                self.setTitleColor(storedTitleColor, for: .highlighted)
                self.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .disabled)
            }else{
                self.setTitleColor(selectStyle.titleColor, for: .normal)
                self.setTitleColor(selectStyle.titleSelectColor, for: .selected)
                self.setTitleColor(selectStyle.titleSelectColor, for: .highlighted)
                self.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .disabled)
            }

            self.corneradius = selectStyle.cornerRadius
            addBorder()
            setNeedsDisplay()
        }
    }
    
    override var isSelected: Bool{
        didSet{
            addBorder()
        }
    }
    override var isEnabled: Bool{
        didSet{
            addBorder()
            if self.state == .disabled {
                self.setTitleColor(.Ex.text2, for: .disabled)
            }
        }
        
    }
    func addBorder(){
        if selectStyle == .defultColorBlueLine{
            if self.state == .disabled {
                self.layer.borderWidth = 0
            }else{
                self.layer.borderWidth = selectStyle.borderWidth
                self.layer.borderColor = selectStyle.borderColor?.cgColor
            }
        }
    }
    
    public var color: UIColor = UIColor.ThemeLabel.colorHighlight {
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
    
    public var selectedColor: UIColor = UIColor.ThemeLabel.colorHighlight {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var disabledColor: UIColor = UIColor.ThemeBtn.disable {
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
    
    
    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
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
        
        let normalImage = ButtonStyles.buttonImage(color: color, shadowHeight: 0, shadowColor: .clear, cornerRadius: cornerRadius)
        let highlightedImage = ButtonStyles.highlightedButtonImage(color: highlightedColor, shadowHeight: 0, shadowColor: .clear, cornerRadius: cornerRadius, buttonPressDepth: 0)
        let selectedImage = ButtonStyles.buttonImage(color: selectedColor, shadowHeight: 0, shadowColor: .clear, cornerRadius: cornerRadius)
        let disabledImage = ButtonStyles.buttonImage(color: disabledColor, shadowHeight: 0, shadowColor: .clear, cornerRadius: cornerRadius)
        
        setBackgroundImage(normalImage, for: .normal)
        setBackgroundImage(highlightedImage, for: .highlighted)
        setBackgroundImage(selectedImage, for: .selected)
        setBackgroundImage(disabledImage, for: .disabled)
//        setTitleColor(UIColor.ThemeLabel.disable, for: .disabled)
    }
    
    func setFont(_ font : UIFont = UIFont.Ex.medium(14)){
        self.titleLabel?.font = font
    }
    
    func isAnimating() {
        self.setTitleColor(UIColor.clear, for: .normal)
    }
    
    func animationStopped() {
        if let titlec = self.storedTitleColor {
            self.setTitleColor(titlec, for: .normal)
        }
    }
}

enum EXButtonColor{
    public static var greenColor            = UIColor.extColorWithHex("00B595")
    public static var highlightedGreenColor = UIColor.extColorWithHex("26C0A4")
    public static var redColor              = UIColor.extColorWithHex("D1425E")
    public static var highlightedRedColor   = UIColor.extColorWithHex("D75E75")
    public static var blueColor             = UIColor.extColorWithHex("2B61FF")
    public static var highlightedBlueColor  = UIColor.extColorWithHex("4E8CFF")
}

enum EXButtonStyles:Int {
    //Can only be added at the tail end
    case defultColor                        = 0     //Only text gray
    case up                                 = 1
    case down                               = 2
    case blueColor                          = 3
    case defultColorBlueLine                = 4     //Text blue border line blue, changed from 6.0 to gray
    case lightColor                         = 5     //Text gray background light
    case lightBlueColor                     = 6     //Text with a light blue background
    case clearBlueColor                     = 7     //Text default gray selected, blue background transparent
    case blueTextColor                     = 8     //Text with a transparent blue background
    
    var color:UIColor{
        switch self{
        case .up:  if EXKLineManager.isGreen(){return EXButtonColor.greenColor}else {return EXButtonColor.redColor}
        case .down:if EXKLineManager.isGreen(){return EXButtonColor.redColor  }else {return EXButtonColor.greenColor}
        case .blueColor:                            return EXButtonColor.blueColor
        case .defultColorBlueLine:                  return UIColor.ThemeView.card2
        case .defultColor:                          return UIColor.ThemeView.bg
        case .lightColor,.lightBlueColor:           return UIColor.ThemeBtn.normal
        case .clearBlueColor,.blueTextColor:                       return UIColor.clear
        }
    }
    
    var highlightedColor:UIColor{
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
        }
    }
    var selectedColor:UIColor{
        return highlightedColor
    }
    
    var titleColor:UIColor {
        switch self{
        case .up,.down,.blueColor,.defultColorBlueLine:                  return UIColor.white
        case .lightBlueColor,.blueTextColor:  return EXButtonColor.blueColor
        default :                                   return UIColor.ThemeBtn.title
        }
    }
    var titleSelectColor:UIColor {
        switch self{
        case .clearBlueColor:                       return UIColor.ThemeLabel.colorHighlight
        default :                                   return titleColor
        }
    }
    var disabledColor:UIColor{
        switch self{
        default : return UIColor.ThemeBtn.disable
        }
    }
    var cornerRadius:CGFloat{
        switch self{
        default : return 4
        }
    }
    var borderWidth:CGFloat{
        switch self{
//        case .defultColorBlueLine:return 1
        default : return 0
        }
    }
    var borderColor:UIColor?{
        switch self{
//        case .defultColorBlueLine:return EXButtonColor.blueColor
        default : return nil
        }
    }

}


