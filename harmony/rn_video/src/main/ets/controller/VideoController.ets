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

import { drm } from '@kit.DrmKit'
import media from '@ohos.multimedia.media';
import audio from '@ohos.multimedia.audio';
import Logger from '../common/util/Logger';
import { AvplayerStatus, CommonConstants, Events, ResizeMode, CurrentTime } from '../common/constants/CommonConstants';
import { PlayConstants } from '../common/constants/PlayConstants';
import { AudioTracksBean, VideoTracksBean } from '../common/bean/AudioTracksBean';
import { IPlayPlayer } from '../view/PlayPlayer';
import { RNCVideo } from '../RNCVideo';
import Matrix4 from '@ohos.matrix4'
import { display } from '@kit.ArkUI';
import { BusinessError  } from '@kit.BasicServicesKit'
import { PlayPlayer } from '../view/PlayPlayer';
import { PipManager } from './PipManager';

const TAG: string = 'RNVideoController'

@Observed
export class VideoController {
  private avPlayer!: media.AVPlayer;
  private duration: number = 0; /* 视频时间长度 */
  private status: number = 0; /* 这个是自定义的 ，avplayer状态可以获取字符串状态 */
  private loop: boolean = false;
  private index: number = 0;
  private url: string | media.AVFileDescriptor = '';
  private _surfaceId: number = 0;
  private _surfaceIdFull: number = 0;
  private isFullScreen: boolean = false;
  private playSpeed: number = PlayConstants.PLAY_PAGE.PLAY_SPEED;
  private seekTime: number = PlayConstants.PLAY_PROGRESS.SEEK_TIME;
  private playerThis!: IPlayPlayer;
  public playPageThis!: RNCVideo;
  private preMutedVolume: number = 1.0;
  private mMuted: boolean = false;
  private flagtd: boolean = false;
  private isSeeking : boolean = false;
  private mVideoBufferedDuration: number =
    0; // 对标安卓，获取缓冲时间， mVideoBufferedDuration = (int) Math.round((double) (mVideoDuration * percent) / 100.0); playableDuration =  mVideoBufferedDuration / 1000.0
  public audioTracksBeanArr?: AudioTracksBean[];
  public videoTracksBeanArr?: VideoTracksBean[];
  private mPreventsDisplaySleepDuringVideoPlayback: boolean = true; /* 默认true*/
  isPiPWindowLoad: boolean = false; // 是否启动画中画
  isPiPWindowRestore: boolean = false; // 画中画从小窗口复原
  mediaKeySystem: drm.MediaKeySystem | undefined= undefined;
  mediaKeySession: drm.MediaKeySession | undefined= undefined;
  pipManager: PipManager = new PipManager()
  constructor() {
    this.createAVPlayer();
  }
  public setSurfaceIdEx(value: number) {
    if(value != 0) {
      this._surfaceIdFull = value;
      this.isFullScreen = true;
      this.avPlayer.surfaceId = String(this._surfaceIdFull);
    } else {
      this.isFullScreen = false;
      this.avPlayer.surfaceId = String(this._surfaceId);
    }
  }

  public setSurfaceId(value: number) {
    this._surfaceId = value;
  }

  public setIsPiPWindowLoad(value: boolean) {
    this.isPiPWindowLoad = value;
  }
  public setIsPiPWindowRestore(value: boolean) {
    this.isPiPWindowRestore = value;
  }
  public getSurfaceId(): string {
    return String(this._surfaceId);
  }
  public getController():XComponentController {
    return (this.playerThis as PlayPlayer).xComponentController
  }
  /**
   * Creates a videoPlayer object.
   */
  createAVPlayer(): void {
    media.createAVPlayer().then((avPlayer) => {
      if (avPlayer) {
        Logger.info(TAG, `createAVPlayer isNull: ${avPlayer == null}`);
        this.avPlayer = avPlayer;
        this.bindState();
        Logger.info(TAG, `createAVPlayer after bind`);
        if (this.flagtd) {
          this.flagtd = false;
          if (typeof this.url === "string") {
            this.avPlayer.url = this.url;
          } else {
            this.avPlayer.fdSrc = this.url;
          }
          Logger.error(TAG, `createAVPlayer need toplay url,after bind:` + this.url);
        } else {
          Logger.error(TAG, `createAVPlayer noneed toplay url,after bind`);
        }
      } else {
        Logger.error(TAG, '[PlayVideoModel] createAvPlayer fail!');
      }
    });
  }

