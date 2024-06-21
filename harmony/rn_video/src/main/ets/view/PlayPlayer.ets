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

import { VideoController } from '../controller/VideoController';
import { CommonConstants } from '../common/constants/CommonConstants';
import { PlayConstants } from '../common/constants/PlayConstants';
import Logger from '../common/util/Logger';
import Matrix4 from '@ohos.matrix4'
import mediaquery from '@ohos.mediaquery'

export interface IPlayPlayer {
  src: string
  muted: boolean
  repeat: boolean
  paused: boolean
  volume: number
  resizeMode:string
  disableFocus: boolean
  preventsDisplaySleepDuringVideoPlayback: boolean
  brightShow:boolean
  volumeShow:boolean
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
  private playVideoModel: VideoController = new VideoController();
  @Consume('srcVar') @Watch("onSrcChanged") src: string;// 视频src
  @Consume index: number;
  @Consume('mutedVar')  @Watch("onMutedChanged") muted: boolean ;
  @Consume('repeatVar') @Watch("onRepeatChanged") repeat: boolean;
  @Consume('pausedVar') @Watch("onPausedChanged") paused: boolean;
  @Consume('volumeVar') @Watch("onChanged") volume: number;
  @Consume('resizeModeVar') @Watch("onChanged") resizeMode:string;
  @Consume('disableFocusVar') @Watch("onChanged") disableFocus: boolean;
  @Consume('preventsDisplaySleepDuringVideoPlaybackVar') @Watch("setPreventsDisplaySleepDuringVideoPlaybackModifier") preventsDisplaySleepDuringVideoPlayback: boolean;

  @State bright: number = PlayConstants.PLAY_PAGE.BRIGHT;
  /* 不需要显示 */
  @State volumeShow: boolean = PlayConstants.PLAY_PAGE.VOLUME_SHOW;
  @State brightShow: boolean = PlayConstants.PLAY_PAGE.BRIGHT_SHOW;
  private xComponentController: XComponentController = new XComponentController();
  private surfaceID: number = 0;

  @Consume videoHeight: number|string;
  @Consume  videoWidth: number|string;

  @State videoJustifyContent: FlexAlign = FlexAlign.Center;
  @State videoAlignItems: HorizontalAlign = HorizontalAlign.Center;
  @State matrix: object = Matrix4.identity();

  viewWidth: number = 0;
  viewHeight: number = 0;
  @Consume
  changedViewWidth: number;
  @Consume
  changedViewHeight: number;

  private orientationChange: boolean = true;

  listener = mediaquery.matchMediaSync('(orientation: landscape)');

  aboutToAppear(): void {
    this.listenScreenDirection();
    if (this.playVideoModel) {
      this.playVideoModel.initPlayerThis(this as IPlayPlayer);
    }
  }

  // @Watch cb
  onChanged(propName: string) : void {
    Logger.debug(TAG, `onChanged,propName= ${JSON.stringify(propName)}`);
    Logger.debug(TAG, `onChanged,volume= ${JSON.stringify(this.volume)}`);
    Logger.debug(TAG, `onChanged,resizeMode= ${JSON.stringify(this.resizeMode)}`);
    Logger.debug(TAG, `onChanged,disableFocus= ${JSON.stringify(this.disableFocus)}`);
    if (this.playVideoModel) {
      this.playVideoModel.updateProp();
    }
  }

  onSrcChanged(propName: string) : void {
    Logger.debug(TAG, `onSrcChanged,srcout: ${JSON.stringify(this.src)}`);
    Logger.debug(TAG, `onSrcChanged,propName: ${JSON.stringify(propName)}`);
    this.playVideoModel.switchVideo(this.src);
  }

  onRepeatChanged(propName: string) : void {
    Logger.debug(TAG, `onRepeatChange, ${JSON.stringify(this.repeat)}`);
    this.playVideoModel.switchRepeat(this.repeat);
  }

  onMutedChanged(propName: string) : void {
    Logger.debug(TAG, `onMutedChanged, ${JSON.stringify(this.muted)}`);
    this.playVideoModel.switchMuted(this.muted);
  }

  onPausedChanged(propName: string) : void {
    Logger.debug(TAG, `onPausedChanged, ${JSON.stringify(this.paused)}`);
    this.playVideoModel.switchPlayOrPause(this.paused);
  }

  setPreventsDisplaySleepDuringVideoPlaybackModifier(propName: string) : void {
    this.playVideoModel.setPreventsDisplaySleepDuringVideoPlaybackModifier(this.preventsDisplaySleepDuringVideoPlayback);
  }

  listenScreenDirection(): void  {
    this.listener.on('change',(mediaQueryResult:mediaquery.MediaQueryResult)=>{
      this.orientationChange = false
    })

  }


  build() {
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
          Logger.debug(TAG, `tofirstPlay, ${JSON.stringify(this.src)}`);
          if (this.src == '') {
            this.playVideoModel.firstPlay(this.index, this.src, this.surfaceID);
          } else {
            this.playVideoModel.firstPlay(this.index, this.src, this.surfaceID);
          }
        })
        .width(this.videoWidth)
        .height(this.videoHeight)
        .scale(this.matrix)
    }
    .width(this.changedViewWidth)
    .height(this.changedViewHeight)
    .alignItems(this.videoAlignItems)
    .justifyContent(this.videoJustifyContent);
  }
}