//
//  EXContractMenuSheet.swift
//  Chainup
//
//  Created by cwd on 2022/11/14.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXContractMenuSheet: UIView {
    let useLike = EXContractUserVm()
    static let numberOfColumn:Int = 4
    static let navBarHeight:Int = 44
    let cellid = "EXContractMenuItemView"
    let footid = "MenuFooterView"
    var sudokudatas:[EXSBouncedModel] = []
    let animationDuration: Double = 0.8
    let delayBase: Double = 0.1
    var showedIdxPath:[IndexPath] = []
    var itemModel: EXSwapItemModel? {
        didSet{
            if let itemModel = itemModel {
               userLiked = useLike.isCollect(item: itemModel)
            }
            sudokuCollection.reloadData()
        }
    }
    var userLiked = false
    typealias MenuCallback = (EXSBouncedModel) -> ()
    var menuItemCallback:MenuCallback?
    var addFavirateCallback: EXComBoolBlock?
    
     //MARK: lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.alertBg
        self.addSubViews([titleBg,sudokuCollection])
        titleBg.addSubview(titleLabel)
        titleBg.addSubview(closeBtn)
        titleBg.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(EX_NAV_STATUS_HEIGHT)
            make.trailing.equalToSuperview()
            make.height.equalTo(EXContractMenuSheet.navBarHeight)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(N_MARGIN_LEFT)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        closeBtn.snp.makeConstraints { make in
            make.trailing.equalTo(-N_MARGIN_LEFT)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.exs_roundCorners(corners: [.bottomLeft,.bottomRight], radius: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: lazy
    lazy var titleBg:UIView = {
        let l = UIView()
        l.backgroundColor = UIColor.ThemeView.alertBg
        return l
    }()
    
    lazy var titleLabel:UILabel = {
        let l = UILabel()
        l.textColor = UIColor.ThemeLabel.colorLite
        l.font = UIFont.ThemeFont.HeadMedium
        l.text = "cp_contract_setting_title".ex_localized()
        return l
    }()
    
    lazy var closeBtn:UIButton = {
        let l = UIButton.init(type: .custom)
        l.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_close"), for: .normal)
        l.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        return l
    }()
    lazy var sudokuCollection : UICollectionView = {
        let layout = EXKitLayouts.contractMenuVerticalLayouts()
        let collectionV = UICollectionView.init(frame: CGRect.zero , collectionViewLayout: layout)
        collectionV.showsHorizontalScrollIndicator = false
        collectionV.showsVerticalScrollIndicator = false
        collectionV.backgroundColor = UIColor.ThemeView.alertBg
        collectionV.register(EXContractMenuItemView.classForCoder(), forCellWithReuseIdentifier: cellid)
        collectionV.register(MenuFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footid)
        collectionV.delegate = self
        collectionV.dataSource = self
        collectionV.isPagingEnabled = false
        collectionV.bounces = true
        collectionV.clipsToBounds = false
        if #available(iOS 11.0, *) {
            collectionV.contentInsetAdjustmentBehavior = .never
        }
        return collectionV
    }()
}
extension EXContractMenuSheet{
    //view 总高度 English: View total height
    class func getViewHeight(count: Int) -> CGFloat{
        if count == 0 {
            return 100
        }
        let collectionH = self.getCollectionViewHeight(count: count)
        let totalH = EX_NAV_STATUS_HEIGHT + CGFloat(EXContractMenuSheet.navBarHeight) + collectionH
//        //print("Total height -,  (totalH)")
        //Title and Top Spacing
        return totalH
    }
    //collection 高度 English: Collection height
    class func getCollectionViewHeight(count: Int) -> CGFloat{
        var itemH:CGFloat = 0
        let layout = EXKitLayouts.contractMenuVerticalLayouts()
        let itemSectionH = layout.sectionInset.top + layout.sectionInset.bottom
        let numberOfLines:CGFloat = CGFloat(ceilf(Float(count)/Float(EXContractMenuSheet.numberOfColumn)))
        if count <= EXContractMenuSheet.numberOfColumn {
            itemH = layout.itemSize.height + itemSectionH
        }else {
            let allItemsH = layout.itemSize.height*numberOfLines + layout.minimumLineSpacing*(numberOfLines - 1) + itemSectionH
            itemH = min(allItemsH, CONTENT_H)
        }
        itemH += layout.footerReferenceSize.height //footer 底部 English: Footer bottom
        return itemH
    }
    
