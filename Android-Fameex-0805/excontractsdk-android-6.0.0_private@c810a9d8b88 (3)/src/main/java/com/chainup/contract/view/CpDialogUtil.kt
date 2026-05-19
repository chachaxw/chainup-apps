package com.chainup.contract.view

import android.content.Context
import android.content.DialogInterface
import android.graphics.*
import android.graphics.drawable.BitmapDrawable
import android.text.Html
import android.text.TextUtils
import android.util.Log
import android.view.*
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.blankj.utilcode.util.AppUtils
import com.blankj.utilcode.util.KeyboardUtils
import com.bumptech.glide.Glide
import com.bumptech.glide.Priority
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.bumptech.glide.load.resource.bitmap.CenterCrop
import com.bumptech.glide.load.resource.bitmap.CircleCrop
import com.bumptech.glide.load.resource.bitmap.RoundedCorners
import com.bumptech.glide.request.RequestOptions
import com.chainup.contract.R
import com.chainup.contract.adapter.*
import com.chainup.contract.app.CpMyApp
import com.chainup.contract.bean.ContractListBean
import com.chainup.contract.bean.CpTabInfo
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.utils.*
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.contract.view.dialog.base.CpBindViewHolder
import com.chainup.contract.view.dialog.listener.OnCpBindViewListener
import com.chainup.kit.utils.PublicSizeUtil
import com.coorchice.library.SuperTextView
import com.yjkj.chainup.manager.CpLanguageUtil
import com.zyyoona7.popup.EasyPopup
import com.zyyoona7.popup.XGravity
import com.zyyoona7.popup.YGravity
import io.reactivex.Observable
import io.reactivex.Scheduler
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.cp_item_modify_position_dialog.view.*
import org.jetbrains.anko.backgroundColor
import org.jetbrains.anko.find
import org.jetbrains.anko.textColor
import org.json.JSONArray
import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.collections.ArrayList


//Created by $USER_NAME on 2018/10/15.

class CpDialogUtil {

    interface ConfirmListener {
        fun click(pos: Int = 0)
    }

