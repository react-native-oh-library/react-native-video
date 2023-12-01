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
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANT KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "EventEmitters.h"

namespace facebook{
    namespace react {


void RNCVideoEventEmitter::onVideoAudioBecomingNoisy(OnVideoAudioBecomingNoisy event) const {
    dispatchEvent("videoAudioBecomingNoisy",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        return payload;
    });
}

void RNCVideoEventEmitter::onBandwidthUpdate(OnBandwidthUpdate event) const {
    dispatchEvent("bandwidthUpdate",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime,"bitrate",event.bitrate);
        return payload;
    });
}


void RNCVideoEventEmitter::onVideoEnd(OnVideoEnd event) const {
    dispatchEvent("videoEnd",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        return payload;
    });
}

void RNCVideoEventEmitter::onVideoExternalPlaybackChange(OnVideoExternalPlaybackChange event) const {
    dispatchEvent("videoExternalPlaybackChange",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime,"isExternalPlaybackActive",event.isExternalPlaybackActive);
        return payload;
    });
}



void RNCVideoEventEmitter::onVideoFullscreenPlayerWillPresent(OnVideoFullscreenPlayerWillPresent event) const {
    dispatchEvent("videoFullscreenPlayerWillPresent",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        return payload;
    });
}

void RNCVideoEventEmitter::onVideoFullscreenPlayerDidPresent(OnVideoFullscreenPlayerDidPresent event) const {
    dispatchEvent("videoFullscreenPlayerDidPresent",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        return payload;
    });
}

void RNCVideoEventEmitter::onVideoFullscreenPlayerWillDismiss(OnVideoFullscreenPlayerWillDismiss event) const {
    dispatchEvent("videoFullscreenPlayerWillDismiss",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        return payload;
    });
}

void RNCVideoEventEmitter::onVideoFullscreenPlayerDidDismiss(OnVideoFullscreenPlayerDidDismiss event) const {
    dispatchEvent("videoFullscreenPlayerDidDismiss",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        return payload;
    });
}

void RNCVideoEventEmitter::onVideoLoad(OnVideoLoad event) const {
    dispatchEvent("videoLoad",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
         payload.setProperty(runtime,"currentPosition",event.currentPosition);
         payload.setProperty(runtime,"duration",event.duration);
         {
            auto naturalSize = jsi::Object(runtime);
            naturalSize.setProperty(runtime,"width",event.naturalSize.width);
            naturalSize.setProperty(runtime,"height",event.naturalSize.height);
            naturalSize.setProperty(runtime,"orientation",event.naturalSize.orientation);
            payload.setProperty(runtime,"naturalSize",naturalSize);

             auto audioTracks = jsi::Array(runtime,event.audioTracks.size());
             for(int i = 0 ; i < event.audioTracks.size(); ++i){
               auto subAudioTracks = jsi::Object(runtime);
               subAudioTracks.setProperty(runtime,"index",event.audioTracks[i].index);
               subAudioTracks.setProperty(runtime,"title",event.audioTracks[i].title);
               subAudioTracks.setProperty(runtime,"language",event.audioTracks[i].language);
               subAudioTracks.setProperty(runtime,"type",event.audioTracks[i].type);
               audioTracks.setValueAtIndex(runtime,i,subAudioTracks);
             }
             payload.setProperty(runtime,"audioTracks",audioTracks);

            auto videoTracks = jsi::Array(runtime, event.videoTracks.size());
             for(int i = 0 ; i < event.videoTracks.size(); ++i){
               auto subVideoTracks = jsi::Object(runtime);
               subVideoTracks.setProperty(runtime,"trackId",event.videoTracks[i].trackId);
               subVideoTracks.setProperty(runtime,"bitrate",event.videoTracks[i].bitrate);
               subVideoTracks.setProperty(runtime,"codecs",event.videoTracks[i].codecs);
               subVideoTracks.setProperty(runtime,"height",event.videoTracks[i].height);
               subVideoTracks.setProperty(runtime,"width",event.videoTracks[i].width);
               videoTracks.setValueAtIndex(runtime,i,subVideoTracks);
             }
             payload.setProperty(runtime,"videoTracks",videoTracks);
         };
         
        return payload;
    });
}


void RNCVideoEventEmitter::onVideoLoadStart(OnVideoLoadStart event) const {
    dispatchEvent("videoLoadStart",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime,"isNetwork",event.isNetwork);
        payload.setProperty(runtime,"type",event.type);
        payload.setProperty(runtime,"uri",event.uri);
        return payload;
    });
}


void RNCVideoEventEmitter::onReadyForDisplay(OnReadyForDisplay event) const {
    dispatchEvent("readyForDisplay",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        return payload;
    });
}



void RNCVideoEventEmitter::onPictureInPictureStatusChanged(OnPictureInPictureStatusChanged event) const {
    dispatchEvent("pictureInPictureStatusChanged",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime,"isActive",event.isActive);
        return payload;
    });
}


void RNCVideoEventEmitter::onPlaybackRateChange(OnPlaybackRateChange event) const {
    dispatchEvent("playbackRateChange",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime,"playbackRate",event.playbackRate);
        return payload;
    });
}

void RNCVideoEventEmitter::onVideoProgress(OnVideoProgress event) const {
    dispatchEvent("videoProgress",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime,"currentTime",event.currentTime);
        payload.setProperty(runtime,"playableDuration",event.playableDuration);
        payload.setProperty(runtime,"seekableDuration",event.seekableDuration);
        return payload;
    });
}

void RNCVideoEventEmitter::onVideoSeek(OnVideoSeek event) const {
    dispatchEvent("videoSeek",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime,"currentTime",event.currentTime);
        payload.setProperty(runtime,"seekTime",event.seekTime);
        return payload;
    });
}
  
  void RNCVideoEventEmitter::onRestoreUserInterfaceForPictureInPictureStop(OnRestoreUserInterfaceForPictureInPictureStop event) const {
    dispatchEvent("restoreUserInterfaceForPictureInPictureStop",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        return payload;
    });
}


void RNCVideoEventEmitter::onTimedMetadata(OnTimedMetadata event) const {
    dispatchEvent("timedMetadata",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        return payload;
    });
}



void RNCVideoEventEmitter::onVideoError(OnVideoError event) const {
    dispatchEvent("videoError",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime,"error",event.error);
        return payload;
    });
}


void RNCVideoEventEmitter::onVideoBuffer(OnVideoBuffer event) const {
    dispatchEvent("videoBuffer",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime,"isBuffering",event.isBuffering);
        return payload;
    });
}

void RNCVideoEventEmitter::onPlaybackStalled(OnPlaybackStalled event) const {
    dispatchEvent("playbackStalled",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        return payload;
    });
}

void RNCVideoEventEmitter::onPlaybackResume(OnPlaybackResume event) const {
    dispatchEvent("playbackResume",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        return payload;
    });
}



void RNCVideoEventEmitter::onAudioFocusChanged(OnAudioFocusChanged event) const {
    dispatchEvent("audioFocusChanged",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime,"hasFocus",event.hasFocus);
        return payload;
    });
}


void RNCVideoEventEmitter::onGetLicense(OnGetLicense event) const {
    dispatchEvent("getLicense",[event=std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
         payload.setProperty(runtime,"licenseUrl",event.licenseUrl);
         payload.setProperty(runtime,"contentId",event.contentId);
         payload.setProperty(runtime,"spcBase64",event.spcBase64);
        return payload;
    });
}

} //namespace react
} //namespace facebook
