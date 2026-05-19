//
//  UISliderExtension.swift
//  SDJGVideo
//
//  Created by 王俊 on 16/5/9.
//Modify by Wang Jun on 17/6/5 Swift3.0
//  Copyright © 2016年 sunlands. All rights reserved.
//

import UIKit

extension UISlider {
    
    /**
Add Event
     
-Parameter target: target
-Parameter actionNames: Method name
-Parameter forControlEvents: Events
     */
    public final func extAddTargets(_ target: AnyObject?, actions: [Selector], forControlEvents: [UIControlEvents]){
        
        for i in 0 ..< actions.count{
            
          self.addTarget(target, action: actions[i], for: forControlEvents[i])
            
        }

    }
    
    /**
Set press drag lift (inside and outside the area) to cancel
     
-Parameter target: target
-Parameter actionNames: Event
     */
    public final func extAddAllTarget(_ target: AnyObject?, actions: [Selector]) {
        
        //1 Press
        self.addTarget(target, action: actions[0], for: UIControlEvents.touchDown)
        //2 Drag
        self.addTarget(target, action: actions[1], for: UIControlEvents.valueChanged)
        
        //3. Lifting inside the lifting area and lifting outside the lifting area has been cancelled (incoming call)
        self.addTarget(target, action: actions[2], for: UIControlEvents.touchUpOutside)
        self.addTarget(target, action: actions[3], for: UIControlEvents.touchCancel)
        self.addTarget(target, action: actions[4], for: UIControlEvents.touchUpInside)
        
    }
    
    
    

}

