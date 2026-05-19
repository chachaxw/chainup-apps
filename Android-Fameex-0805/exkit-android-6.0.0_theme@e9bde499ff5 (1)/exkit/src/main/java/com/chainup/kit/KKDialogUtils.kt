package com.chainup.kit

import android.content.Context
import android.content.DialogInterface
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.text.Editable
import android.text.InputFilter
import android.text.TextUtils
import android.text.TextWatcher
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.MarginLayoutParams
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.PopupWindow
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.annotation.DrawableRes
import androidx.annotation.LayoutRes
import androidx.annotation.StyleRes
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.RecyclerView.ViewHolder
import com.chainup.kit.bean.KKItemTabInfo
import com.chainup.kit.dialog.KKTDialog
import com.chainup.kit.dialog.adapter.KKBottomCardListRvAdapter
import com.chainup.kit.dialog.adapter.KKBottomSheetRvAdapter
import com.chainup.kit.dialog.adapter.KKBottomSheetRvAdapterV2
import com.chainup.kit.dialog.adapter.KKItemCardEntity
import com.chainup.kit.dialog.adapter.KKPopSelectAdapter
import com.chainup.kit.dialog.base.KKBindViewHolder
import com.chainup.kit.utils.PublicSizeUtil
import com.chainup.kit.views.KKButtonKit
import com.chainup.kit.views.base.BaseEditTextKit
import com.chainup.kit.views.base.BaseMaxHeightRecyclerViewKit
import com.example.chainup_kit.R
import com.qmuiteam.qmui.layout.QMUIFrameLayout
import com.qmuiteam.qmui.util.QMUIKeyboardHelper
import com.zyyoona7.popup.EasyPopup
import com.zyyoona7.popup.XGravity
import com.zyyoona7.popup.YGravity
import org.jetbrains.anko.*
import java.security.InvalidParameterException

const val dimAmountValue:Float = 0.5f
class KKDialogUtils {
    interface DialogOnclickListener {
        fun clickItem(data: ArrayList<String>, item: Int)
    }

    interface DialogOnItemClickListener {

        fun clickItem(position: Int)
    }

    interface DialogShareClickListener {
        fun clickItem(bitmap: Bitmap)
    }

    interface DialogBottomListener {
        fun sendConfirm()
    }

    interface DialogDoubleBottomListener {
        fun sendConfirm()

        fun sendCancel()

        fun dismiss(dialog: DialogInterface){}
    }

    interface DialogDoubleBottomStrListener {
        fun sendConfirm(data: String)

        fun sendCancel(data: String)
    }

    interface DialogDoubleBottomIntListener {
        fun sendConfirm(data: Int)

        fun sendCancel(data: Int)
    }

    interface DialogBottomStrListener {
        fun sendConfirm(data: String)
    }

    interface DialogBottomIntListener {
        fun sendConfirm(data: Int)
    }

    interface DialogOnSigningItemClickListener {
        fun clickItem(position: Int, text: String)
    }

    interface DialogOnDismissClickListener {
        fun clickItem()
    }

