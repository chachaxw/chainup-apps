package com.yjkj.chainup.new_version.dialog

import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.content.DialogInterface
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.net.http.SslError
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.Editable
import android.text.Html
import android.text.SpannableString
import android.text.Spanned
import android.text.TextUtils
import android.text.TextWatcher
import android.text.method.ScrollingMovementMethod
import android.text.style.AbsoluteSizeSpan
import android.text.style.ForegroundColorSpan
import android.util.Log
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.view.animation.AnimationUtils
import android.view.inputmethod.InputMethodManager
import android.webkit.*
import android.widget.*
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AppCompatActivity
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.core.view.children
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.request.RequestOptions
import com.bumptech.glide.request.target.SimpleTarget
import com.bumptech.glide.request.transition.Transition
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.chainup.contract.adapter.CpBottomDialogAdapter
import com.chainup.contract.bean.CpTabInfo
import com.chainup.contract.utils.CpPreferenceManager
import com.chainup.contract.utils.CpShareToolUtil
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.contract.view.dialog.base.CpBindViewHolder
import com.chainup.contract.view.dialog.listener.OnCpBindViewListener
import com.chainup.kit.KKDialogUtils
import com.chainup.kit.dialog.KKTDialog
import com.chainup.kit.dialog.adapter.KKBottomCardListRvAdapter
import com.chainup.kit.dialog.adapter.KKItemCardEntity
import com.chainup.kit.dialog.base.KKBindViewHolder
import com.chainup.kit.dialog.security.KKSecurityRule
import com.chainup.kit.dimAmountValue
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.kit.views.KKButtonKit
import com.chainup.kit.views.KKEmptyViewKit
import com.github.promeg.pinyinhelper.Pinyin
import com.google.gson.JsonParser
import com.qmuiteam.qmui.layout.QMUIFrameLayout
import com.qmuiteam.qmui.util.QMUIDisplayHelper
import com.wx.wheelview.widget.WheelView
import com.yjkj.chainup.R
import com.yjkj.chainup.bean.CloudflareBean
import com.yjkj.chainup.bean.CountryInfo
import com.yjkj.chainup.bean.ScaleInfoBean
import com.yjkj.chainup.bean.TartCaptchaV2Bean
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.constant.WebTypeEnum
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.Contract2PublicInfoManager
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.manager.NCoinManager
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.new_version.adapter.AgentLevelAdapter
import com.yjkj.chainup.new_version.adapter.NewDialogAdapter
import com.yjkj.chainup.new_version.adapter.NewDialogAdapterTx
import com.yjkj.chainup.new_version.adapter.NewHomePageServiceAdapter
import com.yjkj.chainup.new_version.bean.CashFlowSceneBean
import com.yjkj.chainup.new_version.home.TAG_ADVERT
import com.yjkj.chainup.new_version.home.dialogType
import com.yjkj.chainup.new_version.redpackage.adapter.WheelViewAdapter
import com.yjkj.chainup.new_version.redpackage.bean.CreatePackageBean
import com.yjkj.chainup.new_version.redpackage.bean.RedPackageInitInfo
import com.yjkj.chainup.new_version.redpackage.bean.TempBean
import com.yjkj.chainup.new_version.view.*
import com.yjkj.chainup.util.*
import com.yjkj.chainup.wedegit.*
import com.yjkj.chainup.wedegit.item.GridSpacingItemDecoration
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import org.jetbrains.anko.*
import org.json.JSONArray
import org.json.JSONObject
import java.io.InputStream
import java.nio.charset.Charset
import java.util.*

/**
 * @Author lianshangljl
 * @Date 2023/3/8-11:59 AM
 * @Email buptjinlong@163.com
 * @description
 */
class NewDialogUtils {

    interface DialogOnclickListener {
        /**
         *Bottom returns position
         *
         *TODO should use Any
         */
        fun clickItem(data: ArrayList<String>, item: Int)

        fun onDismiss()
    }


    interface DialogOnItemClickListener {
        fun clickItem(position: Int)
    }

    interface DialogOnSigningItemClickListener {
        fun clickItem(position: Int, text: String)
        fun onDismiss()
    }

    interface DialogBottomListener {
        /**
         *Prompt dialog
         */
        fun sendConfirm()
        fun sendConfirm(view:View){}
    }

    interface DialogTransferBottomListener {
        /**
         *Prompt dialog
         */
        fun sendConfirm()

        /**
         *Hide
         */
        fun showCancel()
    }

    interface DialogWebViewShareListener {

        fun webviewSaveImage(view: View)

        fun confirmShare(view: View)
    }


    interface DialogValidationGoogleListener {
        fun returnCode(googleCode: String?)

    }

    interface DialogSharePostersListener {
        fun saveIamgePosters(imageUrl: String, shareView: ImageView)
        fun saveIamgePostersNew(imageUrl: String)
    }


    interface DialogVerifiactionListener {
        /**
         *Security verification return verification code
         */
        fun returnCode(phone: String?, mail: String?, googleCode: String?)
        fun returnCode(phone: String, mail: String, googleCode: String,capitalPwd:String,loginPwd:String){}
    }

    interface DialogDismissListener {
        /**
         *Security verification return verification code
         */
        fun onDismiss()
    }

    interface DialogVerifiactionNewListener {
        fun returnCode(phone: String?, mail: String?, phoneCode: String?, mailCode: String?, googleCode: String?, certifcateNumber: String?)
    }

    interface DialogReturnChangeEmail {
        fun returnCode(phone: String?, oldEmail: String?, newEmail: String?, googleCode: String?)
        fun returnCodeWithView(phone:Pair<String?,IEditTextUiError>,oldEmail:Pair<String?,IEditTextUiError>, newEmail: Pair<String?,IEditTextUiError>, googleCode:Pair<String?,IEditTextUiError>){

        }
    }

    interface DialogSecondListener {
        /**
         *Security verification return verification code
         */
        fun returnCode(phone: String?, mail: String?, googleCode: String?, pwd: String?)
    }

    interface DialogCertificationSecondListener {
        /**
         *Security verification return verification code
         */
        fun returnCode(phone: String?, mail: String?, googleCode: String?, pwd: String?)

        fun cancelBtn()
    }

    interface DialogBottomAloneListener {

        fun returnContent(content: String)
    }

    interface DialogBottomPwdListener {

        fun returnContent(content: String)
        fun returnCancel()
    }

    interface DialogBottomCoinListener {
        /**
         *Security verification return verification code
         */
        fun returnTypeCode(phone: String?, mail: String?)

        fun onDismiss()
    }


    companion object {

        /**
         *String bottom dialog
         *
         */
        fun showListDialog(
            context: Context,
            list: ArrayList<String>,
            position: Int,
            listener: DialogOnclickListener
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_new_dialog)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setText(
                        R.id.tv_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    var adapter = NewDialogAdapter(list, position)
                    adapter?.setList(list.size)
                    var listView = viewHolder?.getView<RecyclerView>(R.id.recycler_view)
                    listView?.layoutManager = LinearLayoutManager(context)
                    listView?.adapter = adapter
                    listView?.setHasFixedSize(true)
                    adapter.setOnItemClickListener { adapter, view, position ->
                        listener.clickItem(list, position)
                    }
                }
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .setOnDismissListener {
                    listener.onDismiss()
                }
                .create()
                .show()
        }

        fun showListDialogTx(
            context: Context,
            title: String,
            list: ArrayList<String>,
            position: Int,
            listener: DialogOnclickListener
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_new_dialog_tx)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setText(R.id.tv_title, title)
                    viewHolder?.setText(
                        R.id.tv_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    var adapter = NewDialogAdapterTx(list, position)
                    adapter?.setList(list.size)
                    var listView = viewHolder?.getView<RecyclerView>(R.id.recycler_view)
                    listView?.layoutManager = LinearLayoutManager(context)
                    listView?.adapter = adapter
                    listView?.setHasFixedSize(true)
                    adapter.setOnItemClickListener { adapter, view, position ->
                        listener.clickItem(list, position)
                    }
                }
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        /**
         *String bottom dialog
         *
         */
        fun showNewListDialog(
            context: Context,
            list: ArrayList<CpTabInfo>,
            position: Int,
            listener: DialogOnItemClickListener
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_new_dialog)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setText(
                        R.id.tv_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    var adapter = CpBottomDialogAdapter(list, position)
                    var listView = viewHolder?.getView<RecyclerView>(R.id.recycler_view)
                    listView?.layoutManager = LinearLayoutManager(context)
                    listView?.adapter = adapter
                    listView?.setHasFixedSize(true)
                    adapter.setOnItemClickListener { adapter, view, position ->
                        listener.clickItem(position)
                    }
                }
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        /**
         *Single button new dialog
         */

        fun showNewsingleDialog2(
            context: Context,
            content: String,
            listener: DialogBottomListener?,
            cancelTitle: String = "",
            returnListener: Boolean = false
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_new_normal_dialog2)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    if (!TextUtils.isEmpty(cancelTitle)) {
                        viewHolder?.setText(R.id.tv_confirm_btn, cancelTitle)
                    } else {
                        viewHolder?.setText(
                            R.id.tv_confirm_btn,
                            LanguageUtil.getString(context, "common_text_btnConfirm")
                        )
                    }
                    viewHolder?.setText(R.id.tv_content, content)

                }
                .addOnClickListener(R.id.tv_confirm_btn)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_confirm_btn -> {
                            if (listener != null && returnListener) {
                                listener.sendConfirm()
                            }
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        /**
         *Single button new dialog
         */

        fun showNewsingleDialog(
            context: Context,
            content: String,
            listener: DialogBottomListener?,
            title: String = "",
            cancelTitle: String = "",
            returnListener: Boolean = false
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_new_normal_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    if (!TextUtils.isEmpty(title)) {
                        viewHolder?.setGone(R.id.tv_title, true)
                        viewHolder?.setText(R.id.tv_title, title)
                    } else {
                        viewHolder?.setTextColor(
                            R.id.tv_content,
                            ContextCompat.getColor(context, R.color.text_color)
                        )
                    }

                    if (!TextUtils.isEmpty(cancelTitle)) {
                        viewHolder?.setText(R.id.tv_confirm_btn, cancelTitle)
                    } else {
                        viewHolder?.setText(
                            R.id.tv_confirm_btn,
                            LanguageUtil.getString(context, "common_text_btnConfirm")
                        )
                    }
                    viewHolder?.setText(R.id.tv_content, content)

                }
                .addOnClickListener(R.id.tv_confirm_btn)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_confirm_btn -> {
                            if (listener != null && returnListener) {
                                listener.sendConfirm()
                            }
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        /**
         *Two Button New Dialogs
         */
        fun showNewDoubleDialog(
            context: Context,
            content: String,
            listener: DialogBottomListener?,
            title: String = "",
            cancelTitle: String = "",
            confrimTitle: String = "",
            isFormatHtml: Boolean = true
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_new_double_normal_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    if (!TextUtils.isEmpty(title)) {
                        viewHolder?.setGone(R.id.tv_title, true)
                        viewHolder?.setText(R.id.tv_title, title)
                    } else {
//                            viewHolder?.getView<TextView>(R.id.tv_content)?.textSize = context.resources.getDimension(R.dimen.sp_16)
                        viewHolder?.setTextColor(
                            R.id.tv_content,
                            ContextCompat.getColor(context, R.color.text_color)
                        )

                    }
                    viewHolder?.setText(
                        R.id.tv_cancel_btn,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    if (confrimTitle.isNotEmpty()) {
                        viewHolder?.setText(R.id.tv_cancel_btn, cancelTitle)
                    }
                    if (!TextUtils.isEmpty(cancelTitle)) {
                        viewHolder?.setText(R.id.tv_confirm_btn, confrimTitle)
                    } else {
                        viewHolder?.setText(
                            R.id.tv_confirm_btn,
                            LanguageUtil.getString(context, "common_text_btnConfirm")
                        )
                    }
                    viewHolder?.setText(
                        R.id.tv_content,
                        if (isFormatHtml) Html.fromHtml(content) else content
                    )

                }
                .addOnClickListener(R.id.tv_cancel_btn, R.id.tv_confirm_btn)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel_btn -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_confirm_btn -> {
                            if (listener != null) {
                                listener.sendConfirm()
                            }
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }


        /**
         *Normal Popup
         */
        fun showDialog(
            context: Context,
            content: String,
            isSingle: Boolean,
            listener: DialogBottomListener?,
            title: String = "",
            cancelTitle: String = "",
            confrimTitle: String = "",
            returnListener: Boolean = false,
            isFormatHtml: Boolean = true,
            isBackCancel: Boolean = false
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_normal_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(false)
                .setOnKeyListener { p0, p1, p2 -> isBackCancel }
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    if (!TextUtils.isEmpty(title)) {
                        viewHolder?.setGone(R.id.tv_title, true)
                        viewHolder?.setText(R.id.tv_title, title)
                    } else {
                        viewHolder?.setGone(R.id.tv_title, false)
                    }

                    if (isSingle) {
                        viewHolder?.setGone(R.id.tv_cancel, false)
                        viewHolder?.setGone(R.id.tv_confirm_btn, false)
                        viewHolder?.setGone(R.id.tv_confirm_btn_single, true)
                        if (!TextUtils.isEmpty(cancelTitle)) {
                            viewHolder?.setText(R.id.tv_confirm_btn_single, cancelTitle)
                        } else {
                            viewHolder?.setText(
                                R.id.tv_confirm_btn_single,
                                LanguageUtil.getString(context, "common_text_btnConfirm")
                            )
                        }
                    } else {
                        viewHolder?.setGone(R.id.tv_confirm_btn_single, false)
                        viewHolder?.setText(
                            R.id.tv_cancel,
                            LanguageUtil.getString(context, "common_text_btnCancel")
                        )
                        if (confrimTitle.isNotEmpty()) {
                            viewHolder?.setText(R.id.tv_cancel, confrimTitle)
                        }
                        if (!TextUtils.isEmpty(cancelTitle)) {
                            viewHolder?.setText(R.id.tv_confirm_btn, cancelTitle)
                        } else {
                            viewHolder?.setText(
                                R.id.tv_confirm_btn,
                                LanguageUtil.getString(context, "common_text_btnConfirm")
                            )
                        }
                    }
                    viewHolder?.setText(
                        R.id.tv_content,
                        if (isFormatHtml) Html.fromHtml(content) else content
                    )

                    if (TextUtils.isEmpty(content)) {
                        viewHolder?.setGone(R.id.tv_content, false)
                        val mTitle = viewHolder?.getView<TextView>(R.id.tv_title)
                        mTitle?.apply {
                            val mLayoutParams: LinearLayout.LayoutParams =
                                this?.layoutParams as LinearLayout.LayoutParams
                            mLayoutParams.bottomMargin = DisplayUtils.dip2px(context, 32f)
                            this.layoutParams = mLayoutParams
                        }
                    }
                }
                .addOnClickListener(R.id.tv_cancel, R.id.tv_confirm_btn, R.id.tv_confirm_btn_single)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_confirm_btn -> {
                            if (listener != null && (!isSingle || returnListener)) {
                                listener.sendConfirm()
                            }
                            tDialog.dismiss()
                        }
                        R.id.tv_confirm_btn_single -> {
                            if (listener != null && (!isSingle || returnListener)) {
                                listener.sendConfirm()
                            }
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

        }

        fun showDialogNew(
            context: Context,
            content: String,
            isSingle: Boolean,
            listener: DialogBottomListener?,
            title: String = "",
            cancelTitle: String = "",
            confrimTitle: String = "",
            returnListener: Boolean = false, isBackCancel: Boolean = false
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_normal_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnKeyListener { p0, p1, p2 -> isBackCancel }
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    if (!TextUtils.isEmpty(title)) {
                        viewHolder?.setGone(R.id.tv_title, true)
                        viewHolder?.setText(R.id.tv_title, title)
                    }

                    if (isSingle) {
                        viewHolder?.setGone(R.id.tv_cancel, false)
                        if (!TextUtils.isEmpty(cancelTitle)) {
                            viewHolder?.setText(R.id.tv_confirm_btn, cancelTitle)
                        } else {
                            viewHolder?.setText(
                                R.id.tv_confirm_btn,
                                LanguageUtil.getString(context, "common_text_btnConfirm")
                            )
                        }

                    } else {
                        viewHolder?.setText(
                            R.id.tv_cancel,
                            LanguageUtil.getString(context, "common_text_btnCancel")
                        )
                        if (confrimTitle.isNotEmpty()) {
                            viewHolder?.setText(R.id.tv_cancel, confrimTitle)
                        }
                        if (!TextUtils.isEmpty(cancelTitle)) {
                            viewHolder?.setText(R.id.tv_confirm_btn, cancelTitle)
                        } else {
                            viewHolder?.setText(
                                R.id.tv_confirm_btn,
                                LanguageUtil.getString(context, "common_text_btnConfirm")
                            )
                        }
                    }
                    viewHolder?.setText(R.id.tv_content, content)

                }
                .addOnClickListener(R.id.tv_cancel, R.id.tv_confirm_btn)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_confirm_btn -> {
                            if (listener != null && (!isSingle || returnListener)) {
                                listener.sendConfirm()
                            }
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

        }

        fun showConfirmWithDialog(
            context: Context,
            realAmount: String? = "",
            mainCoin: String?,//Main network
            remark: String?,
            address: String,
            isWhile: Boolean = false,
            symbol: String,
            amount: String,
            fee: String,
            listener: DialogBottomListener?
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_security_confirm_draw_adapter)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    viewHolder?.run {
                        setText(R.id.tv_title,"confirm_withdraw".tr(context))
                        setText(R.id.tv_withdraw_text_moneyWithoutFee,"withdraw_text_moneyWithoutFee".tr(context))
                        setText(R.id.gt_draw_tips,"withdraw_confirm_tip".tr(context))
                        setText(R.id.tv_confirm_btn,"common_text_btnConfirm".tr(context))
                        setText(R.id.tv_cancel_btn,"common_text_btnCancel".tr(context))
                    }
                    val tvReal = viewHolder?.getView<TextView>(R.id.tv_real_amount)
                    tvReal?.text = realAmount

                    val tvAddress = viewHolder?.getView<GridTextView>(R.id.gt_draw_address)
                    val tvMainCoin = viewHolder?.getView<GridTextView>(R.id.gt_draw_link)
                    val tvRemark = viewHolder?.getView<GridDrawTextView>(R.id.gt_draw_remark)

                    tvAddress?.setContentTextInterval(address)
                    tvAddress?.setTitleContent("withdraw_text_address".tr(context))
                    tvRemark?.setTitleContent("withdraw_text_remark".tr(context))
                    tvMainCoin?.setTitleContent("link_name".tr(context))
                    if (mainCoin != null) {
                        tvMainCoin?.setContentTextInterval(mainCoin)
                    } else {
                        tvMainCoin?.visibility = View.GONE
                    }
                    if (remark != null && remark.isNotEmpty()) {
                        tvRemark?.setContentTextInterval(remark, isWhile)
                    } else {
                        tvRemark?.visibility = View.GONE
                    }
                    tvAddress?.setContentTextInterval(address)

                    val tvSymbol = viewHolder?.getView<GridTextView>(R.id.gt_draw_symbol)
                    val tvVolume = viewHolder?.getView<GridTextView>(R.id.gt_draw_volume)
                    val tvFee = viewHolder?.getView<GridTextView>(R.id.gt_draw_fee)

                    tvSymbol?.setContentTextInterval(symbol)
                    tvSymbol?.setTitleContent("common_text_coinsymbol".tr(context))
                    tvVolume?.setContentTextInterval(amount.coinAppendSymbol(symbol))
                    tvVolume?.setTitleContent("charge_text_volume".tr(context))
                    tvFee?.setContentTextInterval(fee.coinAppendSymbol(symbol))
                    tvFee?.setTitleContent("withdraw_text_fee".tr(context))

                }
                .addOnClickListener(R.id.tv_cancel_btn, R.id.tv_confirm_btn)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel_btn -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_confirm_btn -> {
                            listener?.sendConfirm()
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

        }

        /**
         *Transfer
         */
        fun showTransferDialog(
            context: Context,
            content: String,
            isSingle: Boolean,
            listener: DialogTransferBottomListener,
            title: String = "",
            cancelTitle: String = "",
            confrimTitle: String = ""
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_new_double_normal_dialog)
                .setScreenWidthAspect(context, 0.9f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.9f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    if (!TextUtils.isEmpty(title)) {
                        viewHolder?.setGone(R.id.tv_title, true)
                        viewHolder?.setText(R.id.tv_title, title)
                    }

                    if (isSingle) {
                        viewHolder?.setGone(R.id.tv_cancel_btn, false)
                        if (!TextUtils.isEmpty(cancelTitle)) {
                            viewHolder?.setText(R.id.tv_confirm_btn, cancelTitle)
                        } else {
                            viewHolder?.setText(
                                R.id.tv_confirm_btn,
                                LanguageUtil.getString(context, "common_text_btnConfirm")
                            )
                        }

                    } else {
                        viewHolder?.setText(
                            R.id.tv_cancel_btn,
                            LanguageUtil.getString(context, "common_text_btnCancel")
                        )
                        if (confrimTitle.isNotEmpty()) {
                            viewHolder?.setText(R.id.tv_cancel_btn, confrimTitle)
                        }
                        if (!TextUtils.isEmpty(cancelTitle)) {
                            viewHolder?.setText(R.id.tv_confirm_btn, cancelTitle)
                        } else {
                            viewHolder?.setText(
                                R.id.tv_confirm_btn,
                                LanguageUtil.getString(context, "common_text_btnConfirm")
                            )
                        }
                    }
                    viewHolder?.setText(R.id.tv_content, content)

                }
                .addOnClickListener(R.id.tv_cancel_btn, R.id.tv_confirm_btn)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel_btn -> {
                            if (listener != null) {
                                listener.showCancel()
                            }
                            tDialog.dismiss()
                        }
                        R.id.tv_confirm_btn -> {
                            if (listener != null && !isSingle) {
                                listener.sendConfirm()
                            }
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

        }


        /**
         *Security verification dialog
         *
         */
        fun showSecurityVerificationDialog(
            context: Context,
            type: Int,
            codeType: Int,
            listener: DialogVerifiactionListener,
            emailType: Int = -1,
            confirmTitle: String = ""
        ): CpTDialog {
            var phone = ""
            var mail = ""
            var googleCode = ""
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_security_verification_adapter)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    viewHolder?.setGone(R.id.rl_google_layout, false)
                    viewHolder?.setGone(R.id.rl_phone_layout, false)
                    viewHolder?.setGone(R.id.rl_pwd_layout, false)
                    viewHolder?.setGone(R.id.rl_mail_layout, false)
                    viewHolder?.setGone(R.id.ce_account, false)
                    viewHolder?.setGone(R.id.v_line, false)
                    viewHolder?.setText(
                        R.id.tv_title,
                        LanguageUtil.getString(context, "login_action_fogetpwdSafety")
                    )
                    viewHolder?.setText(
                        R.id.tv_security_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    if (TextUtils.isEmpty(confirmTitle)) {
                        viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                            ?.setContent(LanguageUtil.getString(context, "common_text_btnConfirm"))
                    } else {
                        viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                            ?.setContent(confirmTitle)

                    }
                    viewHolder?.getView<CustomizeEditText>(R.id.ce_account)?.hint =
                        LanguageUtil.getString(context, "userinfo_tip_inputNickname")
                    when (type) {
                        /**
                         *Whether to bind to Google verification
                         */
                        0 -> {
                            viewHolder?.setText(
                                R.id.tv_google_title,
                                LanguageUtil.getString(context, "personal_text_googleCode")
                            )
                            viewHolder?.setGone(R.id.rl_google_layout, true)
                        }
                        /**
                         *Whether to bind the phone
                         */
                        1 -> {
                            viewHolder?.setGone(R.id.rl_phone_layout, true)
                            viewHolder?.setText(
                                R.id.tv_phone_title,
                                UserDataService.getInstance().mobileNumber
                            )
                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.otypeForPhone =
                                codeType
                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
                                ?.sendVerify(ComVerifyView.MOBILE)

                        }
                        /**
                         *Bind email or not
                         */
                        2 -> {
                            viewHolder?.setGone(R.id.rl_mail_layout, true)
                            viewHolder?.setText(
                                R.id.tv_mail_title,
                                UserDataService.getInstance().email
                            )
                            if (emailType != -1) {
                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.otypeForEmail =
                                    emailType
                            } else {
                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.otypeForEmail =
                                    codeType
                            }

                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
                                ?.sendVerify(ComVerifyView.EMAIL)

                        }
                        /**
                         *Show All
                         */
                        -1 -> {
                            if (UserDataService.getInstance().googleStatus == 1) {
                                viewHolder?.setGone(R.id.rl_google_layout, true)
                                viewHolder?.setText(
                                    R.id.tv_google_title,
                                    LanguageUtil.getString(context, "personal_text_googleCode")
                                )
                            }
                            if (UserDataService.getInstance().email.isNotEmpty()) {
                                viewHolder?.setGone(R.id.rl_mail_layout, true)
                                viewHolder?.setText(
                                    R.id.tv_mail_title,
                                    UserDataService.getInstance().email
                                )
                                if (emailType != -1) {
                                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.otypeForEmail =
                                        emailType
                                } else {
                                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.otypeForEmail =
                                        codeType
                                }
                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
                                    ?.sendVerify(ComVerifyView.EMAIL)
                            }

                            if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                viewHolder?.setGone(R.id.rl_phone_layout, true)
                                viewHolder?.setText(
                                    R.id.tv_phone_title,
                                    UserDataService.getInstance().mobileNumber
                                )
                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.otypeForPhone =
                                    codeType
                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
                                    ?.sendVerify(ComVerifyView.MOBILE)
                            } else {
                                viewHolder?.setGone(R.id.rl_phone_layout, false)
                            }


                        }

                    }
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.isEnable(true)
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.listener =
                        object : CommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                when (type) {
                                    -1 -> {
                                        googleCode =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code
                                                ?: ""
                                        phone =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code
                                                ?: ""
                                        mail =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code
                                                ?: ""
                                    }
                                    0 -> {
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                            ToastUtils.showToast(
                                                LanguageUtil.getString(
                                                    context,
                                                    "login_tip_inputCode"
                                                )
                                            )
                                        } else {
                                            googleCode =
                                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code
                                                    ?: ""
                                        }
                                    }
                                    1 -> {
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                            ToastUtils.showToast(
                                                LanguageUtil.getString(
                                                    context,
                                                    "login_tip_inputCode"
                                                )
                                            )
                                        } else {
                                            phone =
                                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code
                                                    ?: ""
                                        }
                                    }
                                    2 -> {
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                            ToastUtils.showToast(
                                                LanguageUtil.getString(
                                                    context,
                                                    "login_tip_inputCode"
                                                )
                                            )
                                        } else {
                                            mail =
                                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code
                                                    ?: ""
                                        }
                                    }
                                }

                                listener.returnCode(phone, mail, googleCode)
                            }

                        }
                }
                .addOnClickListener(R.id.tv_security_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_security_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        fun showForgetPwdSecurityVerificationDialog(
            context: Context,
            isPhone: Boolean,
            isEmail: Boolean,
            isGoogleAuth: Boolean,
            isCertificateNumber: Boolean,
            codeType: Int,
            listener: DialogVerifiactionNewListener,
            emailType: Int = -1,
            confirmTitle: String = "",
            token: String,
            account: String
        ): CpTDialog {
            var phone = ""
            var mail = ""
            var phoneCode = ""
            var mailCode = ""
            var googleCode = ""
            var certifcateNumber = ""
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_new_security_verification_adapter)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    viewHolder?.setGone(R.id.rl_google_layout, false)
                    viewHolder?.setGone(R.id.rl_phone_layout, false)
                    viewHolder?.setGone(R.id.rl_mail_layout, false)
                    viewHolder?.setGone(R.id.ce_account, false)
                    viewHolder?.setGone(R.id.v_line, false)
                    viewHolder?.setText(
                        R.id.tv_title,
                        LanguageUtil.getString(context, "login_action_fogetpwdSafety")
                    )
                    viewHolder?.setText(
                        R.id.tv_security_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    if (TextUtils.isEmpty(confirmTitle)) {
                        viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                            ?.setContent(LanguageUtil.getString(context, "common_action_next"))
                    } else {
                        viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                            ?.setContent(confirmTitle)
                    }
                    viewHolder?.getView<CustomizeEditText>(R.id.ce_account)?.hint =
                        LanguageUtil.getString(context, "userinfo_tip_inputNickname")
                    if (isPhone) {
                        phone = account
                        viewHolder?.setGone(R.id.rl_phone_layout, true)
                        viewHolder?.setText(R.id.tv_phone_title, account)
                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.otypeForPhone =
                            codeType
                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
                            ?.sendVerify(ComVerifyView.MOBILE, token4last = token)
                    }
                    if (isEmail) {
                        mail = account
                        viewHolder?.setGone(R.id.rl_mail_layout, true)
                        viewHolder?.setText(R.id.tv_mail_title, account)
                        if (emailType != -1) {
                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.otypeForEmail =
                                emailType
                        } else {
                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.otypeForEmail =
                                codeType
                        }
                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
                            ?.sendVerify(ComVerifyView.EMAIL, token4last = token)
                    }
                    if (isGoogleAuth) {
                        viewHolder?.setText(
                            R.id.tv_google_title,
                            LanguageUtil.getString(context, "personal_text_googleCode")
                        )
                        viewHolder?.setGone(R.id.rl_google_layout, true)
                    }
                    if (isCertificateNumber) {
                        viewHolder?.setText(
                            R.id.tv_certificatenumber_title,
                            LanguageUtil.getString(context, "kyc_text_idnumber")
                        )
                        viewHolder?.setGone(R.id.rl_certificatenumber_layout, true)
                        viewHolder?.getView<CustomizeEditText>(R.id.ce_certificatenumber)?.isFocusableInTouchMode =
                            true
                        viewHolder?.getView<CustomizeEditText>(R.id.ce_certificatenumber)?.isFocusable =
                            true
                        viewHolder?.getView<CustomizeEditText>(R.id.ce_certificatenumber)?.isShowLine =
                            true
                    }

                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.isEnable(true)
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.listener =
                        object : CommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                phoneCode =
                                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code
                                        ?: ""
                                mailCode =
                                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code
                                        ?: ""
                                googleCode =
                                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code
                                        ?: ""
                                certifcateNumber =
                                    viewHolder?.getView<CustomizeEditText>(R.id.ce_certificatenumber)?.textContent
                                        ?: ""
                                listener.returnCode(
                                    phone,
                                    mail,
                                    phoneCode,
                                    mailCode,
                                    googleCode,
                                    certifcateNumber
                                )
                            }
                        }
                }
                .addOnClickListener(R.id.tv_security_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_security_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }


        /**
         *Account transfer display
         *
         */
        fun showAccountDialog(
            context: Context,
            type: Int,
            account: String,
            codeType: Int,
            listener: DialogVerifiactionListener
        ): CpTDialog {
            var phone = ""
            var mail = ""
            var googleCode = ""
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_security_verification_adapter)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    viewHolder?.setGone(R.id.rl_google_layout, false)
                    viewHolder?.setGone(R.id.rl_phone_layout, false)
                    viewHolder?.setGone(R.id.rl_mail_layout, false)
                    viewHolder?.setGone(R.id.rl_pwd_layout, false)
                    viewHolder?.setGone(R.id.ce_account, false)
                    viewHolder?.setGone(R.id.v_line, false)
                    viewHolder?.setText(
                        R.id.tv_title,
                        LanguageUtil.getString(context, "login_action_fogetpwdSafety")
                    )
                    viewHolder?.setText(
                        R.id.tv_security_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.getView<PwdSettingView>(R.id.pwd_login_pwd)
                        ?.setHintEditText(LanguageUtil.getString(context, "register_tip_inputPassword"))
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
                        ?.setHintEditText(LanguageUtil.getString(context, "personal_tip_inputMailCode"))
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
                        ?.setHintEditText(LanguageUtil.getString(context, "toast_no_mobile_verification_code"))
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)
                        ?.setHintEditText(LanguageUtil.getString(context, "common_tip_googleAuth"))
