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

import { Descriptor, RNOHContext, ViewBaseProps, RNViewBase, } from '@rnoh/react-native-openharmony'
import media from '@ohos.multimedia.media';
import { PlayPlayer } from './view/PlayPlayer';
import { VideoController } from './controller/VideoController';
import { PlayConstants } from './common/constants/PlayConstants';
import { CommonConstants, ResizeMode } from './common/constants/CommonConstants';
import Logger from './common/util/Logger';
import { display } from '@kit.ArkUI';
import observer from '@ohos.arkui.observer';

interface NavDestinationState {
  navigationId: string
  name: string
  state: number
  index: number
  param: string
}

class RNCVideoSrcRequestHeaders {
  key: string = ''
  value: string = ''
}

class RNCVideoSrc {
  uri: string = ''
  isNetwork: boolean = true
  isAsset: boolean = false
  shouldCache: boolean = false
  type: string = ''
  mainVer: number = 0
  patchVer: number = 0
  requestHeaders?: RNCVideoSrcRequestHeaders[]
}

export interface RNCVideoProps extends ViewBaseProps {
  controls: boolean
  src: RNCVideoSrc
  paused: boolean
  resizeMode: string
  muted: boolean
  repeat: boolean
  volume: number
  disableFocus: boolean
  preventsDisplaySleepDuringVideoPlayback: boolean
}

export interface AutoLayoutViewState {}

export const RNC_VIDEO_TYPE: string = "RNCVideo"

export type VideoViewDescriptor = Descriptor<"RNCVideo", ViewBaseProps, AutoLayoutViewState, RNCVideoProps>

const RNC_VIDEO_SEEK: string = 'seek'

export interface IRNCVideo {
  videoMargin: string
  viewWidth: number
  viewHeight: number
  onVideoLoadStart: (cUri: string | media.AVFileDescriptor) => void
  onReadyForDisplay: () => void
  onVideoProgress: (currentTime: number, _playableDuration: number, _seekableDuration: number) => void
  onVideoLoad: (startSecond: number, length: number, widthIn: number, heightIn: number, orientationIn: string) => void
  onVideoBuffer: (isBufferingIn: boolean) => void
  onVideoPlaybackStalled: () => void
  onVideoPlaybackResume: () => void
  onVideoEnd: () => void
  onVideoError: (err: string) => void
}

const TAG: string = 'RNOH in RNCVideo'


@Component
export struct RNCVideo {
  ctx!: RNOHContext;
  tag: number = -1;
  @State descriptor: VideoViewDescriptor = Object() as VideoViewDescriptor;
  private callbackList: Array<() => void> = []
  @State videoMargin: string = PlayConstants.PLAY_PAGE.MARGIN_ZERO;
  private playVideoModel: VideoController = new VideoController();
  @Provide('controlsVar') controls: boolean = false;
  @Provide('srcVar') srcParam: string | media.AVFileDescriptor = ''; /*最终avplayer认识的 字符串*/
  @Provide index: number = 0;
  @Provide('mutedVar') muted: boolean = false;
  @Provide('repeatVar') repeat: boolean = false;
  @Provide('pausedVar') paused: boolean = false;
  @Provide('resizeModeVar') resizeMode: string = "none"; /* */
  @Provide('volumeVar') volume: number = PlayConstants.PLAY_PAGE.VOLUME;
  @Provide('disableFocusVar') disableFocus: boolean = false; /* RN侧默认是独占模式传递FALSE过来，鸿蒙默认未共享模式*/
  @Provide('preventsDisplaySleepDuringVideoPlaybackVar') preventsDisplaySleepDuringVideoPlayback: boolean =
    true; /* 默认true*/
  private isResume: boolean = false;
  @State
  viewWidth: number = 0;
  @State
  viewHeight: number = 0;
  @Provide
  videoHeight: number | string = CommonConstants.FULL_PERCENT;
  @Provide
  videoWidth: number | string = CommonConstants.FULL_PERCENT;
  @Provide
  changedViewWidth: number = 0;
  @Provide
  changedViewHeight: number = 0;
  isUserPaused = false
  @Provide
  startSecond: number = 0
  @Provide
  duration: number = 0

