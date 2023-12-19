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
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
import type { HostComponent, ViewProps } from 'react-native';

import type { Float, Int32, WithDefault, DirectEventHandler, Double } from 'react-native/Libraries/Types/CodegenTypes';

type Headers = ReadonlyArray<Readonly<{
  key: string;
  value: string;
}>>

type VideoSrc = Readonly<{
  uri?: string;
  isNetwork?: boolean;
  isAsset?: boolean;
  shouldCache?: boolean;
  type?: string;
  mainVer?: Int32;
  patchVer?: Int32;
  requestHeaders?: Headers;
}>

export type DrmType = WithDefault<'widevine' | 'playready' | 'clearkey' | 'fairplay', 'widevine'>;
type Drm = Readonly<{
  drmType?: DrmType;
  licenseServer?: string;
  headers?: Headers;
  contentId?: string; // ios
  certificateUrl?: string; // ios
  base64Certificate?: boolean; // ios default: false
}>

type TextTracks = ReadonlyArray<Readonly<{
  title: string;
  language: string;
  type: string;
  uri: string;
}>>

type AudioTrackType = WithDefault<'system' | 'disabled' | 'title' | 'language' | 'index', 'system'>;

type SelectedAudioTrack = Readonly<{
  selectedAudioType?: AudioTrackType;
  value?: string;
  index?: Int32;
}>

type TextTrackType = WithDefault<'system' | 'disabled' | 'title' | 'language' | 'index', 'system'>;

type SelectedTextTrack = Readonly<{
  selectedTextType?: TextTrackType;
  value?: string;
  index?: Int32;
}>

type VideoTrackType = WithDefault<'auto' | 'disabled' | 'resolution' | 'index', 'auto'>;

type SelectedVideoTrack = Readonly<{
  selectedVideoType?: VideoTrackType;
  value?: string;
  index?: Int32;
}>

// type SelectedVideoTrack = Readonly<{
//   type?: WithDefault<'auto' | 'disabled' | 'resolution' | 'index', 'auto'>
//   value?: Int32;
// }>

export type Seek = Readonly<{
  time: Float;
  tolerance?: Float;
}>

export type OnLoadStartData = Readonly<{
  isNetwork: boolean;
  type: string;
  uri: string;
}>

// @todo: fix type. for now react native doesn't support array codegen type for native event
type audioTracksData = ReadonlyArray<Readonly<{
  index?: Int32;
  title?: string;
  language?: string;
  type?: string;
}>>
type videoTracksData = ReadonlyArray<Readonly<{
  trackId ?: Int32; // ID for the track
  bitrate ?: Float
  codecs ?: string; // Comma separated list of codecs
  type?: string;
  height?: Float;
  width ?: Float;
}>>

// export type OnLoadData = Readonly<{
//   currentPosition: Float;
//   duration: Float;
//   naturalSize: Readonly<{
//     width: Float;
//     height: Float;
//     orientation: string;
//   }>;
//   audioTracks: ReadonlyArray<audioTracksData>;
//   textTracks: ReadonlyArray<audioTracksData>;
//   videoTracks: ReadonlyArray<videoTracksData>;
// }>

// @todo: fix type. for now react native doesn't support array codegen type for native event
type _OnLoadData = Readonly<{}>
export type OnLoadData = Readonly<{
  currentPosition: Float;
  duration: Float;
  naturalSize: Readonly<{
    width: Float;
    height: Float;
    orientation: string;
  }>;
  audioTracks:audioTracksData;
  textTracks: audioTracksData;
  videoTracks:videoTracksData;
}>

export type OnVideoErrorData = Readonly<{
  error: string;
}>

export type OnProgressData = Readonly<{
  currentTime: Float;
  playableDuration: Float;
  seekableDuration: Float;
}>

export type OnSeekData = Readonly<{
  currentTime: Float; // The current time after the seek eg: currentTime: 100.5
  seekTime: Float;
}>

export type OnBufferData = Readonly<{
  isBuffering: boolean  // Callback when remote video is buffering
}>;

export type OnBandwidthUpdateData = Readonly<{
  bitrate: Float  // The estimated bitrate in bits/sec
}>;

export type OnExternalPlaybackChangeData = Readonly<{
  isExternalPlaybackActive: boolean  // Boolean indicating whether external playback mode is active
}>;

