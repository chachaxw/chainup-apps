package com.yjkj.chainup.new_version.activity.login

import android.annotation.SuppressLint
import android.hardware.fingerprint.FingerprintManager
import android.os.Bundle
import android.os.Handler
import android.os.Message
import androidx.core.hardware.fingerprint.FingerprintManagerCompat
import androidx.core.os.CancellationSignal
import com.jaeger.library.StatusBarUtil
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.util.ColorUtil
import com.yjkj.chainup.util.CryptoObjectHelper
import com.yjkj.chainup.util.ToastUtils
import kotlinx.android.synthetic.main.activity_fingerprint.*

/**
 * @Date 2023-11-14
 *@description Fingerprint recognition verification
 * @author Bertking
 *Reference link: https://blog.csdn.net/createchance/article/details/51991764
 */
class FingerprintActivity : NBaseActivity() {
    override fun setContentView(): Int {
        return R.layout.activity_fingerprint
    }

    lateinit var fingerprintManager: FingerprintManagerCompat
    var cancellationSignal: CancellationSignal? = null
    var authCallBack: AuthCallBack? = null


    var handler = @SuppressLint("HandlerLeak")
    object : Handler() {
        override fun handleMessage(msg: Message) {
            super.handleMessage(msg)

            when (msg?.what) {
                MSG_AUTH_SUCCESS -> {
                    tv_result?.text =  LanguageUtil.getString(mActivity,"open_suc")
                    cancellationSignal = null
                }

                MSG_AUTH_FAILED -> {
                    tv_result?.text =  LanguageUtil.getString(mActivity,"open_failure")
                    cancellationSignal = null
                }

                MSG_AUTH_ERROR -> {
                    tv_result?.text =  LanguageUtil.getString(mActivity,"authorization_suc")
                    handlerErrorCode(msg.arg1)
                }

                MSG_AUTH_HELP -> {
                    tv_result?.text =  LanguageUtil.getString(mActivity,"authorization_help")
                    handleHelpCode(msg.arg1)
                }


            }
        }
    }

    companion object {
        val MSG_AUTH_SUCCESS = 100
        val MSG_AUTH_FAILED = 101
        val MSG_AUTH_ERROR = 102
        val MSG_AUTH_HELP = 103

    }


    override fun onInit(savedInstanceState: Bundle?) {
        super.onInit(savedInstanceState)
        initView()
    }

    override fun initView() {
        StatusBarUtil.setColor(this, ColorUtil.getColorByMode(R.color.bg_card_color_day),0)
        initFingerPrintManager()
        cancellationSignal
        initClicker()
    }

    fun initClicker() {
        /**
         *Enable fingerprint authentication
         */
        btn_open_fingerprint.setOnClickListener {

            /**
             *Enable Authorization
             */
            try {
                var cryptoObjectHelper = CryptoObjectHelper()
                if (cancellationSignal == null) {
                    cancellationSignal = CancellationSignal()
                }
                fingerprintManager.authenticate(cryptoObjectHelper.buildCryptoObject(), 0, cancellationSignal, authCallBack!!, null)
                ToastUtils.showToast( LanguageUtil.getString(mActivity,"authorization_error"))

            } catch (e: Exception) {
                ToastUtils.showToast( LanguageUtil.getString(mActivity,"fingerprint_initialization_failed"))
            }
        }

        btn_cancel_fingerprint.setOnClickListener {
            /**
             *Cancel Authorization
             */
            cancellationSignal?.cancel()
        }


        btn_next.setOnClickListener {
            val bundle = Bundle()
            bundle.putInt("type", TouchIDFaceIDActivity.FINGERPRINT)
            bundle.putBoolean("is_first_login", false)
            ArouterUtil.navigation("/login/touchidfaceidactivity", bundle)
        }
    }


    private fun initFingerPrintManager() {
        fingerprintManager = FingerprintManagerCompat.from(this)
        if (!fingerprintManager.isHardwareDetected) {
            ToastUtils.showToast( LanguageUtil.getString(mActivity,"hardware_not_recognition"))
        } else if (!fingerprintManager.hasEnrolledFingerprints()) {
            ToastUtils.showToast( LanguageUtil.getString(mActivity,"no_fingerprints_were_entered"))
        } else {
            try {
                authCallBack = AuthCallBack(handler)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }


    private fun handleHelpCode(code: Int) {
        when (code) {
            FingerprintManager.FINGERPRINT_ACQUIRED_GOOD -> {
                ToastUtils.showToast( LanguageUtil.getString(mActivity,"fingerprint_complete"))
            }
            /**
             *Fingerprints are inaccurate (dirty)
             */
            FingerprintManager.FINGERPRINT_ACQUIRED_IMAGER_DIRTY -> {
                ToastUtils.showToast( LanguageUtil.getString(mActivity,"fingerprints_too_fuzzy"))
            }
            /**
             *Fingerprints are inaccurate or there is a problem with the sensor
             */
            FingerprintManager.FINGERPRINT_ACQUIRED_INSUFFICIENT -> {
                ToastUtils.showToast( LanguageUtil.getString(mActivity,"fingerprint_blur_or_sensor_blur"))
            }
            /**
             *Incomplete fingerprint
             */
            FingerprintManager.FINGERPRINT_ACQUIRED_PARTIAL -> {
                ToastUtils.showToast( LanguageUtil.getString(mActivity,"Incomplete_fingerprint"))
            }
            /**
             *Too fast to identify fingerprints
             */
            FingerprintManager.FINGERPRINT_ACQUIRED_TOO_FAST -> {
                ToastUtils.showToast( LanguageUtil.getString(mActivity,"moving_too_fast"))
            }
            /**
             *Too slow to identify fingerprints
             */
            FingerprintManager.FINGERPRINT_ACQUIRED_TOO_SLOW -> {
                ToastUtils.showToast( LanguageUtil.getString(mActivity,"cannot_read_fingerprint"))
            }
        }
    }


    fun handlerErrorCode(code: Int) {
        when (code) {
            /**
             *Cancel
             */
            FingerprintManager.FINGERPRINT_ERROR_CANCELED -> {
                ToastUtils.showToast( LanguageUtil.getString(mActivity,"defingerprinting"))

            }

            /**
             *Unavailable
             */
            FingerprintManager.FINGERPRINT_ERROR_HW_UNAVAILABLE -> {
                ToastUtils.showToast( LanguageUtil.getString(mActivity,"hardware_error"))
            }

            /**
             *Error 5 times, locked
             */
            FingerprintManager.FINGERPRINT_ERROR_LOCKOUT -> {
                ToastUtils.showToast( LanguageUtil.getString(mActivity,"error_more_5"))
            }

            /**
             *Supported but set with incomplete fingerprints
             */
            FingerprintManager.FINGERPRINT_ERROR_NO_SPACE -> {
                ToastUtils.showToast( LanguageUtil.getString(mActivity,"fingerprint_incomplete"))
            }

            /**
             *Identification timeout
             */
            FingerprintManager.FINGERPRINT_ERROR_TIMEOUT -> {
                ToastUtils.showToast( LanguageUtil.getString(mActivity,"fingerprint_identification_timeout"))
            }

            /**
             *The sensor cannot process the current fingerprint
             */
            FingerprintManager.FINGERPRINT_ERROR_UNABLE_TO_PROCESS -> {
                ToastUtils.showToast( LanguageUtil.getString(mActivity,"cannot_handle_the_current_fingerprint"))
            }


        }
    }


    override fun onDestroy() {
        super.onDestroy()
        cancellationSignal?.cancel()
    }

}
