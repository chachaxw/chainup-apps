package com.yjkj.chainup.wedegit

import android.content.Context
import android.text.TextUtils
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import com.alibaba.fastjson.JSON
import com.yjkj.chainup.R
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.ManyChainSelectListener
import com.yjkj.chainup.new_version.view.ManySelectCoinListener
import com.yjkj.chainup.util.LineSelectOnclickListener
import kotlinx.android.synthetic.main.item_many_chain.view.*
import org.json.JSONObject

/**
 * @Author lianshangljl
 * @Date 2023-12-24-15:14
 * @Email buptjinlong@163.com
 * @description
 */
class ManyChainView @JvmOverloads constructor(context: Context,
                                              attrs: AttributeSet? = null,
                                              defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {

    var listener: ManyChainSelectListener? = null
    var listener4Select: ManySelectCoinListener? = null

    init {
        LayoutInflater.from(context).inflate(R.layout.item_many_chain, this, true)
        initView()
    }


    fun initView() {
        /**
         *Click on the picture question mark
         */
        iv_risk_rate?.setOnClickListener {
            setContentListener()
        }
        tv_link_name?.text = LanguageUtil.getString(context, "link_name")
    }

    var content: String = ""
    var follCoinByMainList: ArrayList<JSONObject> = arrayListOf()
    var hotCoinList: ArrayList<String> = arrayListOf()

    /**
     *Here is the selection of currency
     */
    fun setHotCoinView(coins: ArrayList<String>) {
        hotCoinList.clear()
        hotCoinList.addAll(coins)

        rv_chain_list?.setHotCoinAdapter(hotCoinList)
        rv_chain_list?.setLineSelectOncilckListener(object : LineSelectOnclickListener {
            override fun sendOnclickMsg() {

            }

            override fun selectMsgIndex(index: String?) {
                if (null != listener) {
                    var json = hotCoinList[index?.toInt() ?: 0]
//                    setIvRiskRateVisible(json)
                    listener4Select?.selectCoin(json)
                }
            }
        })
    }


    /**
     *@param showSymbol, this is the main chain currency
     *Only one sub chain coin is displayed when adding an address to @param selectSymbol
     */
    fun setManyChainView(showSymbol: String, selectSymbol: String = "",type:String="") {
        follCoinByMainList = PublicInfoDataService.getInstance().getFollowCoinsByMainCoinName(showSymbol,type)
        if (null == follCoinByMainList || follCoinByMainList.size == 0) {
            ll_chain_name_layout?.visibility = View.GONE
            rv_chain_list?.visibility = View.GONE
            return
        }
        ll_chain_name_layout?.visibility = View.VISIBLE
        rv_chain_list?.visibility = View.VISIBLE


        follCoinByMainList.sortBy { it.optInt("sort", 0) }


        var selectPosition = 0
        /**
         *Determine whether the selectSymbol is empty. If it is empty, it is normal. If it is not empty, only the child chains of the selectSymbol will be displayed
         */
        if (TextUtils.isEmpty(selectSymbol)) {
            listener?.selectCoin(follCoinByMainList[0])
        } else {
            var selectJson = JSONObject()
            follCoinByMainList.forEach {
                if (it?.optString("name") == selectSymbol) {
                    selectJson = it
                    return@forEach
                }
            }
            if (null != selectJson && selectJson?.length() ?: 0 > 0) {
                follCoinByMainList.clear()
                follCoinByMainList.add(selectJson)
            }
        }

        rv_chain_list?.setNormalAdapter(follCoinByMainList, selectPosition)
        rv_chain_list?.setLineSelectOncilckListener(object : LineSelectOnclickListener {
            override fun sendOnclickMsg() {

            }

            override fun selectMsgIndex(index: String?) {
                if (null != listener) {
                    var json = follCoinByMainList[index?.toInt() ?: 0]
//                    setIvRiskRateVisible(json)
                    listener?.selectCoin(json)
                }
            }
        })
    }


    fun setTitleContent(content: String) {
        tv_link_name?.text = content
        iv_risk_rate?.visibility = View.GONE
    }

    /**
     *Settings
     */
    private fun setIvRiskRateVisible(json: JSONObject) {
        if ("1" == json.optString("mainChainType")) {
            iv_risk_rate?.visibility = View.VISIBLE
        } else {
            iv_risk_rate?.visibility = View.GONE
        }
    }

    private fun setContentListener() {
        NewDialogUtils.showNewsingleDialog(context, content, object : NewDialogUtils.DialogBottomListener {
            override fun sendConfirm() {
            }

        }, LanguageUtil.getString(context, "link_name"), LanguageUtil.getString(context, "alert_common_iknow"))
    }

    fun clearLables() {
        rv_chain_list?.clearLables()
    }

}
