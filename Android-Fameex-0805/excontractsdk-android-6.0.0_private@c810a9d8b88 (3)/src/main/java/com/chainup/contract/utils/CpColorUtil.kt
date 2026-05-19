package com.chainup.contract.utils

import android.content.Context
import android.content.res.ColorStateList
import android.content.res.Resources
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.StateListDrawable
import androidx.core.content.ContextCompat
import android.widget.ImageView
import androidx.annotation.DrawableRes
import androidx.core.content.res.ResourcesCompat
import com.chainup.contract.R
import com.chainup.contract.app.CpMyApp
import com.chainup.contract.eventbus.CpEventBusUtil
import com.chainup.contract.eventbus.CpMessageEvent

/**
 * @Author: Bertking
 * @Date：2019/3/9-2:15 PM
 * @Description:
 */
object CpColorUtil {

    val TAG = "ColorUtil"

    const val COLOR_SELECT = "color_selected"

    /**
     *Green rising and red falling
     */
    const val GREEN_RISE = 0

    /**
     *Red Rising Green Falling
     */
    const val RED_RISE = 1

    @JvmStatic
    fun getColor(context: Context, colorId: Int) =
            ContextCompat.getColor(context, colorId)

    fun getColor(colorId: Int) = getColor(CpMyApp.instance(), colorId)


    fun getMainGreen(): Int {
        return getColor(R.color.main_green)
    }

    fun getMainRed(): Int {
        return getColor(R.color.main_red)
    }

    /**
     *Red Up Green Down OR Green Up Red Down
     *0 ---- Green Rising Red Falling
     *1 ---- Red Rising Green Falling
     *
     */
    fun getColorType(): Int {
        return 0
    }

    @JvmStatic
    fun getColorType(context: Context?): Int {
        return CpPreferenceManager.getInstance(context)
            .getSharedInt(CpPreferenceManager.PREF_CONTRACT_COLOR, 0)
    }

    fun setColorType(context: Context?, type: Int) {
        CpPreferenceManager.getInstance(context)
            .putSharedInt(CpPreferenceManager.PREF_CONTRACT_COLOR, type)
        CpEventBusUtil.post(CpMessageEvent(CpMessageEvent.color_rise_fall_type))
    }

    /**
     *Get the main color (red and green)
     *Is @param isRise in an upward state
     */
    fun getMainColorType(isRise: Boolean = true,isZero:Boolean? = false): Int {
        var colorSelect = getColorType(CpMyApp.instance())
        ChainUpLogUtil.d(TAG, "getMainColorType==isRise is $isRise,colorSelect is $colorSelect")
        val mainGreen = getColor(R.color.main_green)
        val mainRed = getColor(R.color.main_red)
        val zeroColor = getColor(R.color.text_color_2)
        if(isZero==true) return zeroColor
        if (colorSelect == GREEN_RISE) {
            if (isRise) {
                return mainGreen
            }
            return mainRed
        } else {
            if (isRise) {
                return mainRed
            }
            return mainGreen
        }

    }

    /**
     *Get the main color (red and green)
     *Is @param isRise in an upward state
     */
    fun getMainColorType(colorSelect: Int, isRise: Boolean = true): Int {
        val mainGreen =
                getColor(R.color.main_green)
        val mainRed = getColor(R.color.main_red)
        return if (colorSelect == GREEN_RISE) {
            if (isRise) {
                mainGreen
            } else {
                mainRed
            }
        } else {
            if (isRise) {
                mainRed
            } else {
                mainGreen
            }
        }
    }


    /**
     *Get secondary color (red and green with transparency)
     *Is @param isRise in an upward state
     */
    fun getMinorColorType(isRise: Boolean = true,isZero: Boolean? = false): Int {
        var colorSelect = getColorType(CpMyApp.instance())

        val minorGreen = getColor(R.color.main_green_15)
        val minorRed = getColor(R.color.main_red_15)
        val minorZero = getColor(R.color.text_color_2_15)

        if(isZero==true) return minorZero


        return if (colorSelect == GREEN_RISE) {
            if (isRise) {
                minorGreen
            } else {
                minorRed
            }
        } else {
            if (isRise) {
                minorRed
            } else {
                minorGreen
            }
        }

    }


    /**
     *Contract transaction interface (percentage background drawable)
     */
    fun getContractRateDrawable(isRise: Boolean = true): Int {
        var colorSelect = getColorType()
        /*PublicInfoManager.liveData4Color.observeForever {
            colorSelect = it!!
        }*/

        val drawableGreen = R.drawable.cp_border_green_fill
        val drawableRed = R.drawable.cp_border_red_fill
        return if (colorSelect == GREEN_RISE) {
            if (isRise) {
                drawableGreen
            } else {
                drawableRed
            }
        } else {
            if (isRise) {
                drawableRed
            } else {
                drawableGreen
            }
        }
    }


