//
//  EXLeverageSliderView.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/3/17.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit


class EXCustomSlider: UISlider {
    
//    //Make him look like he can reach the end
//    override func trackRect(forBounds bounds: CGRect) -> CGRect {
//        let rect = super.trackRect(forBounds: bounds)
//        let h = self.bounds.height
//        let y = (h - rect.height) * 0.5
//        return CGRect(x: 0, y: y, width: rect.width, height: rect.height)
////        return CGRect(x: -10, y: rect.origin.y, width: rect.width + 20, height: rect.height)
//    }
   //Change the touch range of the slider
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
//        var rect = bounds
//        rect.origin.x = rect.origin.x-10
//        rect.size.width=rect.size.width+20;
//        return super.thumbRect(forBounds: bounds, trackRect: rect, value: value).insetBy(dx: 10, dy: 10)
//        let thumbRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
//        if let img = self.currentThumbImage {
//            return CGRect(x: thumbRect.origin.x, y: thumbRect.origin.y, width: img.size.width, height: img.size.height)
//        }else {
//            return thumbRect
//        }
        var trackRect = rect
        trackRect.origin.x -= 10
        trackRect.origin.y -= 10
        trackRect.size.width += 20
        trackRect.size.height += 20
        
        return super.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        
        
    }
}



class EXNewLeverageSliderView: UIView{
    var isLever: Bool = false //Is it a lever
    ///Minimum value
    var minLevel = 1
    ///Maximum value
    var maxLevel = 100
    var availableLevel = 100
    var valueChangedCallback: ((Int) -> ())?
    var valueOnTapCallback: ((Int) -> ())?
    var lastlevel = 0
    var startEdit: (() -> ())?
    ///Slider size
    let thumbWH = 16
    ///Number of nodes
    var numberOfPart = 5
    //button
    var partViewArray: [UIButton] = []
    //Leveraged display copy
    var textLabelArray: [UILabel] = []
    //Is the display block with sliding top displayed
    var showTopTip = false
    
     //MARK: lifecycle
    init(frame: CGRect, minLevel: Int, maxLevel: Int,availableLevel:Int = 0,showTopTip: Bool = false) {
        super.init(frame: frame)
        self.showTopTip = showTopTip
        self.maxLevel = maxLevel
        self.minLevel = minLevel
        if availableLevel == 0 {
            self.availableLevel = maxLevel
        }else {
            self.availableLevel = availableLevel
        }
        self.slider.maximumValue = Float(self.maxLevel)
        //MARK: The minimum value here is set to 0, otherwise the slider will have an offset. When displaying, the minLevel passed externally needs to be used
        self.slider.minimumValue = 0  //Float(self.minLevel)
        numberOfPart = (self.maxLevel / 25) + 1
        if self.maxLevel <= 25 {
            numberOfPart = 5
        }
        lastlevel = self.maxLevel
        configBottomSliderMaskView()
        self.exs_addSubViews([self.bottomSlider,self.sliderMaskView, self.slider,self.topTipView])
        self.initLayout()
        updateViewStyle()
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: lazy
    lazy var topTipView: LeverTipView = {
        let l = LeverTipView()
//        l.titleLabel.roundCorners(corners: .allCorners, radius: 4)
        l.isHidden = true
        return l
    }()
    
    //Top slider
    private lazy var slider: EXCustomSlider = {
        let slider = EXCustomSlider()
        slider.minimumValue = Float(self.minLevel)
        slider.maximumValue = Float(self.maxLevel)
        slider.backgroundColor = UIColor.clear
        slider.isContinuous = true
        slider.setThumbImage(UIImage.svg_themeImageNamed(imageName: "contract_leverage_slider"), for: .normal)
        slider.setMinimumTrackImage(UIImage.exs_imageWithColor( UIColor.clear), for: .normal)
        slider.setMaximumTrackImage(UIImage.exs_imageWithColor( UIColor.clear), for: .normal)
        slider.setMinimumTrackImage(UIImage.exs_imageWithColor( UIColor.clear), for: .disabled)
        slider.setMaximumTrackImage(UIImage.exs_imageWithColor( UIColor.clear), for: .disabled)
//        slider.isUserInteractionEnabled = false
        slider.alpha = 1.0
        slider.addTarget(self, action: #selector(sliderValueChange(_:for:)), for: .valueChanged)
        let panGesture = UIPanGestureRecognizer(target: nil, action:nil)
                            panGesture.cancelsTouchesInView = false
                            slider.addGestureRecognizer(panGesture)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(handleTapGesture(recognizer:)))
        slider.addGestureRecognizer(tap)
       // <#v#>.isUserInteractionEnabled = true
        
        return slider

    }()

    lazy var bottomSlider: UIProgressView = {
        let view = UIProgressView()
        view.progressTintColor = UIColor.ThemeView.highlight
        view.trackTintColor = UIColor.getConfigBg()   //.ThemeView.card2
        view.setProgress(0, animated: true)
        return view
    }()
    ///Add buttons and labels
    private lazy var sliderMaskView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .equalSpacing
        view.alignment = .fill
        return view
    }()

