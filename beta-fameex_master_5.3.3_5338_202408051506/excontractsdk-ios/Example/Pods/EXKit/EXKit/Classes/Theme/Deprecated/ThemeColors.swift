//
//  ThemeColors.swift
//  Chainup
//
//  Created by liuxuan on 2019/2/15.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit

extension UIColor {
    
    public struct ThemeLabel {
        public static var colorLite :UIColor { return UIColor.themeColor(keyPath:label_litecolor_key)}
        public static var colorMedium :UIColor { return UIColor.themeColor(keyPath:label_medidumcolor_key)}
        public static var colorDark :UIColor { return UIColor.themeColor(keyPath:label_darkcolor_key)}
        public static var colorHighlight :UIColor { return UIColor.themeColor(keyPath:label_highlight_key)}
        public static var white :UIColor { return UIColor.themeColor(keyPath:label_white_key)}
        public static var share :UIColor { return UIColor.themeColor(keyPath:label_share_key)}
    }
    
    public struct ThemeBtn {
        public static var normal :UIColor { return UIColor.themeColor(keyPath:btn_normal_key)}
        public static var touch :UIColor { return UIColor.themeColor(keyPath:btn_touch_key)}
        public static var touch2 :UIColor { return UIColor.themeColor(keyPath:btn_touch2_key)}
        public static var disable :UIColor { return UIColor.themeColor(keyPath:btn_disable_key)}
        public static var highlight :UIColor { return UIColor.themeColor(keyPath:btn_highlight_key)}
        public static var title :UIColor { return UIColor.themeColor(keyPath:btn_title_key)}
    }
    
    public struct ThemekLine {
        public static var up :UIColor {
            if EXKLineManager.isGreen() {
                return UIColor.themeColor(keyPath:kline_up_key)
            }else {
                return UIColor.themeColor(keyPath:kline_down_key)
            }
        }
        public static var up15 :UIColor {
            if EXKLineManager.isGreen() {
                return UIColor.themeColor(keyPath:kline_up15_key)
            }else {
                return UIColor.themeColor(keyPath:kline_down15_key)
            }
        }
        public static var down :UIColor {
            if EXKLineManager.isGreen() {
                return UIColor.themeColor(keyPath:kline_down_key)
            }else {
                return UIColor.themeColor(keyPath:kline_up_key)
            }
        }
        public static var down15 :UIColor {
            if EXKLineManager.isGreen() {
                return UIColor.themeColor(keyPath:kline_down15_key)
            }else {
                return UIColor.themeColor(keyPath:kline_up15_key)
            }
        }
        public static var yellow :UIColor { return UIColor.themeColor(keyPath:kline_yellow_key)}
        public static var green :UIColor { return UIColor.themeColor(keyPath:kline_green_key)}
        public static var purple :UIColor { return UIColor.themeColor(keyPath:kline_purple_key)}
        public static var pink :UIColor { return UIColor.themeColor(keyPath:kline_pink_key)}
        public static var tagbg :UIColor { return UIColor.themeColor(keyPath:kline_tagbg_key)}
        public static var seperator :UIColor { return UIColor.themeColor(keyPath:kline_seperator_key)}
        /// lab
        public static var labcolorLite :UIColor { return UIColor.themeColor(keyPath:kline_label_litecolor_key)}
        public static var labcolorMedium :UIColor { return UIColor.themeColor(keyPath:kline_label_medidumcolor_key)}
        public static var labcolorDark :UIColor { return UIColor.themeColor(keyPath:kline_label_darkcolor_key)}
        public static var labwhite :UIColor { return UIColor.themeColor(keyPath:kline_label_white_key)}
        public static var labcolorHighlight :UIColor { return UIColor.themeColor(keyPath:kline_label_highlight_key)}
        /// view
        public static var viewSeperator :UIColor { return UIColor.themeColor(keyPath:kline_view_seperator_key)}
        public static var viewHighlight :UIColor { return UIColor.themeColor(keyPath:kline_view_highlight_key)}
        public static var viewBg :UIColor {
            return UIColor.themeColor(keyPath:kline_view_bg_key)}
        public static var viewBgTab :UIColor { return UIColor.themeColor(keyPath:kline_view_bgtab_key)}
        public static var viewbgGap :UIColor { return UIColor.themeColor(keyPath:kline_view_bggap_key)}
        public static var viewhighlight50 :UIColor { return UIColor.themeColor(keyPath:kline_view_highlight50_key)}
        public static var viewbgIcon :UIColor {
            return UIColor.themeColor(keyPath:kline_view_bgIcon_key)}
        public static var viewbgIcon25 :UIColor {
            return UIColor.themeColor(keyPath:kline_view_bgIcon25_key)}
        public static var viewborder :UIColor { return UIColor.themeColor(keyPath:kline_view_border_key)}
        /// nav
        public static var navBg :UIColor { return UIColor.themeColor(keyPath:kline_nav_bg_key)}
        /// btn
        public static var btnHighlight :UIColor { return UIColor.themeColor(keyPath:kline_btn_highlight_key)}
        
    }
    
