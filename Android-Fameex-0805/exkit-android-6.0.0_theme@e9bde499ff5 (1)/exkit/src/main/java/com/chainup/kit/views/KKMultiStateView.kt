package com.chainup.kit.views

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ObjectAnimator
import android.content.Context
import android.content.res.TypedArray
import android.graphics.ColorFilter
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.annotation.LayoutRes
import androidx.annotation.StyleableRes
import androidx.core.content.ContextCompat
import com.airbnb.lottie.LottieAnimationView
import com.airbnb.lottie.LottieProperty
import com.airbnb.lottie.SimpleColorFilter
import com.airbnb.lottie.model.KeyPath
import com.airbnb.lottie.value.LottieValueCallback
import com.example.chainup_kit.R
import kotlinx.android.synthetic.main.layout_neterror_def.view.kk_no_network_retry_btn
import kotlinx.android.synthetic.main.layout_neterror_def.view.tv_kk_exception_message
import kotlinx.android.synthetic.main.public_layout_empty_view.view.tv_kk_empty_title

class KKMultiStateView
@JvmOverloads
constructor(context: Context, attrs: AttributeSet? = null, defStyle: Int = 0) :
    FrameLayout(context, attrs, defStyle) {

    /**
     * StateEnumeration
     */
    enum class ViewState {
        CONTENT,
        LOADING,
        EMPTY,
        NET_ERROR
    }

    /**
     * statusMonitoringBeforeChanging
     *
     * @return true Will continue to change state false, will not continue to change state, state will still be oldState
     */
    var stateBeforeChangeListener: ((oldState: ViewState, newState: ViewState) -> Boolean)? = null

    /**
     * State monitoring, after the change, the state has been changed to newState
     */
    var stateAfterChangeListener: ((oldState: ViewState, newState: ViewState) -> Unit)? = null

    var retryClickListener:OnClickListener? = null
        set(value) {
            if(field==null && value!=null && kk_no_network_retry_btn!=null){
                kk_no_network_retry_btn.setOnClickListener(value)
                field = value
            }
        }
    /**
       *Store views in different states
    *Directly locate the index of the internal array based on enum
     */
    private val views = Array<View?>(ViewState.values().size) { null }

    /**
     * switchingAnimationSwitches
     */
    var enableAnimateLayoutChanges: Boolean = false

    /**
     * currentStateSettings
     */
    var currentState = ViewState.CONTENT
        set(value) {
            val previewState = field
            if (value != previewState) {
                field = value
                if (stateBeforeChangeListener?.invoke(previewState, value) != false) {
                    //根据状态进行view显示
                    showViewByState(previewState)

                    stateAfterChangeListener?.invoke(previewState, value)
                }
            }
        }

    init {
        //initializeTheLayoutOfTheConfiguration
        val typeArray = context.obtainStyledAttributes(attrs, R.styleable.KKMultiStateView)
        val layoutInflater = LayoutInflater.from(context)

        //LOADING布局
        defaultLayoutInflater(
            ViewState.LOADING,
            R.layout.layout_loading_def,
            layoutInflater
        )
        //EMPTY布局
        defaultLayoutInflater(
            ViewState.EMPTY,
            R.layout.public_layout_empty_view,
            layoutInflater
        )
        //NET_ERROR布局
        defaultLayoutInflater(
            ViewState.NET_ERROR,
            R.layout.layout_neterror_def,
            layoutInflater
        )

        for (i in views.indices) {
            views[i]?.visibility = View.GONE
        }
        //获取并设置默认的viewState 若无默认设置则为 ViewState.CONTENT
        currentState = when (typeArray.getInt(
            R.styleable.KKMultiStateView_msv_currentViewState,
            ViewState.CONTENT.ordinal
        )) {
            ViewState.CONTENT.ordinal -> ViewState.CONTENT
            ViewState.LOADING.ordinal -> ViewState.LOADING
            ViewState.EMPTY.ordinal -> ViewState.EMPTY
            ViewState.NET_ERROR.ordinal -> ViewState.NET_ERROR
            else -> ViewState.CONTENT
        }
        //切换动画开关
        enableAnimateLayoutChanges =
            typeArray.getBoolean(R.styleable.KKMultiStateView_msv_enableAnimateChanges, false)

        typeArray.recycle()

    }

    /**
     * 添加view通过state
     * @param layoutRes 被添加的layoutRes
     * @param state ViewState
     * @param switchToState 是否需要直接展示
     */
    fun addViewForState(
        @LayoutRes layoutRes: Int,
        state: ViewState,
        switchToState: Boolean = false
    ) {
        val view = LayoutInflater.from(context).inflate(layoutRes, this, false)
        addViewByViewState(view, state, switchToState)
    }

    /**
     * 添加view通过state
     * @param view 被添加的view
     * @param state ViewState
     * @param isImmediatelyShow 是否需要直接展示
     */
    private fun addViewByViewState(
        view: View,
        state: ViewState,
        isImmediatelyShow: Boolean = false
    ) {
        //如果之前存在view，且不为null，则先移除
        obtainView(state)?.let {
            removeView(view)
        }
        //持有添加
        views[state.ordinal] = view
        addView(view)
        //如果当前添加的view，需要立即展示，则设置状态即可
        if (isImmediatelyShow) currentState = state
    }

    /**
     * 根据状态获取view
     * @param state ViewsTate
     */
    fun obtainView(state: ViewState): View? = views[state.ordinal]

    /**
     * 根据state显示相关的view
     * @param state View状态
     */
    private fun showViewByState(previousState: ViewState) {
        if (enableAnimateLayoutChanges) {
            //其他View全部隐藏
            for (i in views.indices) {
                if (i != currentState.ordinal && i != previousState.ordinal) {
                    views[i]?.visibility = View.GONE
                }
            }
            //使用animate执行previousView与currentView的切换
            animateView(obtainView(previousState))
            return
        }
        //不执行动画
        for (i in views.indices) {
            if (i == currentState.ordinal) {
                views[i]?.visibility = View.VISIBLE
            } else {
                views[i]?.visibility = View.GONE
            }
        }
    }

    /**
     * 动画执行隐藏显示
     * @param view view
     */
    private fun animateView(previousView: View?) {
        if (previousView == null) {
            obtainView(currentState)?.let { it.visibility = View.VISIBLE }
                ?: throw IllegalStateException("当前状态的view不能为null")
            return
        }
        val animateDuration = 200L
        ObjectAnimator.ofFloat(previousView, "alpha", 1.0F, 0.0F).apply {
            duration = animateDuration
            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationStart(animation: Animator?) {
                    previousView.visibility = View.VISIBLE
                }

                override fun onAnimationEnd(animation: Animator?) {
                    previousView.visibility = View.GONE
                    obtainView(currentState)?.let {
                        //当前View显示
                        it.visibility = View.VISIBLE
                        ObjectAnimator.ofFloat(it, "alpha", 0.0F, 1.0F)
                            .apply { duration = animateDuration }.start()
                    } ?: throw IllegalStateException("当前状态的view不能为null")
                }
            })
        }.start()
    }

    /**
     * 默认布局填充
     */
    private fun defaultLayoutInflater(
        state: ViewState,
        @LayoutRes layoutRes:Int,
        layoutInflater: LayoutInflater
    ) {
        val contentView = layoutInflater.inflate(layoutRes, this, false)
        //不为空，先赋值到数组，并且加入布局
        views[state.ordinal] = contentView
        if(state==ViewState.LOADING){
            val lottieView: LottieAnimationView = contentView.findViewById(R.id.kk_lottie_view)
            lottieView.addLottieOnCompositionLoadedListener {
                val list = lottieView.resolveKeyPath(KeyPath("**"))
                for (path in list) {
                    Log.d("LottieKeyPath", path.keysToString())
                }
                val keyPath1 = KeyPath("转动", "椭圆 1", "描边 1", " 椭圆路径1")
                val colorCallback = LottieValueCallback<ColorFilter>()
                colorCallback.setValue(
                    SimpleColorFilter(
                        ContextCompat.getColor(
                            context,
                            R.color.text_1
                        )
                    )
                )
                lottieView.addValueCallback(
                    KeyPath("**"),
                    LottieProperty.COLOR_FILTER,
                    colorCallback
                )
            }
            lottieView.cancelAnimation()
            lottieView.setAnimation("loading_btn_black.json")
            lottieView.speed = 1.4f
            lottieView.playAnimation()
        }
        addView(contentView)
    }

    /**
     * 判断如果不是ViewState中除了contentView以外定义的View，将此view默认设置为contentView
     */
    private fun checkContentView(view: View?) {
        val localView = views
        // 如果contentView为null，且将要add的view不等于其他view，则将其默认赋值给contentview
        if (obtainView(ViewState.CONTENT) == null) {
            var flag = true
            for (index in localView.indices) {
                if (localView[index] == view) {
                    flag = false
                    break
                }
            }
            if (flag) {
                localView[ViewState.CONTENT.ordinal] = view
                if (currentState != ViewState.CONTENT) {
                    obtainView(ViewState.CONTENT)?.visibility = View.GONE
                }
            }
        }

    }


    /**
     * 不建议外部直接使用addView进行视图的添加，而应该使用{@link MultiStateView#addViewByViewState}
     */
    override fun addView(child: View?, index: Int, params: ViewGroup.LayoutParams?) {
        checkContentView(child)
        super.addView(child, index, params)
    }

    override fun addView(child: View?, width: Int, height: Int) {
        checkContentView(child)
        super.addView(child, width, height)
    }

    override fun addViewInLayout(
        child: View?,
        index: Int,
        params: ViewGroup.LayoutParams?,
        preventRequestLayout: Boolean
    ): Boolean {
        checkContentView(child)
        return super.addViewInLayout(child, index, params, preventRequestLayout)
    }

    fun setMessageText(emptyMessage:String? = null,exceptionMessage:String? = null,btnMessage:String?=null){
        if(emptyMessage!=null) tv_kk_empty_title.text = emptyMessage
        if(exceptionMessage!=null) tv_kk_exception_message.text = exceptionMessage
        if(btnMessage!=null) kk_no_network_retry_btn.textContent = btnMessage
    }



}

fun KKMultiStateView.loading() {
    this.currentState = KKMultiStateView.ViewState.LOADING
}
fun KKMultiStateView.finish() {
    this.currentState = KKMultiStateView.ViewState.CONTENT
}
fun KKMultiStateView.empty() {
    this.currentState = KKMultiStateView.ViewState.EMPTY
}
fun KKMultiStateView.exception() {
    this.currentState = KKMultiStateView.ViewState.NET_ERROR
}
fun KKMultiStateView.isException():Boolean {
    return this.currentState == KKMultiStateView.ViewState.NET_ERROR
}