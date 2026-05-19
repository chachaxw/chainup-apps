#### 把contract_sdk,talkingdata_library,dsbridge包放在/bigclient-android目录下
1. 在/bigclient-android/settings.gradle添加<br />
    ```include ':contract_sdk'```

2. 在/bigclient-android/app/build.gradle添加<br />
    ```implementation project(path: ':contract_sdk')```

3. SDK初始化
   >CpMyApp⾥初始化sdk，⾃有Application需要继承CpMyApp(如果APP有多进程，需注意避免SDK多次初始化) (必接)

    在 **onCreate()** ⽅法增加以下初始化:
    ```kotlin
    CpClLogicContractSetting.setApiWsUrl(this,"apiurl","wsurl")
    Handler().postDelayed({
        CpWsContractAgentManager.instance.socketUrl("wsurl", true)
    }, 1500)
   ```

4. 登录/退出登录/⽪肤切换的场景
    登录成功，通知SDK
    ```kotlin
    CpClLogicContractSetting.setToken("token")
    ```
    退出登录，通知SDK
    ```kotlin
    CpClLogicContractSetting.cleanToken();
    ```
    设置⽩天黑夜版本 0 - 白天模式 1 - 夜间模式
    ```kotlin
    CpClLogicContractSetting.setThemeMode(mode);
    ```
5. 在自有**NewMainActivity**中增加合约栏链接⾄**CpContractNewTradeFragment**为合约业务⼊口
