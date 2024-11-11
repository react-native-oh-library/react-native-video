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
#include "RNOHCorePackage/ComponentBinders/ViewComponentJSIBinder.h"

namespace rnoh {
class RNCVideoViewJSIBinder : public ViewComponentJSIBinder{
    facebook::jsi::Object createNativeProps(facebook::jsi::Runtime &rt) override 
    {
        auto object = ViewComponentJSIBinder::createNativeProps(rt);
        object.setProperty(rt, "src", "object");
//        object.setProperty(rt, "srcType", "string");
        object.setProperty(rt, "controls", "boolean");
        object.setProperty(rt, "paused", "boolean");
        object.setProperty(rt, "muted", "boolean");
        object.setProperty(rt, "repeat", "boolean");
        object.setProperty(rt, "resizeMode", "string");
        object.setProperty(rt, "volume", "string");
        object.setProperty(rt, "disableFocus", "boolean");
        object.setProperty(rt, "preventsDisplaySleepDuringVideoPlayback", "boolean");
        return object;
    }
    
    facebook::jsi::Object createBubblingEventTypes(facebook::jsi::Runtime &rt) override
    {
        return facebook::jsi::Object(rt);
    }
    
    facebook::jsi::Object createDirectEventTypes(facebook::jsi::Runtime &rt) override
    {
        facebook::jsi::Object events(rt);
        
        events.setProperty(rt, "topVideoLoad", createDirectEvent(rt, "onVideoLoad"));
        events.setProperty(rt, "topVideoLoadStart", createDirectEvent(rt, "onVideoLoadStart"));
        events.setProperty(rt, "topVideoEnd", createDirectEvent(rt, "onVideoEnd"));
        events.setProperty(rt, "topVideoProgress", createDirectEvent(rt, "onVideoProgress"));
        events.setProperty(rt, "topVideoError", createDirectEvent(rt, "onVideoError"));
        events.setProperty(rt, "topVideoBuffer", createDirectEvent(rt, "onVideoBuffer"));
        events.setProperty(rt, "topPlaybackStalled", createDirectEvent(rt, "onPlaybackStalled"));
        events.setProperty(rt, "topPlaybackResume", createDirectEvent(rt, "onPlaybackResume"));
        events.setProperty(rt, "topReadyForDisplay", createDirectEvent(rt, "onReadyForDisplay"));
        return events;
    }
    
};
} // namespace rnoh