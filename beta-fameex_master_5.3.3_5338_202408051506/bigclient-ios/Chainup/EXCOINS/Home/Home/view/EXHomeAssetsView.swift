//
//  EXHomeAssetsView.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//Account page

import UIKit
import EXKit
class EXHomeAssetsView: UIView {
    
    //1 coin, 2 OTC, 3 contracts, 4 leverage
    var assetArr : [HomeAssetsEntity] = [HomeAssetsEntity(),HomeAssetsEntity(),HomeAssetsEntity(),HomeAssetsEntity()]
    
    lazy var homeLoginAssetsView : EXHomeLoginAllAssetsView = {
        let view = EXHomeLoginAllAssetsView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var homeUnLoginAssetsView : EXHomeUnLoginAssetsView = {
        let view = EXHomeUnLoginAssetsView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var bottomV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeNav.bg
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        addSubViews([homeLoginAssetsView,homeUnLoginAssetsView,bottomV])
        homeLoginAssetsView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(bottomV.snp.top)
        }
        homeUnLoginAssetsView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(bottomV.snp.top)
        }
        bottomV.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(10)
        }
    }
    
    func setView(){
        homeUnLoginAssetsView.isHidden = XUserDefault.getToken() != nil
        homeLoginAssetsView.isHidden = XUserDefault.getToken() == nil
        //If logging in
//        if XUserDefault.getToken() != nil{
//            var arr : [HomeAssetsEntity] = []
//            let coinentity = assetArr[0]
//            coinentity.name = LanguageTools.getString(key: "assets_text_exchange")
//            arr.append(coinentity)
//
//        if PublicInfoManager.sharedInstance.getLeverOpen(){
//            let otcentity = assetArr[3]
//            otcentity.name = LanguageTools.getString(key: "leverage_asset")
//            arr.append(otcentity)
//        }
//            if PublicInfoEntity.sharedInstance.haveOTC == "1"{
//                let otcentity = assetArr[1]
//                otcentity.name = LanguageTools.getString(key: "assets_text_otc")
//                arr.append(otcentity)
//            }
//
//            if PublicInfoEntity.sharedInstance.contractOpen == "1"{
//                let otcentity = assetArr[2]
//                otcentity.name = LanguageTools.getString(key: "assets_text_contract")
//                arr.append(otcentity)
//            }
//            homeLoginAssetsView.hiddenBtn.isSelected = XUserDefault.assetPrivacyIsOn()
//            homeLoginAssetsView.collectRowDatas = arr
//        }        
    }
    
    func setAsset(_ index : Int , entity : HomeAssetsEntity){
        if assetArr.count > index{
            assetArr[index] = entity
        }
        setView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

//Logged in to homepage My total assets
class EXHomeLoginAllAssetsView : UIView {
    
    //My assets
    lazy var myassetLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.HeadBold
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = LanguageTools.getString(key: "home_text_assets")
        return label
    }()
    
    //Hide Button
    lazy var hiddenBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setImage(UIImage.themeImageNamed(imageName: "login_eyeoff"), for: UIControl.State.normal)
        btn.setImage(UIImage.themeImageNamed(imageName: "login_eyeon"), for: UIControl.State.selected)
        btn.extSetAddTarget(self, #selector(clickHiddenBtn(_:)))
        return btn
    }()
    
    lazy var hilineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    lazy var allBlanceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorHighlight
        label.text = "assets_text_total".localized()
        label.font = UIFont.ThemeFont.SecondaryBold
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var rightImgV :UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.contentMode = .scaleAspectFit
        imgV.image = EXKitBundle.image(named: "public_positions_arrow_right")
        return imgV
    }()
    
    lazy var assetsLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        return label
    }()
    
    lazy var equivalentLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryBold
        return label
    }()
    
    lazy var iconImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.themeImageNamed(imageName: "home_assetentry")
        return imgV
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([myassetLabel,hiddenBtn,hilineV,allBlanceLabel,rightImgV,assetsLabel,equivalentLabel,iconImgV])
        hilineV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalToSuperview().offset(46)
        }
        myassetLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(22)
            make.right.equalTo(hiddenBtn.snp.left).offset(-10)
        }
        hiddenBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.lessThanOrEqualTo(16)
            make.width.equalTo(16)
            make.centerY.equalTo(myassetLabel)
        }
        allBlanceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(17)
            make.top.equalTo(hilineV.snp.bottom).offset(15)
        }
        rightImgV.snp.makeConstraints { (make) in
            make.left.equalTo(allBlanceLabel.snp.right).offset(3)
            make.height.width.equalTo(8.5)
            make.centerY.equalTo(allBlanceLabel)
        }
        assetsLabel.snp.makeConstraints { (make) in
            make.height.equalTo(19)
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(iconImgV.snp.left).offset(-10)
            make.top.equalTo(allBlanceLabel.snp.bottom).offset(10)
        }
        equivalentLabel.snp.makeConstraints { (make) in
            make.height.equalTo(14)
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(iconImgV.snp.left).offset(-10)
            make.top.equalTo(assetsLabel.snp.bottom).offset(3)
        }
        iconImgV.snp.makeConstraints { (make) in
            make.height.equalTo(94)
            make.width.equalTo(140)
            make.right.equalToSuperview()
            make.top.equalTo(hilineV.snp.bottom)
        }
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickView))
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func clickView(){
        let action = "coin"
        EXNavigationHandler.sharedHandler.commandToAsset(action)
    }
    
    var model = EXHomeAssetModel()
    
    //Click to hide
    @objc func clickHiddenBtn(_ btn : UIButton){
        btn.isSelected = !btn.isSelected
        XUserDefault.switchAssets(btn.isSelected)
        setView(self.model)
    }
    
    func setView(_ model : EXHomeAssetModel){
        self.model = model
        let bool = XUserDefault.assetPrivacyIsOn()
        hiddenBtn.isSelected = bool
        if bool {
            assetsLabel.text = String.privacyString()
            equivalentLabel.text =  String.privacyString()
        }else{
            assetsLabel.attributedText = model.assetsAtt
            equivalentLabel.text = model.rmb
        }
    }

    
}

