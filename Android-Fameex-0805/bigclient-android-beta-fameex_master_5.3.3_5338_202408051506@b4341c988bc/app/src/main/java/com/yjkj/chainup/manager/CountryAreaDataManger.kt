package com.yjkj.chainup.manager

import android.text.TextUtils
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.yjkj.chainup.app.ChainUpApp
import com.yjkj.chainup.bean.CountryInfo
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.util.JsonUtils
import java.io.InputStream
import java.nio.charset.Charset

class CountryAreaDataManger private constructor(){
    private val areaDataList = arrayListOf<CountryInfo>()

    init {
        getAreaData()
    }

    fun getAreaDataList():ArrayList<CountryInfo>{
        return areaDataList
    }

    private fun getAreaData() {
        if(areaDataList.size>0) return
        val stream: InputStream = ChainUpApp.appContext.assets.open("area.json")
        val size = stream.available()
        val byteArray = ByteArray(size)
        stream.read(byteArray)
        stream.close()
        val json = String(byteArray, Charset.defaultCharset())
        val jsonobj = JsonParser().parse(json).asJsonObject
        handleData(jsonobj)
    }

    private fun handleData(data: JsonObject?) {
        if(data==null) return
        var allCountry = arrayListOf<CountryInfo>()
        var limtCountry = PublicInfoDataService.getInstance().getLimitCountryList(null)
        if (data.get("countryList").isJsonArray) {
            val countryData = JsonUtils.jsonToList(data.get("countryList").toString(), CountryInfo::class.java)

            countryData.forEach {
                if (!TextUtils.isEmpty(it.dialingCode)) {
                    allCountry.add(it)
                }
            }
            for (bean in limtCountry) {
                for (country in allCountry) {
                    if (country.numberCode == bean) {
                        allCountry.remove(country)
                        break
                    }
                }
            }
            areaDataList.addAll(allCountry)
        }
    }

    companion object {
        val instance:CountryAreaDataManger by lazy(LazyThreadSafetyMode.SYNCHRONIZED){
            CountryAreaDataManger()
        }
    }
}