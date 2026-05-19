package com.chainup.contract.view

import android.content.Context
import android.graphics.Bitmap
import android.os.Build
import android.text.Html
import android.text.SpannableString
import android.text.SpannableStringBuilder
import android.text.TextUtils
import android.text.method.LinkMovementMethod
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.view.animation.AnimationUtils
import android.view.inputmethod.EditorInfo
import android.widget.EditText
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.annotation.DrawableRes
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.widget.addTextChangedListener
import androidx.fragment.app.DialogFragment.STYLE_NORMAL
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager.widget.ViewPager
import com.blankj.utilcode.util.AppUtils
import com.bumptech.glide.Glide
import com.bumptech.glide.Priority
import com.bumptech.glide.load.resource.bitmap.CenterCrop
import com.bumptech.glide.load.resource.bitmap.RoundedCorners
import com.bumptech.glide.request.RequestOptions
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.listener.OnItemClickListener
import com.chainup.contract.R
import com.chainup.contract.adapter.ContractSettingRvAdapter
import com.chainup.contract.adapter.CpBottomDialogAdapter
import com.chainup.contract.adapter.CpNewDialogAdapter
import com.chainup.contract.adapter.CpPageAdapter
import com.chainup.contract.bean.ContractListBean
import com.chainup.contract.bean.CpTabInfo
import com.chainup.contract.ui.fragment.CpOrderTypeTipFragment
import com.chainup.contract.ui.fragment.DialogSymbolFragment
import com.chainup.contract.utils.CpBigDecimalUtils
import com.chainup.contract.utils.CpBitmapUtils
import com.chainup.contract.utils.CpClLogicContractSetting
import com.chainup.contract.utils.CpColorUtil
import com.chainup.contract.utils.CpMathHelper
import com.chainup.contract.utils.CpNumberUtil
import com.chainup.contract.utils.CpScreenShotUtil
import com.chainup.contract.utils.CpSizeUtils
import com.chainup.contract.utils.CpSoftKeyboardUtil
import com.chainup.contract.utils.CpSystemUtils
import com.chainup.contract.utils.CpZXingUtils
import com.chainup.contract.utils.toDinproMedium
import com.chainup.contract.view.dialog.CpTDialog
import com.chainup.contract.view.dialog.base.CpBindViewHolder
import com.chainup.contract.view.dialog.listener.OnCpBindViewListener
import com.chainup.contract.view.dialog.listener.OnCpViewClickListener
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.kit.utils.ToastUtils
import com.flyco.tablayout.SlidingTabLayout
import com.yjkj.chainup.manager.CpLanguageUtil
import com.yjkj.chainup.new_contract.bean.CpContractPositionBean
import com.zyyoona7.popup.EasyPopup
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import java.util.concurrent.TimeUnit

/**
 * @Author lianshangljl
 * @Date 2019/3/8-11:59 AM
 * @Email buptjinlong@163.com
 * @description
 */
class CpNewDialogUtils {

