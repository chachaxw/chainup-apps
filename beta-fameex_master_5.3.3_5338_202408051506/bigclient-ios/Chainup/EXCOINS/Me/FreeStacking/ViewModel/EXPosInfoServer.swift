//
//  EXPosInfoServer.swift
//  Chainup
//
//  Created by lcus on 2023/10/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit



class EXPosInfoServer: NSObject {
    

  
   class func handerFlagImage(status:Int) -> UIImage {
        
        switch status {
        case 1:
            return UIImage.themeImageNamed(imageName: "personal_hot")
        case 2:
            return UIImage.themeImageNamed(imageName: "personal_new")
            
        default:
            return UIImage()
        }
        
    }
    
    class  func handProgectStatus(type:Int,status:Int)->String {
      
     //Type 3 Protocol POS 1 Position POS
     //Type==3 0 to be started 1. Fundraising concentration 2. Interest to be calculated 3. In progress 4. Interest to be calculated 5. Principal release 6. Full amount belongs to the fundraising concentration status
     //Type==1 1 To be started 2 In progress 3 Ended
        if type == 3 {
            switch status {
            case 0:
                return "「\("pos_state_start".localized())」"
            case 1:
                return "「\("pos_state_buying".localized())」"
            case 2:
                return "「\("pos_state_waitInterest".localized())」"
            case 3:
                return "「\("pos_state_InterestIng".localized())」"
            case 4:
                return "「\("pos_state_InterestEnd".localized())」"
            case 5:
                return "「\("pos_state_release".localized())」"
            case 6:
                return "「\("pos_state_fulled".localized())」"
                
            default:
                return ""
            }
        }else if type == 1 {
            
            switch status {
      
            case 1:
                return "「\("pos_state_start".localized())」"
            case 2:
                return "「\("pos_state_processing".localized())」"
            case 3:
                return "「\("pos_state_end".localized())」"
            default:
                return ""
            
            }
    
        }
        
        return ""
  
    }
    

}