//Logged in to homepage My Assets
class EXHomeLoginAssetsView : UIView ,UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectRowDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let entity = collectRowDatas[indexPath.row]
        let cell : EXHomeLoginAssetsDetailCC = collectionView.dequeueReusableCell(withReuseIdentifier: "EXHomeLoginAssetsDetailCC", for: indexPath) as! EXHomeLoginAssetsDetailCC
        cell.setCell(entity)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        if collectRowDatas.count > index{
            let name = collectRowDatas[index].name
            var action = "coin"
            if name == LanguageTools.getString(key: "assets_text_otc"){
                action = "otc"
            }else if name == LanguageTools.getString(key: "assets_text_contract"){
                action = "contract"
            }else if name == "leverage_asset".localized(){
                action = "leverage"
            }
            EXNavigationHandler.sharedHandler.commandToAsset(action)
        }
    }
    
    var collectRowDatas : [HomeAssetsEntity] = []
    {
        didSet{
            setView(collectRowDatas)
        }
    }
    
    //My assets
    lazy var myassetLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.HeadBold
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = LanguageTools.getString(key: "home_text_assets")
        return label
    }()
    
    //Hide Button
    lazy var hiddenBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setImage(UIImage.themeImageNamed(imageName: "login_eyeoff"), for: UIControl.State.selected)
        btn.setImage(UIImage.themeImageNamed(imageName: "login_eyeon"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickHiddenBtn(_:)))
        return btn
    }()
    
    lazy var hilineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    lazy var collectionV : UICollectionView = {
        let collectionV = UICollectionView.init(frame: CGRect.init(x: 0, y: 46, width: SCREEN_WIDTH, height: 180) , collectionViewLayout: getCollectionLayout())
        collectionV.showsHorizontalScrollIndicator = false
        collectionV.showsVerticalScrollIndicator = false
        collectionV.register(EXHomeLoginAssetsDetailCC.classForCoder(), forCellWithReuseIdentifier: "EXHomeLoginAssetsDetailCC")
        collectionV.delegate = self
        collectionV.dataSource = self
        collectionV.backgroundColor = UIColor.ThemeView.bg
        return collectionV
    }()
    
    func getCollectionLayout() -> UICollectionViewFlowLayout{
        let width = SCREEN_WIDTH / 2
        let collectionLayout = UICollectionViewFlowLayout.init()
        collectionLayout.scrollDirection = .vertical
        collectionLayout.minimumLineSpacing = 0
        collectionLayout.minimumInteritemSpacing = 0
        collectionLayout.itemSize = CGSize.init(width: width, height: 90)
        return collectionLayout
    }
    
    lazy var hlineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    lazy var vLineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([myassetLabel,hiddenBtn,collectionV,hilineV,hlineV,vLineV])
        hilineV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalToSuperview().offset(46)
        }
        myassetLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(22)
            make.right.equalTo(hiddenBtn.snp.left).offset(-10)
        }
        hiddenBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.lessThanOrEqualTo(16)
            make.width.equalTo(16)
            make.centerY.equalTo(myassetLabel)
        }
        vLineV.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalTo(hilineV.snp.bottom)
            make.width.equalTo(0.5)
        }
        hlineV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.centerY.equalTo(collectionV)
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Click to hide
    @objc func clickHiddenBtn(_ btn : UIButton){
        btn.isSelected = !btn.isSelected
        XUserDefault.switchAssets(btn.isSelected)
        collectionV.reloadData()
    }
    
    func setView(_ arr : [Any]){
        if arr.count < 3{
            collectionV.frame = CGRect.init(x: 0, y: 46, width: SCREEN_WIDTH, height: 90)
            hlineV.isHidden = true
        }else{
            collectionV.frame = CGRect.init(x: 0, y: 46, width: SCREEN_WIDTH, height: 180)
            hlineV.isHidden = false
        }
        collectionV.reloadData()
    }
}

