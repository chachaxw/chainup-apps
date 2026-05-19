//
//  EXSimplePickerVc.swift
//  Chainup
//
//  Created by wangdong on 2023/10/30.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXSimplePickerVc: BaseVC, NavigationPlugin, EXEmptyDataSetable {
    
    var didSelected: ((_ index: Int) -> ())? = nil
    var source: Array<AnyObject> = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var cellForTitle: ((_ index: Int) -> (String))? = nil

    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: tableView,presenter: self)
        nav.isLastNavigationStyle = true
        return nav
    }()
    
    var tableView: UITableView = {
        let view = UITableView.init(frame: CGRect.zero, style: .plain)
        view.separatorStyle = .none
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.ThemeView.bg
        tableView.backgroundView?.backgroundColor = UIColor.clear
        

        tableView.register(EXSimplePickerCell.self, forCellReuseIdentifier: "EXSimplePickerCell")
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.snp.makeConstraints { (maker) in
            maker.top.equalTo(navigation.snp.bottom)
            maker.left.right.bottom.equalToSuperview()
        }
        
        tableView.backgroundView?.backgroundColor = UIColor.clear
    }
    
    func setTitle(_ title: String) {
        navigation.setTitle(title: title)
    }
}

extension EXSimplePickerVc: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXSimplePickerCell") as! EXSimplePickerCell

        let title = cellForTitle?(indexPath.row)
        cell.titleLabel.text = title
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelected?(indexPath.row)
        self.navigationController?.popViewController(animated: true)
    }
}

class EXSimplePickerCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    lazy var lineView: UIView = {
        let view = UIView.init(frame: CGRect.zero)
        view.backgroundColor = .Ex.fill4
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.ThemeView.bg
        
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(lineView)
        
        titleLabel.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.left.equalToSuperview().offset(15)
        }
        
        lineView.snp.makeConstraints { (maker) in
            maker.left.equalTo(EX_Margin_Default)
            maker.right.equalTo(-EX_Margin_Default)
            maker.height.equalTo(0.5)
            maker.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
