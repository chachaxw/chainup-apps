//
//  PageWheelView.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//Rotation chart

import UIKit

class EXHomePageNumControl : UIView{
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.image = UIImage.themeImageNamed(imageName: "banner_control")
        return imgV
    }()
    
    lazy var numLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.text = "1"
        label.textAlignment = .center
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemePageControl.bannerUnselect
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([imgV,numLabel])
        imgV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        numLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(14)
        }
    }
    
    func setView(_ num : String){
        numLabel.text = num
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class EXPageControl : UIView{
    
    var currentPage = 0
    {
        didSet{
            setView()
        }
    }
    
    var numberOfPages = 0
    {
        didSet{
            addView()
        }
    }
    
    
    var unselectColor = UIColor.clear
    
    var selectColor = UIColor.clear
    
    var pageArr : [UIView] = []
    
    lazy var backView : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.clear
        view.extSetCornerRadius(1)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selectColor = UIColor.ThemeLabel.colorLite
        self.unselectColor = UIColor.ThemeLabel.colorDark
        addSubview(backView)
    }
    
    func addView(){
        var arr : [UIView] = []
        backView.clearSubViews()//Remove all sub views
        for i in 0..<numberOfPages{
            let view = UIView()
            view.extUseAutoLayout()
            backView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(i * 12)
                make.height.equalTo(2)
                make.width.equalTo(12)
                make.top.equalToSuperview()
            }
            arr.append(view)
        }
        pageArr = arr
        backView.snp.remakeConstraints { (make) in
            make.centerX.top.bottom.equalToSuperview()
            make.width.equalTo(numberOfPages * 12)
        }
        setView()
    }
    
    func setView(){
        for i in 0..<pageArr.count{
            if currentPage == i {
                pageArr[i].backgroundColor = selectColor
            }else{
                pageArr[i].backgroundColor = unselectColor
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EXBannerPageControl : UIView{
    
    var currentPage = 0
    {
        didSet{
            setView()
        }
    }
    
    var numberOfPages = 0
    {
        didSet{
            addView()
        }
    }
    
    var unselectColor = UIColor.clear
    
    var selectColor = UIColor.clear
    
    var pageArr : [UIView] = []
    
    let padding:CGFloat = 6

    
    lazy var backView : UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = padding
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selectColor = UIColor.ThemePageControl.bannerSelect
        self.unselectColor = UIColor.ThemePageControl.bannerUnselect
        addSubview(backView)
    }
    
    func addView(){
        var arr : [UIView] = []
        backView.clearSubViews()//Remove all sub views
        for _ in 0..<numberOfPages{
            let view = UIView()
            view.corneradius = 1
            view.extUseAutoLayout()
            backView.addArrangedSubview(view)
            view.snp.makeConstraints { (make) in
                make.height.equalTo(2)
                make.width.equalTo(3)
            }
            arr.append(view)
        }
        pageArr = arr
        backView.snp.remakeConstraints { (make) in
            make.centerX.top.bottom.equalToSuperview()
        }
        setView()
    }
    
    func setView(){
        for i in 0..<pageArr.count{
            let item = pageArr[i]
            if currentPage == i {
                item.snp.updateConstraints { (make) in
                    make.width.equalTo(9)
                }
                pageArr[i].backgroundColor = selectColor
            }else{
                if i == currentPage + 1 || i == currentPage - 1 {
                    item.snp.updateConstraints { (make) in
                        make.width.equalTo(6)
                    }
                }else {
                    item.snp.updateConstraints { (make) in
                        make.width.equalTo(3)
                    }
                }
                pageArr[i].backgroundColor = unselectColor
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class EXScrollIndicator : UIView{
    
    var sliderWidth:CGFloat = 12
    
    lazy var backView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemeLabel.colorDark
        return view
    }()
    
    lazy var slider:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemeLabel.colorLite
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.extSetCornerRadius(1)
        
        addSubview(backView)
        addSubview(slider)
        
        backView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        slider.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(sliderWidth)
        }
    }
    
    func bindScroll(scroll:UIScrollView) {
        scroll.rx.contentOffset.subscribe(onNext: {[weak self] (point) in
            self?.handleSlider(x: point.x,scroll: scroll)
        }).disposed(by: disposeBag)
    }

    func handleSlider(x:CGFloat,scroll:UIScrollView) {
        //do something
        let changeX = x*(backView.frame.size.width - slider.size.width)/(scroll.contentSize.width - scroll.frame.size.width)
        slider.snp.remakeConstraints { (make) in
            make.left.equalTo(changeX)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(sliderWidth)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