    public struct ThemeView {
        public static var yellow :UIColor { return UIColor.themeColor(keyPath:view_yellow_key)}
        public static var alertBg :UIColor { return UIColor.themeColor(keyPath:view_alertbg_key)}
        public static var markBg :UIColor { return UIColor.themeColor(keyPath:view_markbg_key)}
        public static var midBg :UIColor { return UIColor.themeColor(keyPath:view_midBg_key)}
        public static var card1 :UIColor { return UIColor.themeColor(keyPath:view_card1_key)}
        public static var card2 :UIColor { return UIColor.themeColor(keyPath:view_card2_key)}
        public static var mask :UIColor { return UIColor.themeColor(keyPath:view_mask_key).withAlphaComponent(0.5)}
        public static var toast :UIColor { return UIColor.themeColor(keyPath:view_toast_key)}
        public static var highlight :UIColor { return UIColor.themeColor(keyPath:view_highlight_key)}
        public static var highlight50 :UIColor { return UIColor.themeColor(keyPath:view_highlight50_key)}
        public static var highlight25 :UIColor { return UIColor.themeColor(keyPath:view_highlight25_key)}
        public static var highlight15 :UIColor { return UIColor.themeColor(keyPath:view_highlight15_key)}
        public static var bg :UIColor {
            return UIColor.themeColor(keyPath:view_bg_key)}
        public static var newbg :UIColor {
            return UIColor.themeColor(keyPath:view_newbg_key)}
        public static var bgIcon :UIColor {
            return UIColor.themeColor(keyPath:view_bgIcon_key)}
        public static var bgIcon50 :UIColor {
            return UIColor.themeColor(keyPath:view_bgIcon50_key)}
        public static var bgIcon25 :UIColor {
            return UIColor.themeColor(keyPath:view_bgIcon25_key)}
        public static var bgIconh :UIColor {
            return UIColor.themeColor(keyPath:view_bgIconh_key)}
        public static var bgIconh50 :UIColor {
            return UIColor.themeColor(keyPath:view_bgIconh50_key)}
        public static var bgGap :UIColor { return UIColor.themeColor(keyPath:view_bggap_key)}
        public static var bgTab :UIColor { return UIColor.themeColor(keyPath:view_bgtab_key)}
        public static var seperator :UIColor { return UIColor.themeColor(keyPath:view_seperator_key)}
        public static var border :UIColor { return UIColor.themeColor(keyPath:view_border_key)}
        public static var bgCard :UIColor { return UIColor.themeColor(keyPath:view_bgcard_key)}
        public static var mySign :UIColor {return UIColor.themeColor(keyPath: view_mySign_key)}
        public static var alertImage :UIColor {return UIColor.themeColor(keyPath: view_alertImage_key)}
        public static var badge5 :UIColor { return UIColor.themeColor(keyPath: view_badge5_key)}
        public static var badge10 :UIColor { return UIColor.themeColor(keyPath: view_badge10_key)}
    }
    
    public struct ThemeNav {
        public static var bg :UIColor { return UIColor.themeColor(keyPath:nav_bg_key)}
    }
    
    public struct ThemeTab {
        public static var bg :UIColor { return UIColor.themeColor(keyPath:tab_bg_key)}
        public static var icon :UIColor { return UIColor.themeColor(keyPath:tab_icon_key)}
    }
    
    public struct ThemeState {
        public static var normal :UIColor { return
            UIColor.themeColor(keyPath:state_normal_key)}
        public static var normal80 :UIColor { return
            UIColor.themeColor(keyPath:state_normal80_key)}
        public static var success :UIColor { return UIColor.themeColor(keyPath:state_success_key)}
        public static var success80 :UIColor { return UIColor.themeColor(keyPath:state_success80_key)}
        public static var fail :UIColor { return UIColor.themeColor(keyPath:state_fail_key)}
        public static var fail80 :UIColor { return UIColor.themeColor(keyPath:state_fail80_key)}
        public static var warning :UIColor { return UIColor.themeColor(keyPath:state_warning_key)}
        public static var warning80 :UIColor { return UIColor.themeColor(keyPath:state_warning80_key)}
    }
    
    public struct ThemePageControl{
        public static var select :UIColor { return
            UIColor.themeColor(keyPath:pagecontrol_select_key)}
        public static var unselect :UIColor { return
            UIColor.themeColor(keyPath:pagecontrol_unselect_key)}
        public static var bannerSelect :UIColor { return
            UIColor.themeColor(keyPath:pagecontrol_bannerSelect_key)}
        public static var bannerUnselect :UIColor { return
            UIColor.themeColor(keyPath:pagecontrol_bannerUnselect_key)}
    }
    
    public struct ThemeRedPacket{
        public static var normalRed :UIColor { return
            UIColor.themeColor(keyPath:redpacket_normalRed_key)}
        
        public static var text :UIColor { return
            UIColor.themeColor(keyPath:redpakcet_text_key)}
    }
    
    public struct ThemeTextField{
        public static var seperator :UIColor { return
            UIColor.themeColor(keyPath:textfield_seperator_key)}
    }
    
    public struct ThemeSearchPage{
        public static var searchBarBg :UIColor {
            return UIColor.themeColor(keyPath:searchpage_searchbarbg_key)
        }
        public static var searchBg :UIColor {
            return UIColor.themeColor(keyPath:searchpage_bg_key)
        }
    }
    
}

