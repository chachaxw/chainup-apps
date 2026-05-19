//
//  LBXScanView.swift
//  swiftScan
//
//  Created by xialibing on 15/12/8.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit

open class LBXScanView: UIView
{
    //Various parameters in the scanning area
    var viewStyle:LBXScanViewStyle = LBXScanViewStyle()
    
     //Scan Code Area
    var scanRetangleRect:CGRect = CGRect.zero
    
    //Line scanning animation packaging
    var scanLineAnimation:LBXScanLineAnimation?
    
    //Grid scanning animation encapsulation
    var scanNetAnimation:LBXScanNetAnimation?
    
    //The line is in the middle position and does not move
    var scanLineStill:UIImageView?
    
    //Chrysanthemum waiting when starting the camera
    var activityView:UIActivityIndicatorView?
    
    //Prompt text in activating the camera
    var labelReadying:UILabel?
    
    //Record animation status
    var isAnimationing:Bool = false
    
    /**
Initialize scanning interface
-Parameter frame: Interface size, usually in the video display area
-Parameter vstyle: interface effect parameter
    
    - returns: instancetype
    */
    public init(frame:CGRect, vstyle:LBXScanViewStyle )
    {
        viewStyle = vstyle
        
        switch (viewStyle.anmiationStyle)
        {
        case LBXScanViewAnimationStyle.LineMove:
            scanLineAnimation = LBXScanLineAnimation.instance()
            break
        case LBXScanViewAnimationStyle.NetGrid:
            scanNetAnimation = LBXScanNetAnimation.instance()
            break
        case LBXScanViewAnimationStyle.LineStill:
            scanLineStill = UIImageView()
            scanLineStill?.image = viewStyle.animationImage
            break
            
            
        default:
            break
        }
        
        var frameTmp = frame;
        frameTmp.origin = CGPoint.zero
        
        super.init(frame: frameTmp)
        
        backgroundColor = UIColor.clear
    }
    
    override init(frame: CGRect) {
        
        var frameTmp = frame;
        frameTmp.origin = CGPoint.zero
        
        super.init(frame: frameTmp)
        
        backgroundColor = UIColor.clear
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        self.init()
       
    }
    
    deinit
    {
        if (scanLineAnimation != nil)
        {
            scanLineAnimation!.stopStepAnimating()
        }
        if (scanNetAnimation != nil)
        {
            scanNetAnimation!.stopStepAnimating()
        }
        
        
//        print("LBXScanView deinit")
    }
    
    
    /**
*Start scanning animation
    */
    func startScanAnimation()
    {
        if isAnimationing
        {
            return
        }
        
        isAnimationing = true
        
        let cropRect:CGRect = getScanRectForAnimation()
        
        switch viewStyle.anmiationStyle
        {
        case LBXScanViewAnimationStyle.LineMove:
            
//            print(NSStringFromCGRect(cropRect))
            
            scanLineAnimation!.startAnimatingWithRect(animationRect: cropRect, parentView: self, image:viewStyle.animationImage )
            break
        case LBXScanViewAnimationStyle.NetGrid:
            
            scanNetAnimation!.startAnimatingWithRect(animationRect: cropRect, parentView: self, image:viewStyle.animationImage )
            break
        case LBXScanViewAnimationStyle.LineStill:
            
            let stillRect = CGRect(x: cropRect.origin.x+20,
                                   y: cropRect.origin.y + cropRect.size.height/2,
                                   width: cropRect.size.width-40,
                                   height: 2);
            self.scanLineStill?.frame = stillRect
            
            self.addSubview(scanLineStill!)
            self.scanLineStill?.isHidden = false
            
            break
            
        default: break
            
        }
    }
    
    /**
*Start scanning animation
     */
    func stopScanAnimation()
    {
        isAnimationing = false
        
        switch viewStyle.anmiationStyle
        {
        case LBXScanViewAnimationStyle.LineMove:
            
            scanLineAnimation?.stopStepAnimating()
            break
        case LBXScanViewAnimationStyle.NetGrid:
            
            scanNetAnimation?.stopStepAnimating()
            break
        case LBXScanViewAnimationStyle.LineStill:
             self.scanLineStill?.isHidden = true
            
            break
            
        default: break
            
        }
    }

    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override open func draw(_ rect: CGRect)
    {
        // Drawing code
        drawScanRect()
    }
    
