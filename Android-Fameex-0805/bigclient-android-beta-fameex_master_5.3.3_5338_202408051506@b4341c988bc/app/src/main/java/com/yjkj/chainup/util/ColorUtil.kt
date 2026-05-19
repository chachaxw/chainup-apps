package com.yjkj.chainup.util

import android.content.Context
import android.content.res.ColorStateList
import android.content.res.Resources
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.StateListDrawable
import androidx.core.content.ContextCompat
import android.widget.ImageView
import androidx.annotation.ColorInt
import androidx.annotation.ColorRes
import androidx.annotation.IntRange
import androidx.core.content.res.ResourcesCompat
import com.chainup.contract.utils.CpColorUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.db.service.ColorDataService
import com.yjkj.chainup.db.service.PublicInfoDataService
import java.math.BigDecimal
import com.yjkj.chainup.net.api.ApiConstants

/**
 * @Author: Bertking
 * @Date 2023/3/9-2:15 PM
 * @Description:
 */
object ColorUtil {

    val TAG = "ColorUtil"

    const val COLOR_SELECT = "color_selected"

    /**
     *Green rise and red fall
     */
    const val GREEN_RISE = 0

    /**
     *Red rise and green fall
     */
    const val RED_RISE = 1


    fun getColor(context: Context, colorId: Int) =
            ContextCompat.getColor(context, colorId)

    fun getColor(colorId: Int) = getColor(ChainUpApp.appContext, colorId)


    fun getMainGreen(): Int {
        return getColor(R.color.main_green)
    }

    fun getMainRed(): Int {
        return getColor(R.color.main_red)
    }

    /**
     *Red up green down OR green up red down
     *0- Green rise, red fall
     *1- Red rise and green fall
     *
     */
    fun getColorType(): Int {
        return ColorDataService.getInstance().colorType
    }

