package com.yjkj.chainup.manager

import android.content.Context
import android.text.TextUtils
import android.util.Log
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.tencent.mmkv.MMKV
import com.yjkj.chainup.R
import com.yjkj.chainup.bean.ContractMode
import com.yjkj.chainup.bean.coin.CoinBean
import com.yjkj.chainup.net.HttpClient
import com.yjkj.chainup.net.retrofit.NetObserver
import com.yjkj.chainup.treaty.bean.ContractBean
import com.yjkj.chainup.treaty.bean.ContractPublicInfoBean
import com.yjkj.chainup.treaty.bean.ContractSceneList
import com.yjkj.chainup.util.BigDecimalUtils
import com.yjkj.chainup.util.LogUtil
import com.yjkj.chainup.util.StringUtil
import com.yjkj.chainup.util.StringUtils
import io.reactivex.schedulers.Schedulers

/**
 * @Author: Bertking
 * @Date 2023-05-06-19:41
 *@description: Public Information Management Class for Contracts
 */
object Contract2PublicInfoManager {
    val TAG = Contract2PublicInfoManager::class.java.simpleName
    private val mmkv: MMKV?
        get() {
            val mmkv = MMKV.mmkvWithID("contract_public_info")
            return mmkv
        }

    init {
        mmkv
    }


    /**
     *Contract List
     */
    private const val MARKET = "market"

    /**
     *Contract mode
     */
    const val CONTRACT_MODE = "switch"
    /**
     *Default contract
     */
    private const val DEFAULT_CONTRACT = "marketSymbol"

    /**
     *Contract fund flow type
     */
    private const val SCENELIST = "sceneList"

    /**
     *Contract ID
     */
    private const val CONTRACT_ID = "contractId"

    private const val COIN_LIST = "coinList"


    fun getContractPublicInfo() {
        LogUtil.d("Contract2PublicInfoManager", "getContractPublicInfo")
        HttpClient.instance
                .getPublicInfo4Contract()
                .subscribeOn(Schedulers.io())
                .subscribe(object : NetObserver<ContractPublicInfoBean>() {
                    override fun onHandleSuccess(bean: ContractPublicInfoBean?) {
                        
                        val marketJson = Gson().toJson(bean?.market, HashMap<String, ArrayList<ContractBean>>()::class.java)
                        val sceneListJson = Gson().toJson(bean?.sceneList, ArrayList<ContractSceneList>()::class.java)
                        mmkv?.encode(MARKET, marketJson)
                        mmkv?.encode(DEFAULT_CONTRACT, bean?.marketSymbol)
                        mmkv?.encode(SCENELIST, sceneListJson)
                        /**
                         *Contract mode
                         */
                        mmkv?.encode(CONTRACT_MODE, Gson().toJson(bean?.switch, ContractMode::class.java))
                        /**
                         *Store CoinList
                         */
                        mmkv?.encode(COIN_LIST, Gson().toJson(bean?.coinList, HashMap<String, CoinBean>()::class.java))
                    }

                    override fun onHandleError(code: Int, msg: String?) {
                        super.onHandleError(code, msg)
                        
                    }
                })
    }

    /**
     *Obtain all contract information
     */
    fun getContracts(): HashMap<String, ArrayList<ContractBean>> {
        val string = mmkv?.decodeString(MARKET)
        return if (TextUtils.isEmpty(string)) {
            linkedMapOf()
        } else {
            val type = object : TypeToken<HashMap<String, ArrayList<ContractBean>>>() {}.type
            Gson().fromJson(string, type)
        }
    }

    /**
     *Obtain contract list
     *
     *1. Arrange the initial letters in the dictionary order of the contract currency pair naturally,
     *2. The sorting order is: perpetual, current week, next week, current month, and quarter
     *  PS:9ms
     */
    @JvmStatic
    fun getAllContracts(): ArrayList<ContractBean> {
        var arrayList = arrayListOf<ContractBean>()

        if (getContracts().isEmpty()) {
            arrayList
        } else {
            val associateBy = Contract2PublicInfoManager.getContracts().entries.sortedBy {
                it.key
            }
            associateBy.forEach {
                arrayList.addAll(it.value.sortedBy { it.contractType })
            }
        }
        return arrayList
    }


    /**
     *Obtain Currency List
     */
    fun getCoinList(): HashMap<String, CoinBean> {
        val string = mmkv?.decodeString(COIN_LIST, "")
        return if (TextUtils.isEmpty(string)) {
            HashMap<String, CoinBean>()
        } else {
            var type = object : TypeToken<HashMap<String, CoinBean>>() {}.type
            Gson().fromJson(string, type)
        }
    }

    /**
     *@param key Currency name
     *Obtain the corresponding ConBean based on the currency name
     */
    fun getCoinByName(key: String): CoinBean? {
        return getCoinList()[key]
    }


    /**
     *Obtain all contracts under the same market
     * @param market
     */
    fun getContractByMarket(market: String): ArrayList<ContractBean> {
        return getContracts()[market] ?: arrayListOf<ContractBean>()
    }


    /**
     *Obtaining contracts
     *@param contractId Contract ID
     */
    fun getContractByContractId(contractId: Int): ContractBean? {
        return if (getAllContracts().isNotEmpty()) {
            val filter = getAllContracts().filter {
                it.id == contractId
            }
            filter.firstOrNull()
        } else {
            null
        }
    }

