package com.yjkj.chainup.base

import android.app.Activity
import android.content.Context
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import android.content.res.Resources
import android.os.Build
import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import androidx.annotation.ColorInt
import androidx.annotation.ColorRes
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatDelegate
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import com.alibaba.android.arouter.launcher.ARouter
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.kit.dialog.KKLoadingDialog
import com.jaeger.library.StatusBarUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.push.ActivityCollector
import com.yjkj.chainup.model.model.*
import com.yjkj.chainup.new_version.activity.NewMainActivity
import com.yjkj.chainup.new_version.activity.SplashActivity
import com.yjkj.chainup.new_version.view.ForegroundCallbacksListener
import com.yjkj.chainup.new_version.view.ForegroundCallbacksObserver
import com.yjkj.chainup.util.*
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import java.lang.reflect.Method


/**
 *

 * @Description:

 * @Author:         wanghao

 * @CreateDate:     2019-07-31 11:29

 * @UpdateUser:     wanghao

 * @UpdateDate 2023-07-31 11:29

 *@ UpdateRemark: Update Description

 */

abstract class NBaseActivity : AppCompatActivity(), View.OnClickListener {

    open val TAG = this::class.java.simpleName

    private val STAG = "SHOWACTIVITY"

    val MARKET_NAME = "market_name"
    val CUR_INDEX = "cur_index"
    val CUR_TYPE = "cur_type"

    var mActivity: FragmentActivity = this
    var mContext: ChainUpApp? = null

    var layoutView: View? = null
    var mInflater: LayoutInflater? = null
    var isLandscape = false

    var isFirstInit:Boolean = true


    // var mHeadView: HeadView?=null
    abstract fun setContentView(): Int

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (this.javaClass.simpleName != SplashActivity::class.simpleName && this.javaClass.simpleName != NewMainActivity::class.simpleName) {
            ARouter.getInstance().inject(this)
        }
        EventBusUtil.register(this)
        mActivity = this
        if (Build.VERSION.SDK_INT >= 26) {
//            convertActivityFromTranslucent(mActivity)
        }
        mContext = mActivity.application as ChainUpApp
        mInflater = LayoutInflater.from(this)
        setBarColor(PublicInfoDataService.getInstance().themeMode)
        if (!isLandscape) {
            requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        }
        ActivityCollector.addActivity(this, javaClass)
        setStatusBarColor(R.color.bg_card_color)

        //Adapt to Navigation Bar
        window.navigationBarColor = ContextCompat.getColor(this,R.color.bg_card_color)
        UIUtils.setLightNavigationBar(
            this,
            if(PublicInfoDataService.getInstance().themeModeNew.equals("day")){
                0
            }else{
                1
            }
        )