//                    viewHolder?.getView<CustomizeEditText>(R.id.ce_account)
//                        ?.hint=(LanguageUtil.getString(context, "new_input_nickname"))


                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                        ?.setContent(LanguageUtil.getString(context, "common_text_btnConfirm"))
                    viewHolder?.getView<CustomizeEditText>(R.id.ce_account)?.hint =
                        LanguageUtil.getString(context, "userinfo_tip_inputNickname")
                    when (type) {
                        /**
                         *Whether to bind to Google verification
                         */
                        0 -> {
                            viewHolder?.setGone(R.id.rl_google_layout, true)
                            viewHolder?.setText(
                                R.id.tv_google_title,
                                LanguageUtil.getString(context, "personal_text_googleCode")
                            )
                        }
                        /**
                         *Whether to bind the phone
                         */
                        1 -> {
                            viewHolder?.setGone(R.id.rl_phone_layout, true)
                            viewHolder?.setText(R.id.tv_phone_title, account)
                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.otypeForPhone =
                                codeType
//                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
//                                ?.sendVerify(ComVerifyView.MOBILE)

                        }
                        /**
                         *Bind email or not
                         */
                        2 -> {
                            viewHolder?.setGone(R.id.rl_mail_layout, true)
                            viewHolder?.setText(R.id.tv_mail_title, account)
                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
                                ?.setAccount(account)
//                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
//                                ?.setValidation(true)
//                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.otypeForEmail =
//                                codeType
//                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
//                                ?.sendVerify(ComVerifyView.EMAIL, true, account)
                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.run{
                                setAccount(account)
                                setValidation(true)
                                otypeForEmail = codeType
                            }
                        }
                        /**
                         *Show All
                         */
                        -1 -> {
                            if (UserDataService.getInstance().googleStatus == 1) {
                                viewHolder?.setText(
                                    R.id.tv_google_title,
                                    LanguageUtil.getString(context, "personal_text_googleCode")
                                )
                                viewHolder?.setGone(R.id.rl_google_layout, true)
                            }
                            if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                viewHolder?.setText(
                                    R.id.tv_phone_title,
                                    UserDataService.getInstance().mobileNumber
                                )
                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.otypeForPhone =
                                    codeType
//                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
//                                    ?.sendVerify(ComVerifyView.MOBILE)
                                viewHolder?.setGone(R.id.rl_phone_layout, true)
                            } else {
                                viewHolder?.setGone(R.id.rl_phone_layout, false)
                            }


                            viewHolder?.setText(R.id.tv_mail_title, account)
                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
                                ?.setAccount(account)
                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
                                ?.setValidation(true)
                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.otypeForEmail =
                                codeType
//                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
//                                ?.sendVerify(ComVerifyView.EMAIL, true, account)
                            viewHolder?.setGone(R.id.rl_mail_layout, true)
                        }

                    }
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.setMaxInputLen(6)
                    //Google verification code
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true
                                if (type == 0) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (type == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (type == 2) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (type == -1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                        isEnable = false
                                    }
                                    if (UserDataService.getInstance().googleStatus == 1) {
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                            isEnable = false
                                        }
                                    }
                                    if(UserDataService.getInstance().isOpenMobileCheck == 1){
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                            isEnable = false
                                        }
                                    }
                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        } //Email verification code
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true
                                if (type == 0) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (type == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (type == 2) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (type == -1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                        isEnable = false
                                    }
                                    if (UserDataService.getInstance().googleStatus == 1) {
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                            isEnable = false
                                        }
                                    }
                                    if(UserDataService.getInstance().isOpenMobileCheck == 1){
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                            isEnable = false
                                        }
                                    }

                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        } //Mobile verification code
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true
                                if (type == 0) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (type == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (type == 2) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (type == -1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                        isEnable = false
                                    }
                                    if (UserDataService.getInstance().googleStatus == 1) {
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                            isEnable = false
                                        }
                                    }
                                    if(UserDataService.getInstance().isOpenMobileCheck == 1){
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                            isEnable = false
                                        }
                                    }

                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        }

                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.isEnable(false)
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.listener =
                        object : CommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                when (type) {
                                    -1 -> {
                                        googleCode =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code
                                                ?: ""
                                        phone =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code
                                                ?: ""
                                        mail =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code
                                                ?: ""
                                    }
                                    0 -> {
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                            ToastUtils.showToast(
                                                LanguageUtil.getString(
                                                    context,
                                                    "login_tip_inputCode"
                                                )
                                            )
                                        } else {
                                            googleCode =
                                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code
                                                    ?: ""
                                        }
                                    }
                                    1 -> {
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                            ToastUtils.showToast(
                                                LanguageUtil.getString(
                                                    context,
                                                    "login_tip_inputCode"
                                                )
                                            )
                                        } else {
                                            phone =
                                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code
                                                    ?: ""
                                        }
                                    }
                                    2 -> {
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                            ToastUtils.showToast(
                                                LanguageUtil.getString(
                                                    context,
                                                    "login_tip_inputCode"
                                                )
                                            )
                                        } else {
                                            mail =
                                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code
                                                    ?: ""
                                        }
                                    }
                                }

                                listener.returnCode(phone, mail, googleCode)
                            }

                        }
                }
                .addOnClickListener(R.id.tv_security_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_security_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        /**
         *Security verification dialog
         *
         */
        fun showSecurityForBindDialog(
            context: Context,
            codeType: Int,
            listener: DialogVerifiactionListener,
            type: Int = 0
        ): CpTDialog {
            var phone = ""
            var mail = ""
            var googleCode = ""
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_security_verification_adapter)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.setMaxInputLen(6)
                    val cvvGoogle = viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)
                    viewHolder?.setGone(R.id.ce_account, false)
                    viewHolder?.setGone(R.id.v_line, false)
                    viewHolder?.setGone(R.id.rl_pwd_layout, false)
                    viewHolder?.setText(R.id.tv_mail_title, UserDataService.getInstance().email)
                    viewHolder?.setText(
                        R.id.tv_phone_title,
                        UserDataService.getInstance().mobileNumber
                    )
                    viewHolder?.setText(
                        R.id.tv_google_title,
                        LanguageUtil.getString(context, "personal_text_googleCode")
                    )
                    viewHolder?.setText(
                        R.id.tv_title,
                        LanguageUtil.getString(context, "login_action_fogetpwdSafety")
                    )
                    viewHolder?.setText(
                        R.id.tv_security_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                        ?.setContent(LanguageUtil.getString(context, "common_text_btnConfirm"))
                    viewHolder?.getView<CustomizeEditText>(R.id.ce_account)?.hint =
                        LanguageUtil.getString(context, "userinfo_tip_inputNickname")
                    /**
                     *Whether to bind to Google verification
                     */
                    if (UserDataService.getInstance().googleStatus == 1) {
                        viewHolder?.setGone(R.id.rl_google_layout, true)
                        cvvGoogle?.setHintEditText("common_tip_googleAuth".tr(context))
                    } else {
                        viewHolder?.setGone(R.id.rl_google_layout, false)
                    }
                    /**
                     *Whether to bind the phone
                     */
                    if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                        viewHolder?.setGone(R.id.rl_phone_layout, true)
                        val cvvPhone = viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
                        cvvPhone?.otypeForPhone = codeType
                        cvvPhone?.setHintEditText("personal_tip_inputPhoneCode".tr(context))
//                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
//                            ?.sendVerify(ComVerifyView.MOBILE)
                    } else {
                        viewHolder?.setGone(R.id.rl_phone_layout, false)

                    }
                    /**
                     *Bind email or not
                     */
                    if (type == 0) {
                        if (!TextUtils.isEmpty(UserDataService.getInstance().email)) {
                            viewHolder?.setGone(R.id.rl_mail_layout, true)
                            val cvvEmail = viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
                            cvvEmail?.otypeForEmail = codeType
                            cvvEmail?.setHintEditText("personal_tip_inputMailCode".tr(context))
//                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
//                                ?.sendVerify(ComVerifyView.EMAIL)
                        } else {
                            viewHolder?.setGone(R.id.rl_mail_layout, false)
                        }
                    } else {
                        viewHolder?.setGone(R.id.rl_mail_layout, false)
                    }
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.isEnable(false)
                    //Google verification code
                    cvvGoogle?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (type == 0) {
                                    if (TextUtils.isEmpty(UserDataService.getInstance().email)) {
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                            isEnable = false
                                        }
                                    }
                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        }

                    //Mobile number verification code
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (type == 0) {
                                    if (TextUtils.isEmpty(UserDataService.getInstance().email)) {
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                            isEnable = false
                                        }
                                    }
                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        }

                    //Email verification code
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (type == 0) {
                                    if (TextUtils.isEmpty(UserDataService.getInstance().email)) {
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                            isEnable = false
                                        }
                                    }
                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        }

                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.listener =
                        object : CommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        ToastUtils.showToast(
                                            LanguageUtil.getString(
                                                context,
                                                "hint_google_certification_code"
                                            )
                                        )
                                    } else {
                                        googleCode =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code
                                                ?: ""
                                    }
                                }
                                if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                        ToastUtils.showToast(
                                            LanguageUtil.getString(
                                                context,
                                                "toast_no_mobile_verification_code"
                                            )
                                        )
                                    } else {
                                        phone =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code
                                                ?: ""
                                    }
                                }
                                if (type == 0) {
                                    if (TextUtils.isEmpty(UserDataService.getInstance().email)) {
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {

                                        } else {
                                            mail =
                                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code
                                                    ?: ""
                                        }
                                    }
                                }

                                listener.returnCode(phone, mail, googleCode)
                            }

                        }
                }
                .addOnClickListener(R.id.tv_security_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_security_cancel -> {
                            tDialog.dismiss()

                        }
                    }
                }
                .create()
                .show()
        }

        /**
         * Security verify dialog from bottom
         * @param context
         * @param securityRule Validation rules implemented
         * @param codeType Auth code scene
         * @param listener Code callback
         * @param dismissListener dismiss callback
         * @param manualCancelListener cancel callback
         * @param coinTypeEmail EmailAuth code scene
         * @return CpTDialog
         * */
        fun createNewVersionSecurityDialog(
            context: Context,
            securityRule: KKSecurityRule,
            codeType: Int,
            listener: DialogVerifiactionListener,
            dismissListener:DialogInterface.OnDismissListener? = null,
            manualCancelListener:DialogDismissListener? = null,
            coinTypeEmail:Int = -1,
        ): CpTDialog {
            var phoneCode = ""
            var mailCode = ""
            var googleCode = ""
            var capitalPwd = ""
            var loginPwd = ""
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.layout_security_verification)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(dimAmountValue)
                .setCancelableOutside(false)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    val visibleView = arrayListOf<Any>()
                    val cvvGoogle = viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)
                    val cvvPhone = viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
                    val cvvEmail = viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
                    val psvLoginPwd = viewHolder?.getView<PwdSettingView>(R.id.pwd_login_pwd)
                    val psvCapitalPwd = viewHolder?.getView<PwdSettingView>(R.id.pwd_capital_pwd)
                    val btnConfirm = viewHolder?.getView<KKButtonKit>(R.id.tv_confirm)
                    viewHolder?.setText(R.id.tv_mail_title, UserDataService.getInstance().email)
                    viewHolder?.setText(R.id.tv_phone_title, UserDataService.getInstance().mobileNumber)
                    viewHolder?.setText(R.id.tv_google_title, LanguageUtil.getString(context, "personal_text_googleCode"))
                    viewHolder?.setText(R.id.tv_title, LanguageUtil.getString(context, "login_action_fogetpwdSafety"))
                    viewHolder?.setText(R.id.tv_capital_pwd_title, LanguageUtil.getString(context, "otcSafeAlert_text_otcPwd"))
                    viewHolder?.setText(R.id.tv_pwd_title, LanguageUtil.getString(context, "register_text_loginPwd"))
                    viewHolder?.setText(R.id.tv_security_cancel, LanguageUtil.getString(context, "common_text_btnCancel"))
                    btnConfirm?.textContent = LanguageUtil.getString(context, "common_text_btnConfirm")
                    cvvGoogle?.setHintEditText("personal_text_googleCode".tr(context))
                    cvvPhone?.setHintEditText("personal_text_phoneCode".tr(context))
                    cvvEmail?.setHintEditText("personal_text_mailCode".tr(context))
                    psvLoginPwd?.setHintEditText("register_tip_inputPassword".tr(context))
                    psvCapitalPwd?.setHintEditText("otcSafeAlert_text_otcPwd".tr(context))
                    cvvPhone?.otypeForPhone = codeType
                    cvvEmail?.otypeForEmail = if(coinTypeEmail!=-1) coinTypeEmail else codeType
                    /**
                     *Whether to bind to Google verification
                     */
                    viewHolder?.setGone(R.id.rl_google_layout, false)
                    viewHolder?.setGone(R.id.rl_phone_layout, false)
                    viewHolder?.setGone(R.id.rl_mail_layout, false)
                    viewHolder?.setGone(R.id.rl_capital_pwd_layout, false)
                    viewHolder?.setGone(R.id.rl_pwd_layout, false)

                    viewHolder?.let {
                        val viewGroup = it.bindView as LinearLayout
                        if(viewGroup.childCount>0){
                            val iterator = viewGroup.children.iterator()
                            while (iterator.hasNext()){
                                val next = iterator.next()
                                if(next.id!=R.id.rl_security_verification_layout && next.id!=R.id.tv_confirm){
                                    val ruleCollection = securityRule.makeRule()
                                    var isHasView = false
                                    for(item in ruleCollection){
                                        if(item.getFlag(context).equals(next.tag)){
                                            isHasView = true

                                        }
                                    }

                                    if(isHasView) {
                                        next.visibility = View.VISIBLE

                                        val itemViewGroup = next as ViewGroup
                                        val lastView = itemViewGroup.children.last()
                                        visibleView.add(lastView)
                                        if(lastView is PwdSettingView){
                                            lastView.onTextListener =  object : PwdSettingView.OnTextListener {
                                                override fun showText(text: String): String {
                                                    var isEnable = true
                                                    for(itemVisibleView in visibleView){
                                                        if(itemVisibleView is PwdSettingView){
                                                            if(TextUtils.isEmpty(itemVisibleView.text)){
                                                                isEnable = false
                                                            }
                                                        }else if(itemVisibleView is ComVerifyView){
                                                            if(TextUtils.isEmpty(itemVisibleView.code)){
                                                                isEnable = false
                                                            }
                                                        }
                                                    }

                                                    btnConfirm?.isEnable(isEnable)
                                                    return text
                                                }

                                                override fun returnItem(item: Int) {

                                                }

                                                override fun onclickImage() {

                                                }

                                            }
                                        }else if(lastView is ComVerifyView){
                                            lastView.setMaxInputLen(6)
                                            lastView.onTextListener = object : ComVerifyView.OnTextListener {
                                                override fun showText(text: String): String {
                                                    var isEnable = true
                                                    for(itemVisibleView in visibleView){
                                                        if(itemVisibleView is PwdSettingView){
                                                            if(TextUtils.isEmpty(itemVisibleView.text)){
                                                                isEnable = false
                                                            }
                                                        }else if(itemVisibleView is ComVerifyView){
                                                            if(TextUtils.isEmpty(itemVisibleView.code)||itemVisibleView.code.length<6){
                                                                isEnable = false
                                                            }
                                                        }
                                                    }
                                                    btnConfirm?.isEnable(isEnable)
                                                    return text
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    btnConfirm?.isEnable(false)
                    btnConfirm?.setOnClickListener(object :View.OnClickListener{
                        private fun fillContent(itemVisibleView:PwdSettingView){
                            val itemViewTag = (itemVisibleView.parent as View).tag
                            if(context.getString(R.string.security_capital_pwd).equals(itemViewTag)){
                                capitalPwd = itemVisibleView.text
                            }else if(context.getString(R.string.security_login_pwd).equals(itemViewTag)){
                                loginPwd = itemVisibleView.text
                            }
                        }
                        private fun fillContent(itemVisibleView:ComVerifyView){
                            val itemViewTag = (itemVisibleView.parent as View).tag
                            if(context.getString(R.string.security_email).equals(itemViewTag)){
                                mailCode = itemVisibleView.code
                            }else if(context.getString(R.string.security_phone).equals(itemViewTag)){
                                phoneCode = itemVisibleView.code
                            }else if(context.getString(R.string.security_google).equals(itemViewTag)){
                                googleCode = itemVisibleView.code
                            }
                        }

                        private fun autoFillContent(){
                            for(itemVisibleView in visibleView){
                                if(itemVisibleView is PwdSettingView){
                                    fillContent(itemVisibleView)
                                }else if(itemVisibleView is ComVerifyView){
                                    fillContent(itemVisibleView)
                                }
                            }
                        }

                        override fun onClick(v: View?) {
                            autoFillContent()
                            listener.returnCode(phoneCode,mailCode,googleCode)
                            listener.returnCode(phoneCode, mailCode, googleCode,capitalPwd,loginPwd)
                        }

                    })
                }
                .addOnClickListener(R.id.tv_security_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_security_cancel -> {
                            manualCancelListener?.onDismiss()
                            tDialog.dismiss()
                        }
                    }
                }
                .setOnDismissListener(dismissListener)
                .create()
                .show()
        }

        /**
         *Security verification dialog
         *
         */
        fun showValidationGoogleDialog(
            context: Context,
            listener: DialogValidationGoogleListener
        ): CpTDialog {
            var googleCode = ""
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_security_verification_adapter)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setGone(R.id.ce_account, false)
                    viewHolder?.setGone(R.id.v_line, false)
                    viewHolder?.setGone(R.id.rl_google_layout, false)
                    viewHolder?.setGone(R.id.rl_phone_layout, false)
                    viewHolder?.setGone(R.id.rl_mail_layout, false)
                    viewHolder?.setGone(R.id.rl_pwd_layout, false)
                    viewHolder?.setText(
                        R.id.tv_google_title,
                        LanguageUtil.getString(context, "personal_text_googleCode")
                    )
                    viewHolder?.setText(
                        R.id.tv_title,
                        LanguageUtil.getString(context, "login_action_fogetpwdSafety")
                    )
                    viewHolder?.setText(
                        R.id.tv_security_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                        ?.setContent(LanguageUtil.getString(context, "common_action_next"))
                    viewHolder?.getView<CustomizeEditText>(R.id.ce_account)?.hint =
                        LanguageUtil.getString(context, "userinfo_tip_inputNickname")

                    /**
                     *Whether to bind to Google verification
                     */
                    viewHolder?.setGone(R.id.rl_google_layout, true)


                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.isEnable(true)
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.listener =
                        object : CommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                    ToastUtils.showToast(
                                        LanguageUtil.getString(
                                            context,
                                            "toast_no_mobile_verification_code"
                                        )
                                    )
                                } else {
                                    googleCode =
                                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code
                                            ?: ""
                                }

                                listener.returnCode(googleCode)
                            }

                        }
                }
                .addOnClickListener(R.id.tv_security_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_security_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }


        /**2
         *Bind mobile phone dialog
         *
         */
        fun showSecurityForBindPhoneCodeDialog(
            context: Context,
            codeType: Int,
            listener: DialogVerifiactionListener,
            lisDis:DialogDismissListener
        ): CpTDialog {
            var phone = ""
            var mail = ""
            var googleCode = ""
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_security_verification_adapter)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setGone(R.id.ce_account, false)
                    viewHolder?.setGone(R.id.v_line, false)
                    viewHolder?.setGone(R.id.rl_pwd_layout, false)
                    viewHolder?.setGone(R.id.rl_mail_layout, false)
                    viewHolder?.setText(R.id.tv_mail_title, UserDataService.getInstance().email)
                    viewHolder?.setText(
                        R.id.tv_phone_title,
                        UserDataService.getInstance().mobileNumber
                    )
                    viewHolder?.setText(
                        R.id.tv_google_title,
                        LanguageUtil.getString(context, "personal_text_googleCode")
                    )
                    viewHolder?.setText(
                        R.id.tv_title,
                        LanguageUtil.getString(context, "login_action_fogetpwdSafety")
                    )
                    viewHolder?.setText(
                        R.id.tv_security_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                        ?.setContent(LanguageUtil.getString(context, "common_text_btnConfirm"))
                    viewHolder?.getView<CustomizeEditText>(R.id.ce_account)?.hint =
                        LanguageUtil.getString(context, "userinfo_tip_inputNickname")
                    /**
                     *Whether to bind to Google verification
                     */
                    if (UserDataService.getInstance().googleStatus == 1) {
                        viewHolder?.setGone(R.id.rl_google_layout, true)
                    } else {
                        viewHolder?.setGone(R.id.rl_google_layout, false)
                    }
                    /**
                     *Whether to bind the phone
                     */

                    viewHolder?.setGone(R.id.rl_phone_layout, true)
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.otypeForPhone =
                        codeType
//                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
//                        ?.sendVerify(ComVerifyView.MOBILE)


                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.isEnable(false)
                    //Google verification code
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true

                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                        isEnable = false
                                    }
                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        }  //Mobile verification code
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true

                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                        isEnable = false
                                    }
                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        }

                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.listener =
                        object : CommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        ToastUtils.showToast(
                                            LanguageUtil.getString(
                                                context,
                                                "hint_google_certification_code"
                                            )
                                        )
                                    } else {
                                        googleCode =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code
                                                ?: ""
                                    }
                                }
                                if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                        ToastUtils.showToast(
                                            LanguageUtil.getString(
                                                context,
                                                "toast_no_mobile_verification_code"
                                            )
                                        )
                                    } else {
                                        phone =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code
                                                ?: ""
                                    }
                                }

                                listener.returnCode(phone, mail, googleCode)
                            }

                        }
                }
                .addOnClickListener(R.id.tv_security_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_security_cancel -> {
                            tDialog.dismiss()

                        }
                    }
                }
                .setOnDismissListener {
                    lisDis.onDismiss();
                }
                .create()
                .show()
        }


        /**
         *Bind mobile phone verification dialog
         *
         */
        fun showSecurityForBindPhoneDialog(
            context: Context,
            codeType: Int,
            newphone: String,
            countryCode: String = "",
            listener: DialogVerifiactionListener
        ): CpTDialog {
            var phone = ""
            var mail = ""
            var googleCode = ""
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_security_verification_adapter)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setGone(R.id.ce_account, false)
                    viewHolder?.setGone(R.id.v_line, false)
                    viewHolder?.setGone(R.id.rl_pwd_layout, false)
                    viewHolder?.setText(
                        R.id.tv_mail_title,
                        UserDataService.getInstance().mobileNumber
                    )
                    viewHolder?.setText(R.id.tv_phone_title, newphone)
                    viewHolder?.setText(
                        R.id.tv_google_title,
                        LanguageUtil.getString(context, "personal_text_googleCode")
                    )
                    viewHolder?.setText(
                        R.id.tv_title,
                        LanguageUtil.getString(context, "login_action_fogetpwdSafety")
                    )
                    viewHolder?.setText(
                        R.id.tv_security_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                        ?.setContent(LanguageUtil.getString(context, "common_text_btnConfirm"))
                    viewHolder?.getView<CustomizeEditText>(R.id.ce_account)?.hint =
                        LanguageUtil.getString(context, "userinfo_tip_inputNickname")
                    /**
                     *Whether to bind to Google verification
                     */
                    if (UserDataService.getInstance().googleStatus == 1) {
                        viewHolder?.setGone(R.id.rl_google_layout, true)
                    } else {
                        viewHolder?.setGone(R.id.rl_google_layout, false)
                    }
                    /**
                     *Old phone
                     */
                    viewHolder?.setGone(R.id.rl_mail_layout, false)


                    /**
                     *New phone
                     */
                    viewHolder?.setGone(R.id.rl_phone_layout, true)
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.otypeForPhone =
                        codeType
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.setAccount(newphone)
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
                        ?.setCountry(countryCode)
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.accountValidation = true
//                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
//                        ?.sendVerify(ComVerifyView.MOBILE, true, newphone)



                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.isEnable(false)


                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                        isEnable = false
                                    }
                                }
