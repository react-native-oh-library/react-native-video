"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
var _react = _interopRequireWildcard(require("react"));
var _reactNative = require("react-native");
var _VideoNativeComponent = _interopRequireWildcard(require("./fabric/VideoNativeComponent"));
var _utils = require("./utils");
function _getRequireWildcardCache(e) { if ("function" != typeof WeakMap) return null; var r = new WeakMap(), t = new WeakMap(); return (_getRequireWildcardCache = function (e) { return e ? t : r; })(e); }
function _interopRequireWildcard(e, r) { if (!r && e && e.__esModule) return e; if (null === e || "object" != typeof e && "function" != typeof e) return { default: e }; var t = _getRequireWildcardCache(r); if (t && t.has(e)) return t.get(e); var n = { __proto__: null }, a = Object.defineProperty && Object.getOwnPropertyDescriptor; for (var u in e) if ("default" !== u && Object.prototype.hasOwnProperty.call(e, u)) { var i = a ? Object.getOwnPropertyDescriptor(e, u) : null; i && (i.get || i.set) ? Object.defineProperty(n, u, i) : n[u] = e[u]; } return n.default = e, t && t.set(e, n), n; }
function _extends() { _extends = Object.assign ? Object.assign.bind() : function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); } /**
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
const Video = /*#__PURE__*/(0, _react.forwardRef)(({
  source,
  style,
  resizeMode,
  posterResizeMode,
  poster,
  fullscreen,
  drm,
  textTracks,
  selectedAudioTrack,
  selectedTextTrack,
  selectedVideoTrack,
  onLoadStart,
  onLoad,
  onError,
  onProgress,
  onSeek,
  onEnd,
  onBuffer,
  onBandwidthUpdate,
  onExternalPlaybackChange,
  onFullscreenPlayerWillPresent,
  onFullscreenPlayerDidPresent,
  onFullscreenPlayerWillDismiss,
  onFullscreenPlayerDidDismiss,
  onReadyForDisplay,
  onPlaybackRateChange,
  onAudioBecomingNoisy,
  onPictureInPictureStatusChanged,
  onRestoreUserInterfaceForPictureInPictureStop,
  onAudioFocusChanged,
  // @todo: fix type
  onTimedMetadata,
  ...rest
}, ref) => {
  const videoRef = (0, _react.useRef)(null);
  const [showPoster, setShowPoster] = (0, _react.useState)(!!poster);
  const [isFullscreen, setIsFullscreen] = (0, _react.useState)(fullscreen);
  const [_restoreUserInterfaceForPIPStopCompletionHandler, setRestoreUserInterfaceForPIPStopCompletionHandler] = (0, _react.useState)();
  const posterStyle = (0, _react.useMemo)(() => ({
    ..._reactNative.StyleSheet.absoluteFillObject,
    resizeMode: posterResizeMode && posterResizeMode !== "none" ? posterResizeMode : "contain"
  }), [posterResizeMode]);
  const src = (0, _react.useMemo)(() => {
    const resolvedSource = (0, _utils.resolveAssetSourceForVideo)(source);
    let uri = resolvedSource.uri || "";
    if (uri && uri.match(/^\//)) uri = `file://${uri}`;
    if (!uri) console.warn("Trying to load empty source");
    const isNetwork = !!(uri && uri.match(/^https?:/));
    const isAsset = !!(uri && uri.match(/^(assets-library|ipod-library|file|content|ms-appx|ms-appdata):/));
    return {
      uri,
      isNetwork,
      isAsset,
      shouldCache: resolvedSource.shouldCache || false,
      type: resolvedSource.type || "",
      mainVer: resolvedSource.mainVer || 0,
      patchVer: resolvedSource.patchVer || 0,
      requestHeaders: (0, _utils.generateHeaderForNative)(resolvedSource === null || resolvedSource === void 0 ? void 0 : resolvedSource.headers)
    };
  }, [source]);
  const _drm = (0, _react.useMemo)(() => {
    if (!drm) return;
    return {
      drmType: drm.type,
      licenseServer: drm.licenseServer,
      headers: (0, _utils.generateHeaderForNative)(drm.headers),
      contentId: drm.contentId,
      certificateUrl: drm.certificateUrl,
      base64Certificate: drm.base64Certificate
    };
  }, [drm]);
  const _selectedTextTrack = (0, _react.useMemo)(() => {
    if (!selectedTextTrack) return;
    if (typeof (selectedTextTrack === null || selectedTextTrack === void 0 ? void 0 : selectedTextTrack.value) === 'number') return {
      seletedTextType: selectedTextTrack === null || selectedTextTrack === void 0 ? void 0 : selectedTextTrack.type,
      index: selectedTextTrack === null || selectedTextTrack === void 0 ? void 0 : selectedTextTrack.value
    };
    return {
      seletedTextType: selectedTextTrack === null || selectedTextTrack === void 0 ? void 0 : selectedTextTrack.type,
      value: selectedTextTrack === null || selectedTextTrack === void 0 ? void 0 : selectedTextTrack.value
    };
  }, [selectedTextTrack]);
  const _selectedAudioTrack = (0, _react.useMemo)(() => {
    if (!selectedAudioTrack) return;
    if (typeof (selectedAudioTrack === null || selectedAudioTrack === void 0 ? void 0 : selectedAudioTrack.value) === 'number') return {
      seletedAudioType: selectedAudioTrack === null || selectedAudioTrack === void 0 ? void 0 : selectedAudioTrack.type,
      index: selectedAudioTrack === null || selectedAudioTrack === void 0 ? void 0 : selectedAudioTrack.value
    };
    return {
      seletedAudioType: selectedAudioTrack === null || selectedAudioTrack === void 0 ? void 0 : selectedAudioTrack.type,
      value: selectedAudioTrack === null || selectedAudioTrack === void 0 ? void 0 : selectedAudioTrack.value
    };
  }, [selectedAudioTrack]);
  const _selectedVideoTrack = (0, _react.useMemo)(() => {
    if (!selectedVideoTrack) return;
    if (typeof (selectedVideoTrack === null || selectedVideoTrack === void 0 ? void 0 : selectedVideoTrack.value) === 'number') return {
      selectedVideoType: selectedVideoTrack === null || selectedVideoTrack === void 0 ? void 0 : selectedVideoTrack.type,
      index: selectedVideoTrack === null || selectedVideoTrack === void 0 ? void 0 : selectedVideoTrack.value
    };
    return {
      selectedVideoType: selectedVideoTrack === null || selectedVideoTrack === void 0 ? void 0 : selectedVideoTrack.type,
      value: selectedVideoTrack === null || selectedVideoTrack === void 0 ? void 0 : selectedVideoTrack.value
    };
  }, [selectedVideoTrack]);
  const seek = (0, _react.useCallback)((time, tolerance) => {
    if (isNaN(time)) throw new Error("Specified time is not a number");
    if (!videoRef.current) return;
    _VideoNativeComponent.Commands.seek(videoRef.current, time, tolerance ?? 100);
  }, []);
  const presentFullscreenPlayer = (0, _react.useCallback)(() => {
    setIsFullscreen(true);
  }, [setIsFullscreen]);
  const dismissFullscreenPlayer = (0, _react.useCallback)(() => {
    setIsFullscreen(false);
  }, [setIsFullscreen]);
  const save = (0, _react.useCallback)(async () => {
    if (!videoRef.current) return;
    _VideoNativeComponent.Commands.save(videoRef.current);
  }, []);
  const restoreUserInterfaceForPictureInPictureStopCompleted = (0, _react.useCallback)(restored => {
    setRestoreUserInterfaceForPIPStopCompletionHandler(restored);
  }, [setRestoreUserInterfaceForPIPStopCompletionHandler]);
  const onVideoLoadStart = (0, _react.useCallback)(e => {
    onLoadStart === null || onLoadStart === void 0 || onLoadStart(e.nativeEvent);
  }, [onLoadStart]);

  // const onVideoLoad = useCallback(
  //   (e: NativeSyntheticEvent<OnLoadData>) => {
  //     if (Platform.OS === "windows") setShowPoster(false);
  //     onLoad?.(e.nativeEvent);
  //   },
  //   [onLoad, setShowPoster]
  // );

  /** @todo: fix type */
  const _onVideoLoad = (0, _react.useCallback)(e => {
    if (_reactNative.Platform.OS === "windows") setShowPoster(false);
    onLoad === null || onLoad === void 0 || onLoad(e.nativeEvent);
  }, [onLoad, setShowPoster]);
  const onVideoError = (0, _react.useCallback)(e => {
    onError === null || onError === void 0 || onError(e.nativeEvent);
  }, [onError]);
  const onVideoProgress = (0, _react.useCallback)(e => {
    onProgress === null || onProgress === void 0 || onProgress(e.nativeEvent);
  }, [onProgress]);
  const onVideoSeek = (0, _react.useCallback)(e => {
    onSeek === null || onSeek === void 0 || onSeek(e.nativeEvent);
  }, [onSeek]);

  /** @todo: fix type */
  const _onTimedMetadata = (0, _react.useCallback)(e => {
    onTimedMetadata === null || onTimedMetadata === void 0 || onTimedMetadata(e.nativeEvent);
  }, [onTimedMetadata]);
  const _onPlaybackRateChange = (0, _react.useCallback)(e => {
    onPlaybackRateChange === null || onPlaybackRateChange === void 0 || onPlaybackRateChange(e.nativeEvent);
  }, [onPlaybackRateChange]);
  const _onReadyForDisplay = (0, _react.useCallback)(() => {
    setShowPoster(false);
    onReadyForDisplay === null || onReadyForDisplay === void 0 || onReadyForDisplay();
  }, [setShowPoster, onReadyForDisplay]);
  const _onPictureInPictureStatusChanged = (0, _react.useCallback)(e => {
    onPictureInPictureStatusChanged === null || onPictureInPictureStatusChanged === void 0 || onPictureInPictureStatusChanged(e.nativeEvent);
  }, [onPictureInPictureStatusChanged]);
  const _onAudioFocusChanged = (0, _react.useCallback)(e => {
    onAudioFocusChanged === null || onAudioFocusChanged === void 0 || onAudioFocusChanged(e.nativeEvent);
  }, [onAudioFocusChanged]);
  const onVideoBuffer = (0, _react.useCallback)(e => {
    onBuffer === null || onBuffer === void 0 || onBuffer(e.nativeEvent);
  }, [onBuffer]);
  const onVideoExternalPlaybackChange = (0, _react.useCallback)(e => {
    onExternalPlaybackChange === null || onExternalPlaybackChange === void 0 || onExternalPlaybackChange(e.nativeEvent);
  }, [onExternalPlaybackChange]);
  const _onBandwidthUpdate = (0, _react.useCallback)(e => {
    onBandwidthUpdate === null || onBandwidthUpdate === void 0 || onBandwidthUpdate(e.nativeEvent);
  }, [onBandwidthUpdate]);
  const onGetLicense = (0, _react.useCallback)(event => {
    if (drm && drm.getLicense instanceof Function) {
      const data = event.nativeEvent;
      if (data && data.spcBase64) {
        const getLicenseOverride = drm.getLicense(data.spcBase64, data.contentId, data.licenseUrl);
        const getLicensePromise = Promise.resolve(getLicenseOverride); // Handles both scenarios, getLicenseOverride being a promise and not.
        getLicensePromise.then(result => {
          if (result !== undefined) {
            //   if (videoRef.current) Commands.setLicenseResult(videoRef.current, result);
            // } else {
            //   if (videoRef.current) Commands.setLicenseResultError(videoRef.current, 'Empty license result');
          }
        }).catch(() => {
          // if (videoRef.current) Commands.setLicenseResultError(videoRef.current, 'fetch error');
        });
      } else {
        // if (videoRef.current) Commands.setLicenseResultError(videoRef.current, 'No spc received');
      }
    }
  }, [drm]);
  (0, _react.useImperativeHandle)(ref, () => ({
    seek,
    presentFullscreenPlayer,
    dismissFullscreenPlayer,
    save,
    restoreUserInterfaceForPictureInPictureStopCompleted
  }), [seek, presentFullscreenPlayer, dismissFullscreenPlayer, save, restoreUserInterfaceForPictureInPictureStopCompleted]);
  return /*#__PURE__*/_react.default.createElement(_reactNative.View, {
    style: style
  }, /*#__PURE__*/_react.default.createElement(_VideoNativeComponent.default, _extends({
    ref: videoRef
  }, rest, {
    src: src,
    drm: _drm,
    style: _reactNative.StyleSheet.absoluteFill,
    resizeMode: resizeMode,
    fullscreen: isFullscreen,
    restoreUserInterfaceForPIPStopCompletionHandler: _restoreUserInterfaceForPIPStopCompletionHandler,
    textTracks: textTracks,
    selectedTextTrack: _selectedTextTrack,
    selectedAudioTrack: _selectedAudioTrack,
    selectedVideoTrack: _selectedVideoTrack,
    onGetLicense: onGetLicense,
    onVideoLoad: e => {
      _onVideoLoad(e);
    },
    onVideoLoadStart: onVideoLoadStart,
    onVideoError: onVideoError,
    onVideoProgress: onVideoProgress,
    onVideoSeek: onVideoSeek,
    onVideoEnd: onEnd,
    onVideoBuffer: onVideoBuffer,
    onBandwidthUpdate: _onBandwidthUpdate,
    onTimedMetadata: e => {
      _onTimedMetadata(e);
    },
    onVideoFullscreenPlayerDidDismiss: onFullscreenPlayerDidDismiss,
    onVideoFullscreenPlayerDidPresent: onFullscreenPlayerDidPresent,
    onVideoFullscreenPlayerWillDismiss: onFullscreenPlayerWillDismiss,
    onVideoFullscreenPlayerWillPresent: onFullscreenPlayerWillPresent,
    onVideoExternalPlaybackChange: onVideoExternalPlaybackChange,
    onAudioFocusChanged: _onAudioFocusChanged,
    onReadyForDisplay: _onReadyForDisplay,
    onPlaybackRateChange: _onPlaybackRateChange,
    onVideoAudioBecomingNoisy: onAudioBecomingNoisy,
    onPictureInPictureStatusChanged: _onPictureInPictureStatusChanged,
    onRestoreUserInterfaceForPictureInPictureStop: onRestoreUserInterfaceForPictureInPictureStop
  })), showPoster ? /*#__PURE__*/_react.default.createElement(_reactNative.Image, {
    style: posterStyle,
    source: {
      uri: poster
    }
  }) : null);
});
var _default = exports.default = Video;
//# sourceMappingURL=Video.js.map