    private func initLayout() {
        self.slider.snp.makeConstraints { (make) in
            make.left.equalTo(Double(thumbWH/2))
            make.right.equalTo(Double(-thumbWH/2))
//            make.height.equalTo(26)
            make.top.bottom.equalToSuperview()
        }
        
        self.bottomSlider.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.slider)
            make.height.equalTo(2)
            make.centerY.equalTo(self.slider).offset(1.5)
        }
        self.sliderMaskView.snp.makeConstraints { (make) in
            make.height.equalTo(self.slider)
            make.centerY.equalTo(self.bottomSlider)
            make.left.equalTo(self.slider).offset(-Double(thumbWH/2))
            make.right.equalTo(self.slider).offset(Double(thumbWH/2))
            
//            make.left.equalTo(Double(thumbWH/2)-5)
//            make.right.equalTo(Double(-thumbWH/2)+5)
        }
        self.topTipView.snp.makeConstraints { make in
            make.bottom.equalTo(self.slider.snp.top)
            make.width.equalTo(29)
            make.height.equalTo(25)
            make.centerX.equalTo(5)
        }
    }
}
extension EXNewLeverageSliderView{
    
    //MARK: UI
    //Cover the underlying slider
    func configBottomSliderMaskView() {
        self.partViewArray.removeAll()
        self.textLabelArray.removeAll()
        for i in 0..<numberOfPart {
            let button = UIButton(buttonType: .custom, image: UIImage.exs_themeImageNamed(imageName: "contract_leverage_not"))
            button.setImage(UIImage.svg_themeImageNamed(imageName: "contract_leverage_hover"), for: .selected)
            button.frame = CGRect(x: 0, y: 0, width: 9, height: 14)
//            button.addTarget(self, action: #selector(change(btn:)), for: .touchUpInside)
            button.tag = i
//            button.isUserInteractionEnabled = false
            self.sliderMaskView.addArrangedSubview(button)
            self.partViewArray.append(button)
            if showTopTip {
                continue //If the top shows the bottom, do not display the text block
            }
            let label = UILabel(text: "", font: UIFont.ThemeFont.MinimumRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .center)
            self.textLabelArray.append(label)
            self.sliderMaskView.addSubview(label)
            label.snp.remakeConstraints { (make) in
                make.centerX.equalTo(button)
                make.top.equalTo(button.snp.bottom).offset(0)
            }
        }
    }
    //
//    @objc func change(btn: UIButton){
//        let val = Float(btn.tag + 1) / Float(numberOfPart)
//        updateSliderValue(value: val)
//    }
    
    @objc func handleTapGesture(recognizer: UITapGestureRecognizer) {
        //  self.startEdit?()
        
        let point = recognizer.location(in: self.slider)
        let percent = Float(point.x / self.slider.frame.width)
        
//        var targets = [0,25,50,75,100,125]
//        //print("percent=\(percent)")
//        //print("round percent=\(round(percent))")

        let offset:Float = 3
        var value = round((self.slider.maximumValue - self.slider.minimumValue) * percent + self.slider.minimumValue)
        feedbackGenerator()
        if self.availableLevel > 0 && Int(self.slider.value) > self.availableLevel{
            self.slider.setValue(Float(self.availableLevel), animated: false)
            return
        }
        self.valueOnTapCallback?(Int(value))
        self.updateSliderValue(value: value)
    }
    
