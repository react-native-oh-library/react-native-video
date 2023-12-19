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
 * Home constants for all features.
 */
export class HomeConstants {
  /**
   * Constants on the tab page of the main interface.
   */
  static readonly HOME_TAB = {
    CURRENT_INDEX: 0,
    TAB_BAR_FIRST: 0,
    TAB_BAR_SECOND: 1,
    BAR_WIDTH: 360,
    BAR_HEIGHT: 60,
    FONT_WEIGHT_SELECT: 500,
    FONT_WEIGHT_UNSELECT: 400,
    LINE_HEIGHT: 22,
    MARGIN_TOP_TWO: 17,
    MARGIN_BOTTOM: 7,
    STROKE_WIDTH: 2
  }

  /**
   * Constant of the video list.
   */
  static readonly HOME_TAB_LIST = {
    COLUMN_WIDTH: '86.7%',
    LIST_SPACE: 20,
    LIST_INITIAL_INDEX: 0,
    IMAGE_HEIGHT: '84.8%',
    IMAGE_WIDTH: '26.7%',
    DIVIDER_STROKE_WIDTH: 1,
    LIST_ITEM_ROW_COLUMN_WIDTH: '73.3%',
    LIST_ITEM_ROW_HEIGHT: '12.3%',
    WIDTH: 720,
    HEIGHT: 720
  }

  /**
   * Scan local video and add network video buttons.
   */
  static readonly HOME_TAB_BUTTON = {
    HEIGHT: '51%',
    COLUMN_HEIGHT: '10%'
  }

  /**
   * Add Network Video dialog box.
   */
  static readonly INTERNET_ADD_DIALOG= {
    OFFSET_DX: 0,
    OFFSET_DY: -20,
    GRID_COUNT: 4,
    TEXT_HEIGHT: '6.7%',
    TEXT_MARGIN_TOP: '3.1%',
    DURATION: 1000,
    DURATION_ONE: -1,
    DURATION_TWO: 0
  }

  /**
   * The video player is used to verify the video link.
   */
  static readonly X_COMPONENT = {
    ID: '',
    TYPE: 'surface',
    LIBRARY_NAME: '',
  }
}
