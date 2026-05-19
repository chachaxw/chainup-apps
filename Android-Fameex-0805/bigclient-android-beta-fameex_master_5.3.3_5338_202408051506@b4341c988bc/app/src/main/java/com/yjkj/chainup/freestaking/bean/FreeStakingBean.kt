package com.yjkj.chainup.freestaking.bean

class FreeStakingBean {
    /**
     * banner : http://chaindown-oss.oss-cn-hongkong.aliyuncs.com/upload/20190923113240890.png
     * url : http://www.biki.com
     *TipMine: My Pos Record
     *TypeConfig: [{"langType": "zh_CN", "typeName": "Protocol Pos", "typeSn": "1569209560881_1"}, {"langType": "zh_CN", "typeName": "Position Pos", "typeSn": "1569209560881_3"}, {"langType": "zh_CN", "typeName": "Mainstream Currency Pos", "typeSn": "1569209560881_4"}, {"langType": "zh_CN", "typeName": "Platform Currency Pos", "typeSn": "1569209560881_5"}]
     * footBanner : http://chaindown-oss.oss-cn-hongkong.aliyuncs.com/upload/20190923113240890.png
     * detail :
     *
     *Introduction to Chinese Wealth Management
     *FootTitle: Introduction to financial management homepage title
     *FaqUrl: faq link
     *Contact: Financial contact information
     */

    var banner: String? = null
    var url: String? = null
    var tipMine: String? = null
    var footBanner: String? = null
    var detail: String? = null
    var footTitle: String? = null
    var faqUrl: String? = null
    var contact: String? = null
    var typeConfig: List<TypeConfigBean>? = null

    class TypeConfigBean {
        /**
         * langType : zh_CN
         *TypeName: Protocol Pos
         * typeSn : 1569209560881_1
         */

        var langType: String? = null
        var typeName: String? = null
        var typeSn: String? = null
    }
}