//                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
//                                    isEnable = false
//                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        }
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                        isEnable = false
                                    }
                                }
//                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
//                                    isEnable = false
//                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        }
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.listener =
                        object : CommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        ToastUtils.showToast(
                                            LanguageUtil.getString(
                                                context,
                                                "hint_google_certification_code"
                                            )
                                        )
                                    } else {
                                        googleCode =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code
                                                ?: ""
                                    }
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                    ToastUtils.showToast(
                                        LanguageUtil.getString(
                                            context,
                                            "toast_no_mobile_verification_code"
                                        )
                                    )
                                } else {
                                    phone =
                                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code
                                            ?: ""
                                }
                                listener.returnCode(phone, mail, googleCode)
                            }

                        }
                }
                .addOnClickListener(R.id.tv_security_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_security_cancel -> {
                            tDialog.dismiss()

                        }
                    }
                }
                .create()
                .show()
        }

        /**
         *Modify the mobile phone verification dialog
         *
         */
        fun showSecurityForChangePhoneDialog(
            context: Context,
            codeType: Int,
            newphone: String,
            countryCode: String = "",
            listener: DialogVerifiactionListener
        ): CpTDialog {
            var phone = ""
            var mail = ""
            var googleCode = ""
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_security_verification_adapter)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setGone(R.id.ce_account, false)
                    viewHolder?.setGone(R.id.v_line, false)
                    viewHolder?.setGone(R.id.rl_pwd_layout, false)
                    viewHolder?.setText(
                        R.id.tv_mail_title,
                        UserDataService.getInstance().mobileNumber
                    )
                    viewHolder?.setText(R.id.tv_phone_title, newphone)
                    viewHolder?.setText(
                        R.id.tv_google_title,
                        LanguageUtil.getString(context, "personal_text_googleCode")
                    )
                    viewHolder?.setText(
                        R.id.tv_title,
                        LanguageUtil.getString(context, "login_action_fogetpwdSafety")
                    )
                    viewHolder?.setText(
                        R.id.tv_security_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                        ?.setContent(LanguageUtil.getString(context, "common_text_btnConfirm"))
                    viewHolder?.getView<CustomizeEditText>(R.id.ce_account)?.hint =
                        LanguageUtil.getString(context, "userinfo_tip_inputNickname")
                    /**
                     *Whether to bind to Google verification
                     */
                    if (UserDataService.getInstance().googleStatus == 1) {
                        viewHolder?.setGone(R.id.rl_google_layout, true)
                    } else {
                        viewHolder?.setGone(R.id.rl_google_layout, false)
                    }
                    /**
                     *Old phone
                     */
                    viewHolder?.setGone(R.id.rl_mail_layout, true)
                    val cvMail = viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
                    cvMail?.otypeForPhone = codeType
                    cvMail?.setType(ComVerifyView.MOBILE)

                    /**
                     *New phone
                     */
                    viewHolder?.setGone(R.id.rl_phone_layout, true)
//                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.otypeForPhone =
//                        codeType
//                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.setAccount(newphone)
//                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
//                        ?.setCountry(countryCode)
//                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
//                        ?.sendVerify(ComVerifyView.MOBILE, false, newphone)
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.run{
                        otypeForPhone = codeType
                        setAccount(newphone)
                        setCountry(countryCode)
                        accountValidation = true
                    }


                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.isEnable(false)


                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                    isEnable = false
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                    isEnable = false
                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        }
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                    isEnable = false
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                    isEnable = false
                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        }
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                    isEnable = false
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                    isEnable = false
                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        }

                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.listener =
                        object : CommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        ToastUtils.showToast(
                                            LanguageUtil.getString(
                                                context,
                                                "hint_google_certification_code"
                                            )
                                        )
                                    } else {
                                        googleCode =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code
                                                ?: ""
                                    }
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                    ToastUtils.showToast(
                                        LanguageUtil.getString(
                                            context,
                                            "toast_no_mobile_verification_code"
                                        )
                                    )
                                } else {
                                    phone =
                                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code
                                            ?: ""
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                    ToastUtils.showToast(
                                        LanguageUtil.getString(
                                            context,
                                            "toast_no_mobile_verification_code"
                                        )
                                    )
                                } else {
                                    mail =
                                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code
                                            ?: ""
                                }

                                listener.returnCode(phone, mail, googleCode)
                            }

                        }
                }
                .addOnClickListener(R.id.tv_security_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_security_cancel -> {
                            tDialog.dismiss()

                        }
                    }
                }
                .create()
                .show()
        }

        /**
         *Modify email verification dialog
         *
         */
        fun showSecurityForBindEmailDialog(
            context: Context,
            codeType: Int,
            newEmail: String,
            countryCode: String = "",
            listener: DialogReturnChangeEmail
        ): CpTDialog {
            var phone = ""
            var newEmailcode = ""
            var oldEmail = ""
            var googleCode = ""
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_security_verification_adapter)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setGone(R.id.ce_account, false)
                    viewHolder?.setGone(R.id.rl_new_email_layout, true)
                    viewHolder?.setGone(R.id.v_line, false)
                    viewHolder?.setGone(R.id.rl_pwd_layout, false)
                    viewHolder?.setText(
                        R.id.tv_mail_title,
                        UserDataService.getInstance().mobileNumber
                    )
                    viewHolder?.setText(R.id.tv_phone_title, newEmail)
                    viewHolder?.setText(
                        R.id.tv_new_email_title,
                        UserDataService.getInstance().email
                    )
                    viewHolder?.setText(
                        R.id.tv_google_title,
                        LanguageUtil.getString(context, "personal_text_googleCode")
                    )
                    viewHolder?.setText(
                        R.id.tv_title,
                        LanguageUtil.getString(context, "login_action_fogetpwdSafety")
                    )
                    viewHolder?.setText(
                        R.id.tv_security_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.getView<PwdSettingView>(R.id.pwd_login_pwd)?.setHintEditText(LanguageUtil.getString(context, "register_tip_inputPassword"))
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.setHintEditText(LanguageUtil.getString(context, "email_ver_hint"))
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_new_email)?.setHintEditText(LanguageUtil.getString(context, "email_ver_hint"))
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.setHintEditText(LanguageUtil.getString(context, "toast_no_mobile_verification_code"))
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.setHintEditText(LanguageUtil.getString(context, "common_tip_googleAuth"))

                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                        ?.setContent(LanguageUtil.getString(context, "common_text_btnConfirm"))
                    viewHolder?.getView<CustomizeEditText>(R.id.ce_account)?.hint =
                        LanguageUtil.getString(context, "userinfo_tip_inputNickname")
                    /**
                     *Whether to bind to Google verification
                     */
                    if (UserDataService.getInstance().googleStatus == 1) {
                        viewHolder?.setGone(R.id.rl_google_layout, true)
                    } else {
                        viewHolder?.setGone(R.id.rl_google_layout, false)
                    }
                    /**
                     *Mobile phone
                     */
                    if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                        viewHolder?.setGone(R.id.rl_mail_layout, true)
                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.otypeForPhone =
                            codeType
                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.setType(ComVerifyView.MOBILE)
//                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
//                            ?.sendVerify(ComVerifyView.MOBILE)
                    } else {
                        viewHolder?.setGone(R.id.rl_mail_layout, false)
                    }


                    /**
                     *Old email
                     */
                    viewHolder?.setGone(R.id.rl_new_email_layout, true)
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_new_email)?.otypeForEmail =
                        codeType
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_new_email)
                        ?.setValidation(false)
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.setType(ComVerifyView.EMAIL)
//                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_new_email)
//                        ?.sendVerify(ComVerifyView.EMAIL)

                    /**
                     *New email
                     */
                    viewHolder?.setGone(R.id.rl_phone_layout, true)
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.otypeForEmail =
                        codeType
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.setAccount(newEmail)
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
                        ?.setCountry(countryCode)
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.setValidation(true)
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.setType(ComVerifyView.EMAIL)
//                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
//                        ?.sendVerify(ComVerifyView.EMAIL, true, newEmail)


                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.isEnable(false)

                    //Google verification code
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                    isEnable = false
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_new_email)?.code)) {
                                    isEnable = false
                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        }
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                    isEnable = false
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_new_email)?.code)) {
                                    isEnable = false
                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        }
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                    isEnable = false
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_new_email)?.code)) {
                                    isEnable = false
                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        }
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_new_email)?.onTextListener =
                        object : ComVerifyView.OnTextListener {
                            override fun showText(text: String): String {
                                var isEnable = true
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                        isEnable = false
                                    }
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                    isEnable = false
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_new_email)?.code)) {
                                    isEnable = false
                                }
                                viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                                    ?.isEnable(isEnable)
                                return text
                            }
                        }

                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.listener =
                        object : CommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        ToastUtils.showToast(
                                            LanguageUtil.getString(
                                                context,
                                                "hint_google_certification_code"
                                            )
                                        )
                                    } else {
                                        googleCode =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code
                                                ?: ""
                                    }
                                }
                                if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                        ToastUtils.showToast(
                                            LanguageUtil.getString(
                                                context,
                                                "toast_no_mobile_verification_code"
                                            )
                                        )
                                    } else {
                                        phone =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code
                                                ?: ""
                                    }
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {

                                } else {
                                    newEmailcode =
                                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code
                                            ?: ""
                                }
                                if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_new_email)?.code)) {

                                } else {
                                    oldEmail =
                                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_new_email)?.code
                                            ?: ""
                                }

                                listener.returnCode(phone, oldEmail, newEmailcode, googleCode)
                                viewHolder?.let {
                                    val cvvMail = it.getView<ComVerifyView>(R.id.cv_content_mail)
                                    val cvvNewEmail = it.getView<ComVerifyView>(R.id.cv_content_new_email)
                                    val cvvPhone = it.getView<ComVerifyView>(R.id.cv_content_phone)
                                    val cvvGoogle = it.getView<ComVerifyView>(R.id.cv_content_google)
                                    cvvMail.clearFocus()
                                    cvvNewEmail.clearFocus()
                                    cvvPhone.clearFocus()
                                    cvvGoogle.clearFocus()
                                    cvvMail.resetEditTextColor()
                                    cvvNewEmail.resetEditTextColor()
                                    cvvPhone.resetEditTextColor()
                                    cvvGoogle.resetEditTextColor()
                                    listener.returnCodeWithView(
                                        Pair(phone,cvvMail),
                                        Pair(oldEmail,cvvNewEmail),
                                        Pair(newEmailcode,cvvPhone),
                                        Pair(googleCode,cvvGoogle)
                                    )
                                }

                            }

                        }
                }
                .addOnClickListener(R.id.tv_security_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_security_cancel -> {
                            tDialog.dismiss()

                        }
                    }
                }
                .create()
                .show()
        }


        /**
         *Secondary validation
         */
        fun showSecurityForSecondDialog(
            context: Context,
            codeType: Int,
            listener: DialogSecondListener,
            type: Int = 0,
            loginPwdShow: Boolean,
            confirmTitle: String = "",
            codeType4Email: Int = -1
        ): CpTDialog {
            var phone = ""
            var mail = ""
            var googleCode = ""
            var pwd = ""
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_security_verification_adapter)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.setMaxInputLen(6)

                    viewHolder?.setGone(R.id.ce_account, false)
                    viewHolder?.setGone(R.id.v_line, false)
                    viewHolder?.setGone(R.id.rl_pwd_layout, true)
                    viewHolder?.setText(R.id.tv_mail_title, UserDataService.getInstance().email)
                    viewHolder?.setText(
                        R.id.tv_phone_title,
                        UserDataService.getInstance().mobileNumber
                    )
                    viewHolder?.setText(
                        R.id.tv_google_title,
                        LanguageUtil.getString(context, "personal_text_googleCode")
                    )
                    viewHolder?.setGone(R.id.rl_pwd_layout, loginPwdShow)
                    viewHolder?.setText(
                        R.id.tv_title,
                        LanguageUtil.getString(context, "login_action_fogetpwdSafety")
                    )
                    viewHolder?.setText(
                        R.id.tv_security_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    if (TextUtils.isEmpty(confirmTitle)) {
                        viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                            ?.setContent(LanguageUtil.getString(context, "common_text_btnConfirm"))
                    } else {
                        viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                            ?.setContent(confirmTitle)
                    }

                    viewHolder?.getView<CustomizeEditText>(R.id.ce_account)?.hint =
                        LanguageUtil.getString(context, "userinfo_tip_inputNickname")
                    /**
                     *Whether to bind to Google verification
                     */
                    if (UserDataService.getInstance().googleStatus == 1) {
                        viewHolder?.setGone(R.id.rl_google_layout, true)
                    } else {
                        viewHolder?.setGone(R.id.rl_google_layout, false)
                    }
                    /**
                     *Whether to bind the phone
                     */
                    if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                        viewHolder?.setGone(R.id.rl_phone_layout, true)
                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.otypeForPhone =
                            codeType
                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.verifyType = ComVerifyView.MOBILE
//                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
//                            ?.sendVerify(ComVerifyView.MOBILE)

                    } else {
                        viewHolder?.setGone(R.id.rl_phone_layout, false)

                    }
                    /**
                     *Bind email or not
                     */
                    if (type == 0) {
                        if (!TextUtils.isEmpty(UserDataService.getInstance().email)) {
                            viewHolder?.setGone(R.id.rl_mail_layout, true)
                            if (codeType4Email != -1) {
                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.otypeForEmail =
                                    codeType4Email
                            } else {
                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.otypeForEmail =
                                    codeType
                            }
                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.verifyType = ComVerifyView.EMAIL
//                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
//                                ?.sendVerify(ComVerifyView.EMAIL)

                        } else {
                            viewHolder?.setGone(R.id.rl_mail_layout, false)
                        }
                    } else {
                        viewHolder?.setGone(R.id.rl_mail_layout, false)
                    }
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.isEnable(true)
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.listener =
                        object : CommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        ToastUtils.showToast(
                                            LanguageUtil.getString(
                                                context,
                                                "hint_google_certification_code"
                                            )
                                        )
                                        return
                                    } else {
                                        googleCode =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code
                                                ?: ""
                                    }
                                }
                                if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                        ToastUtils.showToast(
                                            LanguageUtil.getString(
                                                context,
                                                "toast_no_mobile_verification_code"
                                            )
                                        )
                                        return
                                    } else {
                                        phone =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code
                                                ?: ""
                                    }
                                }
                                if (loginPwdShow && TextUtils.isEmpty(
                                        viewHolder?.getView<PwdSettingView>(
                                            R.id.pwd_login_pwd
                                        )?.text
                                    )
                                ) {
                                    ToastUtils.showToast(
                                        LanguageUtil.getString(
                                            context,
                                            "register_tip_inputPassword"
                                        )
                                    )
                                    return
                                } else {
                                    pwd =
                                        viewHolder?.getView<PwdSettingView>(R.id.pwd_login_pwd)?.text
                                            ?: ""
                                }
                                if (type == 0) {
                                    if (!TextUtils.isEmpty(UserDataService.getInstance().email)) {
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                            ToastUtils.showToast(context,LanguageUtil.getString(context, "hint_certification_code_email"))
                                            return
                                        } else {
                                            mail =
                                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code
                                                    ?: ""
                                        }
                                    }
                                }
                                listener.returnCode(phone, mail, googleCode, pwd)
                            }

                        }
                }
                .addOnClickListener(R.id.tv_security_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_security_cancel -> {

                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        /**
         *Secondary validation
         */
        fun showCertificationSecurityForSecondDialog(
            context: Context,
            codeType: Int,
            listener: DialogCertificationSecondListener,
            type: Int = 0,
            loginPwdShow: Boolean,
            confirm: String = ""
        ): CpTDialog {
            var phone = ""
            var mail = ""
            var googleCode = ""
            var pwd = ""
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_security_verification_adapter)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    viewHolder?.getView<PwdSettingView>(R.id.pwd_login_pwd)
                        ?.addFocusList(object : PwdSettingView.FocusChangeListener {
                            override fun focusChange(status: Boolean) {
                                viewHolder?.getView<View>(R.id.v_line_login_pwd)
                                    ?.setBackgroundResource(if (status) R.color.main_blue else R.color.new_edit_line_color)
                            }
                        })

                    viewHolder?.setGone(R.id.ce_account, false)
                    viewHolder?.setGone(R.id.v_line, false)
                    viewHolder?.setGone(R.id.rl_pwd_layout, true)
                    viewHolder?.setText(R.id.tv_mail_title, UserDataService.getInstance().email)
                    viewHolder?.setText(
                        R.id.tv_phone_title,
                        UserDataService.getInstance().mobileNumber
                    )
                    viewHolder?.setText(
                        R.id.tv_google_title,
                        LanguageUtil.getString(context, "personal_text_googleCode")
                    )
                    viewHolder?.setText(
                        R.id.tv_pwd_title,
                        LanguageUtil.getString(context, "register_text_loginPwd")
                    )
                    viewHolder?.getView<PwdSettingView>(R.id.pwd_login_pwd)
                        ?.setHintEditText(LanguageUtil.getString(context, "register_tip_inputPassword"))
                    viewHolder?.setGone(R.id.rl_pwd_layout, loginPwdShow)
                    viewHolder?.setText(
                        R.id.tv_title,
                        LanguageUtil.getString(context, "login_action_fogetpwdSafety")
                    )
                    viewHolder?.setText(
                        R.id.tv_security_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    if (TextUtils.isEmpty(confirm)) {
                        viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                            ?.setContent(LanguageUtil.getString(context, "common_action_next"))
                    } else {
                        viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                            ?.setContent(confirm)
                    }
                    viewHolder?.getView<CustomizeEditText>(R.id.ce_account)?.hint =
                        LanguageUtil.getString(context, "userinfo_tip_inputNickname")
                    /**
                     *Whether to bind to Google verification
                     */
                    if (UserDataService.getInstance().googleStatus == 1) {
                        viewHolder?.setGone(R.id.rl_google_layout, true)
                    } else {
                        viewHolder?.setGone(R.id.rl_google_layout, false)
                    }
                    /**
                     *Whether to bind the phone
                     */
                    if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                        viewHolder?.setGone(R.id.rl_phone_layout, true)
                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.otypeForPhone =
                            codeType
//                        viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)
//                            ?.sendVerify(ComVerifyView.MOBILE)

                    } else {
                        viewHolder?.setGone(R.id.rl_phone_layout, false)

                    }
                    /**
                     *Bind email or not
                     */
                    if (type == 0) {
                        if (!TextUtils.isEmpty(UserDataService.getInstance().email)) {
                            viewHolder?.setGone(R.id.rl_mail_layout, true)
                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.otypeForEmail =
                                codeType
//                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)
//                                ?.sendVerify(ComVerifyView.EMAIL)

                        } else {
                            viewHolder?.setGone(R.id.rl_mail_layout, false)
                        }
                    } else {
                        viewHolder?.setGone(R.id.rl_mail_layout, false)
                    }
                    viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.setMaxInputLen(6)
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.isEnable(true)
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.listener =
                        object : CommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                if (UserDataService.getInstance().googleStatus == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code)) {
                                        ToastUtils.showToast(
                                            LanguageUtil.getString(
                                                context,
                                                "hint_google_certification_code"
                                            )
                                        )
                                        return
                                    } else {
                                        googleCode =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_google)?.code
                                                ?: ""
                                    }
                                }
                                if (UserDataService.getInstance().isOpenMobileCheck == 1) {
                                    if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code)) {
                                        ToastUtils.showToast(
                                            LanguageUtil.getString(
                                                context,
                                                "toast_no_mobile_verification_code"
                                            )
                                        )
                                        return
                                    } else {
                                        phone =
                                            viewHolder?.getView<ComVerifyView>(R.id.cv_content_phone)?.code
                                                ?: ""
                                    }
                                }
                                if (loginPwdShow && TextUtils.isEmpty(
                                        viewHolder?.getView<PwdSettingView>(
                                            R.id.pwd_login_pwd
                                        )?.text
                                    )
                                ) {
                                    ToastUtils.showToast(
                                        LanguageUtil.getString(
                                            context,
                                            "register_tip_inputPassword"
                                        )
                                    )
                                    return
                                } else {
                                    pwd =
                                        viewHolder?.getView<PwdSettingView>(R.id.pwd_login_pwd)?.text
                                            ?: ""
                                }
                                if (type == 0) {
                                    if (TextUtils.isEmpty(UserDataService.getInstance().email)) {
                                        if (TextUtils.isEmpty(viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code)) {
                                        } else {
                                            mail =
                                                viewHolder?.getView<ComVerifyView>(R.id.cv_content_mail)?.code
                                                    ?: ""
                                        }
                                    }
                                }
                                listener.returnCode(phone, mail, googleCode, pwd)
                            }

                        }
                }
                .addOnClickListener(R.id.tv_security_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_security_cancel -> {
                            if (null != listener) {
                                listener.cancelBtn()
                            }
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }


        /**
         *A dialog for an input box
         */
        fun showAloneEdittextDialog(
            context: Context,
            title: String,
            listener: DialogBottomAloneListener
        ): CpTDialog {

            var nickName = ""
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_security_verification_adapter)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setText(R.id.tv_title, title)
                    viewHolder?.setText(
                        R.id.tv_pwd_title,
                        LanguageUtil.getString(context, "register_text_loginPwd")
                    )
                    viewHolder?.getView<PwdSettingView>(R.id.pwd_login_pwd)
                        ?.setHintEditText(LanguageUtil.getString(context, "register_text_loginPwd"))
                    viewHolder?.setText(
                        R.id.tv_security_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.setGone(R.id.rl_google_layout, false)
                    viewHolder?.setGone(R.id.rl_phone_layout, false)
                    viewHolder?.setGone(R.id.rl_mail_layout, false)
                    viewHolder?.setGone(R.id.rl_pwd_layout, false)
                    viewHolder?.setGone(R.id.ce_account, true)
                    var editText = viewHolder?.getView<CustomizeEditText>(R.id.ce_account)
                    editText?.hint = LanguageUtil.getString(context, "userinfo_tip_inputNickname")
                    var v_line = viewHolder?.getView<View>(R.id.v_line)
                    var button = viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                    button?.setContent(LanguageUtil.getString(context, "common_action_next"))
                    editText?.isFocusable = true
                    editText?.isFocusableInTouchMode = true
                    button?.isEnable(false)
                    editText?.setOnFocusChangeListener { v, hasFocus ->
                        v_line?.setBackgroundResource(if (hasFocus) R.color.main_blue else R.color.new_edit_line_color)
                    }

                    editText?.addTextChangedListener(object : TextWatcher {
                        override fun afterTextChanged(s: Editable?) {

                        }

                        override fun beforeTextChanged(
                            s: CharSequence?,
                            start: Int,
                            count: Int,
                            after: Int
                        ) {
                        }

                        override fun onTextChanged(
                            s: CharSequence?,
                            start: Int,
                            before: Int,
                            count: Int
                        ) {
                            nickName = s.toString()
                            if (TextUtils.isEmpty(nickName)) {
                                button?.isEnable(false)
                            } else {
                                button?.isEnable(true)
                            }
                        }
                    })
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.listener =
                        object : CommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                listener.returnContent(nickName)
                            }

                        }
                }
                .addOnClickListener(R.id.tv_security_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_security_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        @RequiresApi(Build.VERSION_CODES.Q)
        fun showNickNameDialog(
            context: Context,
            title: String,
            listener: DialogBottomAloneListener
        ): CpTDialog {

            var nickName = ""
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_security_verification_adapter)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setText(R.id.tv_title, title)
                    viewHolder?.setText(
                        R.id.tv_pwd_title,
                        LanguageUtil.getString(context, "register_text_loginPwd")
                    )
                    viewHolder?.getView<PwdSettingView>(R.id.pwd_login_pwd)
                        ?.setHintEditText(LanguageUtil.getString(context, "register_text_loginPwd"))
                    viewHolder?.setText(
                        R.id.tv_security_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.setGone(R.id.rl_google_layout, false)
                    viewHolder?.setGone(R.id.rl_phone_layout, false)
                    viewHolder?.setGone(R.id.rl_mail_layout, false)
                    viewHolder?.setGone(R.id.rl_pwd_layout, false)
                    viewHolder?.setGone(R.id.ce_account, true)
                    var tverrortip = viewHolder?.getView<TextView>(R.id.tv_error_tip)
                    var editText = viewHolder?.getView<CustomizeEditText>(R.id.ce_account)
                    editText?.hint = LanguageUtil.getString(context, "userinfo_tip_inputNickname")
                    var v_line = viewHolder?.getView<View>(R.id.v_line)
                    var button = viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                    button?.setContent(LanguageUtil.getString(context, "save"))
                    editText?.isFocusable = true
                    editText?.isFocusableInTouchMode = true
                    button?.isEnable(false)
                    editText?.isShowLine = true
                    editText?.setOnFocusChangeListener { v, hasFocus ->
//                            v_line?.setBackgroundResource(if (hasFocus) R.color.main_blue else R.color.new_edit_line_color)
                    }
                    editText?.setMaxLeng(10)
                    editText?.addTextChangedListener(object : TextWatcher {
                        override fun afterTextChanged(s: Editable?) {

                        }

                        override fun beforeTextChanged(
                            s: CharSequence?,
                            start: Int,
                            count: Int,
                            after: Int
                        ) {
                        }

                        override fun onTextChanged(
                            s: CharSequence?,
                            start: Int,
                            before: Int,
                            count: Int
                        ) {
                            nickName = s.toString()
                            if (nickName.length <= 10) {
                                button?.isEnable(true)
                            } else {
                                button?.isEnable(false)
                            }
                            tverrortip?.visibility = View.GONE
                        }
                    })
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.listener =
                        object : CommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
//                                listener.returnContent(nickName)
                                HttpClient.instance.editNickname(nickName)
                                    .subscribeOn(Schedulers.io())
                                    .observeOn(AndroidSchedulers.mainThread())
                                    .subscribe(object : NetObserver<Any>() {
                                        override fun onHandleSuccess(t: Any?) {
                                            listener.returnContent(nickName)
                                            val json = UserDataService.getInstance().userData
                                            if (json != null) {
                                                json.put("nickname", nickName)
                                                UserDataService.getInstance().saveData(json)
                                            }
                                        }


                                        override fun onHandleError(code: Int, msg: String?) {
                                            super.onHandleError(code, msg)
                                            tverrortip?.visibility = View.VISIBLE
                                            tverrortip?.setText(msg)
                                            editText?.isErrorLine = true
                                        }
                                    })
                            }

                        }
                }
                .addOnClickListener(R.id.tv_security_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_security_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        /**
         *Verify Password
         */
        fun showPwdEdittextDialog(
            context: Context,
            title: String,
            listener: DialogBottomPwdListener, content: String
        ): CpTDialog {

            var pwd = ""
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_security_verification_adapter)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    viewHolder?.setText(R.id.tv_title, title)
                    viewHolder?.setText(
                        R.id.tv_pwd_title,
                        LanguageUtil.getString(context, "register_text_loginPwd")
                    )
                    viewHolder?.getView<PwdSettingView>(R.id.pwd_login_pwd)
                        ?.setHintEditText(LanguageUtil.getString(context, "register_text_loginPwd"))
                    viewHolder?.setText(
                        R.id.tv_security_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)
                        ?.setContent(LanguageUtil.getString(context, "common_action_next"))
                    viewHolder?.getView<CustomizeEditText>(R.id.ce_account)?.hint =
                        LanguageUtil.getString(context, "userinfo_tip_inputNickname")


                    viewHolder?.setGone(R.id.tv_pwd_title, false)
                    viewHolder?.setGone(R.id.rl_pwd_layout, true)
                    viewHolder?.setGone(R.id.rl_google_layout, false)
                    viewHolder?.setGone(R.id.rl_phone_layout, false)
                    viewHolder?.setGone(R.id.rl_mail_layout, false)
                    viewHolder?.setGone(R.id.ce_account, false)
                    viewHolder?.setGone(R.id.v_line, false)
                    viewHolder?.getView<PwdSettingView>(R.id.pwd_login_pwd)
                        ?.setHintEditText(content)

                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.isEnable(true)
                    viewHolder?.getView<CommonlyUsedButton>(R.id.tv_confirm)?.listener =
                        object : CommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                if (TextUtils.isEmpty(viewHolder?.getView<PwdSettingView>(R.id.pwd_login_pwd)?.text)) {
                                    ToastUtils.showToast(
                                        LanguageUtil.getString(
                                            context,
                                            "register_tip_inputPassword"
                                        )
                                    )

                                    return
                                } else {
                                    pwd =
                                        viewHolder?.getView<PwdSettingView>(R.id.pwd_login_pwd)?.text
                                            ?: ""
                                }
                                listener.returnContent(pwd)
                            }

                        }
                }
                .addOnClickListener(R.id.tv_security_cancel, R.id.tv_confirm)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_security_cancel -> {
                            listener.returnCancel()
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }


        /**
         *Off site order details click on contact information
         */

        fun OTCOorderContactDialog(
            context: Context,
            numberContent: String,
            emailContent: String,
            listener: DialogBottomListener
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_contact_buy_or_sell_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    if (numberContent.isEmpty()) {
                        viewHolder?.setGone(R.id.tv_number_layout, false)
                    }
                    if (emailContent.isEmpty()) {
                        viewHolder?.setGone(R.id.tv_email_layout, false)
                    }
                    viewHolder?.setText(
                        R.id.tv_contact,
                        LanguageUtil.getString(context, "common_text_contactTitle")
                    )
                    viewHolder?.setText(
                        R.id.tv_number_title,
                        LanguageUtil.getString(context, "personal_text_phoneNumber")
                    )
                    viewHolder?.setText(
                        R.id.tv_email_title,
                        LanguageUtil.getString(context, "register_text_mail")
                    )
                    viewHolder?.setText(
                        R.id.tv_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.setText(R.id.tv_number_content, numberContent)
                    viewHolder?.setText(R.id.tv_email_content, emailContent)
                    viewHolder?.getView<TextView>(R.id.tv_number_content)?.setOnClickListener {
                        ScreenShotUtil.diallPhone(context, numberContent)
                        if (listener != null) {
                            listener.sendConfirm()
                        }
                    }
                }
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }


        /**
         *OTC Buy or Sell
         *Certification
         */

        fun OTCTradingPermissionsDialog(
            context: Context,
            listener: DialogBottomListener,
            type: Int = 1,
            title: String = ""
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_otc_trading_trading_permissions_dialog)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    viewHolder?.setText(R.id.tv_title, LanguageUtil.getString(context, "common_text_tip"))
                    viewHolder?.setText(
                        R.id.tv_nickname_label,
                        LanguageUtil.getString(context, "otcSafeAlert_action_nickname")
                    )
