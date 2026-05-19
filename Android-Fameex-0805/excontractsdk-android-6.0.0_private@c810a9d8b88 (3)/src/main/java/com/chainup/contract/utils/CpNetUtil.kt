package com.chainup.contract.utils

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.NetworkInfo
import android.telephony.TelephonyManager
import android.util.Log
import com.chainup.contract.BuildConfig

/**
 *Network Tools Class
 *Reference {@ url https://developer.android.com/training/basics/network-ops/managing.html }
 *Permission Required:<br>
 * <p>{@link Manifest.permission#ACCESS_NETWORK_STATE}</p>
 * ConnectivityManager: Answers queries about the state of network connectivity. It also notifies applications when network connectivity changes.
 * NetworkInfo: Describes the status of a network interface of a given type (currently either Mobile or Wi-Fi).
 */
class CpNetUtil private constructor() {
    companion object {
        private const val TAG = "NetUtil"
        private val D = BuildConfig.DEBUG
        private val sNetConnChangedReceiver = NetConnChangedReceiver()
        private val sNetConnChangedListeners = ArrayList<NetConnChangedListener>()

        interface NetConnChangedListener {
            fun onNetConnChanged(connectStatus: ConnectStatus)
        }

        enum class ConnectStatus {
            NO_NETWORK,
            WIFI,
            MOBILE,
            MOBILE_2G,
            MOBILE_3G,
            MOBILE_4G,
            MOBILE_UNKNOWN,
            OTHER,
            NO_CONNECTED
        }

        /**
         *Whether the network interface is available (that is, whether the network connection is feasible) and/or connected (that is, whether there is a network connection, whether it is possible to establish a socket and transfer data)
         *
         *@param context Context
         *@return {@ code true} Network available
         */
        fun isNetConnected(context: Context): Boolean {
            val activeInfo = getActiveNetworkInfo(context)
            return activeInfo?.isConnected ?: false
        }

        /**
         *Whether to move data connection
         *
         *@param context Context
         *@return {@ code true} Mobile data connection
         */
        fun isMobileConnected(context: Context): Boolean {
            val activeInfo = getActiveNetworkInfo(context)
            return activeInfo?.run { isConnected && type == ConnectivityManager.TYPE_MOBILE } ?: false
        }

        /**
         *Whether 2G network connection
         *
         *@param context Context
         *@return {@ code true} 2G network connection
         */
        fun is2GConnected(context: Context): Boolean {
            if (!isNetConnected(context)) {
                return false
            }
            val activeInfo = getActiveNetworkInfo(context)
            val subtype = activeInfo?.subtype
            return when (subtype) {
                TelephonyManager.NETWORK_TYPE_GPRS,
                TelephonyManager.NETWORK_TYPE_GSM,
                TelephonyManager.NETWORK_TYPE_EDGE,
                TelephonyManager.NETWORK_TYPE_CDMA,
                TelephonyManager.NETWORK_TYPE_1xRTT,
                TelephonyManager.NETWORK_TYPE_IDEN -> true
                else -> false
            }
        }

        /**
         *Whether 3G network connection
         *
         *@param context Context
         *@return {@ code true} 3G network connection
         */
        fun is3GConnected(context: Context): Boolean {
            if (!isNetConnected(context)) {
                return false
            }
            val activeInfo = getActiveNetworkInfo(context)
            val subtype = activeInfo?.subtype
            return when (subtype) {
                TelephonyManager.NETWORK_TYPE_UMTS,
                TelephonyManager.NETWORK_TYPE_EVDO_0,
                TelephonyManager.NETWORK_TYPE_EVDO_A,
                TelephonyManager.NETWORK_TYPE_HSDPA,
                TelephonyManager.NETWORK_TYPE_HSUPA,
                TelephonyManager.NETWORK_TYPE_HSPA,
                TelephonyManager.NETWORK_TYPE_EVDO_B,
                TelephonyManager.NETWORK_TYPE_EHRPD,
                TelephonyManager.NETWORK_TYPE_HSPAP,
                TelephonyManager.NETWORK_TYPE_TD_SCDMA -> true
                else -> false
            }
        }

        /**
         *4G network connection or not
         *
         *@param context Context
         *@return {@ code true} 4G network connection
         */
        fun is4GConnected(context: Context): Boolean {
            if (!isNetConnected(context)) {
                return false
            }
            val activeInfo = getActiveNetworkInfo(context)
            val subtype = activeInfo?.subtype
            return when (subtype) {
                TelephonyManager.NETWORK_TYPE_LTE,
                TelephonyManager.NETWORK_TYPE_IWLAN -> true
                else -> false
            }
        }

        /**
         *Obtain the mobile network operator name
         * <lu>
         *China Unicom</li>
         *<li>China Mobile</li>
         *<li>China Telecom</li>
         * </lu>
         *
         *@param context Context
         *@return Mobile network operator name
         */
        fun getNetworkOperatorName(context: Context): String {
            val tm = context
                    .getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            return tm.networkOperatorName
        }

        /**
         *Obtain mobile terminal type
         *
         *@param context Context
         *@return Mobile phone format
         * <ul>
         *<li>{@ link TelephonyManager # PHONE_TYPE_NONE}: 0 Mobile phone format unknown</li>
         *<li>{@ link TelephonyManager # PHONE_TYPE_GSM}: 1 The mobile phone format is GSM, and China Mobile and China Unicom</li>
         *<li>{@ link TelephonyManager # PHONE_TYPE_CDMA}: 2 The mobile phone system is CDMA, and telecommunications</li>
         * <li>{@link TelephonyManager#PHONE_TYPE_SIP  } : 3</li>
         * </ul>
         */
        fun getPhoneType(context: Context): Int {
            val tm = context
                    .getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            return tm.phoneType
        }

        /**
         *Determine whether WiFi connection is available
         *
         *@param context Context
         *@return true If it's a wifi connection
         */
        fun isWifiConnected(context: Context): Boolean {
            val activeInfo = getActiveNetworkInfo(context)
            return activeInfo?.run { isConnected && type == ConnectivityManager.TYPE_WIFI } ?: false
        }

        private class NetConnChangedReceiver : BroadcastReceiver() {

            override fun onReceive(context: Context, intent: Intent) {
                log("onReceive")
                val activeInfo = getActiveNetworkInfo(context)
                if (activeInfo == null) {
                    broadcastConnStatus(ConnectStatus.NO_NETWORK)
                } else if (activeInfo!!.isConnected) {
                    val networkType = activeInfo!!.type
                    if (ConnectivityManager.TYPE_WIFI == networkType) {
                        broadcastConnStatus(ConnectStatus.WIFI)
                    } else if (ConnectivityManager.TYPE_MOBILE == networkType) {
                        broadcastConnStatus(ConnectStatus.MOBILE)
                        val subtype = activeInfo!!.subtype
                        if (TelephonyManager.NETWORK_TYPE_GPRS == subtype
                                || TelephonyManager.NETWORK_TYPE_GSM == subtype
                                || TelephonyManager.NETWORK_TYPE_EDGE == subtype
                                || TelephonyManager.NETWORK_TYPE_CDMA == subtype
                                || TelephonyManager.NETWORK_TYPE_1xRTT == subtype
                                || TelephonyManager.NETWORK_TYPE_IDEN == subtype
                        ) {
                            broadcastConnStatus(ConnectStatus.MOBILE_2G)
                        } else if (TelephonyManager.NETWORK_TYPE_UMTS == subtype
                                || TelephonyManager.NETWORK_TYPE_EVDO_0 == subtype
                                || TelephonyManager.NETWORK_TYPE_EVDO_A == subtype
                                || TelephonyManager.NETWORK_TYPE_HSDPA == subtype
                                || TelephonyManager.NETWORK_TYPE_HSUPA == subtype
                                || TelephonyManager.NETWORK_TYPE_HSPA == subtype
                                || TelephonyManager.NETWORK_TYPE_EVDO_B == subtype
                                || TelephonyManager.NETWORK_TYPE_EHRPD == subtype
                                || TelephonyManager.NETWORK_TYPE_HSPAP == subtype
                                || TelephonyManager.NETWORK_TYPE_TD_SCDMA == subtype
                        ) {
                            broadcastConnStatus(ConnectStatus.MOBILE_3G)
                        } else if (TelephonyManager.NETWORK_TYPE_LTE == subtype || TelephonyManager.NETWORK_TYPE_IWLAN == subtype) {
                            broadcastConnStatus(ConnectStatus.MOBILE_4G)
                        } else {
                            broadcastConnStatus(ConnectStatus.MOBILE_UNKNOWN)
                        }
                    } else {
                        broadcastConnStatus(ConnectStatus.OTHER)
                    }
                } else {
                    broadcastConnStatus(ConnectStatus.NO_CONNECTED)
                }
            }
        }

        /**
         *Register Network Recipients
         *@param context Context
         */
        fun registerNetConnChangedReceiver(context: Context) {
            val filter = IntentFilter()
            filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION)
            context.registerReceiver(sNetConnChangedReceiver, filter)
        }

