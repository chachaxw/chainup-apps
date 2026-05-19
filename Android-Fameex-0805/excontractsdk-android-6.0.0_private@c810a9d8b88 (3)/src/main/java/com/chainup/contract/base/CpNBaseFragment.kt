package com.chainup.contract.base

import android.app.Activity
import android.content.Context
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.blankj.utilcode.util.LogUtils
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent
import com.chainup.contract.listener.CpForegroundCallbacks
import com.chainup.contract.listener.CpForegroundCallbacksListener
import com.chainup.contract.listener.CpForegroundCallbacksObserver
import com.chainup.contract.model.CpNewContractModel
import com.chainup.contract.utils.ChainUpLogUtil
import com.chainup.kit.dialog.KKLoadingDialog


import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode

/**
 *

 * @Description:

 * @Author:         wanghao

 * @CreateDate:     2019-07-31 11:56

 * @UpdateUser:     wanghao

 * @UpdateDate:     2019-07-31 11:56

 * @UpdateRemark:   updateDescription

 */

abstract class CpNBaseFragment : Fragment() {

    val TAG = this::class.java.simpleName

    val MARKET_NAME = "market_name"
    val CUR_INDEX = "cur_index"
    val CUR_TYPE = "cur_type"


    var isFirstLoad = false

    protected var layoutView: View? = null

    protected var mActivity: Activity? = null

