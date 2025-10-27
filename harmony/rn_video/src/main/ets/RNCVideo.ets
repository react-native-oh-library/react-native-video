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
import {Descriptor, RNComponentContext, RNViewBase } from '@rnoh/react-native-openharmony';
import { RNC } from "./generated"
import media from '@ohos.multimedia.media';
import { PlayPlayer } from './view/PlayPlayer';
import { VideoController } from './controller/VideoController';
import { PlayConstants } from './common/constants/PlayConstants';
import { CommonConstants, ResizeMode } from './common/constants/CommonConstants';
import Logger from './common/util/Logger';
import { display } from '@kit.ArkUI';
import observer from '@ohos.arkui.observer';
import { emitter } from '@kit.BasicServicesKit';
import {VIDEO_EVENT_ID, EventType} from './VideoManagerTurboModule'
import {VideoManagerTurboModule} from './VideoManagerTurboModule'
import { AudioTracksBean, VideoTracksBean } from './common/bean/AudioTracksBean';
import { PipManager } from './controller/PipManager';

interface NavDestinationState {
  navigationId: string
  name: string
  state: number
  index: number
  param: string
}
interface TimedMetadataItem {
  value?: string;
  identifier: string;
}
interface AudioTrackItem {
  index: number;
  title?: string;
  language?: string;
  bitrate?: number;
  type?: string;
  selected?: boolean;
}
interface TextTrackItem {
  index: number;
  title?: string;
  language?: string;
  type?: string;
  selected?: boolean;
}
interface VideoTrackItem {
  index: number,
  tracksId?: string,
  codecs?: string,
  width?: number,
  height?: number,
  bitrate?: number,
  selected?: boolean
}
export interface ControlsStyles {
  hidePosition?: boolean;
  hidePlayPause?: boolean;
  hideForward?: boolean;
  hideRewind?: boolean;
  hideNext?: boolean;
  hidePrevious?: boolean;
  hideFullscreen?: boolean;
  hideSeekBar?: boolean;
  hideDuration?: boolean;
  hideNavigationBarOnFullScreenMode?: boolean;
  hideNotificationBarOnFullScreenMode?: boolean;
  hideSettingButton?: boolean;
  seekIncrementMS?: number;
  liveLabel?: string;
}
interface RNCVideoSrcDrmHeadersStruct {
  name: string;
  value: string;
}
interface RNCVideoSrcDrmStruct {
  type?: string;
  licenseServer?: string;
  headers?: Array<RNCVideoSrcDrmHeadersStruct>;
  contentId?: string;
  certificateUrl?: string;
  base64Certificate?: boolean;
}

export interface AutoLayoutViewState {}
export const RNC_VIDEO_TYPE: string = "RNCVideo"
const TAG: string = 'RNCVideo'

