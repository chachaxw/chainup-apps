package com.yjkj.chainup.new_version.activity.login

import android.annotation.SuppressLint
import android.content.ContentProvider
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.InputType
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.alibaba.android.arouter.facade.annotation.Route
import com.bumptech.glide.request.RequestOptions
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.utils.setSafeListener
import com.chainup.contract.view.CpTabEntity
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.jaeger.library.StatusBarUtil
 import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.kit.views.PublicHeaderKit
import com.chainup.kit.views.base.BaseEditTextKit
import com.flyco.tablayout.listener.CustomTabEntity
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.bean.CountryInfo
import com.yjkj.chainup.bean.TartCaptchaV2Bean
import com.yjkj.chainup.bean.TitleBean
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.ActivityManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.LoginManager
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.net_new.rxjava.NModelDisposableObserver
import com.yjkj.chainup.new_version.activity.SelectAreaActivity
import com.yjkj.chainup.new_version.dialog.DialogUtil
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.new_version.view.Gt3GeeListener
import com.yjkj.chainup.util.*
import kotlinx.android.synthetic.main.activity_new_version_register.*
import kotlinx.android.synthetic.main.v_area_code.view.tv_area_code
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.json.JSONObject
import java.io.InputStream
import java.nio.charset.Charset
import java.util.*

/**
 * @Author lianshangljl
 * @Date 2023/3/11-3:33 PM
 * @Email buptjinlong@163.com
 *@description registration page
 */
@Route(path = "/login/newversionregisteractivity")
class NewVersionRegisterActivity : NBaseActivity() {
    override fun setContentView(): Int {
        return R.layout.activity_new_version_register
    }


    var isEmailRegister = false
    var accountContent = ""
    var country = "86"
    private val typeList = arrayListOf<CustomTabEntity>()
    private val areaView by lazy { LayoutInflater.from(this).inflate(R.layout.v_area_code,null) }


    private val verificationType by lazy { PublicInfoDataService.getInstance().getVerifyType(null) }


    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        windowTransitionBottomInBottomOut()
        ActivityManager.pushAct2Stack(this)
        var getMessage = PublicInfoDataService.getInstance().getUserRegType(null)
        setTextContent()
        initView()
        setOnClick()
        typeList.clear()
        var defSelectPosition = 0
        if (!TextUtils.isEmpty(getMessage)) {
            var json = JSONObject(getMessage)
            if (json.length() > 0) {
                var current = json.optJSONArray(JsonUtils.getLanguage())
                if (current != null && current.length() > 0) {

                    userRegTypeSetView(current[0] == 2)
                    if (current.length()==2){
                        defSelectPosition = if(current[0] == 2) 1 else 0
                        typeList.add(CpTabEntity(LanguageUtil.getString(this, "register_action_phone"),0,0))
                        typeList.add(CpTabEntity(LanguageUtil.getString(this, "register_action_mail"),0,0))
                    }else{
                        if (current[0] == 1){
                            defSelectPosition = 0
                            typeList.add(CpTabEntity(LanguageUtil.getString(this, "register_action_phone"),0,0))
                        }
                        if (current[0] == 2){
                            defSelectPosition = 0
                            typeList.add(CpTabEntity(LanguageUtil.getString(this, "register_action_mail"),0,0))
                        }
                    }

                }else{
                    //fix https://jira.dw2nn.com/browse/BIGFUTURES-3047
                    userRegTypeSetView(true)
                    defSelectPosition = 0
                    typeList.add(CpTabEntity(LanguageUtil.getString(this, "register_action_phone"),0,0))
                    typeList.add(CpTabEntity(LanguageUtil.getString(this, "register_action_mail"),0,0))
                }
            }
        }

        tab_register_type.setTabDataFont(typeList)
        tab_register_type.currentTab = defSelectPosition


