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

// type SelectedVideoTrack = Readonly<{
//   type?: WithDefault<'auto' | 'disabled' | 'resolution' | 'index', 'auto'>
//   value?: Int32;
// }>

// @todo: fix type. for now react native doesn't support array codegen type for native event

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

// @todo: fix type. for now react native doesn't support array codegen type for native event

export const Commands = codegenNativeCommands({
  supportedCommands: [
  // 'src',
  'save', 'seek'
  // 'fullscreen',
  ]
});
export default codegenNativeComponent('RNCVideo');
//# sourceMappingURL=VideoNativeComponent.js.map