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

import { VideoBean } from '../bean/VideoBean';

/**
 * Common constants for all features.
 */
export class CommonConstants {
  /**
   * Full percent.
   */
  static readonly FULL_PERCENT: string = '100%';

  /**
   * Ninety percent.
   */
  static readonly NINETY_PERCENT: string = '90%';

  /**
   * Fifty percent.
   */
  static readonly FIFTY_PERCENT: string = '50%';

  /**
   * Playback page path.
   */
  static readonly PAGE: string = 'pages/PlayPage';

  /**
   * Local video ID.
   */
  static readonly TYPE_LOCAL: number = 0;

  /**
   * Network video ID.
   */
  static readonly TYPE_INTERNET: number = 1;

  /**
   * Avplayer initialized.
   */
  static readonly STATUS_INITIALIZED: number = 10000;

  /**
   * Start playing.
   */
  static readonly STATUS_START: number = 1;

  /**
   * Playing Pause.
   */
  static readonly STATUS_PAUSE: number = 2;

  /**
   * Stop Playing.
   */
  static readonly STATUS_STOP: number = 3;

  /**
   * prepared status.
   */
  static readonly STATUS_PREPARED: number = 4;

  /**
   * completed status.
   */
  static readonly STATUS_COMPLETED: number = 5;

  /**
   * Width-height ratio.
   */
  static readonly ASPECT_RATIO: number = 1;

  /**
   * One hundred.
   */
  static readonly ONE_HUNDRED: number = 100;

  /**
   * A thousand.
   */
  static readonly A_THOUSAND: number = 1000;

   /**
   * time system, Hour-minute-second conversion.
   */
  static readonly TIME_UNIT: number = 60;

  /**
   * Initial Time UNIT.
   */
  static readonly INITIAL_TIME_UNIT: string = '00';

  /**
   * Zero padding, 2 bits.
   */
  static readonly PADDING_LENGTH: number = 2;

  /**
   * String zero padding.
   */
  static readonly PADDING_STR: string = '0';

  /**
   * Breath screen status.
   */
  static readonly SCREEN_OFF: string = 'usual.event.SCREEN_OFF';

  /**
   * Operation status of video player 4.
   */
  static readonly OPERATE_STATE: Array<string> = ['prepared','playing', 'paused', 'completed'];
}

/**
 * Player component status.
 */
export enum AvplayerStatus {
  IDLE = 'idle',
  INITIALIZED = 'initialized',
  PREPARED = 'prepared',
  PLAYING = 'playing',
  PAUSED = 'paused',
  COMPLETED = 'completed',
  STOPPED = 'stopped',
  RELEASED = 'released',
  ERROR = 'error'
}

/**
 * AVPlayer binding event.
 */
export enum Events {
  STATE_CHANGE = 'stateChange',
  TIME_UPDATE = 'timeUpdate',
  ERROR = 'error',
  DURATION_UPDATE = 'durationUpdate',
  END_OF_STREAM = 'endOfStream',
  BUFFERING_UPDATE = 'bufferingUpdate',
  SEEK_DONE = 'seekDone'
}
