//
//  EXFilterView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/2.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import IQKeyboardManagerSwift
import EXKit

@objc protocol EXFilterViewDelegate {
    @objc func filterDataSource() -> [EXFilterDataModel]
    @objc func filterConfirm(params:[String:String])
    @objc optional func cellModelForceSelect(_ idx:Int) -> Bool
    @objc optional func forceParamNotFill(_ emptyData:[String:String])
    @objc optional func didSelectAtIdxPath(idx:IndexPath)
    @objc optional func resetBtnAction()
}

class EXFilterView: NibBaseView {
    
    @IBOutlet var filterTableview: UITableView!
    @IBOutlet var leftBtn: EXFlatBtn!
    @IBOutlet var rightBtn: EXFlatBtn!
    weak var delegate:EXFilterViewDelegate?
    var datasouces:[EXFilterDataModel] = []
    var expandStatus = [String:Bool]()
    var filterParams = [String:String]()
    var defaultExpand = false
    private var confrimedParams:[String:String]?

    var isShow:Bool = false
    var position :CGPoint = CGPoint.zero
    
    @IBOutlet var filterHeight: NSLayoutConstraint!
    @IBOutlet var filterTopY: NSLayoutConstraint!
    @IBOutlet var filterContainer: UIView!
    @IBOutlet var bgBtn: UIButton!
    