    //MARK: ------ Draw scanning effect-----
    func drawScanRect()
    {
        let XRetangleLeft = viewStyle.xScanRetangleOffset
        var sizeRetangle = CGSize(width: self.frame.size.width - XRetangleLeft*2.0, height: self.frame.size.width - XRetangleLeft*2.0)
        if viewStyle.whRatio != 1.0
        {
            let w = sizeRetangle.width;
            var h:CGFloat = w / viewStyle.whRatio
            
            let hInt:Int = Int(h)
            h = CGFloat(hInt)
            
            sizeRetangle = CGSize(width: w, height: h)
        }
        
        //Minimum coordinate of the Y-axis in the scanning area
        let YMinRetangle = self.frame.size.height / 2.0 - sizeRetangle.height/2.0 - viewStyle.centerUpOffset
        let YMaxRetangle = YMinRetangle + sizeRetangle.height
        let XRetangleRight = self.frame.size.width - XRetangleLeft
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes = [
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.font: UIFont.ThemeFont.BodyRegular,
            NSAttributedStringKey.foregroundColor: UIColor.white
        ]
        let text = "scan_tip_aimToScan".localized()
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        attributedString.draw(in: CGRect(x: 0, y: YMaxRetangle + 60, width: self.frame.size.width, height: 20))
        let context = UIGraphicsGetCurrentContext()!
        
        
        //Translucency in non scanning areas
            //Set non recognition area colors
        context.setFillColor(viewStyle.color_NotRecoginitonArea.cgColor)
            //Fill Rectangle
            //Fill in the scanning area above
        var rect = CGRect(x: 0, y: 0, width: self.frame.size.width, height: YMinRetangle)
            context.fill(rect)
            
            
            //Fill the left side of the scanning area
        rect = CGRect(x: 0, y: YMinRetangle, width: XRetangleLeft, height: sizeRetangle.height)
            context.fill(rect)
            
            //Fill to the right of the scanning area
        rect = CGRect(x: XRetangleRight, y: YMinRetangle, width: XRetangleLeft,height: sizeRetangle.height)
            context.fill(rect)
            
            //Fill below the scanning area
        rect = CGRect(x: 0, y: YMaxRetangle, width: self.frame.size.width,height: self.frame.size.height - YMaxRetangle)
            context.fill(rect)
            //Performing Painting
            context.strokePath()
        
        
        if viewStyle.isNeedShowRetangle
        {
            //Draw a rectangle (square) in the middle
            context.setStrokeColor(viewStyle.colorRetangleLine.cgColor)
            context.setLineWidth(1);
            
            context.addRect(CGRect(x: XRetangleLeft, y: YMinRetangle, width: sizeRetangle.width, height: sizeRetangle.height))
            
            //CGContextMoveToPoint(context, XRetangleLeft, YMinRetangle);
            //CGContextAddLineToPoint(context, XRetangleLeft+sizeRetangle.width, YMinRetangle);
            
            context.strokePath()
            
        }
        scanRetangleRect = CGRect(x: XRetangleLeft, y:  YMinRetangle, width: sizeRetangle.width, height: sizeRetangle.height)
        
        
        //Draw a rectangular box with 4 extra edges around the corner of the frame
        
        //Width and height of frame corners
        let wAngle = viewStyle.photoframeAngleW;
        let hAngle = viewStyle.photoframeAngleH;
        
        //The width of a line with four corners
        let linewidthAngle = viewStyle.photoframeLineW;//Experience parameters: 6 and 4
        
        //Draw scan code rectangle and surrounding semi transparent black coordinate parameters
        var diffAngle = linewidthAngle/3;
        diffAngle = linewidthAngle / 2; //4 corners outside the frame, with gaps between them
        diffAngle = linewidthAngle/2;  //Box 4 corners add 4 corners to the line effect
        diffAngle = 0;//Coincident with rectangular box
        
        switch viewStyle.photoframeAngleStyle
        {
        case LBXScanViewPhotoframeAngleStyle.Outer:
                diffAngle = linewidthAngle/3//The four corners outside the box are closely connected to the box
           
        case LBXScanViewPhotoframeAngleStyle.On:
                diffAngle = 0
            
        case LBXScanViewPhotoframeAngleStyle.Inner:
                diffAngle = -viewStyle.photoframeLineW/2
        }
        
        context.setStrokeColor(viewStyle.colorAngle.cgColor);
        context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0);
        
