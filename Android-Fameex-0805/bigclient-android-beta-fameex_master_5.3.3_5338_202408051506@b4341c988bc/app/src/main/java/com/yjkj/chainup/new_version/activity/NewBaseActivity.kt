package com.yjkj.chainup.new_version.activity

import android.app.Activity
import android.app.ProgressDialog
import android.content.Context
import android.content.pm.ActivityInfo
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.text.TextUtils
import android.util.Log
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.WindowManager
import android.view.animation.AnimationUtils
import android.widget.ImageView
import androidx.core.content.ContextCompat
import com.chainup.kit.dialog.KKLoadingDialog
import com.jaeger.library.StatusBarUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.util.LocalManageUtil
import com.yjkj.chainup.util.NToastUtil
import com.yjkj.chainup.util.ToastUtils
import com.yjkj.chainup.util.UIUtils
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import java.lang.reflect.Method

open class NewBaseActivity : AppCompatActivity() {
    val TAG = this::class.java.simpleName
    lateinit var context: Context
    private var mProgressDialog: ProgressDialog? = null
    private var mLoadingDialog: KKLoadingDialog? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        context = this
        if (Build.VERSION.SDK_INT >= 26) {
            convertActivityFromTranslucent(this)
        }
        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        /**
         *Temporarily adjust the color of the status bar to black
         *Set setDarkMode to white
         */
        setBarColor(PublicInfoDataService.getInstance().themeMode)
        EventBusUtil.register(this)
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
    }
    fun setBgFill2(){
        StatusBarUtil.setColor(this, ContextCompat.getColor(this,R.color.fill_2), 0)
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

    private fun transparentStatusBar(activity: Activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            activity.window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
            activity.window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
            activity.window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
            activity.window.statusBarColor = Color.TRANSPARENT
        } else {
            activity.window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
        }
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

    fun printLogcat(msg: String?) {
        if (!TextUtils.isEmpty(msg)) {
            
        }
    }

    fun showToast(msg: String) {
        if (!TextUtils.isEmpty(msg)) {
            ToastUtils.showToast(msg)
        }
    }

    var listener: TitleShowListener? = null

    fun showProgressDialog(msg: String = "") {
//        var msg = msg
//        if (isFinishing || isDestroyed) {
//            return
//        }
//        if (mProgressDialog == null) {
//            mProgressDialog = ProgressDialog(this, R.style.progressDialog)
//            mProgressDialog?.setCancelable(true)
//        }
//
//        val progressLayout = LayoutInflater.from(baseContext).inflate(R.layout.ly_progress_dialog, null)
//        val ivProgress = progressLayout.findViewById<ImageView>(R.id.iv_progress)
//
//        val animation = AnimationUtils.loadAnimation(baseContext, R.anim.anim_progress)
//        progressLayout.startAnimation(animation)
//
//
//        if (TextUtils.isEmpty(msg)) {
//            msg = LanguageUtil.getString(this, "common_text_refreshing")
//        }
//        mProgressDialog?.setMessage(msg)
//        mProgressDialog?.show()
//        mProgressDialog?.setContentView(progressLayout)
        showLoadingDialog()
    }


    fun cancelProgressDialog() {
//        if (!isDestroyed && !isFinishing && mProgressDialog != null && mProgressDialog!!.isShowing) {
//            mProgressDialog?.cancel()
//            mProgressDialog?.dismiss()
//        }
        closeLoadingDialog()
    }

    fun showLoadingDialog() {
        if (null == mLoadingDialog) {
            mLoadingDialog = KKLoadingDialog(this)
        }
        try {
            mLoadingDialog?.showLoadingDialog()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun closeLoadingDialog() {
        if (mLoadingDialog != null) {
            mLoadingDialog?.closeLoadingDialog()
            mLoadingDialog = null
        }

    }


    fun showSnackBar(msg: String?, isSuc: Boolean = true) {
        NToastUtil.showTopToastNet(this, isSuc, msg)
    }


    override fun attachBaseContext(newBase: Context?) {
        super.attachBaseContext(LocalManageUtil.setLocal(newBase))
    }


    override fun onDestroy() {
        super.onDestroy()
        if (EventBus.getDefault().isRegistered(this)) {
            EventBus.getDefault().unregister(this)
        }

        cancelProgressDialog()
    }

    var y1 = 0f
    var y2 = 0f

    override fun onTouchEvent(event: MotionEvent?): Boolean {
        if (event?.action == MotionEvent.ACTION_DOWN) {
            y1 = event.y
        }

        if (event?.action == MotionEvent.ACTION_MOVE) {
            y2 = event.y
            if (y1 - y2 > 50) {
                if (listener != null) {
                    listener?.TopAndBottom(false)
                }
            } else if (y2 - y1 > 50) {
                if (listener != null) {
                    listener?.TopAndBottom(true)
                }
            }
        }
        return super.onTouchEvent(event)
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

}