  /**
   * AVPlayer binding event.
   */
  bindState(): void {
    Logger.info(TAG, `bindState`);
    let lastCalledTime = 0;
    const interval = 500;
    if (this.avPlayer) {
      this.onStateChange();
      this.avPlayer.on(Events.TIME_UPDATE, (time: number) => {
        const currentTime = new Date().getTime();
        if(currentTime-lastCalledTime >= interval){
          this.onVideoProgress(time);
          lastCalledTime = currentTime;
        }
      });

      this.avPlayer.on(Events.DURATION_UPDATE, (durationA) => {
        Logger.info(TAG, `durationUpdate success,new duration is=${durationA}`);
        this.duration = durationA == 0 ? 0 : Math.floor(durationA / 1000); // ms->s
      })

      this.avPlayer.on(Events.ERROR, (error) => {
        Logger.error(TAG, `event error： ${JSON.stringify(error)}`);
        if (this.playPageThis.disableDisconnectError) {
          switch (error.code) {
            case 5411001:
            case 5411002:
            case 5411003:
            case 5411004:
              Logger.info(TAG, 'disableDisconnectError');
              return;
            default:
              break;
          }
        }
        this.playError(JSON.stringify(error));
      })

      this.avPlayer.on(Events.END_OF_STREAM, () => {
        Logger.info(TAG, 'END_OF_STREAM');
        this.onVideoEnd();
      })

      this.avPlayer.on(Events.BUFFERING_UPDATE, (infoType: media.BufferingInfoType, value: number) => {
        /* 播放缓存事件回调方法。BufferingInfoType为BUFFERING_PERCENT或CACHED_DURATION时，value值有效，否则固定为0。 */
        // Logger.error(TAG, 'BUFFERING_UPDATE');
        switch (infoType) {
          case media.BufferingInfoType.BUFFERING_START: // 表示缓存开始，
            // this.onVideoPlaybackStalled(); 6.13.0版本无此接口
            this.onVideoBuffer(true);
            break;
          case media.BufferingInfoType.BUFFERING_END: // 表示缓存结束，
            // this.onVideoPlaybackResume(); 6.13.0版本无此接口
            this.onVideoBuffer(false);
            break;
          case media.BufferingInfoType.BUFFERING_PERCENT: // 表示缓存百分比
            /* 此时的value有值，表示缓存百分比*/
            break;
          case media.BufferingInfoType.CACHED_DURATION: // 表示缓存时长，毫秒（ms）。
            // Logger.error(TAG, `onVideoProgress CACHED_DURATION value = ${value}`);
            this.mVideoBufferedDuration = Math.floor(value / 1000); // ms--?s
            break;
          default:
            break;
        }
      })
      this.avPlayer.on(Events.VOLUMECHANGE, (volume: number) => {
        this.playPageThis.onVolumeChange(volume);
      })
      this.avPlayer.on(Events.AUDIOINTERRUPT, (inter) => {
        this.playPageThis.onAudioFocusChanged(inter.eventType == 2);
      })
      this.avPlayer.on(Events.SPEEDDONE, (speed: number) => {
        this.playPageThis.onPlaybackRateChange(speed);
      })

      this.avPlayer.on(Events.SEEK_DONE, (seekDoneTime: number) => {
        this.playPageThis.onVideoSeek(this.avPlayer.currentTime,this.seekTime);
        this.isSeeking = false;
        this.playPageThis.onVideoPlaybackStateChanged(this.avPlayer.state == AvplayerStatus.PLAYING, this.isSeeking);
        // Logger.info(TAG, `seekDone success,and seek time is: ${seekDoneTime} `);
      })

      this.avPlayer.on(Events.VIDEOSIZECHANGE, (width: number, height: number) => {
        this.playPageThis.onVideoAspectRatio(width, height);
      })


      this.avPlayer.on(Events.TRACKCHANGE, (index, isSelected) => {
        // console.error(TAG,`trackchange ${index}, ${isSelected}`);
        const audioTracks: Array<AudioTracksBean> = [];
        const videoTracks: Array<VideoTracksBean> = [];
        this.avPlayer.getTrackDescription((error, arrList) => {
          if ((arrList) != null) {
            /* 获取到音视频轨道信息后 回传*/
            arrList.forEach(des => {
              if ((des.track_name as string)?.startsWith('audio')) {
                audioTracks.push({
                  index: des.track_index as number,
                  type: des.track_type as number + '',
                  bitrate: des.bitrate as number,
                  language: des.language as string,
                  title: des.title as string,
                  selected: des.track_index as number == index
                });
              }
              // Extract video tracks
              else if ((des.track_name as string)?.startsWith('video')) {
                videoTracks.push({
                  index: des.track_index as number,
                  selected: true,
                  width: des.width as number,
                  height: des.height as number,
                  bitrate: des.bitrate as number,
                  codecs: des.codec_mime as string,
                  trackId:des.track_type as number
                });
              }
            })
            this.playPageThis.onVideoTracks(videoTracks);
            this.playPageThis.onAudioTracks(audioTracks);
          } else {
            Logger.error(TAG, `getTrackDescription fail, error:${error}`);
          }
        });
      });
    }
    Logger.info(TAG, `bindState end`);
  }
  