    override fun onAttach(context: Context) {
        super.onAttach(context)
        mActivity = context as Activity
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        if (null == layoutView) {
            isFirstLoad = true

            layoutView = inflater.inflate(setContentView(), container, false)
            loadData()

        } else {
            var viewGroup = layoutView?.parent as ViewGroup?
            viewGroup?.removeView(layoutView)
        }
        return layoutView
    }


    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        CpEventBusUtil.register(this)
        initView()
        setForegroundCallbacks()
        //Trigger onVisibleChanged if loaded for the first time
        if(isFirstLoad) onVisibleChanged(isVisibleOnScreen())
    }


    fun setForegroundCallbacks() {
        CpForegroundCallbacksObserver.getInstance().addListener(listener)
    }

    var listener = object : CpForegroundCallbacksListener {
        override fun BackgroundListener() {
            background()
        }

        override fun ForegroundListener() {
            foreground()
        }

        override fun appBackChange(visible: Boolean) {
            appBackGroundChange(visible)
        }
    }

    open fun background() {

    }

    open fun foreground() {

    }

    open fun appBackGroundChange(isVisible: Boolean) {

    }

    /**
     *Refresh Interface
     */
    open fun refreshOkhttp(position: Int) {

    }

    var isCanShowing = true
    override fun onResume() {
        super.onResume()
        isCanShowing = isVisible
        if (userVisibleHint) {
            LogUtils.e("onResume"+userVisibleHint)
            fragmentVisibile(true)
            /*var fgs = fragmentManager?.fragments
            LogUtil.d("setOnScrowListener", "NBaseFragment==onResume==userVisibleHint is $userVisibleHint，isVisible is $isVisible,fgs is $fgs")
            if(null!=fgs){
                for(i in 0 until fgs.size  ){
                    var fg = fgs[i]
                    LogUtil.d("setOnScrowListener", "NBaseFragment==onResume==userVisibleHint is $userVisibleHint，isVisible is $isVisible,fg is $fg,this is $this")

                    if(null!=fg && fg == this){

                    }
                }
            }*/
            //
        }
    }

    override fun onPause() {
        super.onPause()
        isFirstLoad = false
        if (userVisibleHint) {
            LogUtils.e("onPause"+userVisibleHint)
            ChainUpLogUtil.d("setOnScrowListener", "NBaseFragment==onPause==userVisibleHint is $userVisibleHint")
            fragmentVisibile(false)
        }

        closeLoadingDialog()
        clearDisposable()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        CpEventBusUtil.unregister(this)
        CpForegroundCallbacksObserver.getInstance().removeListener(listener)
    }

    override fun setUserVisibleHint(isVisibleToUser: Boolean) {
        if (isVisibleToUser && null != layoutView && isResumed) {
            super.setUserVisibleHint(true)
        } else {
            super.setUserVisibleHint(false)
        }
        LogUtils.e("setUserVisibleHint"+userVisibleHint)
        fragmentVisibile(userVisibleHint)
        isCanShowing = isVisibleToUser
        onVisibleChanged(isVisibleOnScreen())
    }

    override fun onStop() {
        super.onStop()
        isCanShowing = false
    }

    override fun onHiddenChanged(hidden: Boolean) {
        super.onHiddenChanged(hidden)
        isCanShowing = !hidden
        fragmentVisibile(!hidden)
        LogUtils.e("onHiddenChanged"+hidden)

        onVisibleChanged(isVisibleOnScreen())
    }

    open fun onVisibleChanged(isVisible: Boolean) {
        if(isVisible){
            CpForegroundCallbacks.get().activityChange(this)
        }
    }

    /*
     *This method handles view display, or view binding data
     */
    abstract fun initView()

    /*
     *Data requests, it is recommended to overload to maintain a uniform code style
     */
    open fun loadData() {}

    /*
     *Load Layout File
     */
    protected abstract fun setContentView(): Int

    /*
     *Displaying and Hiding Fragments
     *@param isVisibleToUser true is visible, otherwise it is not visible
     */
    open var mIsVisibleToUser = false

    open fun fragmentVisibile(isVisibleToUser: Boolean) {
        mIsVisibleToUser = isVisibleToUser
    }

    /*
     *The processing thread is consistent with the message sending thread
     *Subclass overload
     */
    @Subscribe(threadMode = ThreadMode.POSTING)
    open fun onMessageEvent(event: CpMessageEvent) {
    }

    /*
     *Viscous event handling
     *After subclass overloading completes processing the event, it is necessary to call EventBusUtil. removeStickyEvent (event);
     */
    @Subscribe(threadMode = ThreadMode.POSTING, sticky = true)
    open fun onMessageStickyEvent(event: CpMessageEvent) {
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
     *Log off observers to prevent memory leaks
     */
    fun clearDisposable() {
        disposables?.clear()
        disposables = null
    }

    /*
    *Add Observer
    */
    var disposablesTrade: CompositeDisposable? = null

    fun addDisposableTrade(disposable: Disposable?) {
        if (null == disposable)
            return
        if (disposablesTrade == null) {
            disposablesTrade = CompositeDisposable()
        }
        disposablesTrade!!.add(disposable)
    }

    /*
     *Log off observers to prevent memory leaks
     */
    fun clearDisposableTrade() {
        disposablesTrade?.clear()
        disposablesTrade = null
    }

    private var contractModel: CpNewContractModel? = null
    protected fun getContractModel() = contractModel ?: CpNewContractModel()


    private var mLoadingDialog: KKLoadingDialog? = null
    protected fun showLoadingDialog(loadText: String = "") {
        if (mActivity != null && mActivity?.isFinishing == false) {
            if (null == mLoadingDialog) {
                mLoadingDialog = KKLoadingDialog(
                    mActivity,
                    loadText
                )
            } else {
                mLoadingDialog?.setLoadText(loadText)
            }
            mLoadingDialog?.showLoadingDialog()
        }
    }

    protected fun closeLoadingDialog() {
        mLoadingDialog?.closeLoadingDialog()
        mLoadingDialog = null
    }

    fun isVisibleOnScreen(): Boolean {
        if (isCanShowing && userVisibleHint && isVisible) {
            val parentFragment = parentFragment
            if (parentFragment == null) {
                return true
            }

            if (parentFragment is CpNBaseFragment) {
                return parentFragment.isVisibleOnScreen()
            } else {
                return parentFragment.isVisible
            }
        }
        return false
    }

}
