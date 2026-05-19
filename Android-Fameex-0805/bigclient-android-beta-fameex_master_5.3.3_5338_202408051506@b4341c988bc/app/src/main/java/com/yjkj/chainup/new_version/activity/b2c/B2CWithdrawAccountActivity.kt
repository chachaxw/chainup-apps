package com.yjkj.chainup.new_version.activity.b2c

import android.app.Activity
import android.content.Intent
import android.graphics.Typeface
import android.os.Bundle
import androidx.core.content.ContextCompat
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.util.Log
import android.view.Gravity
import android.view.View
import android.widget.EditText
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
 import com.chainup.contract.view.dialog.CpTDialog
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.ParamConstant.*
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.util.NToastUtil
import com.yjkj.chainup.util.StringUtil
import kotlinx.android.synthetic.main.activity_b2_cadd_withdraw_account.*
import kotlinx.android.synthetic.main.activity_b2_cadd_withdraw_account.btn_confirm
import kotlinx.android.synthetic.main.activity_b2_cadd_withdraw_account.collapsing_toolbar
import kotlinx.android.synthetic.main.activity_b2_cadd_withdraw_account.toolbar
import kotlinx.android.synthetic.main.activity_b2_cadd_withdraw_account.tv_bank
import kotlinx.android.synthetic.main.activity_b2_cadd_withdraw_account.tv_coin
import org.json.JSONObject

/**
 *@description: Add&Modify&View Withdrawal Account (B2C)
 * @author Bertking
 * @Date 2023-10-24 AM
 */
@Route(path = RoutePath.B2CWithdrawAccountActivity)
class B2CWithdrawAccountActivity : NBaseActivity() {
    @JvmField
    @Autowired(name = TYPE)
    var type = TYPE_ADD

    var symbol: String = PublicInfoDataService.getInstance().coinInfo4B2c

    var bankSub: String = ""
    var bankAmount: String = ""

    var bankName: String = ""

    /**
     *Primary key of withdrawal table
     */
    @JvmField
    @Autowired(name = WITHDRAW_ID)
    var id = ""

    /**
     *Bank card number
     */
    @JvmField
    @Autowired(name = BANK_ID)
    var bankNo = ""

    var dialog:  CpTDialog? = null


    override fun setContentView() = R.layout.activity_b2_cadd_withdraw_account

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        initView()
    }

    override fun initView() {
        renderData()
    }


    private fun renderData() {
        
        if (isEnable(et_bank_branch) && isEnable(et_bank_amount)) {
            btn_confirm?.isEnable(true)
        } else {
            btn_confirm?.isEnable(false)
        }

        setSupportActionBar(toolbar)

        toolbar?.setNavigationOnClickListener {
            finish()
        }


        collapsing_toolbar?.run {
            setCollapsedTitleTextColor(ContextCompat.getColor(mActivity, R.color.text_color))
            setExpandedTitleColor(ContextCompat.getColor(mActivity, R.color.text_color))
            setExpandedTitleTypeface(Typeface.DEFAULT_BOLD)
            expandedTitleGravity = Gravity.BOTTOM
        }

        tv_coin?.text = symbol
        tv_bank?.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, if (type == TYPE_SEE) 0 else R.drawable.enter, 0)
        btn_confirm?.visibility = if (type == TYPE_SEE) View.GONE else View.VISIBLE
        tv_edit?.text = (if (type == TYPE_EDIT) getString(R.string.otc_delete) else "")
        collapsing_toolbar?.title = (if (type == TYPE_ADD) getString(R.string.b2c_text_addWithdrawAccount) else getString(R.string.b2c_text_editWithdrawAccount))

        if (type == TYPE_EDIT) {
            tv_edit?.setOnClickListener {
////Delete
//NewDialogUtils. showNormalDialog (mActivity, "Are you sure to delete?", object: NewDialogUtils. DialogBottomListener{
//                    override fun sendConfirm() {
//                    }
//                }, getString(R.string.otc_delete))

                fiatDeleteBank(id)
            }
        }

        /*Select Bank of Deposit*/
        tv_bank?.setOnClickListener {
            ArouterUtil.navigation4Result(RoutePath.B2CBankListActivity, Bundle().apply { putString(BANK_ID, bankNo) }, mActivity, 123)
        }


        et_bank_branch?.isFocusableInTouchMode = type != TYPE_SEE
        et_bank_amount?.isFocusableInTouchMode = type != TYPE_SEE

        /**
         *Branch
         */
        et_bank_branch?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                bankSub = s.toString()
                if (isEnable(et_bank_branch) && isEnable(et_bank_amount)) {
                    btn_confirm?.isEnable(true)
                } else {
                    btn_confirm?.isEnable(false)
                }

            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            }

        })
        /**
         *Bank account number
         */
        et_bank_amount?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                bankAmount = s.toString()
                if (isEnable(et_bank_branch) && isEnable(et_bank_amount)) {
                    btn_confirm?.isEnable(true)
                } else {
                    btn_confirm?.isEnable(false)
                }
            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            }

        })


        /**
         *Payee
         */
        et_payee?.text = UserDataService.getInstance().realName


