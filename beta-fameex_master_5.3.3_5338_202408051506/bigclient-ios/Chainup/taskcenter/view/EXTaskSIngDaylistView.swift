//
//  EXTaskSIngDaylistView.swift
//  Chainup
//
//  Created by cwd on 2023/7/24.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXTaskSIngDaylistView: UIView {

    private let cellId = "EXSignDayItemCell"
    static let itemWidth: CGFloat = 44
    static let itemHeight: CGFloat = 55
    var signListModel: [EXSignShowInfo]? {
        didSet{
            self.collection.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setSubView()
    }
    
    
    func setSubView() {
        self.addSubview(collection)
        collection.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
   
    public static func getSize() -> CGSize{
        let itemCount: CGFloat = 7
        let w:CGFloat  = EXTaskSIngDaylistView.itemWidth * itemCount + CGFloat(3) * (itemCount - 1)
        return CGSize(width: w, height: itemHeight)
    }
    
    
    //MARK: lazy
    lazy var collection : UICollectionView = {
        let collectionV = UICollectionView.init(frame:.zero , collectionViewLayout: getCollectionLayout())
        collectionV.showsHorizontalScrollIndicator = false
        collectionV.showsVerticalScrollIndicator = false
        collectionV.register(EXSignDayItemCell.self, forCellWithReuseIdentifier: cellId)
        collectionV.delegate = self
        collectionV.dataSource = self
        collectionV.backgroundColor = UIColor.Ex.fill3
        collectionV.isPagingEnabled = true
        collectionV.bounces = false
        collectionV.clipsToBounds = false
        if #available(iOS 11.0, *) {
            collectionV.contentInsetAdjustmentBehavior = .never
        }
        return collectionV
    }()
    
    func getCollectionLayout() -> UICollectionViewFlowLayout{
        let collectionLayout = UICollectionViewFlowLayout.init()
        collectionLayout.scrollDirection = .horizontal
        collectionLayout.minimumLineSpacing = 3
        collectionLayout.itemSize = CGSize.init(width: EXTaskSIngDaylistView.itemWidth, height: EXTaskSIngDaylistView.itemHeight)
        return collectionLayout
    }
    
}
extension EXTaskSIngDaylistView: UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.signListModel?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell: EXSignDayItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? EXSignDayItemCell {
            cell.signItem = self.signListModel?[indexPath.item]
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}



class EXSignDayItemCell: UICollectionViewCell {
    
    
    var signItem: EXSignShowInfo? {
        didSet{
            guard let signItem = signItem else { return  }
            amountLabel.text = signItem.amount
            usdtLabel.text = signItem.coin
            dayLabel.text = signItem.index
            
            let hasSigned = signItem.hasSigned
            let t1Color: UIColor = hasSigned ? .white : .Ex.text3 //选中为text4
            amountLabel.textColor = t1Color
            let t2Color: UIColor = hasSigned ? .Ex.text2 : .Ex.text3
            usdtLabel.textColor = t2Color
//            let t3Color: UIColor = hasSigned ? .Ex.text1 : .Ex.text3
            dayLabel.textColor = t1Color
            if hasSigned {
                bgImage.image = UIImage.svgImage(named: "task_checked")
            }else{
                bgImage.image = UIImage.themeImageNamed(imageName: "task_uncheck")
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configSubView()
    }
    
    func configSubView(){
        self.contentView.addSubview(bgImage)
        bgImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bgImage.addSubViews([amountLabel,usdtLabel,dayLabel])
        amountLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(4)
            make.height.equalTo(16)
            make.right.lessThanOrEqualToSuperview()
        }
        usdtLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(4)
            make.top.equalTo(amountLabel.snp.bottom)
            make.height.equalTo(14)
            make.right.lessThanOrEqualToSuperview()
        }
        dayLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-2)
            make.height.equalTo(14)
            make.right.lessThanOrEqualToSuperview()
        }
     
        
    }
   
    lazy var bgImage : UIImageView = {
        let bgImage = UIImageView()
        bgImage.contentMode = .scaleAspectFit
        bgImage.image = UIImage(named: "")
        return bgImage
    }()
    
    lazy var amountLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.medium(14), textColor: .Ex.text3, alignment: NSTextAlignment.left)
        return label
    }()
    lazy var usdtLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.regular(12), textColor: .Ex.text3, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var dayLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.medium(12), textColor: .Ex.text3, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
}
