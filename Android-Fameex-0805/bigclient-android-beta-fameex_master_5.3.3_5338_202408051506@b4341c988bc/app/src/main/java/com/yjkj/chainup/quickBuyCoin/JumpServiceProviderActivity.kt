package com.yjkj.chainup.quickBuyCoin

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import com.alibaba.android.arouter.facade.annotation.Route
import com.yjkj.chainup.R
import com.yjkj.chainup.base.NBaseActivity
import com.yjkj.chainup.db.constant.ParamConstant
import com.yjkj.chainup.db.constant.RoutePath
import com.yjkj.chainup.db.constant.WebTypeEnum
import com.yjkj.chainup.extra_service.arouter.ArouterUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.new_version.view.CommonlyUsedButton
import kotlinx.android.synthetic.main.activity_jump_service_provider.*
import kotlinx.android.synthetic.main.activity_jump_service_provider.img_back
import kotlinx.android.synthetic.main.activity_select_service_provider.*
import java.io.File

@Route(path = RoutePath.JumpServiceProviderActivity)
class JumpServiceProviderActivity : NBaseActivity() {
    override fun setContentView(): Int {
        return  R.layout.activity_jump_service_provider
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val name=intent.getStringExtra("name")
        tv_title.setText(String.format(LanguageUtil.getString(this, "creditCard_text6"),name))
        tv_title_1.setText(String.format(LanguageUtil.getString(this, "creditCard_text7"),name))


        cbtn_confirm.isEnable(true)
        cbtn_confirm.listener=object : CommonlyUsedButton.OnBottonListener{
            override fun bottonOnClick() {
                val urlContent = intent.getStringExtra("urlhtml")
                urlContent?.run {
                    val bundle = Bundle()
                    bundle.putString(ParamConstant.web_url, urlContent)
                    bundle.putString(ParamConstant.head_title, name)
                    if(this.contains("http")){
                        bundle.putInt(ParamConstant.web_type, WebTypeEnum.COMMON_WEB.value)
                    }else{
                        bundle.putInt(ParamConstant.web_type, WebTypeEnum.HTML_INDEX.value)
                    }

                    ArouterUtil.greenChannel(RoutePath.ItemDetailActivity, bundle)
                }


//                openBrowser()
            }
        }
        img_back.setOnClickListener { finish() }
    }

    private fun openBrowser() {
       val intent =  Intent()
        intent.setAction(Intent.ACTION_VIEW)
        val path = "file:///android_asset/service_url.html"
        val file = File(path)
        intent.setData(Uri.fromFile(file))
        if (intent.resolveActivity(this.getPackageManager()) != null) {
             val componentName = intent.resolveActivity(this.getPackageManager())
            startActivity(Intent.createChooser(intent, "选择浏览器"))
        } else {
//            Toast.makeText(context.getApplicationContext(), context.getString(R.string.please_download_browser), Toast.LENGTH_SHORT).show();
        }
    }
}
