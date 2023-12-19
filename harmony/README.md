# react-native-video
添加鸿蒙支持，C端代码和原生端代码位于 `harmony/rn_video` 下，与 `android` 和 `ios` 对齐。

原版readme：[README-org.md](./README-org.md)

## 目录


- [react-native-video](#react-native-video)
  - [目录](#目录)
    - [\[Pack Instructions\] 打包说明](#pack-instructions-打包说明)
    - [\[Instructions\] 快速使用说明](#instructions-快速使用说明)
    -- [\[Instructions\] 安卓侧使用](#instructions-安卓侧使用)
    -- [\[Instructions\] 鸿蒙侧使用](#instructions-鸿蒙侧使用)
    - [\[JS-Instructions\] JS使用说明](#js-instructions-js使用说明)
    - [效果展示](#效果展示)
    - [\[Attributes\] 属性（接口）说明](#attributes-属性接口说明)
    - [\[Other Information\] 其他信息](#other-information-其他信息)
    

### <a name="pack-instructions-打包说明" />[[Pack Instructions] 打包说明]()
- 使用DevEco Studio打开`react-native-video/harmony`
- 点击 `Build` → `Make Module 'rn_video'`
- 得到 `build/outputs/default/rn_video.har`，并复制到 `harmony`目录下。
- 进入 `react-native-video` 目录下
- 初始化，安装依赖。
```sh
yarn
```
- 安装完后会自动执行`npm run bob build`
- 打包
```sh
npm pack
```
获得 `react-native-video-x.x.x.tgz`

### <a name="instructions-快速使用说明" />[[Instructions] 快速使用说明]()
- 进入 `fabricexample`目录，编辑 `package.json`，添加：
```diff
  "dependencies": {
    ...
+   "react-native-video": "file:<path>/react-native-video-x.x.x.tgz", (指向刚才打包出来的.tgz文件)
    ...
  },

```
- 执行：
```sh
npm run preinstall
npm i
```

#### <a name="instructions-安卓侧使用" />[[Instructions] 安卓侧使用]()
- 执行：
```sh
yarn android
# 或者
yarn react-native run-android
```

#### <a name="instructions-鸿蒙侧使用" />[[Instructions] 鸿蒙侧使用]()

- 执行：
```sh
npm run dev:rn // 首次运行
npm run dev // 之后运行可以不带:rn命令
```
- 然后需要在鸿蒙工程里引入三方库（该步骤已经配置好）
- 使用DevoEco Studio打开 `fabricexample/harmony`
- 配置 `./harmony/entry/oh-package.json5`
- 配置 `oh-package.json5`
```diff
{
  "license": "ISC",
  "devDependencies": {},
  "name": "entry",
  "description": "example description",
  "repository": {},
  "version": "1.0.0",
  "dependencies": {
    ...
    "rnoh-video": "file:../../node_modules/react-native-video/rn_video.har",
    ...
  }
}
```
- 进入 `entry/src/main/cpp`
- 配置 `CMakeList.txt`
```diff
待更新

```

- 配置 `PackageProvider.cpp`
```diff
待更新
```

- 配置 `ets/RNPackagesFactory.ts`
```diff
待更新
```


- 使用react-native-video库，修改 `ets/pages/index.ets`
```diff
待更新
```

- 然后编译，运行即可

### <a name="js-instructions-js使用说明" />[[JS-Instructions] JS使用说明]()
- 快速使用

```typescript

import React, {useState, useRef} from 'react';
import {View, ScrollView, StyleSheet, Text,TextInput} from 'react-native';
import RNCVideo from 'react-native-video'

function RNCVideoDemo() {  
    
    const [muted, setMuted] = useState(false);
    const [paused, setPaused] = useState(false);
    const [repeat, setRepeat] = useState(true);
    const [disableFocus, setDisableFocus] = useState(false);
    const [uri, setUri] = useState('https://res.vmallres.com//uomcdn/CN/cms/202210/C7 5C7E20060F3E909F2998E13C3ABC03.mp4');
    const [resizeMode, setResizeMode] = useState('none');
    const [seekSec, setSeekSec] = useState(5000);

    const [onVideoLoad, setOnVideoLoad] = useState("onVideoLoad");
    const [onVideoLoadStart, setOnVideoLoadStart] = useState("onVideoLoadStart");
    const [onVideoError, setOnVideoError] = useState("onVideoError");
    const [onVideoProgress, setOnVideoProgress] = useState("onVideoProgress");
    const [onVideoEnd, setOnVideoEnd] = useState("setOnVideoEnd");
    const [onVideoBuffer, setOnVideoBuffer] = useState("onVideoBuffer");
    const [onPlaybackStalled, setOnPlaybackStalled] = useState("onPlaybackStalled");
    const [onPlaybackResume, setOnPlaybackResume] = useState("onPlaybackResume");

    const videoRef = React.useRef<typeof RNCVideo>(null);

    return (
        <View style={styles.container} >
            <Text style={styles.title}>网络视频demo</Text>
        
            <Text style={styles.button_b} onPress={() => {  videoRef.current?.seek(seekSec)}} >seek:{seekSec.toString()}</Text>
        
            <RNCVideo
              style={styles.video}
              ref={videoRef}
              drm={{ type: 'fairplay', certificateUrl: 'sasddd', drmType: "drmfairplay", }}
              source={{ uri: uri }}
              paused={paused}
              muted={muted}
              resizeMode={resizeMode}
              repeat={repeat}
              volume={1}
              disableFocus={disableFocus}
              onLoad={(e) => {
                setOnVideoLoad("onVideoLoad currentTime =" + e.currentPosition + "s duration =" + e     .duration + "s width =" + e.naturalSize.width+ " orientation =" + e.naturalSize.orient    ation)
                setOnVideoError("onVideoError error = ok" )
              }}
              onProgress={(e) => {
                setOnVideoProgress("onVideoProgress currentTime =" + e.currentTime + " playab   leDuration=" + e.playableDuration + " seekableDuration=" + e.seekableDuration)
              }}
              onError={(e) => {
                setOnVideoError("onVideoError error =" + e.error)
              }}
              onEnd={() => {
                setOnVideoEnd("onVideoEnd completed")
              }}
              onBuffer={(e) => {
                setOnVideoBuffer("onVideoBuffer :"+ e.isBuffering)
              }}
              onPlaybackStalled={() => {
                setOnPlaybackStalled("onPlaybackStalled : true")
                setOnPlaybackResume("onPlaybackResume :false")
              }}
              onPlaybackResume={() => {
                setOnPlaybackStalled("onPlaybackStalled :false")
                setOnPlaybackResume("onPlaybackResume :true")
              }}

            ></RNCVideo>

        </View>
     );
}
const styles = StyleSheet.create({
    ...
     container: {
         width: '100%',
         height: '100%',
         backgroundColor: '#333',
     },
     video: {
        width: '100%',
        height: 260,
     }
    ...
})

export default RNCVideoDemo;

```
<a name="效果展示" />**效果展示：**

<img src="./Screenshot.png" width="30%">

### <a name="attributes-属性接口说明" />[[Attributes] 属性（接口）说明]()
#### Configurable props
* [source](#source)
* [disableFocus](#disableFocus)
* [muted](#muted)
* [paused](#paused)
* [repeat](#repeat)
* [resizeMode](#resizemode)
* [volume](#volume)

#### Event props
* [onEnd](#onEnd)
* [onLoad](#onLoad)
* [onProgress](#onProgress)
* [onError](#onError)
* [onBuffer](#onBuffer)
* [onPlaybackStalled](#onPlaybackStalled)
* [onPlaybackResume](#onPlaybackResume)

#### Methods
* [seek](#seek())

#### Configurable props
##### source
Sets the media source. You can pass an asset loaded via require or an object with a uri.

Setting the source will trigger the player to attempt to load the provided media with all other given props. Please be sure that all props are provided before/at the same time as setting the source.

Rendering the player component with a null source will init the player, and start playing once a source value is provided.

Providing a null source value after loading a previous source will stop playback, and clear out the previous source content.

The docs for this prop are incomplete and will be updated as each option is investigated and tested.

##### disableFocus
Determines whether video audio should override background music/audio in Android devices.
* ** false (default)** - Override background audio/music
* **true** - Let background audio/music from other apps play

##### muted
Controls whether the audio is muted
* **false (default)** - Don't mute audio
* **true** - Mute audio

##### paused
Controls whether the media is paused
* **false (default)** - Don't pause the media
* **true** - Pause the media

##### repeat
Determine whether to repeat the video when the end is reached
* **false (default)** - Don't repeat the video
* **true** - Repeat the video

##### resizeMode
Determines how to resize the video when the frame doesn't match the raw video dimensions.
* **"none" (default)** - Don't apply resize
* **"contain"** - Scale the video uniformly (maintain the video's aspect ratio) so that both dimensions (width and height) of the video will be equal to or less than the corresponding dimension of the view (minus padding).
* **"cover"** - Scale the video uniformly (maintain the video's aspect ratio) so that both dimensions (width and height) of the image will be equal to or larger than the corresponding dimension of the view (minus padding).
* **"stretch"** - Scale width and height independently, This may change the aspect ratio of the src.

##### volume
Adjust the volume.
* **1.0 (default)** - Play at full volume
* **0.0** - Mute the audio
* **Other values** - Reduce volume


#### Event props

##### onEnd
Callback function that is called when the player reaches the end of the media.

##### onLoad
Callback function that is called when the media is loaded and ready to play.

Payload:

Property | Type | Description
--- | --- | ---
currentPosition | number | Time in seconds where the media will start
duration | number | Length of the media in seconds
naturalSize | object | Properties:<br> * width - Width in pixels that the video was encoded at<br> * height - Height in pixels that the video was encoded at<br> * orientation - "portrait" or "landscape"


##### onProgress
Callback function that is called every progressUpdateInterval seconds with info about which position the media is currently playing.

Property | Type | Description
--- | --- | ---
currentTime | number | Current position in seconds
playableDuration | number | Position to where the media can be played to using just the buffer in seconds
seekableDuration | number | Position to where the media can be seeked to in seconds. Typically, the total length of the media




#### Methods

#### seek()
`seek(seconds)`

Seek to the specified position represented by seconds. seconds is a float value.

`seek()` can only be called after the `onLoad` event has fired. Once completed, the [onSeek](#onseek) event will be called.



### <a name="other-information-其他信息" />[[Other Information] 其他信息]()

**约束与限制**
- 在下述版本验证通过：
DevEco Studio: 4.0 Canary1(4.0.3.211), SDK: API10 Release(4.0.0(10)),  react: 18.2.0,react-native: 0.71.3

**开源协议**
- 本项目基于 [The MIT License (MIT)](https://github.com/th3rdwave/react-native-safe-area-context/blob/main/LICENSE) ，请自由地享受和参与开源。