        /**
         *Unregister Network Recipients
         ** @param context context
         */
        fun unregisterNetConnChangedReceiver(context: Context) {
            context.unregisterReceiver(sNetConnChangedReceiver)
            sNetConnChangedListeners.clear()
        }

        /**
         *Add network status change monitoring
         *
         *@param listener Network connection status change monitoring
         */
        fun addNetConnChangedListener(listener: NetConnChangedListener) {
            val result = sNetConnChangedListeners.add(listener)
            log("addNetConnChangedListener: $result")
        }

        /**
         *Remove specified network change monitoring
         *
         *@param listener Network connection status change monitoring
         */
        fun removeNetConnChangedListener(listener: NetConnChangedListener) {
            val result = sNetConnChangedListeners.remove(listener)
            log("removeNetConnChangedListener: $result")
        }

        private fun broadcastConnStatus(connectStatus: ConnectStatus) {
            val size = sNetConnChangedListeners.size
            if (size == 0) {
                return
            }
            for (i in 0 until size) {
                sNetConnChangedListeners[i].onNetConnChanged(connectStatus)
            }
        }

        private fun getActiveNetworkInfo(context: Context): NetworkInfo? {
            val connMgr = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            return connMgr.activeNetworkInfo
        }

        private fun log(msg: String) {
            if (D) {
                Log.e(TAG, msg)
            }
        }
    }
}
