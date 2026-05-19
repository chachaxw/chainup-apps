//
//  EXBtoCBankListVC.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXBtoCBankListVC: NavCustomVC {
    
    typealias ClickCellBlock = (EXBtoCwithDrawBankModel) -> ()
    var clickCellBlock : ClickCellBlock?
    
    var selectNum = -1
    
    var tableViewRowDatas : [EXBtoCwithDrawBankModel] = []
    
    var selectModel : EXBtoCwithDrawBankModel = EXBtoCwithDrawBankModel()
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXBtoCBankListTC.classForCoder()], ["EXBtoCBankListTC"])
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        for index in 0..<tableViewRowDatas.count{
            let model = tableViewRowDatas[index]
            if model.bankNo == selectModel.bankNo{
                selectNum = index
            }
        }
        tableView.reloadData()
    }
    
    override func setNavCustomV() {
        self.setTitle("b2c_text_bank".localized())
        self.navtype = .list
        self.xscrollView = tableView
        self.lastVC = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EXBtoCBankListVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 49
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        var isSelect = false
        if indexPath.row == selectNum{
            isSelect = true
        }
        let cell : EXBtoCBankListTC = tableView.dequeueReusableCell(withIdentifier: "EXBtoCBankListTC") as! EXBtoCBankListTC
        cell.setCell(entity, isSelect: isSelect)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = tableViewRowDatas[indexPath.row]
        self.clickCellBlock?(entity)
        self.popBack()
    }
}

class EXBtoCBankListTC : UITableViewCell{
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        return label
    }()
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.svgImage(named: "personal_selected", version: .five)
        return imgV
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([nameLabel,imgV,lineV])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(imgV.snp.left).offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
        }
        imgV.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(14)
            make.height.equalTo(10)
            make.centerY.equalTo(nameLabel)
        }
        lineV.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(0.5)
        }
    }
    
    func setCell(_ entity : EXBtoCwithDrawBankModel , isSelect : Bool){
        nameLabel.text = entity.accountName
        imgV.isHidden = !isSelect
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
