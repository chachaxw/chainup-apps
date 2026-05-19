//
//  EXBaseContainerListView.swift
//  Chainup
//
//  Created by cwd on 2022/11/6.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
import JXSegmentedView
class EXFilerListView: EXCOCustomBaseView,EXEmptyDataSetable {
    var vm = EXDrawViewModel(){
        didSet{
            subEvent()
        }
    }
    var orinDatas: [EXSwapItemModel] = []
    var rowDatas:[EXSwapItemModel] = [] {
        didSet{
            marketListTable.reloadData()
        }
    }
     //MARK: lifecycle
    override func setSubView() {
        self.addSubview(marketListTable)
        configTable()
       
        
    }

    //MARK: lazy
    private let cellId = "EXFilerListCell"
    lazy var marketListTable : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.rowHeight = 40
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(EXFilerListCell.self, forCellReuseIdentifier: cellId)
        tableView.backgroundColor = UIColor.ThemeView.alertBg
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
}
extension EXFilerListView{
    //订阅事件 English: Subscription events
    func subEvent(){
        self.vm.eventSubject.subscribe(onNext: { [weak self] type in
            switch type{
            case .searchKey(let keyWord):
                self?.updateData(key: keyWord)
            default:
                break
            }
        }).disposed(by: disposeBag)
    }
    //更新搜索 English: Update search
    func updateData(key: String){
        if key == "" {
            self.rowDatas = self.orinDatas
        }else{
            self.rowDatas = self.orinDatas.filter({ item  in
                if let showname = item.ex_contractInfo?.showName().uppercased(),
                   showname.contains(key.uppercased()){
                    return true
                }
                return false
            })
        }
    }
    func configTable() {
        marketListTable.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension EXFilerListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowDatas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = rowDatas[indexPath.row]
        let cell : EXFilerListCell = tableView.dequeueReusableCell(withIdentifier: cellId) as! EXFilerListCell
        cell.item = entity
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for (index,item) in rowDatas.enumerated() {
            item.selected = index == indexPath.row
        }
        tableView.reloadData()
        let item = self.rowDatas[indexPath.row]
        self.vm.eventSubject.onNext(.selectFinsh(item: item))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            EXAlert.dismiss()
        }
    }
}

extension EXFilerListView: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}

extension EXFilerListView {
    
    override func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 0
    }
}


class EXFilerListCell: UITableViewCell{
    
    
    var item: EXSwapItemModel? {
        didSet{
            if item == nil{
                return
            }
            titleLabel.text = item!.ex_contractInfo?.showName()
            checkImage.isHidden = !(item!.selected)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configSubView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configSubView()
    }
    
    func configSubView(){
        contentView.addSubViews([titleLabel,checkImage])
        self.backgroundColor = UIColor.ThemeView.alertBg
        selectionStyle = .none
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        checkImage.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }
    }
    
   ///名称 English: /Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
  
    lazy var checkImage : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image = UIImage.svg_themeImageNamed(imageName: "public_icon_check_mark")
        return arrowImmg
    }()
    
}

