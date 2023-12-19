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
import type { ISO639_1 } from './language';
import type { ReactVideoEvents } from './events';
import type { StyleProp, ViewStyle } from 'react-native';
type Filter = 'None' | 'CIColorInvert' | 'CIColorMonochrome' | 'CIColorPosterize' | 'CIFalseColor' | 'CIMaximumComponent' | 'CIMinimumComponent' | 'CIPhotoEffectChrome' | 'CIPhotoEffectFade' | 'CIPhotoEffectInstant' | 'CIPhotoEffectMono' | 'CIPhotoEffectNoir' | 'CIPhotoEffectProcess' | 'CIPhotoEffectTonal' | 'CIPhotoEffectTransfer' | 'CISepiaTone';
type Headers = Record<string, string>;
export type ReactVideoSource = Readonly<{
    uri?: string;
    isNetwork?: boolean;
    isAsset?: boolean;
    shouldCache?: boolean;
    type?: string;
    mainVer?: number;
    patchVer?: number;
    headers?: Headers;
    startTime?: number;
    endTime?: number;
}>;
export type ReactVideoDrm = Readonly<{
    type?: 'widevine' | 'playready' | 'clearkey' | 'fairplay';
    licenseServer?: string;
    headers?: Headers;
    contentId?: string;
    certificateUrl?: string;
    base64Certificate?: boolean;
    getLicense?: (licenseUrl: string, contentId: string, spcBase64: string) => void;
}>;
type BufferConfig = {
    minBufferMs?: number;
    maxBufferMs?: number;
    bufferForPlaybackMs?: number;
    bufferForPlaybackAfterRebufferMs?: number;
};
type SelectedTrack = {
    type: 'system' | 'disabled' | 'title' | 'language' | 'index';
    value?: string | number;
};
type SelectedVideoTrack = {
    type: 'auto' | 'disabled' | 'resolution' | 'index';
    value: number;
};
type TextTracks = {
    title: string;
    language: ISO639_1;
    type: 'application/x-subrip' | 'application/ttml+xml' | 'text/vtt';
    uri: string;
}[];
export interface ReactVideoProps extends ReactVideoEvents {
    source: ReactVideoSource;
    drm?: ReactVideoDrm;
    style?: StyleProp<ViewStyle>;
    allowsExternalPlayback?: boolean;
    audioOnly?: boolean;
    automaticallyWaitsToMinimizeStalling?: boolean;
    bufferConfig?: BufferConfig;
    currentPlaybackTime?: number;
    controls?: boolean;
    disableFocus?: boolean;
    filter?: Filter;
    filterEnabled?: boolean;
    fullscreen?: boolean;
    fullscreenAutorotate?: boolean;
    fullscreenOrientation?: 'all' | 'landscape' | 'portrait';
    hideShutterView?: boolean;
    ignoreSilentSwitch?: 'inherit' | 'ignore' | 'obey';
    maxBitRate?: number;
    minLoadRetryCount?: number;
    mixWithOthers?: 'inherit' | 'mix' | 'duck';
    muted?: boolean;
    paused?: boolean;
    pictureInPicture?: boolean;
    playInBackground?: boolean;
    playWhenInactive?: boolean;
    poster?: string;
    posterResizeMode?: 'contain' | 'center' | 'cover' | 'none' | 'repeat' | 'stretch';
    preferredForwardBufferDuration?: number;
    preventsDisplaySleepDuringVideoPlayback?: boolean;
    progressUpdateInterval?: number;
    rate?: number;
    repeat?: boolean;
    reportBandwidth?: boolean;
    resizeMode?: 'none' | 'contain' | 'cover' | 'stretch';
    selectedAudioTrack?: SelectedTrack;
    selectedTextTrack?: SelectedTrack;
    selectedVideoTrack?: SelectedVideoTrack;
    stereoPan?: number;
    textTracks?: TextTracks;
    trackId?: string;
    useTextureView?: boolean;
    volume?: number;
}
export {};
//# sourceMappingURL=video.d.ts.map