  setVideoTyped(type:media.VideoScaleType) {
    this.avPlayer.videoScaleType = type;
  }
  getAvPlayer(): media.AVPlayer {
    return this.avPlayer;
  }
  
  /**
   *
   * @author huKang
   * @param null
   * @return null
   */
  onStateChange(): void {
    this.avPlayer.on(Events.STATE_CHANGE, async (state) => {
      switch (state) {
        case AvplayerStatus.IDLE:
          if (typeof this.url === "string") {
            this.avPlayer.url = this.url;
          } else {
            this.avPlayer.fdSrc = this.url;
          }
          this.playPageThis.onVideoIdle();
          break;
        case AvplayerStatus.INITIALIZED:
          if (this.playerThis.disableFocus) {
            let audioRendererInfo = {
              usage: audio.StreamUsage.STREAM_USAGE_GAME,
              rendererFlags: 0
            } as audio.AudioRendererInfo;
            this.avPlayer.audioRendererInfo = audioRendererInfo;
          }
          this.onVideoLoadStart(JSON.stringify(this.url));
          this.avPlayer.surfaceId = String(this._surfaceId);
          this.avPlayer.prepare();
          this.status = CommonConstants.STATUS_INITIALIZED;
          this.watchStatus();
          break;
        case AvplayerStatus.PREPARED:
          this.avPlayer.videoScaleType = 0;
          this.status = CommonConstants.STATUS_PREPARED;
          this.initProps();

          this.watchStatus();
          if (this.playerThis.paused) {
            this.avPlayer.pause();
          } else {
            this.avPlayer.play();
          }
          let startSecond =
            (this.avPlayer.currentTime == CurrentTime.CURRENTTIME_MINUS_ONE ? CurrentTime.CURRENTTIME_ZERO :
            this.avPlayer.currentTime);
          let startPos = this.playPageThis.startPosition
          if (startPos && startPos > 0 && startPos < this.avPlayer.duration) {
            this.avPlayer.seek(startPos)
          }
          this.onVideoLoad(startSecond);
          this.onReadyForDisplay();
          this.pipManager.stopPip()
          this.pipManager.setVideoController(this)
          this.pipManager.setXComponentController(this.getController())
          this.pipManager.init(getContext(this))
          break;
        case AvplayerStatus.PLAYING:
          this.onReadyForDisplay();
          this.status = CommonConstants.STATUS_START;
          this.playPageThis.onVideoPlaybackStateChanged(true, this.isSeeking);
          this.watchStatus();
          break;
        case AvplayerStatus.PAUSED:
          this.status = CommonConstants.STATUS_PAUSE;
          this.playPageThis.onVideoPlaybackStateChanged(false, this.isSeeking);
          this.watchStatus();
          break;
        case AvplayerStatus.COMPLETED:
          //this.duration = PlayConstants.PLAY_PLAYER.DURATION;
          this.status = CommonConstants.STATUS_COMPLETED;
          this.watchStatus();
          /* 20231227 - reset重置是为切换上下一个资源，以及列表序列播放场景下对AVplayer重置，使AVplayer进入idle状态，这里不用 */
          // this.avPlayer.reset();
          break;
        case AvplayerStatus.RELEASED:
          this.avPlayer.release();
          this.status = CommonConstants.STATUS_STOP;
          this.mediaKeySession?.destroy();
          this.mediaKeySystem?.destroy();
          this.watchStatus();
          break;
        case AvplayerStatus.STOPPED:
          break;
        default:
          break;
      }
    });
  }