    /**
     *Otc transaction page trading
     */
    fun getOTCBuyOrSellDrawable(): Int {
        val drawableBlue = R.drawable.cp_bg_otc_buy_or_sell_line

        return drawableBlue
    }


    /**
     *Obtain the ColorStateList of the transaction volume ratio on the transaction interface
     *Add flexible configuration in TODO later
     */
    fun getCheck4ColorStateList(isRise: Boolean = true): ColorStateList {
        val states = arrayOf(
                intArrayOf(android.R.attr.state_checked),
                intArrayOf()
        )

        val colorArray = intArrayOf(
                getMainColorType(isRise),
                getColor(R.color.hint_color)
        )
        return ColorStateList(states, colorArray)
    }

    /**
     *Obtain the StateListDrawable of the transaction volume ratio on the transaction interface
     *Add flexible configuration in TODO later
     */
    fun getCheck4StateListDrawable(isRise: Boolean = true): StateListDrawable {
        val normalDrawable = GradientDrawable()
        normalDrawable.setColor(getColor(R.color.transparent))

        val checkedDrawable = GradientDrawable()
        checkedDrawable.setColor(getMinorColorType(isRise))

        val stateDrawable = StateListDrawable()
        stateDrawable.addState(intArrayOf(android.R.attr.state_checked), checkedDrawable)
        stateDrawable.addState(intArrayOf(), normalDrawable)
        return stateDrawable
    }

    @DrawableRes
    fun getDotDrawableRes(isBuy:Boolean):Int {
        val colorSelect = getColorType(CpMyApp.instance())
        return when(colorSelect){
            //red drawable:   R.drawable.depth_buy_dot
            //green drawable: R.drawable.depth_sell_dot
            GREEN_RISE -> {
                return if(isBuy) R.drawable.depth_sell_dot else R.drawable.depth_buy_dot
            }
            else -> {
                return if(isBuy) R.drawable.depth_buy_dot else R.drawable.depth_sell_dot
            }
        }
    }


    /**
     *Transaction interface (trading TAB drawable), special processing
     *@param flag 0 default; 1 Buy 2 Sell
     */
    fun setTapeIcon(imageView: ImageView, flag: Int = 0) {
        var colorSelect = getColorType(CpMyApp.instance())
        /*PublicInfoManager.liveData4Color.observeForever {
            colorSelect = it!!
        }*/
        return if (colorSelect == GREEN_RISE) {
            when (flag) {
                1 -> {
                    imageView.setImageResource(R.mipmap.public_icon_buy)
                }

                2 -> {
                    imageView.setImageResource(R.mipmap.public_icon_buy_1)
                }

                else -> {
                    imageView.setImageResource(R.mipmap.public_icon_buyandsell)
                }
            }

        } else {
            when (flag) {
                1 -> {
                    imageView.setImageResource(R.mipmap.public_icon_buy_1)
                }

                2 -> {
                    imageView.setImageResource(R.mipmap.public_icon_buy)
                }

                else -> {
                    imageView.setImageResource(R.mipmap.public_icon_buyandsell)
                }
            }

        }
    }


    fun getColorByMode(resId: Int): Int {
        val mResources = CpMyApp.instance().getResources()
        val originColor = ContextCompat.getColor(CpMyApp.instance(), resId)
        var resName: String =CpMyApp.instance().getResources().getResourceEntryName(resId)
        //Determine whether it is daytime mode or nighttime mode
        if (CpClLogicContractSetting.getThemeMode(CpMyApp.instance())==0) {
            resName = resName.replace("night", "day")
        } else if (CpClLogicContractSetting.getThemeMode(CpMyApp.instance())==1) {
            resName = resName.replace("day", "night")
        }
        val trueResId: Int = mResources.getIdentifier(resName, "color", CpMyApp.instance().packageName)
        var trueColor = 0
        trueColor = try {
            ResourcesCompat.getColor(mResources, trueResId, null)
        } catch (e: Resources.NotFoundException) {
            e.printStackTrace()
            originColor
        }
        return trueColor
    }

    /**
     *Get the main color (red and green)
     *Is @param isRise in an upward state
     */
    fun getMainColorV2Type(colorSelect: Int, isRise: Int = 0): Int {
        val mainGreen =
                getColor(R.color.main_green)
        val mainRed = getColor(R.color.main_red)
        val mainZero = getColorByMode(R.color.main_zero_day)
        return if (colorSelect == GREEN_RISE) {
            if (isRise > 0) {
                mainGreen
            } else if (isRise < 0) {
                mainRed
            } else {
                mainZero
            }
        } else {
            if (isRise> 0) {
                mainRed
            } else if (isRise < 0) {
                mainGreen
            }else{
                mainZero
            }
        }
    }
}