        // Draw them with a 2.0 stroke width so they are a bit more visible.
        context.setLineWidth(linewidthAngle);
        
        
        //
        let leftX = XRetangleLeft - diffAngle
        let topY = YMinRetangle - diffAngle
        let rightX = XRetangleRight + diffAngle
        let bottomY = YMaxRetangle + diffAngle
        
        //Horizontal line in the upper left corner
        context.move(to: CGPoint(x: leftX-linewidthAngle/2, y: topY))
        context.addLine(to: CGPoint(x: leftX + wAngle, y: topY))
        
        //Vertical line in the upper left corner
        context.move(to: CGPoint(x: leftX, y: topY-linewidthAngle/2))
        context.addLine(to: CGPoint(x: leftX, y: topY+hAngle))
        
        //Bottom left horizontal line
        context.move(to: CGPoint(x: leftX-linewidthAngle/2, y: bottomY))
        context.addLine(to: CGPoint(x: leftX + wAngle, y: bottomY))
        
        //Bottom left vertical line
        context.move(to: CGPoint(x: leftX, y: bottomY+linewidthAngle/2))
        context.addLine(to: CGPoint(x: leftX, y: bottomY - hAngle))

        //Horizontal line in the upper right corner
        context.move(to: CGPoint(x: rightX+linewidthAngle/2, y: topY))
        context.addLine(to: CGPoint(x: rightX - wAngle, y: topY))
        
        //Vertical line in the upper right corner
        context.move(to: CGPoint(x: rightX, y: topY-linewidthAngle/2))
        context.addLine(to: CGPoint(x: rightX, y: topY + hAngle))

//Bottom right horizontal line
        context.move(to: CGPoint(x: rightX+linewidthAngle/2, y: bottomY))
        context.addLine(to: CGPoint(x: rightX - wAngle, y: bottomY))
        
        //Bottom right vertical line
        context.move(to: CGPoint(x: rightX, y: bottomY+linewidthAngle/2))
        context.addLine(to: CGPoint(x: rightX, y: bottomY - hAngle))
        
