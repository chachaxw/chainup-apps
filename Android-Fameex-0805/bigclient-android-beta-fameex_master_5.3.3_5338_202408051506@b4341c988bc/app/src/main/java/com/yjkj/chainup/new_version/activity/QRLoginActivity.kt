package com.yjkj.chainup.new_version.activity

import android.os.Bundle
import com.alibaba.android.arouter.facade.annotation.Autowired
import com.alibaba.android.arouter.facade.annotation.Route
import com.chainup.kit.utils.ToastUtils
import com.yjkj.chainup.R
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.new_version.bean.QRInfo
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.util.DisplayUtil
import com.yjkj.chainup.util.tr
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_qrlogin.*

@Route(path = RoutePath.QRLoginActivity)
class QRLoginActivity : NewBaseActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_qrlogin)
        ArouterUtil.inject(this)
        if(!LoginManager.checkLogin(this,true)){
            finish()
        }

        initView()
    }


    @JvmField
    @Autowired(name = ParamConstant.QRCODE_MSG)
    var qrCode = ""

    @JvmField
    @Autowired(name = ParamConstant.QRCODE_LOGIN_IP)
    var ip = ""

    @JvmField
    @Autowired(name = ParamConstant.QRCODE_LOGIN_equipment)
    var equipment = ""


    fun initView() {
        tv_ip?.setContentTextInterval(ip)
        tv_device?.setContentTextInterval(equipment)
        ic_close?.setOnClickListener {
            finish()
        }
        login_cancal?.setOnClickListener {
            finish()
        }
        tv_scan_title.text = "login_scan_title".tr(this)
        tv_scan_desc.text = "login_scan_desc".tr(this)
        login_confirm.textContent = "login_scan_confirm".tr(this)
        login_cancal.text = "login_scan_cancel".tr(this)
        tv_ip.setTitleContent(LanguageUtil.getString(this,"login_scan_ipTitle"))
        tv_device.setTitleContent(LanguageUtil.getString(this,"login_scan_equipment"))
        login_confirm?.isEnable(true)
        login_confirm?.setOnClickListener {
            getHelpCenter()
        }
    }


    private fun getHelpCenter() {
        showProgressDialog()
        HttpClient.instance.getPcLogin(qrCode)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(object : NetObserver<Any>() {
                override fun onHandleSuccess(t: Any?) {
                    cancelProgressDialog()
                    finish()
                }

                override fun onHandleError(code: Int, msg: String?) {
                    super.onHandleError(code, msg)
                    cancelProgressDialog()
                    DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                    finish()
                }
            })
    }
}