//        et_payee?.addTextChangedListener(object : TextWatcher {
//            override fun afterTextChanged(s: Editable?) {
//                payee = s.toString()
//                if (isEnable(et_bank_branch) && isEnable(et_bank_amount) && isEnable(et_payee)) {
//                    btn_confirm?.isEnable(true)
//                } else {
//                    btn_confirm?.isEnable(false)
//                }
//            }
//
//            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
//            }
//
//            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
//
//            }
//
//        })


        /*TODO recharge confirmation*/
        btn_confirm?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                when (type) {
                    TYPE_ADD -> {
//                        fiatAddBank()
                        dialog = NewDialogUtils.showAccountBindDialog(mActivity, "", 1, 30, object : NewDialogUtils.DialogVerifiactionListener {
                            override fun returnCode(phone: String?, mail: String?, googleCode: String?) {
                                dialog?.dismiss()
                                
                                fiatAddBank(smsAuthCode = phone ?: return, googleCode = googleCode
                                        ?: return)
                            }
                        })
                    }

                    TYPE_EDIT -> {
                        dialog = NewDialogUtils.showAccountBindDialog(mActivity, "", 1, 31, object : NewDialogUtils.DialogVerifiactionListener {
                            override fun returnCode(phone: String?, mail: String?, googleCode: String?) {
                                dialog?.dismiss()
                                
                                fiatEditBank(smsAuthCode = phone ?: return, googleCode = googleCode
                                        ?: return)
                            }
                        })
                    }
                }

            }
        }



        if (type == TYPE_ADD) {
            fiatAllBank()
        } else {
            
            fiatGetBank()
        }

    }

    fun isEnable(editText: EditText): Boolean {
        val string = editText.text.toString()
        return !(TextUtils.isEmpty(string))
    }


    /**
     *Add withdrawal bank
     */
    fun fiatAddBank(
            smsAuthCode: String = "",
            googleCode: String = ""
    ) {
        addDisposable(getMainModel().fiatAddBank(
                bankNo,
                bankSub = bankSub,
                cardNo = bankAmount,
                name = UserDataService.getInstance().realName,
                symbol = symbol,
                smsAuthCode = smsAuthCode,
                googleCode = googleCode,
                consumer = object : NDisposableObserver(mActivity) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
//ShowSnackBar ("Created successfully", isSuc=true)
                        finish()
                    }
                }))
    }


    /**
     *Bank List
     */
    private fun fiatAllBank() {
        addDisposable(getMainModel().fiatAllBank(symbol = PublicInfoDataService.getInstance().coinInfo4B2c,
                consumer = object : NDisposableObserver(mActivity) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        jsonObject.optJSONArray("data").run {
                            if (this != null && this.length() > 0) {
                                val jsonObject1 = this.optJSONObject(0)
                                bankName = jsonObject1.optString("accountName")

                                tv_bank?.text = bankName
                                bankNo = jsonObject1.optString("bankNo")

                            }

                        }
                    }
                }))
    }


    /**
     *Edit withdrawal bank
     */
    fun fiatEditBank(smsAuthCode: String = "",
                     googleCode: String = "") {
        addDisposable(getMainModel().fiatEditBank(id = id,
                bankId = bankNo,
                bankSub = bankSub,
                cardNo = bankAmount,
                name = UserDataService.getInstance().realName,
                symbol = symbol,
                smsAuthCode = smsAuthCode,
                googleCode = googleCode,
                consumer = object : NDisposableObserver(mActivity) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        showSnackBar(getString(R.string.b2c_text_editSuccess), isSuc = true)
                        finish()
                    }
                }))
    }

    /**
     *Delete withdrawal bank
     */
    fun fiatDeleteBank(id: String) {
        addDisposable(getMainModel().fiatDeleteBank(id = id,
                consumer = object : NDisposableObserver(mActivity) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        NToastUtil.showTopToastNet(mActivity,true, getString(R.string.b2c_text_deleteSuccess))
                        finish()
                    }
                }))
    }


    /**
     *Query withdrawal bank
     */
    private fun fiatGetBank() {
        addDisposable(getMainModel().fiatGetBank(id = id,
                consumer = object : NDisposableObserver(mActivity) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        jsonObject.optJSONObject("data")?.run {
                            tv_bank?.text = optString("bankName")
                            et_bank_branch?.setText(optString("bankSub"))
//                            et_payee?.text = optString("name")
                            et_bank_amount?.setText(optString("cardNo"))

                            bankNo = optString("bankNo")
                        }
                    }
                }))
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == Activity.RESULT_OK) {
            when (requestCode) {
                123 -> {
                    val bankInfo = data?.getStringExtra(BANK_JSON) ?: ""
                    if (StringUtil.checkStr(bankInfo)) {
                        val bank = JSONObject(bankInfo)
                        tv_bank?.text = bank.optString("accountName")
                        bankNo = bank.optString("bankNo")
                    }
                }
            }
        }
    }


}
