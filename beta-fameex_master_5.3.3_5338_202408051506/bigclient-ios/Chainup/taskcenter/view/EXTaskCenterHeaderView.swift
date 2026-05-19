//
//  EXTaskCenterHeaderView.swift
//  Chainup
//
//  Created by cwd on 2023/7/24.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXTaskCenterHeaderView: UIView {
    
    var bannerUrl: String? {
        didSet{
            if let banner = bannerUrl,banner.hasPrefix("http"){
                bannerView.yy_setImage(with: URL(string: banner), placeholder: bannerImageByPlaceholder())
            }
        }
    }
    
    public static let bannerHeight: CGFloat = 190
    
    static func getTotalHeight(showSign: Bool = false, signInfo: EXSignInInfo? = nil) -> CGFloat {
        var height: CGFloat = EXTaskCenterHeaderView.bannerHeight
        if showSign{
            height += (20.0 + EXTaskSIgnMainView.getViewHeight())
        }
        height += showSign ? 20 : 12
        return height
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setSubView()
    }
    
    func setSubView() {
        self.addSubViews([bannerView,signMainview])
        bannerView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(EXTaskCenterHeaderView.bannerHeight)
        }
        signMainview.snp.makeConstraints { make in
            make.top.equalTo(bannerView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(EXTaskSIgnMainView.getViewHeight())
        }
    }
    lazy var bannerView : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.image = bannerImageByPlaceholder()
        img.clipsToBounds = true
        return img
    }()
    
    lazy var signMainview: EXTaskSIgnMainView = {
        let v = EXTaskSIgnMainView()
        v.isHidden = true
        return v
    }()
    
}


extension EXTaskCenterHeaderView {
    
    func bannerImageByPlaceholder() -> UIImage? {
        var name = "task_banner_en"
        if LanguageHandler.priviatePhoneLanguage.contains("zh"){
           name = "task_banner_zh"
        }
       return UIImage.themeImageNamed(imageName: name)
    }
}
