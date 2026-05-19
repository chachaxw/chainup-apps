//
//  ViewController.swift
//  EXKit
//
//  Created by liuxuan on 07/06/2022.
//  Copyright (c) 2022 liuxuan. All rights reserved.
//

import UIKit
import EXKit
import MapKit
import RxSwift

class ViewController: UITableViewController {
    
    let dataList = CompentType.allCases
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "EXKit"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = dataList[indexPath.row].rawValue
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let viewController = dataList[indexPath.row].exampleViewController else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension UIView : EXReusableView { }