    /**
     *Obtain default contract
     */
    private fun getDefaultContract(): ContractBean? {
        return if (getAllContracts().isNotEmpty()) {
            val filter = getAllContracts().filter {
                it.symbol == mmkv?.decodeString(DEFAULT_CONTRACT)
            }
            filter.firstOrNull()
        } else {
            null
        }
    }

    /**
     *Obtain default contract
     */
    fun getSceneList(): ArrayList<ContractSceneList> {
        var sceneList = mmkv?.decodeString(SCENELIST)
        if (TextUtils.isEmpty(sceneList) || !StringUtil.checkStr(sceneList)) {
            return arrayListOf()
        } else {
            val type = object : TypeToken<ArrayList<ContractSceneList>>() {}.type
                    ?: return arrayListOf()
            return Gson().fromJson(sceneList, type)
        }
    }


    /**
     *Obtain corresponding leverage based on contract ID
     */
    fun getLevelsByContractId(contractId: Int): ArrayList<String> {
        val contractBean = getContractByContractId(contractId)
        
        var levels = ArrayList(contractBean?.leverTypes?.split(",") ?: arrayListOf())
        return levels
    }


    /**
     *Save OR to obtain the current contract
     *@param contractId Contract ID
     *Do you want to save @param isSave
     *
     *TODO optimization
     */
    @JvmStatic
    fun currentContractId(contractId: Int? = 0, isSave: Boolean = false): Int {
        return if (isSave) {
            mmkv?.encode(CONTRACT_ID, contractId ?: 0)
            0
        } else {
            mmkv?.decodeInt(CONTRACT_ID, getDefaultContract()?.id ?: 0) ?: 0
        }
    }

    /**
     *TODO optimization -->This method takes about 160ms (try to use as little as possible)
     */
    fun currentContract(lastSymbol: String = ""): ContractBean? {
        return if (getAllContracts().isNotEmpty()) {
            val filter = getAllContracts().filter {
                it.id == currentContractId()
            }

            if (filter.isNotEmpty()) {
                filter.first().lastSymbol = lastSymbol
                filter.first()
            } else {
                null
            }

        } else {
            getDefaultContract()?.lastSymbol = lastSymbol
            getDefaultContract()
        }
    }


    /**
     *Capture data based on 'precision'
     */
    fun cutValueByPrecision(value: String, precision: Int = 4): String {
        val intercept = BigDecimalUtils.divForDown(value, precision).toPlainString()
        return intercept
    }


    /**
     *Capture data based on 'precision'
     *Margin accuracy
     */
    fun cutDespoitByPrecision(value: String, coinName: String = "btc"): String {
        val precision = getCoinByName(coinName)?.showPrecision ?: 8
        val intercept = BigDecimalUtils.divForDown(value, precision).toPlainString()
        return intercept
    }


    /**
     *Intercept data based on "precision" (not recommended for the time being)
     *TODO time-consuming operation (180ms)
     */
    fun cutValueByPrecision(value: String): String {
        var value = value
        if (value.contains("\"")) {
            value = value.replace("\"", "")
        }
        val intercept = BigDecimalUtils.divForDown(value, currentContract()?.pricePrecision
                ?: 4).toPlainString()
        return intercept
    }

    /**
     *@return Contract type+delivery time
     *
     *Perpetual contracts do not display time
     */
    fun getContractType(context: Context, contractType: Int?, settleTime: String?): String {
        val contractTypeName = getContractTypeText(context,contractType)

        var time = ""
        if (contractType != 0) {
            val split = settleTime?.split(" ")
            if (split?.isNotEmpty() == true && split.size >= 2) {
                val yearMonthDay = split[0].split("-")
                if (yearMonthDay.isNotEmpty() && yearMonthDay.size >= 3) {
                    time = yearMonthDay.elementAt(1) + yearMonthDay.elementAt(2)
                }
            }
        }
        return "$contractTypeName  $time"
    }


    fun getContractTypeText(context: Context, contractType: Int?): String {
        val contractBean = getContractByContractId(contractType ?: 0)
        LogUtil.d(TAG,"=====getContractTypeText:${contractBean.toString()}=====")
        return when (contractBean?.contractType) {
            1 -> LanguageUtil.getString(context,"contract_text_currentWeek")
            2 -> LanguageUtil.getString(context,"contract_text_nextWeek")
            3 -> LanguageUtil.getString(context,"noun_date_month")
            4 -> LanguageUtil.getString(context,"noun_date_quarter")

            else -> LanguageUtil.getString(context,"contract_text_perpetual")
        }
    }


    fun getContractType(context: Context, contractId: Int?): String {
        val contractBean = getContractByContractId(contractId ?: 0)
        return getContractType(context, contractBean?.contractType, contractBean?.settleTime)
    }


    /**
     *1- Warehouse division. 0 net position
     *Default net position
     */
    fun isPureHoldPosition(): Boolean {
        val string = mmkv?.decodeString(CONTRACT_MODE, "")
        return if (TextUtils.isEmpty(string)) {
            true
        } else {
            Gson().fromJson(string, ContractMode::class.java)?.isMorePosition ?: "0" == "0"
        }
    }

}