    companion object {

        fun showNewsingleDialog2(
            context: Context,
            content: String,
            listener: CpNewDialogUtils.DialogBottomListener?,
            cancelTitle: String = "",
            returnListener: Boolean = false
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_new_normal_dialog2)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    val buttonView = viewHolder?.getView<SuperTextView>(R.id.tv_confirm_btn)
                    if (!TextUtils.isEmpty(cancelTitle)) {
                        buttonView?.text = cancelTitle
                    } else {
                        buttonView?.text = CpLanguageUtil.getString(context, "cp_calculator_text16")
                    }
                    viewHolder?.setText(R.id.tv_content, content)
                }
                .addOnClickListener(R.id.tv_confirm_btn)
                .setOnViewClickListener { _, _, tDialog ->
                    if (listener != null && returnListener) {
                        listener.sendConfirm()
                    }
                    tDialog?.dismiss()
                }
                .create()
                .show()


        }

        /**
         *Two buttons New dialog
         */
        fun showNewDoubleDialog(
            context: Context,
            content: String,
            listener: CpNewDialogUtils.DialogBottomListener?,
            title: String = "",
            cancelTitle: String = "",
            confrimTitle: String = ""
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_new_double_normal_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(false)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    if (!TextUtils.isEmpty(title)) {
                        viewHolder?.setGone(R.id.tv_title, true)
                        viewHolder?.setText(R.id.tv_title, title)
                    } else {
                        viewHolder?.getView<TextView>(R.id.tv_content)?.textSize =
                            context.resources.getDimension(R.dimen.sp_16)
                        viewHolder?.setTextColor(
                            R.id.tv_content,
                            ContextCompat.getColor(context, R.color.text_color)
                        )

                    }
                    viewHolder?.setText(
                        R.id.tv_cancel_btn,
                        CpLanguageUtil.getString(context, "cp_overview_text56")
                    )
                    if (confrimTitle.isNotEmpty()) {
                        viewHolder?.setText(R.id.tv_cancel_btn, cancelTitle)
                    }
                    if (!TextUtils.isEmpty(cancelTitle)) {
                        viewHolder?.setText(R.id.tv_confirm_btn, confrimTitle)
                    } else {
                        viewHolder?.setText(
                            R.id.tv_confirm_btn,
                            CpLanguageUtil.getString(context, "cp_calculator_text16")
                        )
                    }
                    viewHolder?.setText(R.id.tv_content, content)

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
         *K line market sharing function
         */
        fun showKLineShareDialog(context: Context,flutterEngineRenderer:Any?, mView: View, qrCodeString:String):CpTDialog? {
            var screenshotBitmap: Bitmap? = null

            if(flutterEngineRenderer!=null){
                screenshotBitmap = CpScreenShotUtil.getScreenShotFlutterBitmap(flutterEngineRenderer,mView)
            }else{
                screenshotBitmap = CpScreenShotUtil.getScreenshotBitmap((context as AppCompatActivity).window?.decorView)
            }
            var img_share: ImageView? = null
            var ll_share: View? = null
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_dialog_share_market)
                .setScreenWidthAspect(context, 1.0f)
                .setScreenHeightAspect(context, 1.0f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.run {
                        val options = RequestOptions()
                            .transform(
                                CenterCrop(),
                                RoundedCorners(PublicSizeUtil.dp2px(context,12.0f))
                            )
                            .error(R.mipmap.ic_launcher)
                            .priority(Priority.HIGH)
                        Glide.with(context).load(AppUtils.getAppIconId()).apply(options).into(getView(R.id.iv_app_icon))
                    }
//                        val iv_qrcode = viewHolder?.getView<ImageView>(R.id.iv_qrcode)
                    ll_share = viewHolder?.getView<View>(R.id.ll_share)
//                        viewHolder?.setText(R.id.tv_title, CpLanguageUtil.getString(context, "cp_overview_text56"))
                    viewHolder?.setText(R.id.btn_share, CpLanguageUtil.getString(context, "common_share_confirm"))
//                        var imgUrl = CpClLogicContractSetting.getInviteUrl()
                    val bmp: Bitmap? = CpBitmapUtils.Create2DCode(if (TextUtils.isEmpty(qrCodeString)) {
                        "error"
                    }else{
                        qrCodeString
                    }, 500, 500)
                    viewHolder?.setImageBitmap(R.id.iv_qr_code, bmp)
//                    viewHolder?.setImageResource(R.id.iv_app_icon, AppUtils.getAppIconId())
//                        GlideUtils.loadImageQr(context, iv_qrcode)
                    if (screenshotBitmap != null) {
                        //Obtain status bar height
                        val resourceId = context.getResources().getIdentifier("status_bar_height", "dimen", "android")
                        val mStatusBarHeight = context.getResources().getDimensionPixelSize(resourceId)
                        screenshotBitmap = Bitmap.createBitmap(screenshotBitmap!!, 0, mStatusBarHeight, screenshotBitmap!!.width,
                            screenshotBitmap!!.height - mStatusBarHeight, null, true)
                        img_share = viewHolder?.getView<ImageView>(R.id.img_share)
                        img_share?.setImageDrawable(BitmapDrawable(context.resources, screenshotBitmap))
                    }

                    Observable.timer(300,TimeUnit.MILLISECONDS)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe {
                            //Screen capture dialog
                            val bitmap: Bitmap? = CpScreenShotUtil.getScreenshotBitmap(ll_share)

                            CpZXingUtils.shareImageToWechat(
                                bitmap,
                                CpLanguageUtil.getString(context, "cp_extra_text116"),
                                context
                            )
                        }
                }
//                .addOnClickListener(R.id.btn_share, R.id.tv_cancel_btn, R.id.ll_bg)
//                .setOnViewClickListener { _, view,CpTDialog ->
//                    when (view.id) {
//                        R.id.btn_share -> {
//                            if (ll_share != null) {
//                                var bitmap: Bitmap? = CpScreenShotUtil.getScreenshotBitmap(ll_share)
//                                CpZXingUtils.shareImageToWechat(bitmap, CpLanguageUtil.getString(context,"cp_extra_text116"), context)
//                                CpTDialog.dismiss()
//                            }
//                        }
//                        R.id.ll_bg -> {
//                            CpTDialog.dismiss()
//                        }
//                        R.id.tv_cancel_btn -> {
//                            CpTDialog.dismiss()
//                        }
//                    }
//
//                }
                .create().show()
        }
        fun createCVCOrderPop(
            context: Context?,
            index: Int = 0,
            targetView: View,
            dialogItemClickListener: CpNewDialogUtils.DialogOnSigningItemClickListener?,
            dialogDismissClickListener: CpNewDialogUtils.DialogOnDismissClickListener?
        ) {
            val cvcEasyPopup = EasyPopup.create().setContentView(context, R.layout.cp_item_new_pop)
                .setFocusAndOutsideEnable(true)
                .setBackgroundDimEnable(true)
                .setWidth(targetView.width)
                .setAnimationStyle(R.style.cp_dialogAnim_otop)
                .setDimValue(0.5f)
                .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                .apply()
            cvcEasyPopup?.run {
                val rView = findViewById<RecyclerView>(R.id.recycler_view)
                var list = ArrayList<CpTabInfo>()
                list.add(
                    CpTabInfo(
                        CpLanguageUtil.getString(context, "cp_overview_text3").toString(), 1
                    )
                )
                list.add(
                    CpTabInfo(
                        CpLanguageUtil.getString(context, "cp_overview_text4").toString(), 2
                    )
                )
                list.add(
                    CpTabInfo(
                        CpLanguageUtil.getString(context, "cp_overview_text5").toString(), 3
                    )
                )

                list.add(CpTabInfo(CpLanguageUtil.getString(context, "cp_overview_post_only"), 4))
                list.add(CpTabInfo(CpLanguageUtil.getString(context, "cp_overview_ioc"), 6))
                list.add(CpTabInfo(CpLanguageUtil.getString(context, "cp_overview_fok"), 5))

                var adapter = CpPopAdapter(list, index)
                rView?.layoutManager = LinearLayoutManager(context)
                rView?.adapter = adapter
                rView?.setHasFixedSize(true)
                adapter.setOnItemClickListener { adapter, view, position ->
                    dialogItemClickListener?.clickItem(list[position].index, list[position].name)
                    cvcEasyPopup.dismiss()
                }

            }

            cvcEasyPopup?.showAtAnchorView(targetView, YGravity.BELOW, XGravity.ALIGN_RIGHT, 0, 10)

            cvcEasyPopup?.setOnDismissListener {
                dialogDismissClickListener?.clickItem()
            }
        }


        fun createQuantityTypePop(
            context: Context?,
            index: Int = 0,
            targetView: View,
            listData:ArrayList<CpTabInfo>,
            dialogItemClickListener: CpNewDialogUtils.DialogOnSigningItemClickListener?,
            dialogChildItemClickListener: CpNewDialogUtils.DialogOnSigningItemClickListener?,
            dialogDismissClickListener: CpNewDialogUtils.DialogOnDismissClickListener?
        ){
            val cvcEasyPopup = EasyPopup.create().setContentView(context, R.layout.cp_item_new_pop)
                .setFocusAndOutsideEnable(true)
                .setBackgroundDimEnable(true)
                .setWidth(targetView.width)
                .setAnimationStyle(R.style.cp_dialogAnim_otop_right)
                .setDimValue(0.5f)
                .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                .apply()
            cvcEasyPopup?.run {
                val rView = findViewById<RecyclerView>(R.id.recycler_view)

                var adapter = CpPopAdapter(listData, index)
                rView?.layoutManager = LinearLayoutManager(context)
                rView?.adapter = adapter
                rView?.setHasFixedSize(true)
                adapter.setOnItemClickListener { adapter, view, position ->
                    dialogItemClickListener?.clickItem(listData[position].index, listData[position].name)
                    cvcEasyPopup.dismiss()
                }
                adapter.setOnItemChildClickListener { adapter, view, position ->
                    dialogChildItemClickListener?.clickItem(listData[position].index, listData[position].name)
                }
            }

            cvcEasyPopup?.showAtAnchorView(targetView, YGravity.BELOW, XGravity.ALIGN_RIGHT, 0, 10)

            cvcEasyPopup?.setOnDismissListener {
                dialogDismissClickListener?.clickItem()
            }
        }


        /**
         *@param context Context
         *Whether @param marginModelCanSwitch can switch operation 0 to non switchable
         *@param mMarginModel Currently selected full warehouse=1 warehouse by warehouse=2
         * @return CpTDialog
         *Modify Margin Mode -->>New Version
         */
        fun createModifyMarginModeDialog(context: Context,marginModelCanSwitch: Int = 0,mMarginModel: Int = 0):CpTDialog{
            var isShowPositionDesc = false
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_modify_position_dialog)
                .setScreenWidthAspect(context, 1.0f)
                .setGravity(Gravity.BOTTOM)
                .setDialogAnimationRes(R.style.dialogBottomAnim)
                .setDimAmount(0.3f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.itemView?.run {
                        val tvNoSwitchPosition = findViewById<TextView>(R.id.tv_no_switch_position)
                        val tv_cp_content_text6 = findViewById<TextView>(R.id.tv_cp_content_text6)
                        val tv_cp_contract_setting_text3 =
                            findViewById<TextView>(R.id.tv_cp_contract_setting_text3)
                        val tv_cp_contract_setting_text4 =
                            findViewById<TextView>(R.id.tv_cp_contract_setting_text4)
                        val tvTabFull = findViewById<Button>(R.id.tv_tab_full)
                        val tvTabGradually = findViewById<Button>(R.id.tv_tab_gradually)
                        val tvTitle = findViewById<TextView>(R.id.tv_title)
                        val cancelBtn = findViewById<TextView>(R.id.cancelBtn)


                        tvTitle.text = CpLanguageUtil.getString(context,"cp_margin_mode")
                        cancelBtn.text = CpLanguageUtil.getString(context,"cp_overview_text56")
                        viewHolder.setText(R.id.confirmBtn,CpLanguageUtil.getString(context,"cp_calculator_text16"))

                        tvNoSwitchPosition.text =
                            CpLanguageUtil.getString(context, "cp_contract_setting_text7")


                        val iconDrawable = context.resources.getDrawable(R.mipmap.public_point)
                        iconDrawable.setBounds(0,0, CpDisplayUtils.dip2px(context,8f), CpDisplayUtils.dip2px(context,8f))
                        tvNoSwitchPosition.compoundDrawablePadding = CpDisplayUtils.dip2px(context,8f)
                        tvNoSwitchPosition.setCompoundDrawables(iconDrawable,null,null,null)

                        tvTabFull.text = CpLanguageUtil.getString(context, "cp_contract_setting_text1")
                        tvTabGradually.text = CpLanguageUtil.getString(context, "cp_contract_setting_text2")
                        tv_cp_content_text6.text = CpLanguageUtil.getString(context, "cp_content_text6")
                        tv_cp_contract_setting_text3.text =
                            CpLanguageUtil.getString(context, "cp_contract_setting_text3")
                        tv_cp_contract_setting_text4.text =
                            CpLanguageUtil.getString(context, "cp_contract_setting_text4")

                        when(mMarginModel){
                            //Select all warehouses
                            1 -> {
                                tvTabFull.isSelected = true
                                tvTabGradually.isSelected = false
                            }
                            //Select Warehouse by Warehouse
                            2 -> {
                                tvTabFull.isSelected = false
                                tvTabGradually.isSelected = true
                            }
                        }

                        //Non clickable situations
                        if (marginModelCanSwitch == 0) {
                            //Abolish
                            tvTabFull.isEnabled = false
                            tvTabGradually.isEnabled = false
                            confirmBtn.isEnabled = false
                            if(mMarginModel == 1){
                                //Full warehouse selection cannot be clicked
                                tvTabFull.background = ContextCompat.getDrawable(context,R.drawable.bg_margin_mode_no_enabled)
                                tvTabFull.textColor = ContextCompat.getColor(context,R.color.text_color_2)
                                //Warehouse by warehouse cannot be clicked
                                tvTabGradually.background = ContextCompat.getDrawable(context,R.drawable.cp_bg_trade_market_tip)
                                tvTabGradually.setTextColor(ContextCompat.getColor(context,R.color.text_color_2))
                            }else if(mMarginModel == 2){
                                //"Warehouse by warehouse selection cannot be clicked"
                                tvTabGradually.background = ContextCompat.getDrawable(context,R.drawable.bg_margin_mode_no_enabled)
                                tvTabGradually.textColor = ContextCompat.getColor(context,R.color.text_color_2)
                                //Full warehouse cannot be clicked
                                tvTabFull.background = ContextCompat.getDrawable(context,R.drawable.cp_bg_trade_market_tip)
                                tvTabFull.setTextColor(ContextCompat.getColor(context,R.color.text_color_2))
                            }
                            //Discard the button
                            confirmBtn.solid = ContextCompat.getColor(context,R.color.no_enable_color)
                            confirmBtn.textColor = ContextCompat.getColor(context,R.color.text_color_2)
                        }

                        tvNoSwitchPosition.visibility =
                            if (marginModelCanSwitch == 0) View.VISIBLE else View.GONE

                    }
                }
                .addOnClickListener(R.id.tv_tab_full, R.id.tv_tab_gradually, R.id.ll_show_position_info,R.id.confirmBtn,R.id.cancelBtn)
                .setOnViewClickListener { _, view, tDialog ->
                    var llPositionDesc:View? = null
                    var imgShowPositionInfo:View? = null
                    var tvTabFull:Button? = null
                    var tvTabGradually:Button? = null
                    var confirmBtn:SuperTextView? = null
                    tDialog.view?.run {
                        llPositionDesc = findViewById(R.id.ll_position_desc)
                        imgShowPositionInfo = findViewById<ImageView>(R.id.img_show_position_info)
                        tvTabFull = findViewById(R.id.tv_tab_full)
                        tvTabGradually = findViewById(R.id.tv_tab_gradually)
                        confirmBtn = findViewById(R.id.confirmBtn)
                    }
                    when(view.id){
                        //Full warehouse click
                        R.id.tv_tab_full -> {

                            if (marginModelCanSwitch == 0) {
                                return@setOnViewClickListener
                            }
                            Log.d("button","tv_tab_full")
                            tvTabFull?.isSelected = true
                            tvTabGradually?.isSelected = false
                            confirmBtn?.tag = "1"
                        }
                        //Warehouse by warehouse click
                        R.id.tv_tab_gradually -> {
                            if (marginModelCanSwitch == 0) {
                                return@setOnViewClickListener
                            }
                            Log.d("button","tv_tab_gradually")
                            tvTabFull?.isSelected = false
                            tvTabGradually?.isSelected = true
                            confirmBtn?.tag = "2"
                        }
                        //Explanatory click to expand
                        R.id.ll_show_position_info ->{
                            llPositionDesc?.visibility = if (!isShowPositionDesc) View.VISIBLE else View.GONE
                            if (!isShowPositionDesc) {
                                imgShowPositionInfo?.let { it.animate().setDuration(200).rotation(180f).start() }
                            } else {
                                imgShowPositionInfo?.let{ it.animate().setDuration(200).rotation(0f).start() }
                            }
                            isShowPositionDesc = !isShowPositionDesc
                        }
                        //Confirm button
                        R.id.confirmBtn -> {
                            //Take out the saved tag=the selected [full warehouse="1" warehouse by warehouse="2"]
                            var tag = confirmBtn?.tag
                            if(tag!=null){
                                tag = tag as String
                                val event = CpMessageEvent(CpMessageEvent.sl_contract_switch_lever_event)
                                event.msg_content = tag
                                CpEventBusUtil.post(event)
                            }
                            tDialog.dismiss()
                        }
                        R.id.cancelBtn -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }


        //Modify Deposit Mode ->>>old
        fun createModifyPositionPop(
            context: Context?,
            marginModelCanSwitch: Int = 0,
            mMarginModel: Int = 0,
            targetView: View,
            dialogItemClickListener: CpNewDialogUtils.DialogOnSigningItemClickListener?,
            dialogDismissClickListener: CpNewDialogUtils.DialogOnDismissClickListener?
        ) {
            var isShowPositionDesc = false
            val cvcEasyPopup =
                EasyPopup.create().setContentView(context, R.layout.cp_item_modify_position_dialog)
                    .setFocusAndOutsideEnable(true)
                    .setBackgroundDimEnable(true)
                    .setWidth(ViewGroup.LayoutParams.MATCH_PARENT)
                    .setDimValue(0f)
                    .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                    .apply()
            cvcEasyPopup?.run {
                val llDissmiss = findViewById<LinearLayout>(R.id.ll_dissmiss)
                val tvNoSwitchPosition = findViewById<TextView>(R.id.tv_no_switch_position)
                val tv_cp_content_text6 = findViewById<TextView>(R.id.tv_cp_content_text6)
                val tv_cp_contract_setting_text3 =
                    findViewById<TextView>(R.id.tv_cp_contract_setting_text3)
                val tv_cp_contract_setting_text4 =
                    findViewById<TextView>(R.id.tv_cp_contract_setting_text4)
                val tvTabFull = findViewById<Button>(R.id.tv_tab_full)
                val tvTabGradually = findViewById<Button>(R.id.tv_tab_gradually)
                val llShowPositionInfo = findViewById<LinearLayout>(R.id.ll_show_position_info)
                val imgShowPositionInfo = findViewById<ImageView>(R.id.img_show_position_info)
                val llPositionDesc = findViewById<LinearLayout>(R.id.ll_position_desc)

                tvNoSwitchPosition.text =
                    CpLanguageUtil.getString(context, "cp_contract_setting_text7")
                tvTabFull.text = CpLanguageUtil.getString(context, "cp_contract_setting_text1")
                tvTabGradually.text = CpLanguageUtil.getString(context, "cp_contract_setting_text2")
                tv_cp_content_text6.text = CpLanguageUtil.getString(context, "cp_content_text6")
                tv_cp_contract_setting_text3.text =
                    CpLanguageUtil.getString(context, "cp_contract_setting_text3")
                tv_cp_contract_setting_text4.text =
                    CpLanguageUtil.getString(context, "cp_contract_setting_text4")

                tvTabFull.setBackgroundResource(if (mMarginModel == 1) R.drawable.cp_btn_linear_blue_bg else R.drawable.cp_btn_linear_grey_bg)
                tvTabGradually.setBackgroundResource(if (mMarginModel == 2) R.drawable.cp_btn_linear_blue_bg else R.drawable.cp_btn_linear_grey_bg)
                tvTabFull.setTextColor(
                    if (mMarginModel == 1) CpColorUtil.getColor(R.color.main_blue) else CpColorUtil.getColor(
                        R.color.normal_text_color
                    )
                )
                tvTabGradually.setTextColor(
                    if (mMarginModel == 2) CpColorUtil.getColor(R.color.main_blue) else CpColorUtil.getColor(
                        R.color.normal_text_color
                    )
                )
                if (marginModelCanSwitch == 0) {
                    tvTabFull.setTextColor(CpColorUtil.getColor(R.color.hint_color))
                    tvTabGradually.setTextColor(CpColorUtil.getColor(R.color.hint_color))
                    tvTabFull.setBackgroundResource(if (mMarginModel == 1) R.drawable.cp_btn_linear_blue_grey_bg else R.drawable.cp_border_grey_fill)
                    tvTabGradually.setBackgroundResource(if (mMarginModel == 2) R.drawable.cp_btn_linear_blue_grey_bg else R.drawable.cp_border_grey_fill)
                }
                llDissmiss.setOnClickListener { cvcEasyPopup.dismiss() }
                llShowPositionInfo.setOnClickListener {
                    llPositionDesc.visibility = if (!isShowPositionDesc) View.VISIBLE else View.GONE
                    if (!isShowPositionDesc) {
                        imgShowPositionInfo.animate().setDuration(200).rotation(180f).start()
                    } else {
                        imgShowPositionInfo.animate().setDuration(200).rotation(0f).start()
                    }
                    isShowPositionDesc = !isShowPositionDesc
                }
                tvNoSwitchPosition.visibility =
                    if (marginModelCanSwitch == 0) View.VISIBLE else View.GONE
                tvTabFull.setOnClickListener {
                    if (marginModelCanSwitch == 0) {
                        return@setOnClickListener
                    }
                    cvcEasyPopup.dismiss()
                    val event = CpMessageEvent(CpMessageEvent.sl_contract_switch_lever_event)
                    event.msg_content = "1"
                    CpEventBusUtil.post(event)
                }
                tvTabGradually.setOnClickListener {
                    if (marginModelCanSwitch == 0) {
                        return@setOnClickListener
                    }
                    cvcEasyPopup.dismiss()
                    val event = CpMessageEvent(CpMessageEvent.sl_contract_switch_lever_event)
                    event.msg_content = "2"
                    CpEventBusUtil.post(event)
                }
            }

            cvcEasyPopup?.showAtAnchorView(targetView, YGravity.BELOW, XGravity.ALIGN_RIGHT, 0, 10)

            cvcEasyPopup?.setOnDismissListener {
                dialogDismissClickListener?.clickItem()
            }
        }

        fun createTopListPop(
            context: Context?,
            index: Int = 1,
            data: ArrayList<CpTabInfo>,
            targetView: View,
            dialogItemClickListener: CpNewDialogUtils.DialogOnSigningItemClickListener?,
            dialogDismissClickListener: CpNewDialogUtils.DialogOnDismissClickListener?
        ) {
            val cvcEasyPopup =
                EasyPopup.create().setContentView(context, R.layout.cp_item_new_top_pop)
                    .setFocusAndOutsideEnable(true)
                    .setBackgroundDimEnable(true)
                    .setWidth(ViewGroup.LayoutParams.MATCH_PARENT)
                    .setDimValue(0f)
                    .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                    .apply()
            cvcEasyPopup?.run {
                val llDissmiss = findViewById<LinearLayout>(R.id.ll_dissmiss)
                val rView = findViewById<RecyclerView>(R.id.recycler_view)

                var adapter = CpTopPopAdapter(data, index)
                rView?.layoutManager = LinearLayoutManager(context)
                rView?.adapter = adapter
                rView?.setHasFixedSize(true)
                adapter.setOnItemClickListener { adapter, view, position ->
                    dialogItemClickListener?.clickItem(position, data[position].name)
                    cvcEasyPopup.dismiss()
                }

                llDissmiss.setOnClickListener { cvcEasyPopup.dismiss() }
            }

            cvcEasyPopup?.showAtAnchorView(targetView, YGravity.BELOW, XGravity.ALIGN_RIGHT, 0, 10)

            cvcEasyPopup?.setOnDismissListener {
                dialogDismissClickListener?.clickItem()
            }
        }


        fun createOrderTypePop(
            context: Context?,
            index: Int = 1,
            targetView: View,
            dialogItemClickListener: CpNewDialogUtils.DialogOnSigningItemClickListener?,
            dialogDismissClickListener: CpNewDialogUtils.DialogOnDismissClickListener?,
            dgWidth:Int? = null
        ) {
            val cvcEasyPopup = EasyPopup.create().setContentView(context, R.layout.cp_item_new_pop)
                .setFocusAndOutsideEnable(true)
                .setBackgroundDimEnable(true)
                .setAnimationStyle(R.style.cp_dialogAnim_otop_right)
                .setWidth(if(dgWidth==null) targetView.width+CpSizeUtils.dp2px(20.0f) else dgWidth)
                .setDimValue(0.3f)
                .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                .apply()
            cvcEasyPopup?.run {
                val rView = findViewById<RecyclerView>(R.id.recycler_view)
                var list = ArrayList<CpTabInfo>()
                list.add(
                    CpTabInfo(
                        CpLanguageUtil.getString(context, "cp_overview_text53").toString(), 1
                    )
                )
                list.add(
                    CpTabInfo(
                        CpLanguageUtil.getString(context, "cp_overview_text54").toString(), 2
                    )
                )
                var adapter = CpPopAdapter(list, index)
                rView?.layoutManager = LinearLayoutManager(context)
                rView?.adapter = adapter
                rView?.setHasFixedSize(true)
                adapter.setOnItemClickListener { adapter, view, position ->
                    dialogItemClickListener?.clickItem(list[position].index, list[position].name)
                    cvcEasyPopup.dismiss()
                }

            }

            cvcEasyPopup?.showAtAnchorView(targetView, YGravity.BELOW, XGravity.ALIGN_RIGHT, 0, 10)

            cvcEasyPopup?.setOnDismissListener {
                dialogDismissClickListener?.clickItem()
            }
        }

        fun createRivalPricePop(
            context: Context?,
            mCpContractBuyOrSellHelper: CpContractBuyOrSellHelper,
            targetView: View,
            wView:View,
            dialogItemClickListener: CpNewDialogUtils.DialogOnSigningItemClickListener?,
            dialogDismissClickListener: CpNewDialogUtils.DialogOnDismissClickListener?
        ) {
            val cvcEasyPopup = EasyPopup.create().setContentView(context, R.layout.cp_item_new_pop)
                .setFocusAndOutsideEnable(true)
                .setBackgroundDimEnable(true)
                .setWidth(wView.width)
                .setAnimationStyle(R.style.cp_dialogAnim_otop)
                .setDimValue(0.5f)
                .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                .apply()
            cvcEasyPopup?.run {
                val rView = findViewById<RecyclerView>(R.id.recycler_view)
                var list = ArrayList<CpTabInfo>()
                list.add(
                    CpTabInfo(
                        CpLanguageUtil.getString(context, "cp_overview_text38").toString(), 0, 0
                    )
                )
                list.add(
                    CpTabInfo(
                        CpLanguageUtil.getString(context, "cp_overview_text39").toString(), 1, 4
                    )
                )
                list.add(
                    CpTabInfo(
                        CpLanguageUtil.getString(context, "cp_overview_text40").toString(), 2, 9
                    )
                )
                var adapter = CpPopAdapter(list, mCpContractBuyOrSellHelper.rivalPriceType)
                rView?.layoutManager = LinearLayoutManager(context)
                rView?.adapter = adapter
                rView?.setHasFixedSize(true)
                adapter.setOnItemClickListener { adapter, view, position ->
                    mCpContractBuyOrSellHelper.rivalPriceType = position
                    mCpContractBuyOrSellHelper.rivalPricePosition = list[position].extrasNum!!
                    dialogItemClickListener?.clickItem(position, list[position].name)
                    cvcEasyPopup.dismiss()
                }

            }

            cvcEasyPopup?.showAtAnchorView(targetView, YGravity.BELOW, XGravity.ALIGN_LEFT, 0, 10)

            cvcEasyPopup?.setOnDismissListener {
                dialogDismissClickListener?.clickItem()
            }
        }

        fun createSelectPositionPop(context: Context?, index: Int = 0, targetView: View) {
            val cvcEasyPopup =
                EasyPopup.create().setContentView(context, R.layout.cp_item_select_position)
                    .setFocusAndOutsideEnable(true)
                    .setBackgroundDimEnable(true)
                    .setWidth(ViewGroup.LayoutParams.MATCH_PARENT)
                    .setDimValue(0f)
                    .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                    .apply()
            var isShowPositionInfo = false
            cvcEasyPopup?.run {
                val ll_show_position_info = findViewById<LinearLayout>(R.id.ll_show_position_info)
                val tvPositionInfo = findViewById<TextView>(R.id.tv_position_info)
                tvPositionInfo.visibility = View.VISIBLE
                ll_show_position_info.setOnClickListener {
                    isShowPositionInfo = !isShowPositionInfo
                    tvPositionInfo.visibility = if (isShowPositionInfo) View.VISIBLE else View.GONE
                }
            }
            cvcEasyPopup?.showAtAnchorView(targetView, YGravity.BELOW, XGravity.CENTER, 0, 0)
        }


        /**
         *Toggle Lever Dialog Box
         */
        fun showSelectLeverDialog(
            context: Context,
            listener: OnCpBindViewListener
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_modify_lever_dialog)
                .setScreenWidthAspect(context, 1.0f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.5f)
                .setCancelableOutside(true)
                .setOnBindViewListener(listener)
                .setDialogAnimationRes(R.style.dialogBottomAnim)
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .setOnDismissListener {
                    if (KeyboardUtils.isSoftInputVisible(context)) {
                        KeyboardUtils.toggleSoftInput()
                    }
                }
                .create()
                .show()

        }

        /**
         *Lightning Closing Dialog Box
         */
        fun showQuickClosePositionDialog(
            context: Context,
            listener: OnCpBindViewListener,
            dismissListener:DialogInterface.OnDismissListener
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_quick_close_position_dialog)
                .setScreenWidthAspect(context, 1.0f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.5f)
                .setCancelableOutside(true)
                .setOnBindViewListener(listener)
                .setDialogAnimationRes(R.style.dialogBottomAnim)
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .setOnDismissListener(dismissListener)
                .create()
                .show()

        }

        /**
         *Closing Dialog Box
         */
        fun showClosePositionDialog(
            context: Context,
            listener: OnCpBindViewListener,
            dismissCallback:() -> Unit
        ): CpTDialog {
            val view = LayoutInflater.from(context)
                .inflate(R.layout.cp_item_close_position_new_dialog, null)
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setDialogView(view)
                .setScreenWidthAspect(context, 1.0f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.5f)
                .setCancelableOutside(true)
                .setOnBindViewListener(listener)
                .setDialogAnimationRes(R.style.dialogBottomAnim)
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .setOnDismissListener {
                    if (KeyboardUtils.isSoftInputVisible(context)) {
                        KeyboardUtils.toggleSoftInput()
                    }
                    dismissCallback.invoke()
                }
                .create()
                .show()

        }

        /**
         *Adjust Margin Dialog Box
         */
        fun showAdjustMarginDialog(
            context: Context,
            listener: OnCpBindViewListener
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_adjust_margin_dialog)
                .setScreenWidthAspect(context, 1.0f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.5f)
                .setCancelableOutside(true)
                .setOnBindViewListener(listener)
                .setDialogAnimationRes(R.style.dialogBottomAnim)
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .setOnDismissListener {
                    if (KeyboardUtils.isSoftInputVisible(context)) {
                        KeyboardUtils.toggleSoftInput()
                    }
                }
                .create()
                .show()

        }

        /**
         *Adjust Profit Loss Calculation Dialog Box
         */
        fun showAdjustRoiDialog(
            context: Context,
            listener: OnCpBindViewListener
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_adjust_roi_dialog)
                .setScreenWidthAspect(context, 1.0f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.5f)
                .setCancelableOutside(true)
                .setOnBindViewListener(listener)
                .setDialogAnimationRes(R.style.dialogBottomAnim)
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .setOnDismissListener {
                    if (KeyboardUtils.isSoftInputVisible(context)) {
                        KeyboardUtils.toggleSoftInput()
                    }
                }
                .create()
                .show()

        }

        /**
         *Show Fund Rate Dialog Box
         */
        fun showCapitalRateDialog(
            context: Context,
            listener: OnCpBindViewListener?,
            dismissListener: DialogInterface.OnDismissListener
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_capital_rate_dialog)
                .setScreenWidthAspect(context, 1.0f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(false)
                .setOnBindViewListener(listener)
                .addOnClickListener(R.id.tv_confirm_btn)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.tv_confirm_btn -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .setOnDismissListener(dismissListener)
                .create()
                .show()

        }

        /**
         *Show Tag Price Dialog
         */
        fun showIndexPriceDialog(
            context: Context,
            listener: OnCpBindViewListener?
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_index_price_dialog)
                .setScreenWidthAspect(context, 1.0f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(false)
                .setOnBindViewListener(listener)
                .addOnClickListener(R.id.tv_confirm_btn)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.tv_confirm_btn -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

        }

        /**
         *Opening the contract risk notification dialog box
         */
        fun showCreateContractDialog(
            context: Context,
            listener: CpNewDialogUtils.DialogBottomListener,
            dissmissCallback:(() -> Unit)? = null
        ): CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_open_contract_dialog)
                .setScreenWidthAspect(context, 1.0f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(false)
                .setOnBindViewListener {
                    it.setText(R.id.tv_title,CpLanguageUtil.getString(context,"cp_content_text18"))
                    it.setText(R.id.tv_vontract_info,CpLanguageUtil.getString(context,"cp_extra_text117").replace("\\n","\n").replace("\\r","\r"))
                    it.setText(R.id.tv_confirm_btn,CpLanguageUtil.getString(context,"cp_overview_text66"))
                    it.setText(R.id.tv_close,CpLanguageUtil.getString(context,"cp_overview_text44"))
                }
                .addOnClickListener(R.id.tv_confirm_btn, R.id.tv_close)
                .setOnViewClickListener { _, view, tDialog ->
                    when (view.id) {
                        R.id.tv_confirm_btn -> {
                            tDialog.dismiss()
                            listener.sendConfirm()
                        }
                        R.id.tv_close -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .setOnDismissListener {
                    dissmissCallback?.invoke()
                }
                .create()
                .show()

        }

        //Prompt box for order confirmation
        fun showCreateOrderDialog(
            context: Context,
            titleColor: Int,
            dialogTitle: String,
            contractName: String,
            price: String,
            triggerPrice: String,
            costPrice: String,
            amountValue: String,
            orderType: Int,
            profitTriggerPrice: String,
            lossTriggerPrice: String,
            quote: String,
            showTag: String,
            listener: CpNewDialogUtils.DialogBottomListener?,
            isOpen:Boolean,
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_create_order_dialog)
                .setScreenWidthAspect(context, 0.85f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(false)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    viewHolder?.setText(R.id.tv_cp_overview_text31, CpLanguageUtil.getString(context,"cp_overview_text31") )
                    viewHolder?.setText(R.id.tv_cancel_btn, CpLanguageUtil.getString(context,"cp_overview_text56") )
                    viewHolder?.setText(R.id.tv_confirm_btn, CpLanguageUtil.getString(context,"cp_calculator_text29") )
                    viewHolder?.setText(R.id.tv_cp_overview_text6, CpLanguageUtil.getString(context,"cp_overview_text6") )
                    viewHolder?.setText(R.id.tv_trigger_price_label, CpLanguageUtil.getString(context,"cp_overview_text29") )
                    viewHolder?.setText(R.id.tv_commission_price_label, CpLanguageUtil.getString(context,"cp_overview_text30") )
                    if (
                        (isOpen&&orderType==2) ||
                        (orderType==3 && price.equals(CpLanguageUtil.getString(context, "cp_overview_text53")))
                    ) {
                        viewHolder?.setText(R.id.tv_number_label, CpLanguageUtil.getString(context,"cp_extra_text9") )
                    }else{
                        viewHolder?.setText(R.id.tv_number_label, CpLanguageUtil.getString(context,"cp_overview_text8") )
                    }
                    viewHolder?.setText(R.id.tv_cost_label, CpLanguageUtil.getString(context,"cp_overview_text11") )
                    viewHolder?.setText(R.id.tv_cp_overview_text15, CpLanguageUtil.getString(context,"cp_overview_text15") )
                    viewHolder?.setText(R.id.tv_cp_overview_text16, CpLanguageUtil.getString(context,"cp_overview_text16") )


                    viewHolder?.setTextColor(R.id.tv_title, titleColor)
                    viewHolder?.setText(R.id.tv_title, dialogTitle)
                    viewHolder?.setText(R.id.tv_contract_name, contractName)
                    //Price
                    viewHolder?.setText(R.id.tv_price_value, price)
                    //Commission price
                    viewHolder?.setText(R.id.tv_commission_price_value, price)
                    //Trigger Price
                    viewHolder?.setText(R.id.tv_trigger_price_value, triggerPrice)
                    //Cost
                    viewHolder?.setText(R.id.tv_cost_value, costPrice)
                    //Quantity
                    viewHolder?.setText(R.id.tv_number_value, amountValue)
                    //Stop Profit Trigger Price
                    viewHolder?.setText(
                        R.id.tv_stop_profit_entrust_price_value,
                        profitTriggerPrice + " " + quote
                    )
                    //Stop Loss Trigger Price
                    viewHolder?.setText(
                        R.id.tv_stop_loss_trigger_price_value,
                        lossTriggerPrice + " " + quote
                    )

                    viewHolder?.setVisibility(
                        R.id.ll_stop_profit,
                        if (TextUtils.isEmpty(profitTriggerPrice)) View.GONE else View.VISIBLE
                    )
                    viewHolder?.setVisibility(
                        R.id.ll_stop_loss,
                        if (TextUtils.isEmpty(lossTriggerPrice)) View.GONE else View.VISIBLE
                    )
                    viewHolder?.setText(R.id.tv_open_type, showTag)

                    when (orderType) {
                        1, 2, 4, 5, 6 -> {
                            viewHolder?.setVisibility(R.id.ll_price, View.VISIBLE)
                            viewHolder?.setVisibility(R.id.ll_cost, View.VISIBLE)

                            viewHolder?.setVisibility(R.id.ll_trigger_price, View.GONE)
                            viewHolder?.setVisibility(R.id.ll_commission_price, View.GONE)
                        }
                        else -> {
                            viewHolder?.setVisibility(R.id.ll_price, View.GONE)
                            viewHolder?.setVisibility(R.id.ll_cost, View.GONE)
                            viewHolder?.setText(
                                R.id.tv_title,
                                CpLanguageUtil.getString(
                                    context,
                                    "cp_overview_text55"
                                ) + dialogTitle
                            )
                            viewHolder?.setVisibility(R.id.ll_trigger_price, View.VISIBLE)
                            viewHolder?.setVisibility(R.id.ll_commission_price, View.VISIBLE)
                        }
                    }


                    viewHolder?.setVisibility(R.id.ll_cost, View.GONE)
                }
                .addOnClickListener(R.id.tv_cancel_btn, R.id.tv_confirm_btn, R.id.ll_not_again)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.ll_not_again -> {
                            val cbNotAgain = viewHolder.getView<CheckBox>(R.id.cb_not_again)
                            cbNotAgain.isChecked = !cbNotAgain.isChecked
                        }
                        R.id.tv_cancel_btn -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_confirm_btn -> {
                            val cbNotAgain = viewHolder.getView<CheckBox>(R.id.cb_not_again)
                            CpPreferenceManager.getInstance(CpMyApp.instance()).putSharedBoolean(
                                CpPreferenceManager.PREF_TRADE_CONFIRM, !cbNotAgain.isChecked
                            )
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

        //Closing confirmation box
        fun showCloseOrderDialog(
            context: Context,
            titleColor: Int,
            dialogTitle: String,
            contractName: String,
            price: String,
            triggerPrice: String,
            costPrice: String,
            amountValue: String,
            orderType: Int,
            profitTriggerPrice: String,
            lossTriggerPrice: String,
            showTag: String,
            listener: CpNewDialogUtils.DialogBottomListener?
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_close_order_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.5f)
                .setCancelableOutside(false)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.run {
                        setTextColor(R.id.tv_title, titleColor)
                        setText(R.id.tv_title, dialogTitle)
                        setText(R.id.tv_contract_name, contractName)
                        //Price
                        setText(R.id.tv_price_value, price)
                        //Commission price
                        setText(R.id.tv_commission_price_value, price)
                        //Trigger Price
                        setText(R.id.tv_trigger_price_value, triggerPrice)
                        //Cost
                        setText(R.id.tv_cost_value, costPrice)
                        //Quantity
                        setText(R.id.tv_number_value, amountValue)
                        //Stop Profit Trigger Price
                        setText(R.id.tv_stop_profit_entrust_price_value, profitTriggerPrice)
                        //Stop Loss Trigger Price
                        setText(R.id.tv_stop_loss_trigger_price_value, lossTriggerPrice)

                        setText(R.id.tv_price, CpLanguageUtil.getString(context,"cp_order_text42"))
                        setText(R.id.tv_number_label, CpLanguageUtil.getString(context,"cp_order_text43"))
                        setText(R.id.tv_cancel_btn,CpLanguageUtil.getString(context,"cp_overview_text56"))
                        setText(R.id.tv_confirm_btn,CpLanguageUtil.getString(context,"cp_calculator_text29"))
                        setText(R.id.tv_tip,CpLanguageUtil.getString(context,"cp_overview_text31"))
                        setText(R.id.tv_open_type, showTag)

                        setVisibility(R.id.ll_stop_profit, if (TextUtils.isEmpty(profitTriggerPrice)) View.GONE else View.VISIBLE)
                        setVisibility(R.id.ll_stop_loss, if (TextUtils.isEmpty(lossTriggerPrice)) View.GONE else View.VISIBLE)

                    }

                }
                .addOnClickListener(R.id.tv_cancel_btn, R.id.tv_confirm_btn, R.id.ll_not_again)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.ll_not_again -> {
                            val cbNotAgain = viewHolder.getView<CheckBox>(R.id.cb_not_again)
                            cbNotAgain.isChecked = !cbNotAgain.isChecked
                        }
                        R.id.tv_cancel_btn -> {
                            tDialog.dismiss()
                        }
                        R.id.tv_confirm_btn -> {
                            val cbNotAgain = viewHolder.getView<CheckBox>(R.id.cb_not_again)
                            CpPreferenceManager.getInstance(CpMyApp.instance()).putSharedBoolean(
                                CpPreferenceManager.PREF_TRADE_CONFIRM, !cbNotAgain.isChecked
                            )
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


        fun createSelectCoinsPop(
            context: Context?,
            mContractId: Int = 0,
            targetView: View,
            dialogItemClickListener: CpNewDialogUtils.DialogOnSigningItemClickListener?
        ) {
            val cvcEasyPopup =
                EasyPopup.create().setContentView(context, R.layout.cp_item_select_coins)
                    .setFocusAndOutsideEnable(true)
                    .setBackgroundDimEnable(true)
                    .setWidth(ViewGroup.LayoutParams.MATCH_PARENT)
                    .setDimValue(0f)
                    .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                    .apply()
            cvcEasyPopup?.run {
                val rLeftView = findViewById<RecyclerView>(R.id.rv_left)
                val rRightView = findViewById<RecyclerView>(R.id.rv_right)
                var sideList = ArrayList<CpTabInfo>()
                var sideListBuff = ArrayList<CpTabInfo>()
                var sideListU = ArrayList<CpTabInfo>()
                var sideListB = ArrayList<CpTabInfo>()
                var sideListH = ArrayList<CpTabInfo>()
                var sideListM = ArrayList<CpTabInfo>()

                var isHasU = false //Forward contract
                var isHasB = false //Currency standard
                var isHasH = false //Mixed contract
                var isHasM = false //Simulated contract
                val mContractList =
                    JSONArray(CpClLogicContractSetting.getContractJsonListStr(context))
                var positionLeft = 0
                for (i in 0..(mContractList.length() - 1)) {
                    val obj = mContractList.getJSONObject(i)
                    val contractSide = obj.getInt("contractSide")
                    val contractType = obj.getString("contractType")
                    val id = obj.getInt("id")
                    if (contractSide == 1 && contractType == "E") {
                        isHasU = true
                        sideListU.add(CpTabInfo(obj.getString("symbol"), obj.getInt("id")))
                    } else if (contractSide == 0 && contractType == "E") {
                        isHasB = true
                        sideListB.add(CpTabInfo(obj.getString("symbol"), obj.getInt("id")))
                    } else if (contractType == "S") {
                        isHasM = true
                        sideListM.add(CpTabInfo(obj.getString("symbol"), obj.getInt("id")))
                    } else {
                        isHasH = true
                        sideListH.add(CpTabInfo(obj.getString("symbol"), obj.getInt("id")))
                    }
                    if (mContractId == id) {
                        positionLeft = if (contractSide == 1 && contractType == "E") {
                            0
                        } else if (contractSide == 0 && contractType == "E") {
                            1
                        } else if (contractType == "S") {
                            3
                        } else {
                            2
                        }
                    }
                }
                if (isHasU) {
                    sideList.add(
                        CpTabInfo(
                            CpLanguageUtil.getString(
                                context,
                                "cp_contract_data_text13"
                            ).toString(), 0
                        )
                    )
                }
                if (isHasB) {
                    sideList.add(
                        CpTabInfo(
                            CpLanguageUtil.getString(
                                context,
                                "cp_contract_data_text10"
                            ).toString(), 1
                        )
                    )
                }
                if (isHasH) {
                    sideList.add(
                        CpTabInfo(
                            CpLanguageUtil.getString(
                                context,
                                "cp_contract_data_text12"
                            ).toString(), 2
                        )
                    )
                }
                if (isHasM) {
                    sideList.add(
                        CpTabInfo(
                            CpLanguageUtil.getString(
                                context,
                                "cp_contract_data_text11"
                            ).toString(), 3
                        )
                    )
                }
                if (positionLeft == 0) {
                    sideListBuff.addAll(sideListU)
                } else if (positionLeft == 1) {
                    sideListBuff.addAll(sideListB)
                } else if (positionLeft == 3) {
                    sideListBuff.addAll(sideListM)
                } else {
                    sideListBuff.addAll(sideListH)
                }
                var mRightAdapter = CpCoinSelectRightAdapter(sideListBuff, mContractId)
                rRightView?.layoutManager = LinearLayoutManager(context)
                rRightView?.adapter = mRightAdapter
                rRightView?.setHasFixedSize(true)
                mRightAdapter.setOnItemClickListener { adapter, view, position ->
                    dialogItemClickListener?.clickItem(
                        sideListBuff[position].index,
                        sideListBuff[position].name
                    )
                    dismiss()
                }
                var adapter = CpCoinSelectLeftAdapter(sideList, positionLeft)
                rLeftView?.layoutManager = LinearLayoutManager(context)
                rLeftView?.adapter = adapter
                rLeftView?.setHasFixedSize(true)
                adapter.setOnItemClickListener { adapter, view, position ->
                    sideListBuff.clear()
                    if (sideList[position].index == 0) {
                        sideListBuff.addAll(sideListU)
                    } else if (sideList[position].index == 1) {
                        sideListBuff.addAll(sideListB)
                    } else if (sideList[position].index == 2) {
                        sideListBuff.addAll(sideListH)
                    } else {
                        sideListBuff.addAll(sideListM)
                    }
                    mRightAdapter.notifyDataSetChanged()
                }
            }
            cvcEasyPopup?.showAtAnchorView(targetView, YGravity.BELOW, XGravity.CENTER, 0, 0)
        }


        fun createCommonTopPop(
            context: Context?,
            list: ArrayList<CpTabInfo>,
            position: Int,
            targetView: View,
            dialogItemClickListener: CpNewDialogUtils.DialogOnSigningItemClickListener?,
            dialogDismissClickListener: CpNewDialogUtils.DialogOnDismissClickListener?
        ) {
            val cvcEasyPopup =
                EasyPopup.create().setContentView(context, R.layout.cp_item_select_list)
                    .setFocusAndOutsideEnable(true)
                    .setBackgroundDimEnable(true)
                    .setWidth(ViewGroup.LayoutParams.MATCH_PARENT)
                    .setDimValue(0f)
                    .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                    .apply()
            cvcEasyPopup?.run {
                val rView = findViewById<RecyclerView>(R.id.recycler_view)
                val llDissmiss = findViewById<LinearLayout>(R.id.ll_dissmiss)
                var adapter = CpTopPopAdapter(list, position)
                rView?.layoutManager = LinearLayoutManager(context)
                rView?.adapter = adapter
                rView?.setHasFixedSize(true)
                adapter.setOnItemClickListener { adapter, view, position ->
                    dialogItemClickListener?.clickItem(position, list[position].name)
                    cvcEasyPopup.dismiss()
                }
                llDissmiss.setOnClickListener { dismiss() }

            }

            cvcEasyPopup?.showAtAnchorView(targetView, YGravity.BELOW, XGravity.ALIGN_RIGHT, 0, 0)

            cvcEasyPopup?.setOnDismissListener {
                dialogDismissClickListener?.clickItem()
            }
        }

        fun createMoreTimeKlinePop(
            context: Context?,
            targetView: View,
            dialogDismissClickListener: CpNewDialogUtils.DialogOnSigningItemClickListener?,
            mDialogDismissClickListener: CpNewDialogUtils.DialogOnDismissClickListener?
        ) {
            val cvcEasyPopup =
                EasyPopup.create().setContentView(context, R.layout.cp_item_kline_time_more)
                    .setFocusAndOutsideEnable(true)
                    .setBackgroundDimEnable(true)
                    .setWidth(ViewGroup.LayoutParams.MATCH_PARENT)
                    .setDimValue(0f)
                    .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                    .apply()
            cvcEasyPopup?.run {
                val rvKlineCtrlMore = findViewById<RecyclerView>(R.id.rv_kline_ctrl_more)
                val llDissmiss = findViewById<LinearLayout>(R.id.ll_dissmiss)
                var list = ArrayList<CpTabInfo>()
                list.add(CpTabInfo("line", CpKLineUtil.getKLineScale().indexOf("line")))
                list.add(CpTabInfo("1min", CpKLineUtil.getKLineScale().indexOf("1min")))
                list.add(CpTabInfo("5min", CpKLineUtil.getKLineScale().indexOf("5min")))
                list.add(CpTabInfo("30min", CpKLineUtil.getKLineScale().indexOf("30min")))
                list.add(CpTabInfo("1week", CpKLineUtil.getKLineScale().indexOf("1week")))
                list.add(CpTabInfo("1month", CpKLineUtil.getKLineScale().indexOf("1month")))
                var adapter = CpKlineMorePopAdapter(list, 0)
                rvKlineCtrlMore?.layoutManager = GridLayoutManager(context, 6)
                rvKlineCtrlMore?.adapter = adapter
                rvKlineCtrlMore?.setHasFixedSize(true)
                adapter.setOnItemClickListener { adapter, view, position ->
                    CpKLineUtil.setCurTime(list[position].name)
                    CpKLineUtil.setCurTime4KLine(list[position].index)
                    dialogDismissClickListener?.clickItem(position, list[position].name)
                    cvcEasyPopup.dismiss()
                }
                llDissmiss.setOnClickListener { dismiss() }
            }
            cvcEasyPopup?.setOnDismissListener {
                mDialogDismissClickListener?.clickItem()
            }
            cvcEasyPopup?.showAtAnchorView(targetView, YGravity.BELOW, XGravity.ALIGN_RIGHT, 0, 0)
        }

        fun createMoreTargetKlinePop(
            context: Context?,
            targetView: View,
            dialogDismissClickListener: CpNewDialogUtils.DialogOnSigningItemClickListener?,
            mDialogDismissClickListener: CpNewDialogUtils.DialogOnDismissClickListener?
        ) {
            var isShowPositionDesc = false
            val cvcEasyPopup =
                EasyPopup.create().setContentView(context, R.layout.cp_item_kline_target_more)
                    .setFocusAndOutsideEnable(true)
                    .setBackgroundDimEnable(true)
                    .setWidth(ViewGroup.LayoutParams.MATCH_PARENT)
                    .setDimValue(0f)
                    .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                    .apply()
            cvcEasyPopup?.run {
                findViewById<TextView>(R.id.tv_cp_extra_text156).text = CpLanguageUtil.getString(
                    context,
                    "cp_extra_text156"
                )
                findViewById<TextView>(R.id.tv_cp_extra_text155).text = CpLanguageUtil.getString(
                    context,
                    "cp_extra_text155"
                )
                findViewById<TextView>(R.id.tv_orderDisplayTitle).text = CpLanguageUtil.getString(context,"cp_contract_order_display")
                findViewById<TextView>(R.id.tv_set_title).text = CpLanguageUtil.getString(context,"cp_contract_kline_set_title")

                val rvKlineCtrlMain = findViewById<RecyclerView>(R.id.rv_kline_ctrl_main)
                val rvKlineCtrlVice = findViewById<RecyclerView>(R.id.rv_kline_ctrl_vice)
                val llDissmiss = findViewById<LinearLayout>(R.id.ll_dissmiss)
                var listMain = ArrayList<CpTabInfo>()
                listMain.add(CpTabInfo("MA", 0, 0))
                listMain.add(CpTabInfo("BOLL", 1, 4))

                var listVice = ArrayList<CpTabInfo>()
                listVice.add(CpTabInfo("MACD", 0, 4))
                listVice.add(CpTabInfo("KDJ", 1, 9))
                listVice.add(CpTabInfo("RSI", 2, 9))
                listVice.add(CpTabInfo("WR", 3, 9))

                var adapterMain = CpKlineMoreMainTargetAdapter(listMain)
                rvKlineCtrlMain?.layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL,false)
                rvKlineCtrlMain?.adapter = adapterMain
                rvKlineCtrlMain?.setHasFixedSize(true)
                adapterMain.setOnItemClickListener { adapter, view, position ->
                    dialogDismissClickListener?.clickItem(position, "main")
                    adapter.notifyDataSetChanged()
                }

                var adapterVice = CpKlineMoreViceTargetAdapter(listVice)
                rvKlineCtrlVice?.layoutManager = LinearLayoutManager(context,LinearLayoutManager.HORIZONTAL,false)
                rvKlineCtrlVice?.adapter = adapterVice
                rvKlineCtrlVice?.setHasFixedSize(true)
                adapterVice.setOnItemClickListener { adapter, view, position ->
                    dialogDismissClickListener?.clickItem(position, "vice")
                    adapter.notifyDataSetChanged()
                }
                llDissmiss.setOnClickListener { dismiss() }

                val cbOrderHis = findViewById<LinearLayout>(R.id.ll_toggle_order_visible)
                val tvOrderText = findViewById<TextView>(R.id.tv_order_label)
                val ivOrderIcon = findViewById<ImageView>(R.id.iv_check)

                tvOrderText.text = CpLanguageUtil.getString(context,"cp_contract_order_history")
                ivOrderIcon.isSelected = CpClLogicContractSetting.getKlineOrder()
                cbOrderHis.setOnClickListener {
                    ivOrderIcon.isSelected = !ivOrderIcon.isSelected
                    dialogDismissClickListener?.clickItem(if (ivOrderIcon.isSelected) 1 else 0, "orderHis")
                }
            }
            cvcEasyPopup?.setOnDismissListener {
                mDialogDismissClickListener?.clickItem()
            }
            cvcEasyPopup?.showAtAnchorView(targetView, YGravity.BELOW, XGravity.ALIGN_RIGHT, 0, 0)
        }
    }

}