    func keyboardHeight() -> Observable<CGFloat> {
        return Observable
            .from([
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
                    .map { notification -> CGFloat in
                        (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                },
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
                    .map { _ -> CGFloat in
                        0
                }
                ])
            .merge()
    }
    
    func registerCells() {
        self.filterTableview.register(UINib (nibName: "EXFoldFilterCell", bundle: nil), forCellReuseIdentifier: "EXFoldFilterCell")
        self.filterTableview.register(UINib (nibName: "EXInputFilterCell", bundle: nil), forCellReuseIdentifier: "EXInputFilterCell")
        self.filterTableview.register(UINib (nibName: "EXSwitchFilterCell", bundle: nil), forCellReuseIdentifier: "EXSwitchFilterCell")
        self.filterTableview.register(UINib (nibName: "EXDateFilterCell", bundle: nil), forCellReuseIdentifier: "EXDateFilterCell")
        self.filterTableview.register(UINib (nibName: "EXMixFilterCell", bundle: nil), forCellReuseIdentifier: "EXMixFilterCell")
        self.filterTableview.register(UINib (nibName: "EXSelectorFillterCell", bundle: nil), forCellReuseIdentifier: "EXSelectorFillterCell")
    }
    
    func updateFilterData(_ inRow:Int,_ withModel:EXFilterDataModel) {
        if datasouces.count > inRow {
            datasouces.remove(at: inRow)
            datasouces.insert(withModel, at: inRow)
            self.reloadData()
        }
    }


    override func onCreate() {
        self.registerCells()
        bgBtn.backgroundColor = UIColor.ThemeView.mask
        filterTableview.delegate = self
        filterTableview.dataSource = self
        leftBtn.color = UIColor.ThemeView.bgTab
        rightBtn.color = UIColor.ThemeView.highlight
        rightBtn.titleLabel?.font = UIFont.ThemeFont.Semibold
        leftBtn.titleLabel?.font = UIFont.ThemeFont.Semibold
        leftBtn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        rightBtn.setTitleColor(UIColor.ThemeLabel.white, for: .normal)
        leftBtn.setTitle("filter_action_reset".localized(), for: .normal)
        rightBtn.setTitle("common_text_btnConfirm".localized(), for: .normal)
        
        //Listen for keyboard pop-up notifications
        _ = NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .takeUntil(self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                if let keyBoardValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    self?.handleKeyboard(keyBoardValue.cgRectValue.height)
                }
            })
    }
    
    func handleKeyboard(_ height:CGFloat) {
        let position = self.position
        let itemsHeight = self.heightForFilter()
        let bottomHeight = height > 0 ? height : TABBAR_HEIGHT
        let filterMaxHeight = SCREEN_HEIGHT - position.y - bottomHeight
        let viewHeight = min(filterMaxHeight, itemsHeight + 59 + 15)
        filterHeight.constant = viewHeight
    }
    
    func configTableHeight() {
        
        let position = self.position
        let itemsHeight = self.heightForFilter()
        
        let bottomHeight = TABBAR_HEIGHT
        
        let filterMaxHeight = SCREEN_HEIGHT - position.y - bottomHeight
        let viewHeight = min(filterMaxHeight, itemsHeight + 59 + 15)
        filterHeight.constant = viewHeight
        
        self.frame = CGRect(x: position.x, y: position.y, width: SCREEN_WIDTH, height:SCREEN_HEIGHT - position.y)
        self.snp.remakeConstraints { (make) in
            make.top.equalTo(position.y)
            make.left.equalTo(position.x)
            make.width.equalTo(SCREEN_WIDTH)
            make.height.equalTo(SCREEN_HEIGHT - position.y)
        }
    }
    
    func show(inView:UIView,position:CGPoint = CGPoint(x: 0, y: NAV_SCREEN_HEIGHT)) {
        if self.isShow {
            return
        }
        self.filterTableview.delegate = self
        self.filterTableview.dataSource = self
//        inView.addSubview(self)
        UIApplication.shared.keyWindow?.addSubview(self)
        guard self.window != nil else { return }
        bgBtn.backgroundColor = UIColor.ThemeView.mask

        IQKeyboardManager.shared.enableAutoToolbar = false
        if let datasouces = delegate?.filterDataSource() {
            self.isShow = true
            self.datasouces = datasouces
            self.position = position
            self.updateExpandingStatus()
//            inView.addSubview(self)
            self.configTableHeight()
            
            self.filterContainer.y = -self.filterContainer.height
            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions(rawValue: 7<<16), animations: {
                self.filterContainer.y = 0
            }, completion: nil)
        }
    }
    
    func getStatusStyles()-> [AppFilterStyle] {
        var styles:[AppFilterStyle] = []
        for item in datasouces {
            styles.append(item.filterType)
        }
        
        return styles
    }
    
    func updateExpandingStatus() {
        let styles = self.getStatusStyles()
        for (idx,style) in styles.enumerated() {
            if style == .fold {
                expandStatus["\(idx)"] = false
            }else if style == .mix {
                expandStatus["\(idx)"] = false
            }
        }
    }
    
    func heightForFilter()->CGFloat {
        var height:CGFloat = 0
        let styles = self.getStatusStyles()
        for (idx,style) in styles.enumerated() {
            if style == .fold {
                let idxPath = IndexPath.init(row: idx, section: 0)
                let contents = self.datasouces[idx].items
                if self.defaultExpand {
                    height += EXFoldFilterCell.getHeight(models: contents,expand: true)
                }else{
                    if let expand = self.expandStatus["\(idxPath.row)"] {
                        height += EXFoldFilterCell.getHeight(models: contents,expand: expand)
                    }else {
                        height += EXFoldFilterCell.getHeight(models: contents,expand:false)
                    }
                }
                
            }else if style == .date {
                height += EXDateFilterCell.getHeight()
            }else if style == .input {
                height += EXInputFilterCell.getHeight()
            }else if style == .mix {
                let idxPath = IndexPath.init(row: idx, section: 0)
                let contents = self.datasouces[idx].extraItems
                if let expand = self.expandStatus["\(idxPath.row)"] {
                    height += EXMixFilterCell.getHeight(models: contents, expand: expand)
                }else {
                    height += EXFoldFilterCell.getHeight(models: contents,expand:false)
                }
            }else if style == .onoff {
                height += EXSwitchFilterCell.getHeight()
            }else if style == .selection {
                height += EXSelectorFillterCell.getHeight()
            }
        }
        return height
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismissFilter()
    }
    
    func dismissFilter() {
        self.isShow = false
        bgBtn.backgroundColor = UIColor.clear
        IQKeyboardManager.shared.enableAutoToolbar = true
        UIView.animate(withDuration: 0.3, animations: {
            self.filterContainer.y = -self.filterContainer.height
            self.filterTableview.delegate = nil
            self.filterTableview.dataSource = nil
        }, completion: { (finished) in
            self.removeFromSuperview()
            self.isShow = false
        })
    }
    
    @IBAction func confirmBtnAction(_ sender: UIButton) {
        
        var forceItem : EXFilterDataModel?
        for item in datasouces {
            if item.forceFilterItem == true {
                //TODO optimization, currently only supports the left side of MixModel
                let value = filterParams[item.leftKey]
                if let hasValue = value, !hasValue.isEmpty {
                    break
                }else {
                    forceItem = item
                }
                break
            }
        }

        if let forceErr = forceItem {
            if self.delegate?.forceParamNotFill?([forceErr.leftKey:"",forceErr.rightKey:""]) == nil {
                dismissFilter()
            }
        }else {
            self.confrimedParams = filterParams
            self.delegate?.filterConfirm(params: filterParams)
            self.dismissFilter()
        }
    }
    
    @IBAction func resetBtnAction(_ sender: UIButton) {
        setDefaultFilterParams()
        self.filterTableview.reloadData()
        self.delegate?.resetBtnAction?()
    }
    
    func setDefaultFilterParams() {
        filterParams.removeAll()
        for model in datasouces {
            if model.filterType == .fold {
                if model.items.count > 0 {
                    let item = model.items[0]
                    filterParams[model.leftKey] = item.valueKey
                }
            }
        }
    }
    
    func resetData() {
        setDefaultFilterParams()
        self.filterTableview.reloadData()
    }
    
    func reloadData() {
        self.filterTableview.reloadData()
    }
    
}