  /**
   * This method is triggered when the video playback page is displayed on the video list page.
   *
   * @param index Video object subscript in the video list.
   * @param url Playback Path.
   * @param surfaceId Indicates the surface ID of the surfaceId.
   */
  firstPlay(index: number, url: string | media.AVFileDescriptor, surfaceId: number): void {
    Logger.info(TAG, `firstPlay,  url ${url}`);
    this.index = index;
    this.url = url;
    this._surfaceId = surfaceId;
    if (this.avPlayer && this.avPlayer.state == AvplayerStatus.IDLE) {
      if (typeof this.url === "string") {
        this.avPlayer.url = this.url;
      } else {
        this.avPlayer.fdSrc = this.url;
      }
    } else {
      this.flagtd = true;
    }
  }

  /**
   * Release the video player.
   */
  release(): void {
    this.avPlayer?.release();
  }

  /**
   * Pause Playing.
   */
  pause(): void {
    this.avPlayer?.pause();
  }

  /**
   * Playback mode. The options are as follows: true: playing a single video; false: playing a cyclic video.
   */
  setLoop(): void {
    this.loop = !this.loop;
  }

  /**
   * Set the playback speed.
   *
   * @param playSpeed Current playback speed.
   */
  setSpeed(playSpeed: number): void {
    if (CommonConstants.OPERATE_STATE.indexOf(this.avPlayer.state) === -1) {
      return;
    }
    this.playSpeed = playSpeed;
    this.avPlayer?.setSpeed(this.playSpeed);
  }
  setRate(playSpeed: number): void {
    if (CommonConstants.OPERATE_STATE.indexOf(this.avPlayer.state) === -1) {
      return;
    }
    this.playSpeed = playSpeed;
    this.avPlayer?.setSpeed(this.playSpeed);
  }

  setSelectTrack(type: string, value: string): void {
    // Logger.error(TAG, `setSelectTrack,  type:${type} value:${value}`);
    if (CommonConstants.OPERATE_STATE.indexOf(this.avPlayer.state) === -1) {
      return;
    }
    if (value != undefined) {
      let indexv = Number(value);
      this.avPlayer?.selectTrack(indexv, media.SwitchMode.SMOOTH);
    }
  }

  /**
   * @brief 切换视频播放
   * @return
   */
  switchVideo(newUrl: string | media.AVFileDescriptor): void {
    Logger.info(TAG, `switchVideo,  newUrl ${newUrl}`);
    this.bindState();
    this.url = newUrl;
    if (this._surfaceId == 0 || this._surfaceId == undefined) {
      // Logger.info(TAG, `switchVideo, return`);
      return;
    }
    if (AvplayerStatus.IDLE == this.avPlayer.state) {
      // Logger.info(TAG, `switchVideo,  IDLE `);
      if (typeof this.url === "string") {
        this.avPlayer.url = this.url;
      } else {
        this.avPlayer.fdSrc = this.url;
      }
    } else {
      this.avPlayer.stop().then(
        ()=>{
          Logger.info(TAG, `switchVideo, reset`);
          this.avPlayer.reset();
        }
      )
    }

    Logger.info(TAG, `switchVideo, state ${JSON.stringify(this.avPlayer.state)}`);
  }