    companion object {
        /**
         * @param content String -> dialog content
         * @param title String -> dialog title
         * @param listener DialogDoubleBottomListener? -> callback listener event
         * @param cancelTitle String -> cancel button text
         * @param confrimTitle String -> confirm button text
         * @param isShowCancel bool -> is visible cancel button?
         * @param style Int -> 1,2,3,4
            *   <p>Style 1 without title</p>
            *   <p>Style 2 with title</p>
            *   <p>Style 3 with icon prompt pop-up</p>
            *   <p>Style 4 with top picture dialog</p>
         * @param drawableRes @DrawableRes Int -> top picture drawableRes
         * @param isCancelableOutside bool -> Can the pop-up window be cancelled outside the pop-up area
         * @return KKTDialog -> this dialog
         */
        fun showCommonDialog(
            context: Context,
            content: CharSequence = "",
            title: String = "",
            listener: DialogDoubleBottomListener?,
            cancelTitle: String? = "",
            confrimTitle: String? = "",
            isShowCancel: Boolean? = true,
            style: Int? = 2,
            @DrawableRes drawableRes:Int? = null,
            isCancelableOutside:Boolean? = false
        ) :KKTDialog {
            if(style==4 && drawableRes==null) {
                throw InvalidParameterException("DrawableRes not can is null!")
            }
            val layoutRes = when (style) {
                1 -> R.layout.item_common_style_1_dialog
                2 -> R.layout.item_common_style_2_dialog
                3 -> R.layout.item_common_style_3_dialog
                4 -> R.layout.item_common_style_4_dialog
                else -> R.layout.item_common_style_2_dialog
            }

            return KKTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(layoutRes)
                .setScreenWidthAspect(context, 0.8f)
                .setGravity(Gravity.CENTER)
                .setDimAmount(dimAmountValue)
                .setCancelableOutside(isCancelableOutside?:false)
                .setOnBindViewListener { viewHolder: KKBindViewHolder?, tDialog ->
                    viewHolder?.run {
                        val kkCancelBtn = getView<KKButtonKit>(R.id.tv_cancel_btn)
                        val kkConfirmBtn = getView<KKButtonKit>(R.id.tv_confirm_btn)
                        val tvContent = getView<TextView>(R.id.tv_content)
                        if (!TextUtils.isEmpty(title)) {
                            setGone(R.id.tv_title, true)
                            setText(R.id.tv_title, title)
                        } else {
                            val lp = tvContent.layoutParams as MarginLayoutParams
                            lp.topMargin = 0
                            tvContent.layoutParams = lp
                            setGone(R.id.tv_title, false)
                        }
                        if (!TextUtils.isEmpty(cancelTitle)) {
                            kkCancelBtn.textContent = cancelTitle!!
                        } else {
                            kkCancelBtn.textContent = context.getString(R.string.kk_common_text_btnCancel)
                        }
                        setGone(R.id.tv_cancel_btn, isShowCancel == true)
                        if (!TextUtils.isEmpty(confrimTitle)) {
                            kkConfirmBtn.textContent = confrimTitle!!
                        } else {
                            kkConfirmBtn.textContent = context.getString(R.string.kk_common_text_btnConfirm)
                        }
                        if (!TextUtils.isEmpty(content)) {
                            setText(R.id.tv_content, content)
                            setGone(R.id.tv_content, true)
                        } else {
                            setGone(R.id.tv_content, false)
                        }
                        if(style==4) drawableRes?.run { setImageResource(R.id.iv_ilus,drawableRes) }
                    }

                }
                .addOnClickListener(R.id.tv_cancel_btn,R.id.tv_confirm_btn)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when (view.id) {
                        R.id.tv_cancel_btn -> {
                            listener?.sendCancel()
                        }
                        R.id.tv_confirm_btn -> {
                            listener?.sendConfirm()
                        }
                    }
                    tDialog.dismiss()
                }
                .setOnDismissListener {
                    listener?.dismiss(it)
                }
                .create()
                .show()
        }

        fun showOneBtnDialog(context: Context,confrimTitle: String? = "",content: String = ""){
            KKDialogUtils.showCommonDialog(context,"",
                content,object : KKDialogUtils.DialogDoubleBottomListener{
                    override fun sendConfirm() {

                    }

                    override fun sendCancel() {

                    }
                },cancelTitle = "",confrimTitle = confrimTitle, style = 3, isShowCancel = false)
        }
        fun showOneBtnDialogTitle(context: Context,confrimTitle: String? = "",content: String = "",mTitle:String = ""){
            KKDialogUtils.showCommonDialog(context,content,
                mTitle,object : KKDialogUtils.DialogDoubleBottomListener{
                    override fun sendConfirm() {

                    }

                    override fun sendCancel() {

                    }
                },cancelTitle = "",confrimTitle = confrimTitle, style = 1, isShowCancel = false)
        }