    interface DialogOnclickListener {
        fun clickItem(data: ArrayList<String>, item: Int)
    }
    interface DialogOnclickListenerTx {
        fun clickItem(data: ArrayList<Map<String,Any>>, item: Int)
    }
    interface DialogOnItemClickListener {
        fun clickItem(position: Int)
    }
    interface DialogShareClickListener {
        fun clickItem(bitmap: Bitmap)
    }
    interface DialogBottomListener {
        fun sendConfirm()
        fun dismiss(){}
    }
    interface DialogOnSigningItemClickListener {
        fun clickItem(position: Int, text: String)
        fun doContractSymbolSelect(bean:ContractListBean){}
        fun dismiss(){}
    }
    interface DialogOnDismissClickListener {
        fun clickItem()
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
                .setLayoutRes(R.layout.cp_item_new_dialog)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setText(
                        R.id.tv_cancel,
                        CpLanguageUtil.getString(context, "cp_overview_text56")
                    )
                    var adapter = CpNewDialogAdapter(list, position)
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
                .setLayoutRes(R.layout.cp_item_new_dialog)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(0.8f)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    viewHolder?.setText(
                        R.id.tv_cancel,
                        CpLanguageUtil.getString(context, "cp_overview_text56")
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
            returnListener: Boolean = false, isBackCancel: Boolean = false
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_normal_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(false)
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
                                CpLanguageUtil.getString(context, "cp_calculator_text16")
                            )
                        }

                    } else {
                        viewHolder?.setText(
                            R.id.tv_cancel,
                            CpLanguageUtil.getString(context, "cp_overview_text56")
                        )
                        if (confrimTitle.isNotEmpty()) {
                            viewHolder?.setText(R.id.tv_cancel, confrimTitle)
                        }
                        if (!TextUtils.isEmpty(cancelTitle)) {
                            viewHolder?.setText(R.id.tv_confirm_btn, cancelTitle)
                        } else {
                            viewHolder?.setText(
                                R.id.tv_confirm_btn,
                                CpLanguageUtil.getString(context, "cp_calculator_text16")
                            )
                        }
                    }
                    viewHolder?.setText(R.id.tv_content, Html.fromHtml(content))

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
        fun showDialogNew(context: Context,
                          content: CharSequence,
                          isSingle: Boolean,
                          listener: DialogBottomListener?,
                          title: String = "",
                          cancelTitle: String = "",
                          confrimTitle: String = "",
                          returnListener: Boolean = false,
                          isBackCancel: Boolean = false,
                          contentGravity:Int? = Gravity.LEFT
        ):CpTDialog {
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_normal_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(false)
                .setOnKeyListener { p0, p1, p2 -> isBackCancel }
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    viewHolder?.run{
                        if (!TextUtils.isEmpty(title)) {
                            setGone(R.id.tv_title, true)
                            setText(R.id.tv_title, title)
                        }else{
                            setGone(R.id.tv_title, false)
                        }

                        if (isSingle) {
                            setGone(R.id.tv_cancel, false)
                            setText(R.id.tv_confirm_btn,
                                if(!TextUtils.isEmpty(cancelTitle)){
                                    cancelTitle
                                }else if(!TextUtils.isEmpty(confrimTitle)){
                                    confrimTitle
                                }else{
                                    CpLanguageUtil.getString(context, "cp_calculator_text16")
                                }
                            )

                        } else {
                            setText(R.id.tv_cancel, if (cancelTitle.isNotEmpty()) cancelTitle else CpLanguageUtil.getString(context, "cp_overview_text56"))
                            setText(R.id.tv_confirm_btn,if (!TextUtils.isEmpty(confrimTitle)) confrimTitle else CpLanguageUtil.getString(context, "cp_calculator_text16"))
                        }
                        when (content) {
                            is SpannableString,is SpannableStringBuilder -> {
                                setText(R.id.tv_content, content)
                            }

                            is String -> {
                                setText(R.id.tv_content, Html.fromHtml(content.toString()))
                            }

                            else -> {
                                setText(R.id.tv_content, content.toString())
                            }
                        }

                        getView<TextView>(R.id.tv_content).movementMethod = LinkMovementMethod.getInstance()
                        val tvContent = getView<TextView>(R.id.tv_content)
                        tvContent.gravity = contentGravity!!
                    }


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

        fun showDialogNewWithIcon(context: Context,
                          content: String,
                          isSingle: Boolean,
                          listener: DialogBottomListener?,
                          title: String = "",
                          cancelTitle: String = "",
                          confrimTitle: String = "",
                          returnListener: Boolean = false,
                          isBackCancel: Boolean = false,
                          contentGravity:Int? = Gravity.LEFT,
                          @DrawableRes icon:Int
        ) {
            CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_item_normal_dialog)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(0.8f)
                .setCancelableOutside(false)
                .setOnKeyListener { p0, p1, p2 -> isBackCancel }
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->

                    viewHolder?.run{
                        setGone(R.id.iv_icon_tip,true)
                        setImageDrawable(R.id.iv_icon_tip,context.resources.getDrawable(icon))
                        if (!TextUtils.isEmpty(title)) {
                            setGone(R.id.tv_title, true)
                            setText(R.id.tv_title, title)
                        }else{
                            setGone(R.id.tv_title, false)
                        }

                        if (isSingle) {
                            setGone(R.id.tv_cancel, false)
                            if (!TextUtils.isEmpty(cancelTitle)) {
                                setText(R.id.tv_confirm_btn, cancelTitle)
                            } else {
                                setText(R.id.tv_confirm_btn, CpLanguageUtil.getString(context, "cp_calculator_text16"))
                            }

                        } else {
                            setText(R.id.tv_cancel, CpLanguageUtil.getString(context, "cp_overview_text56"))
                            if (confrimTitle.isNotEmpty()) {
                                setText(R.id.tv_confirm_btn, confrimTitle)
                            }
                            if (!TextUtils.isEmpty(cancelTitle)) {
                                setText(R.id.tv_cancel, cancelTitle)
                            } else {
                                setText(R.id.tv_confirm_btn, CpLanguageUtil.getString(context, "cp_calculator_text16"))
                            }
                        }
                        setText(R.id.tv_content, Html.fromHtml(content))
                        val tvContent = getView<TextView>(R.id.tv_content)
                        tvContent.gravity = contentGravity!!
                    }


                }
                .addOnClickListener(R.id.tv_cancel, R.id.tv_confirm_btn)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel -> {
                            listener?.dismiss()
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

        /**
         *Share Popup
         */
        fun showShareDialog(
            context: Context,
            mContractPositionBean: CpContractPositionBean,
            isBackCancel: Boolean = false
        ): CpTDialog {
            var profitRate = CpNumberUtil().getDecimal(2).format(
                CpMathHelper.round(
                    CpMathHelper.mul(mContractPositionBean?.returnRate, "100"),
                    2
                )
            ).toString()
            val isProfit = CpBigDecimalUtils.compareTo(profitRate, "0") != -1
            val symbol = if (isProfit) "+" else ""
            val profitRateBuff = symbol + profitRate
            return CpTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.cp_hold_share_card)
                .setGravity(Gravity.CENTER)
                .setWidth(CpSizeUtils.dp2px(312.0f))
                .setHeight(CpSizeUtils.dp2px(357.0f))
                .setDimAmount(0.5f)
                .setCancelableOutside(false)
                .setOnKeyListener { p0, p1, p2 -> isBackCancel }
                .setOnBindViewListener { viewHolder: CpBindViewHolder? ->
                    //Set Background Image
                    if(isProfit){
                        viewHolder?.setImageDrawable(R.id.iv_isLossBg,ContextCompat.getDrawable(context,R.mipmap.cp_profit))
                    }else{
                        viewHolder?.setImageDrawable(R.id.iv_isLossBg,ContextCompat.getDrawable(context,R.mipmap.cp_loss))
                    }

                    viewHolder?.setText(
                        R.id.tv_intro,
                        CpClLogicContractSetting.getShareInfo(context, profitRate)
                    )

//                    viewHolder?.setImageResource(R.id.iv_share_header, CpClLogicContractSetting.getShareBg( profitRate))

                    var imgUrl = CpClLogicContractSetting.getInviteUrl()
                    if (TextUtils.isEmpty(imgUrl)) {
                        imgUrl = "error!"
                    }
                    val bmp: Bitmap? = CpBitmapUtils.generateBitmap(imgUrl, 500, 500)
                    viewHolder?.setImageBitmap(R.id.iv_qr_code,bmp)
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
//                    viewHolder?.setImageResource(R.id.iv_app_icon, AppUtils.getAppIconId())
//                    viewHolder?.setText(R.id.tv_share_time, CpV2DateUtil.getCurrentDate(CpV2DateUtil.dateFormatMDHMS))
//                    viewHolder?.setText(R.id.tv_app_name, AppUtils.getAppName())
                    viewHolder?.setText(R.id.tv_earned, profitRateBuff + "%")

                    viewHolder?.setText(R.id.tv_down_app, AppUtils.getAppName())

                    //Currency pair name
                    viewHolder?.setText(
                        R.id.tv_contract_value,
                        CpClLogicContractSetting.getContractShowNameById(
                            context,
                            mContractPositionBean?.contractId!!
                        )
                    )

                    //The text above the yield
                    viewHolder?.setText(R.id.sl_str_profit_rate_label, CpLanguageUtil.getString(context,"cp_stoporder_text3"))

                    viewHolder?.setText(R.id.tv_latest_price, CpLanguageUtil.getString(context,"cp_order_text31"))
                    viewHolder?.setText(R.id.tv_open_price_label, CpLanguageUtil.getString(context,"cp_order_text30"))


//                    viewHolder?.setText(R.id.tv_cancel_btn, CpLanguageUtil.getString(context,"cp_overview_text56"))
//                    viewHolder?.setText(R.id.bt_share, CpLanguageUtil.getString(context,"cp_content_text34"))


                    //Yield
                    CpColorUtil.getMainColorType(CpBigDecimalUtils.compareTo(profitRateBuff,"0")==1)

                    viewHolder?.setTextColor(R.id.tv_earned, CpColorUtil.getMainColorType(CpBigDecimalUtils.compareTo(profitRate, "0") != -1))


//                    var nav_up :Drawable?=null
                    if (mContractPositionBean?.orderSide.equals("BUY")) { //Multi warehouse
                        viewHolder?.setText(R.id.tv_type, CpLanguageUtil.getString(context,"cp_content_text32"))
                        viewHolder?.setTextColor(R.id.tv_type, CpColorUtil.getMainColorType(true))
//                        viewHolder?.setBackgroundRes(R.id.tv_type, R.drawable.cp_border_green_fill)
//                        nav_up= context.getResources().getDrawable(R.drawable.contract_domorethan);

                    } else if (mContractPositionBean?.orderSide.equals("SELL")) { //Short positions
                        viewHolder?.setText(R.id.tv_type, CpLanguageUtil.getString(context,"cp_content_text33"))
//                        viewHolder?.setBackgroundRes(R.id.tv_type, R.drawable.cp_border_red_fill)
                        viewHolder?.setTextColor(R.id.tv_type, CpColorUtil.getMainColorType(false))
//                        nav_up= context.getResources().getDrawable(R.drawable.contract_short);
                    }


//                    nav_up?.setBounds(3, 0, nav_up.getMinimumWidth(), nav_up.getMinimumHeight());
//                    viewHolder?.getView<TextView>(R.id.tv_type)?.setCompoundDrawables(null, null, nav_up, null);
                    viewHolder?.setText(
                        R.id.tv_open_price_value,
                        CpBigDecimalUtils.showSNormal(
                            mContractPositionBean?.openAvgPrice,
                            CpClLogicContractSetting.getContractSymbolPricePrecisionById(
                                context,
                                mContractPositionBean?.contractId!!
                            )
                        )
                    )
                    viewHolder?.setText(
                        R.id.tv_latest_price_value,
                        CpBigDecimalUtils.showSNormal(
                            mContractPositionBean?.indexPrice,
                            CpClLogicContractSetting.getContractSymbolPricePrecisionById(
                                context,
                                mContractPositionBean?.contractId!!
                            )
                        )
                    )

                    //Lever
                    val sbPositionMode = StringBuilder()
                    when(mContractPositionBean?.positionType){
                        //Full warehouse
                        1 -> {
                            sbPositionMode.append("| ${CpLanguageUtil.getString(context,"cp_contract_setting_text1")}")
                        }
                        //Warehouse by warehouse
                        2 -> {
                            sbPositionMode.append("| ${CpLanguageUtil.getString(context,"cp_contract_setting_text2")}")
                        }
                    }

                    if(mContractPositionBean?.leverageLevel==null){
                        sbPositionMode.append("--")
                    }else{
                        sbPositionMode.append("${mContractPositionBean.leverageLevel}X")
                    }
                    viewHolder?.setText(
                        R.id.label_lever,
                        sbPositionMode.toString()
                    )

                    //Share
                    val llShareLayout = viewHolder?.getView<RelativeLayout>(R.id.ll_share_layout)

                    Observable.timer(300,TimeUnit.MILLISECONDS)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe{

                            val bitmp = CpScreenShotUtil.getScreenshotBitmap(llShareLayout)
                            CpZXingUtils.shareImageToWechat(bitmp, CpLanguageUtil.getString(context, "cp_extra_text116"),context)
                        }

                }
//                .addOnClickListener(R.id.img_close, R.id.bt_share, R.id.tv_cancel_btn)
//                .setOnViewClickListener { viewHolder, view, tDialog ->
//                    when (view.id) {
//                        R.id.img_close,  R.id.tv_cancel_btn -> {
//                            tDialog.dismiss()
//                        }
//                        R.id.bt_share -> {
//ChainUpLogUtil. e (TAG, "Click to Share")
//                            val llShareLayout =
//                                viewHolder?.getView<LinearLayout>(R.id.ll_share_layout)
//                            llShareLayout?.isDrawingCacheEnabled = true
//                            llShareLayout?.buildDrawingCache()
//                            val bitmap: Bitmap = Bitmap.createBitmap(llShareLayout?.drawingCache!!)
//                            listener?.clickItem(bitmap)
//                        }
//                    }
//                }
                .create()
                .show()

        }


        /**
         *Display a dialog of two buttons
         */

        fun showNormalDialog(
            context: Context,
            content: String,
            listener: DialogBottomListener,
            title: String = "",
            cancelTitle: String = "",
            confirmTitle: String = ""
        ) {
            showDialog(context, content, false, listener, title, cancelTitle, confirmTitle)
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
         *This function is added to the contract function
         */
        fun showNewBottomListDialog(
            context: Context,
            list: ArrayList<CpTabInfo>,
            position: Int,
            listener: DialogOnItemClickListener
        ): CpTDialog {
            return showNewListDialog(context, list, position, listener)
        }

        fun isEnable(editText: EditText?): Boolean {
            val string = editText?.text.toString()
            return !(TextUtils.isEmpty(string) || string.toDouble() == 0.0)
        }


        /**
         *@param context Context
         *@param data data source
         *@param contractId Current contract ID
         *@param listener DialogOnclickListener Click the interface callback
         *New Version Contract Settings Popup
         * */
        fun createContractSettingDialog(context: Context,contractId:Int,data:ArrayList<Map<String,Any>>,listener:DialogOnclickListenerTx?=null) : CpTDialog{
            val activity = (context as AppCompatActivity)
            return CpTDialog.Builder(activity.supportFragmentManager)
                .setLayoutRes(R.layout.dialog_contract_setting_layout)
                .setScreenWidthAspect(context,1.0f)
                .setDialogAnimationRes(R.style.contract_setting_dialog_ani)
                .setGravity(Gravity.TOP)
                .setDimAmount(0.5f)
                .setOnBindViewListener {
                    //Obtain the currently selected contract currency pair name
                    val symbolName = CpClLogicContractSetting.getContractShowNameById(context,contractId)
                    //Get whether to collect
                    val isCollect = CpClLogicContractSetting.hasCollect(context,contractId)

                    if(isCollect){
                        it.setImageDrawable(R.id.ic_optional,ContextCompat.getDrawable(context,R.drawable.ic_public_favorites))
                        it.setText(R.id.tv_optional,CpLanguageUtil.getString(context,"cp_contract_delete_optional_symbol").format(symbolName))
                    }else{
                        it.setImageDrawable(R.id.ic_optional,ContextCompat.getDrawable(context,R.mipmap.public_notfavorited))
                        it.setText(R.id.tv_optional,CpLanguageUtil.getString(context,"cp_contract_add_optional_symbol").format(symbolName))
                    }
                    it.setText(R.id.ct_title,CpLanguageUtil.getString(context,"cp_contract_setting_title"))

                    val mrv = it.getView<CpGridRecyclerView>(R.id.mStRv)
                    val mLayoutManager = GridLayoutManager(context,4)
                    var adapter:ContractSettingRvAdapter? = null

                    mrv.layoutManager = mLayoutManager
                    adapter = ContractSettingRvAdapter(data)
                    mrv?.adapter = adapter

                    val controller =
                        AnimationUtils.loadLayoutAnimation(context, R.anim.cp_gridlayout_animation_from_bottom)
                    mrv?.setLayoutAnimation(controller)
                    mrv?.scheduleLayoutAnimation()

                    adapter?.setOnItemClickListener(object : OnItemClickListener{
                        override fun onItemClick(
                            adapter: BaseQuickAdapter<*, *>,
                            view: View,
                            position: Int
                        ) {
                            listener?.clickItem(data,position)
                        }
                    })

                }
                .addOnClickListener(R.id.ct_close,R.id.add_optional)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when(view.id){
                        //Click Close
                        R.id.ct_close -> {
                            tDialog.dismiss()
                        }
                        //Add or delete preferences
                        R.id.add_optional -> {
                            val isCollect = CpClLogicContractSetting.hasCollect(context,contractId)
                            if(isCollect){
                                ToastUtils.showToast(context,CpLanguageUtil.getString(context, "kline_tip_removeCollectionSuccess"))
                            }else{
                                ToastUtils.showToast(context,CpLanguageUtil.getString(context, "kline_tip_addCollectionSuccess"))
                            }
                            CpClLogicContractSetting.collectContractCoin(context,contractId)
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .apply {
                    setStyle(STYLE_NORMAL,R.style.contract_setting_dialog)
                }
                .show()
        }


        /**
         *Long press the contract price pop-up box
         *IsShowTop: true Show Top false Don't Show Top
         *IsCollect: true Display favorites false Display cancel favorites
         *DialogItemClickListener: position 1 Collection, Cancel Collection 0 Top, Cancel Top
         */
        fun createMarketPop(
            context: Context?,
            targetView: View,
            isCollect: Boolean,
            dialogItemClickListener: DialogOnSigningItemClickListener?
        ) {
            val leverEasyPopup =
                EasyPopup.create().setContentView(context, R.layout.cp_popwindow_market)
                    .setFocusAndOutsideEnable(true)
                    .setWidth(ViewGroup.LayoutParams.WRAP_CONTENT)
                    .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                    .setAnimationStyle(R.style.cp_dialogAnim)
                    .apply()

            leverEasyPopup?.run {

                val tvCollect = findViewById<TextView>(R.id.tv_collect)
                tvCollect.visibility = View.VISIBLE
                tvCollect.setText(
                    if (!isCollect) CpLanguageUtil.getString(
                        context,
                        "market_str_2"
                    ) else CpLanguageUtil.getString(context, "market_str_1")
                )
                tvCollect.setOnClickListener {
                    dialogItemClickListener?.clickItem(1,"")
                    dismiss()
                }

                setOnDismissListener {
                    dialogItemClickListener?.dismiss()
                }

            }
            val windowPos = CpSystemUtils.calculatePopWindowPos(targetView,leverEasyPopup.contentView)
            //Current X-axis centered
            val viewX =  targetView.getWidth() / 2 - leverEasyPopup.contentView.getMeasuredWidth() / 2
            leverEasyPopup?.showAtLocation(
                targetView,
                Gravity.TOP or Gravity.START,
                viewX,
                windowPos[1]
            )
        }

        //Display bottom dialog with vp+rv+searchBar
        fun createBottomSearchVpDialog(context: Context,contractId:Int, listener: DialogOnSigningItemClickListener,isHasAll:Boolean = false):CpTDialog{
            val activity = context as AppCompatActivity

            var dialog:CpTDialog? = null
            val classificationBuff = CpClLogicContractSetting.getContractClassificationById(context, contractId)
            val data = CpClLogicContractSetting.getDataBottomSearchVpDialog(context,classificationBuff)
            return CpTDialog.Builder(activity.supportFragmentManager)
                .setLayoutRes(R.layout.dialog_bottom_vp_search_layout)
                .setDialogAnimationRes(R.style.dialogBottomAnim)
                .setScreenWidthAspect(context,1.0f)
                .setScreenHeightAspect(context,0.5f)
                .setDimAmount(0.8f)
                .setOnBindViewListener(object : OnCpBindViewListener{
                    override fun bindView(viewHolder: CpBindViewHolder?) {
                        val fm = dialog?.childFragmentManager
                        //Tab name
                        var titles = arrayOfNulls<String>(if(isHasAll) data.first.size+1 else data.first.size)
                        var fragments = arrayListOf<Fragment>()

                        if(isHasAll){
                            titles[0] = CpLanguageUtil.getString(context,"cp_all_contract")
                            //-1代表全部
                            val fragment = DialogSymbolFragment.newInstance(-1,data.second).apply {
                                setSelectContractId(contractId)
                                //Set dialog selection callback
                                setCallback(listener,dialog)
                            }
                            fragments.add(fragment)
                        }

                        val editText = viewHolder?.getView<EditText>(R.id.mSearch)
                        val slidingTab = viewHolder?.getView<SlidingTabLayout>(R.id.mTypeTab)
                        val vp = viewHolder?.getView<ViewPager>(R.id.mSearchVp)
                        //Location of the vp record category after selecting the category
                        var vpSelectPosition = -1

                        editText?.hint = CpLanguageUtil.getString(context,"cp_search_bar_hint_coin")
                        //If there are categories
                        if(data.first!=null){
                            val classData = data.first as ArrayList<CpTabInfo>
                            //Set fragment
                            for(item in classData.withIndex()){
                                val position = if(isHasAll) item.index+1 else item.index
                                titles[position]=when(item.value.index){
                                    1 -> CpLanguageUtil.getString(context, "cp_contract_data_text13")
                                    2 -> CpLanguageUtil.getString(context, "cp_contract_data_text10")
                                    3 -> CpLanguageUtil.getString(context, "cp_contract_data_text12")
                                    4 -> CpLanguageUtil.getString(context, "cp_contract_data_text11")
                                    else ->""
                                }
//                                titles[position] = item.value.name
                                val fragment = DialogSymbolFragment.newInstance(item.value.index,data.second).apply {
                                    setSelectContractId(contractId)
                                    //Set dialog selection callback
                                    setCallback(listener,dialog)
                                }
                                fragments.add(fragment)
                            }
                            //Get the location of the selected category
                            for(i in classData.indices){
                                if(classData[i].extrasBol!!){
                                    vpSelectPosition = i
                                }
                            }
                        }
                        //Set viewpager
                        val marketPageAdapter = CpPageAdapter(fm,null, fragments)
                        vp?.offscreenPageLimit = titles.size
                        vp?.adapter = marketPageAdapter

                        //Set tab+vp
                        slidingTab?.setViewPager(vp, titles)
                        //Set Category Location
                        if(vpSelectPosition!=-1) slidingTab?.currentTab = if(isHasAll) vpSelectPosition+1 else vpSelectPosition

                        //Set dm font
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            for(i in titles.indices) slidingTab?.run{ getTitleView(i).toDinproMedium() }
                        }

                        //Enter keywords to filter data in fg
                        editText?.addTextChangedListener {
                            for(cFg in fragments){
                                val keyword = editText.text.toString()
                                val dialogSymbolFragment = cFg as DialogSymbolFragment
                                dialogSymbolFragment.searchDataByKeyword(keyword)
                            }
                        }
                        editText?.setOnEditorActionListener(object: TextView.OnEditorActionListener {
                            override fun onEditorAction(
                                v: TextView?,
                                actionId: Int,
                                event: KeyEvent?
                            ): Boolean {

                                if(actionId == EditorInfo.IME_ACTION_SEARCH){
                                    CpSoftKeyboardUtil.hideSoftKeyboard(editText)
                                    editText.clearFocus()
                                    for(cFg in fragments){
                                        val keyword = editText.text.toString()
                                        val dialogSymbolFragment = cFg as DialogSymbolFragment
                                        dialogSymbolFragment.searchDataByKeyword(keyword)
                                    }
                                    return true
                                }
                                return false
                            }

                        })
                    }

                })
                .setGravity(Gravity.BOTTOM)
                .addOnClickListener(R.id.bd_cancel)
                .setOnViewClickListener(object : OnCpViewClickListener {
                    override fun onViewClick(
                        viewHolder: CpBindViewHolder?,
                        view: View?,
                        tDialog: CpTDialog?
                    ) {
                        when(view?.id){
                            //Cancel
                            R.id.bd_cancel -> {
                                tDialog?.dismiss()
                            }
                        }
                    }

                })
                .create()
                .apply {
                    dialog = this
                }
                .show()
        }

        //Set the k-line chart position on the home page dialog ->0 top 1 bottom
        fun createContractTradingAreaSettingDialog(context: Context,position: Int=0,listener:DialogOnItemClickListener? = null):CpTDialog{
            val activity = context as AppCompatActivity
            return CpTDialog.Builder(activity.supportFragmentManager)
                .setLayoutRes(R.layout.dialog_contract_trading_area_chart_layout)
                .setDialogAnimationRes(R.style.dialogBottomAnim)
                .setScreenWidthAspect(context,1.0f)
                .setDimAmount(0.5f)
                .setGravity(Gravity.BOTTOM)
                .setOnBindViewListener(object : OnCpBindViewListener{
                    override fun bindView(viewHolder: CpBindViewHolder?) {
                        var topChartView:View? = null
                        var bottomChartView:View? = null
                        val mSwitch = viewHolder?.getView<ImageView>(R.id.mSwitch)

                        val contractChartOff = CpClLogicContractSetting.getContractChartOff(context)
                        var isCheck = contractChartOff==1
                        viewHolder?.run {
                            topChartView = getView(R.id.chartTop)
                            bottomChartView = getView(R.id.chartBottom)

                            setText(R.id.title,CpLanguageUtil.getString(context,"cp_trading_area_chart_title"))
                            setText(R.id.cancel,CpLanguageUtil.getString(context,"cp_overview_text56"))
                            setText(R.id.toplabel,CpLanguageUtil.getString(context,"cp_set_1"))
                            setText(R.id.bottomlabel,CpLanguageUtil.getString(context,"cp_set_2"))
                        }
                        when(position){
                            0 -> {
                                topChartView?.isSelected = true
                                viewHolder?.setTextColor(R.id.toplabel,ContextCompat.getColor(context,R.color.text_color_1))
                                viewHolder?.setTextColor(R.id.bottomlabel,ContextCompat.getColor(context,R.color.text_color_3))
                            }
                            1 -> {
                                bottomChartView?.isSelected = true
                                viewHolder?.setTextColor(R.id.toplabel,ContextCompat.getColor(context,R.color.text_color_3))
                                viewHolder?.setTextColor(R.id.bottomlabel,ContextCompat.getColor(context,R.color.text_color_1))
                            }
                        }


                        mSwitch?.setOnClickListener {
                            isCheck = !isCheck
                            CpClLogicContractSetting.setContractChartOff(context,if(isCheck) 1 else 0)
                            mSwitch?.isSelected = isCheck
                            topChartView?.isEnabled = isCheck
                            bottomChartView?.isEnabled = isCheck
//                            topChartView?.alpha = if(isCheck) 1.0f else 0.5f
//                            bottomChartView?.alpha = if(isCheck) 1.0f else 0.5f

                            if(isCheck){
                                if(position==0){
                                    topChartView?.isSelected = true
                                    viewHolder?.setTextColor(R.id.toplabel,ContextCompat.getColor(context,R.color.text_color_1))
                                    viewHolder?.setTextColor(R.id.bottomlabel,ContextCompat.getColor(context,R.color.text_color_3))
                                }else if(position==1){
                                    bottomChartView?.isSelected = true
                                    viewHolder?.setTextColor(R.id.toplabel,ContextCompat.getColor(context,R.color.text_color_3))
                                    viewHolder?.setTextColor(R.id.bottomlabel,ContextCompat.getColor(context,R.color.text_color_1))
                                }else{
                                    CpClLogicContractSetting.setContractChartPosition(context,0)
                                    topChartView?.isSelected = true
                                    viewHolder?.setTextColor(R.id.toplabel,ContextCompat.getColor(context,R.color.text_color_1))
                                    viewHolder?.setTextColor(R.id.bottomlabel,ContextCompat.getColor(context,R.color.text_color_3))
                                }

                                listener?.clickItem(if(position==null) 0 else position)
                            }else{
                                listener?.clickItem(-1)
                                topChartView?.isSelected = false
                                bottomChartView?.isSelected = false
                                viewHolder?.setTextColor(R.id.toplabel,ContextCompat.getColor(context,R.color.text_color_3))
                                viewHolder?.setTextColor(R.id.bottomlabel,ContextCompat.getColor(context,R.color.text_color_3))
                            }
                        }


                        if(contractChartOff==1){
                            mSwitch?.isSelected = true
                            topChartView?.isEnabled = true
                            bottomChartView?.isEnabled = true

                        }else{
                            mSwitch?.isSelected = false
                            topChartView?.run {
                                isEnabled = false
                                isSelected = false
                            }
                            bottomChartView?.run{
                                isEnabled = false
                                isSelected = false
                            }

//                            topChartView?.alpha = 0.5f
//                            bottomChartView?.alpha = 0.5f
                            viewHolder?.setTextColor(R.id.toplabel,ContextCompat.getColor(context,R.color.text_color_3))
                            viewHolder?.setTextColor(R.id.bottomlabel,ContextCompat.getColor(context,R.color.text_color_3))
                        }

                    }

                })
                .addOnClickListener(R.id.chartTop,R.id.chartBottom,R.id.cancel)
                .setOnViewClickListener(object : OnCpViewClickListener{
                    override fun onViewClick(
                        viewHolder: CpBindViewHolder?,
                        view: View?,
                        tDialog: CpTDialog?
                    ) {
                        when(view?.id){
                            R.id.chartTop -> {
                                CpClLogicContractSetting.setContractChartPosition(context,0)
                                listener?.clickItem(0)
                                view.isSelected = true
                                tDialog?.dismiss()
                            }
                            R.id.chartBottom -> {
                                CpClLogicContractSetting.setContractChartPosition(context,1)
                                listener?.clickItem(1)
                                view.isSelected = true
                                tDialog?.dismiss()
                            }
                            R.id.cancel -> {
                                tDialog?.dismiss()
                            }
                        }
                    }

                })
                .create()
                .show()
        }

        //Successfully opened the contract Dialog
        fun createContractOpenSuccessDialog(context: Context,callback:DialogOnItemClickListener):CpTDialog{
            val activity = context as AppCompatActivity
            var dialog:CpTDialog? = null
            return CpTDialog.Builder(activity.supportFragmentManager)
                .setLayoutRes(R.layout.dialog_contract_open_success_layout)
                .setScreenWidthAspect(activity,0.8f)
                .setDimAmount(0.5f)
                .setGravity(Gravity.CENTER)
                .setOnBindViewListener(object: OnCpBindViewListener {
                    override fun bindView(viewHolder: CpBindViewHolder?) {
                        viewHolder?.run {
                            val toTransferBtn = getView<CpCommonlyUsedButton>(R.id.toTransferBtn)
                            val understandBtn = getView<CpCommonlyUsedButton>(R.id.understandBtn)
                            toTransferBtn.setContent(CpLanguageUtil.getString(context,"cp_contract_opened_dialog_btn1"))
                            understandBtn.setContent(CpLanguageUtil.getString(context,"cp_contract_opened_dialog_btn2"))
                            setText(R.id.cancelBtn,CpLanguageUtil.getString(context,"cp_overview_text56"))
                            setText(R.id.tv_title,CpLanguageUtil.getString(context,"cp_contract_opened_successfully"))
                            setText(R.id.tv_content,CpLanguageUtil.getString(context,"cp_contract_opened_success_msg"))
                            toTransferBtn.listener = object : CpCommonlyUsedButton.OnBottonListener {
                                override fun bottonOnClick() {

                                    callback.clickItem(0)
                                    dialog?.dismiss()
                                }
                            }
                            understandBtn.listener = object : CpCommonlyUsedButton.OnBottonListener {
                                override fun bottonOnClick() {
                                    callback.clickItem(1)
                                    dialog?.dismiss()
                                }
                            }

                        }
                    }
                })
                .addOnClickListener(R.id.cancelBtn)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    if(view.id==R.id.cancelBtn){
                        tDialog.dismiss()
                    }
                }
                .create()
                .apply { dialog = this }
                .show()
        }


        fun showTipDialogByOrderType(context:Context,selectPosition:Int) : CpTDialog{
            val activity = context as AppCompatActivity
            var dialog:CpTDialog? = null
            dialog = CpTDialog.Builder(activity.supportFragmentManager)
                .setLayoutRes(R.layout.dialog_ordertype_tip_layout)
                .setDialogAnimationRes(R.style.dialogBottomAnim)
                .setScreenWidthAspect(context,1.0f)
                .setHeight(CpSizeUtils.dp2px(316.0f))
                .setDimAmount(0.8f)
                .setGravity(Gravity.BOTTOM)
                .setOnBindViewListener {
                    it.setText(R.id.bd_cancel,CpLanguageUtil.getString(context,"cp_overview_text56"))
                    val mSlidingTab = it.getView<SlidingTabLayout>(R.id.mTypeTab)
                    val mTipVp = it.getView<ViewPager>(R.id.mTipVp)
                    val tabTitles = arrayOf(
                        CpLanguageUtil.getString(context, "cp_overview_text3"),
                        CpLanguageUtil.getString(context, "cp_overview_text4"),
                        CpLanguageUtil.getString(context, "cp_overview_text5"),
                        CpLanguageUtil.getString(context, "cp_overview_post_only"),
                        CpLanguageUtil.getString(context, "cp_overview_ioc"),
                        CpLanguageUtil.getString(context, "cp_overview_fok"),
                    )

                    val fragments = arrayListOf<Fragment>(
                        CpOrderTypeTipFragment(CpLanguageUtil.getString(context, "cp_limit_order_tip"), title = CpLanguageUtil.getString(context, "cp_limit_order_tip_title")),
                        CpOrderTypeTipFragment(CpLanguageUtil.getString(context, "cp_market_order_tip"), title = CpLanguageUtil.getString(context, "cp_market_order_tip_title")),
                        CpOrderTypeTipFragment(CpLanguageUtil.getString(context, "cp_trigger_order_tip"), title = CpLanguageUtil.getString(context, "cp_trigger_order_tip_title")),
                        CpOrderTypeTipFragment(CpLanguageUtil.getString(context, "cp_post_only_tip"), title = CpLanguageUtil.getString(context, "cp_post_only_tip_title")),
                        CpOrderTypeTipFragment(CpLanguageUtil.getString(context, "cp_ioc_tip"), title = CpLanguageUtil.getString(context, "cp_ioc_tip_title")),
                        CpOrderTypeTipFragment(CpLanguageUtil.getString(context, "cp_fok_tip"), title = CpLanguageUtil.getString(context, "cp_fok_tip_title")),
                    )

                    mTipVp.adapter = CpPageAdapter(dialog?.childFragmentManager,null,fragments)


                    mSlidingTab.setViewPager(mTipVp,tabTitles)

                    mSlidingTab.currentTab = selectPosition

                }
                .addOnClickListener(R.id.bd_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when(view.id){
                        R.id.bd_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()

            return dialog
        }

    }
}