//                        viewHolder?.setText(R.id.tv_phone, LanguageUtil.getString(context, "title_bind_phone"))
                    viewHolder?.setText(
                        R.id.tv_google_label,
                        LanguageUtil.getString(context, "otcSafeAlert_action_bindphoneOrGoogle")
                    )
                    viewHolder?.setText(
                        R.id.tv_identify_label,
                        LanguageUtil.getString(context, "kyc_page_name")
                    )
//                        viewHolder?.setText(R.id.tv_cancel, LanguageUtil.getString(context, "common_text_btnCancel"))
//                        viewHolder?.setText(R.id.tv_goto_set, LanguageUtil.getString(context, "common_text_btnSetting"))


                    if (type != 1) {
                        viewHolder?.setGone(R.id.ll_nick_layout, false)
                        if (type != -1) {
                            viewHolder?.setGone(R.id.ll_trading_real_layout, false)
                        }
                    }
                    if (!TextUtils.isEmpty(title)) {
                        viewHolder?.setText(R.id.tv_trading_content, title)
                    } else {
                        val currencyTypeTitle =
                            if (PublicInfoDataService.getInstance().getB2CSwitchOpen(null)) {
                                LanguageUtil.getString(context, "otcSafeAlert_text_title_forotc")
                            } else {
                                LanguageUtil.getString(context, "otcSafeAlert_text_title")
                            }
                        viewHolder?.setText(R.id.tv_trading_content, currencyTypeTitle)
                    }

                    if (TextUtils.isEmpty(UserDataService.getInstance().nickName)) {
                        viewHolder?.getView<TextView>(R.id.tv_nickname)?.isEnabled = true
//                            viewHolder?.getView<ImageView>(R.id.iv_nickname)?.setImageResource(R.drawable.fiat_unfinished)
                        viewHolder?.getView<TextView>(R.id.tv_nickname)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                        viewHolder?.getView<TextView>(R.id.tv_nickname)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text17"))
                    } else {
                        viewHolder?.getView<TextView>(R.id.tv_nickname)?.isEnabled = false
                        viewHolder?.getView<TextView>(R.id.tv_nickname)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                        viewHolder?.getView<TextView>(R.id.tv_nickname)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text16"))
//                            viewHolder?.getView<ImageView>(R.id.iv_nickname)?.setImageResource(R.drawable.fiat_complete)
                    }
                    if (UserDataService.getInstance().isOpenMobileCheck != 1 && UserDataService.getInstance().googleStatus != 1) {
//                            viewHolder?.getView<ImageView>(R.id.iv_google)?.setImageResource(R.drawable.fiat_unfinished)
                        viewHolder?.getView<TextView>(R.id.tv_google)?.isEnabled = true
                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text17"))
                    } else {
//                            viewHolder?.getView<ImageView>(R.id.iv_google)?.setImageResource(R.drawable.fiat_complete)
                        viewHolder?.getView<TextView>(R.id.tv_google)?.isEnabled = false
                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text16"))
                    }

                    if (UserDataService.getInstance().authLevel==0) {
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.isEnabled = true
//                            viewHolder?.getView<ImageView>(R.id.iv_realname_certification)?.setImageResource(R.drawable.fiat_unfinished)
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text17"))
                    } else {
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.isEnabled = false
//                            viewHolder?.getView<ImageView>(R.id.iv_realname_certification)?.setImageResource(R.drawable.fiat_complete)
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text16"))
                    }

                }
                .addOnClickListener(
                    R.id.tv_realname_certification,
                    R.id.tv_google,
                    R.id.tv_nickname,
                    R.id.tv_cancel
                )
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when(view.id){
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        else -> {
                            tDialog.dismiss()
                            listener?.sendConfirm(view)
                        }
                    }

                }
                .create()
                .show()
        }


        /**
         *Real name authentication is required
         *Certification
         */
        fun OTCTradingMustPermissionsDialog(
            context: Context,
            listener: DialogBottomListener,
            type: Int = 1,
            title: String = ""
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_validation_must_dialog)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    if (type != 1) {
                        viewHolder?.setGone(R.id.ll_nick_layout, false)
                        if (type != -1) {
                            viewHolder?.setGone(R.id.ll_trading_real_layout, false)
                        }
                    }
                    viewHolder?.setText(R.id.tv_title, LanguageUtil.getString(context, "common_text_tip"))
                    viewHolder?.setText(
                        R.id.tv_nick_name,
                        LanguageUtil.getString(context, "otcSafeAlert_action_nickname")
                    )
                    viewHolder?.setText(
                        R.id.tv_google,
                        LanguageUtil.getString(context, "otcSafeAlert_action_bindphoneOrGoogle")
                    )
                    viewHolder?.setText(
                        R.id.tv_realname_certification,
                        LanguageUtil.getString(context, "otcSafeAlert_action_identify")
                    )
                    viewHolder?.setText(
                        R.id.tv_real_auth,
                        LanguageUtil.getString(context, "kyc_page_name")
                    )

