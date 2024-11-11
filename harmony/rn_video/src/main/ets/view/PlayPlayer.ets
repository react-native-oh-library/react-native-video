/**
 * MIT License
 *
 * Copyright (C) 2023 Huawei Device Co., Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import media from '@ohos.multimedia.media';
import { VideoController } from '../controller/VideoController';
import { CommonConstants } from '../common/constants/CommonConstants';
import { PlayConstants } from '../common/constants/PlayConstants';
import Logger from '../common/util/Logger';
import Matrix4 from '@ohos.matrix4'
import mediaquery from '@ohos.mediaquery'
import fs from '@ohos.file.fs';
import { BusinessError } from '@kit.BasicServicesKit';
import { display } from '@kit.ArkUI';

export interface IPlayPlayer {
  muted: boolean
  repeat: boolean
  paused: boolean
  volume: number
  resizeMode: string
  disableFocus: boolean
  preventsDisplaySleepDuringVideoPlayback: boolean
  brightShow: boolean
  volumeShow: boolean
  bright: number
  videoHeight: string
  videoWidth: string
  videoJustifyContent: FlexAlign
  videoAlignItems: HorizontalAlign
  matrix: Matrix4.Matrix4Transit
}

const TAG: string = 'RNOH in ctrl'

@Component
export struct PlayPlayer {
  private playVideoModel: VideoController | undefined = undefined;
  @Consume('srcVar') @Watch("onSrcChanged") srcParam: string; // 视频src
  @Consume index: number;
  @Consume('mutedVar') @Watch("onMutedChanged") muted: boolean;
  @Consume('repeatVar') @Watch("onRepeatChanged") repeat: boolean;
  @Consume('pausedVar') @Watch("onPausedChanged") paused: boolean;
  @Consume('controlsVar') @Watch("onControlsChanged") controls: boolean;
  @Consume('volumeVar') @Watch("onChanged") volume: number;
  @Consume('resizeModeVar') @Watch("onChanged") resizeMode: string;
  @Consume('disableFocusVar') @Watch("onChanged") disableFocus: boolean;
  @Consume @Watch("onChanged") changedViewWidth: number;
  @Consume @Watch("onChanged") changedViewHeight: number;
  @Consume('preventsDisplaySleepDuringVideoPlaybackVar') @Watch("setPreventsDisplaySleepDuringVideoPlaybackModifier") preventsDisplaySleepDuringVideoPlayback: boolean;
  @Provide type: number = CommonConstants.TYPE_LOCAL; //TODO:luoxf 修改td
  @State bright: number = PlayConstants.PLAY_PAGE.BRIGHT;
  /* 不需要显示 */
  @State volumeShow: boolean = PlayConstants.PLAY_PAGE.VOLUME_SHOW;
  @State brightShow: boolean = PlayConstants.PLAY_PAGE.BRIGHT_SHOW;
  private xComponentController: XComponentController = new XComponentController();
  private surfaceID: number = 0;
  @Consume videoHeight: number | string;
  @Consume videoWidth: number | string;
  @State videoJustifyContent: FlexAlign = FlexAlign.Center;
  @State videoAlignItems: HorizontalAlign = HorizontalAlign.Center;
  @State matrix: object = Matrix4.identity();
  private previousSrc: fs.File | string | undefined = undefined
  viewWidth: number = 0;
  viewHeight: number = 0;
  private orientationChange: boolean = true;
  listener = mediaquery.matchMediaSync('(orientation: landscape)');
  @State sliderWidth: number | string = '80%'
  screenWidth: number = 0
  screenHeight: number = 0
  @Consume startSecond: number
  @Consume duration: number
  @State isVisibility: Visibility = Visibility.Hidden
  lastActiveTime: number = Date.now(); // 记录用户最后活跃时间的变量
  inactivityTimerId: number | undefined; // 定时器ID
  INACTIVITY_THRESHOLD = 5000

  aboutToAppear(): void {
    if (this.controls == true) {
      this.setIsVisibility(this.controls)
      this.resetInactivityTimer()
    }

    this.screenWidth = display.getDefaultDisplaySync().width
    this.screenHeight = display.getDefaultDisplaySync().height
    if (this.screenHeight > this.screenWidth) {
      this.sliderWidth = '65%'
    } else {
      this.sliderWidth = '80%'
    }

    this.listenScreenDirection();
    if (this.playVideoModel) {
      this.playVideoModel.initPlayerThis(this as IPlayPlayer);
    }
  }

  closeFsRawFd() {
    if (typeof this.previousSrc === "string") {
      getContext(this).resourceManager.closeRawFd(this.previousSrc, (error: BusinessError) => {
        if (error != null) {
          Logger.debug(TAG, `aboutToDisappear, closeRawFd error is${error.message} error code:${error.code}`);
        } else {
          Logger.debug(TAG, `aboutToDisappear, closeRawFd file succeed`);
        }
      });
    } else if (typeof this.previousSrc === "object") {
      fs.close(this.previousSrc, (err: BusinessError) => {
        if (err) {
          Logger.debug(TAG,
            `aboutToDisappear, close file failed with error message:${err.message},error code:${err.code}`);
        } else {
          Logger.debug(TAG, `aboutToDisappear, close file succeed`);
        }
      });
    }
  }

  aboutToDisappear(): void {
    if (this.playVideoModel) {
      this.playVideoModel.release()
      this.closeFsRawFd()
    }
  }

  // @Watch cb
  onChanged(propName: string): void {
    if (this.playVideoModel) {
      this.playVideoModel.updateProp();
    }
  }

  async preparePlayer(): Promise<string | media.AVFileDescriptor> {
    this.closeFsRawFd()
    return new Promise(async (resolve, reject) => {
      try {
        let src: string | media.AVFileDescriptor = '';
        if (this.srcParam.startsWith('http')) {
          this.type = CommonConstants.TYPE_INTERNET
          src = this.srcParam
          this.previousSrc = undefined
        } else if (this.srcParam.startsWith('asset')) {
          const fileUrl = this.srcParam.split('//')[1];
          let fileDescriptor = await getContext(this).resourceManager.getRawFd(`assets/${fileUrl}`);
          this.previousSrc = `assets/${fileUrl}`
          src = fileDescriptor;
        } else if (this.srcParam.startsWith('file:')) {
          this.previousSrc = fs.openSync(this.srcParam, fs.OpenMode.READ_ONLY)
          src = `fd://${this.previousSrc.fd}`;
        } else {
          this.previousSrc = undefined
          Logger.debug(TAG, `local, finalsrc: ${(src)}`);
        }
        resolve(src)
      } catch (error) {
        reject(error)
      }
    })
  }

  onSrcChanged(propName: string): void {
    Logger.debug(TAG, `onSrcChanged,propName: ${JSON.stringify(propName)}`);
    this.preparePlayer().then((src) => {
      if (this.playVideoModel) {
        this.playVideoModel.switchVideo(src);
      }
    }).catch((err: BusinessError) => {
      Logger.debug(TAG, `onSrcChanged, preparePlayer error message:${err.message},error code:${err.code}`);
    })
  }

  onRepeatChanged(propName: string): void {
    Logger.debug(TAG, `onRepeatChange, ${JSON.stringify(this.repeat)}`);
    if (this.playVideoModel) {
      this.playVideoModel.switchRepeat(this.repeat);
    }
  }

  onMutedChanged(propName: string): void {
    Logger.debug(TAG, `onMutedChanged, ${JSON.stringify(this.muted)}`);
    if (this.playVideoModel) {
      this.playVideoModel.switchMuted(this.muted);
    }
  }

  onPausedChanged(propName: string): void {
    Logger.debug(TAG, `onPausedChanged, ${JSON.stringify(this.paused)}`);

    if (this.paused == false) {
      setTimeout((): void => this.setIsVisibility(false), 5000);
    }

    if (this.playVideoModel) {
      this.playVideoModel.switchPlayOrPause(this.paused);
    }
  }

  onControlsChanged(propName: string): void {
    Logger.debug(TAG, `onControlsChanged, ${JSON.stringify(this.controls)}`);
  }

  setPreventsDisplaySleepDuringVideoPlaybackModifier(propName: string): void {
    if (this.playVideoModel) {
      this.playVideoModel.setPreventsDisplaySleepDuringVideoPlaybackModifier(this.preventsDisplaySleepDuringVideoPlayback);
    }
  }

  listenScreenDirection(): void {
    this.listener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.orientationChange = false
      this.screenWidth = display.getDefaultDisplaySync().width
      this.screenHeight = display.getDefaultDisplaySync().height
      if (this.screenHeight > this.screenWidth) {
        this.sliderWidth = '65%'
      } else {
        this.sliderWidth = '80%'
      }
    })
  }

  formatSecondsToString(totalSeconds: number): string {
    // 计算小时数
    const hours = Math.floor(totalSeconds / 3600);
    // 计算剩余的秒数，用于计算分钟和最终的秒数
    const remainingSeconds = totalSeconds % 3600;
    // 计算分钟数
    const minutes = Math.floor(remainingSeconds / 60);
    // 计算最终的秒数，这里不需要小数部分，所以直接取整
    const seconds = Math.floor(remainingSeconds % 60);

    // 使用字符串模板和字符串插值，结合 padStart 方法来确保每个部分都是两位数
    return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
  }

  setIsVisibility(isShow: boolean) {
    if (isShow) {
      this.isVisibility = Visibility.Visible
    } else {
      this.isVisibility = Visibility.Hidden
    }
  }

  resetInactivityTimer() {
    // 更新最后活跃时间，并清除（如果需要的话）然后重新设置定时器
    this.lastActiveTime = Date.now();
    if (this.inactivityTimerId !== undefined) {
      clearTimeout(this.inactivityTimerId);
    }
    this.inactivityTimerId = setTimeout((): void => this.hideContent(), this.INACTIVITY_THRESHOLD);
  }

  hideContent() {
    // 如果当前时间减去最后活跃时间大于阈值，则隐藏内容
    if (Date.now() - this.lastActiveTime >= this.INACTIVITY_THRESHOLD) {
      // contentElement.style.backgroundColor = 'gray'; // 或者使用 contentElement.style.display = 'none'; 来完全隐藏
      this.setIsVisibility(false)
      console.log('内容已隐藏，因为5秒内没有操作。');
    }
  }

  build() {
    Stack() {
      Column() {
        XComponent({
          id: PlayConstants.PLAY_PLAYER.ID,
          type: PlayConstants.PLAY_PLAYER.TYPE,
          libraryname: PlayConstants.PLAY_PLAYER.LIBRARY_NAME,
          controller: this.xComponentController
        })
          .onLoad(async () => {
            this.xComponentController.setXComponentSurfaceSize({
              surfaceWidth: PlayConstants.PLAY_PLAYER.SURFACE_WIDTH,
              surfaceHeight: PlayConstants.PLAY_PLAYER.SURFACE_HEIGHT
            });
            this.surfaceID = Number(this.xComponentController.getXComponentSurfaceId());
            this.preparePlayer().then((src) => {
              if (this.playVideoModel) {
                this.playVideoModel.firstPlay(this.index, src, this.surfaceID);
              }
            }).catch((err: BusinessError) => {
              Logger.debug(TAG, `onSrcChanged, preparePlayer error message:${err.message},error code:${err.code}`);
            })

          })
          .width(this.videoWidth)
          .height(this.videoHeight)
          .scale(this.matrix)
      }
      .width(this.changedViewWidth)
      .height(this.changedViewHeight)
      .alignItems(this.videoAlignItems)
      .justifyContent(this.videoJustifyContent);

      Column() {
        Row() {
        }.height("20%")

        Image(this.paused ? $r('app.media.ic_play') : $r('app.media.ic_pause'))
          .width(50)
          .height(50)
          .onClick(() => {
            this.paused = !this.paused
          })
        Row() {
          Image(this.paused ? $r('app.media.ic_play') : $r('app.media.ic_pause'))
            .width(20)
            .height(20)
            .onClick(() => {
              this.paused = !this.paused
            })
          Text(this.formatSecondsToString(this.startSecond))
            .fontSize('10')
            .fontColor(Color.White)
            .margin({ left: 10 })

          Slider({
            value: this.startSecond,
            min: 0,
            max: this.duration
          })
            .width(this.sliderWidth)
            .margin({ left: 5 })
            .onChange((value: number, mode: SliderChangeMode) => {
              setTimeout(() => this.playVideoModel?.setSeekTime(value), 100);
            })

          Text(this.formatSecondsToString(this.duration))
            .fontSize('10')
            .fontColor(Color.White)
            .margin({ left: 5 })

        }.width("90%")
        .height("20%")
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .visibility(this.isVisibility)
    }.width(this.changedViewWidth)
    .height(this.changedViewHeight)
    .onTouch(() => {
      if (this.controls == true) {
        this.setIsVisibility(true)
        this.resetInactivityTimer()
      }
    })
  }
}