  /**
   * Switching Between Video Play and Pause.
   */
  switchPlayOrPause(paused: boolean): void {
    Logger.info(TAG, `switchPlayOrPause,state out= ${this.avPlayer?.state};paused= ${JSON.stringify(paused)}`);
    if (paused) {
      this.avPlayer?.pause();
    } else {
      this.avPlayer?.play();
    }
  }

  switchRepeat(repeat: boolean): void {
    this.loop = repeat;
    if (this.status === CommonConstants.STATUS_PREPARED ||
      this.status === CommonConstants.STATUS_START ||
      this.status === CommonConstants.STATUS_PAUSE ||
      this.status === CommonConstants.STATUS_COMPLETED
    ) {
      this.avPlayer.loop = this.loop;
      Logger.info(TAG, `switchRepeat2, ${JSON.stringify(repeat)}`);
    }
  }

  /**
   * Switching Between Video muted and voice.
   */
  switchMuted(muted: boolean): void {
    this.mMuted = muted;
    let currentVolume = this.playerThis.volume;
    if (muted) {
      currentVolume = 0;
    } else {
      if (this.preMutedVolume > 0) {
        currentVolume = this.preMutedVolume;
      } else {
        currentVolume = 1.0;
      }
    }
    if (this.status === CommonConstants.STATUS_PREPARED ||
      this.status === CommonConstants.STATUS_START ||
      this.status === CommonConstants.STATUS_PAUSE ||
      this.status === CommonConstants.STATUS_COMPLETED
    ) {
      this.avPlayer.setVolume(currentVolume);
      Logger.info(TAG, `switchMuted2,currentVolume= ${JSON.stringify(currentVolume)}`);
    }

    // this.avPlayer.on('volumeChange', (vol: number) => {
    //   Logger.error(TAG, `volumeChange success,and new volume is= ${vol}}`);
    //   this.avPlayer.off('volumeChange');
    // })
  }

  /* 设置播放时屏幕不息屏 -- 暂无HM接口支持*/
  setPreventsDisplaySleepDuringVideoPlaybackModifier(preventsDisplaySleepDuringVideoPlayback: boolean): void {
    this.mPreventsDisplaySleepDuringVideoPlayback = preventsDisplaySleepDuringVideoPlayback;

    /* mMediaPlayer.setScreenOnWhilePlaying(mPreventsDisplaySleepDuringVideoPlayback);
       setKeepScreenOn(mPreventsDisplaySleepDuringVideoPlayback);
        */
  }

  /**
   * @brief do seek
   * @param value 目标位置，毫秒
   * @return
   */
  setSeekTime(value: number): void {
    // Logger.info(TAG, `setSeekTime== ${JSON.stringify(value)}`);
    this.seekTime = value * 1000;
    // Logger.info(TAG, `setSeekTime== ${this.seekTime}`);
    /* seek 只能在prepared/playing/paused/complete状态调用 毫秒（ms）*/
    if (this.status === CommonConstants.STATUS_PREPARED ||
      this.status === CommonConstants.STATUS_START ||
      this.status === CommonConstants.STATUS_PAUSE ||
      this.status === CommonConstants.STATUS_COMPLETED
    ) {
      this.isSeeking = true;
      this.playPageThis.onVideoPlaybackStateChanged(this.avPlayer.state == AvplayerStatus.PLAYING, this.isSeeking);
      this.avPlayer.seek(this.seekTime, media.SeekMode.SEEK_CLOSEST);
    }
  }

  /* 初始化播放器状态 */
  initProps(): void {
    Logger.info(TAG, `initProps repeat, ${JSON.stringify(this.playerThis.repeat)}`);
    this.avPlayer.loop = this.playerThis.repeat;
    this.mMuted = this.playerThis.muted;
    this.preMutedVolume = this.playerThis.volume;
    /* 更新音量 静音 -20231227 */
    this.switchMuted(this.mMuted);
    /* 更新resizeMode */
    this.convertResizeMode(this.playerThis.resizeMode);
  }