        /**
         * todo: position is index  callback is position????
         * Show a bottom select bottomSheetDialog
         * @param context Context
         * @param list dataList
         * @param position selected KKItemTabInfo.index
         * @param cancelTitle cancel title
         * @param listener callback interface -> position
         * @return KKTDialog
         * */
        @Deprecated("this method has a bug!", ReplaceWith("showBottomSheetListV2(context,list,position,cancelTitle,listener)"))
        fun showBottomSheetList(context: Context,
                                list: ArrayList<KKItemTabInfo>,
                                position: Int,
                                cancelTitle: String?,
                                listener: DialogOnItemClickListener) :KKTDialog {
            val activity = context as AppCompatActivity
            return KKTDialog.Builder(activity.supportFragmentManager)
                .setScreenWidthAspect(context, 1.0f)
                .setLayoutRes(R.layout.bottom_sheet_list_dialog)
                .setDimAmount(dimAmountValue)
                .setDialogAnimationRes(R.style.ani_translate_from_bottom_to_top)
                .setGravity(Gravity.BOTTOM)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder, tDialog ->
                    viewHolder?.setText(R.id.tv_cancel, if(cancelTitle!=null) cancelTitle else context.getString(R.string.kk_common_text_btnCancel))

                    val adapter = KKBottomSheetRvAdapter(list, position)
                    val listView = viewHolder?.getView<RecyclerView>(R.id.recycler_view)
                    listView?.layoutManager = LinearLayoutManager(context)
                    listView?.adapter = adapter
                    listView?.setHasFixedSize(true)
                    adapter.setOnItemClickListener { adapter, view, position ->
                        listener.clickItem(position)
                        tDialog.dismiss()
                    }
                }
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when(view.id){
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        /**
         * Show a bottom select bottomSheetDialog
         * @param context Context
         * @param list dataList
         * @param position selected position
         * @param cancelTitle cancel title
         * @param canSwipeClose is open bottom sheet dialog?
         * @param listener callback interface -> position
         * @return KKTDialog
         * */
        fun showBottomSheetListV2(context: Context,
                                list: ArrayList<KKItemTabInfo>,
                                position: Int,
                                cancelTitle: String?,
                                canSwipeClose:Boolean=false,
                                dismissListener:DialogInterface.OnDismissListener?=null,
                                listener: DialogOnItemClickListener) :KKTDialog {
            val activity = context as AppCompatActivity
            return KKTDialog.Builder(activity.supportFragmentManager)
                .setScreenWidthAspect(context, 1.0f)
                .setLayoutRes(R.layout.bottom_sheet_list_dialog)
                .setDimAmount(dimAmountValue)
                .setCanSwipeClose(canSwipeClose)
                .setDialogAnimationRes(R.style.ani_translate_from_bottom_to_top)
                .setGravity(Gravity.BOTTOM)
                .setCancelableOutside(true)
                .setSwipeFoldEnabled(false)
                .setOnBindViewListener { viewHolder, tDialog ->
                    viewHolder.setText(R.id.tv_cancel, if(cancelTitle!=null) cancelTitle else context.getString(R.string.kk_common_text_btnCancel))

                    val adapter = KKBottomSheetRvAdapterV2(list, position)
                    val listView = viewHolder.getView<RecyclerView>(R.id.recycler_view)
                    if(canSwipeClose){
                        val lParams = listView.layoutParams as LinearLayout.LayoutParams
                        lParams.topMargin = PublicSizeUtil.dp2px(context,20f)
                        listView.layoutParams = lParams
                    }
                    listView.layoutManager = LinearLayoutManager(context)
                    listView.adapter = adapter
                    listView.setHasFixedSize(true)
                    adapter.setOnItemClickListener { adapter, view, position ->
                        listener.clickItem(position)
                        tDialog.dismiss()
                    }
                }
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when(view.id){
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .setOnDismissListener(dismissListener)
                .create()
                .show()
        }


        fun createMarketPop(context: Context, targetView: View, actions: Array<String>,listener:DialogOnSigningItemClickListener?){
            if(actions.isEmpty()) throw Exception("actions size = 0!!!")
            val view = LayoutInflater.from(context).inflate(R.layout.public_popwindow_market,null)
            val llAction = view.findViewById<LinearLayout>(R.id.ll_action)

            for((position,item) in actions.withIndex()){
                val tvObj = TextView(context).let {
                    it.text = item
                    it.textSize = 14.0f
                    it.gravity = Gravity.CENTER
                    it.textColor = ContextCompat.getColor(context,R.color.white)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        it.typeface = context.resources.getFont(R.font.dinpro_medium)
                    }
                    it.leftPadding = PublicSizeUtil.dp2px(context,12.0f)
                    it.rightPadding = PublicSizeUtil.dp2px(context,12.0f)
                    it
                }
                val llParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT,LinearLayout.LayoutParams.MATCH_PARENT)
                tvObj.layoutParams = llParams
                llAction.addView(tvObj)

                if(actions.size != 1 && position<actions.size-1){
                    val ivView = ImageView(context).let {
                        it.backgroundColor = ContextCompat.getColor(context,R.color.line_color_night)
                        it
                    }
                    val llIvParams = LinearLayout.LayoutParams(PublicSizeUtil.dp2px(context,0.5f),LinearLayout.LayoutParams.MATCH_PARENT)
                    ivView.layoutParams = llIvParams
                    llAction.addView(ivView)
                }
            }


            EasyPopup.create()
                .setContentView(view)
                .setFocusAndOutsideEnable(true)
                .setWidth(ViewGroup.LayoutParams.WRAP_CONTENT)
                .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                .setAnimationStyle(R.style.ani_popwindow_center)
                .setOnViewListener { view, popup ->
                    val llView = view.findViewById<LinearLayout>(R.id.ll_action)
                    for(index in 0 .. llView.childCount-1){
                        val cview = llView.getChildAt(index)
                        if(cview is TextView){
                            cview.setOnClickListener {
                                val realPosition = index / 2
                                listener?.clickItem(realPosition,actions[realPosition])
                                popup.dismiss()
                            }
                        }
                    }

                }
                .apply()
                .showAtAnchorView(targetView,YGravity.ABOVE,XGravity.CENTER)
        }

