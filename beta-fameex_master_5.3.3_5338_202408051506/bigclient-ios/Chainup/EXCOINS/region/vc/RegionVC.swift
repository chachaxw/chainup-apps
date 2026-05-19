//
//  RegionVC.swift
//  Chainup
//
//  Created by zewu wang on 2018/8/17.
//  Copyright © 2018年 zewu wang. All rights reserved.
//

import UIKit

class RegionVC: NavCustomVC {
    
    var vm = RegionVM()
    
    typealias ClickRegionCellBlock = (RegionEntity)->()
    var clickRegionCellBlock : ClickRegionCellBlock?
    
    var regionTableViewRowDatas : [String : [RegionEntity]] = [:]
    
    var regionNameSetions : [String] = []
    
    var allRowDatas : [String : [RegionEntity]] = [:]
    
    var choose:Bool = false
    //
    lazy var tableView : UITableView = {
        let tableV = UITableView()
        tableV.extUseAutoLayout()
        tableV.extSetTableView(self , self )
        tableV.register(RegionHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: "RegionHeaderView")
        tableV.extRegistCell([RegionTC.classForCoder()], ["RegionTC"])
        tableV.sectionIndexBackgroundColor = UIColor.ThemeView.bg
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
SearchBar. placeholder=LanguageTools. getString (key: "Search for country or region code")
        searchBar.barTintColor = UIColor.ThemeView.bg
        searchBar.layer.borderColor = UIColor.ThemeView.bg.cgColor
        searchBar.subviews.first?.subviews.last?.backgroundColor = UIColor.ThemeView.bg
        searchBar.tintColor = UIColor.ThemeLabel.colorMedium
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField{
            textfield.textColor = UIColor.ThemeLabel.colorMedium
            textfield.font = UIFont.ThemeFont.BodyRegular
            //            textfield.backgroudView.extSetCornerRadius(2)
        }
        searchBar.layer.borderWidth = 1
        searchBar.delegate = self
        searchBar.setImage(UIImage.themeImageNamed(imageName: "search"), for: UISearchBarIcon.search, state: UIControlState.normal)
        return searchBar
    }()
    
    //Cancel button
    lazy var cancelBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
Btn. extSetTitle (LanguageTools. getString (key: "Cancel"), titleColor: UIColor. ThemeLabel. colorMedium)
        btn.extSetAddTarget(self, #selector(clickCancelBtn))
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        return btn
    }()
    
    //Empty Page
    lazy var emptyView : EmptyPageView = {
        let view = EmptyPageView()
        view.extUseAutoLayout()
        view.addBtn.setImage(UIImage.init(named: "nodata"), for: UIControlState.normal)
        view.label.text = LanguageTools.getString(key: "temp_no_data")
        return view
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    override func setNavCustomV() {
        self.navCustomView.isHidden = true
        self.setTitle(LanguageTools.getString(key: "select_area"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        contentView.addSubview(tableView)
        view.addSubview(topSearchView)
        topSearchView.addSubViews([searchBar1, cancelBtn,lineV])
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
        }
        topSearchView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(NAV_TOP + 20)
            make.height.equalTo(44)
        }
        lineV.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        searchBar1.snp.makeConstraints { (make) in
            make.left.equalTo(self.topSearchView)
            make.right.equalTo(self.topSearchView).offset(-45)
            make.top.equalTo(self.topSearchView).offset(10)
            make.height.equalTo(30)
        }
        
        cancelBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.topSearchView).offset(-10)
            make.height.equalTo(16)
            make.width.equalTo(35)
            make.centerY.equalTo(self.searchBar1)
        }
        vm.setVC(self)
        getRegionInfo()
    }
    
    func getRegionInfo(){
        vm.getRegionInfo().subscribe(onNext: {[weak self] (array) in
            guard let mySelf = self else{return}
            if BasicParameter.isHan(){
                mySelf.reloadSearchView(RegionVM().zh_nameTransForm(array))
//                mySelf.regionTableViewRowDatas = RegionVM().zh_nameTransForm(array)
//                mySelf.regionNameSetions = mySelf.regionTableViewRowDatas.keys.sorted()
//                mySelf.tableView.reloadData()
            }else{
                mySelf.reloadSearchView(RegionVM().us_nameTransForm(array))
//                mySelf.regionTableViewRowDatas = RegionVM().us_nameTransForm(array)
//                mySelf.regionNameSetions = mySelf.regionTableViewRowDatas.keys.sorted()
//                mySelf.tableView.reloadData()
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
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
        self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: index), at: UITableViewScrollPosition.top, animated: false)
        return index
    }
    
}

extension RegionVC : UISearchBarDelegate{
    //Click the cancel button
    @objc func clickCancelBtn(){
//        clickCancelBtnBlock?()
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            reloadSearchView(allRowDatas)
        }else{
            var array : [RegionEntity] = []
            if BasicParameter.isHan() == true{
                for key in allRowDatas.keys{
                    for item in allRowDatas[key] ?? []{
//                        let pinyin = vm.transform(item.cnName)
                        if item.cnName.contains(searchText){
                            array.append(item)
                        }
                    }
                }
                self.reloadSearchView(RegionVM().zh_nameTransForm(array))
            }else{
                for key in allRowDatas.keys{
                    for item in allRowDatas[key] ?? []{
                        if item.enName.contains(searchText){
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