  /* 更新属性 */
  updateProp(): void {
    /* 设置 需要特定状态下设置*/
    if (this.avPlayer != null) {
      if(
        this.status === CommonConstants.STATUS_PREPARED ||
        this.status === CommonConstants.STATUS_START ||
        this.status === CommonConstants.STATUS_PAUSE ||
        this.status === CommonConstants.STATUS_COMPLETED
      ){
        let currentVolume = this.playerThis.volume
        if(currentVolume>1){
          currentVolume = 1
        }else if(currentVolume<0){
          currentVolume = 0
        }
        Logger.info(TAG, `updateProp volume, ${JSON.stringify(this.playerThis.volume)}`);
        this.avPlayer.setVolume(this.playerThis.volume); /* 更新音量 */
        Logger.info(TAG, `updateProp resizeMode, ${JSON.stringify(this.playerThis.resizeMode)}`);
        /* 更新 resizeMode */
        this.convertResizeMode(this.playerThis.resizeMode);
      }

      /* 更新音频流类型 */
      this.watchStatus();
    } else {
      Logger.error(TAG, `updateProp :  ${JSON.stringify(this.avPlayer)}`);
    }

  }

  convertResizeMode(resizeModeB: string): void {
    this.playerThis.videoJustifyContent = FlexAlign.Center;
    this.playerThis.videoAlignItems = HorizontalAlign.Center;
    this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT_CROP;
    this.playerThis.matrix = Matrix4.identity();
    switch (resizeModeB) {
      case ResizeMode.NONE:
        this.playerThis.videoJustifyContent = FlexAlign.Start;
        this.playerThis.videoAlignItems = HorizontalAlign.Start;
        this.playerThis.videoWidth = `${px2vp(this.avPlayer.width).toFixed(2)}`;
        this.playerThis.videoHeight = `${px2vp(this.avPlayer.height).toFixed(2)}`;
        break;
      case ResizeMode.CONTAIN: {
        this.playerThis.videoJustifyContent = FlexAlign.Center;
        this.playerThis.videoAlignItems = HorizontalAlign.Center;
        this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT_CROP;
        const viewWidth = this.playPageThis.viewWidth
        const viewHeight = this.playPageThis.viewHeight
        const playerWidth = this.avPlayer.width
        const playerHeight = this.avPlayer.height
        if (playerWidth != 0 && playerHeight != 0 && viewHeight != 0) {
          const videoRatio = playerWidth / playerHeight
          const viewRatio = viewWidth / viewHeight
          if (viewRatio > videoRatio) {
            this.playerThis.videoHeight = `${viewHeight}`;
            this.playerThis.videoWidth = `${viewHeight * videoRatio}`;
            let displayInfo = display.getDefaultDisplaySync();
            console.error('video_test convertResizeMode '+ this.isFullScreen)

            if (this.isFullScreen
              && (displayInfo.orientation === display.Orientation.LANDSCAPE
                || displayInfo.orientation === display.Orientation.LANDSCAPE_INVERTED)) {
              console.error('当前屏幕方向: 横屏');
              console.error('isFullScreen')
              this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT;
              this.playerThis.videoWidth = CommonConstants.NINETY_PERCENT;
              this.playerThis.videoHeight = CommonConstants.NINETY_PERCENT;
            }
          } else {
            this.playerThis.videoWidth = `${viewWidth}`;
            this.playerThis.videoHeight = `${viewWidth / videoRatio}`;
          }
        } else {
          Logger.error(TAG, `ResizeMode contain playerWidth or playerHeight or viewHeight = 0 `);
        }
        break;
      }
      case ResizeMode.COVER: // 保持视频宽高比拉伸至填满窗口，内容可能会有裁剪。
        this.playerThis.videoJustifyContent = FlexAlign.Center;
        this.playerThis.videoAlignItems = HorizontalAlign.Center;
        /* 这种模式，取视频最小的边同窗口比进行缩放，最小边填满窗口最小边 */
        this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT_CROP;
        if (this.avPlayer.height > this.avPlayer.width) { // 视频为竖屏
          this.playerThis.videoWidth = CommonConstants.FULL_PERCENT; // 竖屏则宽度满屏，进行高度比例放大
          let height = (CommonConstants.ONE_HUNDRED * this.avPlayer.height / this.avPlayer.width).toFixed(2);
          this.playerThis.videoHeight = CommonConstants.FULL_PERCENT;
          this.playerThis.matrix = Matrix4.identity()
            .scale({ x: 1, y: Number.parseFloat(height) / 100 });
        } else {
          this.playerThis.videoHeight = CommonConstants.FULL_PERCENT; // 横屏则高度满屏，进行宽度比例放大
          let width = (CommonConstants.ONE_HUNDRED * this.avPlayer.width / this.avPlayer.height).toFixed(2);
          this.playerThis.videoWidth = CommonConstants.FULL_PERCENT;
          this.playerThis.matrix = Matrix4.identity()
            .scale({ x: Number.parseFloat(width) / 100, y: 1 });
        }
        break;
      case ResizeMode.STRETCH:
        this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT;
        /* 这里则不分横竖屏，直接视频尺寸等于窗口尺寸*/
        this.playerThis.videoWidth = CommonConstants.FULL_PERCENT;
        this.playerThis.videoHeight = CommonConstants.FULL_PERCENT;
        break;
      default:
        break;
    }
  }

