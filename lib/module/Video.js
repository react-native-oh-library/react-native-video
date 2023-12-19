function _extends() { _extends = Object.assign ? Object.assign.bind() : function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }
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
import React, { useState, useCallback, useMemo, useRef, forwardRef, useImperativeHandle } from "react";
import { View, StyleSheet, Image, Platform } from "react-native";
import RNCVideoComponent, { Commands } from "./fabric/VideoNativeComponent";
import { generateHeaderForNative, resolveAssetSourceForVideo } from "./utils";
const Video = /*#__PURE__*/forwardRef(({
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
  const videoRef = useRef(null);
  const [showPoster, setShowPoster] = useState(!!poster);
  const [isFullscreen, setIsFullscreen] = useState(fullscreen);
  const [_restoreUserInterfaceForPIPStopCompletionHandler, setRestoreUserInterfaceForPIPStopCompletionHandler] = useState();
  const posterStyle = useMemo(() => ({
    ...StyleSheet.absoluteFillObject,
    resizeMode: posterResizeMode && posterResizeMode !== "none" ? posterResizeMode : "contain"
  }), [posterResizeMode]);
  const src = useMemo(() => {
    const resolvedSource = resolveAssetSourceForVideo(source);
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
      requestHeaders: generateHeaderForNative(resolvedSource === null || resolvedSource === void 0 ? void 0 : resolvedSource.headers)
    };
  }, [source]);
  const _drm = useMemo(() => {
    if (!drm) return;
    return {
      drmType: drm.type,
      licenseServer: drm.licenseServer,
      headers: generateHeaderForNative(drm.headers),
      contentId: drm.contentId,
      certificateUrl: drm.certificateUrl,
      base64Certificate: drm.base64Certificate
    };
  }, [drm]);
  const _selectedTextTrack = useMemo(() => {
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
  const _selectedAudioTrack = useMemo(() => {
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
  const _selectedVideoTrack = useMemo(() => {
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
  const seek = useCallback((time, tolerance) => {
    if (isNaN(time)) throw new Error("Specified time is not a number");
    if (!videoRef.current) return;
    Commands.seek(videoRef.current, time, tolerance ?? 100);
  }, []);
  const presentFullscreenPlayer = useCallback(() => {
    setIsFullscreen(true);
  }, [setIsFullscreen]);
  const dismissFullscreenPlayer = useCallback(() => {
    setIsFullscreen(false);
  }, [setIsFullscreen]);
  const save = useCallback(async () => {
    if (!videoRef.current) return;
    Commands.save(videoRef.current);
  }, []);
  const restoreUserInterfaceForPictureInPictureStopCompleted = useCallback(restored => {
    setRestoreUserInterfaceForPIPStopCompletionHandler(restored);
  }, [setRestoreUserInterfaceForPIPStopCompletionHandler]);
  const onVideoLoadStart = useCallback(e => {
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
  const _onVideoLoad = useCallback(e => {
    if (Platform.OS === "windows") setShowPoster(false);
    onLoad === null || onLoad === void 0 || onLoad(e.nativeEvent);
  }, [onLoad, setShowPoster]);
  const onVideoError = useCallback(e => {
    onError === null || onError === void 0 || onError(e.nativeEvent);
  }, [onError]);
  const onVideoProgress = useCallback(e => {
    onProgress === null || onProgress === void 0 || onProgress(e.nativeEvent);
  }, [onProgress]);
  const onVideoSeek = useCallback(e => {
    onSeek === null || onSeek === void 0 || onSeek(e.nativeEvent);
  }, [onSeek]);

  /** @todo: fix type */
  const _onTimedMetadata = useCallback(e => {
    onTimedMetadata === null || onTimedMetadata === void 0 || onTimedMetadata(e.nativeEvent);
  }, [onTimedMetadata]);
  const _onPlaybackRateChange = useCallback(e => {
    onPlaybackRateChange === null || onPlaybackRateChange === void 0 || onPlaybackRateChange(e.nativeEvent);
  }, [onPlaybackRateChange]);
  const _onReadyForDisplay = useCallback(() => {
    setShowPoster(false);
    onReadyForDisplay === null || onReadyForDisplay === void 0 || onReadyForDisplay();
  }, [setShowPoster, onReadyForDisplay]);
  const _onPictureInPictureStatusChanged = useCallback(e => {
    onPictureInPictureStatusChanged === null || onPictureInPictureStatusChanged === void 0 || onPictureInPictureStatusChanged(e.nativeEvent);
  }, [onPictureInPictureStatusChanged]);
  const _onAudioFocusChanged = useCallback(e => {
    onAudioFocusChanged === null || onAudioFocusChanged === void 0 || onAudioFocusChanged(e.nativeEvent);
  }, [onAudioFocusChanged]);
  const onVideoBuffer = useCallback(e => {
    onBuffer === null || onBuffer === void 0 || onBuffer(e.nativeEvent);
  }, [onBuffer]);
  const onVideoExternalPlaybackChange = useCallback(e => {
    onExternalPlaybackChange === null || onExternalPlaybackChange === void 0 || onExternalPlaybackChange(e.nativeEvent);
  }, [onExternalPlaybackChange]);
  const _onBandwidthUpdate = useCallback(e => {
    onBandwidthUpdate === null || onBandwidthUpdate === void 0 || onBandwidthUpdate(e.nativeEvent);
  }, [onBandwidthUpdate]);
  const onGetLicense = useCallback(event => {
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
  useImperativeHandle(ref, () => ({
    seek,
    presentFullscreenPlayer,
    dismissFullscreenPlayer,
    save,
    restoreUserInterfaceForPictureInPictureStopCompleted
  }), [seek, presentFullscreenPlayer, dismissFullscreenPlayer, save, restoreUserInterfaceForPictureInPictureStopCompleted]);
  return /*#__PURE__*/React.createElement(View, {
    style: style
  }, /*#__PURE__*/React.createElement(RNCVideoComponent, _extends({
    ref: videoRef
  }, rest, {
    src: src,
    drm: _drm,
    style: StyleSheet.absoluteFill,
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
  })), showPoster ? /*#__PURE__*/React.createElement(Image, {
    style: posterStyle,
    source: {
      uri: poster
    }
  }) : null);
});
export default Video;
//# sourceMappingURL=Video.js.map