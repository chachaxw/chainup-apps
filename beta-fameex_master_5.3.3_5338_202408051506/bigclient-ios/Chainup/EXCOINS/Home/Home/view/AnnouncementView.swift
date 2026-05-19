//
//  AnnouncementView.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//Announcement page

import UIKit
import EXKit
class AnnouncementView: UIView {
    
    var tableViewRowDatas : [NoticeInfoEntity] = []
    
    var timer : Timer?
    
    var index : Int = 0
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.themeImageNamed(imageName: "home_announcement")
        return imgV
    }()
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extRegistCell([HomeAnnouncementTC.classForCoder()], ["HomeAnnouncementTC"])
        tableView.extSetTableView(self, self)
        tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.bg
        addSubViews([tableView,lineV,imgV])
        imgV.snp.makeConstraints { (make) in
            make.centerY.equalTo(tableView)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(13)
            make.width.equalTo(13)
        }
        tableView.snp.makeConstraints { (make) in
            make.height.equalTo(17)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.left.equalTo(imgV.snp.right).offset(8)
        }
        lineV.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func initTimer(){
        if timer != nil{
            timer?.invalidate()
            timer = nil
        }
        timer = Timer.init(timeInterval: 3, repeats: true, block: {[weak self] (timer) in
            guard let mySelf = self else{return}
            if timer == mySelf.timer{
                if mySelf.tableViewRowDatas.count > 0 {
                    if mySelf.index == mySelf.tableViewRowDatas.count - 1{
                        mySelf.index = 0
                        mySelf.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableView.ScrollPosition.middle, animated: false)
                    }else if mySelf.index < mySelf.tableViewRowDatas.count - 1{
                        mySelf.index = mySelf.index + 1
                        mySelf.tableView.scrollToRow(at: IndexPath.init(row: mySelf.index, section: 0), at: UITableView.ScrollPosition.middle, animated: true)
                    }
                }
            }
        })
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    func startTimer(){
        timer?.fireDate = Date.init()
    }
    
    func pauseTimer(){
        timer?.fireDate = Date.distantFuture
    }
    
    func stopTimer(){
        if timer != nil{
            timer?.invalidate()
            timer = nil
        }
    }
    
    func setView(_ entity : HomeEntity){
        let arr = entity.noticeInfoList
        if arr.count > 0{
            tableViewRowDatas = arr
            if arr.count > 1{
                if let f = arr.first{
                    tableViewRowDatas.append(f)
                }
                initTimer()
            }
        }else{
            stopTimer()
        }
        tableView.reloadData()
        tableView.layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

extension AnnouncementView : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 17
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = tableViewRowDatas[indexPath.row]
        let cell : HomeAnnouncementTC = tableView.dequeueReusableCell(withIdentifier: "HomeAnnouncementTC") as! HomeAnnouncementTC
        cell.setCell(entity)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entity = tableViewRowDatas[indexPath.row]
        let announceEntity = EXAnnouncementEntity()
        announceEntity.title = entity.title
        announceEntity.id = entity.id
        //Click to enter the web
        let announcementDetailsVC = EXAnnouncementDetailsVC()
        announcementDetailsVC.entity = announceEntity
        self.yy_viewController?.navigationController?.pushViewController(announcementDetailsVC, animated: true)
    }
    
}

