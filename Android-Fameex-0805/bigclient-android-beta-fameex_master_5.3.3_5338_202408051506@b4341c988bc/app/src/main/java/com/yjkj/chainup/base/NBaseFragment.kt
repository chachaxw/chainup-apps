package com.yjkj.chainup.base

import android.app.Activity
import android.content.Context
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import com.chainup.kit.dialog.KKLoadingDialog

import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.extra_service.eventbus.EventBusUtil
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.model.model.ContractModel
import com.yjkj.chainup.model.model.MainModel
import com.yjkj.chainup.model.model.NewContractModel
import com.yjkj.chainup.model.model.OTCModel
import com.yjkj.chainup.new_version.view.ForegroundCallbacksListener
import com.yjkj.chainup.new_version.view.ForegroundCallbacksObserver
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.wedegit.ForegroundCallbacks
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

 * @UpdateDate 2023-07-31 11:56

 *@ UpdateRemark: Update Description

 */

abstract class NBaseFragment : Fragment() {

    val TAG = this::class.java.simpleName

    val MARKET_NAME = "market_name"
    val CUR_INDEX = "cur_index"
    val CUR_TYPE = "cur_type"


    var isFirstLoad = false
    var isFirstInflater = true
    protected var layoutView: View? = null

    protected var mActivity: Activity? = null
    protected var mContext: ChainUpApp? = null

    override fun onAttach(context: Context) {
        super.onAttach(context)
        mActivity = context as Activity
        mContext = mActivity?.application as ChainUpApp
        mIsVisibleToUser = true
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
        EventBusUtil.register(this)
        initView()
        setForegroundCallbacks()
        //If onVisibleChanged is triggered the same as the first load
        if(isFirstLoad) onVisibleChanged(isVisibleOnScreen())
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
            LogUtil.d("setOnScrowListener", "NBaseFragment==onPause==userVisibleHint is $userVisibleHint")
            fragmentVisibile(false)
        }

        closeLoadingDialog()
        clearDisposable()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        isFirstInflater = true
        EventBusUtil.unregister(this)
        ForegroundCallbacksObserver.getInstance().removeListener(listener)
    }

    override fun setUserVisibleHint(isVisibleToUser: Boolean) {
        if (isVisibleToUser && null != layoutView && isResumed) {
            super.setUserVisibleHint(true)
        } else {
            super.setUserVisibleHint(false)
        }
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
        onVisibleChanged(isVisibleOnScreen())
    }

    open fun onVisibleChanged(isVisible: Boolean) {
        if(isVisible){
            ForegroundCallbacks.get().activityChange(this)
        }
    }

    /*
     *This method handles view display or view binding data
     */
    abstract fun initView()

    /*
     *Data request. It is recommended to overload and keep the Programming style unified
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
    open fun onMessageEvent(event: MessageEvent) {
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
     *Log off observers to prevent Memory leak
     */
    fun clearDisposableTrade() {
        disposablesTrade?.clear()
        disposablesTrade = null
    }

    private var mainModel: MainModel? = null
    protected fun getMainModel(): MainModel {
        if (null == mainModel) {
            mainModel = MainModel()
        }
        return mainModel!!
    }

    private var otcModel: OTCModel? = null

    protected fun getOTCModel(): OTCModel {
        if (null == otcModel) {
            otcModel = OTCModel()
        }
        return otcModel ?: OTCModel()
    }

    private var contractModelNet: ContractModel? = null
    protected fun getContractModelOld() = contractModelNet ?: ContractModel()

    private var contractModel: NewContractModel? = null
    protected fun getContractModel() = contractModel ?: NewContractModel()


    private var mLoadingDialog: KKLoadingDialog? = null
    protected fun showLoadingDialog(loadText: String = "") {
        if (mActivity != null && mActivity?.isFinishing == false) {
            if (null == mLoadingDialog) {
                mLoadingDialog = KKLoadingDialog(mActivity, loadText)
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
        if (isCanShowing) {
            val parentFragment = parentFragment
            if (parentFragment == null) {
                return true
            }

            if (parentFragment is NBaseFragment) {
                return parentFragment.isVisibleOnScreen()
            } else {
                return parentFragment.isVisible
            }
        }
        return false
    }

}
