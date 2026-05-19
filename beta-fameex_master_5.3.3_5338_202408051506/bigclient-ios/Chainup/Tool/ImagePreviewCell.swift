//
//  ImagePreviewCell.swift
//  ImagePreview
//
//  Created by zewu wang on 2023/10/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import YYWebImage

class ImagePreviewCell: UICollectionViewCell {
    
    typealias ClickCellBlock = () -> ()
    var clickCellBlock : ClickCellBlock?
    
    //Scroll View
    var scrollView:UIScrollView!
    
    //ImageView for displaying images
    var imageView:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //ScrollView initialization
        scrollView = UIScrollView(frame: self.contentView.bounds)
        self.contentView.addSubview(scrollView)
        scrollView.delegate = self
        //ScrollView Zoom Range 1-3
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        
        //ImageView initialization
        imageView = UIImageView()
        imageView.frame = scrollView.bounds
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        
        //Click to listen
        let tapSingle=UITapGestureRecognizer(target:self,
                                             action:#selector(tapSingleDid))
        tapSingle.numberOfTapsRequired = 1
        tapSingle.numberOfTouchesRequired = 1
        //Double click listening
        let tapDouble=UITapGestureRecognizer(target:self,
                                             action:#selector(tapDoubleDid(_:)))
        tapDouble.numberOfTapsRequired = 2
        tapDouble.numberOfTouchesRequired = 1
        //Declare that a click event requires a double click event detection failure before it can be executed
        tapSingle.require(toFail: tapDouble)
        self.imageView.addGestureRecognizer(tapSingle)
        self.imageView.addGestureRecognizer(tapDouble)
    }
    
    //Reset the size of elements within cells
    func resetSize(){
        //ScrollView reset without scaling
        scrollView.frame = self.contentView.bounds
        scrollView.zoomScale = 1.0
        //ImageView reset
        if let image = self.imageView.image {
            //Set the size of the imageView to ensure that it can be displayed on one screen
            imageView.frame.size = scaleSize(size: image.size)
            //ImageView centered
            imageView.center = scrollView.center
        }
    }
    
    //When the view layout changes (the cell size also changes when switching between horizontal and vertical screens)
    override func layoutSubviews() {
        super.layoutSubviews()
        //Reset the size of elements within cells
        resetSize()
    }
    
    //Obtain the zoom size of the imageView (ensuring that the entire image can be fully displayed for the first time)
    func scaleSize(size:CGSize) -> CGSize {
        let width = size.width
        let height = size.height
        let widthRatio = width/UIScreen.main.bounds.width
        let heightRatio = height/UIScreen.main.bounds.height
        let ratio = max(heightRatio, widthRatio)
        return CGSize(width: width/ratio, height: height/ratio)
    }
    
    //Image click event response
    @objc func tapSingleDid(_ ges:UITapGestureRecognizer){
        clickCellBlock?()
//        //Show or hide the navigation bar
//        if let nav = self.responderViewController()?.navigationController{
////            nav.setNavigationBarHidden(!nav.isNavigationBarHidden, animated: true)
////            nav.popViewController(animated: true)
//        }
    }
    
    //Image Double Click Event Response
    @objc func tapDoubleDid(_ ges:UITapGestureRecognizer){
        //Hide Navigation Bar
        if let nav = self.responderViewController()?.navigationController{
            nav.setNavigationBarHidden(true, animated: true)
        }
        //Zoom View (with Animated Effects)
        UIView.animate(withDuration: 0.5, animations: {
            //If not currently scaled, zoom in to 3x. Otherwise, restore it
            if self.scrollView.zoomScale == 1.0 {
                self.scrollView.zoomScale = 3.0
            }else{
                self.scrollView.zoomScale = 1.0
            }
        })
    }
    
    //Find the ViewController where it is located
    func responderViewController() -> UIViewController? {
        for view in sequence(first: self.superview, next: { $0?.superview }) {
            if let responder = view?.next {
                if responder.isKind(of: UIViewController.self){
                    return responder as? UIViewController
                }
            }
        }
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
}

//Implementation of the UIScrollViewDelegate proxy for ImagePreviewCell
extension ImagePreviewCell:UIScrollViewDelegate{
    
    //Zoom View
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    //Scaling response, setting the center position of the imageView
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var centerX = scrollView.center.x
        var centerY = scrollView.center.y
        centerX = scrollView.contentSize.width > scrollView.frame.size.width ?
            scrollView.contentSize.width/2:centerX
        centerY = scrollView.contentSize.height > scrollView.frame.size.height ?
            scrollView.contentSize.height/2:centerY
        print(centerX,centerY)
        imageView.center = CGPoint(x: centerX, y: centerY)
    }
}

