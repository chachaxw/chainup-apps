# 交易所插件【flutter版本】

这tm的是一个跨端开发的一个程序，下面我写了点步骤，乐意看的就看，不乐意看的就拉倒！

## 1、安装FlutterSdk【推荐 v3.3.0】
+ **下载链接：[点击下载](https://github.com/flutter/flutter/releases/tag/3.3.0)**

+ **解压安装包到你想安装的目录**

  ```javascript
  cd ~/development
  unzip ~/Downloads/flutter_macos_v3.3.0.zip
  ```

+ **添加flutter相关工具到path中：**

  ```javascript
  export PATH=`pwd`/flutter/bin:$PATH
  ```

## 2、clone插件代码

+ **将插件代码【ExFlutterPlugin目录和chainup-ios同级存放】**
  ```javascript
  eg:
  - chainup-ios
      - xx
      - xxx
  - ExFlutterPlugin
      - xx
      - xxx
  ```

+ **在控制台cd到ExFlutterPlugin目录执行命令：**

  ```javascript
  flutter packages get
  ```
+ **在控制台cd到chainup-ios目录执行命令：**

  ```javascript
  pod installl
  ```

+ **运行程序就ok**	