import { PlayConstants } from '../common/constants/PlayConstants';
import { VideoController } from '../controller/VideoController';
import display from '@ohos.display';
import Matrix4 from '@ohos.matrix4'
import media from '@ohos.multimedia.media';
import {
  AvplayerStatus,
  CommonConstants,
  ResizeMode } from '../common/constants/CommonConstants';

let fitMap: Map<string,  ImageFit> = new Map();
fitMap.set('cover',ImageFit.Cover)
fitMap.set('contain',ImageFit.Contain)
fitMap.set('stretch',ImageFit.Fill)
fitMap.set('center',ImageFit.CENTER)

@CustomDialog
export struct OverlayDialogEx {
  @Link videoSrc: string
  @Link videoResizeMode:string
  @State previewUri: string = 'common/videoIcon.png'
  @State durationTime: number = 0
  @State currentTime:number = 0
  lastUpdateTime: number = 0
  private surfaceID: number = 0;
  @Consume videoHeight: number | string;
  @Consume videoWidth: number | string;
  @Consume startTime:number
  @State paused:boolean = false;
  @State isVisibility: Visibility = Visibility.Hidden
  lastActiveTime: number = Date.now(); // 记录用户最后活跃时间的变量
  inactivityTimerId: number | undefined; // 定时器ID
  INACTIVITY_THRESHOLD = 5000
  @Consume @Watch("ModalVisible") isModalVisible:boolean
  public playVideoModel: VideoController | undefined = undefined;
  @State matrix: Matrix4.Matrix4Transit | undefined = Matrix4.identity();
  @Consume @Watch("onChanged") changedViewWidth: number;
  @Consume @Watch("onChanged") changedViewHeight: number;
  @Consume ('currentPlaybackTimeV') @Watch("onCurrentPlaybackTime")  currentPlaybackTime :number;

  @State videoJustifyContent: FlexAlign = FlexAlign.Center;
  @State videoAlignItems: HorizontalAlign = HorizontalAlign.Center;
  controller?: CustomDialogController
  private xComponentController: XComponentController = new XComponentController();

  // 若尝试在CustomDialog中传入多个其他的Controller，以实现在CustomDialog中打开另一个或另一些CustomDialog，那么此处需要将指向自己的controller放在所有controller的后面
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  onCurrentPlaybackTime () {
    this.currentTime = this.currentPlaybackTime;
    if ( this.playVideoModel?.getAvPlayer())
      this.durationTime = this.playVideoModel?.getAvPlayer().duration * 0.001
  }

  getVideoPaused() {
    let avPlayer = this.playVideoModel?.getAvPlayer();
    if(avPlayer) {
      this.paused = avPlayer?.state != AvplayerStatus.PLAYING
    }
  }
  onChanged(propName: string): void {
    console.error('video_test ex onChanged')

    this.playVideoModel?.convertResizeMode(this.videoResizeMode)
    setTimeout(()=>{
      this.getVideoPaused()
    },100)

  }


  aboutToAppear(): void {
    console.error('video_test 弹窗拉起 '+ this.videoResizeMode)
    setTimeout(()=>{
      this.getVideoPaused()
    },100)
  }
  aboutToDisappear(): void {
  }
  setIsVisibility(isShow: boolean) {
    if (isShow) {
      this.isVisibility = Visibility.Visible
    } else {
      this.isVisibility = Visibility.Hidden
    }
  }
  resetInactivityTimer() {
    // 更新最后活跃时间，并清除（如果需要的话）然后重新设置定时器
    this.lastActiveTime = Date.now();
    if (this.inactivityTimerId !== undefined) {
      clearTimeout(this.inactivityTimerId);
    }
    this.inactivityTimerId = setTimeout((): void => this.hideContent(), this.INACTIVITY_THRESHOLD);
  }

  hideContent() {
    // 如果当前时间减去最后活跃时间大于阈值，则隐藏内容
    if (Date.now() - this.lastActiveTime >= this.INACTIVITY_THRESHOLD) {
      this.setIsVisibility(false)

    }
  }
  ModalVisible(propName: string) {
      if(this.isModalVisible == false)
      {
        if (this.controller != undefined) {
          this.cancel()
          this.controller.close()
        }
        this.isModalVisible = true
      }
  }


  build() {
    Column() {
      Stack()
      {
        Column() {
          Column() {
            //xcomponent 添加
            XComponent({
              id: PlayConstants.PLAY_PLAYER.ID,
              type: PlayConstants.PLAY_PLAYER.TYPE,
              libraryname: PlayConstants.PLAY_PLAYER.LIBRARY_NAME,
              controller: this.xComponentController
            })
              .onLoad(async () => {
                // 获取屏幕尺寸并设置XComponent尺寸以适应全屏
                this.surfaceID = Number(this.xComponentController.getXComponentSurfaceId());
                this.playVideoModel?.setSurfaceIdEx(this.surfaceID);
                this.playVideoModel?.convertResizeMode(this.videoResizeMode)
              })
              .width(this.videoWidth)
              .height(this.videoHeight)
              .scale(this.matrix as object)

          }
          .width('100%')
          .height('100%')
          .alignItems(this.videoAlignItems)
          .justifyContent(this.videoJustifyContent);

        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)

        Column() {
          Row() {
          }.height("20%")

          Image(this.paused ? $r('app.media.ic_play') : $r('app.media.ic_pause'))
            .onClick(() => {
              this.paused = !this.paused
              this.playVideoModel?.switchPlayOrPause(this.paused)
            })
            .width(50)
            .height(50)
          Row() {
            Image( this.paused ? $r('app.media.ic_play') : $r('app.media.ic_pause'))
              .onClick(() => {
                this.paused = !this.paused
                this.playVideoModel?.switchPlayOrPause(this.paused)
              })
              .width(20)
              .height(20)

            Text(this.formatSecondsToString(this.currentTime))
              .fontSize('10')
              .fontColor(Color.White)
              .margin({ left: 10 })

            Slider({
              value: this.currentTime,
              min: 0,
              max: this.durationTime
            })
              .onChange((value: number, mode: SliderChangeMode) => {
                //let seekValue: number = value
                //滑块滑动结束后再设置seek
                if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
                  setTimeout(
                    ()=> {this.playVideoModel?.setSeekTime(value)}
                    , 100);
                }
              })
              .width('60%')
              .margin({ left: 5 })

            Text(this.formatSecondsToString(this.durationTime))
              .fontSize('10')
              .fontColor(Color.White)
              .margin({ left: 5 })

          }.width("90%")
          .height("20%")
          .alignItems(VerticalAlign.Center)

        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .visibility(this.isVisibility)

      }
      .onTouch(() => {
          this.setIsVisibility(true)
          this.resetInactivityTimer()
      })
    }
    .backgroundColor('#000000')
    .width('100%')
    .height('105%')

    // 如果需要使用border属性或cornerRadius属性，请和borderRadius属性一起使用。
  }
  formatSecondsToString(totalSeconds: number): string {
    // 计算小时数
    const hours = Math.floor(totalSeconds / 3600);
    // 计算剩余的秒数，用于计算分钟和最终的秒数
    const remainingSeconds = totalSeconds % 3600;
    // 计算分钟数
    const minutes = Math.floor(remainingSeconds / 60);
    // 计算最终的秒数，这里不需要小数部分，所以直接取整
    const seconds = Math.floor(remainingSeconds % 60);
    // 使用字符串模板和字符串插值，结合 padStart 方法来确保每个部分都是两位数
    return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
  }


}