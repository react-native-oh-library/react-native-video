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

#pragma once
#include "RNOH/Package.h"
#include <react/renderer/components/react_native_video/ComponentDescriptors.h>
#include "RNOH/generated/components/RNCVideoJSIBinder.h"
#include "RNOH/generated/components/RNCVideoViewNapiBinder.h"
#include "RNOH/generated/turbo_modules/VideoDecoderInfoModule.h"
#include "RNOH/generated/turbo_modules/VideoManager.h"
#include "glog/logging.h"


using namespace rnoh;
using namespace facebook;

namespace rnoh {

class BaseReactNativeVideoPackageTurboModuleFactoryDelegate : public TurboModuleFactoryDelegate {
  public:
    SharedTurboModule createTurboModule(Context ctx, const std::string &name) const override {
        if (name == "VideoDecoderInfoModule") {
            return std::make_shared<VideoDecoderInfoModule>(ctx, name);
        }
        if (name == "VideoManager") {
            return std::make_shared<VideoManager>(ctx, name);
        }
        return nullptr;
    };
};

class BaseReactNativeVideoPackageEventEmitRequestHandler : public EventEmitRequestHandler {
  public:
    void handleEvent(Context const &ctx) override {
        auto eventEmitter = ctx.shadowViewRegistry->getEventEmitter<facebook::react::EventEmitter>(ctx.tag);
        if (eventEmitter == nullptr) {
            return;
        }

        std::vector<std::string> supportedComponentNames = {
            "RNCVideo",
        };

        std::vector<std::string> supportedEventNames = {
            "controlsVisibilityChange",
            "videoLoad",
            "videoLoadStart",
            "videoAspectRatio",
            "videoBuffer",
            "videoError",
            "videoProgress",
            "videoBandwidthUpdate",
            "videoSeek",
            "videoEnd",
            "videoAudioBecomingNoisy",
            "videoFullscreenPlayerWillPresent",
            "videoFullscreenPlayerDidPresent",
            "videoFullscreenPlayerWillDismiss",
            "videoFullscreenPlayerDidDismiss",
            "readyForDisplay",
            "playbackRateChange",
            "volumeChange",
            "videoExternalPlaybackChange",
            "getLicense",
            "pictureInPictureStatusChanged",
            "restoreUserInterfaceForPictureInPictureStop",
            "receiveAdEvent",
            "videoPlaybackStateChanged",
            "videoIdle",
            "audioFocusChanged",
            "timedMetadata",
            "audioTracks",
            "textTracks",
            "textTrackDataChanged",
            "videoTracks",
        };

        if (std::find(supportedEventNames.begin(), supportedEventNames.end(), ctx.eventName) != supportedEventNames.end()) {
            eventEmitter->dispatchEvent(ctx.eventName, ArkJS(ctx.env).getDynamic(ctx.payload));
        }
    }
};

class RNCVideoArkTsMessage : public ArkTSMessageHandler {
    void handleArkTSMessage(const Context &ctx) override
    {
        auto rnInstance = ctx.rnInstance.lock();
        if (rnInstance) {
        }
    }
};

class RNCVideoPackage : public Package {
public:
    RNCVideoPackage(Package::Context ctx) : Package(ctx) {}
    
    std::unique_ptr<TurboModuleFactoryDelegate> createTurboModuleFactoryDelegate() override {
        return std::make_unique<BaseReactNativeVideoPackageTurboModuleFactoryDelegate>();
    }
    
    std::vector<facebook::react::ComponentDescriptorProvider> createComponentDescriptorProviders() override 
    {
        return {
            facebook::react::concreteComponentDescriptorProvider<facebook::react::RNCVideoComponentDescriptor>(),
        };
    }

    ComponentJSIBinderByString createComponentJSIBinderByName() override 
    {
        return {{"RNCVideo", std::make_shared<RNCVideoJSIBinder>()}};
    };

    ComponentNapiBinderByString createComponentNapiBinderByName() override
    {
        return {{"RNCVideo", std::make_shared<RNCVideoViewNapiBinder>()}};
    };

    EventEmitRequestHandlers createEventEmitRequestHandlers() override
    {
        return {std::make_shared<BaseReactNativeVideoPackageEventEmitRequestHandler>()};
    }
    
    std::vector<ArkTSMessageHandler::Shared> createArkTSMessageHandlers() override
    {
        return { std::make_shared<RNCVideoArkTsMessage>() };
    }
};
} // namespace rnoh