    //MARK: Event
    //The leverage ratio for external call switching is different, and the copy needs to be updated
    func updateLever(min:Int, max:Int,availableLevel:Int = 0) {
        self.minLevel = min
        self.maxLevel = max
        if availableLevel == 0 {
            self.availableLevel = maxLevel
        }else {
            self.availableLevel = availableLevel
        }
        slider.minimumValue = 0 // Float(min)
        slider.maximumValue = Float(max)
        updateViewStyle()
    }
    //Externally given the currently selected lever tree
    func updateSliderValueOnlyUI(value: Float) {
        self.topTipView.isHidden = true
        self.slider.setValue(value, animated: false)
        sliderValueChange(onlyUI: true)
    }
    
    //Externally given the currently selected lever tree
    func updateSliderValue(value: Float) {
        self.topTipView.isHidden = true
        self.slider.setValue(value, animated: false)
        sliderValueChange()
    }
    //Update the copy displayed on the interface
    func updateViewStyle(){
        let progress = availableLevel / maxLevel
        self.bottomSlider.setProgress(Float(progress), animated: true)
        let section = (Float(maxLevel) - Float(minLevel))
        let margin = Int(round(section / Float((numberOfPart-1))))
        for index in 0..<partViewArray.count {
            let button =  partViewArray[index]
            if index * margin > availableLevel {
                button.isSelected = false
            }else{
                button.isSelected = true
            }
            if showTopTip{
                continue //No more text displayed
            }
            var text: String
            if index == 0 {
                text = String(format: "%dx", self.minLevel)
            } else if index == numberOfPart-1 {
                text = String(format: "%dx", self.maxLevel)
            } else {
//                text = String(format: "%dx", margin*index+Int(minLevel))
                text = String(format: "%dx", margin*index)
            }
            let label = self.textLabelArray[index]
            label.text = text
        }
    }
    func updateBtnImage(level: Int){
        let section = (Float(maxLevel) - Float(minLevel))
        let margin = Int(round(section / Float((numberOfPart-1))))
        for index in 0..<partViewArray.count {
            let button =  partViewArray[index]
            if index * margin > level {
                button.isSelected = false
            }else{
                button.isSelected = true
            }
        }
    }
    
    @objc func sliderValueChange(_ slider: UISlider?, for event: UIEvent?) {
            let touchEvent = event?.allTouches?.first
            switch touchEvent?.phase {
            case .began:
//                //print("Start dragging")
                if self.showTopTip{
                    self.topTipView.isHidden = false
                }
            case .moved:
                feedbackGenerator()
                print(slider?.value as Any)
                if self.showTopTip{
                    updateTip()
                }
                if self.availableLevel > 0 && Int(self.slider.value) > self.availableLevel{
                    self.slider.setValue(Float(self.availableLevel), animated: false)
                    return
                }
                self.sliderValueChange()
            case .ended:
//                //print("End drag")
                if self.showTopTip{
                    self.topTipView.isHidden = true
                }
            default:
                break
            }
    }
    
    @objc func sliderValueChange(onlyUI:Bool = false){
        if onlyUI == false{
            self.startEdit?() //Collapse the keyboard
        }
        let val = self.slider.value
        var progress = val / Float(maxLevel)
        if val == 1 {
           progress = 0
        }
        if progress < 0.5{ //Less than half of the time, Progress bar
            progress -= Float(CGFloat(thumbWH/2)/self.width)
        }
        var level = Int(ceil(val))
        //print("level = \(level)")
        if self.showTopTip {
            if level == 0 {
                level = 1
            }
        }
        
        if self.availableLevel > 0 && Int(val) > self.availableLevel{
            self.slider.setValue(Float(self.availableLevel), animated: false)
            progress = Float(self.availableLevel) / Float(maxLevel)
            level = self.availableLevel
        }
        self.bottomSlider.setProgress(progress, animated: false)
        //print("val = \(val)")
        updateBtnImage(level: level)
        if self.isLever {
            if val == 0 { //The minimum lever value is 0, set to the minimum value
                self.valueChangedCallback?(self.minLevel)
                return
            }
        }
        if onlyUI{
            return
        }
        self.valueChangedCallback?(level)
    }
    