        /**
         * @param context
         * @param adapter set recyclerview adapter
         * @param title
         * @param warnText warnText
         * @param canSwipeClose is open bottom sheet dialog?
         * @param maxListHeight set BaseMaxHeightRecyclerViewKit can scroll maxHeight
         * @param visibleHeader is visible public header layout
         * @return KKTDialog
         * */
        fun <VH : ViewHolder> showBottomListDialogByAdapter(
            context: Context,
            adapter:RecyclerView.Adapter<VH>,
            title:String? = "",
            warnText:String? = "",
            canSwipeClose:Boolean=false,
            maxListHeight:Int = -1,
            visibleHeader:Boolean = true,
            visibleCancel:Boolean = true,
            peekHeight:Int = -1,
            canSwipeFoldEnabled:Boolean = false,
            dismissListener:DialogInterface.OnDismissListener?=null,
            bindView: ((holder: KKBindViewHolder,dialog:KKTDialog,recyclerView:BaseMaxHeightRecyclerViewKit) -> Unit)? = null
        ) : KKTDialog {
            return KKTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.bottom_card_list_dialog)
                .setScreenWidthAspect(context, 1.0f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(dimAmountValue)
                .setCanSwipeClose(canSwipeClose)
                .setSwipePeekHeight(peekHeight)
                .setSwipeFoldEnabled(canSwipeFoldEnabled)
                .setDialogAnimationRes(R.style.ani_translate_from_bottom_to_top)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: KKBindViewHolder?, tDialog ->
                    viewHolder?.run {
                        setGone(R.id.kk_ll_header,visibleHeader)
                        setGone(R.id.tv_cancel,visibleCancel)
                        setGone(R.id.v_topLine,canSwipeClose)
                        if(visibleHeader){
                            setText(R.id.tv_title,title ?: "")
                            setText(R.id.tv_cancel,context.getString(R.string.kk_common_text_btnCancel))
//                        setGone(R.id.tv_warn_tip, warnText?.isEmpty() ?: true)
                            setText(R.id.tv_warn_tip,warnText ?: "")
                            if(canSwipeClose) {
                                val vTitleLayout = getView<View>(R.id.rl_title_layout)
                                val lp = vTitleLayout.layoutParams as LinearLayout.LayoutParams
                                lp.topMargin = PublicSizeUtil.dp2px(context,4f)
                                vTitleLayout.layoutParams = lp
                            }
                        }

                        val rvList = getView<BaseMaxHeightRecyclerViewKit>(R.id.rvList)
                        with(rvList) {
                            if(maxListHeight!=-1) setMaxHeight(maxListHeight)
                            layoutManager = LinearLayoutManager(context,LinearLayoutManager.VERTICAL,false)
                            this.adapter = adapter
                        }
                        bindView?.invoke(this,tDialog,rvList)
                    }
                }
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when(view.id){
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .setOnDismissListener(dismissListener)
                .create()
                .show()
        }

        @Deprecated("Please use showBottomListDialogByAdapter,It is not active,want deprecated!", ReplaceWith("showBottomListDialogByAdapter(context,adapter,title,warnText)"))
        fun <VH : ViewHolder> showSelCoinListDialogByAdapter(
            context: Context,
            adapter:RecyclerView.Adapter<VH>,
            title:String? = "",
            warnText:String? = ""
        ) : KKTDialog {
            return KKTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.bottom_coin_list_dialog)
                .setScreenWidthAspect(context, 1.0f)
                .setScreenHeightAspect(context, 0.98f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(dimAmountValue)
                .setDialogAnimationRes(R.style.ani_translate_from_bottom_to_top)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: KKBindViewHolder?, tDialog ->
                    viewHolder?.run {
                        setText(R.id.tv_title,title ?: "")
                        setText(R.id.tv_cancel,context.getString(R.string.kk_common_text_btnCancel))
//                        setGone(R.id.tv_warn_tip, warnText?.isEmpty() ?: true)
                        setText(R.id.tv_warn_tip,warnText ?: "")

                        val rvList = getView<RecyclerView>(R.id.rvList)
                        with(rvList) {
                            layoutManager = LinearLayoutManager(context,LinearLayoutManager.VERTICAL,false)
                            this.adapter = adapter
                        }
                    }
                }
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when(view.id){
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .create()
                .show()
        }

