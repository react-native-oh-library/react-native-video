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
import audio from '@ohos.multimedia.audio';
import Logger from '../common/util/Logger';
import { AvplayerStatus, CommonConstants, Events, ResizeMode, CurrentTime } from '../common/constants/CommonConstants';
import { PlayConstants } from '../common/constants/PlayConstants';
import { AudioTracksBean, VideoTracksBean } from '../common/bean/AudioTracksBean';
import { IPlayPlayer } from '../view/PlayPlayer';
import { IRNCVideo } from '../RNCVideo';
import Matrix4 from '@ohos.matrix4'
import { display } from '@kit.ArkUI';

const TAG: string = 'RNOH in ctrl'

@Observed
export class VideoController {
  private avPlayer!: media.AVPlayer;
  private duration: number = 0; /* 视频时间长度 */
  private status: number = 0; /* 这个是自定义的 ，avplayer状态可以获取字符串状态 */
  private loop: boolean = false;
  private index: number = 0;
  private url: string | media.AVFileDescriptor = '';
  private surfaceId: number = 0;
  private playSpeed: number = PlayConstants.PLAY_PAGE.PLAY_SPEED;
  private seekTime: number = PlayConstants.PLAY_PROGRESS.SEEK_TIME;
  private playerThis!: IPlayPlayer;
  private playPageThis!: IRNCVideo;
  private preMutedVolume: number = 1.0;
  private mMuted: boolean = false;
  private flagtd: boolean = false;
  private mVideoBufferedDuration: number =
    0; // 对标安卓，获取缓冲时间， mVideoBufferedDuration = (int) Math.round((double) (mVideoDuration * percent) / 100.0); playableDuration =  mVideoBufferedDuration / 1000.0
  public audioTracksBeanArr?: AudioTracksBean[];
  public videoTracksBeanArr?: VideoTracksBean[];
  private mPreventsDisplaySleepDuringVideoPlayback: boolean = true; /* 默认true*/

  constructor() {
    this.createAVPlayer();
  }

