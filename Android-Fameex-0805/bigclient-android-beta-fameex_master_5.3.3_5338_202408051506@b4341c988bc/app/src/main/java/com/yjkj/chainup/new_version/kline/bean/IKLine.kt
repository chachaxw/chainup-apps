package  com.yjkj.chainup.new_version.kline.bean

import com.yjkj.chainup.new_version.kline.bean.vice.IKDJ
import com.yjkj.chainup.new_version.kline.bean.vice.IMACD
import com.yjkj.chainup.new_version.kline.bean.vice.IRSI
import com.yjkj.chainup.new_version.kline.bean.vice.IWR


/**
 * @Author: Bertking
 * @Date 2023/2/25-10:55 AM
 *@description: K-line entity
 */
interface IKLine : CandleBean, VolumeBean, IKDJ, IMACD, IRSI, IWR
