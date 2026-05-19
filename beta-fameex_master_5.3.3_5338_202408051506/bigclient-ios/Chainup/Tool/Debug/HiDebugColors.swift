//
//  HiDebugColors.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class HiDebugColors: UIViewController {
    
    var categorys:[String] = []
    var colorsArr:Array<Dictionary<String,String>>=Array()

    @IBOutlet var colorTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let title = String.init(format: "tradeLimit_text_everyDayBuy".localized(), "3")

        self.navigationItem.title = title
        self.themeByNight(isNight: false)
        self.colorTable.reloadData()
    }
    
    func themeByNight(isNight:Bool){
        let fileName = isNight ? "NightTheme" : "DayKlineNightTheme"
        let path = Bundle.main.path(forResource: fileName, ofType: "plist")
        if let plistPath = path {
            if let plistDict = NSDictionary(contentsOfFile: plistPath) {
                for category in plistDict.allKeys {
                    if let key = category as? String {
                        categorys.append(key)
                        let value  = plistDict[key]
                        if let result = value {
                            if let dic = result as? Dictionary<String,String> {
                                colorsArr.append(dic)
                            }
                        }
                    }
                }
            }
            
        }
    }
}

extension HiDebugColors:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionKey = categorys[section]
        let header = UILabel()
        header.text = sectionKey
        header.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 40)
        header.backgroundColor = UIColor.cyan
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

extension HiDebugColors:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionKey = categorys[indexPath.section]
        let dic = colorsArr[indexPath.section]
        let key =  Array(dic.keys)[indexPath.row]
        let value = dic[key]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HiDebugColorCell", for: indexPath) as! HiDebugColorCell
        cell.colorName.text = key
        cell.colorValue.text = value ?? ""
        cell.colorView.backgroundColor = UIColor.themeColor(keyPath:sectionKey+"."+key)
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return categorys
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categorys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dic = colorsArr[section]
        return dic.keys.count
    }
}