// @todo: fix type. for now react native doesn't support array codegen type for native event
type _OnTimedMetadataData = Readonly<{}>
export type OnTimedMetadataData = Readonly<{
  metadata: ReadonlyArray<Readonly<{
    value?: string
    identifier?: string
  }>>
}>

export type OnPlaybackData = Readonly<{
  playbackRate: Float; // 0 when playback is paused, 1 when playing at normal speed. Other values when playback is slowed down or sped up
}>;

export type OnAudioFocusChangedData = Readonly<{
  hasFocus: boolean;
}>

export type OnGetLicenseData = Readonly<{
  licenseUrl: string;
  contentId: string;
  spcBase64: string;
}>

export type OnPictureInPictureStatusChangedData = Readonly<{
  isActive: boolean;
}>

type BufferConfig = Readonly<{
  minBufferMs?: Float;
  maxBufferMs?: Float;
  bufferForPlaybackMs?: Float;
  bufferForPlaybackAfterRebufferMs?: Float;
}>

export type Filter = WithDefault<'None' |
'CIColorInvert' |
'CIColorMonochrome' |
'CIColorPosterize' |
'CIFalseColor' |
'CIMaximumComponent' |
'CIMinimumComponent' |
'CIPhotoEffectChrome' |
'CIPhotoEffectFade' |
'CIPhotoEffectInstant' |
'CIPhotoEffectMono' |
'CIPhotoEffectNoir' |
'CIPhotoEffectProcess' |
'CIPhotoEffectTonal' |
'CIPhotoEffectTransfer' |
'CISepiaTone', 'None'>;




export interface VideoNativeProps extends ViewProps {
  // 这里申明的属性和方法，是需要传递给安卓 iOS 鸿蒙等本地native端使用
  // Configurable props
  src: VideoSrc; // source 资源源
  drm?: Drm;

  allowsExternalPlayback?: boolean // iOS
  // audioOnly?: boolean // all rn框架能力，纯js实现，不用移植适配
  automaticallyWaitsToMinimizeStalling?: boolean // iOS
  bufferConfig?: BufferConfig // Platforms: Android ExoPlayer
  controls?: boolean // Platforms: Android ExoPlayer, iOS, react-native-dom
  currentPlaybackTime?: Double // Platforms: Android ExoPlayer, iOS
  disableFocus?: boolean // Platforms: Android Exoplayer
  filter?: Filter // iOS
  filterEnabled?: boolean // iOS
  fullscreen?: boolean; // ios, default false
  fullscreenAutorotate?: boolean; // ios, default true
  fullscreenOrientation?: WithDefault<'all' | 'landscape' | 'portrait', 'all'>; // iOS
  // headers // Pass headers to the HTTP client. Can be used for authorization. Headers must be a part of the source object.
  hideShutterView?: boolean //	Platforms: Android ExoPlayer, default false
  // id?: string // Platforms: react-native-dom, id="video"
  ignoreSilentSwitch?: WithDefault<'inherit' | 'ignore' | 'obey', 'inherit'>; // ios, 'inherit'
  maxBitRate?: Float // Platforms: Android ExoPlayer, iOS  Default: 0. Don't limit the maxBitRate.
  minLoadRetryCount?: Int32; // Android ExoPlayer
  mixWithOthers?: WithDefault<'inherit' | 'mix' | 'duck', 'inherit'>; // ios, 'inherit'
  muted?: boolean; // all ,false (default) - Don't mute audio
  paused?: boolean; // all , false (default) - Don't pause the media
  pictureInPicture?: boolean; // ios, false
  playInBackground?: boolean; // Platforms: Android ExoPlayer, Android MediaPlayer, iOS || false (default) - Don't continue playing the media
  playWhenInactive?: boolean; // ios, false
  // poster?: string; // all, rn框架能力，纯js实现，不用移植适配
  // posterResizeMode?: WithDefault<'contain' | 'center' | 'cover' | 'none' | 'repeat' | 'stretch', 'contain'>; // all 纯js
  preferredForwardBufferDuration?: Float; //ios, 0
  preventsDisplaySleepDuringVideoPlayback?: boolean; // ios android
  progressUpdateInterval?: Float;
  rate?: Float;
  repeat?: boolean;
  reportBandwidth?: boolean; //Android
  resizeMode?: WithDefault<'none' | 'contain' | 'cover' | 'stretch', 'none'>;
  selectedAudioTrack?: SelectedAudioTrack; // Android ExoPlayer, iOS
  selectedTextTrack?: SelectedTextTrack; // Android ExoPlayer, iOS
  selectedVideoTrack?: SelectedVideoTrack; // android
  stereoPan?: Float; // Android MediaPlayer,0.0 (default) - Center
  textTracks?: TextTracks; // Platforms: Android ExoPlayer, iOS
  trackId?: string; // Android
  useTextureView?: boolean;	// Android
  volume?: Float; // default 1.0
  restoreUserInterfaceForPIPStopCompletionHandler?: boolean;