//                        viewHolder?.setText(R.id.tv_cancel, LanguageUtil.getString(context, "common_text_btnCancel"))
//                        viewHolder?.setText(R.id.tv_goto_set, LanguageUtil.getString(context, "common_text_btnSetting"))
                    if (!TextUtils.isEmpty(title)) {
                        viewHolder?.setText(R.id.tv_validation_content, title)
                    } else {
                        val currencyTypeTitle =
                            if (PublicInfoDataService.getInstance().getB2CSwitchOpen(null)) {
                                LanguageUtil.getString(context, "otcSafeAlert_text_title_forotc")
                            } else {
                                LanguageUtil.getString(context, "otcSafeAlert_text_title")
                            }
                        viewHolder?.setText(R.id.tv_validation_content, currencyTypeTitle)
                    }

                    if (TextUtils.isEmpty(UserDataService.getInstance().nickName)) {
                        viewHolder?.getView<TextView>(R.id.tv_nickname_set)
                            ?.isEnabled = true
//                            viewHolder?.getView<ImageView>(R.id.iv_nickname)?.setImageResource(R.drawable.fiat_unfinished)
                        viewHolder?.getView<TextView>(R.id.tv_nickname_set)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                        viewHolder?.getView<TextView>(R.id.tv_nickname_set)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text17"))
                    } else {
                        viewHolder?.getView<TextView>(R.id.tv_nickname_set)
                            ?.isEnabled = false
//                            viewHolder?.getView<ImageView>(R.id.iv_nickname)?.setImageResource(R.drawable.fiat_complete)

                        viewHolder?.getView<TextView>(R.id.tv_nickname_set)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                        viewHolder?.getView<TextView>(R.id.tv_nickname_set)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text16"))
                    }

                    if (UserDataService.getInstance().googleStatus != 1) {
//                            viewHolder?.getView<ImageView>(R.id.iv_google)?.setImageResource(R.drawable.fiat_unfinished)
                        viewHolder?.getView<TextView>(R.id.tv_google)?.isEnabled = true
                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text17"))
                    } else {
//                            viewHolder?.getView<ImageView>(R.id.iv_google)?.setImageResource(R.drawable.fiat_complete)
                        viewHolder?.getView<TextView>(R.id.tv_google)?.isEnabled = false
                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text16"))
                    }

                    if (UserDataService.getInstance().authLevel == 0) {
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.isEnabled = true
//                            viewHolder?.getView<ImageView>(R.id.iv_realname_certification)?.setImageResource(R.drawable.fiat_unfinished)
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text17"))
                    } else {
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.isEnabled = false
//                            viewHolder?.getView<ImageView>(R.id.iv_realname_certification)?.setImageResource(R.drawable.fiat_complete)

                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text16"))
                    }

                }
                .addOnClickListener(
                    R.id.tv_realname_certification,
                    R.id.tv_google,
                    R.id.tv_nickname_set,
                    R.id.tv_cancel
                )
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    tDialog.dismiss()
                    listener.sendConfirm(view)
                    when (view.id) {
                        R.id.tv_google -> {
                            tDialog.dismiss()
                            listener.sendConfirm()
                        }
                        R.id.tv_nickname_set -> {
                            tDialog.dismiss()
                            listener.sendConfirm()
                        }
                        R.id.tv_realname_certification -> {
                            listener.sendConfirm()
                            tDialog.dismiss()
                        }
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        /**
         *Only judge real name authentication
         */
        fun OTCTradingOnlyPermissionsDialog(
            context: Context,
            listener: DialogBottomListener,
            title: String = ""
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_validation_must_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setGone(R.id.ll_nick_layout, false)
                    viewHolder?.setGone(R.id.ll_google_layout, false)
                    viewHolder?.setText(
                        R.id.tv_tip,
                        LanguageUtil.getString(context, "common_text_tip")
                    )
                    viewHolder?.setText(
                        R.id.tv_nickname,
                        LanguageUtil.getString(context, "otcSafeAlert_action_nickname")
                    )
                    viewHolder?.setText(
                        R.id.tv_google,
                        LanguageUtil.getString(context, "otcSafeAlert_action_bindGoogle")
                    )
                    viewHolder?.setText(
                        R.id.tv_realname_certification,
                        LanguageUtil.getString(context, "otcSafeAlert_action_identify")
                    )
                    viewHolder?.setText(
                        R.id.tv_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.setText(
                        R.id.tv_goto_set,
                        LanguageUtil.getString(context, "common_text_btnSetting")
                    )

                    if (!TextUtils.isEmpty(title)) {
                        viewHolder?.setText(R.id.tv_validation_content, title)
                    } else {
                        val currencyTypeTitle =
                            if (PublicInfoDataService.getInstance().getB2CSwitchOpen(null)) {
                                LanguageUtil.getString(context, "otcSafeAlert_text_title_forotc")
                            } else {
                                LanguageUtil.getString(context, "otcSafeAlert_text_title")
                            }
                        viewHolder?.setText(R.id.tv_validation_content, currencyTypeTitle)
                    }

                    if (UserDataService.getInstance().authLevel != 1) {
                        viewHolder?.getView<ImageView>(R.id.iv_realname_certification)
                            ?.setImageResource(R.drawable.fiat_unfinished)
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                    } else {
                        viewHolder?.getView<ImageView>(R.id.iv_realname_certification)
                            ?.setImageResource(R.drawable.fiat_complete)
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                    }

                }
                .addOnClickListener(R.id.tv_goto_set, R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_goto_set -> {
                            listener.sendConfirm()
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }


        /**
         *Contract adjustment margin
         */
        fun adjustDepositDialog(
            context: Context,
            jsonObject: JSONObject,
            listener: DialogBottomAloneListener
        ) {
            val side = jsonObject.optString("side")
            val volume = jsonObject.optString("volume")
            val usedMargin = jsonObject.optString("usedMargin")
            val canUseMargin = jsonObject.optString("canUseMargin")
            var isAdd = true

            /**
             *Deposit quantity
             */
            var depositAmount = ""

            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_adjust_deposit)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setText(
                        R.id.rb_add_deposit,
                        LanguageUtil.getString(context, "contract_action_increaseMargin")
                    )
                    viewHolder?.setText(
                        R.id.btn_adjust_deposit,
                        LanguageUtil.getString(context, "common_text_btnConfirm")
                    )
                    viewHolder?.setText(
                        R.id.rb_sub_deposit,
                        LanguageUtil.getString(context, "contract_action_decreaseMargin")
                    )
                    viewHolder?.setText(
                        R.id.tv_deposit_title,
                        LanguageUtil.getString(context, "contract_text_increaseMarginVolume")
                    )
                    viewHolder?.getView<EditText>(R.id.et_deposit_amount)?.hint =
                        LanguageUtil.getString(context, "contract_text_increaseMarginVolume")
                    viewHolder?.getView<PositionITemView>(R.id.pit_position_amount)
                        ?.setHeadTitle(LanguageUtil.getString(context, "position_amount"))
                    viewHolder?.getView<PositionITemView>(R.id.pit_allocated_deposit)
                        ?.setHeadTitle(LanguageUtil.getString(context, "contract_allocated_margin"))
                    viewHolder?.getView<PositionITemView>(R.id.pit_available_deposit)?.setHeadTitle(
                        LanguageUtil.getString(
                            context,
                            "contract_distributable_security"
                        )
                    )
                    viewHolder?.getView<RadioGroup>(R.id.rg_deposit)
                        ?.setOnCheckedChangeListener { group, checkedId ->
                            when (checkedId) {
                                R.id.rb_add_deposit -> {
                                    viewHolder.getView<EditText>(R.id.et_deposit_amount).hint =
                                        LanguageUtil.getString(
                                            context,
                                            "contract_text_increaseMarginVolume"
                                        )
                                    viewHolder.getView<TextView>(R.id.tv_deposit_title).text =
                                        LanguageUtil.getString(
                                            context,
                                            "contract_text_increaseMarginVolume"
                                        )
                                    isAdd = true
                                }

                                R.id.rb_sub_deposit -> {
                                    viewHolder.getView<EditText>(R.id.et_deposit_amount).hint =
                                        LanguageUtil.getString(
                                            context,
                                            "contract_text_decreaseMarginVolume"
                                        )
                                    viewHolder.getView<TextView>(R.id.tv_deposit_title).text =
                                        LanguageUtil.getString(
                                            context,
                                            "contract_text_decreaseMarginVolume"
                                        )
                                    isAdd = false
                                }
                            }
                        }

                    /**
                     *Number of positions (pieces)
                     */
                    val pit_position_amount =
                        viewHolder?.getView<PositionITemView>(R.id.pit_position_amount)
                    pit_position_amount?.tailValueColor = ColorUtil.getMainColorType(side == "BUY")
                    if (side == "BUY") {
                        pit_position_amount?.value = "+${volume}"
                    } else {
                        pit_position_amount?.value = "-${volume}"
                    }

                    /**
                     *Allocated margin
                     */
                    viewHolder?.getView<PositionITemView>(R.id.pit_allocated_deposit)?.run {
                        val usedMargin =
                            Contract2PublicInfoManager.cutDespoitByPrecision(usedMargin)
                        value = usedMargin
                        title =
                            LanguageUtil.getString(context, "contract_allocated_margin") + " (BTC)"
                    }

                    /**
                     *Available margin
                     */
                    viewHolder?.getView<PositionITemView>(R.id.pit_available_deposit)?.run {
                        val canUseMargin =
                            Contract2PublicInfoManager.cutDespoitByPrecision(canUseMargin)
                        value = canUseMargin
                        title = LanguageUtil.getString(
                            context,
                            "contract_text_availableMargin"
                        ) + "(BTC)"
                    }

                    viewHolder?.getView<TextView>(R.id.tv_base_symbol)?.text = "BTC"

                    val btn_adjust_deposit = viewHolder?.getView<TextView>(R.id.btn_adjust_deposit)

                    val et_deposit_amount = viewHolder?.getView<EditText>(R.id.et_deposit_amount)
                    et_deposit_amount?.filters = arrayOf(
                        DecimalDigitsInputFilter(
                            Contract2PublicInfoManager.getCoinByName("btc")?.showPrecision
                                ?: 8
                        )
                    )

                    et_deposit_amount?.addTextChangedListener(object : TextWatcher {
                        override fun afterTextChanged(s: Editable?) {
                            depositAmount = s.toString()
                            btn_adjust_deposit?.isEnabled = !TextUtils.isEmpty(depositAmount)
                            if (TextUtils.isEmpty(depositAmount)) {
                                btn_adjust_deposit?.backgroundColorResource =
                                    R.color.normal_text_color
                            } else {
                                btn_adjust_deposit?.backgroundColorResource = R.color.main_blue
                            }
                        }

                        override fun beforeTextChanged(
                            s: CharSequence?,
                            start: Int,
                            count: Int,
                            after: Int
                        ) {
                        }

                        override fun onTextChanged(
                            s: CharSequence?,
                            start: Int,
                            before: Int,
                            count: Int
                        ) {
                        }

                    })


                }
                .addOnClickListener(R.id.tv_cancel, R.id.btn_adjust_deposit)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.btn_adjust_deposit -> {
                            val activity = context as Activity
                            if (TextUtils.isEmpty(depositAmount)) return@setOnViewClickListener
                            if (depositAmount.toDouble() == 0.0) {
                                tDialog.dismiss()
                                NToastUtil.showTopToastNet(
                                    activity,
                                    false,
                                    LanguageUtil.getString(context, "transfer_tip_emptyVolume")
                                )

                                return@setOnViewClickListener
                            }

//Log. d ("==Deposit==", "===depositAmount: ${depositAmount. toDouble()}, canUseMargin ${position. canUseMargin}==")
                            if (isAdd && (depositAmount.toDouble() > canUseMargin.toDoubleOrNull() ?: 0.0)) {
                                tDialog.dismiss()
                                NToastUtil.showTopToastNet(
                                    activity,
                                    false,
                                    LanguageUtil.getString(context, "contract_tip_volumeError")
                                )
                                return@setOnViewClickListener
                            }
                            var value = if (isAdd) depositAmount else "-$depositAmount"
                            listener.returnContent(value)
                            tDialog.activity?.window?.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN)
                            tDialog.dismiss()
                            //Turn off keyboard
                            val inputManager =
                                context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                            Log.d("=isActive=", "=======${inputManager.isActive}===========")
                            inputManager.hideSoftInputFromWindow(
                                context.window?.decorView?.windowToken,
                                0
                            )
                        }
                    }
                }
                .create()
                .show()
        }


        /**
         *KYC verification dialog
         */
        fun KycSecurityDialog(
            context: Context,
            contentTitle: String,
            listener: DialogBottomListener
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_otc_trading_security_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    val tipsTitle = contentTitle

                    viewHolder?.setText(R.id.tv_tips_title, tipsTitle)

                    viewHolder?.setText(
                        R.id.tv_money_password,
                        context.getString(R.string.otcSafeAlert_action_identify)
                    )
                    viewHolder?.getView<ImageView>(R.id.iv_money_password)
                        ?.setImageResource(R.drawable.fiat_unfinished)
                    viewHolder?.getView<TextView>(R.id.tv_money_password)
                        ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))


                    viewHolder?.setGone(R.id.rl_collect_money_layout, false)

                }
                .addOnClickListener(R.id.tv_goto_set, R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_goto_set -> {
                            listener.sendConfirm()
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        /**
         *OTC Buy or Sell
         *Security
         */
        fun OTCTradingSecurityDialog(
            context: Context,
            listener: DialogBottomListener,
            paymentStatus: Boolean,
            isCheckCapitalPwordSet:Boolean? = false
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_otc_trading_security_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    val tipsTitle =
                        if (PublicInfoDataService.getInstance().getB2CSwitchOpen(null)) {
                            LanguageUtil.getString(context, "otcSafeAlert_text_settingDesc_forotc")
                        } else {
                            LanguageUtil.getString(context, "otcSafeAlert_text_settingDesc")
                        }

                    viewHolder?.setText(R.id.tv_tips_title, tipsTitle)
                    viewHolder?.setText(
                        R.id.tv_tip,
                        LanguageUtil.getString(context, "common_text_tip")
                    )
                    viewHolder?.setText(
                        R.id.tv_money_password,
                        LanguageUtil.getString(context, "safety_action_otcPassword")
                    )
                    viewHolder?.setText(
                        R.id.tv_collect_money,
                        LanguageUtil.getString(context, "noun_order_paymentTerm")
                    )
                    viewHolder?.setText(
                        R.id.tv_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.setText(
                        R.id.tv_goto_set,
                        LanguageUtil.getString(context, "common_text_btnSetting")
                    )

                    viewHolder?.setGone(R.id.ll_capitalPwordSet,isCheckCapitalPwordSet!!)
                    if(isCheckCapitalPwordSet!!){
                        if (UserDataService.getInstance().isCapitalPwordSet != 1) {
                            viewHolder?.getView<ImageView>(R.id.iv_money_password)
                                ?.setImageResource(R.mipmap.public_deleteall)
                            viewHolder?.getView<TextView>(R.id.tv_money_password)
                                ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                        } else {
                            viewHolder?.getView<ImageView>(R.id.iv_money_password)
                                ?.setImageResource(R.drawable.ic_public_icon_check_mark)
                            viewHolder?.getView<TextView>(R.id.tv_money_password)
                                ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                        }
                    }

                    if (!paymentStatus) {
                        viewHolder?.getView<ImageView>(R.id.iv_collect_money)
                            ?.setImageResource(R.mipmap.public_deleteall)
                        viewHolder?.getView<TextView>(R.id.tv_collect_money)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                    } else {
                        viewHolder?.getView<ImageView>(R.id.iv_collect_money)
                            ?.setImageResource(R.drawable.ic_public_icon_check_mark)
                        viewHolder?.getView<TextView>(R.id.tv_collect_money)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                    }


                }
                .addOnClickListener(R.id.tv_goto_set, R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_goto_set -> {
                            listener.sendConfirm()
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }


        /**
         *OTC nickname or payment method
         *Security
         */
        fun OTCTradingSecurityNickAndPaymentDialog(
            context: Context,
            listener: DialogBottomListener,
            paymentStatus: Boolean
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_otc_trading_security_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setText(
                        R.id.tv_money_password,
                        LanguageUtil.getString(context, "nickname")
                    )

                    val tipsTitle =
                        if (PublicInfoDataService.getInstance().getB2CSwitchOpen(null)) {
                            LanguageUtil.getString(context, "otcSafeAlert_text_settingDesc_forotc")
                        } else {
                            LanguageUtil.getString(context, "otcSafeAlert_text_settingDesc")
                        }

                    viewHolder?.setText(R.id.tv_tips_title, tipsTitle)
                    viewHolder?.setText(
                        R.id.tv_money_password,
                        LanguageUtil.getString(context, "safety_action_otcPassword")
                    )
                    viewHolder?.setText(
                        R.id.tv_collect_money,
                        LanguageUtil.getString(context, "noun_order_paymentTerm")
                    )
                    viewHolder?.setText(
                        R.id.tv_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.setText(
                        R.id.tv_goto_set,
                        LanguageUtil.getString(context, "common_text_btnSetting")
                    )

                    if (UserDataService.getInstance().nickName.isEmpty()) {
                        viewHolder?.getView<ImageView>(R.id.iv_money_password)
                            ?.setImageResource(R.drawable.fiat_unfinished)
                        viewHolder?.getView<TextView>(R.id.tv_money_password)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                    } else {
                        viewHolder?.getView<ImageView>(R.id.iv_money_password)
                            ?.setImageResource(R.drawable.fiat_complete)
                        viewHolder?.getView<TextView>(R.id.tv_money_password)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                    }
                    if (UserDataService.getInstance().nickName.isNotEmpty()) {
                        viewHolder?.getView<ImageView>(R.id.iv_collect_money)
                            ?.setImageResource(R.drawable.fiat_unfinished)
                        viewHolder?.getView<TextView>(R.id.tv_collect_money)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                    } else if (paymentStatus) {
                        viewHolder?.getView<ImageView>(R.id.iv_collect_money)
                            ?.setImageResource(R.drawable.fiat_unfinished)
                        viewHolder?.getView<TextView>(R.id.tv_collect_money)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                    } else {
                        viewHolder?.getView<ImageView>(R.id.iv_collect_money)
                            ?.setImageResource(R.drawable.fiat_complete)
                        viewHolder?.getView<TextView>(R.id.tv_collect_money)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                    }


                }
                .addOnClickListener(R.id.tv_goto_set, R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_goto_set -> {
                            listener.sendConfirm()
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        /**
         *OTC Buy or Sell
         *Security
         */

        fun OTCTradingNickeSecurityDialog(
            context: Context,
            listener: DialogBottomListener
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_otc_trading_security_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    val tipsTitle =
                        if (PublicInfoDataService.getInstance().getB2CSwitchOpen(null)) {
                            LanguageUtil.getString(context, "otcSafeAlert_text_settingDesc_forotc")
                        } else {
                            LanguageUtil.getString(context, "otcSafeAlert_text_settingDesc")
                        }

                    viewHolder?.setText(R.id.tv_tips_title, tipsTitle)
                    viewHolder?.setText(
                        R.id.tv_tip,
                        LanguageUtil.getString(context, "common_text_tip")
                    )

                    viewHolder?.setText(
                        R.id.tv_money_password,
                        LanguageUtil.getString(context, "nickname")
                    )
                    viewHolder?.setText(
                        R.id.tv_collect_money,
                        LanguageUtil.getString(context, "otcSafeAlert_action_identify")
                    )
                    viewHolder?.setText(
                        R.id.tv_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.setText(
                        R.id.tv_goto_set,
                        LanguageUtil.getString(context, "common_text_btnSetting")
                    )
                    if (UserDataService.getInstance().nickName.isEmpty()) {
                        viewHolder?.getView<ImageView>(R.id.iv_money_password)
                            ?.setImageResource(R.drawable.fiat_unfinished)
                        viewHolder?.getView<TextView>(R.id.tv_money_password)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                    } else {
                        viewHolder?.getView<ImageView>(R.id.iv_money_password)
                            ?.setImageResource(R.drawable.fiat_complete)
                        viewHolder?.getView<TextView>(R.id.tv_money_password)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                    }
                    if (UserDataService.getInstance().authLevel != 1) {
                        viewHolder?.getView<ImageView>(R.id.iv_collect_money)
                            ?.setImageResource(R.drawable.fiat_unfinished)
                        viewHolder?.getView<TextView>(R.id.tv_collect_money)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                    } else {
                        viewHolder?.getView<ImageView>(R.id.iv_collect_money)
                            ?.setImageResource(R.drawable.fiat_complete)
                        viewHolder?.getView<TextView>(R.id.tv_collect_money)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                    }


                }
                .addOnClickListener(R.id.tv_goto_set, R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_goto_set -> {
                            listener.sendConfirm()
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }


        /**
         *Transaction confirmation payment
         */
        fun tradingOTCConfirm(
            context: Context,
            title: String,
            payment: String,
            accountName: String,
            peyAmount: String,
            listener: DialogBottomListener,
                rightString: String = "",
            buyOrSell: Boolean = false
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_confirm_payment)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    if (rightString.isNotEmpty()) {
                        viewHolder?.setText(R.id.tv_confirm, rightString)
                    } else {
                        viewHolder?.setText(
                            R.id.tv_confirm,
                            LanguageUtil.getString(context, "common_text_btnConfirm")
                        )

                    }
                    viewHolder?.setText(R.id.tv_payment_type, payment)
                    viewHolder?.setText(R.id.tv_title, title)
                    viewHolder?.setText(
                        R.id.tv_confirm_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )

                    viewHolder?.setText(R.id.tv_account_name, accountName)
                    viewHolder?.setText(R.id.tv_payment_amount, peyAmount)
                    if (buyOrSell) {
                        viewHolder?.setText(
                            R.id.tv_content,
                            LanguageUtil.getString(context, "otc_tip_remindBuyerClickDidPay")
                        )
                        viewHolder?.setText(
                            R.id.tv_1_content,
                            LanguageUtil.getString(context, "noun_order_paymentTerm")
                        )
                        viewHolder?.setText(
                            R.id.tv_2_content,
                            LanguageUtil.getString(context, "otc_text_payee")
                        )
                        viewHolder?.setText(
                            R.id.tv_3_content,
                            LanguageUtil.getString(context, "otc_text_paymentAmount")
                        )
                        viewHolder?.setText(
                            R.id.tv_confirm,
                            LanguageUtil.getString(context, "common_text_btnConfirm")
                        )

                    } else {
                        viewHolder?.setText(
                            R.id.tv_content,
                            LanguageUtil.getString(context, "otc_tip_remindSellerSendCoin")
                        )
                        viewHolder?.setText(
                            R.id.tv_1_content,
                            LanguageUtil.getString(context, "common_text_paymentTypeBuyer")
                        )
                        viewHolder?.setText(
                            R.id.tv_2_content,
                            LanguageUtil.getString(context, "otc_text_payee")
                        )
                        viewHolder?.setText(
                            R.id.tv_3_content,
                            LanguageUtil.getString(context, "journalAccount_text_amount")
                        )
                        viewHolder?.setText(
                            R.id.tv_confirm,
                            LanguageUtil.getString(context, "otc_action_confirmSendCoin")
                        )
                    }

                }
                .addOnClickListener(R.id.tv_confirm, R.id.tv_confirm_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_confirm_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_confirm -> {
                            listener.sendConfirm()
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }


        /**
         *Transaction cancellation order
         */
        fun tradingOTCCancelOrder(context: Context, listener: DialogBottomListener) {
            var isTurelyChecked = false
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_cancel_order)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    viewHolder?.setText(
                        R.id.tv_otc_action_cancel,
                        LanguageUtil.getString(context, "otc_action_cancel")
                    )
                    viewHolder?.setText(
                        R.id.tv_oct_tip_buyerCancel,
                        LanguageUtil.getString(context, "oct_tip_buyerCancel")
                    )
                    viewHolder?.setText(
                        R.id.cb_pay,
                        LanguageUtil.getString(context, "otc_tip_buyerCancelConfirm")
                    )
                    viewHolder?.setText(
                        R.id.tv_order_cancel,
                        LanguageUtil.getString(context, "common_action_thinkAgain")
                    )
                    viewHolder?.setText(
                        R.id.tv_confirm,
                        LanguageUtil.getString(context, "common_text_btnConfirm")
                    )

                    viewHolder?.getView<CheckBox>(R.id.cb_pay)
                        ?.setOnCheckedChangeListener { buttonView, isChecked ->
                            if (isChecked) {
                                isTurelyChecked = true
                                viewHolder.getView<TextView>(R.id.tv_confirm)?.setTextColor(
                                    ContextCompat.getColor(
                                        context,
                                        R.color.main_blue
                                    )
                                )
                            } else {
                                isTurelyChecked = false
                                viewHolder.getView<TextView>(R.id.tv_confirm)?.setTextColor(
                                    ContextCompat.getColor(
                                        context,
                                        R.color.normal_text_color
                                    )
                                )
                            }
                        }
                }
                .addOnClickListener(R.id.tv_confirm, R.id.tv_order_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_order_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_confirm -> {
                            if (isTurelyChecked) {
                                listener.sendConfirm()
                                tDialog.dismiss()
                            }

                        }
                    }
                }
                .create()
                .show()
        }


        /**
         *Display a regular dialog for a button
         */
        fun showSingleDialog(
            context: Context,
            content: String,
            listener: DialogBottomListener?,
            title: String = "",
            cancelTitle: String = "",
            isFormatHtml: Boolean = true
        ) {
            showDialog(
                context,
                content,
                true,
                listener,
                title,
                cancelTitle,
                "",
                false,
                isFormatHtml
            )
        }

        fun showSingle2Dialog(
            context: Context,
            content: String,
            listener: DialogBottomListener,
            title: String = "",
            cancelTitle: String = ""
        ) {
            showDialog(context, content, true, listener, title, cancelTitle, "", true)
        }

        /**
         *Display a dialog for two buttons
         */

        fun showNormalDialog(
            context: Context,
            content: String? = "",
            listener: DialogBottomListener,
            title: String = "",
            cancelTitle: String = "",
            confirmTitle: String = ""
        ) {
            showDialog(
                context,
                content.toString(),
                false,
                listener,
                title,
                cancelTitle,
                confirmTitle
            )
        }

        /**
         *Transfer Record
         */
        fun showNormalTransferDialog(
            context: Context,
            content: String,
            listener: DialogTransferBottomListener,
            title: String = "",
            cancelTitle: String = "",
            confirmTitle: String = ""
        ) {
            showTransferDialog(context, content, false, listener, title, cancelTitle, confirmTitle)
        }


        /**
         *String list bottom dialog
         *
         */
        fun showBottomListDialog(
            context: Context,
            list: ArrayList<String>,
            position: Int,
            listener: DialogOnclickListener
        ): CpTDialog {
            return showListDialog(context, list, position, listener)
        }

        /**
         *Add this function to the contract function
         */
        fun showNewBottomListDialog(
            context: Context,
            list: ArrayList<CpTabInfo>,
            position: Int,
            listener: DialogOnItemClickListener
        ): CpTDialog {
            return showNewListDialog(context, list, position, listener)
        }



        /**
         *Show security verification based on security selection
         *@param type -1 is all displayed
         */
        fun showSecurityDialog(
            context: Context,
            type: Int = -1,
            codeType: Int,
            listener: DialogVerifiactionListener,
            emailType: Int = -1,
            confirmTitle: String = ""
        ): CpTDialog {
            return showSecurityVerificationDialog(
                context,
                type,
                codeType,
                listener,
                emailType,
                confirmTitle
            )
        }


        /**
         *A dialog with only one input box
         */
        fun showAloneDialog(
            context: Context,
            title: String,
            listener: DialogBottomAloneListener
        ): CpTDialog {
            return showAloneEdittextDialog(context, title, listener)
        }

        /**
         *Verify password dialog
         */
        fun showPwdDialog(
            context: Context,
            title: String,
            listener: DialogBottomPwdListener,
            content: String = ""
        ): CpTDialog {
            return showPwdEdittextDialog(context, title, listener, content)
        }

        /**
         *Verification of normal bounce based on user information
         *@param type 0 Normal 1: Pop up Google and Phone
         *
         */
        fun showBindDialog(
            context: Context,
            codeType: Int,
            listener: DialogVerifiactionListener,
            type: Int = 0,
            account: String = ""
        ): CpTDialog {
            return showSecurityForBindDialog(context, codeType, listener, type)
        }

        /**
         *Modify mobile verification
         */
        fun showBindPhoneCodeDialog(
            context: Context,
            codeType: Int,
            listener: DialogVerifiactionListener,
            lisDis: DialogDismissListener,
        ): CpTDialog {
            return showSecurityForBindPhoneCodeDialog(context, codeType, listener,lisDis)
        }

        /**
         *Modify mobile verification
         */
        fun showBindPhoneDialog(
            context: Context,
            codeType: Int,
            listener: DialogVerifiactionListener,
            account: String = "",
            countryCode: String = ""
        ): CpTDialog {
            return showSecurityForBindPhoneDialog(context, codeType, account, countryCode, listener)
        }

        /**
         *Modify mobile verification
         */
        fun showChangePhoneDialog(
            context: Context,
            codeType: Int,
            listener: DialogVerifiactionListener,
            account: String = "",
            countryCode: String = ""
        ): CpTDialog {
            return showSecurityForChangePhoneDialog(
                context,
                codeType,
                account,
                countryCode,
                listener
            )
        }


        /**
         *Modify email
         */
        fun showBindEmailDialog(
            context: Context,
            codeType: Int,
            listener: DialogReturnChangeEmail,
            account: String = "",
            countryCode: String = ""
        ): CpTDialog {
            return showSecurityForBindEmailDialog(context, codeType, account, countryCode, listener)
        }


        /**
         *According to
         *@param type 0 Normal 1: Pop up Google and Phone
         *
         */
        fun showAccountBindDialog(
            context: Context,
            account: String,
            type: Int = -1,
            codeType: Int,
            listener: DialogVerifiactionListener
        ): CpTDialog {
            return showAccountDialog(context, type, account, codeType, listener)
        }

        /**
         *Secondary validation
         */
        fun showSecondDialog(
            context: Context,
            cointype: Int,
            listener: DialogSecondListener,
            type: Int = 1,
            loginPwdShow: Boolean = true,
            confirmTitle: String = "",
            cointype4Email: Int = -1
        ): CpTDialog {
            return showSecurityForSecondDialog(
                context,
                cointype,
                listener,
                type,
                loginPwdShow,
                confirmTitle,
                cointype4Email
            )
        }

        fun showCertificationSecondDialog(
            context: Context,
            cointype: Int,
            listener: DialogCertificationSecondListener,
            type: Int = 1,
            loginPwdShow: Boolean = true,
            confirmTitle: String = ""
        ): CpTDialog {
            return showCertificationSecurityForSecondDialog(
                context,
                cointype,
                listener,
                type,
                loginPwdShow,
                confirmTitle
            )
        }


        /**
         *Show only Google issues
         */
        fun showOnlyGoogleDialog(
            context: Context,
            listener: DialogValidationGoogleListener
        ): CpTDialog {
            return showValidationGoogleDialog(context, listener)
        }

        /**
         *Select red envelope currency
         */
        fun selectSymbol4RedPackage(
            context: Context,
            data: ArrayList<RedPackageInitInfo.Symbol?>,
            listener: DialogOnItemClickListener
        ) {
            var wheelView: WheelView<RedPackageInitInfo.Symbol>? = null
            var index = 0

            for (i in 0..3) {
                val redPackageInitInfo = RedPackageInitInfo.Symbol()
                redPackageInitInfo.amount = "-1"
                data.add(redPackageInitInfo)
            }

            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_wheel_red_package)
                .setScreenWidthAspect(context, 1f)
                .setScreenHeightAspect(context, 0.3f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    wheelView =
                        viewHolder?.getView<WheelView<RedPackageInitInfo.Symbol>>(R.id.wheelview)
                    wheelView?.backgroundColorResource = R.color.bg_card_color
                    wheelView?.setWheelAdapter(WheelViewAdapter(context))
                    viewHolder?.setText(
                        R.id.tv_confirm,
                        LanguageUtil.getString(context, "redpacket_payment_confirm")
                    )
                    viewHolder?.setText(
                        R.id.tv_cancel,
                        LanguageUtil.getString(context, "redpacket_payment_cancel")
                    )
                    val style = WheelView.WheelViewStyle()
                    style.selectedTextColor = ContextCompat.getColor(context, R.color.text_color)
                    style.textColor = ContextCompat.getColor(context, R.color.normal_text_color)
                    style.holoBorderColor = ContextCompat.getColor(context, R.color.line_color)
                    style.backgroundColor = ContextCompat.getColor(context, R.color.bg_card_color)
                    wheelView?.skin = WheelView.Skin.Holo
                    wheelView?.setWheelData(data)

                    wheelView?.style = style
                    wheelView?.invalidate()
//                        wheelView?.setLoop(true)
                    wheelView?.setOnWheelItemSelectedListener { position, t ->
                        index = position
                    }

                }.addOnClickListener(R.id.tv_cancel, R.id.tv_confirm)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_confirm -> {
                            Log.d(
                                "XX",
                                "===XXX====${index},${wheelView?.selectedItemPosition}======"
                            )
                            val index = if (index < 0) {
                                0
                            } else {
                                index
                            }
                            listener.clickItem(index)
                            tDialog?.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        /**
         *Confirmation box for sending red envelopes
         */
        fun order4RedPackage(context: Context, bean: TempBean, listener: DialogBottomListener) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_create_red_package)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    var tv_money = viewHolder?.getView<TextView>(R.id.tv_money)
                    viewHolder?.setText(
                        R.id.tv_title,
                        LanguageUtil.getString(context, "redpacket_payment_payment")
                    )
                    viewHolder?.setText(
                        R.id.tv_money_title,
                        LanguageUtil.getString(context, "redpacket_payment_amount")
                    )
                    viewHolder?.setText(
                        R.id.tv_money_type_title,
                        LanguageUtil.getString(context, "redpacket_payment_type")
                    )
                    viewHolder?.setText(
                        R.id.tv_account_title,
                        LanguageUtil.getString(context, "redpacket_payment_account")
                    )
                    viewHolder?.setText(
                        R.id.tv_cancel,
                        LanguageUtil.getString(context, "redpacket_payment_cancel")
                    )
                    viewHolder?.setText(
                        R.id.tv_confirm,
                        LanguageUtil.getString(context, "redpacket_payment_confirm")
                    )



                    tv_money?.text = "${bean.money} ${NCoinManager.getShowMarket(bean.coin)}"

                    var tv_account = viewHolder?.getView<TextView>(R.id.tv_account)
                }.addOnClickListener(R.id.tv_cancel, R.id.tv_confirm)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_confirm -> {
                            listener.sendConfirm()
                            tDialog?.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }


        /**
         *Sharing red envelopes
         */
        fun share4RedPackage(
            context: Context,
            bean: CreatePackageBean?,
            isDirectShare: Boolean = false
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_red_package)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    var iv_logo = viewHolder?.getView<ImageView>(R.id.iv_logo)
                    var logoBean = PublicInfoDataService.getInstance().getApp_logo_list_new(null)
                    if (null != logoBean && logoBean.size >= 2) {
                        if (!TextUtils.isEmpty(logoBean[1])) {
                            GlideUtils.loadImageHeader(context, logoBean[0], iv_logo)
                        }
                    }

                    viewHolder?.setText(
                        R.id.tv_redpacket_send_longPress,
                        LanguageUtil.getString(context, "redpacket_send_longPress")
                    )
                    var iv_qr_code = viewHolder?.getView<ImageView>(R.id.iv_qr_code)

                    /**
                     *QR code image
                     */
                    if (!TextUtils.isEmpty(bean?.shareUrl)) {
                        iv_qr_code?.setImageBitmap(
                            BitmapUtils.generateBitmap(
                                bean?.shareUrl,
                                300,
                                300
                            )
                        )
                    }

                    var tv_coin = viewHolder?.getView<TextView>(R.id.tv_coin)
                    if (bean?.coinSymbol?.length ?: 0 > 4) {
                        tv_coin?.textSize = 12f
                    } else {
                        tv_coin?.textSize = 16f
                    }
                    tv_coin?.text =
                        NCoinManager.getShowMarket(bean?.coinSymbol).toString().toUpperCase()


                    val tv_red_package_owner =
                        viewHolder?.getView<TextView>(R.id.tv_red_package_owner)

                    tv_red_package_owner?.text =
                        LanguageUtil.getString(context, "redpacket_send_from")
                            .format(bean?.nickName)

                    val ly_red_package = viewHolder?.getView<ConstraintLayout>(R.id.ly_red_package)
                    if (SystemUtils.isZh()) {
                        ly_red_package?.backgroundResource = R.drawable.bg_red_package
                    } else {
                        ly_red_package?.backgroundResource = R.drawable.background_english
                    }
                    if (context != null) {
                        Glide.with(context).load(bean?.background)
                            .into(object : SimpleTarget<Drawable>() {
                                override fun onResourceReady(
                                    resource: Drawable,
                                    transition: Transition<in Drawable>?
                                ) {
                                    ly_red_package?.backgroundDrawable = resource
                                }
                            })
                    }

                    Handler().postDelayed(object : Runnable {
                        override fun run() {
                            val screenshotBitmap = ScreenShotUtil.getScreenshotBitmap(
                                ly_red_package
                                    ?: return
                            )

                            CpShareToolUtil.sendLocalShare(context, screenshotBitmap)
//                                var imgName = "${System.currentTimeMillis()}${context.packageName}.jpg"
//                                if (screenshotBitmap != null) {
//                                    val path = ImageTools.saveBitmap(screenshotBitmap, imgName)
//                                    ImageTools.insertImageToSystem(context, path, imgName)
//                                    val shareImageIntent = Intent(Intent.ACTION_SEND)
//                                    shareImageIntent.type = "image/*"
//                                    shareImageIntent.putExtra(Intent.EXTRA_STREAM, Uri.parse(path))
//                                    context.startActivity(Intent.createChooser(shareImageIntent, LanguageUtil.getString(context, "contract_share_label")))
//
//                                }
                        }

                    }, if (isDirectShare) 200 else 2500)
                }
                .create()
                .show()
        }

        /**
         *Conditions for sending red envelopes
         */
        fun redPackageConditionDialog(context: Context) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_red_package_condition)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    /**
                     *Real name authentication
                     *Certification status 0. Under review, 1. Passed, 2. Not passed, 3. Not certified
                     */
                    if (UserDataService.getInstance().authLevel != 1) {
                        viewHolder?.getView<ImageView>(R.id.iv_realname_certification)
                            ?.setImageResource(R.drawable.fiat_unfinished)
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                    } else {
                        viewHolder?.getView<ImageView>(R.id.iv_realname_certification)
                            ?.setImageResource(R.drawable.fiat_complete)
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                    }

                    /**
                     *Bind Google
                     */
                    if (UserDataService.getInstance().googleStatus != 1 && UserDataService.getInstance().isOpenMobileCheck != 1) {
                        viewHolder?.getView<ImageView>(R.id.iv_google)
                            ?.setImageResource(R.drawable.fiat_unfinished)
                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                    } else {
                        viewHolder?.getView<ImageView>(R.id.iv_google)
                            ?.setImageResource(R.drawable.fiat_complete)
                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                    }

                }
                .addOnClickListener(R.id.tv_goto_set, R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_goto_set -> {
                            tDialog.dismiss()
                            if (UserDataService.getInstance().authLevel!=1) {
                                ArouterUtil.greenChannel(RoutePath.KycActivity, null)
                                return@setOnViewClickListener
                            }

                            if (UserDataService.getInstance().googleStatus != 1 || UserDataService.getInstance().isOpenMobileCheck != 1) {
                                ArouterUtil.greenChannel(RoutePath.SafetySettingActivity, null)
                                return@setOnViewClickListener
                            }
                        }
                    }
                }
                .create()
                .show()
        }


        /**
         *Limit price closing position
         */
        fun closePositionByLimit(
            context: Context,
            quoteSymbol: String,
            listener: DialogBottomAloneListener
        ) {
            var mount = 0L
            var price = "0.0"
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_limit_close_position)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    viewHolder?.getView<TextView>(R.id.tv_coin)?.text = quoteSymbol

                    val btn_close_position =
                        viewHolder?.getView<Button>(R.id.btn_close_position)?.apply {
                            backgroundColorResource = R.color.normal_text_color
                        }
                    viewHolder?.run {
                        setText(
                            R.id.tv_contract_limit_balance,
                            LanguageUtil.getString(context, "contract_text_limitPositions")
                        )
                        setText(
                            R.id.tv_cancel,
                            LanguageUtil.getString(context, "common_text_btnCancel")
                        )
                        setText(
                            R.id.tv_contract_text_price,
                            LanguageUtil.getString(context, "contract_text_price")
                        )
                        setText(
                            R.id.btn_close_position,
                            LanguageUtil.getString(context, "common_text_btnConfirm")
                        )

                    }

                    viewHolder?.getView<CustomizeEditText>(R.id.et_price)?.hint =
                        LanguageUtil.getString(context, "contract_tip_pleaseInputPrice")

                    viewHolder?.getView<EditText>(R.id.et_price)?.apply {
                        filters = arrayOf(
                            DecimalDigitsInputFilter(
                                Contract2PublicInfoManager.getCoinByName(quoteSymbol)?.showPrecision
                                    ?: 8
                            )
                        )

                        addTextChangedListener(object : TextWatcher {
                            override fun afterTextChanged(s: Editable?) {
                                if (isEnable(this@apply)) {
                                    btn_close_position?.run {
                                        backgroundColorResource = R.color.main_blue
                                        isEnabled = true
                                        price = s.toString()
                                    }
                                } else {
                                    btn_close_position?.run {
                                        backgroundColorResource = R.color.normal_text_color
                                        isEnabled = false
                                    }
                                }
                            }

                            override fun beforeTextChanged(
                                s: CharSequence?,
                                start: Int,
                                count: Int,
                                after: Int
                            ) {
                            }

                            override fun onTextChanged(
                                s: CharSequence?,
                                start: Int,
                                before: Int,
                                count: Int
                            ) {
                            }

                        })
                    }


