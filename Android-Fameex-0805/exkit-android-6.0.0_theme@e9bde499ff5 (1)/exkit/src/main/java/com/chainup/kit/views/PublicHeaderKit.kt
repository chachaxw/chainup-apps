package com.chainup.kit.views

import android.app.Activity
import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.annotation.DrawableRes
import androidx.annotation.LayoutRes
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.bitmap.CircleCrop
import com.bumptech.glide.request.RequestOptions
import com.chainup.kit.utils.PublicSizeUtil
import com.example.chainup_kit.R
import kotlinx.android.synthetic.main.public_header_kit_layout.view.custom_layout
import kotlinx.android.synthetic.main.public_header_kit_layout.view.tv_title
import kotlinx.android.synthetic.main.public_header_kit_layout.view.v_line

/**
 * Common 6.0 NewVersion Header Kit
 * @property listener Set event listening
 * @property mIsShowRightBtn Sets whether to display the right button
 * @property titleText set title
 * @property setFilterTitleContent The copy that sets the filter title is currently used to filter the currency
 * @property setBackIconGone(isGone:Boolean) Hidden or Not Return icon isGone: Hidden or not
 * @property setContractHeaderTag(@LayoutRes layoutRes:Int)
 * */
open class PublicHeaderKit @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null
) : RelativeLayout(context, attrs) {
    var listener:IOnBackClickListener? = null
    private var mBackBtn: View? = null
    private var mRightBtn:View? = null
    private var mSubRightBtn:View? = null
    private var mSubRightBtn2:View? = null

    private var mTitleView:TextView? = null
    private var pFilterView:LinearLayout? = null

    private var mImgBack:ImageView
    private var mRightBtnImgView:ImageView
    private var mRightBtnTextView:TextView

    private var mSubRightBtnImgView:ImageView
    private var mSubRightBtnTextView:TextView

    private var mTitleImgView:ImageView

    private var mSubRightBtnImgView2:ImageView
    private var mSubRightBtnTextView2:TextView

    private var mChgTag:KKTagKit
    private var mCoinTypeTag:KKTagKit

    private var mFilterTitleView:RelativeLayout
    private var mTitleDownView:ImageView

    private var mRightBtnText:String?
    private var mSubRightBtnText:String?
    private var mSubRightBtnText2:String?

    @DrawableRes
    var mRightBtnRes:Int? = -1
        set(value) {
            field = value
            setRightBtnView()
        }


    @DrawableRes
    private var mTitleImageRes:Int

    @DrawableRes
    private var mSubRightBtnRes:Int

    @DrawableRes
    private var mSubRightBtnRes2:Int

    var mIsShowLeftBtn:Boolean = true
        set(value) {
            field = value
            setLeftBtnView()
        }

    var mIsShowRightBtn:Boolean = false
        set(value) {
            field = value
            setRightBtnView()
        }
    //Is the right sub icon displayed
    private var isShowSubRightBtn:Boolean = false
    private var isShowSubRightBtn2:Boolean = false

    private var mRightBtnType:Int
    private var mSubRightBtnType:Int
    private var mSubRightBtnType2:Int

    //The color of the button text on the right
    private var mRightBtnColor:Int? = null

    var titleText:String? = null
        set(value) {
            field = value
            setTitleContent(value)
        }

    var isShowFilterTitleVisible:Boolean = false
    var isShowTitleDown:Boolean = false
    var isShowChgTag:Boolean = false
    var isShowCoinTypeTag:Boolean = false


    init {
        val typedArray = context.obtainStyledAttributes(attrs, R.styleable.PublicHeaderKit)
        titleText = typedArray.getString(R.styleable.PublicHeaderKit_title)

        mRightBtnText = typedArray.getString(R.styleable.PublicHeaderKit_rightBtnText)
        mSubRightBtnText = typedArray.getString(R.styleable.PublicHeaderKit_subRightBtnText)
        mSubRightBtnText2 = typedArray.getString(R.styleable.PublicHeaderKit_subRightBtnText2)
        //Obtain the icon res on the right side of 2
        mRightBtnRes = typedArray.getResourceId(R.styleable.PublicHeaderKit_rightBtnRes,R.mipmap.public_return)
        mSubRightBtnRes = typedArray.getResourceId(R.styleable.PublicHeaderKit_subRightBtnRes,R.mipmap.public_return)
        mTitleImageRes = typedArray.getResourceId(R.styleable.PublicHeaderKit_titleRes,0)
        mSubRightBtnRes2 = typedArray.getResourceId(R.styleable.PublicHeaderKit_subRightBtnRes2,R.mipmap.public_return)

        mIsShowLeftBtn = typedArray.getBoolean(R.styleable.PublicHeaderKit_isShowLeftBtn,true)

        //Do you want to display the 2 buttons on the right
        mIsShowRightBtn = typedArray.getBoolean(R.styleable.PublicHeaderKit_isShowRightBtn,false)
        isShowSubRightBtn = typedArray.getBoolean(R.styleable.PublicHeaderKit_isShowSubRightBtn,false)
        isShowSubRightBtn2 = typedArray.getBoolean(R.styleable.PublicHeaderKit_isShowSubRightBtn2,false)

        //Default icon
        mRightBtnType = typedArray.getInt(R.styleable.PublicHeaderKit_rightBtnType,1)
        mSubRightBtnType = typedArray.getInt(R.styleable.PublicHeaderKit_subRightBtnType,1)
        mSubRightBtnType2 = typedArray.getInt(R.styleable.PublicHeaderKit_subRightBtnType2,1)

        mRightBtnColor = typedArray.getColor(R.styleable.PublicHeaderKit_rightBtnTextColor,0)
        isShowFilterTitleVisible = typedArray.getBoolean(R.styleable.PublicHeaderKit_filterTitleVisible,false)
        isShowTitleDown = typedArray.getBoolean(R.styleable.PublicHeaderKit_isShowTitleDown,false)
        isShowChgTag = typedArray.getBoolean(R.styleable.PublicHeaderKit_isShowChgTag,false)
        isShowCoinTypeTag = typedArray.getBoolean(R.styleable.PublicHeaderKit_isShowCoinTypeTag,false)

        typedArray.recycle()

        LayoutInflater.from(context).inflate(R.layout.public_header_kit_layout,this,true)
            .apply {
                mBackBtn = findViewById(R.id.public_ic_back)
                mTitleView = findViewById(R.id.public_tx_content)
                mRightBtn = findViewById(R.id.public_ic_btn)
                mSubRightBtn = findViewById(R.id.sub_public_ic_btn)
                mSubRightBtn2 = findViewById(R.id.sub_public_ic_btn2)

                mImgBack = findViewById(R.id.img_back)
                mRightBtnImgView = findViewById(R.id.rightBtnImgView)
                mRightBtnTextView = findViewById(R.id.rightBtnTextView)
                mSubRightBtnImgView = findViewById(R.id.sub_rightBtnImgView)
                mSubRightBtnTextView = findViewById(R.id.sub_rightBtnTextView)
                mSubRightBtnImgView2 = findViewById(R.id.sub_rightBtnImgView2)
                mSubRightBtnTextView2 = findViewById(R.id.sub_rightBtnTextView2)

                mTitleImgView = findViewById(R.id.public_title_img)

                mFilterTitleView = findViewById(R.id.filterTitle)

                mChgTag = findViewById(R.id.chgTag)
                mCoinTypeTag = findViewById(R.id.typeTag)

                pFilterView = findViewById(R.id.parent_filterView)

                mTitleDownView = findViewById(R.id.public_title_down)
            }
        initView()
    }

    private fun initView() {
        mFilterTitleView.visibility = if(isShowFilterTitleVisible) View.VISIBLE else View.GONE
        mTitleDownView.visibility = if(isShowTitleDown) View.VISIBLE else View.GONE
        mChgTag.visibility = if(isShowChgTag) View.VISIBLE else View.GONE
        mCoinTypeTag.visibility = if(isShowCoinTypeTag) View.VISIBLE else View.GONE

        mFilterTitleView.setOnClickListener {
            listener?.onFilterTitle(it)
        }

        setTitleContent(titleText)
        setTitleImage(mTitleImageRes)

        setRightBtnView()

        mRightBtn?.setOnClickListener {
            listener?.onRightBtn(it)
        }
        mSubRightBtn?.setOnClickListener{
            listener?.onSubRightBtn(it)
        }
        mSubRightBtn2?.setOnClickListener {
            listener?.onSubRightBtn(it)
        }
        mTitleView?.setOnClickListener {
            listener?.onTitleClick(it)
        }

        //Click to return
        mBackBtn?.setOnClickListener{

            if(listener?.onBack() == true){
                return@setOnClickListener
            }

            if(context is Activity){
                (context as Activity).finish()
            }
        }
        setLeftBtnView()
    }

    fun setTitleContent(value:String?="") {
        mTitleView?.text = value
    }

    fun setContentTitle(value:String?="") {
        mTitleView?.text = value
    }

    fun setCoinChgValue(value:String?="") {
        mChgTag?.setTagContent(value)
    }

    private fun setTitleImage(linkRes:String?="") {
        if(linkRes?.isEmpty() == true){
            mTitleImgView.visibility= GONE
        }else{
            mTitleImgView.visibility= VISIBLE
            val requestOptions = RequestOptions()
            RequestOptions.bitmapTransform(CircleCrop())
            Glide.with(context).load(linkRes).apply(requestOptions).into(mTitleImgView)
        }
    }

    private fun setTitleImage(idRes:Int) {
        if(idRes==0){
            mTitleImgView.visibility= GONE
        }else{
            mTitleImgView.visibility= VISIBLE
            mTitleImgView.setImageResource(idRes)
        }
    }

    fun setFilterTitleContent(value:String){
//        mFilterTitleView.text = value
        tv_title.text = value
    }

    interface IOnBackClickListener{
        //Click on the callback returned
        fun onBack():Boolean {
            return false
        }
        //Callback clicked on the right button
        fun onRightBtn(view:View){

        }

        fun onFilterTitle(view:View){

        }

        fun onSubRightBtn(view:View){

        }

        fun onTitleClick(view:View){

        }
    }


    private fun setLeftBtnView(){
        setBackIconGone(!mIsShowLeftBtn)
    }

    private fun setRightBtnView(){
        //Right sub btn must be displayed when rightbtn mIsShowRightBtn=true because subbtn depends on mRightBtn layout
        mSubRightBtn?.visibility = if(mIsShowRightBtn && isShowSubRightBtn) VISIBLE else GONE
        mSubRightBtn2?.visibility = if(mIsShowRightBtn && isShowSubRightBtn && isShowSubRightBtn2) VISIBLE else GONE

        mRightBtn?.visibility = if(mIsShowRightBtn) VISIBLE else GONE
        //If the right button is not displayed, all programs that set the right button will end
        if(!mIsShowRightBtn) return

        when(mRightBtnType){
            //icon
            1 -> {
                mRightBtnTextView.visibility = GONE
                mRightBtnImgView.visibility = VISIBLE

                mRightBtnImgView.setImageResource(mRightBtnRes!!)
            }

            //text
            2 -> {
                mRightBtnTextView.visibility = VISIBLE
                mRightBtnImgView.visibility = GONE

                mRightBtnTextView.text = mRightBtnText?:"null"

                if(mRightBtnColor!=0){
                    mRightBtnColor?.let { mRightBtnTextView.setTextColor(it) }
                }

            }
        }


        when(mSubRightBtnType){
            //icon
            1 -> {
                mSubRightBtnTextView.visibility = GONE
                mSubRightBtnImgView.visibility = VISIBLE

                mSubRightBtnImgView.setImageResource(mSubRightBtnRes)
            }

            //text
            2 -> {
                mSubRightBtnTextView.visibility = VISIBLE
                mSubRightBtnImgView.visibility = GONE

                mSubRightBtnTextView.text = mSubRightBtnText?:"null"

                if(mRightBtnColor!=0){
                    mRightBtnColor?.let { mSubRightBtnTextView.setTextColor(it) }
                }

            }
        }


        when(mSubRightBtnType2){
            //icon
            1 -> {
                mSubRightBtnTextView2.visibility = GONE
                mSubRightBtnImgView2.visibility = VISIBLE

                mSubRightBtnImgView2.setImageResource(mSubRightBtnRes)
            }

            //text
            2 -> {
                mSubRightBtnTextView2.visibility = VISIBLE
                mSubRightBtnImgView2.visibility = GONE

                mSubRightBtnTextView2.text = mSubRightBtnText?:"null"

                if(mRightBtnColor!=0){
                    mRightBtnColor?.let { mSubRightBtnTextView2.setTextColor(it) }
                }

            }
        }
    }

    //Whether to hide the return icon
    fun setBackIconGone(isGone:Boolean){
        when(isGone){
            true -> {
                mBackBtn?.visibility = GONE
                if(isShowFilterTitleVisible){
                    v_line.visibility = View.GONE
                    pFilterView?.let {
                        val layoutParams = it.layoutParams as LayoutParams
                        layoutParams.leftMargin = PublicSizeUtil.dp2px(context,16.0f)
                        it.layoutParams = layoutParams
                    }

                }
            }
            false -> {
                mBackBtn?.visibility = VISIBLE
                if(isShowFilterTitleVisible){
                    v_line.visibility = View.VISIBLE
                    pFilterView?.let {
                        val layoutParams = it.layoutParams as LayoutParams
                        layoutParams.leftMargin = 0
                        it.layoutParams = layoutParams
                    }

                }
            }
        }


    }


    //The contract trading homepage needs to dynamically add a tag to display the rise and fall rate, which should be SuperTextView. This broken control kit package is not referenced, and can only dynamically load the contract package
    fun setContractHeaderTag(@LayoutRes layoutRes:Int):View{
        val view = LayoutInflater.from(context).inflate(layoutRes,this,false)
        pFilterView?.addView(view)
        return view
    }

    fun setTvRightText(text:String){
        mRightBtnTextView.text = text
    }

    fun setFilterTitleVisible(visible:Boolean) {
        isShowFilterTitleVisible = visible
        mFilterTitleView.visibility = if(visible) View.VISIBLE else View.GONE
    }

    fun setRightCustomLayout(view:View){
        custom_layout.visibility = View.VISIBLE
        custom_layout.removeAllViews()
        isShowSubRightBtn2 = false
        isShowSubRightBtn = false
        mIsShowRightBtn = false
        custom_layout.addView(view)
    }

    fun setLeftImg(img:Int){
        mImgBack.setImageResource(img)
    }

     fun setRightIconGone(isGone:Boolean){
         mRightBtn?.visibility=if(!isGone) View.VISIBLE else View.GONE
//         mSubRightBtn?.visibility=if(!isGone) View.VISIBLE else View.GONE
//         mSubRightBtn2?.visibility=if(!isGone) View.VISIBLE else View.GONE
    }

}
