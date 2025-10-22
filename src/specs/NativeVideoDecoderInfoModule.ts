import { TurboModuleRegistry, TurboModule } from 'react-native';
import type {Int32} from 'react-native/Libraries/Types/CodegenTypes';

// @TODO rename to "Spec" when applying new arch
export interface Spec extends TurboModule {
  getWidevineLevel: () => Promise<Int32>;
  isCodecSupported: (
    mimeType: string,
    width: Int32,
    height: Int32,
  ) => Promise<'unsupported' | 'hardware' | 'software'>;
  isHEVCSupported: () => Promise<'unsupported' | 'hardware' | 'software'>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('VideoDecoderInfoModule');