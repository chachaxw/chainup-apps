package com.yjkj.chainup.new_version.contract

import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import androidx.recyclerview.widget.LinearLayoutManager
import android.text.TextUtils
import android.util.Log
import android.widget.TextView
import com.chad.library.adapter.base.listener.OnItemChildClickListener
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseFragment
import com.yjkj.chainup.manager.Contract2PublicInfoManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.adapter.NPositionAdapter
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.util.*
import kotlinx.android.synthetic.main.fragment_position.*
import org.json.JSONObject

/**
 * @Author: Bertking
 * @Date 2023-09-12-16:03
 *@description: The "position" of the contract
 */

class NPositionFragment : NBaseFragment() {
    override fun setContentView() = R.layout.fragment_position

    var adapter = NPositionAdapter(arrayListOf())
    var userPositionList: ArrayList<JSONObject> = arrayListOf()


    override fun onResume() {
        super.onResume()
        getPosition4Contract()
    }

    override fun initView() {
        onSelectClick()
        rv_position?.setHasFixedSize(true)
        rv_position?.layoutManager = LinearLayoutManager(context)
        rv_position?.adapter = adapter
        adapter.setEmptyView(EmptyForAdapterView(context ?: return))

        adapter.setOnItemChildClickListener { adapter, view, position ->
            val jsonObject = adapter?.data?.get(position) as JSONObject
            val contractId = jsonObject.optString("contractId")
            val leverageLevel = jsonObject.optString("leverageLevel")
            val quoteSymbol = jsonObject.optString("quoteSymbol")
            val id = jsonObject.optString("id")

            when (view?.id) {
                R.id.btn_adjust_lever -> {
                    //Adjusting the lever
                    if (Contract2PublicInfoManager.isPureHoldPosition()) {
                        AdjustLeverUtil(context
                                ?: return@setOnItemChildClickListener, contractId.toInt(), leverageLevel, object : AdjustLeverUtil.AdjustLeverListener {
                            override fun adjustSuccess(value: String) {
                                if (adapter.getViewByPosition(position, R.id.btn_adjust_deposit) != null) {
                                    (adapter.getViewByPosition(position, R.id.btn_adjust_deposit) as TextView).text = LanguageUtil.getString(context, "contract_action_editLever") + "(" + value + "x)"
                                }
                                Log.d("OnItemChildClickListener", "==当前杠杆==$value")
                                getPosition4Contract()
                            }

                            override fun adjustFailed(msg: String) {
                                //DisplayUtil.showSnackBar(activity?.window?.decorView, msg, false)
                                NToastUtil.showTopToastNet(activity,false, msg)
                            }
                        })
                    } else {
                        //Limit price closing position
                        NewDialogUtils.closePositionByLimit(context!!, quoteSymbol,
                                object : NewDialogUtils.DialogBottomAloneListener {
                                    override fun returnContent(content: String) {
                                        /**
                                         *Return content format: price/volume
                                         */
                                        val split = content.split("/")
                                        takeOrder(jsonObject, price = split[0], vol = split[1], orderType = 1)
                                    }
                                })
                    }
                }

                //Market closing
                R.id.btn_take_order -> {
                    takeOrder(jsonObject, orderType = 2)
                }
                //Margin
                R.id.tv_deposit -> {
                    NewDialogUtils.adjustDepositDialog(context!!, jsonObject,
                            object : NewDialogUtils.DialogBottomAloneListener {
                                override fun returnContent(content: String) {
                                    transferMargin4Contract(id, contractId, content)
                                }
                            })


                }
            }
        }
    }


    fun onSelectClick() {
        swipe_refresh?.setOnRefreshListener{
            getPosition4Contract()
        }

    }


    /**
     *User position information
     */
    private fun getPosition4Contract() {
//        if (!LoginManager.checkLogin(activity, false)) {
//            adapter.setList(arrayListOf())
//            return
//        }
        LogUtil.d(TAG, "getPosition4Contract1")
        addDisposable(getContractModelOld().getPosition4Contract(
                consumer = object : NDisposableObserver() {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        swipe_refresh?.finishRefresh(true)
                        jsonObject.optJSONObject("data").run {
                            userPositionList.clear()
                            val jsonArray = optJSONArray("positions")
                            if (jsonArray != null && jsonArray.length() != 0) {
                                for (i in 0 until jsonArray.length()) {
                                    userPositionList.add(jsonArray.optJSONObject(i))
                                }
                                val contractId = Contract2PublicInfoManager.currentContractId()
                                val filterIndexed = userPositionList.filterIndexed { index, position ->
                                    position.optString("contractId").toIntOrNull() ?: -1 == contractId
                                }
                                userPositionList.removeAll(filterIndexed)
                                userPositionList.addAll(0, filterIndexed)
                                adapter.setList(userPositionList)

                            }
                        }
                    }

                    override fun onResponseFailure(code: Int, msg: String?) {
                        super.onResponseFailure(code, msg)
                        swipe_refresh?.finishRefresh(true)
                    }
                }))
    }

    /**
     *Limit price closing orderType=1
     *Market Closing OrderType=2
     */
    private fun takeOrder(jsonObject: JSONObject, price: String = "", vol: String = "", orderType: Int) {
        val side = jsonObject.optString("side")
        val volume = jsonObject.optString("volume")
        val indexPrice = jsonObject.optString("indexPrice")
        val contractId = jsonObject.optString("contractId")
        val leverageLevel = jsonObject.optString("leverageLevel")
        val id = jsonObject.optString("id")

        addDisposable(getContractModelOld().takeOrder4Contract(
                contractId = contractId.toString()
                , volume = if (TextUtils.isEmpty(price)) {
            volume.toString()
        } else {
            vol
        }, price = if (TextUtils.isEmpty(price)) {
            indexPrice.toString()
        } else {
            price
        },
                orderType = orderType,
                side = if (side == "BUY") "SELL" else "BUY",
                closeType = "1",
                level = leverageLevel.toString(),
                positionId = id.toString(),
                consumer = object : NDisposableObserver() {
                    override fun onResponseSuccess(data: JSONObject) {
                        NToastUtil.showTopToastNet(activity,true, LanguageUtil.getString(context, "contract_tip_submitSuccess"))
                        getPosition4Contract()
                    }
                }))
    }


    /**
     *Additional margin
     */
    private fun transferMargin4Contract(positionId: String, contractId: String, amount: String) {
        if (!LoginManager.checkLogin(context, false)) return
        addDisposable(getContractModelOld().transferMargin4Contract(
                positionId = positionId,
                contractId = contractId,
                amount = amount,
                consumer = object : NDisposableObserver() {
                    override fun onResponseSuccess(data: JSONObject) {
                        getPosition4Contract()
                        NToastUtil.showTopToastNet(activity,true, LanguageUtil.getString(context, "contract_modify_the_success"))
                    }

                }))
    }
}

