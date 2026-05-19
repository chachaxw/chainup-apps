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
import android.widget.TextView
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
import com.bumptech.glide.request.RequestOptions
 import com.chainup.contract.view.dialog.CpTDialog
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.DataManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.new_version.activity.CoinActivity
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.new_version.view.OnSaveSuccessListener
import com.yjkj.chainup.new_version.view.UploadHelper
import com.yjkj.chainup.util.*
import kotlinx.android.synthetic.main.activity_b2_crecharge.*
import org.json.JSONObject

/**
 *@description: Recharge (B2C)
 * @author Bertking
 * @Date 2023-10-23 AM
 *
 *TODO OSS has restrictions on uploading images
 */
@Route(path = RoutePath.B2CRechargeActivity)
class B2CRechargeActivity : NBaseActivity() {


    var symbol: String = PublicInfoDataService.getInstance().coinInfo4B2c

    var dialog:  CpTDialog? = null

    var imageUrl: String = ""
    var imageLocalPath: String = ""

    /*Do you need a transfer voucher*/
    var isTransferVoucher = false

    var isRefresh = false

    var imageTokenJSONObject = JSONObject()

    //Minimum recharge
    var depositMin = "0.0"

    var precision: Int = 2

    /**
     *Tools for taking photos
     */
    var imageTool: ImageTools? = null

