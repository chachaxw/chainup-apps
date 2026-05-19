//
//  EXDateFilterCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/2.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit


class EXDateFilterCell: EXFilterBaseCell {

    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var leftField: EXIconSelectionField!
    @IBOutlet var rightField: EXIconSelectionField!
    @IBOutlet var middleLabel: UILabel!
    
    var startDate :Date?
    var endDate :Date?

    typealias DateCallback = (String,String) -> ()
    var lastBeginDate:String?
    var lastEndDate:String?
    var dateDidCallback : DateCallback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.ThemeView.bg
        contentView.backgroundColor = UIColor.ThemeView.bg
        leftField.iconBtn.setImage(UIImage.themeImageNamed(imageName: "transaction_triangle_down"), for: .normal)
        leftField.iconBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        rightField.iconBtn.setImage(UIImage.themeImageNamed(imageName: "transaction_triangle_down"), for: .normal)
        rightField.iconBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        middleLabel.text = "filter_text_to".localized()
        
        leftField.textfieldDidTapBlock = {[weak self] in
            guard let mySelf = self else {return}
            mySelf.dateselection(idx:0)
        }
        
        rightField.textfieldDidTapBlock = {[weak self] in
            guard let mySelf = self else {return}
            mySelf.dateselection(idx:1)
        }
    }
    
    func dateselection(idx:Int) {
        var minDate:Date?
        var maxDate:Date?
        if idx == 0 {
            if let date = self.endDate {
                maxDate = date
            }
        }else {
            if let date = self.startDate {
                minDate = date
            }
        }
        
        let alert = EXDatePicker()
        alert.setDatePickerMode(mode: .date)
        if let min = minDate {
            alert.datePickerView.minimumDate = min
        }
        if let max = maxDate {
            alert.datePickerView.maximumDate = max 
        }
        alert.dateConfirmCallback = {[weak self] date in
            guard let `self` = self else {return}
            self.handleDatePicker(date:date,atIdx:idx)
        }
        alert.dateCancelCallback = {[weak self] in
            guard let `self` = self else {return}
            self.backToNormal()
        }

        EXAlert.showDatePicker(dateView: alert)
    }
    
    func backToNormal() {
        leftField.normalStyle()
        rightField.normalStyle()
    }
    
    func handleDatePicker(date:Date,atIdx:Int) {
        self.backToNormal()
        if atIdx == 0 {
            self.startDate = date
            leftField.setText(text:DateTools.dateToString(date))
        }else {
            self.endDate = date
            rightField.setText(text: DateTools.dateToString(date))
        }
        if let startDate = leftField.input.text, let endDate = rightField.input.text {
           let startMills = DateTools.getMillTimeStamp(dateStr: startDate + " 00:00:00")
           let endMills = DateTools.getMillTimeStamp(dateStr: endDate + " 23:59:59")
           dateDidCallback?(startMills,endMills)
        }
    }
    
    func bindModel(model:EXFilterDataModel) {
        if model.items.count > 0,model.extraItems.count > 0 {
            let modelLeft = model.items[0]
            let modelRight = model.extraItems[0]

            leftField.setPlaceHolder(placeHolder: modelLeft.inputPlaceHolder)
            rightField.setPlaceHolder(placeHolder: modelRight.inputPlaceHolder)
            if let begin = self.lastBeginDate, let end = self.lastEndDate {
                leftField.setText(text: begin)
                rightField.setText(text: end)
            }else {
                leftField.setText(text: "")
                rightField.setText(text: "")
            }
        }
        cellTitle.text = model.title
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func getHeight() -> CGFloat{
        //54 + gap 15 + gap 15
        return 84
    }
    
}
