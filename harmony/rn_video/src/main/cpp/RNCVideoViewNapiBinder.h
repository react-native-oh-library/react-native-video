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
#include "Props.h"


namespace rnoh {

class RNCVideoViewNapiBinder : public ViewComponentNapiBinder{
public:
    napi_value createProps(napi_env env, facebook::react::ShadowView const shadowView) override 
    {
        napi_value napiViewProps = ViewComponentNapiBinder::createProps(env, shadowView);
        auto propsObjBuilder = ArkJS(env).getObjectBuilder(napiViewProps);
        if (auto props = std::dynamic_pointer_cast<const facebook::react::RNCVideoProps>(shadowView.props)){
            propsObjBuilder
                .addProperty("controls", props->controls)
                .addProperty("paused", props->paused)
                .addProperty("muted", props->muted)
                .addProperty("repeat", props->repeat)
                .addProperty("resizeMode", facebook::react::toString(props->resizeMode))
                .addProperty("volume", props->volume)
                .addProperty("disableFocus", props->disableFocus);
            
            auto srcRaw = props->src;
            auto srcObjBuilder = ArkJS(env).createObjectBuilder();
            
            srcObjBuilder
                .addProperty("uri", srcRaw.uri)
                .addProperty("isNetwork", srcRaw.isNetwork)
                .addProperty("isAsset", srcRaw.isAsset)
                .addProperty("shouldCache", srcRaw.shouldCache)
                .addProperty("type", srcRaw.type)
                .addProperty("mainVer", srcRaw.mainVer)
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
            
            propsObjBuilder.addProperty("src", srcObjBuilder.build());
            
            return propsObjBuilder.build();
        }
        
            return napiViewProps;
    };
};
} // namespace rnoh