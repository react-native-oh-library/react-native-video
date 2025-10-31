import { RNPackageContext, RNPackage } from '@rnoh/react-native-openharmony/ts';
import { RNCVideoPackage } from '@react-native-oh-tpl/react-native-video/ts';

export function createRNPackages(ctx: RNPackageContext): RNPackage[] {
  return [
    new RNCVideoPackage(ctx)
  ];
}