  /**
   * Creates a videoPlayer object.
   */
  createAVPlayer(): void {
    media.createAVPlayer().then((avPlayer) => {
      if (avPlayer) {
        Logger.debug(TAG, `createAVPlayer isNull: ${avPlayer == null}`);
        this.avPlayer = avPlayer;
        this.bindState();
        Logger.debug(TAG, `createAVPlayer after bind`);
        if (this.flagtd) {
          this.flagtd = false;
          if (typeof this.url === "string") {
            this.avPlayer.url = this.url;
          } else {
            this.avPlayer.fdSrc = this.url;
          }
          Logger.debug(TAG, `createAVPlayer need toplay url,after bind:` + this.url);
        } else {
          Logger.debug(TAG, `createAVPlayer noneed toplay url,after bind`);
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
    Logger.debug(TAG, `bindState`);
    if (this.avPlayer) {

      this.onStateChange();

      this.avPlayer.on(Events.TIME_UPDATE, (time: number) => {
        this.onVideoProgress(time);
      });

      this.avPlayer.on(Events.DURATION_UPDATE, (durationA) => {
        Logger.debug(TAG, `durationUpdate success,new duration is=${durationA}`);
        this.duration = durationA == 0 ? 0 : Math.floor(durationA / 1000); // ms->s
      })

      this.avPlayer.on(Events.ERROR, (error) => {
        Logger.debug(TAG, `event error： ${JSON.stringify(error)}`);
        this.playError(JSON.stringify(error));
      })

      this.avPlayer.on(Events.END_OF_STREAM, () => {
        Logger.debug(TAG, 'END_OF_STREAM');
        this.onVideoEnd();
      })

      this.avPlayer.on(Events.BUFFERING_UPDATE, (infoType: media.BufferingInfoType, value: number) => {
        /* 播放缓存事件回调方法。BufferingInfoType为BUFFERING_PERCENT或CACHED_DURATION时，value值有效，否则固定为0。 */
        Logger.debug(TAG, 'BUFFERING_UPDATE');
        switch (infoType) {
          case media.BufferingInfoType.BUFFERING_START: // 表示缓存开始，
            this.onVideoPlaybackStalled();
            this.onVideoBuffer(true);
            break;
          case media.BufferingInfoType.BUFFERING_END: // 表示缓存结束，
            this.onVideoPlaybackResume();
            this.onVideoBuffer(false);
            break;
          case media.BufferingInfoType.BUFFERING_PERCENT: // 表示缓存百分比
            /* 此时的value有值，表示缓存百分比*/
            break;
          case media.BufferingInfoType.CACHED_DURATION: // 表示缓存时长，毫秒（ms）。
            Logger.debug(TAG, `onVideoProgress CACHED_DURATION value = ${value}`);
            this.mVideoBufferedDuration = Math.floor(value / 1000); // ms--?s
            break;
          default:
            break;
        }
      })

      this.avPlayer.on(Events.SEEK_DONE, (seekDoneTime: number) => {
        Logger.debug(TAG, `seekDone success,and seek time is: ${seekDoneTime} `);
      })
    }
    Logger.debug(TAG, `bindState end`);
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
          this.onVideoLoadStart(JSON.stringify(this.url));
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
          this.avPlayer.surfaceId = String(this.surfaceId);
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
          this.onVideoLoad(startSecond);
          this.onReadyForDisplay();
          break;
        case AvplayerStatus.PLAYING:
          this.status = CommonConstants.STATUS_START;
          this.watchStatus();
          break;
        case AvplayerStatus.PAUSED:
          this.status = CommonConstants.STATUS_PAUSE;
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
    this.index = index;
    this.url = url;
    this.surfaceId = surfaceId;
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

  /**
   * @brief 切换视频播放
   * @return
   */
  switchVideo(newUrl: string | media.AVFileDescriptor): void {
    this.bindState();
    this.url = newUrl;
    if (this.surfaceId == 0 || this.surfaceId == undefined) {
      return;
    }
    if (AvplayerStatus.IDLE == this.avPlayer.state) {
      if (typeof this.url === "string") {
        this.avPlayer.url = this.url;
      } else {
        this.avPlayer.fdSrc = this.url;
      }
    } else {
      this.avPlayer.reset();
    }
    Logger.debug(TAG, `switchVideo,  state11 ${JSON.stringify(this.avPlayer.state)}`);
  }

  /**
   * Switching Between Video Play and Pause.
   */
  switchPlayOrPause(paused: boolean): void {
    Logger.debug(TAG, `switchPlayOrPause,state out= ${this.avPlayer?.state};paused= ${JSON.stringify(paused)}`);
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
      Logger.debug(TAG, `switchRepeat2, ${JSON.stringify(repeat)}`);
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
      Logger.debug(TAG, `switchMuted2,currentVolume= ${JSON.stringify(currentVolume)}`);
    }

    this.avPlayer.on('volumeChange', (vol: number) => {
      Logger.debug(TAG, `volumeChange success,and new volume is= ${vol}}`);
      this.avPlayer.off('volumeChange');
    })
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
    Logger.debug(TAG, `setSeekTime== ${JSON.stringify(value)}`);
    this.seekTime = value * 1000;
    Logger.debug(TAG, `setSeekTime== ${this.seekTime}`);
    /* seek 只能在prepared/playing/paused/complete状态调用 毫秒（ms）*/
    if (this.status === CommonConstants.STATUS_PREPARED ||
      this.status === CommonConstants.STATUS_START ||
      this.status === CommonConstants.STATUS_PAUSE ||
      this.status === CommonConstants.STATUS_COMPLETED
    ) {
      this.avPlayer.seek(this.seekTime, media.SeekMode.SEEK_CLOSEST);
    }
  }

  /* 初始化播放器状态 */
  initProps(): void {
    Logger.debug(TAG, `initProps repeat, ${JSON.stringify(this.playerThis.repeat)}`);
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
      Logger.debug(TAG, `updateProp volume, ${JSON.stringify(this.playerThis.volume)}`);
      this.avPlayer.setVolume(this.playerThis.volume); /* 更新音量 */
      Logger.debug(TAG, `updateProp resizeMode, ${JSON.stringify(this.playerThis.resizeMode)}`);
      /* 更新 resizeMode */
      this.convertResizeMode(this.playerThis.resizeMode);
      /* 更新音频流类型 */
      this.watchStatus();
    } else {
      Logger.debug(TAG, `updateProp :  ${JSON.stringify(this.avPlayer)}`);
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

  /**
   * Pass this on the playback page.
   *
   * @param playerThis PlayPlayer this object.
   *
   */
  initPlayerThis(playerThis: IPlayPlayer): void {
    if (playerThis == null) {
      Logger.debug(TAG, `initPlayerThis is null .`);
    }
    this.playerThis = playerThis;
  }

  /**
   * Callback function that is called when the media starts loading.
   * setSrc()->mEventEmitter.receiveEvent
   * @param cUri: 当前视频URL
   */
  onVideoLoadStart(cUri: string | media.AVFileDescriptor): void {
    Logger.debug(TAG, `onVideoLoadStart URL: ${cUri}`);
    this.playPageThis.onVideoLoadStart(cUri);
  }

  /**
   * Callback function that is called when the first video frame is ready for display. This is when the poster is removed.
   * @author huKang
   * @date 2023/10/19 17:44
   * @return null
   */
  onReadyForDisplay(): void {
    Logger.debug(TAG, `onReadyForDisplay`);
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
          orientationIn);

      } else {
        Logger.debug(TAG, `getTrackDescription fail, error:${error}`);
      }
    });
  }


  /**
   *
   * @param isBuffering Boolean indicating whether buffering is active
   */
  onVideoBuffer(isBuffering: boolean): void {
    Logger.debug(TAG, `onVideoBuffer out：${JSON.stringify(isBuffering)}`);
    this.playPageThis.onVideoBuffer(isBuffering);
  }

  /**
   * event video onBuffering start
   */
  onVideoPlaybackStalled(): void {
    Logger.debug(TAG, `onVideoPlaybackStalled`);
    this.playPageThis.onVideoPlaybackStalled();
  }

  /**
   * event video onBuffering end
   */
  onVideoPlaybackResume(): void {
    Logger.debug(TAG, `onVideoPlaybackResume`);
    this.playPageThis.onVideoPlaybackResume();
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
  initPlayPageThis(playPageThis: IRNCVideo): void {
    this.playPageThis = playPageThis;
  }

  /**
   * An error is reported during network video playback.
   */
  playError(errMsg: string): void {
    Logger.debug(TAG, `onVideoError：${JSON.stringify(errMsg)}`);
    if (this.playPageThis) {
      this.playPageThis.onVideoError(errMsg);
    }
  }
}
