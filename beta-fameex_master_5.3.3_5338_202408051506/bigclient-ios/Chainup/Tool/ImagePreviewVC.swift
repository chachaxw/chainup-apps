//
//  ImagePreviewVC.swift
//  ImagePreview
//
//  Created by zewu wang on 2023/10/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import YYWebImage
import EXKit
enum ImagePreviewVCType {
    case urlString
    case image
}

//Image browsing controller
class ImagePreviewVC: NavCustomVC {
    
    var copyType = "1"//Is there a save button
    
    var type = ImagePreviewVCType.urlString
    
    //Save button
    lazy var copyBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.extSetTitle("", 16, UIColor.ThemeView.highlight, UIControl.State.normal)
        btn.extSetCornerRadius(2)
        btn.backgroundColor = UIColor.ThemeView.bg
        btn.extSetBorderWidth(1, color: UIColor.ThemeView.highlight)
        btn.extSetAddTarget(self, #selector(clickSaveQrCodeImgBtn))
        return btn
    }()
    
    //Store image array
    var images:[String] = []
    
    var imageimage:[UIImage] = []
    
    //Default displayed image index
    var index:Int = 0
    
    //Used to place various image units
    var collectionView:UICollectionView!
    
    //Layout of collectionView
    var collectionViewLayout: UICollectionViewFlowLayout!
    
    //Page controller (small dots)
    var pageControl : UIPageControl!
    
//    //initialization
//    init(images:[String], index:Int = 0,){
//        self.images = images
//        self.index = index
//
//        super.init(nibName: nil, bundle: nil)
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    //initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the background to black
        self.view.backgroundColor = UIColor.black
        
        //CollectionView size style settings
        collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        //Horizontal scrolling
        collectionViewLayout.scrollDirection = .horizontal
        
        //CollectionView initialization
        collectionView = UICollectionView(frame: self.view.bounds,
                                          collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = UIColor.black
        collectionView.register(ImagePreviewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        //Do not automatically adjust the inner margin to ensure full screen display
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.view.addSubview(collectionView)
        
        if copyType == "1"{
            self.view.addSubview(copyBtn)
            
            copyBtn.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-30)
                make.height.equalTo(30)
                make.width.equalTo(100)
            }
            
        }
        
        //Scroll the view onto the default image
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        
        //Set Page Controller
        pageControl = UIPageControl()
        pageControl.isHidden = true
        pageControl.center = CGPoint(x: UIScreen.main.bounds.width/2,
                                     y: UIScreen.main.bounds.height - 20)
        if type == .urlString{
            pageControl.numberOfPages = images.count
        }else{
            pageControl.numberOfPages = imageimage.count
        }
        pageControl.isUserInteractionEnabled = false
        pageControl.currentPage = index
        view.addSubview(self.pageControl)
    }
    
    //When the view is displayed
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Hide Navigation Bar
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navCustomView.isHidden = true
    }
    
    //When the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Show Navigation Bar
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navCustomView.isHidden = false
    }
    
    //hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //Called when the sub view layout is about to be adjusted (when switching between horizontal and vertical screens)
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //Resize the collectionView
        collectionView.frame.size = self.view.bounds.size
        collectionView.collectionViewLayout.invalidateLayout()
        
        //Scroll the view onto the current picture
        let indexPath = IndexPath(item: self.pageControl.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        
        //Reset the position of the page controller
        pageControl.center = CGPoint(x: UIScreen.main.bounds.width/2,
                                     y: UIScreen.main.bounds.height - 20)
    }
    
    //MARK: Click to save the QR code
    @objc func clickSaveQrCodeImgBtn(){
        if let cellV = collectionView.visibleCells[0] as? ImagePreviewCell{
            if let img = cellV.imageView.image{
                UIImageWriteToSavedPhotosAlbum(img, self, #selector(saveImg), nil)
                return
            }
        }
        
        EXAlert.showFail(msg: LanguageTools.getString(key: "save_fail"))
    }
    
    @objc func saveImg(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        if error != nil{
            EXAlert.showFail(msg: LanguageTools.getString(key: "save_fail"))
            return
        }
        EXAlert.showSuccess(msg: LanguageTools.getString(key: "save_succcess"))
        //        alert.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//Implementation of CollectionView Related Protocol Method for ImagePreviewVC
extension ImagePreviewVC:UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout{
    
    //CollectionView cell creation
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                          for: indexPath) as! ImagePreviewCell
//            let image = UIImage(named: self.images[indexPath.row])
            if type == ImagePreviewVCType.urlString{
                if let url = URL.init(string: self.images[indexPath.row]){
                    cell.imageView.yy_setImage(with: url, options: YYWebImageOptions.allowBackgroundTask)
                }
            }else{
                cell.imageView.image = self.imageimage[indexPath.row]
            }
            
            cell.clickCellBlock = {[weak self]() in
                guard let mySelf = self else{return}
                mySelf.view.bringSubviewToFront(mySelf.navCustomView)
                mySelf.navCustomView.isHidden = !mySelf.navCustomView.isHidden
            }
            return cell
    }
    
    //Number of collectionView cells
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if type == ImagePreviewVCType.urlString{
            return self.images.count
        }else{
            return self.imageimage.count
        }
    }
    
    //CollectionView Cell Size
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.view.bounds.size
    }
    
    //A certain cell in the collectionView is about to be displayed
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? ImagePreviewCell{
            //Due to the reuse of cells, the internal element size needs to be reset
            cell.resetSize()
        }
    }
    
    //A certain cell in the collectionView has been displayed
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        //Current displayed cells
        let visibleCell = collectionView.visibleCells[0]
        //Set Page Controller Current Page
        self.pageControl.currentPage = collectionView.indexPath(for: visibleCell)!.item
    }
}

