//
//  RegionVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/17.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
typealias ClickRegionCellBlock = (RegionEntity)->()
class RegionVC: NavCustomVC {
    
    var vm = RegionVM()
    var clickRegionCellBlock : ClickRegionCellBlock?
    
    var regionTableViewRowDatas : [String : [RegionEntity]] = [:]
    
    var regionNameSetions : [String] = []
    
    var allRowDatas : [String : [RegionEntity]] = [:]
    
    var choose:Bool = false
    
    ///Filter blacklist identification true: Filter false: Do not filter
    private var limitFlag: Bool = true
    
    ///Title
    lazy var titleLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.text = "personal_Center_text22".localized()
        label.ext_UseAutoLayout()
        return label
    }()
    
    //
    lazy var tableView : UITableView = {
        let tableV = UITableView()
        tableV.extUseAutoLayout()
        tableV.extSetTableView(self , self )
        tableV.register(RegionHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: "RegionHeaderView")
        tableV.extRegistCell([RegionTC.classForCoder()], ["RegionTC"])
        tableV.sectionIndexBackgroundColor = UIColor.clear
        tableV.sectionIndexColor = UIColor.ThemeLabel.colorLite
        return tableV
    }()
    
    //Search Background
    lazy var topSearchView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.bg
        return view
    }()
    
    //Search bar
    lazy var searchBar1 : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.extUseAutoLayout()
        searchBar.barTintColor = UIColor.ThemeView.bg
        searchBar.layer.borderColor = UIColor.ThemeView.bg.cgColor
        searchBar.subviews.first?.subviews.last?.backgroundColor = UIColor.ThemeView.bgTab
        searchBar.subviews.first?.subviews.last?.corneradius = 16
        searchBar.tintColor = UIColor.ThemeLabel.colorMedium
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField{
            textfield.setPlaceHolderAtt(LanguageTools.getString(key: "common_text_searchCountry"), color: UIColor.ThemeLabel.colorDark, font: 14, weight: .medium)
            textfield.textColor = UIColor.ThemeLabel.colorMedium
            textfield.font = UIFont.ThemeFont.BodyRegular
            textfield.setModifyClearButton()
            textfield.backgroundColor = UIColor.clear
            //            textfield.backgroudView.extSetCornerRadius(2)
        }
        searchBar.layer.borderWidth = 1
        searchBar.delegate = self
        searchBar.setImage(UIImage.themeImageNamed(imageName: "public_search"), for: UISearchBar.Icon.search, state: .normal)
        return searchBar
    }()
    
    //Cancel button
    lazy var cancelBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.extSetTitle(LanguageTools.getString(key: "common_text_btnCancel"), titleColor: UIColor.ThemeLabel.colorMedium)
        btn.extSetAddTarget(self, #selector(clickCancelBtn))
        btn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        return btn
    }()
    
    //Empty Page
    lazy var emptyView : EmptyPageView = {
        let view = EmptyPageView()
        view.extUseAutoLayout()
        view.addBtn.setImage(UIImage.init(named: "nodata"), for: .normal)
        view.label.text = LanguageTools.getString(key: "temp_no_data")
        return view
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    
    convenience init(limitFlag: Bool = true) {
        self.init(nibName: nil, bundle: nil)
        self.limitFlag = limitFlag
    }
    
    override func setNavCustomV() {
        self.navCustomView.isHidden = true
        self.setTitle(LanguageTools.getString(key: "select_area"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.ThemeView.bg
        vm.setVC(self)
        getRegionInfo()
    }
    override func addConstraint(){
        super.addConstraint()
        contentView.addSubview(tableView)
        contentView.addSubview(topSearchView)
        topSearchView.addSubViews([titleLabel,cancelBtn,searchBar1])
        contentView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        topSearchView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
//            make.top.equalTo(NAV_TOP)
            make.height.equalTo(95)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(topSearchView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
        }
//        lineV.snp.makeConstraints { (make) in
//            make.left.right.bottom.equalToSuperview()
//            make.height.equalTo(0.5)
//        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
        }
        cancelBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(16)
            make.width.lessThanOrEqualTo(100)
            make.centerY.equalTo(titleLabel)
        }
        searchBar1.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.equalTo(32)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.roundCorners(corners: [.topLeft,.topRight], radius: 10)
    }
    
    func getRegionInfo(){
//        vm.getRegionInfo().subscribe(onNext: {[weak self] (array) in
//            guard let mySelf = self else{return}
    
    
            if LanguageTools.isHan(){
                self.reloadSearchView(RegionVM().zh_nameTransForm(CountryList.getAllRegions()))
//                mySelf.regionTableViewRowDatas = RegionVM().zh_nameTransForm(array)
//                mySelf.regionNameSetions = mySelf.regionTableViewRowDatas.keys.sorted()
//                mySelf.tableView.reloadData()
            }else{
                self.reloadSearchView(RegionVM().us_nameTransForm(CountryList.getAllRegions()))
//                mySelf.regionTableViewRowDatas = RegionVM().us_nameTransForm(array)
//                mySelf.regionNameSetions = mySelf.regionTableViewRowDatas.keys.sorted()
//                mySelf.tableView.reloadData()
            }
//        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension RegionVC : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.regionNameSetions.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let name = self.regionNameSetions[section]
        let view : RegionHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "RegionHeaderView") as! RegionHeaderView
        view.setCellLabel(name)
        if choose{
            if section == 0{
                view.isHidden = true

            }else{
                view.isHidden = false

            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if choose{
            if section == 0{
                return 0.01
            }
        }
        return 32
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.regionTableViewRowDatas[self.regionNameSetions[section]]?.count{
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let secion = self.regionTableViewRowDatas[self.regionNameSetions[indexPath.section]]{
            let entity = secion[indexPath.row]
            let cell : RegionTC = tableView.dequeueReusableCell(withIdentifier: "RegionTC") as! RegionTC
            cell.setCellWithEntity(entity)
            cell.clickRegionCellBlock = { [weak self] e in
                ///Pop comes out and EXAlert comes out, with two exit methods
                EXAlert.dismiss()
                self?.dismiss(animated: true, completion: nil)
                self?.clickRegionCellBlock?(e)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let secion = self.regionTableViewRowDatas[self.regionNameSetions[indexPath.section]]{
            let entity = secion[indexPath.row]
            clickRegionCellBlock?(entity)
            popBack()
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.regionNameSetions
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: index), at: .top, animated: false)
        return index
    }
    
}

extension RegionVC : UISearchBarDelegate{
    //Click the cancel button
    @objc func clickCancelBtn(){
//        clickCancelBtnBlock?()
        EXAlert.dismiss()
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            reloadSearchView(allRowDatas)
        }else{
            var array : [RegionEntity] = []
            if LanguageTools.isHan() == true{
                for key in allRowDatas.keys{
                    for item in allRowDatas[key] ?? []{
//                        let pinyin = vm.transform(item.cnName)
                        if item.cnName.contains(searchText) || item.dialingCode.contains(searchText){
                            array.append(item)
                        }
                    }
                }
                self.reloadSearchView(RegionVM().zh_nameTransForm(array))
            }else{
                for key in allRowDatas.keys{
                    for item in allRowDatas[key] ?? []{
                        if item.enName.uppercased().contains(searchText) || item.enName.lowercased().contains(searchText) ||  item.dialingCode.contains(searchText){
                            array.append(item)
                        }
                    }
                }
                self.reloadSearchView(RegionVM().us_nameTransForm(array))
            }
        }
    }
    
    func reloadSearchView(_ arr :  [String : [RegionEntity]]){
        self.regionTableViewRowDatas = arr
        self.regionNameSetions = self.regionTableViewRowDatas.keys.sorted()
        self.tableView.reloadData()
//        isShowEmptyView(tableViewRowDatas.count > 0 ? false : true)
        if allRowDatas.count == 0{
            allRowDatas = arr
        }
    }
}