    //MARK: 更新数据 English: MARK: Updating data
    func bindSudokus(_ arr :[EXSBouncedModel]){
        sudokudatas = arr
        let itemH = EXContractMenuSheet.getCollectionViewHeight(count: arr.count)
        sudokuCollection.snp.remakeConstraints { make in
            make.top.equalTo(titleBg.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(itemH)
          //  make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
        }
        sudokuCollection.reloadData()
    }
    
    @objc func dismiss() {
        EXAlert.dismiss()
    }
    
    func collecion(add: Bool){ //添加自选 English: Add Custom
        guard self.itemModel != nil else {
            return
        }
        EXAlert.dismissEnd(complete: {
            self.addFavirateCallback?(add)
        }, delay: 0.1)
    }
    
}

extension EXContractMenuSheet : UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sudokudatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let entity = sudokudatas[indexPath.row]
        let cell : EXContractMenuItemView = collectionView.dequeueReusableCell(withReuseIdentifier: cellid, for: indexPath) as! EXContractMenuItemView
        cell.model = entity
        return cell
    }
    //MARK: 动画 English: MARK: animation
    func moveAnimation(collection:UICollectionView, cell:UICollectionViewCell,idxPath:IndexPath) {
        
        let column = Double(cell.frame.minX / cell.frame.width)
        let row = Double(cell.frame.minY / cell.frame.height)
        let distance = sqrt(pow(column, 2) + pow(row, 2))
        let delay = sqrt(distance) * delayBase

        let toframe = cell.frame
        cell.frame = CGRect(x: cell.frame.origin.x, y:cell.frame.origin.y - cell.bounds.size.height, width: cell.bounds.size.width, height: cell.bounds.size.height)
        cell.contentView.alpha = 0
        UIView.animate(withDuration: animationDuration, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: []) {
            cell.contentView.alpha = 1
            cell.frame = toframe
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if showedIdxPath.contains(indexPath) {
            return;
        }else {
            showedIdxPath.append(indexPath)
            self.moveAnimation(collection: collectionView,cell: cell, idxPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        EXAlert.dismissEnd(complete: {
            let entity = self.sudokudatas[indexPath.row]
            self.menuItemCallback?(entity)
        }, delay: 0.1)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footid, for: indexPath) as! MenuFooterView
            footer.likeBlock = { [weak self] add in
                self?.collecion(add: add)
                
            }
            footer.imageIV.isSelected = self.userLiked
            var title = self.userLiked ? "cp_contract_delete_optional_symbol".ex_localized() : "cp_contract_add_optional_symbol".ex_localized()
            title = title.removeQ()
            title += self.itemModel?.ex_contractInfo?.showName() ?? ""
            footer.titleLabel.text = title
            return footer
        }
        return UICollectionReusableView()
    }
}



class MenuFooterView: UICollectionReusableView{
    
    
    var likeBlock: EXComBoolBlock?
    
    //32 + 14
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubView()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.exs_roundCorners(corners: .allCorners, radius: 4)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubView() {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.ThemeView.alertBg
        bgView.backgroundColor = UIColor.ThemeView.card2
        self.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
            make.height.equalTo(32)
        }
        bgView.addSubViews([imageIV,titleLabel])
        imageIV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imageIV.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    let bgView = UIView()
    lazy var imageIV : UIButton = {
        let b = UIButton()
        b.setImage(UIImage.exs_themeImageNamed(imageName: "public_notfavorited"), for: .normal)
        b.setImage(UIImage.svg_themeImageNamed(imageName: "public_favorites"), for: .selected)
        return b
    }()
    /// ///名称 English: /Name
    lazy var titleLabel: UILabel = {
        //MARK: fix 币对 English: MARK: Fix Coin Pair
        let label = UILabel(text:"--", font: UIFont.ThemeFont.SecondaryBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    @objc func click(){
        self.imageIV.isSelected = !self.imageIV.isSelected
        self.likeBlock?(self.imageIV.isSelected)
    }
}

