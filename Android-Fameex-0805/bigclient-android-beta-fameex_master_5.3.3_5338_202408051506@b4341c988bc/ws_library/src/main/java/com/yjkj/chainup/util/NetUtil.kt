package com.yjkj.chainup.util

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.NetworkInfo
import android.os.Build
import android.telephony.TelephonyManager
import android.util.Log
import com.chainup.ws.BuildConfig

/**
 *Network Tools Class
 *Reference {@ URL https://developer.android.com/training/basics/network-ops/managing.html }
 *Permission required:<br>
 * <p>{@link Manifest.permission#ACCESS_NETWORK_STATE}</p>
 * ConnectivityManager: Answers queries about the state of network connectivity. It also notifies applications when network connectivity changes.
 * NetworkInfo: Describes the status of a network interface of a given type (currently either Mobile or Wi-Fi).
 */
class NetUtil private constructor() {
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
         *Whether the network interface is available (i.e. whether the network connection is feasible) and/or connected (i.e. whether there is a network connection, whether sockets can be established and data can be transmitted)
         *
         *@param context context
         *@return {@ code true} Network available
         */
        fun isNetConnected(context: Context): Boolean {
//            val activeInfo = getActiveNetworkInfo(context)
//            return activeInfo?.isConnected ?: false
            return isNetworkAvailable(context)
        }

        /**
         *Whether to move data connection
         *
         *@param context context
         *@return {@ code true} Mobile data connection
         */
        fun isMobileConnected(context: Context): Boolean {
            val activeInfo = getActiveNetworkInfo(context)
            return activeInfo?.run { isConnected && type == ConnectivityManager.TYPE_MOBILE } ?: false
        }

        /**
         *Is there a 2G network connection
         *
         *@param context context
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
         *Is there a 3G network connection
         *
         *@param context context
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
         *Is there a 4G network connection
         *
         *@param context context
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
         *Get the name of Mobile network operator
         * <lu>
         *China Unicom</li>
         *China Mobile</li>
         *China Telecom</li>
         * </lu>
         *
         *@param context context
         *@return Name of Mobile network operator
         */
        fun getNetworkOperatorName(context: Context): String {
            val tm = context
                    .getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            return tm.networkOperatorName
        }

        /**
         *Obtain mobile terminal type
         *
         *@param context context
         *@return Mobile phone format
         * <ul>
         *{@ link TelephonyManager # PHONE_TYPE_NONE}: 0 Unknown phone format</li>
         *<li>{@ link TelephonyManager # PHONE_TYPE_GSM}: 1. The mobile phone format is GSM, and China Mobile and China Unicom</li>
         *<li>{@ link TelephonyManager # PHONE_TYPE_CDMA}: 2. The mobile phone format is CDMA, and telecommunications</li>
         * <li>{@link TelephonyManager#PHONE_TYPE_SIP  } : 3</li>
         * </ul>
         */
        fun getPhoneType(context: Context): Int {
            val tm = context
                    .getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            return tm.phoneType
        }

        /**
         *Determine if there is a WiFi connection
         *
         *@param context context
         *@return true If it is a WiFi connection
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
         *Register Network Recipient
         *@param context context
         */
        fun registerNetConnChangedReceiver(context: Context) {
            val filter = IntentFilter()
            filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION)
            context.registerReceiver(sNetConnChangedReceiver, filter)
        }

        /**
         *Unregister Network Recipient
         ** @param context context
         */
        fun unregisterNetConnChangedReceiver(context: Context) {
            context.unregisterReceiver(sNetConnChangedReceiver)
            sNetConnChangedListeners.clear()
        }

        /**
         *Add network status change monitoring
         *
         *Param listener listens for changes in network connection status
         */
        fun addNetConnChangedListener(listener: NetConnChangedListener) {
            val result = sNetConnChangedListeners.add(listener)
            log("addNetConnChangedListener: $result")
        }

        /**
         *Remove specified network change monitoring
         *
         *Param listener listens for changes in network connection status
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
                
            }
        }

        private fun isNetworkAvailable(context: Context): Boolean {
            val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val network = connectivityManager.activeNetwork
                val capabilities = connectivityManager.getNetworkCapabilities(network)
                return capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) == true
            } else {
                val networkInfo = connectivityManager.activeNetworkInfo
                return networkInfo?.isConnected == true
            }
        }
    }
}
