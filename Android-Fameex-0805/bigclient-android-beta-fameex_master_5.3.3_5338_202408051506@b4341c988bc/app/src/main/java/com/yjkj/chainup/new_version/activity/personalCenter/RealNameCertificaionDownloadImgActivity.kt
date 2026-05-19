package com.yjkj.chainup.new_version.activity.personalCenter

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.text.Html
import android.text.TextUtils
import android.util.Log
import android.view.View
import androidx.core.content.ContextCompat
import com.bumptech.glide.request.RequestOptions
import com.google.gson.JsonObject
import com.tbruyelle.rxpermissions2.RxPermissions
 import com.chainup.contract.view.dialog.CpTDialog
import com.jaeger.library.StatusBarUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.new_version.activity.NewBaseActivity
import com.yjkj.chainup.new_version.activity.TitleShowListener
import com.yjkj.chainup.new_version.bean.AccountCertificationBean
import com.yjkj.chainup.new_version.bean.AccountCertificationLanguageBean
import com.yjkj.chainup.new_version.bean.ImageTokenBean
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import com.yjkj.chainup.new_version.view.OnSaveSuccessListener
import com.yjkj.chainup.new_version.view.UploadHelper
import com.yjkj.chainup.util.*
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_real_name_certification_download_img.*
import org.json.JSONObject


/**
 * @Author lianshangljl
 * @Date 2023/4/24-9:49 AM
 * @Email buptjinlong@163.com
 *@description Real name authentication upload image
 */
class RealNameCertificaionDownloadImgActivity : NewBaseActivity() {
    /**
     *You need to pass the country number and country code here
     */
    var areaInfo: String = ""
    var areaCode: String = ""

    /**
     *Tools for taking photos
     */
    val imageTool: ImageTools by lazy { ImageTools(this) }

    /**
     *ID number
     */
    var certNum = ""

    /**
     *Photo Location
     */
    var curIndex = FIRST_INDEX

    /**
     *Name
     */
    var realName = ""

    /**
     *Last Name (Non Chinese)
     */
    var fristName = ""

    /**
     *First name (non Chinese)
     */
    var surName = ""


    var firstImgPath = ""
    var secondImgPath = ""
    var thirdImgPath = ""

    val REQUEST_PERMISSIONS = arrayOf(android.Manifest.permission.READ_EXTERNAL_STORAGE, android.Manifest.permission.CAMERA, android.Manifest.permission.WRITE_EXTERNAL_STORAGE)

    companion object {
        const val IDCARD = 1 //ID card
        const val PASSPORT = 2 //Passport
        const val ORHERID = 3 //Other
        const val DRIVERLICENSE = 4 //Other

        /**
         *As a marker for photo position
         */
        const val FIRST_INDEX = 0 //First photo
        const val SECOND_INDEX = 1 //Second photo
        const val THIRD_INDEX = 2//Third photo

        const val CREDENTIALS_TYPE = 1//Documents
        const val PHOTO_TYPE = 2//Picture selection
        const val AREA_INFO = "area_info"//Country code+country code
        const val REAL_NAME = "real_name"//Name
        const val SURNAME_NAME = "surname_name"//Name
        const val FRISTNAME_NAME = "fristName_name"//Last Name
        const val CERT_NUM = "cert_num"//ID number
        const val CREDENTIALSTYPE = "credentials_type"//Last Name

        /**
         *China
         */
        fun enter2(context: Context, areaInfo: String, certNum: String, realName: String, credentials_type: Int, areaCode: String) {
            var intent = Intent()
            intent.setClass(context, RealNameCertificaionDownloadImgActivity::class.java)
            intent.putExtra(AREA_INFO, areaInfo)
            intent.putExtra(REAL_NAME, realName)
            intent.putExtra(SURNAME_NAME, "")
            intent.putExtra(FRISTNAME_NAME, "")
            intent.putExtra(ParamConstant.AREA_CODE, areaCode)
            intent.putExtra(CREDENTIALSTYPE, credentials_type)
            intent.putExtra(CERT_NUM, certNum)
            context.startActivity(intent)
        }

        /**
         *Non China
         */
        fun enter2(context: Context, areaInfo: String, certNum: String, surname: String, fristName: String, credentials_type: Int, areaCode: String) {
            var intent = Intent()
            intent.setClass(context, RealNameCertificaionDownloadImgActivity::class.java)
            intent.putExtra(AREA_INFO, areaInfo)
            intent.putExtra(REAL_NAME, "")
            intent.putExtra(SURNAME_NAME, surname)
            intent.putExtra(FRISTNAME_NAME, fristName)
            intent.putExtra(ParamConstant.AREA_CODE, areaCode)
            intent.putExtra(CREDENTIALSTYPE, credentials_type)
            intent.putExtra(CERT_NUM, certNum)
            context.startActivity(intent)
        }
    }

