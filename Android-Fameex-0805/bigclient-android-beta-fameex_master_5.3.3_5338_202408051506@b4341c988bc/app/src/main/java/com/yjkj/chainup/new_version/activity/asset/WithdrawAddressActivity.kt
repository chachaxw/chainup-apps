package com.yjkj.chainup.new_version.activity.asset

import android.app.Activity
import android.content.Intent
import android.graphics.Typeface
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.KeyEvent
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
 import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.KKDialogUtils
import com.yjkj.chainup.R
import com.yjkj.chainup.app.AppConstant
import com.yjkj.chainup.bean.address.AddressBean
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.new_version.activity.NewBaseActivity
import com.yjkj.chainup.new_version.adapter.WithdrawAddressAdapter
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.new_version.view.EmptyForAdapterView
import com.yjkj.chainup.securityVerifyRule.VerifyRule2
import com.yjkj.chainup.util.DisplayUtil
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_withdraw_address.*


/**
 *@description Withdrawal Address List
 */
class WithdrawAddressActivity : NewBaseActivity() {
    var symbol: String = ""
    var showSymbol: String = ""
    var selectAddress: String = ""

    var list = arrayListOf<AddressBean.Address>()
    lateinit var adapter: WithdrawAddressAdapter


    companion object {
        const val REQUEST_CODE_ADDRESS = 2088

        const val OBJECT_ADDRESS = "address"

        const val SELECT_ADDRESS = "select_address"

        const val SYMBOL = "Symbol"
        const val SHOWSYMBOL = "showSymbol"

        fun enter4Result(activity: Activity, symbol: String?, showSymbol: String = "", selectAddress: String = "") {
            val intent = Intent(activity, WithdrawAddressActivity::class.java)
            intent.putExtra(SYMBOL, symbol)
            intent.putExtra(SHOWSYMBOL, showSymbol)
            intent.putExtra(SELECT_ADDRESS, selectAddress)
            activity.startActivityForResult(intent, REQUEST_CODE_ADDRESS)
        }
    }


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_withdraw_address)
        context = this
        symbol = intent.getStringExtra(SYMBOL) ?: ""
        showSymbol = intent.getStringExtra(SHOWSYMBOL) ?: ""
        selectAddress = intent.getStringExtra(SELECT_ADDRESS) ?: ""
        //https://jira.dw2nn.com/browse/CUSTOMER-29993
        val titleSymbol = if("".equals(symbol)) showSymbol else symbol
        title_layout?.setContentTitle(titleSymbol + LanguageUtil.getString(this, "common_text_address"))
        initClickListener()
    }

    override fun onResume() {
        super.onResume()
        if (UserDataService.getInstance().isLogined) {
            getAddressList(symbol)
        }

        initViews()
    }


    private fun initViews() {
        adapter = WithdrawAddressAdapter(list)
        adapter?.setAddress(selectAddress)
        rv_address?.layoutManager = LinearLayoutManager(this)
        adapter.setEmptyView(EmptyForAdapterView(context ?: return))
        rv_address?.adapter = adapter

        /**
         *Delete Address
         */
        adapter.setOnItemLongClickListener { adapter, view, position ->

            var dialog:CpTDialog? = null
            KKDialogUtils.showCommonDialog(
                this,
                LanguageUtil.getString(this, "common_text_confirmDelete"),
                LanguageUtil.getString(this, "common_text_tip"),
                object : KKDialogUtils.DialogDoubleBottomListener {
                    override fun sendConfirm() {
                        dialog = NewDialogUtils.createNewVersionSecurityDialog(
                            this@WithdrawAddressActivity,
                            VerifyRule2(),
                            AppConstant.DEL_WITHDRAW_ADDRESS,
                            listener = object : NewDialogUtils.DialogVerifiactionListener{
                                override fun returnCode(
                                    phone: String?,
                                    mail: String?,
                                    googleCode: String?
                                ) {}

                                override fun returnCode(
                                    phone: String,
                                    mail: String,
                                    googleCode: String,
                                    capitalPwd: String,
                                    loginPwd: String
                                ) {
                                    delAddress(dialog,position,phone,mail,googleCode)
                                }

                            }
                        )
                    }
                    override fun sendCancel() {}
                },
                confrimTitle = LanguageUtil.getString(this, "common_text_btnConfirm"),
                cancelTitle = LanguageUtil.getString(this, "common_text_btnCancel"),
                isShowCancel = true,
                style = 3
            )


            true
        }

        /**
         *Click on the address
         */
        adapter.setOnItemClickListener { adapter, view, position ->
            val intent = Intent()
            intent.putExtra(OBJECT_ADDRESS, list[position])
            setResult(Activity.RESULT_OK, intent)
            finish()
        }
    }

    var onclickItem = false

    private fun initClickListener() {
        /**
         *Add Address
         */
        cbt_add_address?.isEnable(true)
        cbt_add_address.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                NewVersionAddAddressActivity.enter2(this@WithdrawAddressActivity, symbol, showSymbol)
            }
        }
    }

    private fun delAddress(dialog:CpTDialog?,position:Int,smsAuthCode:String,emailCode:String,googleCode:String){
        /**
         *If there is no Google or Mobile, do not verify
         */
        HttpClient.instance.delWithdrawAddress(list[position].id.toString(),smsAuthCode,emailCode,googleCode)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(object : NetObserver<Any>() {
                override fun onHandleSuccess(t: Any?) {
                    dialog?.dismiss()
                    list.removeAt(position)
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@WithdrawAddressActivity, "address_tip_deleteSuccess"), isSuc = true)
                    adapter.removeAt(position)
                    adapter.notifyItemRemoved(position)
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@WithdrawAddressActivity, "address_tip_deleteSuccess"), isSuc = true)


                }

                override fun onHandleError(code: Int, msg: String?) {
                    super.onHandleError(code, msg)

                    DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)


                }

            })
    }


    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {

        if (keyCode == KeyEvent.KEYCODE_BACK) {
            if (onclickItem) {
                val intent = Intent()
                setResult(Activity.RESULT_OK, intent)
                finish()
            }
        }

        return super.onKeyDown(keyCode, event)
    }


    /**
     *Get Address List
     *Return all data when @ showSymbol is empty
     */
    private fun getAddressList(symbol: String = "") {
        HttpClient.instance.getAddressList(symbol)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<AddressBean>() {
                    override fun onHandleSuccess(t: AddressBean?) {

                        if (null != t?.addressList) {
                            list = ArrayList(t?.addressList)
                        }
                        adapter.setList(list)
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)

                    }

                })
    }

    var tDialog:  CpTDialog? = null

    /**
     *Display the dialog for secondary validation
     *
     *12- Modify Digital Currency Address
     *@param Address ID
     *Location deleted by @param
     *
     */
    fun showVerifyDialog(id: String, position: Int) {

        tDialog = NewDialogUtils.showSecondDialog(this@WithdrawAddressActivity, AppConstant.CHANGE_WITHDRAW_ADDRESS, object : NewDialogUtils.DialogSecondListener {
            override fun returnCode(phone: String?, mail: String?, googleCode: String?, pwd: String?) {
                HttpClient.instance.delWithdrawAddress(id, smsCode = phone!!, googleCode = googleCode!!)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(object : NetObserver<Any>() {
                            override fun onHandleSuccess(t: Any?) {
                                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@WithdrawAddressActivity, "address_tip_deleteSuccess"), isSuc = true)
                                
                                adapter.remove(position)
                                adapter.notifyItemRemoved(position)
                                tDialog?.dismiss()
                                onclickItem = true
                            }

                            override fun onHandleError(code: Int, msg: String?) {
                                super.onHandleError(code, msg)
                                DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)

                                tDialog?.dismiss()

                                
                            }

                        })
            }
        }, loginPwdShow = false)
    }

}