class EXHomeLoginAssetsDetailCC : UICollectionViewCell{
    
    lazy var nameBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.isUserInteractionEnabled = false
        btn.titleLabel?.font = UIFont.ThemeFont.SecondaryBold
        btn.setTitleColor(UIColor.ThemeBtn.highlight, for: UIControl.State.normal)
        return btn
    }()
    
    lazy var rightBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.isUserInteractionEnabled = false
        btn.setImage(UIImage.themeImageNamed(imageName: "home_enter"), for: UIControl.State.normal)
        return btn
    }()
    
    lazy var moneyLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.extUseAutoLayout()
        label.isUserInteractionEnabled = false
        return label
    }()
    
    lazy var rmbLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.isUserInteractionEnabled = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.ThemeView.bg
        contentView.addSubViews([nameBtn,rightBtn,moneyLabel,rmbLabel])
        nameBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(14)
            make.width.lessThanOrEqualTo(SCREEN_WIDTH / 2 - 30)
            make.height.equalTo(17)
        }
        rightBtn.snp.makeConstraints { (make) in
            make.height.width.equalTo(8.5)
            make.centerY.equalTo(nameBtn)
            make.left.equalTo(nameBtn.snp.right).offset(5)
        }
        moneyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameBtn)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(19)
            make.top.equalTo(nameBtn.snp.bottom).offset(10)
        }
        rmbLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(moneyLabel)
            make.height.equalTo(14)
            make.top.equalTo(moneyLabel.snp.bottom).offset(2)
        }
    }
    
    func setHidden(_ entity : HomeAssetsEntity){
        let bool = XUserDefault.assetPrivacyIsOn()
        if bool {
            moneyLabel.text = String.privacyString()
            rmbLabel.text =  String.privacyString()
        }else{
            moneyLabel.attributedText = entity.assetsAtt
            rmbLabel.text = entity.rmb
        }
    }
    
    func setCell(_ entity : HomeAssetsEntity){
        nameBtn.setTitle(entity.name, for: UIControl.State.normal)
        setHidden(entity)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//My assets are not logged in to the homepage
class EXHomeUnLoginAssetsView : UIView{
    
    lazy var assetsLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.HeadBold
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = LanguageTools.getString(key: "home_text_assets")
        return label
    }()
    
    lazy var promptLoginLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.text = LanguageTools.getString(key: "home_action_notLogin")
        return label
    }()
    
    lazy var loginBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.extSetCornerRadius(4)
        btn.setTitle(LanguageTools.getString(key: "login_action_login"), for: UIControl.State.normal)
        btn.extSetBorderWidth(0.5, color: UIColor.ThemeView.border.withAlphaComponent(0.5))
        btn.backgroundColor = UIColor.ThemeTab.bg.withAlphaComponent(0.5)
        btn.titleLabel?.font = UIFont.ThemeFont.SecondaryBold
        btn.setTitleColor(UIColor.ThemeBtn.highlight, for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickLoginBtn))
        return btn
    }()
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.themeImageNamed(imageName: EXHomeViewModel.getHomeNoLoginDefaultImage())
        return imgV
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([assetsLabel,promptLoginLabel,loginBtn,imgV])
        assetsLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(22)
            make.right.equalTo(imgV.snp.left).offset(-10)
        }
        promptLoginLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(assetsLabel.snp.bottom).offset(2)
            make.height.equalTo(17)
            make.right.equalTo(imgV.snp.left).offset(-10)
        }
        loginBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(promptLoginLabel.snp.bottom).offset(15)
            make.height.equalTo(30)
            make.width.equalTo(110)
        }
        imgV.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(180)
            make.height.equalTo(116)
        }
    }
    
    //Click on the login button
    @objc func clickLoginBtn(){
        BusinessTools.modalLoginVC()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EXHomeBannerAssetView : UIView{
    
    lazy var noLoginView : EXHomeBannerAssetNoLoginView = {
        let view = EXHomeBannerAssetNoLoginView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var loginView : EXHomeBannerAssetLoginView = {
        let view = EXHomeBannerAssetLoginView()
        view.extUseAutoLayout()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([noLoginView,loginView])
        noLoginView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        loginView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func setView(_ totalAccountBlance : String){
        noLoginView.isHidden = XUserDefault.getToken() != nil
        loginView.isHidden = XUserDefault.getToken() == nil
        loginView.setView(totalAccountBlance)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EXHomeBannerAssetNoLoginView : UIView{
    
    lazy var imgBackV : UIImageView = {
        let imgV = UIImageView()
        imgV.contentMode = .scaleAspectFill
        imgV.backgroundColor = UIColor.ThemeView.highlight
        imgV.image = UIImage.themeImageNamed(imageName: "banner_japan")
        imgV.extUseAutoLayout()
        imgV.extSetCornerRadius(8)
        return imgV
    }()
    
    
    lazy var assetLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = "home_text_assets".localized()
        label.textColor = UIColor.ThemeLabel.white
        label.font = UIFont.ThemeFont.H3Bold
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var assetDetailLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = "home_action_notLogin".localized()
        label.textColor = UIColor.ThemePageControl.bannerSelect
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var loginBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setTitle("login_action_login".localized(), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.SecondaryRegular
        btn.extSetCornerRadius(2)
        btn.extSetBorderWidth(0.5, color: UIColor.white)
        btn.extSetAddTarget(self, #selector(clickLoginBtn))
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([imgBackV,assetLabel,assetDetailLabel,loginBtn])
//        imgBackV.backgroundColor = UIColor.GradientColor.japanHeader(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH - MARGIN_LEFT_DOUBLE, height: EXHomePageHeightHelper.bannerH))

        imgBackV.snp.makeConstraints { (make) in
            make.left.equalTo(MARGIN_LEFT)
            make.right.equalTo(-MARGIN_LEFT)
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview()
        }
        assetLabel.snp.makeConstraints { (make) in
            make.left.equalTo(MARGIN_LEFT_DOUBLE)
            make.top.equalTo(22)
            make.height.equalTo(20)
        }

        assetDetailLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.height.equalTo(17)
            make.top.equalTo(assetLabel.snp.bottom).offset(20)
        }
        loginBtn.snp.makeConstraints { (make) in
            make.top.equalTo(assetDetailLabel.snp.bottom).offset(20)
            make.height.equalTo(30)
            make.width.equalTo(110)
            make.left.equalToSuperview().offset(30)
        }
    }
    
    //Click on the login button
    @objc func clickLoginBtn(){
        BusinessTools.modalLoginVC()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EXHomeBannerAssetLoginView : UIView{
    
    lazy var imgBackV : UIImageView = {
        let imgV = UIImageView()
        imgV.contentMode = .scaleAspectFill
        imgV.backgroundColor = UIColor.ThemeView.highlight
        imgV.image = UIImage.themeImageNamed(imageName: "banner_japan")
        imgV.extUseAutoLayout()
        imgV.extSetCornerRadius(8)
        return imgV
    }()
    
    lazy var assetLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = "home_text_assets".localized()
        label.textColor = UIColor.ThemeLabel.white
        label.font = UIFont.ThemeFont.H3Bold
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var totalAssetsLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = "assets_text_total".localized()
        label.textColor = UIColor.ThemePageControl.bannerSelect
        label.font = UIFont.ThemeFont.SecondaryMedium
        label.layoutIfNeeded()
        return label
    }()
//
//    lazy var totalAssetsImgV : UIImageView = {
//        let imgV = UIImageView()
//        imgV.extUseAutoLayout()
//        imgV.image = UIImage.init(named: "home_enter")
//        return imgV
//    }()
    
    lazy var totalBtcAssetLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.white
        label.font = UIFont.ThemeFont.H1Medium
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var reducedLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemePageControl.bannerSelect
        label.font = UIFont.ThemeFont.SecondaryMedium
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var hideBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setImage(UIImage.themeImageNamed(imageName: "login_eyeon"), for: UIControl.State.selected)
        btn.setImage(UIImage.themeImageNamed(imageName: "login_eyeoff"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickHideBtn))
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([imgBackV,assetLabel,totalAssetsLabel,totalBtcAssetLabel,reducedLabel,hideBtn])
//        imgBackV.backgroundColor = UIColor.GradientColor.japanHeader(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH - MARGIN_LEFT_DOUBLE, height: EXHomePageHeightHelper.bannerH))
        imgBackV.snp.makeConstraints { (make) in
            make.left.equalTo(MARGIN_LEFT)
            make.right.equalTo(-MARGIN_LEFT)
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview()
        }
        
        assetLabel.snp.makeConstraints { (make) in
            make.left.equalTo(MARGIN_LEFT_DOUBLE)
            make.top.equalTo(22)
            make.height.equalTo(20)
        }
        
        totalAssetsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(MARGIN_LEFT_DOUBLE)
            make.top.equalTo(assetLabel.snp.bottom).offset(20)
            make.height.equalTo(16)
        }
//
//        totalAssetsImgV.snp.makeConstraints { (make) in
//            make.height.width.equalTo(8.5)
//            make.centerY.equalTo(totalAssetsLabel)
//            make.left.equalTo(totalAssetsLabel.snp.right).offset(5)
//        }
        totalBtcAssetLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(MARGIN_LEFT_DOUBLE)
            make.top.equalTo(totalAssetsLabel.snp.bottom).offset(2)
            make.height.equalTo(32)
        }
        reducedLabel.snp.makeConstraints { (make) in
            make.left.equalTo(totalBtcAssetLabel.snp.right).offset(4)
            make.height.equalTo(16)
            make.bottom.equalTo(totalBtcAssetLabel.snp.bottom)
        }
        
        hideBtn.snp.makeConstraints { (make) in
            make.height.equalTo(17)
            make.width.equalTo(17)
            make.right.equalToSuperview().offset(-MARGIN_LEFT_DOUBLE)
            make.centerY.equalTo(assetLabel)
        }
        hideBtn.setEnlargeEdgeWithTop(20, left: 20, bottom: 20, right: 20)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickView))
        self.addGestureRecognizer(tap)
    }
    
    var balance = ""
    
    func setView(_ balance : String){
        if XUserDefault.assetPrivacyIsOn() == false{
            if balance != ""{
                self.balance = balance
            }else{
                self.balance = "0"
            }
            
            totalBtcAssetLabel.text = self.balance.formatAmount("BTC")
            let btc = EXAppMarketManager.sharedInstance.getCoinExchangeRate("BTC")
            if let str = NSString.init(string: self.balance).multiplying(by: btc.1, decimals: btc.2){
                reducedLabel.text = "≈" + btc.0 + str
            }
            hideBtn.isSelected = false
        }else{
            hideBtn.isSelected = true
            totalBtcAssetLabel.text = "****"
            reducedLabel.text = "****"
        }
    }
    
    @objc func clickHideBtn(){
        hideBtn.isSelected = !hideBtn.isSelected
        XUserDefault.switchAssets(hideBtn.isSelected)
        setView(self.balance)
    }
    
    @objc func clickView(){
        let action = "coin"
        EXNavigationHandler.sharedHandler.commandToAsset(action)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

