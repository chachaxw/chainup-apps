import EXKit
class EXEditFavoriteCell: EXHomeBaseCell {
    var onTopActionCallback: (() -> ())?

    lazy var editCheckBox:EXCheckBox = {
        let check = EXCheckBox.init(frame: .zero, style: .circleCheck)
        return check
    }()
    
//    lazy var bottomLine:UIView = {
//        let line = UIView.init()
//        line.backgroundColor = UIColor.ThemeView.seperator
//        return line
//    }()
    
    lazy var topPin:UIButton = {
        let pin = UIButton.init(type: .custom)
        pin.addTarget(self, action: #selector(topAction), for: .touchUpInside)
        pin.setImage(EXKitBundle.image(named: "quotes_top"), for: .normal)
        return pin
    }()
    
    lazy var moveHandler:UIButton = {
        let handler = UIButton.init(type: .custom)
        handler.setImage(EXKitBundle.image(named:  "quotes_drag"), for: .normal)
        return handler
    }()
    
    @objc func topAction() {
        self.onTopActionCallback?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(editCheckBox)
        self.contentView.addSubview(topPin)
        self.contentView.addSubview(moveHandler)
//        self.contentView.addSubview(bottomLine)
//        editCheckBox.updateInnerGap(10)
        editCheckBox.spacing = 10
        let centerX = EXUIMeasure.getPercentX(0.73)
        editCheckBox.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(topPin.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        topPin.snp.makeConstraints { (make) in
            make.width.equalTo(44)
            make.height.equalToSuperview()
            make.centerX.equalTo(centerX)
            make.centerY.equalToSuperview()
        }
        
        moveHandler.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
        
//        bottomLine.snp.makeConstraints { (make) in
//            make.bottom.equalToSuperview()
//            make.height.equalTo(1/UIScreen.main.scale)
//            make.left.equalTo(15)
//            make.right.equalToSuperview()
//        }
    }
    
    func updateCoinName(name:String,isChecked:Bool) {
//        let nameAttrStr = String.getCoinMapAttr(name.aliasCoinMapName(),leftFont:UIFont().themeHNBoldFont(size: 16))
        //        editCheckBox.attributeText(content: nameAttrStr)
        editCheckBox.checkLabel.setCoinMap(name.aliasCoinMapName(), leftFont: UIFont.ThemeFont.HeadMedium, handleKern: 2)
        editCheckBox.checked(check: isChecked)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

