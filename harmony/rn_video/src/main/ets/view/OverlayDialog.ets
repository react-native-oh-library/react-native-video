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
let fitMap: Map<string,  ImageFit> = new Map();
fitMap.set('cover',ImageFit.Cover)
fitMap.set('contain',ImageFit.Contain)
fitMap.set('stretch',ImageFit.Fill)
fitMap.set('center',ImageFit.CENTER)

@CustomDialog
export struct OverlayDialog {
 // @Link textValue: string
  //@State videoSrc: Resource| string = 'https://res.vmallres.com//uomcdn/CN/cms/202210/C75C7E20060F3E909F2998E13C3ABC03.mp4'
  @Link videoSrc: string
  @Link videoResizeMode:string
  @State previewUri: string = 'common/videoIcon.png'
  @State curRate: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X
  @State durationTime: number = 0
  @State currentTime:number = 0
  @Consume startTime:number
  videoController: VideoController = new VideoController()
  @State paused:boolean = false;
  @State isVisibility: Visibility = Visibility.Hidden
  lastActiveTime: number = Date.now(); // 记录用户最后活跃时间的变量
  inactivityTimerId: number | undefined; // 定时器ID
  INACTIVITY_THRESHOLD = 5000
  @Consume @Watch("ModalVisible") isModalVisible:boolean

  controller?: CustomDialogController
  // 若尝试在CustomDialog中传入多个其他的Controller，以实现在CustomDialog中打开另一个或另一些CustomDialog，那么此处需要将指向自己的controller放在所有controller的后面
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }
  aboutToAppear(): void {
    console.info('video_test 弹窗拉起')
  }
  aboutToDisappear(): void {
    this.videoController.stop()
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
      // contentElement.style.backgroundColor = 'gray'; // 或者使用 contentElement.style.display = 'none'; 来完全隐藏
      this.setIsVisibility(false)

    }
  }
  ModalVisible(propName: string) {
      if(this.isModalVisible == false)
      {
        if (this.controller != undefined) {
          this.controller.close()
          this.cancel()
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
            Video({
              src: this.videoSrc,
              previewUri: this.previewUri,
              currentProgressRate: this.curRate,
              controller: this.videoController
            })
              .controls(false)
              .autoPlay(true)
              .objectFit(fitMap.get(this.videoResizeMode)==null ? fitMap.get('contain'):fitMap.get(this.videoResizeMode))
              .onUpdate((event) => {
                if (event) {
                  this.currentTime = event.time
                  this.startTime = this.currentTime

                }
              })
              .onPrepared(
                (event) => {
                  if (event) {
                    this.durationTime = event.duration
                    this.currentTime = this.startTime
                    this.videoController.setCurrentTime(this.startTime, SeekMode.Accurate) // 精准跳转到视频的10s位置
                  }
                }
                )

          }
          .width('100%')
          .height('100%')

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
              if (this.paused == true) {
                this.videoController.pause()
              }else {
                this.videoController.start()
              }
            })
            .width(50)
            .height(50)

          Row() {
            Image( this.paused ? $r('app.media.ic_play') : $r('app.media.ic_pause'))
              .onClick(() => {
                this.paused = !this.paused
                if (this.paused == true) {
                  this.videoController.pause()
                }else {
                  this.videoController.start()
                }
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
                    ()=> {this.videoController.setCurrentTime(value)}
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