        tab_register_type.setOnTabSelectListener(object : com.flyco.tablayout.listener.OnTabSelectListener {
            override fun onTabSelect(position: Int) {
                userRegTypeSetView(typeList[position].tabTitle.equals(LanguageUtil.getString(this@NewVersionRegisterActivity, "register_action_mail")))
            }

            override fun onTabReselect(position: Int) {

            }
        })
        val tabViewParent = (tab_register_type.getChildAt(0) as ViewGroup)
        if(tabViewParent.childCount>1){
            val rlView = tabViewParent.getChildAt(1)
            val lp = rlView.layoutParams as LinearLayout.LayoutParams
            lp.leftMargin = PublicSizeUtil.dp2px(this,8.0f)
            rlView.layoutParams = lp
        }

    }

    fun userRegTypeSetView(status: Boolean) {
        isEmailRegister = status
        if (isEmailRegister) {
            et_input.title = ""
            et_input.removeCustomActionBefore()
            et_input?.hint = LanguageUtil.getString(this, "safety_tip_inputMail")
            et_input?.title = LanguageUtil.getString(this, "register_text_mail")
            et_input.getRealEditText().inputType = InputType.TYPE_CLASS_TEXT
        } else {
            et_input.addCustomActionBefore(areaView)
            et_input?.hint = LanguageUtil.getString(this, "userinfo_tip_inputPhone")
            et_input?.title = LanguageUtil.getString(this, "register_text_phone")
            et_input.getRealEditText().inputType = InputType.TYPE_CLASS_NUMBER
        }
        et_input.getRealEditText().setText("")

    }

    fun setTextContent() {
        tv_existing_account?.text = LanguageUtil.getString(this, "register_tip_exsitUser")
        tv_go_login?.text = LanguageUtil.getString(this, "login_action_login")
        et_input?.hint = LanguageUtil.getString(this, "userinfo_tip_inputPhone")
        et_input?.title = LanguageUtil.getString(this, "register_text_phone")
        btn_next?.textContent = LanguageUtil.getString(this, "common_action_next")

    }

    var tDialog: CpTDialog? = null

    @SuppressLint("NewApi")
    fun setOnClick() {

        title_layout.listener = object: PublicHeaderKit.IOnBackClickListener {
            override fun onRightBtn(view: View) {
                super.onRightBtn(view)
                finish()
            }
        }

        et_input?.listener = object: BaseEditTextKit.OnKKBaseListener{
            override fun textChange(text: String) {
                accountContent = text
                if (accountContent.isNotEmpty() && (accountContent.length >= 5)) {
                    btn_next?.isEnable(true)
                } else {
                    btn_next?.isEnable(false)
                }
            }

        }
        areaView.setOnClickListener {
            startActivity(Intent(this@NewVersionRegisterActivity, SelectAreaActivity::class.java))
        }

        /**
         *Go log in
         */
        tv_go_login?.setOnClickListener {
            ArouterUtil.navigation("/login/NewVersionLoginActivity", null)
            finish()
        }
        tv_existing_account?.setOnClickListener {
            ArouterUtil.navigation("/login/NewVersionLoginActivity", null)
            finish()
        }


        /**
         *Click Next
         */

        btn_next?.setSafeListener {
            if (isEmailRegister) {
                if (!StringUtils.checkEmail(accountContent)) {
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "toast_email_error"), isSuc = false)
                    return@setSafeListener
                }
            } else {
                if (StringUtil.isNumericAndroidLenght(accountContent)) {
                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(mActivity, "userinfo_tip_inputPhone"), isSuc = false)
                    return@setSafeListener
                }
            }

            addDisposable(getMainModel().getTartCaptchaV2(
                consumer = object : NModelDisposableObserver<TartCaptchaV2Bean>(this,true){
                    override fun onResponseSuccess(data: TartCaptchaV2Bean) {
                        NewDialogUtils.createSafeVerifyDialog(this@NewVersionRegisterActivity,data){
                            reg4Step1(country, accountContent,it)
                        }
                    }
                }
            ))

        }


    }

    override fun initView() {
        et_input?.getRealEditText()?.inputType = InputType.TYPE_CLASS_PHONE
//        pws_view?.setvalidationStatus(false)
        et_input?.isFocusable = true
        et_input?.isFocusableInTouchMode = true
        btn_next?.isEnable(false)
        getAreaData()
        DialogUtil.showRegisterStatement(this)
        val logoBeanLogos = PublicInfoDataService.getInstance().getApp_logo_list_new(null)
        tv_welcome.setText(LanguageUtil.getString(this,"register_action_title"))
        if (logoBeanLogos != null && logoBeanLogos.size > 0) {
            var logo_black = logoBeanLogos[0]
            var logo_white = ""
            if (logoBeanLogos.size > 1) {
                logo_white = logoBeanLogos[1]
            }
            if (PublicInfoDataService.getInstance().themeMode == 0) {

                if (StringUtil.checkStr(logo_white)) {
                    tv_welcome.visibility = View.GONE
                    GlideUtils.loadImageHeader(this, logo_white, app_logo)
                }else{
                    tv_welcome.visibility = View.VISIBLE
                }
            } else {
                if (StringUtil.checkStr(logo_black)) {
                    tv_welcome.visibility = View.GONE
                    GlideUtils.loadImageHeader(this, logo_black, app_logo)
                }else{
                    tv_welcome.visibility = View.VISIBLE
                }
            }
        }
    }

    private fun handleData(data: JsonObject) {
        var allCountry = arrayListOf<CountryInfo>()
        var limtCountry = PublicInfoDataService.getInstance().getLimitCountryList(null)
        if (data.get("countryList").isJsonArray) {
            val countryData = JsonUtils.jsonToList(data.get("countryList").toString(), CountryInfo::class.java)
            
            countryData.forEach {
                if (!TextUtils.isEmpty(it.dialingCode)) {
                    allCountry.add(it)
                }
            }
            for (bean in limtCountry) {
                for (country in allCountry) {
                    if (country.numberCode == bean) {
                        allCountry.remove(country)
                        break
                    }
                }
            }
            setPwsView(allCountry[0])
            var defaultCode = PublicInfoDataService.getInstance().getDefaultCountryCodeReal(null);
            if (TextUtils.isEmpty(defaultCode)) {
                selectCountry(allCountry)
            } else {
                allCountry.forEach {
                    if (it.numberCode == defaultCode) {
                        setPwsView(it)
                        return
                    }
                }
                selectCountry(allCountry)
            }
        }
    }

    fun selectCountry(allCountry: ArrayList<CountryInfo>) {
        allCountry.forEach {
            if (it.dialingCode == PublicInfoDataService.getInstance().getDefaultCountryCode(null)) {
                setPwsView(it)
                return@forEach
            }
        }
    }

    fun setPwsView(it: CountryInfo) {
        runOnUiThread {
            if (Locale.getDefault().language.contentEquals("zh")) {
                areaView.tv_area_code.setText(it.cnName + " " + it.dialingCode)
            } else {
                areaView.tv_area_code.setText(it.enName + " " + it.dialingCode)
            }
            country = it.dialingCode
            LoginManager.getInstance().loginAreaCodeCache = country
        }

    }


    private fun getAreaData() {
        val stream: InputStream = assets.open("area.json")
        val size = stream.available()
        val byteArray = ByteArray(size)
        stream.read(byteArray)
        stream.close()
        val json: String = String(byteArray, Charset.defaultCharset())
        val jsonObject = JsonParser().parse(json).asJsonObject
        handleData(jsonObject)
        

    }


    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onEvent4Area(area: CountryInfo) {
        country = area.dialingCode
        LoginManager.getInstance().loginAreaCodeCache = area.dialingCode
        if (Locale.getDefault().language.contentEquals("zh")) {
            areaView.tv_area_code.setText(area.cnName + " " + area.dialingCode)
        } else {
            areaView.tv_area_code.setText(area.enName + " " + area.dialingCode)
        }

    }


    /**
     *Register Step 1
     */
    private fun reg4Step1(country: String, mobile: String,safeVerifyMap:Map<String,String>) {
        addDisposable(getMainModel().reg4Step1(country = country,
                mobile = mobile,
                verificationType = verificationType,
                safeVerifyDataMap = safeVerifyMap,
                consumer = object : NDisposableObserver(mActivity, false) {
            override fun onResponseSuccess(jsonObject: JSONObject) {
                if (isEmailRegister) {
                    var bundle = Bundle()
                    bundle.putString("send_account", accountContent)
                    bundle.putString("send_token", "")
                    bundle.putString("send_countryCode", country)
                    bundle.putInt("send_position", NewPhoneVerificationActivity.EMAIL_VERIFY)
                    bundle.putInt("send_islogin", 1)
                    ArouterUtil.greenChannel("/login/newphoneverificationactivity", bundle)
                } else {
                    var bundle = Bundle()
                    bundle.putString("send_account", accountContent)
                    bundle.putString("send_token", "")
                    bundle.putString("send_countryCode", country)
                    bundle.putInt("send_position", NewPhoneVerificationActivity.MOBiLE_VERIFY)
                    bundle.putInt("send_islogin", 1)
                    ArouterUtil.greenChannel("/login/newphoneverificationactivity", bundle)
                }
            }

            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                if (code == 10023 || code == 10013) {
                    NewDialogUtils.showDialog(this@NewVersionRegisterActivity, LanguageUtil.getString(this@NewVersionRegisterActivity, "account_has_benn_registered_tip"), false, object : NewDialogUtils.DialogBottomListener {
                        override fun sendConfirm() {
                            ArouterUtil.navigation("/login/NewVersionLoginActivity", null)
                            finish()
                        }
                    }, getLineText("common_text_tip"), getLineText("login_action_login"), getLineText("cancel"))
                } else {
                    NToastUtil.showTopToastNet(mActivity, false, msg)
                }
            }
        }))
    }

    class BuffAdapter(layoutResId: Int, data: MutableList<TitleBean>) :
            BaseQuickAdapter<TitleBean, BaseViewHolder>(layoutResId, data) {
        var selectIndex = 0

        @SuppressLint("NewApi")
        override fun convert(helper: BaseViewHolder, item: TitleBean) {
            if (selectIndex == helper.adapterPosition) {
                helper.setTextColor(R.id.title, ContextCompat.getColor(context, R.color.text_color))
            } else {
                helper.setTextColor(R.id.title, ContextCompat.getColor(context, R.color.normal_text_color))
            }
            helper.setText(R.id.title, item.titleName)
            helper.getView<TextView>(R.id.title).setTextSize(if (item.isSelect) 28f else 16f)
        }
    }
}