        onInit(savedInstanceState)
        setForegroundCallbacks()
    }

    override fun onNightModeChanged(mode: Int) {
        super.onNightModeChanged(mode)
        
    }

    fun setForegroundCallbacks() {
        ForegroundCallbacksObserver.getInstance().addListener(listener)
    }

    var listener = object : ForegroundCallbacksListener {
        override fun BackgroundListener() {
            background()
        }

        override fun ForegroundListener() {
            foreground()
        }

        override fun appBackChange(visible: Boolean) {

        }
    }

    /**
     *Entering the backend
     */
    open fun background() {

    }

    /**
     *Enter the front desk
     */
    open fun foreground() {

    }


    open fun onInit(savedInstanceState: Bundle?) {
        layoutView = mInflater?.inflate(setContentView(), null)
        DisplayUtil.setDefaultDisplay(this)
        setContentView(layoutView)
        layoutView?.fitsSystemWindows = true
        // mHeadView = HeadView(layoutView)
    }

    /**
     *Dealing with the issue of forced vertical screen crashes in systems above 8.0
     */
    fun convertActivityFromTranslucent(activity: Activity) {
        try {
            var method: Method = Activity::class.java.getDeclaredMethod("convertFromTranslucent")
            method.isAccessible = true
            method.invoke(activity)
        } catch (t: Throwable) {
        }
    }


    /*
     *To maintain the Programming style, it is better to overload the subclass when it involves data requests
     */
    open fun loadData() {}

    /*
     *In order to keep the Programming style unified, it is recommended that subclasses be overloaded
     */
    open fun initView() {

    }


    /*
     *Set Full Screen
     */
    fun setFullScreen() {
        this.window.setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )
    }

    /*
     *The return button in the upper left corner of the page exits event processing, and subclasses can be overloaded
     */
    override fun onClick(view: View) {

    }

    /*
     *The processing thread is consistent with the message sending thread
     *Subclass overload
     */
    @Subscribe(threadMode = ThreadMode.POSTING)
    open fun onMessageEvent(event: MessageEvent) {
        if (event.getMsg_type() == MessageEvent.data_req_error) {

        }
    }

    /*
        *The processing thread is consistent with the message sending thread
        *Subclass overload
        */
    @Subscribe(threadMode = ThreadMode.POSTING)
    open fun onCpMessageEvent(event: CpMessageEvent) {

    }

    /*
     *Viscous event handling
     *After subclass overloading and processing the event, EventBusUtil. removeStickyEvent (event) needs to be called;
     */
    @Subscribe(threadMode = ThreadMode.POSTING, sticky = true)
    open fun onMessageStickyEvent(event: MessageEvent) {

    }


    /*
     *Add Observer
     */
    var disposables: CompositeDisposable? = null

    fun addDisposable(disposable: Disposable?) {
        if (null == disposable)
            return
        if (disposables == null) {
            disposables = CompositeDisposable()
        }
        disposables!!.add(disposable)
    }

    /*
     *Log off observers to prevent Memory leak
     */
    fun clearDisposable() {
        disposables?.clear()
        disposables = null
    }

    private var mainModel: MainModel? = null
    protected fun getMainModel() = mainModel ?: MainModel()


    private var speedModel: SpeedModel? = null
    protected fun getSpeedModel() = speedModel ?: SpeedModel()

    private var redPackageModel: RedPackageModel? = null
    protected fun getRedPackageModel() = redPackageModel ?: RedPackageModel()

    private var otcModel: OTCModel? = null
    protected fun getOTCModel() = otcModel ?: OTCModel()

    private var assetModel: AssetModel? = null
    protected fun getAssetModel() = assetModel ?: AssetModel()


    private var contractModelNet: ContractModel? = null
    protected fun getContractModelOld() = contractModelNet ?: ContractModel()

    private var contractModel: NewContractModel? = null
    protected fun getContractModel() = contractModel ?: NewContractModel()


    private var mLoadingDialog: KKLoadingDialog? = null
    protected fun showLoadingDialog() {
        if (null == mLoadingDialog) {
            mLoadingDialog = KKLoadingDialog(mActivity)
        }
        try {
            mLoadingDialog?.showLoadingDialog()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    protected fun closeLoadingDialog() {
        if (mLoadingDialog != null) {
            mLoadingDialog?.closeLoadingDialog()
            mLoadingDialog = null
        }

    }

    fun showSnackBar(msg: String?, isSuc: Boolean = true) {
        NToastUtil.showTopToastNet(this, isSuc, msg)
    }


    /**
     *The page enters from the right side
     */
    private val WINDOW_EXIT_ANIM_MODE_RIGHT_OUT = 0x110
    private val WINDOW_EXIT_ANIM_MODE_BOTTOM_OUT = 0x111
    private val WINDOW_EXIT_ANIM_MODE_LEFT_OUT = 0x112
    private var currentWindowTransitionMode = -1

    protected fun windowTransitionRightInRightOut() {
        overridePendingTransition(R.anim.slide_right_in, R.anim.slide_left_out)
        currentWindowTransitionMode = WINDOW_EXIT_ANIM_MODE_RIGHT_OUT
    }

    protected fun windowTransitionBottomInBottomOut() {
        overridePendingTransition(R.anim.slide_down_in, R.anim.activity_stay)
        currentWindowTransitionMode = WINDOW_EXIT_ANIM_MODE_BOTTOM_OUT
    }

    protected fun windowTransitionLeftInRightOut() {
        overridePendingTransition(R.anim.sl_slide_left_in, R.anim.anim_no)
        currentWindowTransitionMode = WINDOW_EXIT_ANIM_MODE_LEFT_OUT
    }

    override fun onPause() {
        super.onPause()
        isFirstInit = false
        closeLoadingDialog()
    }

    override fun finish() {
        super.finish()
        if (currentWindowTransitionMode == WINDOW_EXIT_ANIM_MODE_RIGHT_OUT) {
            overridePendingTransition(R.anim.slide_left_in, R.anim.slide_right_out)
        } else if (currentWindowTransitionMode == WINDOW_EXIT_ANIM_MODE_BOTTOM_OUT) {
            overridePendingTransition(0, R.anim.slide_down_out)
        } else if (currentWindowTransitionMode == WINDOW_EXIT_ANIM_MODE_LEFT_OUT) {
            overridePendingTransition(R.anim.anim_no, R.anim.sl_slide_left_out)
        }
    }

    public override fun onDestroy() {
        super.onDestroy()
        EventBusUtil.unregister(this)
        clearDisposable()
        closeLoadingDialog()
        ForegroundCallbacksObserver.getInstance().removeListener(listener)
        ActivityCollector.removeActivity(this)
    }

    override fun attachBaseContext(newBase: Context?) {
        super.attachBaseContext(LocalManageUtil.setLocal(newBase))
    }


    fun isNotEmpty(str: String?): Boolean {
        return !isEmpty(str)
    }

    fun isEmpty(str: String?): Boolean {
        return TextUtils.isEmpty(str)
    }

    /**
     *Set the color of the status bar
     *@param 0 is daytime mode, and the status bar is white with black characters. 1 is Light-on-dark color scheme, and the status bar is black with white characters
     */
    fun setBarColor(index: Int) {
        when (index) {
            0 -> {
                StatusBarUtil.setLightMode(this)
            }
            1 -> {
                StatusBarUtil.setDarkMode(this)
            }

        }
    }

    fun setStatusBarColor(@ColorRes color:Int){
        StatusBarUtil.setColor(this, ContextCompat.getColor(this,color), 0)
    }
    fun setBgCardBar(){
        StatusBarUtil.setColor(this, ContextCompat.getColor(this,R.color.bg_card_color), 0)
    }

    fun setBgSearchBar(){
        StatusBarUtil.setColor(this, ContextCompat.getColor(this,R.color.bg_search_color), 0)
    }

    fun setBgFill2(){
        StatusBarUtil.setColor(this, ContextCompat.getColor(this,R.color.fill_2), 0)
    }


    override fun getResources(): Resources {
        val resources = super.getResources()
        val configuration = Configuration()
        configuration.setToDefaults()
        resources.updateConfiguration(configuration, resources.displayMetrics)
        return resources
    }

}
