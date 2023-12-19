"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
Object.defineProperty(exports, "DRMType", {
  enumerable: true,
  get: function () {
    return _DRMType.default;
  }
});
Object.defineProperty(exports, "FilterType", {
  enumerable: true,
  get: function () {
    return _FilterType.default;
  }
});
Object.defineProperty(exports, "TextTrackType", {
  enumerable: true,
  get: function () {
    return _TextTrackType.default;
  }
});
Object.defineProperty(exports, "VideoRef", {
  enumerable: true,
  get: function () {
    return _Video.VideoRef;
  }
});
Object.defineProperty(exports, "VideoResizeMode", {
  enumerable: true,
  get: function () {
    return _VideoResizeMode.default;
  }
});
exports.default = void 0;
var _Video = _interopRequireWildcard(require("./Video"));
var _FilterType = _interopRequireDefault(require("./lib/FilterType"));
var _VideoResizeMode = _interopRequireDefault(require("./lib/VideoResizeMode"));
var _TextTrackType = _interopRequireDefault(require("./lib/TextTrackType"));
var _DRMType = _interopRequireDefault(require("./lib/DRMType"));
function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
function _getRequireWildcardCache(e) { if ("function" != typeof WeakMap) return null; var r = new WeakMap(), t = new WeakMap(); return (_getRequireWildcardCache = function (e) { return e ? t : r; })(e); }
function _interopRequireWildcard(e, r) { if (!r && e && e.__esModule) return e; if (null === e || "object" != typeof e && "function" != typeof e) return { default: e }; var t = _getRequireWildcardCache(r); if (t && t.has(e)) return t.get(e); var n = { __proto__: null }, a = Object.defineProperty && Object.getOwnPropertyDescriptor; for (var u in e) if ("default" !== u && Object.prototype.hasOwnProperty.call(e, u)) { var i = a ? Object.getOwnPropertyDescriptor(e, u) : null; i && (i.get || i.set) ? Object.defineProperty(n, u, i) : n[u] = e[u]; } return n.default = e, t && t.set(e, n), n; }
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
var _default = exports.default = _Video.default;
//# sourceMappingURL=index.js.map