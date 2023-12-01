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

/**
 * Play constants for all features.
 */
export class PlayConstants {
  /**
   * Playback page constant.
   */
  static readonly PLAY_PAGE = {
    PLAY_SPEED: 1,
    VOLUME: 0.5,
    VOLUME_SHOW: false,
    BRIGHT: 0.5,
    BRIGHT_SHOW: false,
    POSITION_X: 0,
    POSITION_Y: 0,
    HEIGHT: '7.2%',
    PLAY_PLAYER_HEIGHT: '25.6%',
    PLAY_PLAYER_HEIGHT_FULL: '75.4%',
    PLAY_PROGRESS_HEIGHT: '7.1%',
    COLUMN_HEIGHT_ONE: '26.9%',
    COLUMN_HEIGHT_TWO: '22.9%',
    MIN_ANGLE: 0,
    MAX_ANGLE: 30,
    MIN_VALUE: 0,
    MAX_VALUE: 1,
    DISAPPEAR_TIME: 200,
    MARGIN_ZERO: '0'
  } as PlayPage

  /**
   * Video playback constant.
   */
  static  readonly PLAY_PLAYER = {
    ID: '',
    TYPE: 'surface',
    LIBRARY_NAME: '',
    SURFACE_WIDTH: 1920,
    SURFACE_HEIGHT: 1080,
    STACK_WIDTH: '16.7%',
    IMAGE_WIDTH: '95%',
    FIRST: 0,
    NEXT: 1,
    DURATION: 0
  } as PlayPlayer

  /**
   * Network video playback error notification duration
   */
  static readonly PLAY_ERROR_TIME = 3000;

  /**
   * Progress bar page constant.
   */
  static readonly PLAY_PROGRESS = {
    CURRENT_TIME: '00:00',
    TOTAL_TIME: '00:00',
    PROGRESS_VAL: 0,
    INTERVAL: -1,
    STEP: 1,
    TRACK_THICKNESS: 1,
    SLIDER_WIDTH: '68.9%',
    MARGIN_LEFT: '2.2%',
    SEEK_TIME: 0,
    ROW_WIDTH: '93.4%'
  } as PlayProgress

}

class PlayPlayer {
  ID: string = ''
  TYPE: string ='surface'
  LIBRARY_NAME: string = ''
  SURFACE_WIDTH: number = 1920
  SURFACE_HEIGHT: number = 1080
  STACK_WIDTH: string = '16.7%'
  IMAGE_WIDTH: string = '95%'
  FIRST: number = 0
  NEXT: number = 1
  DURATION: number = 0
}

class PlayPage {
    PLAY_SPEED: number = 1
    VOLUME: number = 1.0
    VOLUME_SHOW: boolean =  false
    BRIGHT: number = 0.5
    BRIGHT_SHOW: boolean = false
    POSITION_X: number = 0
    POSITION_Y: number = 0
    HEIGHT: string = '7.2%'
    PLAY_PLAYER_HEIGHT: string = '25.6%'
    PLAY_PLAYER_HEIGHT_FULL: string = '75.4%'
    PLAY_PROGRESS_HEIGHT: string = '7.1%'
    COLUMN_HEIGHT_ONE: string = '26.9%'
    COLUMN_HEIGHT_TWO: string = '22.9%'
    MIN_ANGLE: number = 0
    MAX_ANGLE: number = 30
    MIN_VALUE: number = 0
    MAX_VALUE: number = 1
    DISAPPEAR_TIME: number = 200
    MARGIN_ZERO: string = '0'
  }

class PlayProgress {
  CURRENT_TIME: string = '00:00'
  TOTAL_TIME: string = '00:00'
  PROGRESS_VAL: number = 0
  INTERVAL: number = -1
  STEP: number = 1
  TRACK_THICKNESS: number = 1
  SLIDER_WIDTH: string = '68.9%'
  MARGIN_LEFT: string = '2.2%'
  SEEK_TIME: number = 0
  ROW_WIDTH: string = '93.4%'
}