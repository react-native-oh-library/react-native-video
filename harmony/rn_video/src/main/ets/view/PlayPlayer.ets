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
}

@Component
export struct PlayPlayer {
  private playVideoModel!: VideoController;
  @Consume('srcVar') @Watch("onSrcChanged") src: string;// 视频src
  @Consume index: number;
  @Consume('mutedVar')  @Watch("onMutedChanged") muted: boolean ;
  @Consume('repeatVar') @Watch("onChanged") repeat: boolean;
  @Consume('pausedVar') @Watch("onPausedChanged") paused: boolean;
  @Consume('volumeVar') @Watch("onChanged") volume: number;
  @Consume('resizeModeVar') @Watch("onChanged") resizeMode:string;
  @Consume('disableFocusVar') @Watch("onChanged") disableFocus: boolean;
  @Consume('preventsDisplaySleepDuringVideoPlaybackVar') @Watch("setPreventsDisplaySleepDuringVideoPlaybackModifier") preventsDisplaySleepDuringVideoPlayback: boolean;

  @State bright: number = PlayConstants.PLAY_PAGE.BRIGHT;
  /* 不需要显示 */
  @State volumeShow: boolean = PlayConstants.PLAY_PAGE.VOLUME_SHOW;
  @State brightShow: boolean = PlayConstants.PLAY_PAGE.BRIGHT_SHOW;
  private xComponentController: XComponentController = new XComponentController();;
  private surfaceID: number = 0;

  @State videoHeight: string = CommonConstants.FULL_PERCENT;
  @State videoWidth: string = CommonConstants.FULL_PERCENT;

  aboutToAppear() {
    if (this.playVideoModel) {
      this.playVideoModel.initPlayerThis(this as IPlayPlayer);
    }
    // this.xComponentController = new XComponentController();
  }
  // @Watch cb
  onChanged(propName: string) : void {
    Logger.info(`RNOH in Player, onChanged, ${JSON.stringify(propName)}`);
    Logger.info(`RNOH in Player, onChanged, ${JSON.stringify(this.repeat)}`);
    Logger.info(`RNOH in Player, onChanged,resizeMode= ${JSON.stringify(this.resizeMode)}`);
    Logger.info(`RNOH in Player, onChanged,disableFocus= ${JSON.stringify(this.disableFocus)}`);
    //this.playVideoModel.avPlayer.loop = this.playerThis.repeat == 1;
    if (this.playVideoModel) {
      this.playVideoModel.updateProp()
    }
  }

  onSrcChanged(propName: string) : void {
    Logger.info(`RNOH in Player, onSrcChanged,srcout: ${JSON.stringify(this.src)}`);
    Logger.info(`RNOH in Player, onSrcChanged,propName: ${JSON.stringify(propName)}`);
    this.playVideoModel.switchVideo(this.src);
  }
  onMutedChanged(propName: string) : void {
    Logger.info(`RNOH in Player, onMutedChanged, ${JSON.stringify(this.muted)}`);
    this.playVideoModel.switchMuted(this.muted);
  }

  onPausedChanged(propName: string) : void {
    Logger.info(`RNOH in Player, onPausedChanged, ${JSON.stringify(this.paused)}`);
    this.playVideoModel.switchPlayOrPause(this.paused);
  }

  setPreventsDisplaySleepDuringVideoPlaybackModifier(propName: string):void{
    this.playVideoModel.setPreventsDisplaySleepDuringVideoPlaybackModifier(this.preventsDisplaySleepDuringVideoPlayback);
  }

  build() {
    Flex({justifyContent: FlexAlign.Center,alignItems: ItemAlign.Center}) {
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
          Logger.info(`RNOH in Player, tofirstPlay, ${JSON.stringify(this.src)}`);
          if (this.src == '') {
            this.playVideoModel.firstPlay(this.index, this.src, this.surfaceID);
          } else {
            this.playVideoModel.firstPlay(this.index, this.src, this.surfaceID);
          }
        })
        .width(this.videoWidth)
        .height(this.videoHeight)

    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}