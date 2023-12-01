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

type Filter = | 'None'
              | 'CIColorInvert'
              | 'CIColorMonochrome'
              | 'CIColorPosterize'
              | 'CIFalseColor'
              | 'CIMaximumComponent'
              | 'CIMinimumComponent'
              | 'CIPhotoEffectChrome'
              | 'CIPhotoEffectFade'
              | 'CIPhotoEffectInstant'
              | 'CIPhotoEffectMono'
              | 'CIPhotoEffectNoir'
              | 'CIPhotoEffectProcess'
              | 'CIPhotoEffectTonal'
              | 'CIPhotoEffectTransfer'
              | 'CISepiaTone'



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
  contentId?: string; // ios
  certificateUrl?: string; // ios
  base64Certificate?: boolean; // ios default: false
  getLicense?: (licenseUrl: string, contentId: string, spcBase64: string) => void; // ios
}>

type BufferConfig = {
  minBufferMs?: number;
  maxBufferMs?: number;
  bufferForPlaybackMs?: number;
  bufferForPlaybackAfterRebufferMs?: number;
}

type SelectedTrack = {
  type: 'system' | 'disabled' | 'title' | 'language' | 'index';
  value?: string | number;
}

type SelectedVideoTrack = {
  type: 'auto' | 'disabled' | 'resolution' | 'index'
  value: number;
}

type TextTracks = {
  title: string;
  language: ISO639_1;
  type: | 'application/x-subrip'
        | 'application/ttml+xml'
        | 'text/vtt';
  uri: string;
}[]

export interface ReactVideoProps extends ReactVideoEvents {
  source: ReactVideoSource;
  drm?: ReactVideoDrm; // Android Exoplayer, iOS
  style?: StyleProp<ViewStyle>;
  allowsExternalPlayback?: boolean // iOS
  audioOnly?: boolean; // all
  automaticallyWaitsToMinimizeStalling?: boolean; // iOS
  bufferConfig?: BufferConfig; // Android
  currentPlaybackTime?: number; // Android ExoPlayer, iOS
  controls?: boolean; // Android ExoPlayer, iOS, react-native-dom
  disableFocus?: boolean; // Android Exoplayer
  filter?: Filter; // iOS
  filterEnabled?:	boolean; // iOS
  fullscreen?: boolean; // iOS
  fullscreenAutorotate?: boolean; // iOS
  fullscreenOrientation?: 'all' | 'landscape' | 'portrait';	// iOS
  hideShutterView?: boolean; //	Android
  ignoreSilentSwitch?: 'inherit' | 'ignore' | 'obey'	// iOS
  maxBitRate?: number;
  minLoadRetryCount?: number;	// Android
  mixWithOthers?: 'inherit' | 'mix' | 'duck'; // iOS
  muted?: boolean;
  paused?: boolean;
  pictureInPicture?: boolean // ios, false
  playInBackground?: boolean // Platforms: Android ExoPlayer, Android MediaPlayer, iOS || false (default) - Don't continue playing the media
  playWhenInactive?: boolean // ios, false
  poster?: string; // all
  posterResizeMode?: 'contain' | 'center' | 'cover' | 'none' | 'repeat' | 'stretch'; //all
  preferredForwardBufferDuration?: number// iOS
  preventsDisplaySleepDuringVideoPlayback?: boolean; // iOS, Android
  progressUpdateInterval?: number; // all
  rate?: number; // all
  repeat?: boolean; // all
  reportBandwidth?: boolean; //Android ExoPlayer
  resizeMode?: 'none' | 'contain' | 'cover' | 'stretch'; // Android ExoPlayer, Android MediaPlayer, iOS, Windows UWP
  selectedAudioTrack?: SelectedTrack; // Android ExoPlayer, iOS
  selectedTextTrack?: SelectedTrack; // Android ExoPlayer, iOS
  selectedVideoTrack?: SelectedVideoTrack; // Android ExoPlayer
  stereoPan?: number // Android MediaPlayer,0.0 (default) - Center
  textTracks?: TextTracks; // Android ExoPlayer, iOS
  trackId?: string; // Android ExoPlayer
  useTextureView?: boolean;	//  Android ExoPlayer,true (default) - Use a TextureView
  volume?: number; // all
}