  // Event props
  onVideoAudioBecomingNoisy?: DirectEventHandler<Readonly<{}>>; // Platforms: Android ExoPlayer, iOS
  onBandwidthUpdate?: DirectEventHandler<OnBandwidthUpdateData>// Platforms: Android ExoPlayer
  onVideoEnd?: DirectEventHandler<Readonly<{}>>; // all  onEnd
  onVideoExternalPlaybackChange?: DirectEventHandler<OnExternalPlaybackChangeData>; // iOS
  onVideoFullscreenPlayerWillPresent?: DirectEventHandler<Readonly<{}>>; // Platforms: Android ExoPlayer, Android MediaPlayer, iOS
  onVideoFullscreenPlayerDidPresent?: DirectEventHandler<Readonly<{}>>;  // Platforms: Android ExoPlayer, Android MediaPlayer, iOS
  onVideoFullscreenPlayerWillDismiss?: DirectEventHandler<Readonly<{}>>;  // iOS, android
  onVideoFullscreenPlayerDidDismiss?: DirectEventHandler<Readonly<{}>>;  // iOS, android
  onVideoLoad?: DirectEventHandler<_OnLoadData>; // all
  onVideoLoadStart?: DirectEventHandler<OnLoadStartData>; // all
  onReadyForDisplay?: DirectEventHandler<Readonly<{}>>; // Platforms: Android ExoPlayer, Android MediaPlayer, iOS, Web
  onPictureInPictureStatusChanged?: DirectEventHandler<OnPictureInPictureStatusChangedData>; // iOS
  onPlaybackRateChange?: DirectEventHandler<OnPlaybackData>; // all
  onVideoProgress?: DirectEventHandler<OnProgressData>; // all
  onVideoSeek?: DirectEventHandler<OnSeekData>; // Platforms: Android ExoPlayer, Android MediaPlayer, iOS, Windows UWP
  onRestoreUserInterfaceForPictureInPictureStop?: DirectEventHandler<Readonly<{}>>; // iOS
  onTimedMetadata?: DirectEventHandler<_OnTimedMetadataData>; // Platforms: Android ExoPlayer, Android MediaPlayer, iOS

  onVideoError?: DirectEventHandler<OnVideoErrorData>; // (nowhere in document, so do not use as props. just type declaration)
  onVideoBuffer?: DirectEventHandler<OnBufferData>; // (nowhere in document, so do not use as props. just type declaration)
  onPlaybackStalled?: DirectEventHandler<Readonly<{}>>; // (nowhere in document, so do not use as props. just type declaration)
  onPlaybackResume?: DirectEventHandler<Readonly<{}>>; //  (nowhere in document, so do not use as props. just type declaration)
  onAudioFocusChanged?: DirectEventHandler<OnAudioFocusChangedData>; // (nowhere in document, so do not use as props. just type declaration)
  onGetLicense?: DirectEventHandler<OnGetLicenseData>; // Platforms: iOS (nowhere in document, so do not use as props. just type declaration)

}

export type VideoComponentType = HostComponent<VideoNativeProps>
export interface NativeCommands {
  // src: (viewRef: React.ElementRef<VideoComponentType>,src:string) => void;
  save: (viewRef: React.ElementRef<VideoComponentType>) => void;
  seek: (viewRef: React.ElementRef<VideoComponentType>, time: Float, tolerance?: Float) => void;
  // fullscreen: (viewRef: React.ElementRef<VideoComponentType>, isFullscreen: boolean) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: [
    // 'src',
    'save',
    'seek',
    // 'fullscreen',
  ],
});

export default codegenNativeComponent<VideoNativeProps>('RNCVideo') as VideoComponentType;


