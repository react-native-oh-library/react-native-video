import { PiPWindow, typeNode } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../common/util/Logger';
import { VideoController } from '../controller/VideoController';
import { IRNCVideo } from '../RNCVideo';

const TAG = 'PipManager';

interface contentSizeType {
  contentWidth: number;
  contentHeight: number;
}

export interface  PipManagerInitProps {
  navigationId?: string | undefined;
  isInitialAutoStartEnabled?: boolean;
  playVideoModal?: VideoController;
  isInitialStartPip?: boolean;
  contentSize?: contentSizeType;
}

export class PipManager {
  private static instance: PipManager = new PipManager();
  private pipController?: PiPWindow.PiPController = undefined;
  private playPageThis!: IRNCVideo;
  private playVideoModal: VideoController | undefined = undefined;

  public static getInstance(): PipManager {
    return PipManager.instance;
  }

  constructor() {}

  /**
   * 监听画中画控制面板的按钮状态
   * @param control
   */
  onActionEvent(control: PiPWindow.ControlEventParam) {
    switch (control.controlType) {
      case PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE:
        if (control.status === PiPWindow.PiPControlStatus.PAUSE) {
          //停止视频
          this.playVideoModal?.switchPlayOrPause(true);
        } else if (control.status === PiPWindow.PiPControlStatus.PLAY) {
          //播放视频
          this.playVideoModal?.switchPlayOrPause(false);
        }
        break;
      default:
        break;
    }
    Logger.debug('onActionEvent, controlType:' + control.controlType + ', status' + control.status);
  }

  /**
   * 监听画中画生命周期
   * @param state
   * @param reason
   */
  onStateChange(state: PiPWindow.PiPState, reason: string) {
    let curState: string = '';
    switch (state) {
      case PiPWindow.PiPState.ABOUT_TO_START:
        curState = "ABOUT_TO_START";
        break;
      case PiPWindow.PiPState.STARTED:
        curState = "STARTED";
        this.updatePipStatus(true);
        break;
      case PiPWindow.PiPState.ABOUT_TO_STOP:
        curState = "ABOUT_TO_STOP";
        break;
      case PiPWindow.PiPState.STOPPED:
        curState = "STOPPED";
        this.updatePipStatus(false);
        break;
      case PiPWindow.PiPState.ABOUT_TO_RESTORE:
        curState = "ABOUT_TO_RESTORE";
        break;
      case PiPWindow.PiPState.ERROR:
        curState = "ERROR";
        break;
      default:
        break;
    }
    Logger.debug(`[${TAG}] onStateChange: ${curState}, reason: ${reason}`);
  }

  /**
   * 解注册监听
   */
  unregisterPipStateChangeListener() {
    Logger.debug(TAG, 'aboutToDisappear');
    this.pipController?.off('stateChange');
    this.pipController?.off('controlEvent');
  }

  /**
   * 创建画中画控制器，注册生命周期事件以及控制事件回调
   * @param ctx
   * @param componentController
   * @param otherParams
   */
  init(ctx: Context, componentController: XComponentController, otherParams: PipManagerInitProps) {
    if (this.pipController !== null && this.pipController != undefined) {
      return;
    }
    Logger.debug(TAG, 'onPageShow');
    if (!PiPWindow.isPiPEnabled()) {
      Logger.error(TAG, `picture in picture disabled for current OS`);
      return;
    }
    this.playVideoModal = otherParams.playVideoModal;
    let config: PiPWindow.PiPConfiguration = {
      context: ctx,
      componentController: componentController,
      // 1、UIAbility使用Navigation管理页面，需要设置Navigation控件的id属性，并将该id设置给画中画控制器，确保还原场景下能够从画中画窗口恢复到原页面
      // 2、UIAbility只有单页面时，无需设置navigationId，还原场景下也能够从画中画窗口恢复到原页面
      navigationId: otherParams.navigationId || '',
      templateType: PiPWindow.PiPTemplateType.VIDEO_PLAY,
      contentWidth: otherParams.contentSize?.contentWidth || 1920,
      contentHeight: otherParams.contentSize?.contentHeight || 1080,
    };

    // 通过create接口创建画中画控制器实例
    PiPWindow.create(config).then((controller: PiPWindow.PiPController) => {
      this.pipController = controller;
      // 通过画中画控制器实例的setAutoStartEnabled接口设置是否需要在应用返回桌面时自动启动画中画
      this.pipController.setAutoStartEnabled(otherParams.isInitialAutoStartEnabled || false);
      // 通过画中画控制器实例的on('stateChange')接口注册生命周期事件回调
      this.pipController.on('stateChange', (state: PiPWindow.PiPState, reason: string) => {
        this.onStateChange(state, reason);
      });
      // 通过画中画控制器实例的on('controlEvent')接口注册控制事件回调
      this.pipController.on('controlEvent', (control: PiPWindow.ControlEventParam) => {
        this.onActionEvent(control);
      });
      if (otherParams.isInitialStartPip) {
        this.startPip();
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to create pip controller. Cause:${err.code}, message:${err.message}`);
    });
  }

  /**
   * 创建画中画控制器实例后，通过startPiP接口启动画中画
   */
  startPip() {
    this.pipController?.startPiP().then(() => {
      Logger.debug(TAG, `Succeeded in starting pip.`);
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to start pip. Cause:${err.code}, message:${err.message}`);
    });
  }

  /**
   * 关闭画中画
   */
  stopPip() {
    if (this.pipController === null || this.pipController === undefined) {
      return;
    }
    let promise: Promise<void> = this.pipController.stopPiP();
    promise.then(() => {
      Logger.debug(TAG, `Succeeded in stopping pip.`);
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to stop pip. Cause:${err.code}, message:${err.message}`);
    });
  }

  /**
   * 设置是否在应用返回桌面时自动开启画中画
   * @param autoStart
   */
  setAutoStart(autoStart: boolean): void {
    Logger.debug(TAG, `setAutoStart: ${autoStart}`);
    this.pipController?.setAutoStartEnabled(autoStart);
  }

  /**
   * 更新画中画当前状态
   * @param isActive
   */
  updatePipStatus(isActive: boolean): void {
    Logger.debug(TAG, `updatePipStatus, isActive: ${isActive}`);
    this.playPageThis.onPictureInPictureStatusChanged(isActive);
  }

  /**
   * 更新画中画控制面板中的按钮状态
   * @param paused
   */
  updatePipControlStatus(paused: boolean): void {
    Logger.debug(TAG, `updatePipControlStatus, paused: ${paused}`);
    let controlType: PiPWindow.PiPControlType = PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE;
    this.pipController?.updatePiPControlStatus(controlType,
      paused ? PiPWindow.PiPControlStatus.PAUSE : PiPWindow.PiPControlStatus.PLAY);
  }

  initPlayPageThis(playPageThis: IRNCVideo): void {
    this.playPageThis = playPageThis;
  }
}