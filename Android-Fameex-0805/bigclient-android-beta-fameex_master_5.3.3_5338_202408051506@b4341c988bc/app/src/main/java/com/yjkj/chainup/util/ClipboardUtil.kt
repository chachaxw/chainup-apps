package com.yjkj.chainup.util

import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.widget.TextView
import com.yjkj.chainup.app.ChainUpApp


/**
 * @Author: Bertking
 * @Date 2023/3/7-3:41 PM
 *@description: Clipboard function
 */
object ClipboardUtil {
    /**
     *Copy function
     *@param textView copies its text
     */
    fun copy(textView: TextView) {
        val cm = textView.context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

        if (cm != null) {
            cm.setPrimaryClip(ClipData.newPlainText(null, textView.text))
        }


    }

    /**
     *Copy function
     *@param string target string
     */
    fun copy(string: String) {
        val cm = ChainUpApp.appContext.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        if (cm != null) {
            cm.setPrimaryClip(ClipData.newPlainText(null, string))
        }
    }


    /**
     *Paste function
     *@param textView Target Text Box
     */
    fun paste(textView: TextView) {
        val cm = textView.context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        //Pasteboard has data and is text
        if (null != cm.primaryClipDescription) {
            if (cm.hasPrimaryClip() && cm.primaryClipDescription!!.hasMimeType(ClipDescription.MIMETYPE_TEXT_PLAIN)) {
                val item = cm.primaryClip?.getItemAt(0)
                val text = item?.text ?: ""
                textView.text = text
            }
        }

    }

    /**
     *Obtain data for the pasteboard
     */
    fun paste(mContext: Context): String {
        val cm = mContext.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        //Pasteboard has data and is text
        if (null != cm.primaryClipDescription) {
            if (cm.hasPrimaryClip() && cm.primaryClipDescription!!.hasMimeType(ClipDescription.MIMETYPE_TEXT_PLAIN)) {
                val item = cm.primaryClip?.getItemAt(0)
                val text = item?.text ?: ""
                return text.toString()
            }
        }
        return ""
    }
}
