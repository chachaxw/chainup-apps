//
//  EXEmptyNetworkCell.swift
//  Chainup
//
//  Created by 1 on 2021/4/9.
//  Copyright © 2021 Chainup. All rights reserved.
//

import Foundation

public class EXEmptyNetworkCell: UIView{
    lazy var bgbutton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(checkNetAction), for: .touchUpInside)
        return button
    }()
    lazy var image1: UIImageView = {
        let image = UIImageView.init(image:UIImage.themeImageNamedFromPod(imageName: "remind"))
        return image
    }()
    
    lazy var titleLable: UILabel = {
        let title = UILabel()
        title.textColor = UIColor.white
        title.font = UIFont.ThemeFont.BodyRegular
        title.text = EXUIDatasource.shared.networkError
        return title
    }()
    
    lazy var image2: UIImageView = {
        let image = UIImageView.init(image:UIImage.themeImageNamedFromPod(imageName: "enterwhite"))
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        creatUI()
    }
    func creatUI(){
        self.backgroundColor = UIColor.extColorWithHex("D1425E")
        self.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width , height: 44)
        self.addSubview(self.image1)
        self.image1.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(CGSize.init(width: 14, height: 14))
        }
        self.addSubview(self.titleLable)
        self.titleLable.snp.makeConstraints { (make) in
            make.left.equalTo(self.image1.snp.right).offset(5)
            make.centerY.equalTo(self.snp.centerY)
        }
        self.addSubview(self.image2)
        self.image2.snp.makeConstraints { (make) in
            make.left.equalTo(UIScreen.main.bounds.size.width - 28)
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(CGSize.init(width: 6, height:10))
        }
        self.addSubview(self.bgbutton)
        self.bgbutton.snp.makeConstraints{ (make) in
            make.edges.equalTo(self)
        }
        
    }
    @objc func checkNetAction(){
        guard let settingUrl = URL.init(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingUrl){
            UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
        }
    }
}
