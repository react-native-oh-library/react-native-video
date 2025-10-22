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
#include <react/renderer/core/PropsParserContext.h>
#include "RNOHCorePackage/ComponentBinders/ViewComponentNapiBinder.h"
#include "react/renderer/components/react_native_video/Props.h"


namespace rnoh {

class RNCVideoViewNapiBinder : public ViewComponentNapiBinder{
public:
    napi_value createProps(napi_env env, facebook::react::ShadowView const shadowView) override 
    {
        napi_value napiViewProps = ViewComponentNapiBinder::createProps(env, shadowView);
        auto propsObjBuilder = ArkJS(env).getObjectBuilder(napiViewProps);
        if (auto props = std::dynamic_pointer_cast<const facebook::react::RNCVideoProps>(shadowView.props)){
            auto srcRaw = props->src;
            auto srcObjBuilder = ArkJS(env).createObjectBuilder();
            srcObjBuilder
                .addProperty("uri", srcRaw.uri)
                .addProperty("isNetwork", srcRaw.isNetwork)
                .addProperty("isAsset", srcRaw.isAsset)
                .addProperty("shouldCache", srcRaw.shouldCache)
                .addProperty("type", srcRaw.type)
                .addProperty("mainVer", srcRaw.mainVer)
                .addProperty("startPosition", srcRaw.startPosition)
                .addProperty("cropStart", srcRaw.cropStart)
                .addProperty("cropEnd", srcRaw.cropEnd)
                .addProperty("patchVer", srcRaw.patchVer);
               
            auto items = std::vector<napi_value>();
            auto requestHeadersRaw = srcRaw.requestHeaders;
            
            for(auto item : requestHeadersRaw) {
                auto itemObjBuilder = ArkJS(env).createObjectBuilder();
                itemObjBuilder
                    .addProperty("key",item.key)
                    .addProperty("value",item.value);
                items.push_back(itemObjBuilder.build());
            }
            
            auto itemsArray = ArkJS(env).createArray(items);
            srcObjBuilder.addProperty("requestHeaders",itemsArray);
            
            // 添加 drm 属性到 src 对象中
            auto drmRaw = props->src.drm;
            auto drmObjBuilder = ArkJS(env).createObjectBuilder();
            drmObjBuilder
                .addProperty("drmType", facebook::react::toString(drmRaw.type))
                .addProperty("licenseServer", drmRaw.licenseServer)
                .addProperty("contentId", drmRaw.contentId)
                .addProperty("certificateUrl", drmRaw.certificateUrl)
                .addProperty("base64Certificate", drmRaw.base64Certificate);
                
            auto drmHeaders = std::vector<napi_value>();
            auto drmHeadersRaw = drmRaw.headers;
            
            for(auto header : drmHeadersRaw) {
                auto headerObjBuilder = ArkJS(env).createObjectBuilder();
                headerObjBuilder
                    .addProperty("name", header.key)
                    .addProperty("value", header.value);
                drmHeaders.push_back(headerObjBuilder.build());
            }
            
            auto drmHeadersArray = ArkJS(env).createArray(drmHeaders);
            drmObjBuilder.addProperty("headers", drmHeadersArray);
            
            srcObjBuilder.addProperty("drm", drmObjBuilder.build());
            
            propsObjBuilder.addProperty("src", srcObjBuilder.build());
            
            auto controlStyles = props->controlsStyles;
            auto controlStylesObjBuilder = ArkJS(env).createObjectBuilder();
            controlStylesObjBuilder
                .addProperty("hidePosition", controlStyles.hidePosition)
                .addProperty("hidePlayPause", controlStyles.hidePlayPause)
                .addProperty("hideForward", controlStyles.hideForward)
                .addProperty("hideRewind", controlStyles.hideRewind)
                .addProperty("hideNext", controlStyles.hideNext)
                .addProperty("hidePrevious", controlStyles.hidePrevious)
                .addProperty("hideFullscreen", controlStyles.hideFullscreen)
                .addProperty("hideSeekBar", controlStyles.hideSeekBar)
                .addProperty("hideDuration", controlStyles.hideDuration)
                .addProperty("hideNavigationBarOnFullScreenMode", controlStyles.hideNavigationBarOnFullScreenMode)
                .addProperty("hideNotificationBarOnFullScreenMode", controlStyles.hideNotificationBarOnFullScreenMode)
                .addProperty("hideSettingButton", controlStyles.hideSettingButton)
                .addProperty("liveLabel", controlStyles.liveLabel)
                .addProperty("seekIncrementMS", controlStyles.seekIncrementMS);  
            
            propsObjBuilder.addProperty("controlStyles", controlStylesObjBuilder.build());

            propsObjBuilder
                .addProperty("controls", props->controls)
                .addProperty("fullscreen", props->fullscreen)
                .addProperty("paused", props->paused)
                .addProperty("muted", props->muted)
                .addProperty("repeat", props->repeat)
                .addProperty("resizeMode", facebook::react::toString(props->resizeMode))
                .addProperty("volume", props->volume)
                .addProperty("disableFocus", props->disableFocus)
                .addProperty("audioOutput", props->audioOutput)
                .addProperty("rate", props->rate)
                .addProperty("currentPlaybackTime", props->currentPlaybackTime)
                .addProperty("disableDisconnectError", props->disableDisconnectError)
                .addProperty("focusable", props->focusable)
                .addProperty("viewType", props->viewType)
                .addProperty("enterPictureInPictureOnLeave", props->enterPictureInPictureOnLeave);

            // add selectedTextTrack
            if (!props->selectedTextTrack.value.empty()) {
                auto selectedTextTrackBuilder = ArkJS(env).createObjectBuilder();
                selectedTextTrackBuilder
                    .addProperty("value", props->selectedTextTrack.value)
                    .addProperty("type", props->selectedTextTrack.type);
                propsObjBuilder.addProperty("selectedTextTrack", selectedTextTrackBuilder.build());
            }

            // add selectedAudioTrack
            if (props->selectedAudioTrack.value.empty()) {
                auto selectedAudioTrackBuilder = ArkJS(env).createObjectBuilder();
                selectedAudioTrackBuilder
                    .addProperty("value", props->selectedAudioTrack.value)
                    .addProperty("type", props->selectedAudioTrack.type);
                propsObjBuilder.addProperty("selectedAudioTrack", selectedAudioTrackBuilder.build());
            }

            // add selectedVideoTrack
            if (props->selectedVideoTrack.value.empty()) {
                auto selectedVideoTrackBuilder = ArkJS(env).createObjectBuilder();
                selectedVideoTrackBuilder
                    .addProperty("value", props->selectedVideoTrack.value)
                    .addProperty("type", props->selectedVideoTrack.type);
                propsObjBuilder.addProperty("selectedVideoTrack", selectedVideoTrackBuilder.build());
            }
            
            return propsObjBuilder.build();
        }
        return napiViewProps;
    };
};
} // namespace rnoh