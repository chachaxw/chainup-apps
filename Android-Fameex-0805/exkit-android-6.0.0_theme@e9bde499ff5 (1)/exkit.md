## Exkit（6.0.0_theme）
#### 如何打包生成aar？
```groovy
gradlew :exkit:assembleRelease
```
_执行成功后在exkit的/exkit-android/exkit/build/outputs/aar/目录下_

#### 如何解压aar进行修改资源文件？
```unzip 待解压的aar文件 -d aar资源文件目录名```
> unzip myLib.aar -d tempFolder

#### 修改后如何二次打包aar？
> jar cvf 新的aar名称.aar -C tempFolder/ .

### 最终aar要放置在 /主工程/app/libs/exkit-release.aar的位置即可，aar的名字永久为exkit-release保持不变