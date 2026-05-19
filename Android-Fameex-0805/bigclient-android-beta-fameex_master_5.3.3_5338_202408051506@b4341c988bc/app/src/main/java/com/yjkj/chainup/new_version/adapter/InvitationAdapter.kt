package com.yjkj.chainup.new_version.adapter

import android.text.TextUtils
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.module.LoadMoreModule
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.fengniao.news.util.DateUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.freestaking.bean.CurrencyBean
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.new_version.bean.MyInvitationsListBean
import com.yjkj.chainup.util.BigDecimalUtils
import org.json.JSONObject
import java.util.ArrayList

/**
 * @Author lianshangljl
 * @Date 2023-08-31-16:12
 * @Email buptjinlong@163.com
MyInvitationsListBean
 * @description
 */
class InvitationAdapter(data: ArrayList<MyInvitationsListBean>) : BaseQuickAdapter<MyInvitationsListBean, BaseViewHolder>(R.layout.item_my_invitation, data) , LoadMoreModule {


    var type = ParamConstant.MY_INVITATION

    override fun convert(helper: BaseViewHolder, item: MyInvitationsListBean) {
        var precision = NCoinManager.getCoinShowPrecision("USDT")
        item?.run {
            helper?.run {
                when (type) {

                    ParamConstant.MY_INVITATION -> {
                        setText(R.id.tv_type_key_1, "UID")
                        setText(R.id.tv_type_key_2, LanguageUtil.getString(context,"referral_inviteRewards_invitation_account"))
                        setText(R.id.tv_type_key_3, LanguageUtil.getString(context,"referral_inviteRewards_invitation_type"))
                        setText(R.id.tv_type_key_4, LanguageUtil.getString(context,"referral_inviteRewards_invitation_time"))

                        setText(R.id.tv_type_1, item.levelZeroRegisterUid)
                        setText(R.id.tv_type_2, item.levelZeroRegisterAccount)
                        setText(R.id.tv_type_3, item.levelStr)
                        setText(R.id.tv_type_4, DateUtil.longToString("yyyy-MM-dd", item.registerTime.toLong()))

                    }

                    ParamConstant.INVITE_REWARDS -> {

                        setText(R.id.tv_type_key_1, LanguageUtil.getString(context,"invite_reward_issue_date"))
                        setText(R.id.tv_type_key_2, LanguageUtil.getString(context,"referral_inviteRewards_invitation_account"))
                        setText(R.id.tv_type_key_3, LanguageUtil.getString(context,"referral_inviteRewards_amount"))

                        setText(R.id.tv_type_1, DateUtil.longToString("yyyy-MM-dd", item.sendTime.toLong()))
                        setText(R.id.tv_type_2, item.userAccountNum)

                        setText(R.id.tv_type_3, BigDecimalUtils.showSNormal(item.conversionAmount,NCoinManager.getCoinShowPrecision("USDT"),true))

                        setGone(R.id.rl_type_4,true)
                    }
                    else -> {

                    }
                }

            }


        }
    }

}
