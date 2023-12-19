"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.generateHeaderForNative = generateHeaderForNative;
exports.isFabric = isFabric;
exports.resolveAssetSourceForVideo = resolveAssetSourceForVideo;
var _reactNative = require("react-native");
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

function generateHeaderForNative(obj) {
  if (!obj) return [];
  return Object.entries(obj).map(([key, value]) => ({
    key,
    value
  }));
}
function resolveAssetSourceForVideo(source) {
  if (typeof source === 'number') {
    return {
      uri: _reactNative.Image.resolveAssetSource(source).uri
    };
  }
  return source;
}
function isFabric() {
  var _global;
  // @ts-expect-error nativeFabricUIManager is not yet included in the RN types
  return !!((_global = global) !== null && _global !== void 0 && _global.nativeFabricUIManager);
}
//# sourceMappingURL=utils.js.map