    override fun setContentView() = R.layout.activity_b2_crecharge

    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        initView()
    }

    override fun onResume() {
        super.onResume()
//        if (PublicInfoDataService.getInstance().getUploadImgType(null) == "1") {
//            getImageToken(operate_type = "2")
//        }
        if (!TextUtils.isEmpty(et_amount?.textContent)) {
            btn_confirm?.isEnable(true)
        } else {
            btn_confirm?.isEnable(false)
        }

        getB2CAccount(symbol)
        fiatBankInfo(symbol)
    }


    override fun initView() {
        imageTool = ImageTools(mActivity)


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

        /*Recharge Record*/
        tv_recharge_record?.setOnClickListener {
            ArouterUtil.navigation(RoutePath.B2CRecordsActivity, Bundle().apply { putInt(ParamConstant.OPTION_TYPE, ParamConstant.RECHARGE) })
        }


        tv_amount_title?.text = symbol.toUpperCase() +  LanguageUtil.getString(mActivity,"b2c_text_rechargeAccount")

        /*Select Currency*/
        tv_choose_coin?.setOnClickListener {
            ArouterUtil.navigation4Result(RoutePath.SelectCoinActivity, Bundle().apply {
                putInt(ParamConstant.OPTION_TYPE, ParamConstant.RECHARGE)
                putBoolean(ParamConstant.COIN_FROM, false)
            }, mActivity, 321)
        }

        tv_coin?.text = symbol

        tv_remark_title?.setOnClickListener {
            NewDialogUtils.showSingleDialog(mActivity,  LanguageUtil.getString(mActivity,"b2c_text_transferNote"), object : NewDialogUtils.DialogBottomListener {
                override fun sendConfirm() {

                }

            }, "",  LanguageUtil.getString(mActivity,"alert_common_iknow"))
        }
        iv_copy_remark?.setOnClickListener {
            copy(tv_remark)
        }

        /*Transfer voucher*/
        tv_transfer_voucher?.setOnClickListener {
            NewDialogUtils.showSingleDialog(mActivity,  LanguageUtil.getString(mActivity,"b2c_text_transferPrompt"), object : NewDialogUtils.DialogBottomListener {
                override fun sendConfirm() {

                }

            }, "",  LanguageUtil.getString(mActivity,"alert_common_iknow"))
        }

        /**
         *Upload images
         */
        iv_upload_img?.setOnClickListener {
            showBottomMenu()
        }

        /*Recharge amount*/
        val precision = DataManager.getCoinByName(symbol)?.showPrecision ?: 4
        et_amount?.filters = arrayOf(DecimalDigitsInputFilter(precision))
        et_amount?.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(p0: Editable?) {
                if (!TextUtils.isEmpty(p0.toString())) {
                    btn_confirm?.isEnable(true)
                } else {
                    btn_confirm?.isEnable(false)
                }

            }

            override fun beforeTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {
            }

            override fun onTextChanged(p0: CharSequence?, p1: Int, p2: Int, p3: Int) {
            }

        })

        /*Single transaction limit*/
        tv_amount_tip?.text =  LanguageUtil.getString(mActivity,"b2c_text_singleNoLessthan").format(BigDecimalUtils.showNormal(depositMin))


        /*Recharge confirmation*/
        btn_confirm?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {

                if (BigDecimalUtils.compareTo(et_amount?.textContent, depositMin) < 0) {
                    NToastUtil.showTopToastNet(mActivity,false,  LanguageUtil.getString(mActivity,"b2c_recharge_min").format(BigDecimalUtils.showNormal(depositMin)))
                    return
                }

                if(isTransferVoucher){
                    if(TextUtils.isEmpty(imageUrl)){
                        NToastUtil.showTopToastNet(mActivity,false,  LanguageUtil.getString(mActivity,"b2c_text_addTransferCredentials"))
                        return
                    }
                }

                dialog = NewDialogUtils.confirmRecharge(mActivity, symbol, et_amount?.textContent
                        ?: "", imageLocalPath, object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        dialog?.dismiss()
                        recharge(symbol, imageUrl, et_amount?.textContent ?: "")
                    }
                })

            }
        }
    }


    private fun getParamValue(jsonObject: JSONObject?, param: String): String {
        return jsonObject?.optString(param) ?: ""
    }


    /**
     *New interface to obtain token images
     */
    private fun getImageToken(operate_type: String = "2", path: String = "") {
        addDisposable(getMainModel().getImageToken(operate_type = operate_type,
                consumer = object : NDisposableObserver(mActivity) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        imageTokenJSONObject = jsonObject.optJSONObject("data")
                        if (path.isNotEmpty()) {
                            if (isRefresh) {
                                isRefresh = false
                                uploadImage(path)
                            }
                        }
                    }
                }))

    }


    private fun uploadImage(path: String) {
        imageTokenJSONObject.run {
            val accessKeyId = optString("AccessKeyId")
            val accessKeySecret = optString("AccessKeySecret")
            val expiration = optString("Expiration")
            val securityToken = optString("SecurityToken")
            val catalog = optString("catalog")
            val ossUrl = optString("ossUrl")
            val bucketName = optString("bucketName")

            var uploadHelper = UploadHelper.uploadImage(path, accessKeyId, accessKeySecret, bucketName,
                    ossUrl, securityToken, catalog)
            if (TextUtils.isEmpty(uploadHelper)) {
                isRefresh = true
                getImageToken(operate_type = "2", path = path)
                return
            } else if (uploadHelper == "error") {
                DisplayUtil.showSnackBar(window?.decorView,  LanguageUtil.getString(mActivity,"toast_upload_pic_failed"), isSuc = false)
                return
            }

            val options = RequestOptions().placeholder(R.drawable.assets_addingpaymentmethod)
                    .error(R.drawable.assets_addingpaymentmethod)
            imageUrl = path
            imageUrl = uploadHelper.substring(uploadHelper.indexOf(catalog))
            GlideUtils.load(mActivity, path, iv_upload_img, options)
            iv_cancel?.visibility = View.VISIBLE

            if (!TextUtils.isEmpty(et_amount?.textContent)) {
                btn_confirm?.isEnable(true)
            } else {
                btn_confirm?.isEnable(false)
            }
        }
    }


    var imageMenuDialog: CpTDialog? = null
    private fun showBottomMenu() {
        imageMenuDialog = NewDialogUtils.showBottomListDialog(mActivity, arrayListOf( LanguageUtil.getString(mActivity,"noun_camera_takeAlbum"),  LanguageUtil.getString(mActivity,"noun_camera_takephoto")), 0
                , object : NewDialogUtils.DialogOnclickListener {
            override fun clickItem(data: ArrayList<String>, item: Int) {
                when (item) {
                    0 -> {
                        imageTool?.openGallery("")
                    }
                    1 -> {
                        imageTool?.openCamera("")

                    }
                }
                imageMenuDialog?.dismiss()
            }

                override fun onDismiss() {

                }

            })
    }


    /**
     *Rendering Bank Information
     */
    private fun renderBankInfo(jsonObject: JSONObject?) {
        isTransferVoucher = getParamValue(jsonObject, "isTransferVoucher") == "1"

        /*Opening bank*/
        tv_bank?.text = getParamValue(jsonObject, "bankName")
        /*Opening branch*/
        tv_bank_branch?.text = getParamValue(jsonObject, "bankSub")
        iv_copy_bank_branch?.setOnClickListener {
            copy(tv_bank_branch)
        }

        /*Bank account number*/
        tv_bank_account?.text = getParamValue(jsonObject, "cardNo")
        iv_copy_bank_account?.setOnClickListener {
            copy(tv_bank_account)
        }

        /*Payee*/
        tv_payee?.text = getParamValue(jsonObject, "name")
        iv_copy_payee?.setOnClickListener {
            copy(tv_payee)
        }


        /*Transfer remarks*/
        tv_remark?.text = getParamValue(jsonObject, "remark")


    }

    private fun copy(textView: TextView) {
        ClipboardUtil.copy(textView)
        DisplayUtil.showSnackBar(window?.decorView,  LanguageUtil.getString(mActivity,"common_tip_copySuccess"))
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == Activity.RESULT_OK) {
            when (requestCode) {
                /**Currency*/
                321 -> {
                    symbol = data?.getStringExtra(CoinActivity.SELECTED_COIN) ?: ""
                    PublicInfoDataService.getInstance().saveCoinInfo4B2C(symbol)
                    fiatBankInfo(symbol)
                }
            }
        }

        imageTool?.onAcitvityResult(requestCode, resultCode, data) { bitmap, path ->
            imageLocalPath = path
//            if (PublicInfoDataService.getInstance().getUploadImgType(null) == "1") {
//                Utils.saveBitmap(path, object : OnSaveSuccessListener {
//                    override fun onSuccess(path: String) {
//                            uploadImage(path)
//                    }
//                })
//            } else {
                /*Old interface uploading images*/
                val options = RequestOptions().placeholder(R.drawable.assets_addingpaymentmethod)
                        .error(R.drawable.assets_addingpaymentmethod)
                GlideUtils.load(this, path, iv_upload_img, options)
                val bitmap2Base64 = imageTool?.bitmap2Base64(bitmap)
                uploadImg(bitmap2Base64 ?: return@onAcitvityResult)

//            }

        }

    }

    /**
     *Recharge
     */
    fun recharge(symbol: String, transferVoucher: String, amount: String) {
        addDisposable(getMainModel().fiatDeposit(symbol = symbol,
                transferVoucher = transferVoucher,
                amount = amount,
                consumer = object : NDisposableObserver(mActivity) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        NToastUtil.showTopToastNet(mActivity,true,  LanguageUtil.getString(mActivity,"b2c_text_rechargeSuccess"))
                        et_amount?.textContent = ""
                        iv_upload_img?.setImageResource(R.drawable.assets_addingpaymentmethod)
                        iv_cancel?.visibility = View.GONE
                        finish()
                    }
                }))
    }

    /**
     *Platform's recharge bank information
     */
    private fun fiatBankInfo(symbol: String) {
        renderBankInfo(null)
        addDisposable(getMainModel().fiatBankInfo(symbol = symbol,
                consumer = object : NDisposableObserver(mActivity) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {
                        renderBankInfo(jsonObject.optJSONObject("data"))
                    }
                }))
    }


    private fun getB2CAccount(symbol: String) {
        addDisposable(getMainModel().fiatBalance(symbol = symbol,
                consumer = object : NDisposableObserver(mActivity) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {

                        val data = jsonObject.optJSONObject("data") ?: return
                        val depositTip = data?.optString("depositTip")
                        precision = data.optInt("showPrecision", 2)

                        tv_note?.text = depositTip
                        tv_notes_title?.visibility = if (TextUtils.isEmpty(depositTip)) View.INVISIBLE else View.VISIBLE

                        val jsonArray = data?.optJSONArray("allCoinMap")
                        if (jsonArray?.length() != 0) {
                            jsonArray?.optJSONObject(0)?.run {
                                tv_coin?.text = optString("symbol")

                                //Minimum recharge
                                depositMin =  optString("depositMin")
                                tv_amount_tip?.text =  LanguageUtil.getString(mActivity,"b2c_recharge_min").format(BigDecimalUtils.showNormal(depositMin)) + " $symbol"
                            }
                        }


                    }
                }))
    }


    /**
     *Old interface for uploading photos
     */
    fun uploadImg(imageBase: String) {
        addDisposable(getMainModel().uploadImg(imgBase64 = imageBase,
                consumer = object : NDisposableObserver(mActivity) {
                    override fun onResponseSuccess(jsonObject: JSONObject) {

                        val fileName = jsonObject.optJSONObject("data")?.optString("filename") ?: ""
                        if (jsonObject.has("filenameStr")) {
                            val fileNameStr = jsonObject.getString("filenameStr")
                            if (TextUtils.isEmpty(fileNameStr)) {
                                if (TextUtils.isEmpty(fileName)) {
                                    DisplayUtil.showSnackBar(window?.decorView,  LanguageUtil.getString(mActivity,"toast_upload_pic_failed"), isSuc = false)
                                    return
                                } else {
                                    imageUrl = fileName
                                    DisplayUtil.showSnackBar(window?.decorView,  LanguageUtil.getString(mActivity,"toast_upload_pic_suc"), isSuc = true)

                                }
                            } else {
                                imageUrl = fileNameStr
                                DisplayUtil.showSnackBar(window?.decorView,  LanguageUtil.getString(mActivity,"toast_upload_pic_suc"), isSuc = true)

                            }

                        } else {
                            if (TextUtils.isEmpty(fileName)) {
                                DisplayUtil.showSnackBar(window?.decorView,  LanguageUtil.getString(mActivity,"toast_upload_pic_failed"), isSuc = false)
                                return
                            } else {
                                imageUrl = fileName
                                DisplayUtil.showSnackBar(window?.decorView,  LanguageUtil.getString(mActivity,"toast_upload_pic_suc"), isSuc = true)
                            }

                        }

                        if (TextUtils.isEmpty(imageUrl)) {
                            iv_upload_img?.setImageResource(R.drawable.assets_addingpaymentmethod)
                        } else {
                            iv_cancel.visibility = View.VISIBLE
                        }

                        if (!TextUtils.isEmpty(et_amount?.textContent)) {
                            btn_confirm?.isEnable(true)
                        } else {
                            btn_confirm?.isEnable(false)
                        }
                    }
                }))
    }


}