extension EXFilterView : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellStyle = self.getStatusStyles()[indexPath.row]
        if cellStyle == .fold {
            let models = self.datasouces[indexPath.row].items
            if self.defaultExpand{
                return EXFoldFilterCell.getHeight(models: models,expand:true)
            }else{
                if let expand = self.expandStatus["\(indexPath.row)"] {
                    return EXFoldFilterCell.getHeight(models: models,expand:expand)
                }else {
                    return EXFoldFilterCell.getHeight(models: models,expand:false)
                }
            }
        }else if cellStyle == .input {
            return EXInputFilterCell.getHeight()
        }else if cellStyle == .date {
            return EXDateFilterCell.getHeight()
        }else if cellStyle == .onoff {
            return EXSwitchFilterCell.getHeight()
        }else if cellStyle == .mix {
            let models = self.datasouces[indexPath.row].extraItems
            if let expand = self.expandStatus["\(indexPath.row)"] {
                return EXMixFilterCell.getHeight(models: models, expand: expand)
            }else {
                return EXMixFilterCell.getHeight(models: models, expand: false)
            }
        }else if cellStyle == .selection {
            return EXSelectorFillterCell.getHeight()
        }
        return CGFloat.leastNonzeroMagnitude
    }
}

extension EXFilterView : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datasouces.count
    }
    
    func handleFilterExpandAction(path:IndexPath,expand:Bool) {
        self.expandStatus["\(path.row)"] = expand
        self.configTableHeight()
        self.filterTableview.reloadRows(at: [path], with: .none)
    }
    
    func handleSelectedValue(path:IndexPath,value:String,key:String) {
        filterParams[key] = value
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellStyle = self.datasouces[indexPath.row].filterType
        let model = self.datasouces[indexPath.row]

        if let forceModel = delegate?.cellModelForceSelect?(indexPath.row) {
            if forceModel == true {
               model.forceFilterItem = true
            }
        }
        
        if cellStyle == .fold {
            let cell = tableView .dequeueReusableCell(withIdentifier: "EXFoldFilterCell", for: indexPath)  as! EXFoldFilterCell
            let models = model.items
            if let key = filterParams[model.leftKey] {
                cell.selectedItemValue = key
                for item in models {
                    if item.valueKey == key {
                        cell.selectValueLabel.text = item.text
                    }
                }
            }else {
                cell.selectedItemValue = ""
                if models.count > 0 {
                    let itemModel = models[0]
                    cell.selectValueLabel.text = itemModel.text
                    filterParams[model.leftKey] = itemModel.valueKey
                }
            }
            cell.cellTitle.text = model.title
            if let expand = self.expandStatus["\(indexPath.row)"] {
                cell.bindFoldCell(models: models, expand: expand)
            }else {
                cell.bindFoldCell(models: models, expand: false)
            }
            if defaultExpand{
                cell.bindFoldCell(models: models, expand: true)
                cell.selectValueLabel.isHidden = true
                cell.expandBtn.isHidden = true
            }
            cell.cellDidExpandBlock = {[weak self] expand in
                self?.handleFilterExpandAction(path: indexPath,expand:expand)
            }
            cell.itemDidChangeBlock = {[weak self] value in
                self?.handleSelectedValue(path: indexPath, value: value, key: model.leftKey)
            }
            return cell
        }else if cellStyle == .input {
            let cell = tableView .dequeueReusableCell(withIdentifier: "EXInputFilterCell", for: indexPath)  as! EXInputFilterCell
            if let value = self.filterParams[model.leftKey] {
                cell.lastValue = value
            }else {
                cell.lastValue = nil
                filterParams[model.leftKey] = ""
            }
            cell.bindModel(model)
            cell.leftCallback = {[weak self] value in
                self?.handleSelectedValue(path: indexPath, value: value, key: model.leftKey)
            }
            return cell
        }else if cellStyle == .date {
            let cell = tableView .dequeueReusableCell(withIdentifier: "EXDateFilterCell", for: indexPath)  as! EXDateFilterCell
            if let begin = self.filterParams[model.leftKey],
                let end = self.filterParams[model.rightKey]{
                if begin.isEmpty == false && end.isEmpty == false{
                    cell.lastBeginDate =  DateTools.strToTimeString(begin, dateFormat: "yyyy-MM-dd")//begin
                    cell.lastEndDate = DateTools.strToTimeString(end, dateFormat: "yyyy-MM-dd")//end
                }
            }else {
                filterParams[model.leftKey] = ""
                filterParams[model.rightKey] = ""
                cell.lastBeginDate = nil
                cell.lastEndDate = nil
            }
            cell.bindModel(model: model)
            cell.dateDidCallback = {[weak self] (startdate,enddate) in
                self?.handleSelectedValue(path: indexPath, value: startdate, key: model.leftKey)
                self?.handleSelectedValue(path: indexPath, value: enddate, key: model.rightKey)
            }
            return cell
        }else if cellStyle == .onoff {
            let cell = tableView .dequeueReusableCell(withIdentifier: "EXSwitchFilterCell", for: indexPath)  as! EXSwitchFilterCell
            if self.filterParams[model.leftKey] == nil {
                filterParams[model.leftKey] = "0"
            }
            
            cell.bindModel(model, lastValue: self.filterParams[model.leftKey])
            cell.itemDidSwitchBlock = {[weak self] isON in
                self?.handleSelectedValue(path: indexPath, value: isON ? "1" : "0", key: model.leftKey)
            }
            return cell
        }else if cellStyle == .mix {
            let cell = tableView .dequeueReusableCell(withIdentifier: "EXMixFilterCell", for: indexPath)  as! EXMixFilterCell
            if self.filterParams[model.leftKey] == nil {
                filterParams[model.leftKey] = ""
            }
            if self.filterParams[model.rightKey] == nil {
                filterParams[model.rightKey] = ""
            }
//            if model.extraItems.count > 0 {
//                let rightItem = model.extraItems[0]
//                if rightItem.valueKey == EXFoldItemType.forceAll.rawValue {
//
//                }
//            }
            
            cell.lastLeftValue = self.filterParams[model.leftKey]
            cell.lastRightValue = self.filterParams[model.rightKey]
            
            cell.cellDidExpandBlock = {[weak self] expand in
                self?.handleFilterExpandAction(path: indexPath,expand:expand)
            }
            cell.leftCallback = {[weak self] value in
                self?.handleSelectedValue(path: indexPath, value: value, key: model.leftKey)
            }
            cell.rightCallback = {[weak self] value in
                self?.handleSelectedValue(path: indexPath, value: value, key: model.rightKey)
            }
            
            
            if let expand = self.expandStatus["\(indexPath.row)"] {
                cell.bindMixCell(model: model,expand:expand)
            }else {
                cell.bindMixCell(model: model, expand: false)
            }
            
            return cell
        }else if cellStyle == .selection {
            let cell = tableView .dequeueReusableCell(withIdentifier: "EXSelectorFillterCell", for: indexPath)  as! EXSelectorFillterCell
            let firstModel = model.items[0]
            var place = firstModel.inputPlaceHolder
            if let value = self.filterParams[model.leftKey] {
                place = value
            }else {
                filterParams[model.leftKey] = ""
            }
            self.handleSelectedValue(path: indexPath, value: place, key: model.leftKey)
            cell.textfieldDidTapBlock = {[weak self] in
                guard let strongSelf = self else {return}
                strongSelf.delegate?.didSelectAtIdxPath?(idx: indexPath)
            }
            cell.bindSelector(title: model.title, value:place)
            return cell
        }
        
        let cell = UITableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "")
        return cell
    }
}