//                        et_mount?.addTextChangedListener(object : TextWatcher {
//                            override fun afterTextChanged(s: Editable?) {
//                                if (isEnable(et_price) && isEnable(et_mount)) {
//                                    mount = s.toString().toLong()
//                                } else {
//                                    btn_close_position?.isEnable(false)
//                                }
//                            }
//
//                            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
//                            }
//
//                            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
//                            }
//
//                        })

                }
                .addOnClickListener(R.id.tv_cancel, R.id.btn_close_position)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.btn_close_position -> {
                            if (TextUtils.isEmpty(price) || price.toDouble() == 0.0) {
                                return@setOnViewClickListener
                            }
//                                if (mount > position?.volume?.toLong() ?: 0) {
//                                    tDialog.dismiss()
//DisplayUtil. showSnackBar (context. window. ecorView, "The maximum number of current positions is"+position?. volume, isSuc=false)
//                                    return@setOnViewClickListener
//                                }


                            /**
                             *Here, the price and number of positions will be split and sent out in/
                             */
                            listener.returnContent(price + "/$mount")
                            tDialog.activity?.window?.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN)
                            tDialog.dismiss()
                            //Turn off keyboard
                            val inputManager =
                                context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                            Log.d("=isActive=", "=======${inputManager.isActive}===========")
                            inputManager.hideSoftInputFromWindow(
                                context.window?.decorView?.windowToken,
                                0
                            )
                        }
                    }
                }
                .create()
                .show()
        }

        fun isEnable(editText: EditText?): Boolean {
            val string = editText?.text.toString()
            return !(TextUtils.isEmpty(string) || string.toDouble() == 0.0)
        }


        fun redPackageCondition(context: Context) {
            OTCTradingPermissionsDialog(context, object : DialogBottomListener {
                override fun sendConfirm() {
                    val isEnforceGoogleAuth =
                        PublicInfoDataService.getInstance().isEnforceGoogleAuth(null)
                    val googleStatus = UserDataService.getInstance().googleStatus
                    val isOpenMobileCheck = UserDataService.getInstance().isOpenMobileCheck

                    if (isEnforceGoogleAuth) {
                        if (googleStatus != 1) {
                            ArouterUtil.greenChannel(RoutePath.SafetySettingActivity, null)
                        } else {
                            if (UserDataService.getInstance().authLevel!=1) {
                                ArouterUtil.navigation(
                                    RoutePath.KycActivity,
                                    null
                                )
                            }
                        }
                    } else {
                        if ((googleStatus != 1 && isOpenMobileCheck != 1)) {
                            ArouterUtil.greenChannel(RoutePath.SafetySettingActivity, null)
                        } else {
                            if (UserDataService.getInstance().authLevel!=1) {
                                ArouterUtil.navigation(
                                    RoutePath.KycActivity,
                                    null
                                )
                            }
                        }
                    }
                }
            }, -1, LanguageUtil.getString(context, "redpacket_click_prompt"))
        }

        /**
         * TODO dialog_recharge_b2c
         */
        fun confirmRecharge(
            context: Context,
            symbol: String,
            amount: String,
            imgUrl: String,
            listener: DialogBottomListener
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_recharge_b2c)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.run {
                        /*Payment amount*/
                        setText(R.id.tv_amount, BigDecimalUtils.showNormal(amount) + " $symbol")

                        setText(
                            R.id.tv_title,
                            LanguageUtil.getString(context, "b2c_text_rechargeConfirm")
                        )
                        setText(
                            R.id.tv_tips,
                            LanguageUtil.getString(context, "b2c_text_rechargeNote")
                        )
                        setText(
                            R.id.tv_amount_title,
                            LanguageUtil.getString(context, "otc_text_paymentAmount")
                        )
                        setText(
                            R.id.tv_purchase_voucher_title,
                            LanguageUtil.getString(context, "b2c_Transfer_Vouchers")
                        )
                        setText(
                            R.id.tv_cancel,
                            LanguageUtil.getString(context, "common_text_btnCancel")
                        )
                        setText(
                            R.id.tv_confirm,
                            LanguageUtil.getString(context, "b2c_text_confirmRecharge")
                        )

                        Log.d("转账凭证", "======imageUrl:$imgUrl=====")
                        /*Transfer voucher*/
                        GlideUtils.loadImageHeader(
                            context,
                            imgUrl,
                            getView<ImageView>(R.id.iv_voucher)
                        )
                    }
                }
                .addOnClickListener(R.id.tv_confirm, R.id.tv_cancel)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                            ViewUtils.showSnackBar(context.window?.decorView, "取消充值", false)
                        }
                        R.id.tv_confirm -> {
                            listener.sendConfirm()

                        }
                    }
                }
                .create()
                .show()
        }

        /**
         *OTC activation payment method
         *Security
         */
        fun activationPaymentMethodDialog(
            context: Context?,
            listener: DialogBottomListener,
            payments: JSONArray?
        ) {
            if (null == context)
                return
            if (null == payments || payments.length() <= 0)
                return

            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_otc_activate_paymentmethod_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    var paymentMethodString = StringBuilder()
                    for (i in 0 until payments.length()) {
                        var title = payments.optJSONObject(i)?.optString("title")
                        if (!StringUtil.checkStr(title)) {
                            title = payments.optJSONObject(i)?.optString("key") ?: ""
                        }
                        paymentMethodString.append(title)
                        paymentMethodString.append(",")
                    }
                    viewHolder?.getView<TextView>(R.id.tv_tip)?.text =
                        LanguageUtil.getString(context, "common_text_tip")
                    viewHolder?.getView<TextView>(R.id.tv_cancel)?.text =
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    viewHolder?.getView<TextView>(R.id.tv_goto_activation)?.text =
                        LanguageUtil.getString(context, "otc_string_goActivate")
                    var methodString = paymentMethodString.toString()
                        .substring(0, paymentMethodString.toString().length - 1)
                    viewHolder?.getView<TextView>(R.id.tv_content)?.text = LanguageUtil.getString(
                        context,
                        "otc_string_buyerOnlyCan"
                    ) + methodString + LanguageUtil.getString(context, "otc_string_youNeedDo")
                }
                .addOnClickListener(R.id.tv_goto_activation, R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_goto_activation -> {
                            listener.sendConfirm()
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        /**
         *Leveraged account
         */
        fun leverAccountDialog(
            context: Context,
            symbol: String,
            jsonObject: JSONObject?,
            listener: DialogOnItemClickListener
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_layout_lever)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.TOP)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setDialogAnimationRes(R.style.dialogTopAnim)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.run {
                        val showName = NCoinManager.getMarketName4Symbol(symbol)
                        var quoteCoin = NCoinManager.getMarketCoinName(showName)
                        var baseCoin = NCoinManager.getMarketName(showName)
                        setText(
                            R.id.btn_return,
                            LanguageUtil.getString(context, "return_the_number")
                        )

                        setText(
                            R.id.tv_explosion_price_title,
                            LanguageUtil.getString(
                                context,
                                "leverage_text_blowingUp"
                            ) + " ($quoteCoin)"
                        )
                        setText(
                            R.id.tv_available_balance_title,
                            "${LanguageUtil.getString(context, "assets_text_available")} ($baseCoin)"
                        )
                        setText(
                            R.id.tv_borrowed_title,
                            "${LanguageUtil.getString(context, "assets_text_available")} ($quoteCoin)"
                        )

                        setText(
                            R.id.tv_risk_rate_value,
                            LanguageUtil.getString(context, "leverage_risk")
                        )
                        setText(R.id.tv_title, showName)
                        setText(
                            R.id.tv_risk_tip,
                            LanguageUtil.getString(context, "leverage_risk_prompt")
                        )
                        setText(R.id.btn_borrow, LanguageUtil.getString(context, "leverage_borrow"))
                        setText(
                            R.id.btn_transfer,
                            LanguageUtil.getString(context, "assets_action_transfer")
                        )

                        jsonObject?.run {
                            val quoteCoin = optString("quoteCoin", "")
                            val baseCoin = optString("baseCoin", "")

                            setText(R.id.tv_risk_rate, "--")

                            var riskRate = optString("riskRate", "0")
                            if(StringUtil.isNumeric(riskRate) && BigDecimalUtils.compareTo(riskRate, "999")==1){
                                riskRate = "999"
                            }
                            var showName = NCoinManager.getShowMarketName("$baseCoin/$quoteCoin")
                            setText(
                                R.id.tv_title,
                                showName
                            )
                            setText(R.id.tv_risk_rate, "$riskRate%")

                            val imStatus = getView<ImageView>(R.id.im_status)


                            if (BigDecimalUtils.compareTo(riskRate,"200") >= 0) {
                                setTextColor(R.id.tv_risk_rate, ColorUtil.getColor(context, R.color.green))
                                imStatus.imageResource = R.mipmap.coins_pointer1

                            } else if (BigDecimalUtils.compareTo(riskRate,"150") >= 0 && BigDecimalUtils.compareTo(riskRate,"200") <= 0) {
                                setTextColor(R.id.tv_risk_rate, ColorUtil.getColor(context, R.color.red))
                                imStatus.imageResource = R.mipmap.coins_pointer2

                            } else if (BigDecimalUtils.compareTo(riskRate,"120") >= 0 && BigDecimalUtils.compareTo(riskRate,"150") <= 0) {
                                setTextColor(R.id.tv_risk_rate, ColorUtil.getColor(context, R.color.red))
                                imStatus.imageResource = R.mipmap.coins_pointer3
                            } else {
                                setTextColor(R.id.tv_risk_rate, ColorUtil.getColor(context, R.color.text_color))
                                setText(R.id.tv_risk_rate, "--")
                                imStatus.imageResource = if (BigDecimalUtils.compareTo(riskRate,"0") == 0) R.mipmap.coins_pointer1 else R.mipmap.coins_pointer4
                            }

                            if (BigDecimalUtils.compareTo(riskRate,"110") < 0) {
                                setTextColor(R.id.tv_risk_rate, ColorUtil.getColor(context, R.color.text_color))
                                setText(R.id.tv_risk_rate, "--")
                            }
                            var quoteRate = NCoinManager.getCoinShowPrecision(quoteCoin)
                            var baseRate = NCoinManager.getCoinShowPrecision(baseCoin)


                            val precision = NCoinManager.getSymbolObj(symbol)?.optInt("price", 2)
                                ?: 2

                            setText(
                                R.id.tv_explosion_price_title,
                                LanguageUtil.getString(
                                    context,
                                    "leverage_text_blowingUp"
                                ) + " (${NCoinManager.getShowMarket(quoteCoin)})"
                            )

                            val burstPrice = optString("burstPrice", "")
                            setText(
                                R.id.tv_explosion_price,
                                if("999".equals(riskRate)){
                                    "--"
                                }else{
                                    BigDecimalUtils.divForDown(burstPrice, precision).toPlainString()
                                }
                            )

                            setText(
                                R.id.tv_available_balance_title,
                                "${
                                    LanguageUtil.getString(
                                        context,
                                        "assets_text_available"
                                    )
                                } (${NCoinManager.getShowMarket(baseCoin)})"
                            )
                            setText(
                                R.id.tv_available_balance,
                                BigDecimalUtils.divForDown(optString("baseNormalBalance", ""), 8)
                                    .toPlainString()
                            )
                            setText(
                                R.id.tv_borrowed_title,
                                "${
                                    LanguageUtil.getString(
                                        context,
                                        "assets_text_available"
                                    )
                                } (${NCoinManager.getShowMarket(quoteCoin)})"
                            )
                            setText(
                                R.id.tv_borrowed,
                                BigDecimalUtils.divForDown(optString("quoteNormalBalance", ""), 8)
                                    .toPlainString()
                            )
                        }
                    }
                }
                .addOnClickListener(R.id.btn_borrow, R.id.btn_return, R.id.btn_transfer)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.btn_borrow -> {
                            tDialog.dismiss()
                            listener.clickItem(1)
                        }
                        R.id.btn_return -> {
                            listener.clickItem(2)
                        }
                        R.id.btn_transfer -> {
                            listener.clickItem(3)
                        }
                    }
                }
                .create()
                .show()
        }


        /**
         *Popup on homepage
         */
        fun showHomePageDialog(context: Context) {
            val homePageDialogTitle =
                PublicInfoDataService.getInstance().getHomePageDialogTitle(null)
            val homePageDialogStatus = PublicInfoDataService.getInstance().homePageDialogStatus
            if (homePageDialogStatus || TextUtils.isEmpty(homePageDialogTitle)) return
            LogUtil.e(TAG_ADVERT, "showHomePageDialog ${dialogType}")
            if (dialogType != 0) {
                return
            }
            dialogType = 3
            var isSelected = true
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_homepage_warn)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setText(R.id.tv_text, homePageDialogTitle)

                    viewHolder?.setText(
                        R.id.tv_has_known,
                        LanguageUtil.getString(context, "common_has_known")
                    )
                    viewHolder?.setText(
                        R.id.btn_know,
                        LanguageUtil.getString(context, "alert_common_iknow")
                    )
                    val tv_text = viewHolder?.getView<TextView>(R.id.tv_text)
                    tv_text?.movementMethod = ScrollingMovementMethod()

                    val imageView = viewHolder?.getView<ImageView>(R.id.iv_state)
                    imageView?.setOnClickListener {
                        isSelected = !isSelected
                        if (isSelected) {
                            imageView.imageResource = R.drawable.selected
                        } else {
                            imageView.imageResource = R.drawable.unchecked
                        }
                    }
                }.setOnDismissListener {
                    dialogType = 0
                }
                .addOnClickListener(R.id.btn_know)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.btn_know -> {
                            if (!isSelected) return@setOnViewClickListener
                            tDialog.dismiss()
                            PublicInfoDataService.getInstance().saveHomePageDialogStatus(isSelected)
                        }
                    }

                }.setOnKeyListener(DialogInterface.OnKeyListener { _, keyCode, _ ->
                    if (keyCode == KeyEvent.KEYCODE_BACK) {
                        return@OnKeyListener true
                    }
                    false  //Default return value
                }).create().show()
        }


        /**
         *Popup window of lever
         */
        fun showLeverDialog(context: Context, listener: DialogTransferBottomListener) {
            val leverDialogURL = PublicInfoDataService.getInstance().getLeverDialogURL(null)
            var isSelected = false
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_lever_warn)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    val text = LanguageUtil.getString(context, "lever_need_read")
//                                if (SystemUtils.isZh()) {
//                            Html.fromHtml("${ LanguageUtil.getString(context,"lever_need_read")}<font color='#3078FF'>${ LanguageUtil.getString(context,"lever_trade_agreement")}</font>")
//                        } else if (SystemUtils.isTW()) {
//                            Html.fromHtml("${ LanguageUtil.getString(context,"lever_need_read")}<font color='#3078FF'>${ LanguageUtil.getString(context,"lever_trade_agreement")}</font>")
//                        } else if (SystemUtils.isJapanese()) {
//Html. from Html ("${" レバレッジジををソるににをソるるににををるるにににをよバレよッジジをを)
//                        } else if (SystemUtils.isKorea()) {
//                            Html.fromHtml("${"레버리지 거래를 시작하기 전에 \""}<font color='#3078FF'>${ LanguageUtil.getString(context,"lever_trade_agreement")}</font>" + "\" 을 읽고 동의하십시오")
//                        } else if (SystemUtils.isVietNam()) {
//                            Html.fromHtml("${"Đọc và đồng ý với\""}<font color='#3078FF'>${ LanguageUtil.getString(context,"lever_trade_agreement")}</font>" + "\" trước khi bắt đầu giao dịch có đòn bẩy")
//                        } else {
//                            Html.fromHtml("${"Read and agree to the \""}<font color='#3078FF'>${ LanguageUtil.getString(context,"lever_trade_agreement")}</font>" + "\" before starting leveraged trading")
//                        }
                    viewHolder?.setText(R.id.tv_text, text)
                    viewHolder?.setText(
                        R.id.tv_has_known,
                        LanguageUtil.getString(context, "common_has_known")
                    )
                    viewHolder?.setText(
                        R.id.btn_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.setText(
                        R.id.btn_know,
                        LanguageUtil.getString(context, "common_start_trade")
                    )
                    val imageView = viewHolder?.getView<ImageView>(R.id.iv_state)
                    imageView?.setOnClickListener {
                        isSelected = !isSelected
                        if (isSelected) {
                            imageView.imageResource = R.drawable.selected
                        } else {
                            imageView.imageResource = R.drawable.unchecked
                        }
                    }
                }
                .addOnClickListener(R.id.btn_know, R.id.btn_cancel, R.id.tv_text)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.tv_text -> {
                            ArouterUtil.greenChannel(RoutePath.ItemDetailActivity, Bundle().apply {
                                putString(
                                    ParamConstant.head_title,
                                    LanguageUtil.getString(context, "lever_trade_agreement")
                                )
                                putString(ParamConstant.web_url, leverDialogURL)
                                putInt(ParamConstant.web_type, WebTypeEnum.NORMAL_INDEX.value)
                            })
                        }

                        R.id.btn_cancel -> {
                            tDialog.dismiss()
                            listener.showCancel()
                        }

                        R.id.btn_know -> {
                            if (!isSelected) return@setOnViewClickListener
                            tDialog.dismiss()
                            PublicInfoDataService.getInstance().saveLeverDialogStatus(isSelected)
                            listener.sendConfirm()
                        }
                    }

                }.setOnKeyListener(DialogInterface.OnKeyListener { _, keyCode, _ ->
                    if (keyCode == KeyEvent.KEYCODE_BACK) {
                        return@OnKeyListener true
                    }
                    false  //Default return value
                })
                .create()
                .show()
        }

        /**
         *Only judge real name authentication
         */
        fun loginTypeDialog(
            context: Context,
            listener: DialogTransferBottomListener,
            title: String = "", googleAuth: String? = ""
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_validatin_type_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    viewHolder?.setText(
                        R.id.tv_tip,
                        LanguageUtil.getString(context, "login_action_fogetpwdSafety")
                    )
                    viewHolder?.setText(
                        R.id.tv_validation_content,
                        LanguageUtil.getString(context, "login_success_action_alert_message")
                    )
                    viewHolder?.setText(
                        R.id.tv_google,
                        LanguageUtil.getString(context, "safety_action_changeLoginPassword")
                    )
                    viewHolder?.setText(
                        R.id.tv_realname_certification,
                        LanguageUtil.getString(context, "login_success_action_alert_google")
                    )
                    viewHolder?.setText(
                        R.id.tv_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.setText(
                        R.id.tv_goto_set,
                        LanguageUtil.getString(context, "common_text_btnSetting")
                    )
                    if (googleAuth == "1") {
                        viewHolder?.setGone(R.id.tv_realname_certification, true)
                    } else {
                        viewHolder?.setGone(R.id.tv_realname_certification, false)
                    }

                }
                .addOnClickListener(R.id.tv_goto_set, R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            listener.showCancel()
                            tDialog.dismiss()
                        }
                        R.id.tv_goto_set -> {
                            listener.sendConfirm()
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        var show4KolDialog: CpTDialog? = null

        /**
         *Only judge real name authentication
         */
        fun webShare(
            context: Context,
            listener: DialogWebViewShareListener,
            profitRate: Double = 0.0,
            winRateWeek: Double = 0.0,
            winRate: Double = 0.0,
            labe: String = "",
            userName: String = ""
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_webview_documentary_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    var threshold = 0
                    var inviteUrl = UserDataService.getInstance().inviteUrl

                    var imageDown = viewHolder?.getView<ImageView>(R.id.tv_swipe_down)
                    var imageNext = viewHolder?.getView<ImageView>(R.id.tv_swipe_next)
                    var tvProfit = viewHolder?.getView<TextView>(R.id.tv_profit)
                    var tvNumber = viewHolder?.getView<TextView>(R.id.tv_number)
                    var tvExchange = viewHolder?.getView<TextView>(R.id.tv_exchange)
                    var tvQrCode = viewHolder?.getView<ImageView>(R.id.tv_qr_code)
                    var ivLogo = viewHolder?.getView<ImageView>(R.id.iv_logo)

                    viewHolder?.setText(R.id.tv_user_name, userName)
                    viewHolder?.setText(R.id.tv_describe, labe)
                    tvQrCode?.setImageBitmap(BitmapUtils.generateBitmap(inviteUrl, 300, 300))
                    var app_logo_list_new =
                        PublicInfoDataService.getInstance().getApp_logo_list_new(null)
                    if (null != app_logo_list_new && app_logo_list_new.size > 0) {
                        var logoWhite = app_logo_list_new[1]
                        if (StringUtil.isHttpUrl(logoWhite)) {
                            GlideUtils.loadImageHeader(context, logoWhite, ivLogo)
                        }
                    }
                    tvExchange?.text =
                        "${AppUtils.getAppName(context)}-" + context.getString(R.string.contract_digital_currency_exchange)
                    tvProfit?.text = context.getString(R.string.contract_total_profit)
                    tvNumber?.run {
                        textColor = ColorUtil.getMainColorType(winRateWeek >= 0)
                        text = "${
                            BigDecimalUtils.divForDown(winRateWeek.toString(), 2).toPlainString()
                        }"
                    }

                    var mainLayout =
                        viewHolder?.getView<RelativeLayout>(R.id.rl_contract_share_layout)
                    mainLayout?.setOnLongClickListener {
                        show4KolDialog = showListDialog(
                            context,
                            arrayListOf(
                                context.getString(R.string.sl_str_save_image),
                                context.getString(R.string.sl_str_share_confirm)
                            ),
                            0,
                            object : DialogOnclickListener {
                                override fun clickItem(data: ArrayList<String>, item: Int) {
                                    imageDown?.visibility = View.INVISIBLE
                                    imageNext?.visibility = View.INVISIBLE
                                    if (listener != null) {
                                        when (item) {
                                            0 -> {
                                                listener.webviewSaveImage(mainLayout)
                                            }
                                            1 -> {
                                                listener.confirmShare(mainLayout)
                                            }
                                        }
                                        show4KolDialog?.dismiss()
                                    }
                                }

                                override fun onDismiss() {

                                }
                            })
                        false
                    }
                    imageDown?.setOnClickListener {
                        when (threshold) {
                            0 -> {
                                threshold = 2
                                tvProfit?.text = context.getString(R.string.contract_win_rate)
                                tvNumber?.run {
                                    textColor = ColorUtil.getMainColorType(winRate >= 0)
                                    text = "$winRate%"
                                }

                            }
                            1 -> {
                                threshold = 0
                                tvProfit?.text = context.getString(R.string.contract_total_profit)
                                tvNumber?.run {
                                    textColor = ColorUtil.getMainColorType(winRateWeek >= 0)
                                    text = "${
                                        BigDecimalUtils.divForDown(winRateWeek.toString(), 2)
                                            .toPlainString()
                                    }"
                                }

                            }
                            2 -> {
                                threshold = 1
                                tvProfit?.text = context.getString(R.string.sl_str_profit_rate1)
                                tvNumber?.run {
                                    textColor = ColorUtil.getMainColorType(profitRate >= 0)
                                    text = "$profitRate%"
                                }
                            }
                        }
                    }

                    imageNext?.setOnClickListener {
                        when (threshold) {
                            0 -> {
                                threshold = 1
                                tvProfit?.text = context.getString(R.string.sl_str_profit_rate1)
                                tvNumber?.run {
                                    textColor = ColorUtil.getMainColorType(profitRate >= 0)
                                    text = "$profitRate%"
                                }
                            }
                            1 -> {
                                threshold = 2
                                tvProfit?.text = context.getString(R.string.contract_win_rate)
                                tvNumber?.run {
                                    textColor = ColorUtil.getMainColorType(winRate >= 0)
                                    text = "$winRate%"
                                }
                            }
                            2 -> {
                                threshold = 0
                                tvProfit?.text = context.getString(R.string.contract_total_profit)
                                tvNumber?.run {
                                    textColor = ColorUtil.getMainColorType(winRateWeek >= 0)
                                    text = "${
                                        BigDecimalUtils.divForDown(winRateWeek.toString(), 2)
                                            .toPlainString()
                                    }"
                                }
                            }
                        }
                    }
                }
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        /**
         *Show invitation poster
         */
        fun showInvitationPosters(
            context: Activity,
            list: ArrayList<String>,
            listener: DialogSharePostersListener
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_invitation_posters)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.5f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder ->
                    var imageUrl = list[0]
                    var item = 0
                    var checkbox1 = viewHolder?.getView<CheckBox>(R.id.checkbox_invitation)
                    var checkbox2 = viewHolder?.getView<CheckBox>(R.id.checkbox_invitation_2)
                    viewHolder?.getView<LinearLayout>(R.id.ll_share_layout)?.setOnClickListener {
                        imageUrl = list[0]
                        if (checkbox1?.isChecked!!) {
                            return@setOnClickListener
                        }
                        checkbox1?.isChecked = true
                        checkbox2?.isChecked = false
                        item = 0
                    }
                    viewHolder?.getView<LinearLayout>(R.id.ll_share_layout_2)
                        ?.setOnClickListener {
                            imageUrl = list[1]
                            if (checkbox2?.isChecked!!) {
                                return@setOnClickListener
                            }
                            item = 1
                            checkbox2?.isChecked = true
                            checkbox1?.isChecked = false
                        }

                    viewHolder?.setText(R.id.tv_iphone, UserDataService.getInstance().userAccount)
                    viewHolder?.setText(R.id.tv_iphone_2, UserDataService.getInstance().userAccount)

                    var ivShareImage=viewHolder?.getView<ImageView>(R.id.iv_share_image)
                    val layoutParams1 = ivShareImage?.layoutParams
                    layoutParams1?.height=((QMUIDisplayHelper.getScreenWidth(context)/2-48)*1.592).toInt()
                    ivShareImage?.layoutParams = layoutParams1

                    var ivShareImage2=viewHolder?.getView<ImageView>(R.id.iv_share_image_2)
                    val layoutParams = ivShareImage2?.layoutParams
                    layoutParams?.height=((QMUIDisplayHelper.getScreenWidth(context)/2-48)*1.592).toInt()
                    ivShareImage2?.layoutParams = layoutParams

                    if (SystemUtils.isZh()) {

                        viewHolder?.setText(
                            R.id.tv_invitation_content,
                            String.format(
                                LanguageUtil.getString(context, "invite_you_qr"),
                                AppUtils.getAppName(context)
                            )
                        )
                        viewHolder?.setText(
                            R.id.tv_invitation_content_2,
                            String.format(
                                LanguageUtil.getString(context, "invite_you_qr"),
                                AppUtils.getAppName(context)
                            )
                        )

                        var optionsOne = RequestOptions().placeholder(R.drawable.ic_share_cn_one)
                            .error(R.drawable.ic_share_cn_one)

                        GlideUtils.load(
                            context,
                            list[0],
                            viewHolder?.getView(R.id.iv_share_image),
                            optionsOne
                        )
//                            GlideUtils.load(context, "http://img3.redocn.com/20130723/Redocn_2013072308525388.jpg", viewHolder?.getView(R.id.iv_share_image), optionsOne)

                        var optionsTwo = RequestOptions().placeholder(R.drawable.ic_share_cn_two)
                            .error(R.drawable.ic_share_cn_two)

                        GlideUtils.load(
                            context,
                            list[1],
                            viewHolder?.getView(R.id.iv_share_image_2),
                            optionsTwo
                        )
//                            GlideUtils.load(context, "http://img3.redocn.com/20130723/Redocn_2013072308525388.jpg", viewHolder?.getView(R.id.iv_share_image_2), optionsTwo)

                    } else {

                        viewHolder?.setText(
                            R.id.tv_invitation_content,
                            String.format(
                                LanguageUtil.getString(context, "invite_you_qr"),
                                LanguageUtil.getString(context, "app_name")
                            )
                        )
                        viewHolder?.setText(
                            R.id.tv_invitation_content_2,
                            String.format(
                                LanguageUtil.getString(context, "invite_you_qr"),
                                LanguageUtil.getString(context, "app_name")
                            )
                        )

                        var optionsOne = RequestOptions().placeholder(R.drawable.ic_share_en_one)
                            .error(R.drawable.ic_share_en_one)

                        GlideUtils.load(
                            context,
                            list[0],
                            viewHolder?.getView(R.id.iv_share_image),
                            optionsOne
                        )

                        var optionsTwo = RequestOptions().placeholder(R.drawable.ic_share_en_two)
                            .error(R.drawable.ic_share_en_two)

                        GlideUtils.load(
                            context,
                            list[1],
                            viewHolder?.getView(R.id.iv_share_image_2),
                            optionsTwo
                        )
                    }


                    /**
                     *QR code image
                     */
                    if (!TextUtils.isEmpty(UserDataService.getInstance()?.inviteUrl)) {
                        viewHolder?.getView<ImageView>(R.id.tv_invitation_qr_code)?.setImageBitmap(
                            BitmapUtils.generateBitmap(
                                UserDataService.getInstance()?.inviteUrl,
                                300,
                                300
                            )
                        )
                        viewHolder?.getView<ImageView>(R.id.tv_invitation_qr_code_2)
                            ?.setImageBitmap(
                                BitmapUtils.generateBitmap(
                                    UserDataService.getInstance()?.inviteUrl,
                                    300,
                                    300
                                )
                            )
                    }


                    viewHolder?.setText(
                        R.id.tv_invitaion_title,
                        LanguageUtil.getString(context, "share_your_tailored_poster")
                    )
                    viewHolder?.setText(
                        R.id.tv_cancel,
                        LanguageUtil.getString(context, "common_text_btnCancel")
                    )
                    viewHolder?.getView<CommonlyUsedButton>(R.id.save_image_btn)?.isEnable(true)
                    viewHolder?.getView<CommonlyUsedButton>(R.id.save_image_btn)
                        ?.setContent(LanguageUtil.getString(context, "sl_str_save_image"))
                    viewHolder?.getView<CommonlyUsedButton>(R.id.save_image_btn)?.listener =
                        object : CommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                when (item) {
                                    0 -> {
                                        if (listener != null) {
                                            listener?.saveIamgePosters(
                                                imageUrl,
                                                viewHolder.getView<ImageView>(R.id.iv_share_image)
                                            )
                                        }
                                    }
                                    1 -> {
                                        if (listener != null) {
                                            listener?.saveIamgePosters(
                                                imageUrl,
                                                viewHolder.getView<ImageView>(R.id.iv_share_image_2)
                                            )
                                        }
                                    }
                                }

                            }
                        }

                }

                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

        }

        /**
         *Number of invited applicants
         */
        fun showApplyInvitationNum(
            context: Activity,
            listener: DialogSharePostersListener
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_apply_invitation_num)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder ->
                    var ceAccount = viewHolder?.getView<CustomizeEditText>(R.id.ce_account)
                    var ceDesc = viewHolder?.getView<CustomizeEditText>(R.id.ce_desc)
                    viewHolder?.getView<CommonlyUsedButton>(R.id.save_image_btn)?.isEnable(true)
                    viewHolder?.getView<CommonlyUsedButton>(R.id.save_image_btn)?.listener =
                        object : CommonlyUsedButton.OnBottonListener {
                            override fun bottonOnClick() {
                                if (listener != null) {
                                    listener?.saveIamgePostersNew(ceAccount?.text.toString() + "&" + ceDesc?.text.toString())
                                }
                            }
                        }

                }

                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

        }


        /**
         *Face to face
         */
        fun showFaceToFace(context: Context, faceToFace: String) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_facetoface)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder ->
                    if (SystemUtils.isZh()) {
                        var options = RequestOptions().placeholder(R.drawable.facetoface_bg)
                            .error(R.drawable.facetoface_bg)

                        GlideUtils.load(
                            context,
                            faceToFace,
                            viewHolder?.getView(R.id.iv_face_toface_bg),
                            options
                        )
                    } else {
                        var options = RequestOptions().placeholder(R.drawable.facetoface_bg)
                            .error(R.drawable.facetoface_bg)

                        GlideUtils.load(
                            context,
                            faceToFace,
                            viewHolder?.getView(R.id.iv_face_toface_bg),
                            options
                        )

                    }
                    val requestOptions = RequestOptions()
                    requestOptions.error(R.drawable.icon_send_image)
                        .placeholder(R.drawable.icon_send_image)

                    var ivFacetoface=viewHolder?.getView<ImageView>(R.id.iv_face_to_face)
                    val bitmap = ZXingUtils.createQRImage(
                        UserDataService.getInstance().inviteUrl,
                        SizeUtils.dp2px(40f),
                        SizeUtils.dp2px(40f)
                    )
                    ivFacetoface?.setImageBitmap(bitmap)
                    val mFacelayoutParams = ivFacetoface?.layoutParams
                    mFacelayoutParams?.width = (QMUIDisplayHelper.getScreenWidth(context)*0.8*0.6).toInt()
                    mFacelayoutParams?.height= (QMUIDisplayHelper.getScreenWidth(context)*0.8*0.6).toInt()
                    ivFacetoface?.layoutParams = mFacelayoutParams

                    var rlFacetoface=viewHolder?.getView<RelativeLayout>(R.id.rl_facetoface_layout)
                    val layoutParams = rlFacetoface?.layoutParams
                    layoutParams?.width = (QMUIDisplayHelper.getScreenWidth(context)*0.8).toInt()
                    layoutParams?.height=(QMUIDisplayHelper.getScreenWidth(context)*0.8*1.32).toInt()
                    rlFacetoface?.layoutParams = layoutParams

                    viewHolder?.getView<TextView>(R.id.tv_invite_poster_tips)?.setText("invite_poster_tips".tr(context))
                }

                .addOnClickListener(R.id.iv_shut_down)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.iv_shut_down -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

        }

        /**
         *Display a regular dialog for a button
         */
        fun showSingleForceDialog(
            context: Context,
            content: String,
            listener: DialogBottomListener
        ) {
            showDialog(context, content, true, listener, "", "", "", true, false, true)
        }

        /**
         *Security verification dialog
         *
         */
        fun showCoinBottomDialog(
            context: Context,
            codeType: String,
            symbolAndUnit: String,
            isLevel: Boolean,
            listener: DialogBottomCoinListener
        ): CpTDialog {
            var commissiondSelectSymbolStatus = false
            var commissionedSymbol = ""
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_bottom_coin_adapter)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    val itemCoins = viewHolder?.getView<DownSettingView>(R.id.pet_select_coin)
                    val layoutCoin =
                        viewHolder?.getView<LineAdapter4FundsLayout>(R.id.ll_total_title)
                    val etCurrency = viewHolder?.getView<EditText>(R.id.et_currency)
                    val cubConfirm = viewHolder?.getView<KKButtonKit>(R.id.tv_confirm)
                    cubConfirm?.isEnable(false)
                    cubConfirm?.textContent = LanguageUtil.getString(context, "confirm")
                    val btn_return = viewHolder?.getView<KKButtonKit>(R.id.btn_return)
                    btn_return?.textContent = LanguageUtil.getString(context, "reset")
                    val tv_title = viewHolder?.getView<TextView>(R.id.tv_title)
                    tv_title?.setText(
                        LanguageUtil.getString(
                            context,
                            "common_action_allTradingPairs"
                        )
                    )
                    val tv_security_cancel = viewHolder?.getView<TextView>(R.id.tv_security_cancel)
                    tv_security_cancel?.setText(
                        LanguageUtil.getString(
                            context,
                            "common_text_btnCancel"
                        )
                    )
                    val et_currency = viewHolder?.getView<EditText>(R.id.et_currency)
                    et_currency?.setHint(LanguageUtil.getString(context, "filter_input_coinsymbol"))
                    val pet_select_coin = viewHolder?.getView<DownSettingView>(R.id.pet_select_coin)
                    pet_select_coin?.setHintEditText(
                        LanguageUtil.getString(
                            context,
                            "filter_fold_tradeUnit"
                        )
                    )

                    etCurrency?.isFocusable = true
                    etCurrency?.isFocusableInTouchMode = true
                    cubConfirm?.isEnabled = false
                    etCurrency?.transformationMethod = TransInformation()
                    etCurrency?.addTextChangedListener(object : TextWatcher {
                        override fun beforeTextChanged(
                            s: CharSequence?,
                            start: Int,
                            count: Int,
                            after: Int
                        ) {
                        }

                        override fun afterTextChanged(s: Editable?) {
                        }

                        override fun onTextChanged(
                            s: CharSequence?,
                            start: Int,
                            before: Int,
                            count: Int
                        ) {
                            val temp = s.toString()
                            if (temp.isNotEmpty() || codeType.isNotEmpty()) {
                                if (LanguageUtil.getString(
                                        context,
                                        "common_text_allDay"
                                    ) != s.toString()
                                ) {
                                    commissionedSymbol = s.toString().getCoinToUpper()
                                }
                                cubConfirm?.isEnabled = true

                            } else {
                                cubConfirm?.isEnabled = false
                            }

                        }
                    })
                    if (codeType.isNotEmpty()) {
                        etCurrency?.text = codeType.editable()
                    }
                    layoutCoin?.apply {
                        val coinList = arrayListOf<String>()
                        if (isLevel) {
                            coinList.addAll(NCoinManager.getLeverGroup())
                            if (PublicInfoDataService.getInstance().getOpenOrderCollect(null)) {
                                coinList.add(
                                    0,
                                    LanguageUtil.getString(context, "common_action_sendall")
                                )
                            }
                        } else {
                            coinList.addAll(
                                PublicInfoDataService.getInstance().getMarketSortList(null)
                            )
                            if (PublicInfoDataService.getInstance().getOpenOrderCollect(null)) {
                                coinList.add(
                                    0,
                                    LanguageUtil.getString(context, "common_action_sendall")
                                )
                            }
                        }
                        if (symbolAndUnit.isNotEmpty()) {
                            itemCoins?.setEditText(symbolAndUnit)
                            selectPosition = coinList.indexOf(symbolAndUnit)
                        }
                        setStringBeanData(coinList, false)
                        setLineSelectOncilckListener(object : LineSelectOnclickListener {
                            override fun selectMsgIndex(index: String?) {
                                itemCoins?.setEditText(NCoinManager.getShowMarket(index) ?: "")
                            }

                            override fun sendOnclickMsg() {

                            }
                        })
                    }
                    itemCoins?.onTextListener = object : DownSettingView.OnTextListener {
                        override fun showText(text: String): String {

                            return text
                        }

                        override fun returnItem(item: Int) {

                        }

                        override fun onclickImage() {
                            commissiondSelectSymbolStatus = !commissiondSelectSymbolStatus
                            if (commissiondSelectSymbolStatus) {
                                layoutCoin?.visibility = View.VISIBLE
                            } else {
                                layoutCoin?.visibility = View.GONE
                            }
                            itemCoins?.priceDownEdit(commissiondSelectSymbolStatus)
                        }

                    }
                }
                .addOnClickListener(R.id.tv_security_cancel, R.id.btn_return, R.id.tv_confirm)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_security_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.btn_return -> {
                            //
                            val cubConfirm = viewHolder.getView<KKButtonKit>(R.id.tv_confirm)
                            cubConfirm.setEnabled(false)
                            viewHolder?.getView<EditText>(R.id.et_currency)?.text =
                                "".editable()
                            val itemCoins =
                                viewHolder?.getView<DownSettingView>(R.id.pet_select_coin)
                            val layoutCoin =
                                viewHolder?.getView<LineAdapter4FundsLayout>(R.id.ll_total_title)
                            layoutCoin?.visibility = View.GONE
                            itemCoins?.isFocusableInTouchMode = false
                            itemCoins?.resetEdit()
                            KeyBoardUtils.closeKeyBoard(context)
                        }
                        R.id.tv_confirm -> {
                            val itemCoins =
                                viewHolder?.getView<DownSettingView>(R.id.pet_select_coin)
                            listener.returnTypeCode(commissionedSymbol, itemCoins?.text)
                            tDialog.dismiss()
                        }
                    }
                }
                .setOnDismissListener {
                    listener.onDismiss();
                }
                .create()
                .show()
        }


        /**
         *PoS purchase successful
         */
        fun showSuccessDialog(
            context: Context,
            content: String,
            isSingle: Boolean,
            listener: DialogBottomListener,
            title: String = "",
            cancelTitle: String = "",
            confrimTitle: String = ""
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_normal_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    if (!TextUtils.isEmpty(title)) {
                        viewHolder?.setGone(R.id.tv_title, true)
                        viewHolder?.setText(R.id.tv_title, title)
                    }

                    if (isSingle) {
                        viewHolder?.setGone(R.id.tv_cancel, false)
                        if (!TextUtils.isEmpty(cancelTitle)) {
                            viewHolder?.setText(R.id.tv_confirm_btn, cancelTitle)
                        } else {
                            viewHolder?.setText(
                                R.id.tv_confirm_btn,
                                context.getString(R.string.common_text_btnConfirm)
                            )
                        }

                    } else {
                        viewHolder?.setText(
                            R.id.tv_cancel,
                            context.getString(R.string.common_text_btnCancel)
                        )
                        if (confrimTitle.isNotEmpty()) {
                            viewHolder?.setText(R.id.tv_cancel, confrimTitle)
                        }
                        if (!TextUtils.isEmpty(cancelTitle)) {
                            viewHolder?.setText(R.id.tv_confirm_btn, cancelTitle)
                        } else {
                            viewHolder?.setText(
                                R.id.tv_confirm_btn,
                                context.getString(R.string.common_text_btnConfirm)
                            )
                        }
                    }
                    viewHolder?.setText(R.id.tv_content, content)

                }
                .addOnClickListener(R.id.tv_cancel, R.id.tv_confirm_btn)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_confirm_btn -> {
                            if (listener != null) {
                                listener.sendConfirm()
                            }
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

        }

        fun showAreaDialog(
            context: Context,
            listener: DialogBottomListener
        ) {
            val mList: java.util.ArrayList<CountryInfo> = java.util.ArrayList()
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_select_area)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setHeight(QMUIDisplayHelper.getScreenHeight(context) - 100)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    val stream: InputStream = context.assets.open("area.json")
                    val size = stream.available()
                    val byteArray = ByteArray(size)
                    stream.read(byteArray)
                    stream.close()
                    val json: String = String(byteArray, Charset.defaultCharset())
                    val data = JsonParser().parse(json).asJsonObject
                    var allCountry = arrayListOf<CountryInfo>()
                    var limtCountry = PublicInfoDataService.getInstance().getLimitCountryList(null)
                    if (data.get("countryList").isJsonArray) {
                        val countryData = JsonUtils.jsonToList(
                            data.get("countryList").toString(),
                            CountryInfo::class.java
                        )
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
                        mList.clear()
                        mList.addAll(allCountry)


                        if (Locale.getDefault().language.contentEquals("zh")) {
                            val sortedByPinyinList =
                                mList.sortedBy { Pinyin.toPinyin(it.cnName, "") }
                            sortedByPinyinList.forEach(::println)
                            initAdapter(context, ArrayList(sortedByPinyinList))
                        } else {
                            initAdapter(context, mList)
                        }

                    }


