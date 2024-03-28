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
#include "RNCVideoComponentDescriptor.h"
#include "RNCVideoViewJSIBinder.h"
#include "RNCVideoViewNapiBinder.h"
#include "RNCVideoEventEmitRequestHandler.h"
#include "RNOH/ArkTSComponentInstance.h"

using namespace rnoh;
using namespace facebook;

class RNCVideoComponentInstanceFactoryDelegate : public ComponentInstanceFactoryDelegate {
public:
    using ComponentInstanceFactoryDelegate::ComponentInstanceFactoryDelegate;

    ComponentInstance::Shared create(ComponentInstance::Context ctx) override {
        if (ctx.componentName == "RNCVideo") {
            return std::make_shared<ArkTSComponentInstance>(ctx);
        }
        return nullptr;
    }
};

namespace rnoh {

class RNCVideoPackage : public Package {
public:
    RNCVideoPackage(Package::Context ctx) : Package(ctx) {}

    ComponentInstanceFactoryDelegate::Shared createComponentInstanceFactoryDelegate() override {
            return std::make_shared<RNCVideoComponentInstanceFactoryDelegate>(m_ctx);
    }

    std::vector<facebook::react::ComponentDescriptorProvider> createComponentDescriptorProviders() override 
    {
        return {
            facebook::react::concreteComponentDescriptorProvider<facebook::react::RNCVideoComponentDescriptor>(),
        };
    }

    ComponentJSIBinderByString createComponentJSIBinderByName() override 
    {
        return {{"RNCVideo", std::make_shared<RNCVideoViewJSIBinder>()}};
    };

    ComponentNapiBinderByString createComponentNapiBinderByName() override
    {
        return {{"RNCVideo", std::make_shared<RNCVideoViewNapiBinder>()}};
    };

    EventEmitRequestHandlers createEventEmitRequestHandlers() override
    {
        return {std::make_shared<RNCVideoEventEmitRequestHandler>()};
    }
};
} // namespace rnoh

