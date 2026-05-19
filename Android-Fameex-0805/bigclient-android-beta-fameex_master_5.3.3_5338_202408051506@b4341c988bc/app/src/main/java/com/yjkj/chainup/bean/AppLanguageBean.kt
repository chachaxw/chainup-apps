package com.yjkj.chainup.bean

import android.os.Parcel
import android.os.Parcelable
import com.google.gson.annotations.SerializedName

/**
 * @Author lianshangljl
 *@ Date 2018/10/22-4:01 PM
 * @Email buptjinlong@163.com
 *@description Get supported languages
 */
data class AppLanguageBean(
        @SerializedName("defLan") var defLan: String ?= "",//Default Language
        @SerializedName("lanList") var lanList: ArrayList<LanguageListBean> ?= arrayListOf()
) : Parcelable {
    constructor(parcel: Parcel) : this(
            parcel.readString(),
            parcel.createTypedArrayList(LanguageListBean)
    )

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeString(defLan)
    }

    override fun describeContents(): Int {
        return 0
    }

    companion object CREATOR : Parcelable.Creator<AppLanguageBean> {
        override fun createFromParcel(parcel: Parcel): AppLanguageBean {
            return AppLanguageBean(parcel)
        }

        override fun newArray(size: Int): Array<AppLanguageBean?> {
            return arrayOfNulls(size)
        }
    }


}
