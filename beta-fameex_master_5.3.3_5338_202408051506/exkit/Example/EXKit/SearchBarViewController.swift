//
//  SearchBarViewController.swift
//  EXKit_Example
//
//  Created by cwd on 2023/6/19.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EXKit
class SearchBarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .Ex.fill1
       searchBar()
    }
    
    
    func searchBar(){
        let searchView = EXSearchBarView()
        self.view.addSubview(searchView)
        searchView.placeHolder = "请输入"
//        searchView.canSearch = false
        searchView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(200)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(32)
        }
        searchView.textDidChange = { [weak self] str in
            print(str)
        }
        searchView.jumpCallBack = {  [weak self] _ in
            print("跳转")
        }
        
        
    
        
        
        
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