//                        viewHolder?.setText(R.id.tv_content, content)

                }
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
//                            R.id.tv_confirm_btn -> {
//                                if (listener != null && (!isSingle)) {
//                                    listener.sendConfirm()
//                                }
//                                tDialog.dismiss()
//                            }
                    }
                }
                .create()
                .show()

        }


        private fun initAdapter(context: Context, mList: java.util.ArrayList<CountryInfo>) {
//
//            var countryList = arrayListOf<CountryInfo>()
//            var countryListNormal = arrayListOf<CountryInfo>()
//
//            countryList.clear()
//            countryListNormal.clear()
//            countryList.addAll(mList)
//            countryListNormal.addAll(mList)
////            area_side_bar.visibility = View.VISIBLE
//            val areaAdapter = AreaAdapter(countryList, context)
//            rv_area?.layoutManager = LinearLayoutManager(context)
//            rv_area?.adapter = areaAdapter
//
//
//            area_side_bar?.setOnTouchingLetterChangedListener { s ->
//                for (i in 0 until countryList.size) {
////Compare strings, ignoring case
//                    if (countryList[i].getStickItem().equals(s, true)) {
//                        rv_area.scrollToPosition(i)
//                        break
//                    }
//                }
//            }
//
//
//            /**
//             *Add ItemDecoration to RecyclerView
//             */
//            rv_area?.addItemDecoration(SectionDecoration(this, object : SectionDecoration.DecorationCallback {
//                override fun getGroupFirstLine(position: Int): String {
//Log. d (TAG, "--- position ---"+position)
//                    
//                    return countryList[position].getStickItem().substring(0, 1).toLowerCase()
//                }
//
//                override fun getGroupId(position: Int): Long {
//                    
//                    return Character.toUpperCase(countryList[position].getStickItem()[0]).toLong()
//
//                }
//
//            }))
//
//            /**
//             *Click event for adapter
//             */
//            areaAdapter.setOnItemClickListener { adapter, view, position ->
//                intent.putExtra(SelectAreaActivity.COUNTRYCODE, countryList[position].dialingCode)
//                if (Locale.getDefault().language.contentEquals("zh")) {
//                    intent.putExtra(SelectAreaActivity.AREA, countryList[position].cnName)
//                } else {
//                    intent.putExtra(SelectAreaActivity.AREA, countryList[position].enName)
//                }
//
//                setResult(Activity.RESULT_OK, intent)
//                EventBus.getDefault().post(countryList[position])
//                finish()
//            }
//            areaAdapter.listener = object : AreaAdapter.FilterListener {
//                override fun getFilterData(list: java.util.ArrayList<CountryInfo>) {
//                    countryList.clear()
//                    countryList.addAll(list)
//                    areaAdapter.setList(countryList)
//                }
//
//            }
//
//            et_search?.addTextChangedListener(object : TextWatcher {
//                override fun afterTextChanged(s: Editable?) {
//
//                }
//
//                override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
//                }
//
//                override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
//                    areaAdapter.filter.filter(s)
//                }
//
//            })
        }

        /**
         *Grid sharing
         */
        fun webGridShare(
            context: Context,
            listener: DialogWebViewShareListener?,
            totalProfit: String = "",
            profitRate: String = "",
            time: String = "",
            count: String = "",
            coin: String = "",
            coinSymbol: String = ""
        ): CpTDialog {

            val total = context.getString(R.string.quant_grid_profit) + "($coinSymbol)"
            val rate = context.getString(R.string.grid_annualized_yield)
            val totalProfitTemp = "${ColorUtil.getMainGridResTypeCorner(totalProfit)}${
                BigDecimalUtils.divForDown(
                    totalProfit,
                    2
                ).toPlainString()
            }"
            val profitRateTemp = "${ColorUtil.getMainGridResTypeCorner(profitRate)}${profitRate}"
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_webview_grid_share_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    var threshold = 0
                    var inviteUrl = UserDataService.getInstance().inviteUrl

                    var imageDown = viewHolder?.getView<ImageView>(R.id.tv_swipe_down)
                    var imageNext = viewHolder?.getView<ImageView>(R.id.tv_swipe_next)
                    var tvProfit = viewHolder?.getView<TextView>(R.id.tv_profit)
                    var tvNumber = viewHolder?.getView<TextView>(R.id.tv_number)
                    var tvQrCode = viewHolder?.getView<ImageView>(R.id.tv_qr_code)
                    var ivLogo = viewHolder?.getView<ImageView>(R.id.iv_logo)

                    var tvProfitSum = viewHolder?.getView<TextView>(R.id.tv_profit_sum_value)
                    var tvProfitPrice = viewHolder?.getView<TextView>(R.id.tv_profit_price_vale)
                    var tvTime = viewHolder?.getView<TextView>(R.id.tv_loss_price_value)

                    viewHolder?.setText(R.id.tv_app_name_title, "grid_share_title".tr(context))
                    viewHolder?.setText(R.id.tv_app_name_desc, "grid_share_desc".tr(context))
                    viewHolder?.setText(R.id.tv_app_name, com.blankj.utilcode.util.AppUtils.getAppName())
                    viewHolder?.setText(R.id.tv_profit_sum, "quant_order_pending_totalcount".tr(context))
                    viewHolder?.setText(R.id.tv_loss_price, "quant_run_time".tr(context))
                    viewHolder?.setText(R.id.tv_profit_price, "filter_mix_tradeCoinPair".tr(context))
                    tvProfitSum?.text = count
                    tvProfitPrice?.text = coin
                    tvTime?.text = time

                    tvQrCode?.setImageBitmap(BitmapUtils.generateBitmap(inviteUrl, 300, 300))
                    ivLogo?.imageResource = R.mipmap.ic_launcher
                    tvProfit?.text = total
                    tvNumber?.run {
                        textColor = ColorUtil.getMainGridResType(totalProfit)
                        text = totalProfitTemp
                    }
                    imageDown?.setOnClickListener {
                        when (threshold) {
                            0 -> {
                                threshold = 1
                                tvProfit?.text = rate
                                tvNumber?.run {
                                    textColor = ColorUtil.getMainGridResType(profitRate)
                                    text = "$profitRateTemp%"
                                }

                            }
                            1 -> {
                                threshold = 0
                                tvProfit?.text = total
                                tvNumber?.run {
                                    textColor = ColorUtil.getMainGridResType(totalProfit)
                                    text = totalProfitTemp
                                }

                            }
                        }
                    }

                    imageNext?.setOnClickListener {
                        when (threshold) {
                            0 -> {
                                threshold = 1
                                tvProfit?.text = rate
                                tvNumber?.run {
                                    textColor = ColorUtil.getMainGridResType(profitRate)
                                    text = "$profitRateTemp%"
                                }
                            }
                            1 -> {
                                threshold = 0
                                tvProfit?.text = total
                                tvNumber?.run {
                                    textColor = ColorUtil.getMainGridResType(totalProfit)
                                    text = "$totalProfitTemp"
                                }
                            }
                        }
                    }
                }
                .addOnClickListener(R.id.btn_share)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.btn_share -> {
                            val mainLayout =
                                viewHolder?.getView<RelativeLayout>(R.id.rl_contract_share_layout)
                            mainLayout?.apply {
                                Handler().postDelayed({
                                    listener?.confirmShare(this)
                                }, 200)
                            }
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        interface DialogWebViewAliYunSlideListener {

            fun webviewSlideListener(json: Map<String, String>)
        }

        fun webAliyunShare(
            context: Context,
            listener: DialogWebViewAliYunSlideListener?,
            webUrl: String = ""
        ): CpTDialog {

            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_aliyun_slide)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    val testWebview = viewHolder?.getView<WebView>(R.id.rv_webview)
                    testWebview!!.settings.useWideViewPort = true
                    testWebview.settings.loadWithOverviewMode = true
                    //It is recommended to prohibit cache loading to ensure that the latest sliding verification components can be quickly obtained for confrontation in the event of an attack.
                    testWebview.settings.cacheMode = WebSettings.LOAD_NO_CACHE //LOAD_NO_CACHE
                    testWebview.settings.domStorageEnabled = true //Enable local DOM storage to solve the problem of blank pages when loading some links
                    testWebview.settings.allowContentAccess = true
                    //Set not to use the default browser, but to load the page directly using the WebView component.
                    testWebview.setWebViewClient(object : WebViewClient() {
                        override fun shouldOverrideUrlLoading(
                            view: WebView,
                            url: String?
                        ): Boolean {
                            view.loadUrl(url!!)
                            return true
                        }

                        override fun onReceivedSslError(
                            view: WebView?,
                            handler: SslErrorHandler?,
                            error: SslError?
                        ) {
                            super.onReceivedSslError(view, handler, error)
                            var builder = AlertDialog.Builder(view?.getContext());
                            builder.setMessage(
                                LanguageUtil.getString(
                                    context,
                                    "base_error_prompt5"
                                )
                            )
                            builder.setPositiveButton(
                                LanguageUtil.getString(
                                    context,
                                    "common_text_btnConfirm"
                                )
                            ) { dialog, which -> handler?.proceed(); };
                            builder.setNegativeButton(
                                LanguageUtil.getString(
                                    context,
                                    "common_text_btnCancel"
                                )
                            ) { dialog, which -> handler?.cancel() };
                            var dialog = builder.create()
                            dialog.show()
                        }
                    })
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                        WebView.setWebContentsDebuggingEnabled(true)
                    }
                    //Set the WebView component to support loading JavaScript.
                    testWebview.settings.javaScriptEnabled = true
                    //Establish a bridge for JavaScript to call Java interfaces.
                    testWebview.addJavascriptInterface(SlideJsInterface(listener), "testInterface")
                    //Load the business page.
                    testWebview.loadUrl(webUrl)
                }
                .addOnClickListener(R.id.imClose)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.imClose -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        fun createCloudFlareVerify(context:Context, bean: CloudflareBean, listener: CloudFlareView.OnCloudFlareListener?): CpTDialog {
            var cfvVerify:CloudFlareView? = null
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_cloudflare_verify)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(dimAmountValue)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.run {
                        getView<QMUIFrameLayout>(R.id.qf_layout).setBorderColor(
                            if(PublicInfoDataService.getInstance().themeMode==PublicInfoDataService.THEME_MODE_NIGHT){
                                ContextCompat.getColor(context,R.color.fill_3)
                            }else{
                                Color.parseColor("#EDEFF2")
                            }
                        )
                        setText(R.id.tvTitle,"complete_verify".tr(context))
                        cfvVerify = getView(R.id.cfv_verify)
                        cfvVerify?.initCloudFlare(bean.siteKey,bean.domain)
                        cfvVerify?.listener = listener
                    }
                }
                .setOnDismissListener {
                    cfvVerify?.run{
                        this.listener = null
                        if (parent != null) {
                            (parent as ViewGroup).removeView(this)
                        }
                        stopLoading()
                        //Call this method on exit to remove the bound service, otherwise certain specific systems may report errors
                        settings.javaScriptEnabled = false
                        clearHistory()
                        clearView()
                        removeAllViews()
                        destroy()
                    }
                }
                .addOnClickListener(R.id.imClose)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.imClose -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        fun createSafeVerifyDialog(context:Context, dataBean: TartCaptchaV2Bean, callback:((dataMap:Map<String,String>) -> Unit)) {
            val verifyType = PublicInfoDataService.getInstance().getVerifyType(null)
            val dataMap = hashMapOf<String,String>()
            //0 Mixed mode，1 aliyun，2 Geetest，3 cloudflare
            when(verifyType){
                0 -> {
                    //Mixed mode
                    val random = Random()
                    val randomType = if (random.nextBoolean()) 2 else 3
                    startSafeVerify(context,randomType,dataBean,dataMap,callback)
                }
                1 -> {
                    //aliyun
                    callback.invoke(dataMap)
                }
                2,3 -> {
                    startSafeVerify(context,verifyType,dataBean,dataMap,callback)
                }
                else -> {
                    callback.invoke(dataMap)
                }
            }
        }

        private fun startSafeVerify(context:Context,type:Int,dataBean: TartCaptchaV2Bean,dataMap:HashMap<String,String>,callback:((dataMap:Map<String,String>) -> Unit)){
            dataMap.clear()
            when(type){
                2 -> {//Geetest
                    dataBean.geetest?.let {
                        Utils.gee3test(context,it, object: Gt3GeeListener{
                            override fun onSuccess(result: ArrayList<String>) {
                                dataMap["geetest_challenge"] = result[0]
                                dataMap["geetest_validate"] = result[1]
                                dataMap["geetest_seccode"] = result[2]
                                Utils.setGeetestDeatroy()
                                callback.invoke(dataMap)
                            }
                        })
                    } ?: com.chainup.kit.utils.ToastUtils.showToast(context,LanguageUtil.getString(context,"verifyEroor"))
                }
                3 -> {//cloudflare
                    dataBean.cloudflare?.let {
                        var verifyDialog:CpTDialog? = null
                        verifyDialog = createCloudFlareVerify(
                            context,
                            it,
                            listener = object: CloudFlareView.OnCloudFlareListener{
                                override fun onComplete(token: String) {
                                    dataMap["cloudFlareToken"] = token
                                    Handler(Looper.getMainLooper()).postDelayed({
                                        verifyDialog?.dismissAllowingStateLoss()
                                    },1000)
                                    callback.invoke(dataMap)
                                }

                                override fun onError(message: String) {
                                    if("".equals(message)) return
                                    com.chainup.kit.utils.ToastUtils.showToast(context,message)
                                }

                            }
                        )
                    } ?: com.chainup.kit.utils.ToastUtils.showToast(context,LanguageUtil.getString(context,"verifyEroor"))
                }
                else -> {
                    callback.invoke(dataMap)
                }
            }
        }


        /**
         *String bottom dialog
         *
         */
        fun showNewHomeGridDialog(
            context: Context?,
            list: ArrayList<JSONObject>,
            listener: DialogOnItemClickListener?
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_grid_new_dialog)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setDialogAnimationRes(R.style.DialogAnimation)
                .setCancelableOutside(true)
                .setOnBindViewListener {
                    it.setText(
                        R.id.tv_more,
                        LanguageUtil.getString(context, "common_action_showMore")
                    )
                    val adapter = NewHomePageServiceAdapter(context,list)
                    var listView = it.getView<GridRecyclerView>(R.id.recycler_view)
                    val mLayoutManager = GridLayoutManager(context, 5)

                    listView?.layoutManager = mLayoutManager
                    listView?.adapter = adapter
                    val controller =
                        AnimationUtils.loadLayoutAnimation(
                            context,
                            R.anim.gridlayout_animation_from_bottom
                        );
                    val divider =
                        GridSpacingItemDecoration(5, ViewUtil.dpToPx(18f), ViewUtil.dpToPx(4f))
                    listView?.addItemDecoration(divider)
                    listView?.setLayoutAnimation(controller);
                    adapter.notifyDataSetChanged();
                    listView?.scheduleLayoutAnimation();
                    adapter.setOnItemClickListener { adapter, view, position ->
                        listener?.clickItem(position)

                    }
                }
                .addOnClickListener(R.id.ic_close)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.ic_close -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        //Account detection dialog
        fun showConfirmAccountDestroyDialog(context: Activity,bindListener: OnCpBindViewListener): CpTDialog {
            val activity = context as AppCompatActivity
            return CpTDialog.Builder(activity.supportFragmentManager)
                .setWidth(DisplayUtil.dip2px(312))
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(true)
                .setLayoutRes(R.layout.dialog_account_destroy_layout)
                .setOnBindViewListener(bindListener)
                .addOnClickListener(R.id.cub_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when(view.id){
                        R.id.cub_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }


        fun showAgentRebateRatioDialog(context:Context,dataList:ArrayList<ScaleInfoBean>){
            val appCompatActivity = context as AppCompatActivity
            var dialog:CpTDialog? = null
            dialog = CpTDialog.Builder(appCompatActivity.supportFragmentManager)
                .setWidth(DisplayUtils.dip2px(context,312.0f))
                .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(true)
                .setLayoutRes(R.layout.dialog_agent_level_layout)
                .setOnBindViewListener(object :OnCpBindViewListener{
                    override fun bindView(viewHolder: CpBindViewHolder?) {
                        viewHolder?.run {
                            val cubConfirm = getView<CommonlyUsedButton>(R.id.cub_confirm)
                            cubConfirm.isEnable(true)
                            cubConfirm.textContent = LanguageUtil.getString(context,"alert_common_iknow")
                            setText(R.id.tv_title,LanguageUtil.getString(context,"RebateRate"))
                            val rvList = getView<RecyclerView>(R.id.rv_datalist)
                            rvList.layoutManager = GridLayoutManager(context,2,GridLayoutManager.VERTICAL,false)
                            rvList.setHasFixedSize(true)
                            rvList.adapter = AgentLevelAdapter(dataList)
                            cubConfirm.listener = object : CommonlyUsedButton.OnBottonListener{
                                override fun bottonOnClick() {
                                    dialog?.dismiss()
                                }

                            }
                        }
                    }
                })
                .create()
                .show()

        }

        fun showSignSuccessDialog(
            context: Context,
            reward:String,
            unit:String,
            message:String?=null
        ) {
            KKTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_signin_success_layout)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(dimAmountValue)
                .setCancelableOutside(false)
                .setOnBindViewListener { viewHolder: KKBindViewHolder?, tDialog ->
                    viewHolder?.run {
                        setText(R.id.tv_sign_success,if(message==null) LanguageUtil.getString(context,"rewardCenter_text13") else message)

                        getView<KKButtonKit>(R.id.btn_confirm).textContent = LanguageUtil.getString(context,"rewardCenter_text14")
                        val value = "$reward $unit"
                        val spannableString = SpannableString(value)
                        val absoluteSizeSpan = AbsoluteSizeSpan(24, true)
                        val absoluteSizeSpanUnit = AbsoluteSizeSpan(16, true)
                        val foregroundColorSpan = ForegroundColorSpan(ContextCompat.getColor(context,R.color.main_color))
                        val foregroundColorSpanUnit = ForegroundColorSpan(ContextCompat.getColor(context,R.color.text_1))
                        spannableString.setSpan(absoluteSizeSpan,0,reward.length,Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
                        spannableString.setSpan(foregroundColorSpan,0,reward.length,Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
                        spannableString.setSpan(absoluteSizeSpanUnit,reward.length,value.length,Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
                        spannableString.setSpan(foregroundColorSpanUnit,reward.length,value.length,Spanned.SPAN_EXCLUSIVE_INCLUSIVE)
                        setText(R.id.tv_sign_value,spannableString)
                    }
                }
                .addOnClickListener(R.id.btn_confirm)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.btn_confirm -> {
                            tDialog.dismiss()
                        }
                    }

                }
                .create()
                .show()
        }


        fun showRewardSignUnPassDialog(
            context: Context,
            listener: DialogBottomListener,
            title: String = "",
            googleValid:Boolean,
            identifyValid:Boolean
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_otc_trading_trading_permissions_dialog)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    viewHolder?.setGone(R.id.ll_nick_layout, false)
                    viewHolder?.setText(
                        R.id.tv_google_label,
                        LanguageUtil.getString(context, "otcSafeAlert_action_bindGoogle")
                    )
                    viewHolder?.setText(
                        R.id.tv_identify_label,
                        LanguageUtil.getString(context, "kyc_page_name")
                    )
                    viewHolder?.setGone(R.id.rl_google, googleValid)
                    viewHolder?.setGone(R.id.ll_trading_real_layout, identifyValid)
                    if (!TextUtils.isEmpty(title)) {
                        viewHolder?.setText(R.id.tv_title, title)
                    }
                    viewHolder?.setText(R.id.tv_trading_content, LanguageUtil.getString(context,"rewardCenter_text40"))

                    if (UserDataService.getInstance().googleStatus != 1) {
                        viewHolder?.getView<TextView>(R.id.tv_google)?.isEnabled = true
                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text17"))
                    } else {
                        viewHolder?.getView<TextView>(R.id.tv_google)?.isEnabled = false
                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text16"))
                    }

                    if (UserDataService.getInstance().authLevel != 1) {
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text17"))
                    } else {
//                            viewHolder?.getView<ImageView>(R.id.iv_realname_certification)?.setImageResource(R.drawable.fiat_complete)
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text16"))
                    }

                }
                .addOnClickListener(
                    R.id.tv_realname_certification,
                    R.id.tv_google,
                    R.id.tv_nickname,
                    R.id.tv_cancel
                )
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    tDialog.dismiss()
                    listener.sendConfirm(view)
                }
                .create()
                .show()
        }



        /**
         *Real name authentication is required
         *Certification
         */

        fun OTCTradingMustPermissionsDialogNew(
            context: Context,
            listener: DialogBottomListener,
            type: Int = 1,
            title: String = "",
            isNeedBindGa:Boolean = true
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_validation_must_dialog)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setGone(R.id.layout_google,isNeedBindGa)
                    if (type != 1) {
                        viewHolder?.setGone(R.id.ll_nick_layout, false)
                        if (type != -1) {
                            viewHolder?.setGone(R.id.ll_trading_real_layout, false)
                        }
                    }
