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
import type { OnBandwidthUpdateData, OnBufferData, OnLoadData, OnLoadStartData, OnProgressData, OnSeekData, OnPlaybackData, OnExternalPlaybackChangeData, OnPictureInPictureStatusChangedData, OnVideoErrorData, OnAudioFocusChangedData, OnTimedMetadataData } from 'src/fabric/VideoNativeComponent';
export interface ReactVideoEvents {
    onAudioBecomingNoisy?: () => void;
    onBandwidthUpdate?: (e: OnBandwidthUpdateData) => void;
    onAudioFocusChanged?: (e: OnAudioFocusChangedData) => void;
    onEnd?: () => void;
    onBuffer?: (e: OnBufferData) => void;
    onError?: (e: OnVideoErrorData) => void;
    onExternalPlaybackChange?: (e: OnExternalPlaybackChangeData) => void;
    onFullscreenPlayerWillPresent?: () => void;
    onFullscreenPlayerDidPresent?: () => void;
    onFullscreenPlayerWillDismiss?: () => void;
    onFullscreenPlayerDidDismiss?: () => void;
    onLoad?: (e: OnLoadData) => void;
    onLoadStart?: (e: OnLoadStartData) => void;
    onReadyForDisplay?: () => void;
    onPictureInPictureStatusChanged?: (e: OnPictureInPictureStatusChangedData) => void;
    onPlaybackRateChange?: (e: OnPlaybackData) => void;
    onProgress?: (e: OnProgressData) => void;
    onSeek?: (e: OnSeekData) => void;
    onRestoreUserInterfaceForPictureInPictureStop?: () => void;
    onTimedMetadata?: (e: OnTimedMetadataData) => void;
}
//# sourceMappingURL=events.d.ts.map