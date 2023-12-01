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
#pragma once

#include <react/renderer/components/view/ViewEventEmitter.h>
#include <jsi/jsi.h>

namespace facebook {
namespace react {

class JSI_EXPORT RNCVideoEventEmitter : public ViewEventEmitter {
public:
    using ViewEventEmitter::ViewEventEmitter;
     
    struct OnVideoAudioBecomingNoisy{};
     
    struct OnBandwidthUpdate {
        Float bitrate;
    };

    struct OnVideoEnd{};

    struct OnVideoExternalPlaybackChange{
        bool isExternalPlaybackActive;
    };

    struct OnVideoFullscreenPlayerWillPresent{};

    struct OnVideoFullscreenPlayerDidPresent{};

    struct OnVideoFullscreenPlayerWillDismiss{};

    struct OnVideoFullscreenPlayerDidDismiss{};
  

    struct OnVideoLoadNaturalSize {
        Float width;
        Float height;
        std::string orientation;
    };

    struct OnVideoLoadAudioTracks {
        int index;
        std::string title;
        std::string language;
        std::string type;
    };

    struct OnVideoLoadVideoTracks {
        int trackId;
        Float bitrate;
        std::string codecs;
        Float height;
        Float width;
    };

    
    struct OnVideoLoad{
        Float currentPosition;
        Float duration;
        OnVideoLoadNaturalSize naturalSize ;
        std::vector<OnVideoLoadAudioTracks> audioTracks;
        std::vector<OnVideoLoadVideoTracks> videoTracks;
    };


  
    struct OnVideoLoadStart {
        bool isNetwork;
        std::string type;
        std::string uri;
    };

   struct OnReadyForDisplay {};

   struct OnPictureInPictureStatusChanged {
        bool isActive;
    };

   struct OnPlaybackRateChange {
        Float playbackRate;
    };

    struct OnVideoProgress{
      Float currentTime;
      Float playableDuration;
      Float seekableDuration;
    };

    struct OnVideoSeek{
      Float currentTime;
      Float seekTime;
    };

    struct OnRestoreUserInterfaceForPictureInPictureStop {};
   
    struct OnTimedMetadata {};

    struct OnVideoError{
      std::string error;
    };

   struct OnVideoBuffer{
      bool isBuffering;
    };


    struct OnPlaybackStalled{};
    struct OnPlaybackResume {};

    struct OnAudioFocusChanged{
      bool hasFocus;
    };

    
    struct OnGetLicense {
        std::string licenseUrl;
        std::string contentId;
        std::string spcBase64;
    };



    void onVideoAudioBecomingNoisy(OnVideoAudioBecomingNoisy value) const;


    void onBandwidthUpdate(OnBandwidthUpdate value) const;


    void onVideoEnd(OnVideoEnd value) const;
    
    
    void onVideoExternalPlaybackChange(OnVideoExternalPlaybackChange value) const;
    void onVideoFullscreenPlayerWillPresent(OnVideoFullscreenPlayerWillPresent value) const;
    void onVideoFullscreenPlayerDidPresent(OnVideoFullscreenPlayerDidPresent value) const;
    void onVideoFullscreenPlayerWillDismiss(OnVideoFullscreenPlayerWillDismiss value) const;
    void onVideoFullscreenPlayerDidDismiss(OnVideoFullscreenPlayerDidDismiss value) const;

    void onVideoLoad(OnVideoLoad value) const;
    void onVideoLoadStart(OnVideoLoadStart value) const;
    void onReadyForDisplay(OnReadyForDisplay value) const;
    void onPictureInPictureStatusChanged(OnPictureInPictureStatusChanged value) const;
    void onPlaybackRateChange(OnPlaybackRateChange value) const;
    
    
    void onVideoProgress(OnVideoProgress value) const;
    void onVideoSeek(OnVideoSeek value) const;
    void onRestoreUserInterfaceForPictureInPictureStop(OnRestoreUserInterfaceForPictureInPictureStop value) const;
    void onTimedMetadata(OnTimedMetadata value) const;
    void onVideoError(OnVideoError value) const;
    void onVideoBuffer(OnVideoBuffer value) const;
    void onPlaybackStalled(OnPlaybackStalled value) const;
    void onPlaybackResume(OnPlaybackResume value) const;

    void onAudioFocusChanged(OnAudioFocusChanged value) const;
    void onGetLicense(OnGetLicense value) const;
};

} // namespace react
} // namespace facebook