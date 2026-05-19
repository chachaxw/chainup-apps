package com.yjkj.chainup.new_version.activity.personalCenter

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.kit.utils.InputPatternFilter
import com.jaeger.library.StatusBarUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.bean.CountryInfo
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.new_version.activity.NewBaseActivity
import com.yjkj.chainup.new_version.activity.SelectAreaActivity
import com.yjkj.chainup.new_version.activity.TitleShowListener
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.new_version.view.PwdSettingView
import com.yjkj.chainup.new_version.view.TextViewAddEditTextView
import kotlinx.android.synthetic.main.activity_real_name_certification.cet_view
import kotlinx.android.synthetic.main.activity_real_name_certification.cub_next
import kotlinx.android.synthetic.main.activity_real_name_certification.pws_areaCountry_type_view
import kotlinx.android.synthetic.main.activity_real_name_certification.pws_certificate_type_view
import kotlinx.android.synthetic.main.activity_real_name_certification.tet_firstname
import kotlinx.android.synthetic.main.activity_real_name_certification.tet_id_number
import kotlinx.android.synthetic.main.activity_real_name_certification.tet_name
import kotlinx.android.synthetic.main.activity_real_name_certification.tet_surname
import kotlinx.android.synthetic.main.activity_real_name_certification.tv_certificate_type_title
import kotlinx.android.synthetic.main.activity_real_name_certification.tv_countries_title
import kotlinx.android.synthetic.main.activity_real_name_certification.tv_prompt
import kotlinx.android.synthetic.main.activity_real_name_certification.tv_prompt_title
import kotlinx.android.synthetic.main.activity_real_name_certification.v_head
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import java.util.Locale

/**
 * @Author lianshangljl
 * @Date 2023-08-01-14:30
 * @Email buptjinlong@163.com
 *@description: Select a country for the real name authentication of the new version
 */

class RealNameCertificationChooseCountriesActivity : NewBaseActivity() {

    private var pattern = "[`~!@#$%^&*()+=|{}':;',\\[\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]"
    /**
     *You need to transfer the country code and phone area code here
     */
    var areaInfo: String = ""
    var areaCode: String = ""

    /**
     *Country
     */
    var areaCountry: String = ""
    /**
     *ID number
     */
    var certNum = ""
    /**
     *Name
     */
    var realName = ""
    /**
     *Name
     */
    var surname = ""
    /**
     *Last Name
     */
    var fristName = ""

    /**
     *Document type
     *Default: ID card
     */
    var credentials_type: Int = RealNameCertificaionDownloadImgActivity.IDCARD

    companion object {
        fun enter(context: Context, areaNum: String, areaCountry: String, areaCode: String) {
            var intent = Intent()
            intent.setClass(context, RealNameCertificationChooseCountriesActivity::class.java)
            intent.putExtra(ParamConstant.AREA_NUMBER, areaNum)
            intent.putExtra(ParamConstant.AREA_COUNTRY, areaCountry)
            intent.putExtra(ParamConstant.AREA_CODE, areaCode)
            context.startActivity(intent)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_real_name_certification)
        StatusBarUtil.setColor(this, ContextCompat.getColor(this,R.color.bg_card_color), 0)
        if (!EventBus.getDefault().isRegistered(this)) {
            EventBus.getDefault().register(this)
        }

        cub_next?.isEnable(false)
        getData()
        initView()
        setOnclick()
        v_head?.setContentTitle(LanguageUtil.getString(this,"kyc_page_name"))
        tv_countries_title?.text = LanguageUtil.getString(this,"personal_text_country")
        tv_certificate_type_title?.text = LanguageUtil.getString(this,"kyc_text_certificateType")
        tv_prompt_title?.text = LanguageUtil.getString(this,"common_text_tip")
        tv_prompt?.text = LanguageUtil.getString(this,"common_tip_safetyIdentityAuth")

        tet_firstname?.setTitle(LanguageUtil.getString(this,"kyc_text_givenName"))
        tet_firstname?.setEditText(LanguageUtil.getString(this,"kyc_text_givenName"))

        tet_surname?.setTitle(LanguageUtil.getString(this,"kyc_text_familyName"))
        tet_surname?.setEditText(LanguageUtil.getString(this,"kyc_text_familyName"))

        tet_name?.setTitle(LanguageUtil.getString(this,"kyc_text_name"))
        tet_name?.setEditText(LanguageUtil.getString(this,"common_tip_inputRealName"))

        tet_id_number?.setTitle(LanguageUtil.getString(this,"kyc_text_certificateNumber"))
        tet_id_number?.setEditText(LanguageUtil.getString(this,"personal_tip_inputIdnumber"))
        cub_next?.setBottomTextContent(LanguageUtil.getString(this,"common_action_next"))
    }