  aboutToAppear(): void {

    this.descriptor = this.ctx.descriptorRegistry.getDescriptor<VideoViewDescriptor>(this.tag);
    this.callbackList.push(this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      (newDescriptor) => {
        this.descriptor = (newDescriptor as VideoViewDescriptor);
        /*------ 当RN侧属性props有更改 -------*/
        this.updatePropFromDesc();
        this.videoWidth = this.viewWidth;

        if (display.getDefaultDisplaySync().orientation == 0 || display.getDefaultDisplaySync().orientation == 2) {
          this.videoWidth = CommonConstants.FULL_PERCENT;
          // this.videoHeight = CommonConstants.FULL_PERCENT;
        }
      }
    ))
    this.playVideoModel.initPlayPageThis(this as IRNCVideo);
    /*------ 初始化 -------*/
    this.updatePropFromDesc();
    this.registerCommandCallback();

    this.callbackList.push(this.ctx.rnInstance.subscribeToLifecycleEvents("BACKGROUND", () => {
      this.paused = true
    })
    )
    this.callbackList.push(this.ctx.rnInstance.subscribeToLifecycleEvents("FOREGROUND", () => {
      if (this.isUserPaused) {
        this.paused = true
      } else {
        this.paused = false
      }
    })
    )

    observer.on('navDestinationUpdate', (info) => {
      let navDestinationInfo = JSON.stringify(info)
      let navDestinationState = JSON.parse(navDestinationInfo) as NavDestinationState
      let state = navDestinationState.state
      let index = navDestinationState.index
      //index 是 Navigation 的页面值  video 当前的页面 == 1, state表示当前页面的状态,ON_HIDDEN 为页面隐藏,ON_SHOWN为页面显示
      if ((index == 1 || index == 0) && state == observer.NavDestinationState.ON_HIDDEN) {
        this.paused = true
      }
      if ((index == 1 || index == 0) && state == observer.NavDestinationState.ON_SHOWN) {
        if (this.isUserPaused) {
          this.paused = true
        } else {
          this.paused = false
        }

      }
    });

  }

  aboutToDisappear(): void {
    this.cancellationCallback()
    this.playVideoModel.release();
    observer.off('navDestinationUpdate');
  }

  registerCommandCallback(): void {
    if (this.ctx) {
      this.callbackList.push(this.ctx.componentCommandReceiver.registerCommandCallback(
        this.tag,
        (command, args: (string | number)[]) => {
          if (command === RNC_VIDEO_SEEK) {
            this.playVideoModel.setSeekTime(Number(args[0]));
          }
        }))
    }
  }

  /* 更新属性变更  */
  updatePropFromDesc(): void {
    this.muted = this.descriptor.rawProps.muted
    this.paused = this.descriptor.rawProps.paused
    this.isUserPaused = this.descriptor.rawProps.paused
    this.controls = this.descriptor.rawProps.controls
    this.resizeMode = this.descriptor.rawProps.resizeMode
    this.repeat = this.descriptor.rawProps.repeat
    this.volume = this.descriptor.rawProps.volume
    this.srcParam = this.descriptor.rawProps.src.uri
    this.disableFocus = this.descriptor.rawProps.disableFocus
    this.preventsDisplaySleepDuringVideoPlayback = this.descriptor.rawProps.preventsDisplaySleepDuringVideoPlayback
    this.viewWidth = this.descriptor.layoutMetrics.frame.size.width
    this.viewHeight = this.descriptor.layoutMetrics.frame.size.height
    this.changedViewWidth = this.viewWidth
    this.changedViewHeight = this.viewHeight
    if (this.resizeMode === ResizeMode.COVER) {
      this.videoHeight = this.viewHeight
    }
  }

  /**
   * @brief onVideoLoad callback
   * @param startSecond 开始播放时间
   * @param length 视频长度
   * @param widthIn 视频width
   * @param heightIn 视频height
   * @param orientationIn 视频方向 对标安卓，通过视频宽高比对判断。
   * @return void
   */
  onVideoLoad(startSecond: number, length: number, widthIn: number, heightIn: number, orientationIn: string): void {
    if (this.ctx) {
      this.ctx.rnInstance.emitComponentEvent(this.descriptor.tag, RNC_VIDEO_TYPE, {
        type: "onVideoLoad",
        currentPosition: startSecond,
        duration: length,
        naturalSize: {
          width: widthIn,
          height: heightIn,
          orientation: orientationIn
        },
        audioTracks: this.playVideoModel.audioTracksBeanArr,
        videoTracks: this.playVideoModel.videoTracksBeanArr

      })
      this.startSecond = startSecond
      this.duration = length
    }
  }

  onVideoEnd(): void {
    if (this.ctx) {
      this.ctx.rnInstance.emitComponentEvent(this.descriptor.tag, RNC_VIDEO_TYPE, {
        type: "onVideoEnd"
      })
    }
  }

  /**
   *
   * @author hukang
   * @date 2023/10/18 11:49
   * @param cUri 当前视频URL
   * @return null
   */
  onVideoLoadStart(cUri: string | media.AVFileDescriptor): void {
    if (this.ctx) {
      this.ctx.rnInstance.emitComponentEvent(this.descriptor.tag, RNC_VIDEO_TYPE, {
        type: "onVideoLoadStart",
        isNetwork: this.descriptor.rawProps.src.isNetwork,
        videoType: this.descriptor.rawProps.src.type,
        uri: cUri
      })
    }
  }

  onReadyForDisplay(): void {
    if (this.ctx) {
      this.ctx.rnInstance.emitComponentEvent(this.descriptor.tag, RNC_VIDEO_TYPE, {
        type: "onReadyForDisplay"
      })
    }
  }

  onVideoError(err: string): void {
    if (this.ctx) {
      this.ctx.rnInstance.emitComponentEvent(this.descriptor.tag, RNC_VIDEO_TYPE, {
        type: "onVideoError",
        error: err
      })
    }
  }

  onVideoProgress(time: number, _playableDuration: number = 0, _seekableDuration: number = 0): void {
    if (this.ctx) {
      this.ctx.rnInstance.emitComponentEvent(this.descriptor.tag, RNC_VIDEO_TYPE, {
        type: "onVideoProgress",
        currentTime: time,
        playableDuration: _playableDuration,
        seekableDuration: _seekableDuration
      })
      this.startSecond = time
    }
  }

  onVideoBuffer(isBufferingIn: boolean): void {
    if (this.ctx) {
      this.ctx.rnInstance.emitComponentEvent(this.descriptor.tag, RNC_VIDEO_TYPE, {
        type: "onVideoBuffer",
        isBuffering: isBufferingIn
      })
    }
  }

  onVideoPlaybackStalled(): void {
    if (this.ctx) {
      this.ctx.rnInstance.emitComponentEvent(this.descriptor.tag, RNC_VIDEO_TYPE, {
        type: "onPlaybackStalled"
      })
    }
  }

  onVideoPlaybackResume(): void {
    if (this.ctx) {
      this.ctx.rnInstance.emitComponentEvent(this.descriptor.tag, RNC_VIDEO_TYPE, {
        type: "onPlaybackResume"
      })
    }
  }

  async getFd(): Promise<void> {
    // Logger.debug(TAG, `getFd, ${(this.src)}`);
  }

  onPageHide(): void {
    Logger.debug(TAG, `onPageHide.`);
    this.playVideoModel.pause();
    this.isResume = true;
  }

  cancellationCallback() {
    this.callbackList.forEach(
      callback => {
        callback?.()
      }
    )
  }

  build() {
    RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      PlayPlayer({ playVideoModel: this.playVideoModel, viewWidth: this.viewWidth, viewHeight: this.viewHeight })
        .align(Alignment.Center)
        .height(this.viewHeight)
        .width(this.viewWidth)
    }
  }
}