package com.yjkj.chainup.util

import android.content.Context
import android.content.res.Configuration
import android.os.Build
import android.view.Display
import android.view.View
import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.service.UserDataService
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.new_version.dialog.NewDialogUtils
import com.yjkj.chainup.wedegit.SnackLayout
import org.jetbrains.anko.dip
import org.jetbrains.anko.sp
import org.json.JSONObject
import java.lang.reflect.Method


/**
 * @Author: Bertking
 * @Date 2023/3/6-11:53 AM
 *Description: Tool class for obtaining screen information
 *As for the mutual conversion of dp&sp, the Anko library already has built-in dip()&sp()</p>
 * <link>https://github.com/Kotlin/anko/wiki/Anko-Commons-%E2%80%93-Misc#dimensions</link>
 */

object DisplayUtil {
    /**
     *@return Screen width
     */
    fun getScreenWidth(context: Context = ChainUpApp.appContext): Int = context.resources.displayMetrics.widthPixels

    /**
     *@return Screen height
     */
    fun getScreenHeight(context: Context = ChainUpApp.appContext): Int = context.resources.displayMetrics.heightPixels

    /**
     *@return Resolution
     */
    fun getDisplayDensity(context: Context = ChainUpApp.appContext): Float = context.resources.displayMetrics.density


    /**
     * @param view
     * @param text
     *Is @param isSuc in a successful state
     */
    fun showSnackBar(view: View?, text: String?, isSuc: Boolean = true) {
        SnackLayout.showSnackBar(view, text, isSuc)
    }

    fun dip2px(int: Int): Int {
        return ChainUpApp.appContext.dip(int)
    }


    fun sp2px(int: Int): Int {
        return ChainUpApp.appContext.sp(int)
    }


    fun dip2px(float: Float): Float {
        return ChainUpApp.appContext.dip(float).toFloat()
    }


    fun sp2px(float: Float): Float {
        return ChainUpApp.appContext.sp(float).toFloat()
    }


    fun getCerificationStatus(context: Context, beans: ArrayList<JSONObject>,isCheckCapitalPwordSet:Boolean): Boolean {
        if (UserDataService.getInstance().googleStatus == 1) {
            if (UserDataService.getInstance().nickName.isEmpty() || UserDataService.getInstance().authLevel != 1 || UserDataService.getInstance().googleStatus != 1) {
                NewDialogUtils.OTCTradingMustPermissionsDialog(context, object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        if (UserDataService.getInstance().nickName.isEmpty()) {
                            //Certification status 0. Under review, 1. Passed, 2. Not passed, 3. Not certified
                            ArouterUtil.navigation(RoutePath.PersonalInfoActivity, null)
                        } else if (UserDataService.getInstance().authLevel != 1) {
                            ArouterUtil.navigation(RoutePath.KycActivity, null)
                        } else {
                            ArouterUtil.navigation(RoutePath.SafetySettingActivity, null)
                        }

                    }
                })
                return true
            } else if (UserDataService.getInstance().isCapitalPwordSet != 1 || beans?.size == 0) {
                NewDialogUtils.OTCTradingSecurityDialog(context!!,isCheckCapitalPwordSet = isCheckCapitalPwordSet, listener = object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        if (UserDataService.getInstance().isCapitalPwordSet != 1 && isCheckCapitalPwordSet) {
                            ArouterUtil.navigation(RoutePath.SafetySettingActivity, null)
                        } else {
                            ArouterUtil.navigation(RoutePath.PaymentMethodActivity, null)

                        }

                    }
                }, paymentStatus = beans?.size != 0)
                return true
            }
        } else {
            if (UserDataService.getInstance().nickName.isEmpty() || UserDataService.getInstance().authLevel != 1 || (UserDataService.getInstance().isOpenMobileCheck != 1 && UserDataService.getInstance().googleStatus != 1)) {
                NewDialogUtils.OTCTradingPermissionsDialog(context, object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        if (UserDataService.getInstance().nickName.isEmpty()) {
                            //Certification status 0. Under review, 1. Passed, 2. Not passed, 3. Not certified
                            ArouterUtil.navigation(RoutePath.PersonalInfoActivity, null)
                        } else if (UserDataService.getInstance().authLevel != 1) {
                            ArouterUtil.navigation(RoutePath.KycActivity, null)
                        } else {
                            ArouterUtil.navigation(RoutePath.SafetySettingActivity, null)

                        }
                    }
                })
                return true
            } else if (UserDataService.getInstance().isCapitalPwordSet != 1 || beans?.size == 0) {
                NewDialogUtils.OTCTradingSecurityDialog(context!!, object : NewDialogUtils.DialogBottomListener {
                    override fun sendConfirm() {
                        if (UserDataService.getInstance().isCapitalPwordSet != 1) {

                            ArouterUtil.navigation(RoutePath.SafetySettingActivity, null)

                        } else {
                            ArouterUtil.navigation(RoutePath.PaymentMethodActivity, null)
                        }

                    }
                }, beans?.size != 0)
                return true
            }
        }
        return false
    }

    fun setDefaultDisplay(context: Context) {
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.M) {
            val origConfig: Configuration = context.resources.configuration
            origConfig.densityDpi = getDefaultDisplayDensity()
            context.resources.updateConfiguration(origConfig, context.resources.displayMetrics)
        }
    }


    fun getDefaultDisplayDensity(): Int {
        return try {
            val clazz = Class.forName("android.view.WindowManagerGlobal")
            val method: Method = clazz.getMethod("getWindowManagerService")
            method.setAccessible(true)
            val iwm: Any = method.invoke(clazz)
            val getInitialDisplayDensity: Method = iwm.javaClass.getMethod(
                "getInitialDisplayDensity",
                Int::class.javaPrimitiveType
            )
            getInitialDisplayDensity.setAccessible(true)
            val densityDpi: Any = getInitialDisplayDensity.invoke(iwm, Display.DEFAULT_DISPLAY)
            densityDpi as Int
        } catch (e: Exception) {
            e.printStackTrace()
            -1
        }
    }

}