  /**
   * Obtains the current video playing status.
   */
  getStatus(): number {
    return this.status;
  }

  setAudioOutput(audioOut:string) {
    if(audioOut == 'speaker') {
      // 此处鸿蒙接口无效
      // audio.getAudioManager().setDeviceActive(audio.ActiveDeviceType.SPEAKER, true);
    } else if (audioOut == 'earpiece') {
      // audio.getAudioManager().setDeviceActive(audio.ActiveDeviceType.BLUETOOTH_SCO, true);
    }
  }

  /**
   * Pass this on the playback page.
   *
   * @param playerThis PlayPlayer this object.
   *
   */
  initPlayerThis(playerThis: IPlayPlayer): void {
    if (playerThis == null) {
      Logger.error(TAG, `initPlayerThis is null .`);
    }
    this.playerThis = playerThis;
  }

  /**
   * Callback function that is called when the media starts loading.
   * setSrc()->mEventEmitter.receiveEvent
   * @param cUri: 当前视频URL
   */
  onVideoLoadStart(cUri: string | media.AVFileDescriptor): void {
    Logger.info(TAG, `onVideoLoadStart URL: ${cUri}`);
    this.playPageThis.onVideoLoadStart(cUri);
  }

  /**
   * Callback function that is called when the first video frame is ready for display. This is when the poster is removed.
   * @author huKang
   * @date 2023/10/19 17:44
   * @return null
   */
  onReadyForDisplay(): void {
    Logger.info(TAG, `onReadyForDisplay`);
    this.playPageThis.onReadyForDisplay();
  }

  /**
   * Initialization progress bar.
   * currentTime is ms
   * @param time Current video playback time.
   */
  onVideoProgress(currentTime: number): void {
    let sec = currentTime == 0 ? 0 : currentTime / 1000;
    let playableDuration = this.mVideoBufferedDuration == 0 ? 0 : this.mVideoBufferedDuration;
    let seekableDuration = this.duration == 0 ? 0 : this.duration;
    this.playPageThis.onVideoProgress(sec, playableDuration, seekableDuration);
    // Logger.error(TAG, `sec ${sec}`);
  }

  /**
   * video completed call
   */
  onVideoEnd(): void {
    this.playPageThis.onVideoEnd();
  }