@Component
export struct RNCVideo {
  public static readonly NAME = RNC.RNCVideo.NAME
  public static  instance : RNCVideo;
  public ctx!: RNComponentContext
  public  tag: number = -1;
  @State private descriptorWrapper: RNC.RNCVideo.DescriptorWrapper = {} as RNC.RNCVideo.DescriptorWrapper
  private eventEmitter: RNC.RNCVideo.EventEmitter | undefined = undefined
  @Provide index: number = 0;
  @State videoMargin: string = PlayConstants.PLAY_PAGE.MARGIN_ZERO;
  @Provide('controlsVar') controls: boolean = false;
  @Provide('srcVar') srcParam: string | undefined = ''; /*最终avplayer认识的 字符串*/
  @Provide('drmVar') drm: RNCVideoSrcDrmStruct | undefined = undefined
  @Provide('startPosVar') startPosition: number | undefined = 0;
  @Provide('cropStartVar') cropStart: number | undefined = 0;
  @Provide('cropEndVar') cropEnd: number | undefined = 0;
  @Provide('mutedVar') muted: boolean = false;
  @Provide('fullscreenVar') fullscreen: boolean = false;
  @Provide ('extFullscreenVar') @Watch("extFullscreenChanged") extFullscreen: boolean = false;
  @Provide('repeatVar') repeat: boolean = false;
  @Provide('pausedVar') paused: boolean = false;
  @Provide('resizeModeVar') resizeMode: string = "none"; /* */
  @Provide('volumeVar') volume: number = PlayConstants.PLAY_PAGE.VOLUME;
  @Provide('disableFocusVar') disableFocus: boolean = false; /* RN侧默认是独占模式传递FALSE过来，鸿蒙默认未共享模式*/
  @Provide('currentPlaybackTimeV') currentPlaybackTime : number = 0.00;
  @Provide('preventsDisplaySleepDuringVideoPlaybackVar') preventsDisplaySleepDuringVideoPlayback: boolean =
    true; /* 默认true*/
  @Provide('viewTypeVar') viewType: number = 1; /*1 surface 0 texture*/
  @Provide('rateVar') rate: number = PlayConstants.PLAY_PAGE.PLAY_SPEED; /*1 surface 0 texture*/
  @Provide('selectedTextTrackType') textTrackType :string | undefined = 'index';
  @Provide('selectedTextTrackValue') textTrackValue :string | undefined = '';
  @Provide('selectedAudioTrackType') audioTrackType :string | undefined = 'index';
  @Provide('selectedAudioTrackValue') audioTrackValue :string | undefined = '';
  @Provide('selectedVideoTrackType') videoTrackType :string | undefined = 'index';
  @Provide('selectedVideoTrackValueV') selectedVideoTrackValue :string | undefined = '';
  @Provide('audioOutputVar') audioOutput :string = 'speaker';
  @Provide ('enterpipOnLeaveVar') @Watch("pipOnLeaveChange") enterPipOnLeave: boolean = false;
  @Provide ('disableDisconnectErrorVar') disableDisconnectError: boolean = false
  @Provide('controlsStylesVar') controlsStyles: ControlsStyles | undefined = undefined;
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
  @Provide
  isUserPaused: boolean = false
  @Provide
  startSecond: number = 0
  @Provide
  duration: number = 0
  private callbackList: Array<() => void> = []
  public playVideoModel: VideoController = new VideoController();
  private isResume: boolean = false;
  private event: emitter.InnerEvent = {
    eventId : VIDEO_EVENT_ID,
    priority : emitter.EventPriority.HIGH
  };
  private callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {

  let tag: number = eventData.data?.tag
  if (tag !== this.descriptorWrapper.tag) {
    return;
  }
  let event: number  = eventData.data?.event;
  switch (event) {
    case EventType.SETSOURCECMD:
      try {
        const uri: string = eventData.data?.uri;
        if (uri && uri.length > 0) {
          this.playVideoModel.switchVideo(uri);
        }
      } catch (error) {
        Logger.error(TAG, `Error extracting URI or switching video: ${error.message}`);
      }
      break;
    case EventType.SETVOLUMECMD:
      const _volume:number = eventData.data?.volume;
      this.volume = _volume;
      break;
    case EventType.SEEKCMD:
      const _time:number = eventData.data?.time;
      this.playVideoModel.setSeekTime(_time);
      break;
    case EventType.SETPLAYERPAUSESTATECMD:
      const _paused:boolean = eventData.data?.paused;
      this.playVideoModel.switchPlayOrPause(_paused);
      break;
    case EventType.SETLICENSERESULTCMD:
    case EventType.SETLICENSERESULTERRORCMD:
      break;
    case EventType.SETFULLSCREENCMD:
      this.playVideoModel.pipManager.stopPip()

      const _fullscreen: boolean = eventData.data?.fullScreen;
      this.fullscreen = _fullscreen;
      this.extFullscreen = !_fullscreen;
      break;
    case EventType.ENTERPICTUREINPICTURECMD:
      this.playVideoModel.pipManager.stopPip()
      this.playVideoModel.pipManager.setVideoController(this.playVideoModel)
      this.playVideoModel.pipManager.setXComponentController(this.playVideoModel.getController())
      this.playVideoModel.pipManager.init(getContext(this)).then(()=>{
        this.playVideoModel.pipManager.startPip()
      })
      break;
    case EventType.EXITPICTUREINPICTURECMD:
      this.playVideoModel.pipManager.stopPip()
      break;
    case EventType.SAVE:
      break;
    case EventType.GETCURRENTPOSITION:
      VideoManagerTurboModule.currentPos = this.currentPlaybackTime
      break;
    default:
      break;
  }
}
  constructor() {
    super();
    RNCVideo.instance = this;
  }