    fun getData() {
        areaInfo = intent?.getStringExtra(ParamConstant.AREA_NUMBER) ?: ""
        areaCode = intent?.getStringExtra(ParamConstant.AREA_CODE) ?: ""
        areaCountry = intent?.getStringExtra(ParamConstant.AREA_COUNTRY) ?: ""
        pws_certificate_type_view?.setEditText(LanguageUtil.getString(this,"kyc_text_passport"))
        pws_areaCountry_type_view?.setEditText(areaCountry)
        cet_view?.setText(areaCountry)
        cet_view?.isFocusable = false
        cet_view?.isFocusableInTouchMode = false
        if (areaInfo == "+86") {
            tet_firstname.visibility = View.GONE
            tet_surname.visibility = View.GONE
            tv_certificate_type_title.visibility = View.GONE
            pws_certificate_type_view.visibility = View.GONE
            tet_id_number.setTitle(LanguageUtil.getString(this,"kyc_text_idnumber"))
            credentials_type = RealNameCertificaionDownloadImgActivity.IDCARD
        } else {
            tet_name.visibility = View.GONE
            credentials_type = RealNameCertificaionDownloadImgActivity.PASSPORT
        }
    }


    var certificateDialog:  CpTDialog? = null

    var certificateItem = 0
    fun initView() {

        tet_firstname.getEditText().filters = arrayOf(InputPatternFilter(pattern))
        tet_surname.getEditText().filters = arrayOf(InputPatternFilter(pattern))
        tet_name.getEditText().filters = arrayOf(InputPatternFilter(pattern))
        tet_id_number.getEditText().filters = arrayOf(InputPatternFilter(pattern))
        /**
         *Document type
         */
        pws_certificate_type_view?.onTextListener = object : PwdSettingView.OnTextListener {
            override fun showText(text: String): String {

                return text
            }

            override fun returnItem(item: Int) {

            }

            override fun onclickImage() {
                certificateDialog = NewDialogUtils.showListDialogTx(this@RealNameCertificationChooseCountriesActivity, LanguageUtil.getString(this@RealNameCertificationChooseCountriesActivity, "kyc_text_certificateType"),arrayListOf(LanguageUtil.getString(this@RealNameCertificationChooseCountriesActivity,"kyc_text_passport"), LanguageUtil.getString(this@RealNameCertificationChooseCountriesActivity,"kyc_text_drivingLicense"), LanguageUtil.getString(this@RealNameCertificationChooseCountriesActivity,"kyc_text_otherLegal")), certificateItem, object : NewDialogUtils.DialogOnclickListener {
                    override fun clickItem(data: ArrayList<String>, item: Int) {
                        certificateItem = item
                        when (item) {
                            0 -> {
                                credentials_type = RealNameCertificaionDownloadImgActivity.PASSPORT
                            }
                            1 -> {
                                credentials_type = RealNameCertificaionDownloadImgActivity.DRIVERLICENSE
                            }
                            2 -> {
                                credentials_type = RealNameCertificaionDownloadImgActivity.ORHERID
                            }
                        }
                        pws_certificate_type_view?.setEditText(data[item])
                        certificateDialog?.dismiss()
                    }

                    override fun onDismiss() {

                    }
                })
            }

        }
        tet_name?.listener = object : TextViewAddEditTextView.OnTextListener {
            override fun showText(text: String): String {
                realName = text
                if (areaInfo == "+86") {
                    if (realName.isNotEmpty() && certNum.isNotEmpty()) {
                        cub_next?.isEnable(true)
                    } else {
                        cub_next?.isEnable(false)
                    }
                }

                return text
            }

        }
        tet_id_number?.listener = object : TextViewAddEditTextView.OnTextListener {
            override fun showText(text: String): String {
                certNum = text
                if (areaInfo == "+86") {
                    if (realName.isNotEmpty() && certNum.isNotEmpty()) {
                        cub_next?.isEnable(true)
                    } else {
                        cub_next?.isEnable(false)
                    }
                } else {
                    if (certNum.isNotEmpty() && fristName.isNotEmpty() && surname.isNotEmpty()) {
                        cub_next?.isEnable(true)
                    } else {
                        cub_next?.isEnable(false)
                    }
                }
                return text

            }
        }
        tet_firstname?.listener = object : TextViewAddEditTextView.OnTextListener {
            override fun showText(text: String): String {
                fristName = text
                if (certNum.isNotEmpty() && fristName.isNotEmpty() && surname.isNotEmpty()) {
                    cub_next?.isEnable(true)
                } else {
                    cub_next?.isEnable(false)
                }
                return text
            }

        }
        tet_surname?.listener = object : TextViewAddEditTextView.OnTextListener {
            override fun showText(text: String): String {
                surname = text
                if (certNum.isNotEmpty() && fristName.isNotEmpty() && surname.isNotEmpty()) {
                    cub_next?.isEnable(true)
                } else {
                    cub_next?.isEnable(false)
                }
                return text
            }

        }

    }


