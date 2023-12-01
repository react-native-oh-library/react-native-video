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

import { CommonConstants } from '../constants/CommonConstants'

class DateFormatUtil {
  /**
   * Seconds converted to HH:mm:ss.
   *
   * @param seconds Maximum video duration (seconds).
   * @return Time after conversion.
   */
  secondToTime(seconds: number) {
    let time = `${CommonConstants.INITIAL_TIME_UNIT}${':'}${CommonConstants.INITIAL_TIME_UNIT}`;
    let hourUnit = CommonConstants.TIME_UNIT * CommonConstants.TIME_UNIT;
    let hour = Math.floor(seconds / hourUnit);
    let minute = Math.floor((seconds - hour * hourUnit) / CommonConstants.TIME_UNIT);
    let second = seconds - hour * hourUnit - minute * CommonConstants.TIME_UNIT;
    if (hour > 0) {
      return `${this.padding(hour.toString())}${':'}
        ${this.padding(minute.toString())}${':'}${this.padding(second.toString())}`;
    }
    if (minute > 0) {
      return `${this.padding(minute.toString())}${':'}${this.padding(second.toString())}`;
    } else {
      return `${CommonConstants.INITIAL_TIME_UNIT}${':'}${this.padding(second.toString())}`;
    }
    return time;
  }

  /**
   * Zero padding, 2 bits.
   *
   * @param num Number to be converted.
   * @return Result after zero padding.
   */
  padding(num: string) {
    let length = CommonConstants.PADDING_LENGTH;
    for (let len = (num.toString()).length; len < length; len = num.length) {
      num = `${CommonConstants.PADDING_STR}${num}`;
    }
    return num;
  }
}

export default new DateFormatUtil();

