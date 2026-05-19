//
//  EXPosStepProgressView.swift
//  Chainup
//
//  Created by lcus on 2023/10/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

enum ItemAligenModel {
    case left
    case right
    case center
}


private class PorgressTitleItem:UIView {
    
    var colorView :UIView = {
        let v = UIView()
        v.backgroundColor = .gray
        v.extSetCornerRadius(5)
        return v;
    }()
    
    var colorMaskView :UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill2
        v.extSetCornerRadius(8)
        return v
    }()
    
    var headTitle :UILabel = {
        let v = UILabel(font: .Ex.regular(10), textColor: .Ex.text2)
        return v
    }()
    
    var traiTitle :UILabel = {
        let v = UILabel(font: .Ex.regular(10), textColor: .Ex.text2, numberOfLines: 0)
        v.textAlignment = .right
        return v
    }()
    
    
    init(frame: CGRect,aligen:ItemAligenModel) {
        
        super.init(frame: frame)
        
        addSubViews([colorMaskView,headTitle,traiTitle]);
        
        colorMaskView.addSubview(colorView)
        
        colorMaskView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self);
            make.right.equalTo(self)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        colorView.snp.makeConstraints { (make) in
            make.center.equalTo(colorMaskView);
            make.width.equalTo(10)
            make.height.equalTo(10)
        }
        switch aligen {
        case .left:
            headTitle.snp.makeConstraints { (make) in
                
                make.left.equalTo(self)
                make.bottom.equalTo(colorView.snp.top).offset(-5)
            }
            traiTitle.snp.makeConstraints { (make) in
                make.left.equalTo(self)
                make.top.equalTo(colorView.snp.bottom).offset(5)
                make.width.equalTo(60)
            }
            traiTitle.textAlignment = .left
        case.right:
            headTitle.snp.makeConstraints { (make) in
                
                make.right.equalTo(self)
                make.bottom.equalTo(colorView.snp.top).offset(-5)
            }
            traiTitle.snp.makeConstraints { (make) in
                make.right.equalTo(self)
                make.top.equalTo(colorView.snp.bottom).offset(5)
                make.width.equalTo(60)
            }
            traiTitle.textAlignment = .right
            
        case .center:
            
            headTitle.snp.makeConstraints { (make) in
                
                make.centerX.equalTo(self)
                make.bottom.equalTo(colorView.snp.top).offset(-5)
            }
            traiTitle.snp.makeConstraints { (make) in
                make.centerX.equalTo(self)
                make.top.equalTo(colorView.snp.bottom).offset(5)
                make.width.equalTo(60)
            }
            traiTitle.textAlignment = .center
            
        }
        
    }
    convenience init(aligen:ItemAligenModel) {
        self.init(frame: CGRect.zero, aligen: aligen)
    }
   
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class EXPosStepProgressView: UIView {

    var titles:[String] = []
    
    var titleViewContainer:[UIView] = []
    
    var normalColor:UIColor = UIColor.ThemeView.bgIconh
    
    var highlightColor:UIColor = UIColor.ThemeView.highlight
    
    lazy var progress: UIProgressView = {
        let v  = UIProgressView()
        v.progressTintColor = .Ex.main1
        v.trackTintColor = UIColor.ThemePageControl.unselect
        v.progress = 0;
        return v
        
    }()
    
     init(frame: CGRect,titles:[String],normalColor:UIColor,highlightColor:UIColor) {
        super.init(frame: frame)
        self.titles = titles
        self.normalColor = normalColor
        self.highlightColor = highlightColor
        self .addSubview(progress)
    
        for i in 0..<titles.count {
    
            let title = titles[i]
            var view = PorgressTitleItem(aligen: .center)
            if i == 0 {

                view = PorgressTitleItem(aligen: .left)
            }
            
            if i == titles.count - 1 {
                view = PorgressTitleItem( aligen: .right)
            }
            view.headTitle.text = title;
            view.colorView.backgroundColor = self.normalColor
            titleViewContainer.append(view);
            self.addSubview(view)
            
        }
        
        progress.snp.makeConstraints { (make) in
            
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
        }
        

        titleViewContainer.snp.distributeViewsAlong(axisType: .horizontal, fixedItemLength: 16, leadSpacing: 8, tailSpacing:8);
        titleViewContainer.snp.makeConstraints{
            $0.centerY.equalTo(self)
            $0.height.equalTo(16)
        }
        
        
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTimes(enity:EXPosDetailProtocolEnity)  {
        
        let limitprogess:Float = 0.33
        let times = [enity.stimeShow,enity.etimeShow,enity.ltimeShow,enity.iasDateShow];
        var stautus = enity.activeStatus
        //Full amount belongs to centralized fundraising status
        if stautus == 6 {
            stautus = 1
        }
        
        for index in 0..<titleViewContainer.count {
            let View = titleViewContainer[index] as! PorgressTitleItem
            View.traiTitle.text = times[index]
            
            if(index < stautus) {
                View.colorView.backgroundColor = UIColor.ThemeView.highlight
            }
            
        }
        progress.progress = mapProgess(state: stautus) * limitprogess
        
    }
    
    func mapProgess(state:Int) ->Float{
        
        switch state {
        case 0:
            return 0
        case 1 :
            return 0.5
        case 2 :
            return 1.5
        case 3 :
            return 2.5
        case 6:
            return 1.0
            
        default:
            return 3.2
        }
        
        
    }
    
    
}