        context.strokePath()
    }
    
    func getScanRectForAnimation() -> CGRect
    {
        let XRetangleLeft = viewStyle.xScanRetangleOffset
        var sizeRetangle = CGSize(width: self.frame.size.width - XRetangleLeft*2, height: self.frame.size.width - XRetangleLeft*2)
        
        if viewStyle.whRatio != 1
        {
            let w = sizeRetangle.width
            var h = w / viewStyle.whRatio
            
            
            let hInt:Int = Int(h)
            h = CGFloat(hInt)
            
            sizeRetangle = CGSize(width: w, height: h)
        }
        
        //Minimum coordinate of the Y-axis in the scanning area
        let YMinRetangle = self.frame.size.height / 2.0 - sizeRetangle.height/2.0 - viewStyle.centerUpOffset
        //Scanning area coordinates
        let cropRect =  CGRect(x: XRetangleLeft, y: YMinRetangle, width: sizeRetangle.width, height: sizeRetangle.height)
        
        return cropRect;
    }

    //Obtain recognition area based on rectangular area
    static func getScanRectWithPreView(preView:UIView, style:LBXScanViewStyle) -> CGRect
    {
        let XRetangleLeft = style.xScanRetangleOffset;
        var sizeRetangle = CGSize(width: preView.frame.size.width - XRetangleLeft*2, height: preView.frame.size.width - XRetangleLeft*2)
        
        if style.whRatio != 1
        {
            let w = sizeRetangle.width
            var h = w / style.whRatio
            
            let hInt:Int = Int(h)
            h = CGFloat(hInt)
            
            sizeRetangle = CGSize(width: w, height: h)
        }
        
        //Minimum coordinate of the Y-axis in the scanning area
        let YMinRetangle = preView.frame.size.height / 2.0 - sizeRetangle.height/2.0 - style.centerUpOffset
        //Scanning area coordinates
        let cropRect =  CGRect(x: XRetangleLeft, y: YMinRetangle, width: sizeRetangle.width, height: sizeRetangle.height)
        
        
        //Calculate Region of Interest
        var rectOfInterest:CGRect
        
        //ref:http://www.cocoachina.com/ios/20141225/10763.html
        let size = preView.bounds.size;
        let p1 = size.height/size.width;
        
        let p2:CGFloat = 1920.0/1080.0 //1080p image output used
        if p1 < p2 {
            let fixHeight = size.width * 1920.0 / 1080.0;
            let fixPadding = (fixHeight - size.height)/2;
            rectOfInterest = CGRect(x: (cropRect.origin.y + fixPadding)/fixHeight,
                                    y: cropRect.origin.x/size.width,
                                    width: cropRect.size.height/fixHeight,
                                    height: cropRect.size.width/size.width)
            
            
        } else {
            let fixWidth = size.height * 1080.0 / 1920.0;
            let fixPadding = (fixWidth - size.width)/2;
            rectOfInterest = CGRect(x: cropRect.origin.y/size.height,
                                    y: (cropRect.origin.x + fixPadding)/fixWidth,
                                    width: cropRect.size.height/size.height,
                                    height: cropRect.size.width/fixWidth)
        }
        return rectOfInterest
    }
    
    func getRetangeSize()->CGSize
    {
        let XRetangleLeft = viewStyle.xScanRetangleOffset
        
        var sizeRetangle = CGSize(width: self.frame.size.width - XRetangleLeft*2, height: self.frame.size.width - XRetangleLeft*2)
        
        let w = sizeRetangle.width;
        var h = w / viewStyle.whRatio;
        
        
        let hInt:Int = Int(h)
        h = CGFloat(hInt)
        
        sizeRetangle = CGSize(width: w, height:  h)
        
        return sizeRetangle
    }
    
    func deviceStartReadying(readyStr:String)
    {
        let XRetangleLeft = viewStyle.xScanRetangleOffset
        
        let sizeRetangle = getRetangeSize()
        
        //Minimum coordinate of the Y-axis in the scanning area
        let YMinRetangle = self.frame.size.height / 2.0 - sizeRetangle.height/2.0 - viewStyle.centerUpOffset
        
        //Device startup status prompt
        if (activityView == nil)
        {
            self.activityView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            
            activityView?.center = CGPoint(x: XRetangleLeft +  sizeRetangle.width/2 - 50, y: YMinRetangle + sizeRetangle.height/2)
            activityView?.activityIndicatorViewStyle = UIActivityIndicatorView.Style.whiteLarge
            
            addSubview(activityView!)
            
            
            let labelReadyRect = CGRect(x: activityView!.frame.origin.x + activityView!.frame.size.width + 10, y: activityView!.frame.origin.y, width: 100, height: 30);
            //print("%@",NSStringFromCGRect(labelReadyRect))
            self.labelReadying = UILabel(frame: labelReadyRect)
            labelReadying?.text = readyStr
            labelReadying?.backgroundColor = UIColor.clear
            labelReadying?.textColor = UIColor.white
            labelReadying?.font = UIFont.systemFont(ofSize: 18.0)
            addSubview(labelReadying!)
        }
        
         addSubview(labelReadying!)
         activityView?.startAnimating()
        
    }
    
    func deviceStopReadying()
    {
        if activityView != nil
        {
            activityView?.stopAnimating()
            activityView?.removeFromSuperview()
            labelReadying?.removeFromSuperview()
            
            activityView = nil
            labelReadying = nil
            
        }
    }

}

