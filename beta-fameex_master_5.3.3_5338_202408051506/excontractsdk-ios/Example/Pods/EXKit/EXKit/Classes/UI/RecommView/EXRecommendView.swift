//
//  EXRecommendView.swift
//  EXKit_Example
//
//  Created by cwd on 2022/7/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

/**
 推荐模型,外部转化
 */
public class RecommendItem: NSObject{
    public var isSelected: Bool = false
    public var index: String = ""
    public var title: String = ""
    public var attrtitle = NSAttributedString()
    public var subtitle: String = ""
    public var sigle: Bool = false
    
   
}
//自选推荐
public class EXRecommendView: EXBaseView {
    var empty = EXComEmptyView()
    public var emptyImage: UIImage = UIImage() {
        didSet{
            self.empty.imgV.image = emptyImage
        }
    }
    //属性
    public var btnTitle: String = "" {
        didSet{
            sureBtm.setTitle(btnTitle, for: .normal)
        }
    }
    //按钮样式
    public var btnStyle: BtnStyle = .sure{
        didSet{
            sureBtm.setBackgroundColor(color: btnStyle.bgColor, forState: .normal)
            sureBtm.setBackgroundColor(color: btnStyle.bgHighLightColor, forState: .highlighted)
            sureBtm.setBackgroundColor(color: btnStyle.bgColor, forState: .selected)
            sureBtm.setBackgroundColor(color: btnStyle.disenbleColor, forState: .disabled)
            sureBtm.setTitleColor(btnStyle.titleColor, for: .normal)
        }
    }
    
    public var items = [RecommendItem]() {
        didSet{
            sureBtm.isHidden = items.count == 0
            mainCollection.reloadData()
            
            var h = EXRecommendView.getViewHeight(count: items.count)
            if items.count == 0 {
                empty.isHidden = false
                h = EXRecommendView.getViewHeight(count: 6)
            }
            mainCollection.snp.makeConstraints { make in
                make.height.equalTo(h)
            }
        }
    }
    
    class func getViewHeight(count: Int = 6) -> CGFloat {
        let row =  (count + 1 ) / 2
        return  60  * CGFloat(row) +  12 * CGFloat(row-1) + EXRecommendView.topMargin
    }
    
    public var btnClick: EXComStringArrayBlock?
    let recommendCollectionViewCell = "EXRecommendCollectionViewCell"
    static let topMargin: CGFloat = 8
    lazy var layout: UICollectionViewFlowLayout = {
        let margin: CGFloat = 16
        let itemW: CGFloat = (Device_W - margin * 2 - 15) * 0.5
        let ly = UICollectionViewFlowLayout()
        ly.minimumLineSpacing = 12
        ly.minimumInteritemSpacing = 15
        ly.sectionInset = UIEdgeInsets(top: EXRecommendView.topMargin, left: margin, bottom: 0, right: margin)
        ly.itemSize = CGSize(width: itemW, height: 60)
        return ly
        
    }()
    lazy var mainCollection : UICollectionView = {
        let collectionV = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionV.showsHorizontalScrollIndicator = false
        collectionV.showsVerticalScrollIndicator = false
        collectionV.register(EXRecommendCollectionViewCell.self, forCellWithReuseIdentifier: recommendCollectionViewCell)
        collectionV.delegate = self
        collectionV.dataSource = self
        collectionV.backgroundColor = UIColor.ThemeView.bg
        collectionV.isPagingEnabled = true
        collectionV.bounces = false
        collectionV.clipsToBounds = false
        if #available(iOS 11.0, *) {
            collectionV.contentInsetAdjustmentBehavior = .never
        }
        return collectionV
    }()

    //确认
    lazy var sureBtm : UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.ThemeLabel.colorHighlight
        btn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        btn.addTarget(self, action: #selector(clickBtn), for: UIControl.Event.touchUpInside)
        btn.setTitle("全部选择", for: .normal)
        btn.corneradius = 4
        return btn
    }()
    
    public override func setSubView() {
        self.addSubview(mainCollection)
        mainCollection.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(EXRecommendView.getViewHeight())
        }
        self.addSubview(sureBtm)
        sureBtm.snp.makeConstraints { make in
            make.top.equalTo(mainCollection.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
        self.addSubview(empty)
        empty.isHidden = true
        let wh = EXComEmptyView.getHeight()
        empty.snp.makeConstraints { make in
            make.width.height.equalTo(wh)
            make.center.equalTo(self)
        }
    }
    
    @objc func clickBtn(){
       let selecteds = items.filter { $0.isSelected == true}
       var ids = [String]()
       for i in selecteds {
            print("i.index=>\(i.index)")
           ids.append(i.index)
       }
       btnClick?(ids)
    }
    func updateBtnState(){
        let selecteds = items.filter { $0.isSelected == true}
        sureBtm.isEnabled = selecteds.count > 0
    }
}


extension EXRecommendView: UICollectionViewDelegate,UICollectionViewDataSource{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recommendCollectionViewCell, for: indexPath) as! EXRecommendCollectionViewCell
        cell.item = items[indexPath.row]
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.isSelected = !item.isSelected
        collectionView.reloadItems(at: [indexPath])
        updateBtnState()
        
    }
    
}


public class EXComEmptyView: EXBaseView {
    public static func getHeight() -> CGFloat {
        return 60 + 10 + 17
    }
    lazy var imgV : UIImageView = {
        let imgV = UIImageView.init()
        imgV.contentMode = .scaleAspectFit
        imgV.image =  EXKitBundle.svgImage(named: "public_nocontentyet")
        return imgV
    }()
    
    lazy var label : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = EXUIDatasource.shared.no_data  //"cp_extra_text52"
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textAlignment = .center
        return label
    }()
    
    public override func setSubView() {
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubview(imgV)
        self.addSubview(label)
        imgV.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.width.equalTo(60)
        }
        label.snp.makeConstraints { (make) in
            make.top.equalTo(imgV.snp.bottom).offset(10)
            make.height.equalTo(17)
            make.left.right.equalToSuperview()
        }
    }
}