//                        viewHolder?.setText(R.id.tv_tip, LanguageUtil.getString(context, "common_text_tip"))
                    viewHolder?.setText(
                        R.id.tv_nick_name,
                        LanguageUtil.getString(context, "otcSafeAlert_action_nickname")
                    )
                    viewHolder?.setText(
                        R.id.tv_ga,
                        LanguageUtil.getString(context, "otcSafeAlert_action_bindGoogle")
                    )
                    viewHolder?.setText(
                        R.id.tv_real_auth,
                        LanguageUtil.getString(context, "kyc_page_name")
                    )

//                    val isGoogle = PublicInfoDataService.getInstance().isEnforceGoogleAuth(null)
//                    viewHolder?.setGone(R.id.layout_google, isGoogle)
//                        viewHolder?.setText(R.id.tv_cancel, LanguageUtil.getString(context, "common_text_btnCancel"))
//                        viewHolder?.setText(R.id.tv_goto_set, LanguageUtil.getString(context, "common_text_btnSetting"))
                    if (!TextUtils.isEmpty(title)) {
                        viewHolder?.setText(R.id.tv_validation_content, title)
                    } else {
                        val currencyTypeTitle =
                            if (PublicInfoDataService.getInstance().getB2CSwitchOpen(null)) {
                                LanguageUtil.getString(context, "otcSafeAlert_text_title_forotc")
                            } else {
                                LanguageUtil.getString(context, "otcSafeAlert_text_title")
                            }
                        viewHolder?.setText(R.id.tv_validation_content, currencyTypeTitle)
                    }

                    if (TextUtils.isEmpty(UserDataService.getInstance().nickName)) {
                        viewHolder?.getView<TextView>(R.id.tv_nickname_set)
                            ?.isEnabled = true
//                            viewHolder?.getView<ImageView>(R.id.iv_nickname)?.setImageResource(R.drawable.fiat_unfinished)

                        viewHolder?.getView<TextView>(R.id.tv_nickname_set)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                        viewHolder?.getView<TextView>(R.id.tv_nickname_set)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text17"))

                    } else {
                        viewHolder?.getView<TextView>(R.id.tv_nickname_set)
                            ?.isEnabled = false
//                            viewHolder?.getView<ImageView>(R.id.iv_nickname)?.setImageResource(R.drawable.fiat_complete)

                        viewHolder?.getView<TextView>(R.id.tv_nickname_set)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))

                        viewHolder?.getView<TextView>(R.id.tv_nickname_set)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text16"))
                    }

                    if (UserDataService.getInstance().googleStatus != 1) {
//                            viewHolder?.getView<ImageView>(R.id.iv_google)?.setImageResource(R.drawable.fiat_unfinished)
                        viewHolder?.getView<TextView>(R.id.tv_google)?.isEnabled = true
                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text17"))
                    } else {
//                            viewHolder?.getView<ImageView>(R.id.iv_google)?.setImageResource(R.drawable.fiat_complete)
                        viewHolder?.getView<TextView>(R.id.tv_google)?.isEnabled = false

                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))

                        viewHolder?.getView<TextView>(R.id.tv_google)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text16"))
                    }

                    if (UserDataService.getInstance().authLevel==0) {
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.isEnabled = true
//                            viewHolder?.getView<ImageView>(R.id.iv_realname_certification)?.setImageResource(R.drawable.fiat_unfinished)
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setTextColor(ColorUtil.getColor(R.color.main_blue))
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text17"))
                    } else {
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.isEnabled = false
//                            viewHolder?.getView<ImageView>(R.id.iv_realname_certification)?.setImageResource(R.drawable.fiat_complete)

                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setTextColor(ColorUtil.getColor(R.color.normal_text_color))
                        viewHolder?.getView<TextView>(R.id.tv_realname_certification)
                            ?.setText(LanguageUtil.getString(context, "personal_Center_text16"))

                    }

                }
                .addOnClickListener(
                    R.id.tv_realname_certification,
                    R.id.tv_google,
                    R.id.tv_nickname_set,
                    R.id.tv_cancel
                )
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    tDialog.dismiss()
                    listener.sendConfirm(view)
                    when (view.id) {
                        R.id.tv_google -> {
                            tDialog.dismiss()
                            listener.sendConfirm()
                        }
                        R.id.tv_nickname_set -> {
                            tDialog.dismiss()
                            listener.sendConfirm()
                        }
                        R.id.tv_realname_certification -> {
                            listener.sendConfirm()
                            tDialog.dismiss()
                        }
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }


        fun showFlowFliterDialog(context: Context,sceneList:ArrayList<CashFlowSceneBean.Scene>) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.dialog_flow_fliter)
                .setScreenWidthAspect(context,1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.5f)
                .setCancelableOutside(false)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setText(R.id.tv_title, LanguageUtil.getString(context,"otc_choose_symbol"))
                    viewHolder?.setText(R.id.tv_cancel, LanguageUtil.getString(context, "reset"))
                    viewHolder?.setText(R.id.tv_cancel_btn, LanguageUtil.getString(context, "common_text_btnCancel"))
                    viewHolder?.setText(R.id.tv_confirm_btn, LanguageUtil.getString(context, "common_text_btnConfirm"))
                    viewHolder?.setText(R.id.item_filter_time, LanguageUtil.getString(context,"charge_text_date"))
                    viewHolder?.setText(R.id.item_filter_order_type, LanguageUtil.getString(context,"transfer_type"))

                    val labelsType = viewHolder?.getView<LabelsViewV2>(R.id.labels_type)
                    labelsType?.setLabels(sceneList, object : LabelsViewV2.LabelTextProvider<CashFlowSceneBean.Scene> {
                        override fun getLabelText(
                            label: TextView?,
                            position: Int,
                            data: CashFlowSceneBean.Scene?
                        ): CharSequence {
                            return data?.keyText.toString()
                        }
                    })

                    val tvStart = viewHolder?.getView<TextView>(R.id.pet_start_time)
                    val tvEnd = viewHolder?.getView<TextView>(R.id.pet_end_time)

//                    if(timeType != ""){
//                        val times = DateUtils.get7DayTimeStart(timeType)
//                        tempStart = DateUtils.getYearMonthDayMS(times.first.toLong())
//                        tempEnd = DateUtils.getYearMonthDayMS(times.second.toLong())
//                        tvStart?.text = tempStart
//                        tvEnd?.text = tempEnd
//                    } else {
//                        tvStart?.text = tempStart
//                        tvEnd?.text = tempEnd
//                    }


                    tvStart?.setOnClickListener {
                        showFilterTimeDialog(context,true,"","",object : SelectDateLeverView.IDateValue{
                            override fun returnValue(startTime: String, endTimes: String) {
//                                tempStart = startTime
//                                tempEnd = endTimes
//                                tvStart.text = startTime
//                                tvEnd?.text = endTimes
                            }
                        })
                    }

                    tvEnd?.setOnClickListener {
                        showFilterTimeDialog(context,true,"","",object : SelectDateLeverView.IDateValue{
                            override fun returnValue(startTime: String, endTimes: String) {
//                                tempStart = startTime
//                                tempEnd = endTimes
//                                tvStart.text = startTime
//                                tvEnd?.text = endTimes
//                                calibrationAdapter.index = ""
//                                calibrationAdapter.notifyDataSetChanged()
                            }
                        })
                    }

//                    allSymbol?.setOnClickListener {
////                        listener?.sendSelectSymbol()
//                    }

//                    selectSymbol.observe(context, Observer {
//                        tempSymbol = it.first
//                        tvSymbol?.text = it.second
//                    })

                    // 处理数据填充

//                    val layoutManager = GridLayoutManager(context, 4)
//                    layoutManager.isAutoMeasureEnabled = false
//                    timeRV?.layoutManager = layoutManager
//                    val divider: GridItemDecoration = GridItemDecoration.Builder(context)
//                        .setVerticalSpan(R.dimen.dp_10)
//                        .setShowLastLine(false)
//                        .setColorResource(R.color.transparent)
//                        .build()
//
//                    val dividerStatusNew: GridItemDecoration = GridItemDecoration.Builder(context)
//                        .setVerticalSpan(R.dimen.dp_10)
//                        .setHorizontalSpan(R.dimen.dp_10)
//                        .setShowLastLine(false)
//                        .setColorResource(R.color.transparent)
//                        .build()
//
//                    val flexboxLayoutManager = FlexboxLayoutManager(context)
//                    flexboxLayoutManager.flexDirection = FlexDirection.ROW
//                    flexboxLayoutManager.flexWrap = FlexWrap.WRAP
//
//                    val flexboxLayoutManagerType = FlexboxLayoutManager(context)
//                    flexboxLayoutManagerType.flexDirection = FlexDirection.ROW
//                    flexboxLayoutManagerType.flexWrap = FlexWrap.WRAP
//
//                    timeRV?.addItemDecoration(divider)
//
//
//                    calibrationAdapter.index = timeType
//                    timeRV?.adapter = calibrationAdapter
                }
                .addOnClickListener(R.id.tv_cancel_btn, R.id.tv_confirm_btn,R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel_btn -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_cancel -> {
                            // reset
//                            val tvStart = viewHolder?.getView<TextView>(R.id.pet_start_time)
//                            val tvEnd = viewHolder?.getView<TextView>(R.id.pet_end_time)
//
//                            val times = DateUtils.get7DayTimeStart("0")
//
//                            tempStart = DateUtils.getYearMonthDayMS(times.first.toLong())
//                            tempEnd = DateUtils.getYearMonthDayMS(times.second.toLong())
//                            tvStart?.text = tempStart
//                            tvEnd?.text = tempEnd
//
//                            calibrationAdapter.index = "0"
//                            calibrationAdapter.notifyDataSetChanged()
//
//                            // 处理逻辑
//                            typeAdapter.resetData(orderType)
//                            slideAdapter.resetData(slideType)
//                            statusAdapter.resetData(statusType)
//
//                            selectSymbol.postValue(Pair("",LanguageUtil.getString(context,"common_action_sendall")))


                        }
                        R.id.tv_confirm_btn -> {

//                            listener?.sendConfirm(tempSymbol,calibrationAdapter.getTimeType(),tempStart,tempEnd,
//                                statusAdapter.getAllType(),slideAdapter.getAllType(),typeAdapter.getAllType())
//                            tDialog.dismiss()
                        }

                    }
                }
                .create()
                .show()

        }

        fun showFilterTimeDialog(context: Context,
                                 isStart: Boolean = true,
                                 startTimeTemp: String = "",
                                 endTimeTemp: String = "",
                                 listener: SelectDateLeverView.IDateValue?): CpTDialog {
            var start = startTimeTemp
            var end = endTimeTemp
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_dialog_time_view)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setDialogAnimationRes(R.style.DialogAnimation)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setText(R.id.tv_cancel_btn, LanguageUtil.getString(context, "common_text_btnCancel"))
                    viewHolder?.setText(R.id.tv_title, LanguageUtil.getString(context, "otc_choose_symbol"))
                    viewHolder?.setText(R.id.tv_done_btn, LanguageUtil.getString(context, "common_text_btnConfirm"))

                    val dateTime =  viewHolder?.getView<SelectDatePricerView>(R.id.sdv_asset_top_up)
                    if(endTimeTemp.isEmpty()){
                        end= DateUtils.getCurrentDate(DateUtils.FORMAT_YEAR_MONTH_DAY)
                    }
                    if(startTimeTemp.isEmpty()){
                        start=DateUtils.getCurrentDateByOffset(DateUtils.FORMAT_YEAR_MONTH_DAY,Calendar.DATE,-7)
                    }
                    dateTime?.initData(context,start,end,isStart)
                    dateTime?.dateListener = object : SelectDatePricerView.IDateValue{
                        override fun returnValue(startTime: String, endTimes: String) {
                            start = startTime
                            end = endTimes
                        }
                    }
                }
                .addOnClickListener(R.id.tv_cancel_btn,R.id.tv_done_btn)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel_btn -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_done_btn -> {
                            LogUtil.e("SelectDateLeverView","start ${start}  end ${end}")
                            if(!DateUtils.dayIsStop(start,end)){
                                com.chainup.kit.utils.ToastUtils.showToast(context,LanguageUtil.getString(context,"trade_time_filter_error"))
                                return@setOnViewClickListener
                            }
                            tDialog.dismiss()
                            listener?.returnValue(start,end)
                        }
                    }
                }
                .create()
                .show()
        }

        fun showSuspensionChargingDialog(context: Context, viewListener: OnCpBindViewListener?,
                                         listener: NewDialogUtils.DialogBottomListener
        ):  CpTDialog {
            return  CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.sl_item_suspension_charging)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(false)
                .setOnBindViewListener(viewListener)
                .addOnClickListener(R.id.tv_confirm_btn, R.id.tv_cancel_btn)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.tv_confirm_btn -> {
                            listener.sendConfirm()
                            tDialog.dismiss()
                        }
                        R.id.tv_cancel_btn -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

        }

        fun showSimpleSafetyAdviceDialog(context: Context, viewListener: OnCpBindViewListener?,
                                         listener: NewDialogUtils.DialogBottomListener
        ):  CpTDialog {
            var isSelected = false
            return  CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.sl_item_simple_safety_advice_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setScreenWidthAspect(context, 0.89f)
                .setCancelableOutside(false)
                .setOnBindViewListener { viewHolder ->
                    val imageView = viewHolder?.getView<ImageView>(R.id.iv_state)
                    imageView?.setOnClickListener {
                        isSelected = !isSelected
                        if (isSelected) {
                            imageView.imageResource = R.drawable.ic_public_selected
                        } else {
                            imageView.imageResource = R.drawable.public_unselected_square
                        }
                    }
                    viewHolder.setText(R.id.tv_text1,LanguageUtil.getString(context,"assets_security_advice_tips1"))
                    viewHolder.setText(R.id.tv_text2,LanguageUtil.getString(context,"assets_security_advice_tips2"))
                    viewHolder.setText(R.id.tv_text3,LanguageUtil.getString(context,"assets_security_advice_tips3"))
                    viewHolder.setText(R.id.tv_has_known,LanguageUtil.getString(context,"sl_str_no_longer_remind"))
                    viewHolder.getView<KKButtonKit>(R.id.tv_confirm_btn).textContent = LanguageUtil.getString(context,"alert_common_i_understand")
                }
                .addOnClickListener(R.id.tv_confirm_btn, R.id.tv_cancel_btn)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.tv_confirm_btn -> {
                            CpPreferenceManager.putBoolean(context, "isShowSafetyAdviceDialog", !isSelected)
                            listener.sendConfirm()
                            tDialog.dismiss()
                        }
                        R.id.tv_cancel_btn -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

        }

        fun showSimpleCreateContractDialog(context: Context, viewListener: OnCpBindViewListener?,
                                           listener: NewDialogUtils.DialogBottomListener
        ):  CpTDialog {
            return  CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.sl_item_simple_create_contract_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(false)
                .setOnBindViewListener(viewListener)
                .addOnClickListener(R.id.tv_confirm_btn, R.id.tv_cancel_btn)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.tv_confirm_btn -> {
                            listener.sendConfirm()
                            tDialog.dismiss()
                        }
                        R.id.tv_cancel_btn -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

        }
        fun createWithdrawAddressSelectDialog(context:Context,
                                              dataList:ArrayList<KKItemCardEntity>,
                                              listener: KKDialogUtils.DialogOnItemClickListener?)
                : KKTDialog {

            val adapter = object : KKBottomCardListRvAdapter(dataList){
                init {
                    addItemType(KKItemCardEntity.withdraw_address_type, R.layout.dialog_select_withdraw_address)
                }
                override fun convert(holder: BaseViewHolder, item: KKItemCardEntity) {
                    super.convert(holder, item)
                    val dataPair = item.arg as Pair<Int,Int>
                    holder.setGone(R.id.tk_tag,dataPair.first==0)
                    holder.setText(R.id.tv_title,item.title)
                    holder.setText(R.id.tv_sub_title,item.content)
                    holder.setText(R.id.tk_tag,"common_text_already_trust".tr(context))

                }
            }
            adapter.setOnItemClickListener { adapter, view, position ->
                listener?.clickItem(position)
            }
            adapter.setEmptyView(KKEmptyViewKit(context).apply {
                val params = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT,
                    PublicSizeUtil.dp2px(context,200f))
                params.gravity = Gravity.CENTER
                this.layoutParams = params
                this.setImageViewTop(20f)
            })

            return KKDialogUtils.showBottomListDialogByAdapter(
                context,
                adapter,
                "select_address".tr(context),
                null
            )
        }

    }

    class SlideJsInterface(mListener: DialogWebViewAliYunSlideListener?) {
        var listener: DialogWebViewAliYunSlideListener? = mListener

        @JavascriptInterface
        fun getSlideData(callData: String?) {
            println("callData ${callData}")
            if (!callData.isNullOrEmpty()) {
                var mapClass: Map<String, String> = HashMap()
                val map = JsonUtils.jsonToBean(callData, mapClass.javaClass)
                listener?.webviewSlideListener(map)
            }
        }
    }


}