    fun setOnclick() {
        pws_areaCountry_type_view?.onTextListener = object : PwdSettingView.OnTextListener {
            override fun showText(text: String): String {
                return text
            }

            override fun returnItem(item: Int) {

            }

            override fun onclickImage() {
                startActivity(Intent(this@RealNameCertificationChooseCountriesActivity, SelectAreaActivity::class.java))
            }

        }


        cub_next?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                if (areaInfo == "+86") {
                    RealNameCertificaionDownloadImgActivity.enter2(this@RealNameCertificationChooseCountriesActivity, areaInfo, certNum, realName, credentials_type, areaCode)
                } else {
                    RealNameCertificaionDownloadImgActivity.enter2(this@RealNameCertificationChooseCountriesActivity, areaInfo, certNum, surname, fristName, credentials_type, areaCode)
                }
                finish()
            }
        }

    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onEvent4Area(area: CountryInfo) {
        areaInfo = area.dialingCode
        areaCode = area.numberCode
        if (Locale.getDefault().language.contentEquals("zh")) {
            areaCountry = area.cnName
        } else {
            areaCountry = area.enName
        }


        if (Locale.getDefault().language.contentEquals("zh")) {
//            tv_select_area.text = area.dialingCode + " ${area.cnName}"
            pws_areaCountry_type_view?.setEditText("${area.cnName}")
        } else {
//            tv_select_area.text = area.dialingCode + " ${area.enName}"
            pws_areaCountry_type_view?.setEditText("${area.enName}")

        }
        tet_name.setText("")
        tet_firstname.setText("")
        tet_surname.setText("")
        tet_id_number.setText("")

        pws_certificate_type_view?.setEditText(LanguageUtil.getString(this,"kyc_text_passport"))
        pws_areaCountry_type_view?.setEditText(areaCountry)
        cet_view?.setText(areaCountry)
        cet_view?.isFocusable = false
        cet_view?.isFocusableInTouchMode = false
        if (areaInfo == "+86") {
            tet_name.visibility = View.VISIBLE
            tet_firstname.visibility = View.GONE
            tet_surname.visibility = View.GONE
            tv_certificate_type_title.visibility = View.GONE
            pws_certificate_type_view.visibility = View.GONE
            tet_id_number.setTitle(LanguageUtil.getString(this,"kyc_text_idnumber"))
            credentials_type = RealNameCertificaionDownloadImgActivity.IDCARD
        } else {
            tet_name.visibility = View.GONE
            tet_firstname.visibility = View.VISIBLE
            tet_surname.visibility = View.VISIBLE
            tv_certificate_type_title.visibility = View.VISIBLE
            pws_certificate_type_view.visibility = View.VISIBLE
            credentials_type = RealNameCertificaionDownloadImgActivity.PASSPORT
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (EventBus.getDefault().isRegistered(this)) {
            EventBus.getDefault().unregister(this)
        }
    }
}