        /**
         * custom layout.
         * @param context
         * @param title
         * @param layoutRes layout Pointer
         * @param bindView init view bind callback
         * @return KKTDialog
         * If you not need header or you need by swipe close this dialog,you can use overloads fun {showBottomDialogByLayout},it contain param canSwipeClose,it default value is true
         * */
        fun showBottomDialogByLayout(
            context: Context,
            title:String? = "",
            @LayoutRes layoutRes:Int,
            heightPx:Int = -1,
            dismissListener:DialogInterface.OnDismissListener?=null,
            bindView:(holder: KKBindViewHolder) -> Unit
        ):KKTDialog {
            return KKTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.bottom_layout_dialog)
                .setScreenWidthAspect(context, 1.0f)
                .setHeight(heightPx)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(dimAmountValue)
                .setDialogAnimationRes(R.style.ani_translate_from_bottom_to_top)
                .setCancelableOutside(true)
                .setSwipeFoldEnabled(false)
                .setOnBindViewListener { viewHolder: KKBindViewHolder?, tDialog ->
                    viewHolder?.run {
                        setText(R.id.tv_title,title ?: "")
                        setText(R.id.tv_cancel,context.getString(R.string.kk_common_text_btnCancel))
                        setGone(R.id.tv_warn_tip,false)
                        val layoutView = LayoutInflater.from(context).inflate(layoutRes,null)
                        (getView(R.id.fl_layout) as ViewGroup).addView(layoutView)
                        bindView.invoke(this)
                    }
                }
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when(view.id){
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .setOnDismissListener(dismissListener)
                .create()
                .show()
        }
        fun showBottomDialogByLayout(
            context: Context,
            @LayoutRes layoutRes:Int,
            canSwipeClose: Boolean = true,
            canSwipeFoldEnabled: Boolean = false,
            heightPx:Int = -1,
            dismissListener:DialogInterface.OnDismissListener?=null,
            bindView: (holder: KKBindViewHolder) -> Unit
        ):KKTDialog {
            return KKTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.bottom_layout_dialog_v2)
                .setScreenWidthAspect(context, 1.0f)
                .setHeight(heightPx)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(dimAmountValue)
                .setCanSwipeClose(canSwipeClose)
                .setDialogAnimationRes(R.style.ani_translate_from_bottom_to_top)
                .setCancelableOutside(true)
                .setSwipeFoldEnabled(canSwipeFoldEnabled)
                .setOnBindViewListener { viewHolder: KKBindViewHolder?, tDialog ->
                    viewHolder?.run {
                        val layoutView = LayoutInflater.from(context).inflate(layoutRes,null)
                        val flLayout = (getView(R.id.fl_layout) as ViewGroup)
                        if(canSwipeClose) {
                            val rlParams = flLayout.layoutParams as RelativeLayout.LayoutParams
                            rlParams.topMargin = PublicSizeUtil.dp2px(context,20f)
                            flLayout.layoutParams = rlParams
                        }
                        flLayout.addView(layoutView)
                        bindView.invoke(this)
                    }
                }
                .addOnClickListener(R.id.tv_cancel)
                .setOnViewClickListener { viewHolder, view, tDialog ->
                    when(view.id){
                        R.id.tv_cancel -> {
                            tDialog.dismiss()
                        }
                    }
                }
                .setOnDismissListener(dismissListener)
                .create()
                .show()
        }

        fun showBottomCardSelectDialog(
            context: Context,
            dataList:ArrayList<KKItemCardEntity>,
            listener:DialogOnItemClickListener?,
            title:String?,
            warnText:String?=""
        ) : KKTDialog {

            val rvAdapter = KKBottomCardListRvAdapter(dataList)
            val tDialog = showBottomListDialogByAdapter(context, rvAdapter, title,warnText)

            rvAdapter.setOnItemClickListener { adapter, view, position ->
                listener?.clickItem(position)
                Handler(Looper.getMainLooper()).postDelayed(Runnable {
                    tDialog.dismiss()
                },300L)
            }

            rvAdapter.setOnItemChildClickListener { adapter, view, position ->
                when(view.id){
                    R.id.iv_icon_tip -> {
                        //todo:unfinish
                    }
                }
            }

            return tDialog
        }

        fun createSelectPop(context: Context?,
                            index: Int = 0,
                            listData:ArrayList<KKItemTabInfo>,
                            targetView: View,
                            listener:DialogOnSigningItemClickListener?,
                            tipListener:DialogOnSigningItemClickListener?,
                            @StyleRes ams:Int?,
                            dimValue:Float = dimAmountValue,
                            drawableSelectorBg: Drawable? = null,
                            selectTextSize:Float? = null,
                            elevation:Float = 0f,
                            gravity: Int = Gravity.CENTER,
                            dismissListener: PopupWindow.OnDismissListener? = null,
                            dropDownSelectWidth:Int? = null
        ) {
            val mEasyPopup = EasyPopup.create()
                .setContentView(context, R.layout.public_pop_select_rv_layout)
                .setFocusAndOutsideEnable(true)
                .setBackgroundDimEnable(true)
                .setWidth(if(dropDownSelectWidth!=null) (dropDownSelectWidth+(elevation*2)).toInt() else ViewGroup.LayoutParams.WRAP_CONTENT)
                .setAnimationStyle(ams ?: R.style.ani_popwindow_top)
                .setDimValue(dimValue)
                .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                .apply()

            mEasyPopup?.run {
                val rView = findViewById<RecyclerView>(R.id.recycler_view)
                val flView = rView.parent as QMUIFrameLayout
                flView.shadowElevation = elevation.toInt()
                flView.shadowColor = Color.BLACK
                flView.shadowAlpha = 0.6f
                if(drawableSelectorBg!=null){
                    flView.background = drawableSelectorBg
                }
                val layoutParams = flView.layoutParams as FrameLayout.LayoutParams
                layoutParams.margin = elevation.toInt()
                flView.layoutParams = layoutParams
                val adapter = KKPopSelectAdapter(listData, index,selectTextSize,gravity)
                rView?.layoutManager = LinearLayoutManager(context)
                rView?.adapter = adapter
                rView?.setHasFixedSize(true)
                adapter.setOnItemClickListener { adapter, view, position ->
                    listener?.clickItem(position, listData[position].name)
                    mEasyPopup.dismiss()
                }
                adapter.setOnItemChildClickListener { adapter, view, position ->
                    tipListener?.clickItem(position, listData[position].name)
                }
                setOnDismissListener(dismissListener)
            }

            mEasyPopup?.showAtAnchorView(targetView, YGravity.BELOW, XGravity.ALIGN_LEFT, if(elevation>0) -elevation.toInt() else 0, if(elevation>0) (10-elevation).toInt() else 10)

        }

        fun showInputBottomDialog(
            context: Context,
            title:String? = "",
            cancelTitle:String? = "",
            confrimTitle:String = "",
            hint:String? = "",
            listener:DialogDoubleBottomStrListener,
            filters:Array<InputFilter>?=null,
        ): KKTDialog {
            return KKTDialog.Builder((context as AppCompatActivity).supportFragmentManager)
                .setLayoutRes(R.layout.item_input_bottom)
                .setScreenWidthAspect(context, 1f)
                .setGravity(Gravity.BOTTOM)
                .setDimAmount(dimAmountValue)
                .setCancelableOutside(true)
                .setOnBindViewListener { viewHolder: KKBindViewHolder?, tDialog ->
                    viewHolder?.setText(R.id.tv_title, title)
                    viewHolder?.setText(R.id.tv_cancel, cancelTitle)
                    var editText = viewHolder?.getView<BaseEditTextKit>(R.id.edt_input)
                    var btnTv = viewHolder?.getView<KKButtonKit>(R.id.tv_btn)
                    btnTv?.isEnable(false)
                    btnTv?.textContent=confrimTitle
                    editText?.setHint(hint)
                    editText?.filters=filters
                    editText?.requestFocus()
                    QMUIKeyboardHelper.showKeyboard(editText,100)
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
                            if (editText.text.toString().trim().length!=0) {
                                btnTv?.isEnable(true)
                            } else {
                                btnTv?.isEnable(false)
                            }
                        }
                    })
                    btnTv?.setOnClickListener {
                        listener.sendConfirm(editText?.text.toString().trim())
//                        tDialog.dismiss()
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
                    listener.sendCancel("");
                }
                .create()
                .show()
        }

    }
}








