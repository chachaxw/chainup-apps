//
//  EXTestWebViewController.swift
//  Chainup
//
//  Created by ljw on 2023/9/25.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXJsWebViewController: NavCustomVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webView = DWKWebView(frame: CGRect.zero)
        contentView.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        webView.addJavascriptObject(EXJsApiMethodSwift(), namespace: nil)
         if let data = try? JSONSerialization.data(withJSONObject: ["key":"111","key1":"222"], options: []),let string = String(data: data, encoding: String.Encoding.utf8)  {
            webView.callHandler("exchange", arguments: [string]) { (numb : Any?)->Void in
                   guard let number = numb else {
                       return
                   }
                   print(number)
               }
         }
        
        webView.loadUrl("http://192.168.60.152:8081/ex/appds")
        
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