    //Update tipview frame
    func updateTip(){
        if !self.showTopTip{
            return
        }
        let val = self.slider.value
        var progress = val / Float(maxLevel)
        if val == 1 {
           progress = 0
        }
        var level = Int(ceil(val))
        if level == 0{
            level = 1
            progress = val / Float(maxLevel)
        }
//        //print("level = \(level)")
        updateTipView(progress:progress,level:level)
    }
   
    func updateTipView(progress:Float, level: Int){
        self.topTipView.isHidden = false
        self.topTipView.titleLabel.text = "\(level)%"
        let x = CGFloat(progress) * self.slider.width + 5
        self.topTipView.snp.updateConstraints({ make in
            make.centerX.equalTo(x)
        })
    }
    
    func reset(callback:Bool? = false){
        if let callback = callback,callback == true{
            updateSliderValue(value: 0)
        }else{
            updateSliderValueOnlyUI(value: 0)
        }
    }
}



class LeverTipView: EXCOCustomBaseView {
    
    static let arrWH: CGFloat = 6
    
    //Arrows are processed using images, and the arrows drawn at the bottom are too sharp
    lazy var arrowImage: UIImageView = {
        let arrow = UIImageView()
        arrow.contentMode = .scaleAspectFit
        arrow.image =  UIImage.svg_themeImageNamed(imageName: "contract_airbubbles")
        return arrow
    }()
     ///Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.MinimumRegular, textColor: .white, alignment: NSTextAlignment.center)
//        label.backgroundColor = UIColor.ThemeView.highlight
        label.ext_UseAutoLayout()
        return label
    }()
    override func setSubView() {
       
        addSubview(arrowImage)
        self.backgroundColor = .clear
        arrowImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        arrowImage.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
//    override func layoutSubviews(){
//        super.layoutSubviews()
//        titleLabel.roundCorners(corners: .allCorners, radius: 5)
//    }
}


/**
*Draw dashed lines using CAShapeLayer method
 *
*Param lineView: A view that needs to be drawn as a dashed line
*Param lineLength: The width of the dashed line
*Param lineSpacing: The spacing of dashed lines
*Param lineColor: The color of the dashed line
*Param lineDirection The direction of the dashed line is true for the horizontal direction, and false for the vertical direction
 **/
func drawLineOfDashByCAShapeLayer(lineView:UIView!,
                                  lineLength:Int,
                                  lineSpacing:Int,
                                  lineColor:UIColor,
                                  isHorizonal:Bool) {
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.bounds = lineView.bounds
    if (isHorizonal){
        shapeLayer.position = CGPoint(x: lineView.frame.width/2, y: lineView.frame.height)
    }else{
        shapeLayer.position = CGPoint(x: lineView.frame.size.width/2, y: lineView.frame.size.height/2)
    }
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = lineColor.cgColor
    //Set Lineweight
    if (isHorizonal){
        shapeLayer.lineWidth = lineView.frame.size.height
    }else{
        shapeLayer.lineWidth = lineView.frame.size.width
    }
    //Set line width and spacing
    shapeLayer.lineDashPattern = [NSNumber(integerLiteral: lineLength),NSNumber(integerLiteral: lineSpacing)]
    
    //set up path
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 0, y: lineView.frame.size.height/2), transform: .identity)
    
    if isHorizonal {
        path.addLine(to: CGPoint(x: lineView.frame.width, y: lineView.frame.size.height/2), transform: .identity)
    } else {
        path.addLine(to: CGPoint(x: 0, y: lineView.frame.height), transform: .identity)
    }
    shapeLayer.path = path
    //Add the drawn dashed line
    lineView.layer.addSublayer(shapeLayer)
}