    /**
     *Obtain the main color (red and green)
     *Is @param isRise in an upward state
     */
    fun getMainColorType(isRise: Boolean = true,isZero:Boolean? = false): Int {
        var colorSelect = getColorType()
        LogUtil.d(TAG, "getMainColorType==isRise is $isRise,colorSelect is $colorSelect")
        val mainGreen = getColor(R.color.main_green)
        val mainRed = getColor(R.color.main_red)
        val zeroColor = CpColorUtil.getColor(R.color.main_zero)
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
     *Obtain the main color (red and green)
     *Is @param isRise in an upward state
     */
    fun getMainColorBgType(isRise: Boolean = true): Pair<Int, Int> {
        var colorSelect = getColorType()
        LogUtil.d(TAG, "getMainColorType==isRise is $isRise,colorSelect is $colorSelect")
        val mainGreen = getColor(R.color.main_green)
        val mainRed = getColor(R.color.main_red)

        val drawableGreen = R.drawable.bg_trade_green_rose
        val drawableRed = R.drawable.bg_trade_red_rose

        if (colorSelect == GREEN_RISE) {
            if (isRise) {
                return Pair(mainGreen, drawableGreen)
            }
            return Pair(mainRed, drawableRed)
        } else {
            if (isRise) {
                return Pair(mainRed, drawableRed)
            }
            return Pair(mainGreen, drawableGreen)
        }

    }

    /**
     *Obtain the main color (red and green)
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
     *Obtain secondary colors (red and green with transparency)
     *Is @param isRise in an upward state
     */
    fun getMinorColorType(isRise: Boolean = true): Int {
        var colorSelect = getColorType()

        val minorGreen = getColor(R.color.main_green_15)
        val minorRed = getColor(R.color.main_red_15)

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
     *Transaction interface (buy and sell TAB drawable), special handling
     */
    fun getOrientationTabDrawable(isBuy: Boolean = true): Int {
        var colorSelect = getColorType()
        /*PublicInfoManager.liveData4Color.observeForever {
            colorSelect = it!!
        }*/

        val drawableGreen = R.drawable.bg_buy_line
        val drawableRed = R.drawable.bg_sell_line
        return if (colorSelect == GREEN_RISE) {
            if (isBuy) {
                drawableGreen
            } else {
                drawableRed
            }
        } else {
            if (isBuy) {
                drawableRed
            } else {
                drawableGreen
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

        val drawableGreen = R.drawable.sl_border_green_fill
        val drawableRed = R.drawable.sl_border_red_fill
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
     *OTC transaction page buying and selling
     */
    fun getOTCBuyOrSellDrawable(): Int {
        val drawableBlue = R.drawable.bg_otc_buy_or_sell_line

        return drawableBlue
    }


    /**
     *Obtain the ColorStateList of the transaction volume ratio on the transaction interface
     *Adding flexible configurations in the later stage of TODO
     */
    fun getCheck4ColorStateList(isRise: Boolean = true): ColorStateList {
        val states = arrayOf(
                intArrayOf(android.R.attr.state_checked),
                intArrayOf()
        )

        val colorArray = intArrayOf(
                getMainColorType(isRise),
                getColor(R.color.trade_hint_color)
        )
        return ColorStateList(states, colorArray)
    }

    /**
     *StateListDrawable to obtain the transaction volume ratio of the transaction interface
     *Adding flexible configurations in the later stage of TODO
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


    /**
     *Transaction interface (buy and sell TAB drawable), special handling
     *@param flag 0 default; 1 Buy 2 Sell
     */
    fun setTapeIcon(imageView: ImageView, flag: Int = 0) {
        var colorSelect = getColorType()
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

    fun getColorByMode(resId: Int ): Int {
        return getColorByMode(resId,false)
    }
    fun getColorByMode(resId: Int , iskline: Boolean = false): Int {
        val mResources = ChainUpApp.appContext.getResources()
        val originColor = ContextCompat.getColor(ChainUpApp.appContext, resId)
        var resName: String = ChainUpApp.appContext.getResources().getResourceEntryName(resId)
        //Judge whether it is daytime mode or Light-on-dark color scheme
        if (PublicInfoDataService.getInstance().getThemeModeNew().equals("day")) {
            resName = resName.replace("night", "day")
            if (iskline) {
                if (PublicInfoDataService.getInstance().klineThemeMode != ApiConstants.themeDay()) {
                    resName = resName.replace("day", "night")
                }
            }
        } else if (PublicInfoDataService.getInstance().getThemeModeNew().equals("night")) {
            resName = resName.replace("day", "night")
        }

        val trueResId: Int = mResources.getIdentifier(resName, "color", ChainUpApp.appContext.packageName)
        var trueColor = 0
        trueColor = try {
            ResourcesCompat.getColor(mResources, trueResId, null)
        } catch (e: Resources.NotFoundException) {
            e.printStackTrace()
            originColor
        }
        return trueColor
    }


    fun getBuyOrSellPair(context:Context): Pair<Int,Int> {
        val colorSelect = getColorType()
        if (colorSelect == GREEN_RISE) {
            return Pair(ContextCompat.getColor(context,R.color.main_green),ContextCompat.getColor(context,R.color.main_red))
        } else {
            return Pair(ContextCompat.getColor(context,R.color.main_red),ContextCompat.getColor(context,R.color.main_green))
        }
    }

    /**
     *Obtain the main color (red and green)
     *Is @param isRise in an upward state
     */
    fun getMainFocusColorType(isBuy: Boolean = true): Int {
        var colorSelect = getColorType()
        LogUtil.d(TAG, "getMainColorType==isRise is $isBuy,colorSelect is $colorSelect")
        val mainGreen = R.drawable.bg_trade_et_focused_green
        val mainRed = R.drawable.bg_trade_et_focused_red

        if (colorSelect == GREEN_RISE) {
            if (isBuy) {
                return mainGreen
            }
            return mainRed
        } else {
            if (isBuy) {
                return mainRed
            }
            return mainGreen
        }

    }

    /**
     *Obtain the main color (red and green)
     *Is @param isRise in an upward state
     */
    fun getMainTickColorType(isBuy: Boolean = true): Int {
        var colorSelect = getColorType()
        LogUtil.d(TAG, "getMainColorType==isRise is $isBuy,colorSelect is $colorSelect")
        val mainGreen = R.drawable.depth_sell_dot
        val mainRed = R.drawable.depth_buy_dot

        if (colorSelect == GREEN_RISE) {
            if (isBuy) {
                return mainGreen
            }
            return mainRed
        } else {
            if (isBuy) {
                return mainRed
            }
            return mainGreen
        }

    }

    /**
     *Obtain the main color (red and green)
     *Is @param isRise in an upward state
     */
    fun getMainSelectColorType(isBuy: Boolean = true, position: Int = 0): Int {
        var colorSelect = getColorType()
        LogUtil.d(TAG, "getMainColorType==isRise is $isBuy,colorSelect is $colorSelect")
        val mainGreen = R.drawable.bg_trade_et_focused_green
        val mainRed = R.drawable.bg_trade_et_focused_red

        if (colorSelect == GREEN_RISE) {
            if (isBuy) {
                return mainGreen
            }
            return mainRed
        } else {
            if (isBuy) {
                return mainRed
            }
            return mainGreen
        }

    }


    /**
     *Obtain the main color (red and green)
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
            if (isRise > 0) {
                mainRed
            } else if (isRise < 0) {
                mainGreen
            } else {
                mainZero
            }
        }
    }
    /**
     *Obtain the main color (red and green)
     *Is @param isRise in an upward state
     */
    fun getMainColorV2Type(context: Context,isRise: Int = 0): Int {
        val colorSelect = getColorType()
        val mainGreen =
            getColor(R.color.main_green)
        val mainRed = getColor(R.color.main_red)
        val mainZero = getColor(context,R.color.main_zero)
        return if (colorSelect == GREEN_RISE) {
            if (isRise > 0) {
                mainGreen
            } else if (isRise < 0) {
                mainRed
            } else {
                mainZero
            }
        } else {
            if (isRise > 0) {
                mainRed
            } else if (isRise < 0) {
                mainGreen
            } else {
                mainZero
            }
        }
    }
    fun getMainColorV3Type(isRise: Boolean = true): Int {
        val colorSelect = getColorType()
        val mainGreen =R.color.main_green
        val mainRed =R.color.main_red
        val mainZero =R.color.main_zero
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

    fun getMainBgType(isRise: Boolean = true): Int {
        var colorSelect = getColorType()
        LogUtil.d(TAG, "getMainColorType==isRise is $isRise,colorSelect is $colorSelect")
        val mainGreen = R.drawable.bg_buy_btn
        val mainRed = R.drawable.bg_sell_btn

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

    fun getMainGridResType(isRise: String = "0"): Int {
        val colorSelect = getColorType()
        val mainGreen = getColor(R.color.main_green)
        val mainRed = getColor(R.color.main_red)
        val mainZero = getColor(R.color.main_zero)
        if (colorSelect == GREEN_RISE) {
            if (isRise.isNotEmpty()) {
                val number = BigDecimal(isRise)
                val diff = BigDecimalUtils.compareTo(number, BigDecimal.ZERO)
                if (diff == 0) {
                    return mainZero
                } else if (diff == 1) {
                    return mainGreen
                } else if (diff == -1) {
                    return mainRed
                }
            }
        } else {
            if (isRise.isNotEmpty()) {
                val number = BigDecimal(isRise)
                val diff = BigDecimalUtils.compareTo(number, BigDecimal.ZERO)
                if (diff == 0) {
                    return mainZero
                } else if (diff == 1) {
                    return mainRed
                } else if (diff == -1) {
                    return mainGreen
                }
            }
        }
        return mainZero
    }

    fun getGridColorType(): Int {
        var colorSelect = getColorType()

        val mainGreen = R.drawable.bg_progressbar_grid_green
        val mainRed = R.drawable.bg_progressbar_grid_red

        if (colorSelect == GREEN_RISE) {
            return mainGreen
        } else {
            return mainRed
        }

    }

    fun getMainGridResTypeCorner(isRise: String = "0"): String {
        val number = BigDecimal(isRise)
        if (number == BigDecimal.ZERO) {
            return ""
        } else if (number > BigDecimal.ZERO) {
            return "+"
        } else if (number < BigDecimal.ZERO) {
            return ""
        }
        return ""
    }


    @ColorInt
    fun setAlphaComponent(@ColorInt color:Int, @IntRange(from = 0,to = 255) alpha:Int):Int {
        if (alpha >= 0 && alpha <= 255) {
            return color and 16777215 or alpha shl 24
        } else {
            throw IllegalArgumentException("alpha must be between 0 and 255.");
        }
    }

}
