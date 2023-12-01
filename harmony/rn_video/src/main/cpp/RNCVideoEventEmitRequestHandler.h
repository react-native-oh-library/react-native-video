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
#include "RNOH/ArkJS.h"
#include "RNOH/EventEmitRequestHandler.h"
#include "EventEmitters.h"

#include <glog/logging.h>
#include "folly/json.h"

using namespace facebook;
namespace rnoh {

enum RNCVideoEventType {
    RNC_VIDEO_LOAD = 0,
    RNC_VIDEO_LOAD_START = 1,
    RNC_VIDEO_BUFFER = 2,
    RNC_VIDEO_ERROR = 3,
    RNC_VIDEO_PROGRESS = 4,
    RNC_VIDEO_BAND_WIDTH_UPDATE = 5,
    RNC_VIDEO_SEEK = 6,
    RNC_VIDEO_END = 7,
    RNC_VIDEO_PLAYBACK_STALLED = 8,
    RNC_VIDEO_PLAYBACK_RESUME = 9,
    RNC_VIDEO_READY_FOR_DISPLAY = 10,
};

RNCVideoEventType getRNCVideoEventType(ArkJS &arkJs, napi_value eventObject)
{
    auto eventType = arkJs.getString(arkJs.getObjectProperty(eventObject, "type"));
    if(eventType == "onVideoLoad"){
        return RNCVideoEventType::RNC_VIDEO_LOAD;
    }else if (eventType == "onVideoLoadStart"){
        return RNCVideoEventType::RNC_VIDEO_LOAD_START;
    }else if (eventType == "onVideoBuffer"){
        return RNCVideoEventType::RNC_VIDEO_BUFFER;
    }else if (eventType == "onVideoError"){
        return RNCVideoEventType::RNC_VIDEO_ERROR;
    }else if (eventType == "onVideoProgress"){
        return RNCVideoEventType::RNC_VIDEO_PROGRESS;
    }else if (eventType == "onBandwidthUpdate"){
        return RNCVideoEventType::RNC_VIDEO_BAND_WIDTH_UPDATE;
    }else if (eventType == "onVideoSeek"){
        return RNCVideoEventType::RNC_VIDEO_SEEK;
    }else if (eventType == "onVideoEnd"){
        return RNCVideoEventType::RNC_VIDEO_END;
    }else if (eventType == "onPlaybackStalled"){
        return RNCVideoEventType::RNC_VIDEO_PLAYBACK_STALLED;
    }else if (eventType == "onPlaybackResume"){
        return RNCVideoEventType::RNC_VIDEO_PLAYBACK_RESUME;
    }else if (eventType == "onReadyForDisplay"){
        return RNCVideoEventType::RNC_VIDEO_READY_FOR_DISPLAY;
    }else {
        throw std::runtime_error("Unknown Page event type");
    }
}

class RNCVideoEventEmitRequestHandler : public EventEmitRequestHandler {
public:
    void handleEvent(EventEmitRequestHandler::Context const &ctx) override
    {
        if(ctx.eventName != "RNCVideo") {
            return;
        }
        ArkJS arkJs(ctx.env);
        auto eventEmitter = ctx.shadowViewRegistry->getEventEmitter<react::RNCVideoEventEmitter>(ctx.tag);
        if(eventEmitter == nullptr) {
            return;
        }
        
        switch (getRNCVideoEventType(arkJs,ctx.payload)){
            case RNCVideoEventType::RNC_VIDEO_LOAD: {
                float currentPosition = (float)arkJs.getDouble(arkJs.getObjectProperty(ctx.payload, "currentPosition"));
                float duration = (float)arkJs.getDouble(arkJs.getObjectProperty(ctx.payload, "duration"));
                LOG(INFO) << "RNCVideoEventEmitRequestHandler RNC_VIDEO_LOAD float currentTime: " << currentPosition ;
                RNOHNapiObject naturalSizeObject = arkJs.getObject(arkJs.getObjectProperty(ctx.payload, "naturalSize"));
                
                float width = (float)arkJs.getDouble(naturalSizeObject.getProperty("width"));
                float height = (float)arkJs.getDouble(naturalSizeObject.getProperty("height"));
                std::string orientation = arkJs.getString(naturalSizeObject.getProperty("orientation"));
                
                LOG(INFO) << "RNCVideoEventEmitRequestHandler RNC_VIDEO_LOAD naturalSizeObject width : " << width ;
                
                facebook::react::RNCVideoEventEmitter::OnVideoLoadNaturalSize naturalSize {
                    width, height, orientation
                };
                react::RNCVideoEventEmitter::OnVideoLoad event{currentPosition, duration, naturalSize};
               
                auto audioTracks = arkJs.getObjectProperty(ctx.payload, "audioTracks");
                if(arkJs.getType(audioTracks) == napi_object) { // FixMe: 此处应该判断你是否是数组
                    int len = arkJs.getArrayLength(audioTracks);
                    for (int i = 0; i < len ; ++i) {
                        auto subAudioTracks = arkJs.getArrayElement(audioTracks, i);
                        auto _subAudioTracks = arkJs.getObject(subAudioTracks);
                        int index = (int)arkJs.getDouble(_subAudioTracks.getProperty("index"));
                        std::string title = arkJs.getString(_subAudioTracks.getProperty("title"));
                        std::string language = arkJs.getString(_subAudioTracks.getProperty("language"));
                        std::string type = arkJs.getString(_subAudioTracks.getProperty("type"));
                        event.audioTracks.push_back({index, title, language, type});
                    }
                }
                
                 auto videoTracks = arkJs.getObjectProperty(ctx.payload, "videoTracks");
                   if(arkJs.getType(videoTracks) == napi_object) { // FixMe: 此处应该判断你是否是数组
                    int len = arkJs.getArrayLength(videoTracks);
                    for (int i = 0; i < len ; ++i) {
                        auto subVideoTracks = arkJs.getArrayElement(videoTracks, i);
                        auto _subVideoTracks = arkJs.getObject(subVideoTracks);
                        int trackId = (int)arkJs.getDouble(_subVideoTracks.getProperty("trackId"));
                        float bitrate = (float)arkJs.getDouble(_subVideoTracks.getProperty("bitrate"));
                        std::string codecs = arkJs.getString(_subVideoTracks.getProperty("codecs"));
                        float height = (float)arkJs.getDouble(_subVideoTracks.getProperty("height"));
                        float width = (float)arkJs.getDouble(_subVideoTracks.getProperty("width"));
                        event.videoTracks.push_back({trackId, bitrate, codecs, height, width});
                    }
                }
                
                eventEmitter->onVideoLoad(event);
                break;
            }
            
            case RNCVideoEventType::RNC_VIDEO_LOAD_START: {
                bool isNetwork = arkJs.getBoolean(arkJs.getObjectProperty(ctx.payload, "isNetwork"));
                std::string type = arkJs.getString(arkJs.getObjectProperty(ctx.payload, "videoType"));
                std::string uri = arkJs.getString(arkJs.getObjectProperty(ctx.payload, "uri"));
                
                react::RNCVideoEventEmitter::OnVideoLoadStart event{isNetwork, type, uri};
                eventEmitter->onVideoLoadStart(event);
                break;
            }
            case RNCVideoEventType::RNC_VIDEO_BUFFER: {
                bool isBuffering = arkJs.getBoolean(arkJs.getObjectProperty(ctx.payload, "isBuffering"));
                
                react::RNCVideoEventEmitter::OnVideoBuffer event{isBuffering};
                eventEmitter->onVideoBuffer(event);
                break;
            }
            case RNCVideoEventType::RNC_VIDEO_ERROR: {
                std::string error = arkJs.getString(arkJs.getObjectProperty(ctx.payload, "error"));
                
                react::RNCVideoEventEmitter::OnVideoError event{ error };
                eventEmitter->onVideoError(event);
                break;
            }
            case RNCVideoEventType::RNC_VIDEO_END: {
                react::RNCVideoEventEmitter::OnVideoEnd event{ };
                eventEmitter->onVideoEnd(event);
                break;
            }
            case RNCVideoEventType::RNC_VIDEO_PROGRESS: {
                float currentTime = (float)arkJs.getDouble(arkJs.getObjectProperty(ctx.payload, "currentTime"));
                float playableDuration = (float)arkJs.getDouble(arkJs.getObjectProperty(ctx.payload, "playableDuration"));
                float seekableDuration = (float)arkJs.getDouble(arkJs.getObjectProperty(ctx.payload, "seekableDuration"));
                
                react::RNCVideoEventEmitter::OnVideoProgress event{ currentTime, playableDuration, seekableDuration };
                eventEmitter->onVideoProgress(event);
                break;
            }
            case RNCVideoEventType::RNC_VIDEO_PLAYBACK_STALLED : {
                react::RNCVideoEventEmitter::OnPlaybackStalled event{};
                LOG(INFO) << "RNCVideoEventEmitRequestHandler OnPlaybackStalled:" ;
                eventEmitter->onPlaybackStalled(event);
                break;
            }
            case RNCVideoEventType::RNC_VIDEO_PLAYBACK_RESUME: {
                react::RNCVideoEventEmitter::OnPlaybackResume event{};
                LOG(INFO) << "RNCVideoEventEmitRequestHandler OnPlaybackResume:" ;
                eventEmitter->onPlaybackResume(event);
                break;
            }
            case RNCVideoEventType::RNC_VIDEO_READY_FOR_DISPLAY: 
            {
                react::RNCVideoEventEmitter::OnReadyForDisplay event{};
                LOG(INFO) << "RNCVideoEventEmitRequestHandler OnReadyForDisplay:" ;
                eventEmitter->onReadyForDisplay(event);
                break;
            }
            default:
                break;
        }
    };
};
} //namespace rnoh