  /**
   *
   * @param time Current video playback time.
   * getTrackDescription 可以在prepared/playing/paused状态调用。
   */
  onVideoLoad(time: number): void {
    let startSecond = time == 0 ? 0 : Math.floor(time / 1000);
    let orientationIn = "landscape"; // 对标安卓 if (mp.getVideoWidth() > mp.getVideoHeight())
    if (this.avPlayer.width > this.avPlayer.height) {
      orientationIn = "landscape";
    } else {
      orientationIn = "portrait";
    }

    this.avPlayer.getTrackDescription((error, arrList) => {
      if ((arrList) != null) {
        /* 获取到音视频轨道信息后 回传*/
        this.playPageThis.onVideoLoad(startSecond, this.duration, this.avPlayer.width, this.avPlayer.height,
          orientationIn,arrList);

      } else {
        Logger.error(TAG, `getTrackDescription fail, error:${error}`);
      }
    });
  }

  async getSelectTracks(): Promise<number[]> {
    if (CommonConstants.OPERATE_STATE.indexOf(this.avPlayer.state) === -1) {
      return [];
    }
    return await this.avPlayer.getSelectedTracks();
  }

  /**
   *
   * @param isBuffering Boolean indicating whether buffering is active
   */
  onVideoBuffer(isBuffering: boolean): void {
    Logger.info(TAG, `onVideoBuffer out：${JSON.stringify(isBuffering)}`);
    this.playPageThis.onVideoBuffer(isBuffering);
  }

  /**
   * event video onBuffering start
   */
  onVideoPlaybackStalled(): void {
    // Logger.info(TAG, `onVideoPlaybackStalled`);
    // this.playPageThis.onVideoPlaybackStalled();
  }

  /**
   * event video onBuffering end
   */
  onVideoPlaybackResume(): void {
    Logger.error(TAG, `onVideoPlaybackResume`);
    // this.playPageThis.onVideoPlaybackResume();
  }

  /**
   * Reset progress bar data.
   * @Deprecated luoxf 0707
   */
  resetProgress(): void {
    this.seekTime = PlayConstants.PLAY_PROGRESS.SEEK_TIME;
  }

  /**
   * Sets whether the screen is a constant based on the playback status.
   * Add avplayer InterruptMode based on the playback status.
   */
  watchStatus(): void {
    /* disableFocus 属性触发 1、屏幕常亮 2、申请音频焦点--鸿蒙系统管理音频焦点，只需注入音频streamtype*/
    // if (this.status === CommonConstants.STATUS_START && this.playerThis.disableFocus) {
    //   globalThis.windowClass.setWindowKeepScreenOn(true);
    // } else {
    //   globalThis.windowClass.setWindowKeepScreenOn(false);
    // }
    /* 设置音频渲染信息，默认值contentType为CONTENT_TYPE_MUSIC，streamUsage为STREAM_USAGE_MEDIA。
       只允许在initialized状态下设置 */
    if (this.status === CommonConstants.STATUS_INITIALIZED) {
      if (this.avPlayer) {
        if (this.playerThis.disableFocus) {
          /* 设置音频流类型为视频，获取视频 音视频打断*/
          let audioRendererInfo = {
            content: audio.ContentType.CONTENT_TYPE_MOVIE,
            usage: audio.StreamUsage.STREAM_USAGE_MEDIA,
            rendererFlags: 0
          } as audio.AudioRendererInfo;
          this.avPlayer.audioRendererInfo = audioRendererInfo;
        }
      }
    } else if (this.status === CommonConstants.STATUS_PREPARED ||
      this.status === CommonConstants.STATUS_START ||
      this.status === CommonConstants.STATUS_PAUSE ||
      this.status === CommonConstants.STATUS_COMPLETED
    ) {
      /* setVolume 只能在prepared/playing/paused/complete状态调用 */
      /* 20231227 - 不重复调用静音设置，在点击变更时再设置，switchMuted */
      // this.switchMuted(this.mMuted);
    }

  }

  /**
   * Obtains the this object of the PlayPage.
   *
   * @param playPageThis This object of PlayPage.
   */
  initPlayPageThis(playPageThis: RNCVideo): void {
    this.playPageThis = playPageThis;
  }

  /**
   * An error is reported during network video playback.
   */
  playError(errMsg: string): void {
    Logger.error(TAG, `onVideoError：${JSON.stringify(errMsg)}`);
    if (this.playPageThis) {
      this.playPageThis.onVideoError(errMsg);
    }
  }
}
