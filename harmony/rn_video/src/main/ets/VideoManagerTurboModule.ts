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
import {UITurboModule, UITurboModuleContext} from '@rnoh/react-native-openharmony/ts';
import { TM } from "./generated/ts"
import { emitter } from '@kit.BasicServicesKit';
const RNC_VIDEO_TYPE: string = "RNCVideo"
export const VIDEO_EVENT_ID: number = 123456
export enum EventType {
  SETSOURCECMD,
  SETVOLUMECMD,
  SEEKCMD,
  SETPLAYERPAUSESTATECMD,
  SETLICENSERESULTCMD,
  SETLICENSERESULTERRORCMD,
  SETFULLSCREENCMD,
  ENTERPICTUREINPICTURECMD,
  EXITPICTUREINPICTURECMD,
  SAVE,
  GETCURRENTPOSITION
}

export interface EventData {
  data: {
    tag?: number
    event?: EventType;
    [key: string]: any;
  };
}

export class VideoManagerTurboModule extends UITurboModule implements TM.VideoManager.Spec {
  static TAG: string = 'VideoManagerTurboModule'
  public static currentPos : number = 0;
  ctx_: UITurboModuleContext;
  private event: emitter.InnerEvent = {
    eventId:VIDEO_EVENT_ID,
    priority: emitter.EventPriority.HIGH
  };
  constructor(protected ctx: UITurboModuleContext) {
    super(ctx);
    this.ctx_ = ctx;
  }

  seekCmd(reactTag: number, time: number, tolerance: number): Promise<void> {
    const data = {
      'tag':reactTag,
      'event':EventType.SEEKCMD,
      'time': time,
      'tolerance':tolerance};
    let eventData: emitter.EventData = {
      data
    };
    emitter.emit(this.event, eventData);
    return Promise.resolve();
  }

  setPlayerPauseStateCmd(reactTag: number, paused: boolean): Promise<void> {
    const data = {
      'tag':reactTag,
      'event':EventType.SETPLAYERPAUSESTATECMD,
      'paused': paused
    };
    let eventData: emitter.EventData = {
      data
    };
    emitter.emit(this.event, eventData);
    return Promise.resolve();
  }

  setLicenseResultCmd(reactTag: number, result: string, licenseUrl: string): Promise<void>{
    return Promise.resolve();
  }

  setLicenseResultErrorCmd(reactTag: number, error: string, licenseUrl: string): Promise<void> {
    return Promise.resolve();
  }

  setFullScreenCmd(reactTag: number, fullScreen: boolean): Promise<void> {
    console.info("setFullScreenCmd " +reactTag +",full:"+fullScreen)
    const data = {
      'tag':reactTag,
      'event':EventType.SETFULLSCREENCMD,
      'fullScreen': fullScreen
    };
    let eventData: emitter.EventData = {
      data
    };
    emitter.emit(this.event, eventData);
    return Promise.resolve();
  }

  setSourceCmd(reactTag: number, source: Object): Promise<void> {
    try {
      const { uri } = source as { uri?: string };
      const { isNetwork }  = source as { isNetwork?: boolean };

      if (!uri) {
        throw new Error("Source URI is required");
      }

      const data = {
        'tag':reactTag,
        'event':EventType.SETSOURCECMD,
        'uri': uri ,
        'isNetwork':isNetwork
      };
      let eventData: emitter.EventData = {
        data
      };
      emitter.emit(this.event, eventData);
    } catch (error) {
      return Promise.reject(error);
    }

    return Promise.resolve();
  }

  setVolumeCmd(reactTag: number, volume: number): Promise<void> {
    const data = {
      'tag':reactTag,
      'event':EventType.SETVOLUMECMD,
      'volume': volume
    };
    let eventData: emitter.EventData = {
      data
    };
    emitter.emit(this.event, eventData);
    return Promise.resolve();
  }

  enterPictureInPictureCmd(reactTag: number): Promise<void> {
    const data = {
      'tag':reactTag,
      'event':EventType.ENTERPICTUREINPICTURECMD
    };
    let eventData: emitter.EventData = {
      data
    };
    emitter.emit(this.event, eventData);
    return Promise.resolve();
  }

  exitPictureInPictureCmd(reactTag: number): Promise<void> {
    const data = {
      'tag':reactTag,
      'event':EventType.EXITPICTUREINPICTURECMD
    };
    let eventData: emitter.EventData = {
      data
    };
    emitter.emit(this.event, eventData);
    return Promise.resolve();
  }

  save(reactTag: number, option: Object): Promise<void> {
    const data = {
      'tag':reactTag,
      'event':EventType.SAVE,
      'option':option
    };
    let eventData: emitter.EventData = {
      data
    };
    emitter.emit(this.event, eventData);
    return Promise.resolve();
  }

  async getCurrentPosition(reactTag: number): Promise<number> {
    const data = {
      'tag':reactTag,
      'event':EventType.GETCURRENTPOSITION};
    let eventData: emitter.EventData = {
      data
    };
    await emitter.emit(this.event, eventData);
    return Promise.resolve(VideoManagerTurboModule.currentPos);
  }
}