    /**
     *Document type
     *Default: ID card
     */
    var credentials_type: Int = IDCARD

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_real_name_certification_download_img)
        StatusBarUtil.setColor(this, ContextCompat.getColor(this,R.color.bg_card_color), 0)
//        if (PublicInfoDataService.getInstance().isInterfaceSwitchOpen(null)) {
//            AccountCertificationLanguage()
//        }
//        accountCertification()
        getData()
        if (PublicInfoDataService.getInstance().getUploadImgType(null) == "1") {
            getImageToken(operate_type = "1")
        }

        setOnclick()
        v_head?.setContentTitle(LanguageUtil.getString(this, "kyc_page_name"))
        tv_common_action_uploadFrontView?.text = LanguageUtil.getString(this, "common_action_uploadFrontView")
        tv_common_action_uploadBackView?.text = LanguageUtil.getString(this, "common_action_uploadBackView")
        tv_common_action_uplodadIdInHand?.text = LanguageUtil.getString(this, "common_action_uplodadIdInHand")
        tv_common_tip_uploadImgRequire?.text = LanguageUtil.getString(this, "common_tip_uploadImgRequire")+":"
        tv_kyc_explain_photoTip?.text = Html.fromHtml(LanguageUtil.getString(this, "kyc_explain_photoTip").replace("\\n","<br/>"))
        tv_4_content?.text = LanguageUtil.getString(this, "kyc_explain_lastTip")
        cub_next?.setBottomTextContent(LanguageUtil.getString(this, "common_action_next"))
        accountCertificationLanguage()
    }


    var imageMenuDialog: CpTDialog? = null
    fun showBottomMenu(index: Int) {
        curIndex = index
        imageMenuDialog = NewDialogUtils.showBottomListDialog(this@RealNameCertificaionDownloadImgActivity, arrayListOf(LanguageUtil.getString(this, "noun_camera_takephoto"), LanguageUtil.getString(this, "noun_camera_takeAlbum")), 0
                , object : NewDialogUtils.DialogOnclickListener {
            override fun clickItem(data: ArrayList<String>, item: Int) {
                when (item) {
                    0 -> {
                        openCamera()
                    }
                    1 -> {
                        val rxPermissions = RxPermissions(this@RealNameCertificaionDownloadImgActivity)
                        val observable = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            rxPermissions.request(android.Manifest.permission.READ_MEDIA_IMAGES)
                        }else{
                            rxPermissions.request(android.Manifest.permission.READ_EXTERNAL_STORAGE)
                        }
                        observable
                            .subscribe({ granted ->
                                if (granted) {
                                    imageTool?.openGallery("")
                                } else {
                                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@RealNameCertificaionDownloadImgActivity, "warn_storage_permission"), isSuc = false)
                                }
                            })
                    }
                }
                imageMenuDialog?.dismiss()
            }

                override fun onDismiss() {

                }

            })

    }

    fun getData() {
        if (intent != null) {
            areaInfo = intent.getStringExtra(AREA_INFO) ?: ""
            areaCode = intent.getStringExtra(ParamConstant.AREA_CODE) ?: ""
            certNum = intent.getStringExtra(CERT_NUM) ?: ""
            realName = intent.getStringExtra(REAL_NAME) ?: ""
            fristName = intent.getStringExtra(FRISTNAME_NAME) ?: ""
            surName = intent.getStringExtra(SURNAME_NAME) ?: ""
            credentials_type = intent.getIntExtra(CREDENTIALSTYPE, IDCARD)
        }
    }

    fun setOnclick() {
        cub_next?.isEnable(false)
        cub_next?.listener = object : CommonlyUsedButton.OnBottonListener {
            override fun bottonOnClick() {
                setAuthRealName()
            }
        }
        ll_frist_reset?.setOnClickListener {
            iv_frist_close?.visibility = View.GONE
            it .visibility= View.GONE
            iv_frist?.setImageResource(R.mipmap.personal_positiveupload)
            firstImgPath = ""
            showBottomMenu(FIRST_INDEX)
        }
        ll_second_reset?.setOnClickListener {
            iv_second_close?.visibility = View.GONE
          it .visibility= View.GONE
            iv_second?.setImageResource(R.mipmap.personal_uploadreverse)
            secondImgPath = ""
            showBottomMenu(SECOND_INDEX)
        }
        ll_third_reset?.setOnClickListener {
            iv_third_close?.visibility = View.GONE
            it .visibility= View.GONE
            iv_third?.setImageResource(R.mipmap.personal_uploadreverse)
            thirdImgPath = ""
            showBottomMenu(THIRD_INDEX)
        }

        iv_frist?.setOnClickListener {
            showBottomMenu(FIRST_INDEX)
        }
        iv_second?.setOnClickListener {
            showBottomMenu(SECOND_INDEX)
        }
        iv_third?.setOnClickListener {
            showBottomMenu(THIRD_INDEX)
        }

    }

    /**
     *Obtain camera permissions
     */
    private fun openCamera() {
        val rxPermissions: RxPermissions = RxPermissions(this)
        rxPermissions.request(android.Manifest.permission.CAMERA)
                .subscribe({ granted ->
                    if (granted) {

                        imageTool?.openCamera("")
                    } else {
                        DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@RealNameCertificaionDownloadImgActivity, "warn_camera_permission"), isSuc = false)
                    }

                })
    }

    /**
     *Real name authentication
     */
    fun setAuthRealName() {
        if (firstImgPath.isEmpty() || secondImgPath.isEmpty() || thirdImgPath.isEmpty()) {
            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "common_tip_pleaseUpload"), isSuc = false)
            return
        }
        HttpClient.instance.authVerify(countryCode = areaInfo, certType = credentials_type, certNum = certNum,
                userName = realName, firstPhoto = firstImgPath, secondPhoto = secondImgPath,
                thirdPhoto = thirdImgPath, familyName = surName, name = fristName, numberCode = areaCode)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<Any>() {
                    override fun onHandleSuccess(t: Any?) {
                        DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@RealNameCertificaionDownloadImgActivity, "toast_cert_summit_suc"), isSuc = true)

                        var json = UserDataService.getInstance().userData
                        json.put("authLevel", 0)
                        UserDataService.getInstance().saveData(json)
                        ArouterUtil.greenChannel(RoutePath.RealNameCertificaionSuccessActivity, null)
                        finish()
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)


                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)


                    }
                })
    }

    var imageTokenBean: ImageTokenBean = ImageTokenBean()

    fun loadingImage(path: String) {
        showProgressDialog()
        var uploadHelper = UploadHelper.uploadImage(path, imageTokenBean.AccessKeyId, imageTokenBean.AccessKeySecret, imageTokenBean.bucketName,
                imageTokenBean.ossUrl, imageTokenBean.SecurityToken, imageTokenBean.catalog)
        if (TextUtils.isEmpty(uploadHelper)) {
            isRefresh = true
            getImageToken(operate_type = "1", path = path)
            return
        } else if (uploadHelper == "error") {
            DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this, "toast_upload_pic_failed"), isSuc = false)
            return
        }


        /**
         *ID card
         */
        when (curIndex) {
            FIRST_INDEX -> {
                var options = RequestOptions().placeholder(R.drawable.personal_positiveupload)
                        .error(R.drawable.personal_positiveupload)

                firstImgPath = path
                if (uploadHelper.indexOf(imageTokenBean.catalog) > 0 && uploadHelper.indexOf(imageTokenBean.catalog) < uploadHelper.length) {
                    firstImgPath = uploadHelper.substring(uploadHelper.indexOf(imageTokenBean.catalog))
                }

                GlideUtils.load(this@RealNameCertificaionDownloadImgActivity, path, iv_frist, options)
//                iv_frist_close?.visibility = View.VISIBLE
                ll_frist_reset?.visibility = View.VISIBLE
                checkIsUpload()
            }
            SECOND_INDEX -> {
                var options = RequestOptions().placeholder(R.drawable.personal_uploadreverse)
                        .error(R.drawable.personal_uploadreverse)

                secondImgPath = path
                secondImgPath = uploadHelper.substring(uploadHelper.indexOf(imageTokenBean.catalog))
                GlideUtils.load(this@RealNameCertificaionDownloadImgActivity, path, iv_second, options)
//                iv_second_close?.visibility = View.VISIBLE
                ll_second_reset?.visibility = View.VISIBLE
                checkIsUpload()
            }
            THIRD_INDEX -> {
                var options = RequestOptions().placeholder(R.drawable.personal_handhelddocuments)
                        .error(R.drawable.personal_handhelddocuments)
                thirdImgPath = path
                thirdImgPath = uploadHelper.substring(uploadHelper.indexOf(imageTokenBean.catalog))
                GlideUtils.load(this@RealNameCertificaionDownloadImgActivity, path, iv_third, options)
//                iv_third_close?.visibility = View.VISIBLE
                ll_third_reset?.visibility = View.VISIBLE
                checkIsUpload()
            }
        }
        cancelProgressDialog()
    }

    private fun checkIsUpload() {
        if (firstImgPath.isEmpty() || secondImgPath.isEmpty() || thirdImgPath.isEmpty()) {
            cub_next?.isEnable(false)
        }else{
            cub_next?.isEnable(true)
        }
    }

    /**
     *Old interface for uploading photos
     */
    fun uploadImg(imageBase: String, index: Int, path: String) {
        showProgressDialog(LanguageUtil.getString(this, "pic_uploading"))
        HttpClient.instance.uploadImg(imgBase64 = imageBase)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<JsonObject>() {
                    override fun onHandleSuccess(t: JsonObject?) {
                        if (t == null) return
                        var json = JSONObject(t.toString())
                        cancelProgressDialog()


                        val baseImgUrl = json.getString("base_image_url")
                        val fileName = json.getString("filename")

                        var finalImageURL = ""

                        if (json.has("filenameStr")) {
                            val fileNameStr = json.getString("filenameStr")
                            if (TextUtils.isEmpty(fileNameStr)) {
                                if (TextUtils.isEmpty(fileName)) {
                                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@RealNameCertificaionDownloadImgActivity, "toast_upload_pic_failed"), isSuc = false)
                                    return
                                } else {
                                    finalImageURL = fileName
//                                    DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@RealNameCertificaionDownloadImgActivity, "toast_upload_pic_suc"), isSuc = true)

                                }
                            } else {
                                finalImageURL = fileNameStr
//                                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@RealNameCertificaionDownloadImgActivity, "toast_upload_pic_suc"), isSuc = true)

                            }

                        } else {
                            if (TextUtils.isEmpty(fileName)) {
                                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@RealNameCertificaionDownloadImgActivity, "toast_upload_pic_failed"), isSuc = false)
                                return
                            } else {
                                finalImageURL = fileName
//                                DisplayUtil.showSnackBar(window?.decorView, LanguageUtil.getString(this@RealNameCertificaionDownloadImgActivity, "toast_upload_pic_suc"), isSuc = true)
                            }

                        }



                        when (index) {
                            FIRST_INDEX -> {
                                firstImgPath = finalImageURL
                                var options = RequestOptions().placeholder(R.drawable.personal_positiveupload)
                                        .error(R.drawable.personal_positiveupload)
                                if (TextUtils.isEmpty(firstImgPath)) {
                                    GlideUtils.load(this@RealNameCertificaionDownloadImgActivity, "", iv_frist, options)
                                } else {
//                                    iv_frist_close.visibility = View.VISIBLE
                                    ll_frist_reset?.visibility = View.VISIBLE
                                    GlideUtils.load(this@RealNameCertificaionDownloadImgActivity, path, iv_frist, options)
                                }
checkIsUpload()
                            }
                            SECOND_INDEX -> {
                                secondImgPath = finalImageURL
                                var options = RequestOptions().placeholder(R.drawable.personal_uploadreverse)
                                        .error(R.drawable.personal_uploadreverse)
                                if (TextUtils.isEmpty(secondImgPath)) {
                                    GlideUtils.load(this@RealNameCertificaionDownloadImgActivity, "", iv_second, options)
                                } else {
                                    GlideUtils.load(this@RealNameCertificaionDownloadImgActivity, path, iv_second, options)
//                                    iv_second_close?.visibility = View.VISIBLE
                                    ll_second_reset?.visibility = View.VISIBLE
                                }
                                checkIsUpload()
                            }

                                    THIRD_INDEX -> {
                                thirdImgPath = finalImageURL
                                var options = RequestOptions().placeholder(R.drawable.personal_handhelddocuments)
                                        .error(R.drawable.personal_handhelddocuments)
                                if (TextUtils.isEmpty(thirdImgPath)) {
                                    GlideUtils.load(this@RealNameCertificaionDownloadImgActivity, "", iv_third, options)
                                } else {
                                    GlideUtils.load(this@RealNameCertificaionDownloadImgActivity, path, iv_third, options)
//                                    iv_third_close?.visibility = View.VISIBLE
                                    ll_third_reset?.visibility = View.VISIBLE
                                }
                                        checkIsUpload()
                            }
                        }

                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        cancelProgressDialog()

                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                        when (index) {
                            FIRST_INDEX -> {
                                firstImgPath = ""
                                if (TextUtils.isEmpty(firstImgPath)) {
                                    var options = RequestOptions().placeholder(R.drawable.personal_positiveupload)
                                            .error(R.drawable.personal_positiveupload)
                                    GlideUtils.load(this@RealNameCertificaionDownloadImgActivity, "", iv_frist, options)
                                }

                            }
                            SECOND_INDEX -> {
                                secondImgPath = ""

                                if (TextUtils.isEmpty(secondImgPath)) {
                                    var options = RequestOptions().placeholder(R.drawable.personal_uploadreverse)
                                            .error(R.drawable.personal_uploadreverse)
                                    GlideUtils.load(this@RealNameCertificaionDownloadImgActivity, "", iv_second, options)
                                }

                            }
                            THIRD_INDEX -> {
                                thirdImgPath = ""
                                if (TextUtils.isEmpty(thirdImgPath)) {
                                    var options = RequestOptions().placeholder(R.drawable.personal_handhelddocuments)
                                            .error(R.drawable.personal_handhelddocuments)
                                    GlideUtils.load(this@RealNameCertificaionDownloadImgActivity, "", iv_third, options)
                                }

                            }
                        }
                    }
                })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        imageTool?.onAcitvityResult(requestCode, resultCode, data
        ) { bitmap, path ->
            if (PublicInfoDataService.getInstance().getUploadImgType(null) == "1") {
                Utils.saveBitmap(path, object : OnSaveSuccessListener {
                    override fun onSuccess(path: String) {
                        if (path != null) {
                            loadingImage(path)
                        }
                    }
                })
            } else {

                /**
                 *ID card
                 */
                when (curIndex) {
                    FIRST_INDEX -> {
                        val bitmap2Base64 = imageTool?.bitmap2Base64(bitmap)
                        uploadImg(bitmap2Base64 ?: return@onAcitvityResult, FIRST_INDEX, path)
                    }
                    SECOND_INDEX -> {
                        val bitmap2Base64 = imageTool?.bitmap2Base64(bitmap)
                        uploadImg(bitmap2Base64 ?: return@onAcitvityResult, SECOND_INDEX, path)
                    }
                    THIRD_INDEX -> {

                        val bitmap2Base64 = imageTool?.bitmap2Base64(bitmap)
                        uploadImg(bitmap2Base64 ?: return@onAcitvityResult, THIRD_INDEX, path)
                    }
                }

            }

        }
    }

    var isRefresh = false

    /**
     *New interface to obtain token images
     */
    fun getImageToken(operate_type: String = "1", path: String = "") {
        showProgressDialog()
        HttpClient.instance.getImageToken(operate_type)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<ImageTokenBean>() {
                    override fun onHandleSuccess(t: ImageTokenBean?) {
                        cancelProgressDialog()
                        t ?: return
                        imageTokenBean = t
                        if (path.isNotEmpty()) {
                            if (isRefresh) {
                                isRefresh = false
                                loadingImage(path)
                            }
                        }
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        cancelProgressDialog()
                        DisplayUtil.showSnackBar(window?.decorView, msg, isSuc = false)
                    }
                })

    }


    /**
     * Obtain a real name authentication token
     *
     */
    fun accountCertificationLanguage() {
        HttpClient.instance.AccountCertificationLanguage()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : NetObserver<AccountCertificationLanguageBean>() {
                    override fun onHandleSuccess(t: AccountCertificationLanguageBean?) {
                        t ?: return
                        if (t.language.isNotEmpty()) {
                            tv_4_content.visibility = View.VISIBLE
                            tv_4_content?.text = "4.${t?.language}"
                        }
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                    }
                })
    }

}
