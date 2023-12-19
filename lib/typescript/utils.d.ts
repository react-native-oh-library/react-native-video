import type { ImageSourcePropType } from 'react-native';
import type { ReactVideoSource } from './types/video';
type Source = ImageSourcePropType | ReactVideoSource;
export declare function generateHeaderForNative(obj?: Record<string, any>): {
    key: string;
    value: any;
}[];
export declare function resolveAssetSourceForVideo(source: Source): ReactVideoSource;
export declare function isFabric(): boolean;
export {};
//# sourceMappingURL=utils.d.ts.map