  aboutToAppear() {
    this.eventEmitter = new RNC.RNCVideo.EventEmitter(this.ctx.rnInstance, this.tag);
    this.onDescriptorWrapperChange(this.ctx.descriptorRegistry.findDescriptorWrapperByTag<RNC.RNCVideo.DescriptorWrapper>(this.tag)!)
    this.callbackList.push(this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      (_descriptor, newDescriptorWrapper) => {
        // Logger.error(TAG, `newDescriptorWrapper: ${JSON.stringify(newDescriptorWrapper)}`);
        this.onDescriptorWrapperChange(newDescriptorWrapper! as RNC.RNCVideo.DescriptorWrapper)
        this.updatePropFromDesc();
        if (display.getDefaultDisplaySync().orientation == 0 || display.getDefaultDisplaySync().orientation == 2) {
          this.videoWidth = CommonConstants.FULL_PERCENT;
          // this.videoHeight = CommonConstants.FULL_PERCENT;
        }
      }
    ))
    this.playVideoModel.initPlayPageThis(this);
    this.updatePropFromDesc();
    this.registerCommandCallback();
    this.videoWidth = this.viewWidth;
    this.videoHeight = this.viewHeight;

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
    }))
    observer.on('navDestinationUpdate', this.navDestinationCallback);

  }

  registerCommandCallback(): void {
    // 定义一个事件的回调处理函数，当收到对应的事件后执行回调函数

    // 收到eventId为1的事件后执行回调函数
    emitter.on(this.event, this.callback);
  }

  private onDescriptorWrapperChange(descriptorWrapper: RNC.RNCVideo.DescriptorWrapper) {
    this.descriptorWrapper = descriptorWrapper
  }

  aboutToDisappear() {
    this.playVideoModel.isPiPWindowLoad = false;
    this.callbackList.forEach(cb => cb())
    this.playVideoModel.release();
    this.playVideoModel.pipManager.stopPip();
    this.playVideoModel.pipManager.setAutoStart(false);
    //销毁 navDestinationCallback
    observer.off('navDestinationUpdate', this.navDestinationCallback);
    emitter.off(this.event.eventId, this.callback);
  }

  build() {
    Column(){
      RNViewBase({ ctx: this.ctx, tag: this.tag }) {
        PlayPlayer({ playVideoModel: this.playVideoModel, viewWidth: this.viewWidth, viewHeight: this.viewHeight })
          .align(Alignment.Center)
          .height(this.viewHeight)
          .width(this.viewWidth)
      }
    }
  }

  updatePropFromDesc(): void {
    // Logger.error(TAG,"updatePropFromDesc : "+ this.descriptorWrapper.props);
    this.muted = this.descriptorWrapper.props.muted!== undefined ?this.descriptorWrapper.props.muted:this.muted
    this.viewType = this.descriptorWrapper.props.viewType;
    this.paused = this.descriptorWrapper.props.paused
    this.isUserPaused = this.descriptorWrapper.props.paused
    this.controls = this.descriptorWrapper.props.controls
    this.fullscreen =  this.descriptorWrapper.props.fullscreen !== undefined
      ? this.descriptorWrapper.props.fullscreen:this.fullscreen;
    this.resizeMode = this.descriptorWrapper.props.resizeMode
    this.repeat = this.descriptorWrapper.props.repeat !== undefined?this.descriptorWrapper.props.repeat:false;
    this.volume = this.descriptorWrapper.props.volume !== undefined?this.descriptorWrapper.props.volume:1.0;
    this.srcParam = this.descriptorWrapper.props.src?.uri
    this.startPosition = this.descriptorWrapper.props.src?.startPosition
    this.cropStart = this.descriptorWrapper.props.src?.cropStart
    this.cropEnd = this.descriptorWrapper.props.src?.cropEnd

    this.disableFocus = this.descriptorWrapper.props.disableFocus
    this.preventsDisplaySleepDuringVideoPlayback = this.descriptorWrapper.props.preventsDisplaySleepDuringVideoPlayback
    this.viewWidth = this.descriptorWrapper.width
    this.viewHeight = this.descriptorWrapper.height
    this.rate = this.descriptorWrapper.props.rate;
    this.textTrackType = this.descriptorWrapper.props.selectedTextTrack?.type
    this.textTrackValue = this.descriptorWrapper.props.selectedTextTrack?.value
    this.audioTrackType = this.descriptorWrapper.props.selectedAudioTrack?.type
    this.audioTrackValue = this.descriptorWrapper.props.selectedAudioTrack?.value
    this.videoTrackType = this.descriptorWrapper.props.selectedVideoTrack?.type
    this.selectedVideoTrackValue = this.descriptorWrapper.props.selectedVideoTrack?.value
    this.audioOutput = this.descriptorWrapper.props.audioOutput
    this.changedViewWidth = this.viewWidth
    this.changedViewHeight = this.viewHeight
    this.enterPipOnLeave = this.descriptorWrapper.props.enterPictureInPictureOnLeave
    this.disableDisconnectError = this.descriptorWrapper.props.disableDisconnectError
    this.controlsStyles = this.descriptorWrapper.props.controlsStyles;

    if (this.resizeMode === ResizeMode.COVER) {
      this.videoHeight = this.viewHeight
    }
  }

  onVideoLoadStart(cUri: string | media.AVFileDescriptor): void {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoLoadStart", {
      isNetwork: this.descriptorWrapper.props.src?.isNetwork,
      videoType: this.descriptorWrapper.props.src?.type,
      uri: cUri
    })
  }
  onReadyForDisplay(): void {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "readyForDisplay", {})
  }
  onVideoProgress(time: number, _playableDuration: number = 0, _seekableDuration: number = 0): void {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoProgress", {
      currentTime: time,
      playableDuration: _playableDuration,
      seekableDuration: _seekableDuration
    })
    this.currentPlaybackTime = time;
    VideoManagerTurboModule.currentPos = time;
    this.startSecond = time
  }
  onVideoLoad(startSecond: number, length: number, widthIn: number, heightIn: number, orientationIn: string,
    mdes:Array<media.MediaDescription>): void {
    if (this.ctx) {
      // Process media descriptions to extract audio/video tracks
      const audioTracks: Array<AudioTracksBean> = [];
      const videoTracks: Array<VideoTracksBean> = [];
      // Logger.error(TAG, `MediaDescription：${JSON.stringify(mdes)}`);
      this.playVideoModel.getSelectTracks().then(dess =>{
        // Logger.error(TAG, `getSelectTracks：${JSON.stringify(dess)}`);
        mdes.forEach((des, index) => {
          // Extract audio tracks
          if ((des.track_name as string)?.startsWith('audio')) {
            audioTracks.push({
              index: des.track_index as number,
              type: des.track_type as number + '',
              bitrate: des.bitrate as number,
              language: des.language as string,
              title: des.title as string,
              selected: dess.includes(des.track_index as number)
            });
          }
          // Extract video tracks
          else if ((des.track_name as string)?.startsWith('video')) {
            videoTracks.push({
              index: des.track_index as number,
              selected: des.track_index as number === 0,
              width: des.width as number,
              height: des.height as number,
              bitrate: des.bitrate as number,
              codecs: des.codec_mime as string,
              trackId:des.track_type as number
            });
          }
        });

        // Update playVideoModel with the extracted tracks
        this.playVideoModel.audioTracksBeanArr = audioTracks;
        this.playVideoModel.videoTracksBeanArr = videoTracks;

        this.ctx.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoLoad", {
          currentPosition: startSecond,
          duration: length,
          naturalSize: {
            width: widthIn,
            height: heightIn,
            orientation: orientationIn
          },
          audioTracks: this.playVideoModel.audioTracksBeanArr,
          videoTracks: this.playVideoModel.videoTracksBeanArr
        });
      })

      this.startSecond = startSecond;
      this.duration = length;
    }
  }
  onVideoBuffer(isBufferingIn: boolean): void {
    if (this.ctx) {
      this.ctx.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoBuffer", {
        isBuffering: isBufferingIn
      })
    }
  }
  onVideoEnd(): void {
    if (this.repeat == undefined || this.repeat == false) {
      this.paused = true
    }
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoEnd", {})
  }
  onVideoError(err: string): void {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoError", {
      error: err
    })
  }
  onControlsVisibilityChange(_isVisibled: boolean) {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "controlsVisibilityChange", {
      isVisible:_isVisibled
    })
  }
  onVideoAspectRatio(_width: number, _height: number) {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoAspectRatio", {
      width:_width,
      height:_height
    })
  }
  onVideoBandwidthUpdate(_bitrate: number, _width?: number, _height?: number, _trackId?: number) {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoBandwidthUpdate", {
      bitrate:_bitrate,
      width:_width,
      height:_height,
      trackId:_trackId
    })
  }
  onVideoAudioBecomingNoisy() {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoAudioBecomingNoisy", {})
  }
  onVideoFullscreenPlayerWillPresent() {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoFullscreenPlayerWillPresent", {})
  }
  onVideoFullscreenPlayerDidPresent() {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoFullscreenPlayerDidPresent", {})
  }
  onVideoFullscreenPlayerWillDismiss() {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoFullscreenPlayerWillDismiss", {})
  }
  onVideoFullscreenPlayerDidDismiss() {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoFullscreenPlayerDidDismiss", {})
  }
  onPlaybackRateChange(_playbackRate: number) {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "playbackRateChange", {
      playbackRate:_playbackRate,
    })

  }
  onVolumeChange(_volume: number) {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "volumeChange", {
      volume:_volume,
    })
  }
  onVideoExternalPlaybackChange (isExternalPlaybackActive: boolean) {}
  onGetLicense(licenseUrl: string, loadedLicenseUrl: string, contentId: string, spcBase64: string) {}
  onPictureInPictureStatusChanged(_isActive: boolean) {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "pictureInPictureStatusChanged", {
      isActive:_isActive,
    })
  }
  onRestoreUserInterfaceForPictureInPictureStop() {}
  onReceiveAdEvent(data?: object, event?: string) {}
  onVideoSeek(_currentTime: number, _seekTime: number) {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoSeek", {
      currentTime:_currentTime,
      seekTime:_seekTime
    })
  }
  onVideoPlaybackStateChanged(_isPlaying: boolean, _isSeeking: boolean) {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoPlaybackStateChanged", {
      isPlaying:_isPlaying,
      isSeeking:_isSeeking
    })
  }
  onVideoIdle() {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoIdle", {})
  }
  onAudioFocusChanged(_hasAudioFocus: boolean) {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "audioFocusChanged", {
      hasAudioFocus:_hasAudioFocus
    })
  }
  onTimedMetadata(metadata: TimedMetadataItem[]) {}
  onAudioTracks(_audioTracks: AudioTrackItem[]) {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "audioTracks", {
      audioTracks:_audioTracks
    })
  }
  onTextTracks(textTracks: TextTrackItem[]) {

  }
  onVideoTracks(_videoTracks: VideoTrackItem[]) {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "videoTracks", {
      videoTracks:_videoTracks
    })
  }
  onTextTrackDataChanged(_subtitleTracks: string) {
    this.ctx?.rnInstance.emitComponentEvent(this.descriptorWrapper.tag, "textTrackDataChanged", {
      subtitleTracks:_subtitleTracks
    })
  }
  pipOnLeaveChange(changedPropertyName: string) {
    this.playVideoModel.pipManager.setAutoStart(this.enterPipOnLeave)
  }
  extFullscreenChanged(changedPropertyName: string) {
    if(this.extFullscreen) {
      this.extFullscreen = false
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

  private navDestinationCallback: Callback<NavDestinationInfo> = (info) => {
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
  }
}