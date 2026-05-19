package com.yjkj.chainup.new_version.activity

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.text.TextUtils
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import com.yjkj.chainup.R
import com.yjkj.chainup.db.service.PublicInfoDataService
import com.yjkj.chainup.db.service.RateDataService
import com.yjkj.chainup.extra_service.eventbus.MessageEvent
import com.yjkj.chainup.extra_service.eventbus.NLiveDataUtil
import com.yjkj.chainup.manager.LanguageUtil
import com.yjkj.chainup.model.model.MainModel
import com.yjkj.chainup.net_new.rxjava.NDisposableObserver
import com.yjkj.chainup.util.Utils
import com.yjkj.chainup.util.permissionIsGranted
import io.reactivex.disposables.Disposable
import kotlinx.android.synthetic.main.activity_splash.*
import org.json.JSONObject

class SplashActivity : AppCompatActivity() {
    var disposable:Disposable? = null

    companion object {
        const val PERMISSION_REQUEST_CODE_STORAGE: Int = 101
        val REQUEST_PERMISSIONS = arrayOf(android.Manifest.permission.READ_EXTERNAL_STORAGE, android.Manifest.permission.CAMERA,
                android.Manifest.permission.READ_PHONE_STATE, android.Manifest.permission.WRITE_EXTERNAL_STORAGE)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash)
        if (Utils.checkDeviceHasNavigationBar2(this)) {
            iv_splash?.visibility = View.GONE
            rl_splash?.setBackgroundResource(R.drawable.bg_splash)
        }

        if (!this.isTaskRoot) {
            if (intent?.action != null) {
                if (intent.hasCategory(Intent.CATEGORY_LAUNCHER) && Intent.ACTION_MAIN.equals(intent.action)) {
                    finish()
                    return
                }
            }
        }
//        if (hasPermission()) {
        val hasData = PublicInfoDataService.getInstance().getData(null) != null
        if(hasData) {
            Handler().postDelayed({ goHome() }, 150)
            return
        }
        disposable = MainModel().public_info_v4(object :NDisposableObserver(){
            override fun onResponseSuccess(jsonObject: JSONObject) {
                var data = jsonObject.optJSONObject("data")
                PublicInfoDataService.getInstance().saveData(data)
                if (null != data && data.length() > 0) {
                    var rate = data.optJSONObject("rate")
                    RateDataService.getInstance().saveData(rate)
                }
                Handler().postDelayed({ goHome() }, 150)
            }
            override fun onResponseFailure(code: Int, msg: String?) {
                super.onResponseFailure(code, msg)
                Handler().postDelayed({ goHome() }, 150)
            }
        })

//        } else {
//            requestPermission()
//        }
    }


    override fun onDestroy() {
        super.onDestroy()
        disposable?.dispose()
    }
    fun goHome() {
        startActivity(Intent(this@SplashActivity, NewMainActivity::class.java))//
        finish()
    }

    override fun onRestart() {
        super.onRestart()
        //The first time the user denies permission, the home key exits the application, and then comes back to prompt for authorization again
//        if (hasPermission()) {
            Handler().postDelayed({ goHome() }, 150)
//        } else {
//            requestPermission()
//        }
    }
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        if (PERMISSION_REQUEST_CODE_STORAGE == requestCode) {
            if (permissions.isNotEmpty() && grantResults.permissionIsGranted()) {
                goHome()
            }else if (! ActivityCompat.shouldShowRequestPermissionRationale
                    (this, android.Manifest.permission.READ_EXTERNAL_STORAGE)){
                /**
                 *Users can proceed here by clicking 'reject' and not asking again
                 *You can directly jump to the settings interface to open permissions or pop up a toast prompt for users to open permissions
                 *ToastUtils. showToast ("Please grant corresponding permissions in system settings")
                 */
            }
            return
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    private fun hasPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            checkSelfPermission(android.Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED
                    && checkSelfPermission(android.Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
                    && checkSelfPermission(android.Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED
                    && checkSelfPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
        } else true
    }

    private fun requestPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            requestPermissions(REQUEST_PERMISSIONS, PERMISSION_REQUEST_CODE_STORAGE)
        }
    }


    override fun onBackPressed() {
        return
    }

}
