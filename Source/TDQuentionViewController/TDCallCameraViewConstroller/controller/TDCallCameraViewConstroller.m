//
//  TDCallCameraViewConstroller.m
//  edX
//
//  Created by Elite Edu on 2018/4/25.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDCallCameraViewConstroller.h"
#import "TDCallCameraView.h"
#import "SRUtil.h"

#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "NSString+OEXFormatting.h"

@interface TDCallCameraViewConstroller () <AVCaptureFileOutputRecordingDelegate>//AVCaptureMetadataOutputObjectsDelegate

@property (nonatomic,strong) TDCallCameraView *callCameraView;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIView *playView;

@property (nonatomic,strong) AVCaptureSession *captureSession;  //session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic,strong) AVCaptureDevice *captureDevice;//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property (nonatomic,strong) AVCaptureDeviceInput *videoDeviceInput; //代表输入设备，他使用AVCaptureDevice 来初始化

@property (nonatomic,strong) AVCaptureMovieFileOutput *movieFileOutput;//视频输出
@property (nonatomic,strong) AVCaptureStillImageOutput *imageOutPut; //照片输出

@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer; //图像预览层，实时显示捕获的图像

//@property (nonatomic,strong) AVCaptureMetadataOutput *metadataOutput; //当启动摄像头开始捕获输入

@property (nonatomic,assign) BOOL isflashOn;

@property (nonatomic,assign) CGFloat currentVideoDur;//持续时间
@property (nonatomic,strong) NSURL *currentFileURL;
@property (nonatomic, retain) NSString *videoSaveFilePath;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayerItem *playerItem;

@property (nonatomic,assign) NSInteger cameraType;//1 拍照；2 摄像
@property (nonatomic,assign) BOOL isFinish;//是否操作结束

@property (nonatomic,strong) CAShapeLayer *shapeLayer;
@property (nonatomic,strong) NSTimer *recordTimer;
@property (nonatomic,assign) CGFloat recordTimeNum;

@end

@implementation TDCallCameraViewConstroller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setViewConstraint];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self customCamera];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

#pragma mark - action
- (void)dismissButtonAction:(UIButton *)sender { //返回
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)discarButtonAction:(UIButton *)sender { //重拍
    
    if (self.cameraType == 1) {
        [self.imageView removeFromSuperview];
    
    }
    else if (self.cameraType == 2) {
        [self removeMovFile]; //移除mov视频文件
        [self releaseVideoPlayer];
        [self.playView removeFromSuperview];
        
        [self removeRecordProgress];
    }
    
    [self.callCameraView hideSelectButtonHandle];
    
    [self.captureSession startRunning]; //会话层启动
    
    self.cameraType = 0;
    self.isFinish = NO;
}

- (void)selectButtonAction:(UIButton *)sender {//选择
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.cameraType == 1) { //图片
        if (self.handleCameraImage) {
            self.handleCameraImage(self.imageView.image);
        }
    }
    else {
        
    }
}

- (void)exchangeButtonAction:(UIButton *)sender {//切换前后镜头
    
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    
    if (cameraCount > 1) {
        NSError *error;
        
        CATransition *animation = [CATransition animation];
        animation.duration = .5f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[self.videoDeviceInput device] position];
        
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        
        } else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }
        
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        
        [self.previewLayer addAnimation:animation forKey:nil];
        
        if (newInput != nil) {
            [self.captureSession beginConfiguration];
            [self.captureSession removeInput:self.videoDeviceInput];
            
            if ([self.captureSession canAddInput:newInput]) {
                [self.captureSession addInput:newInput];
                self.videoDeviceInput = newInput;
                
            } else {
                [self.captureSession addInput:self.videoDeviceInput];
            }
            
            [self.captureSession commitConfiguration];
            
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}

- (void)customCamera {
    
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.videoDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.captureDevice error:nil]; //使用设备初始化输入
    self.captureSession = [[AVCaptureSession alloc] init]; //生成会话，用来结合输入输出
//    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];//生成输出对象
    
    [self.captureSession beginConfiguration];
    
    if ([self.captureSession canAddInput:self.videoDeviceInput]) {
        [self.captureSession addInput:self.videoDeviceInput];
    }
    
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil];
    if ([self.captureSession canAddInput:audioDeviceInput]) {
        [self.captureSession addInput:audioDeviceInput];
    }
    
    self.imageOutPut = [[AVCaptureStillImageOutput alloc] init];
    if ([self.captureSession canAddOutput:self.imageOutPut]) {
        [self.captureSession addOutput:self.imageOutPut];
    }
    
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.captureSession canAddOutput:self.movieFileOutput]) {
        [self.captureSession addOutput:self.movieFileOutput];
    }
    
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    
    [self.captureSession commitConfiguration];
    
    //初始化预览层，captureSession负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    self.previewLayer.frame = CGRectMake(0, 0, TDWidth, TDHeight);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.callCameraView.layer insertSublayer:self.previewLayer below:self.callCameraView.exchangeButton.layer];
    
    
    if ([self.captureDevice lockForConfiguration:nil]) {
        if ([self.captureDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [self.captureDevice setFlashMode:AVCaptureFlashModeAuto];
        }
        
        if ([self.captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {//自动白平衡
            [self.captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        
        if ([self.captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [self.captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];//曝光量调节
        }
        [self.captureDevice unlockForConfiguration]; //锁定设备
    }
    
     [self.captureSession startRunning]; //会话层启动
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}

#pragma mark - 拍照
- (void)tapAction:(UITapGestureRecognizer *)tap {
    
    
    AVCaptureConnection * videoConnection = [self.imageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    self.cameraType = 1;
    self.callCameraView.dismissButton.hidden = YES;
    
    [self.imageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        
        [self.captureSession stopRunning]; //会话层关闭
        
        [self saveImageToPhotoAlbum:image]; //保存图片
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.previewLayer.frame];
        self.imageView.image = image;
        [self.callCameraView insertSubview:self.imageView belowSubview:self.callCameraView.cameraImageView];
        
        [self finishDealWithButtonStatus:1];
        
        NSLog(@"相片大小size = %@",NSStringFromCGSize(image.size));
    }];
}

- (void)finishDealWithButtonStatus:(NSInteger)type { //1 拍照；2 摄像
    
    self.isFinish = YES;
    
    self.cameraType = type;
    [self.callCameraView showSelectButtonHandle];
    
}

#pragma mark - 闪光灯
- (void)FlashOn {
    
    if ([self.captureDevice lockForConfiguration:nil]) {
        
        if (self.isflashOn) {
            if ([self.captureDevice isFlashModeSupported:AVCaptureFlashModeOff]) {
                [self.captureDevice setFlashMode:AVCaptureFlashModeOff];
                self.isflashOn = NO;
//                [_flashButton setTitle:@"闪光灯关" forState:UIControlStateNormal];
            }
        } else {
            if ([self.captureDevice isFlashModeSupported:AVCaptureFlashModeOn]) {
                [self.captureDevice setFlashMode:AVCaptureFlashModeOn];
                self.isflashOn = YES;
//                [_flashButton setTitle:@"闪光灯开" forState:UIControlStateNormal];
            }
        }
        
        [self.captureDevice unlockForConfiguration];
    }
}

#pragma mark - 焦点
- (void)focusGesture:(UITapGestureRecognizer *)gesture {
    
    if (self.isFinish) { //已操作结束
        return;
    }
    
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}

- (void)focusAtPoint:(CGPoint)point {
    
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    
    if ([self.captureDevice lockForConfiguration:&error]) {
        
        if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) { //焦点
            [self.captureDevice setFocusPointOfInterest:focusPoint];
            [self.captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.captureDevice setExposurePointOfInterest:focusPoint];
            [self.captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        [self.captureDevice unlockForConfiguration]; //锁定设备
        
        self.callCameraView.focusView.center = point;
        self.callCameraView.focusView.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.callCameraView.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                self.callCameraView.focusView.transform = CGAffineTransformIdentity;
            
            } completion:^(BOOL finished) {
                self.callCameraView.focusView.hidden = YES;
            }];
        }];
    }
}

#pragma - 保存至相册
- (void)saveImageToPhotoAlbum:(UIImage *)savedImage {
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    } else {
        msg = @"保存图片成功" ;
    }
    [self.view makeToast:msg duration:0.8 position:CSToastPositionCenter];
}

#pragma mark - 视频录制
- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        self.cameraType = 2;
        self.callCameraView.dismissButton.hidden = YES;
        self.callCameraView.exchangeButton.hidden = YES;
        
        [self addProgressShapeLayer];
        
        NSURL *recordUrl = [NSURL fileURLWithPath:[self getVideoSaveFilePathString]];
        AVCaptureConnection *captureConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if (![self.movieFileOutput isRecording]) {
            captureConnection.videoOrientation = [self.previewLayer connection].videoOrientation;//预览图层和视频方向保持一致
            [self.movieFileOutput startRecordingToOutputFileURL:recordUrl recordingDelegate:self];
        }
        else {
            [self stopRecordVideo]; //停止录制
        }
    }
    else if (longPress.state == UIGestureRecognizerStateChanged) {
        
    }
    else if (longPress.state == UIGestureRecognizerStateEnded) {
        [self stopRecordVideo]; //停止录制
    }
}

- (void)stopRecordVideo {
    
    self.recordTimeNum = 0;
    [self.movieFileOutput stopRecording]; //停止录制
    
    [self.recordTimer invalidate];
    self.recordTimer = nil;
}

- (void)addProgressShapeLayer { //动画
    [self.callCameraView updateCameraButtonConstraint:NO];
    
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(animationTimerAction) userInfo:nil repeats:YES];
}

- (void)animationTimerAction {
    
    self.recordTimeNum += 0.1;
    if (self.recordTimeNum >= 60) {
        
        [self stopRecordVideo]; //停止录制
        [self showRecordProgress:1];
    }
    else {
        [self showRecordProgress:self.recordTimeNum / 60];
    }
}

- (void)showRecordProgress:(CGFloat)progress {
    
    NSLog(@"进度 -- %lf",progress);
    
    if (self.shapeLayer) {
        [self.shapeLayer removeFromSuperlayer];
    }
    
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.frame = self.callCameraView.cameraImageView.bounds;
    self.shapeLayer.lineCap = kCALineCapRound;
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.shapeLayer.strokeColor = [UIColor colorWithHexString:colorHexStr1].CGColor;
    self.shapeLayer.lineWidth = 4.0f;

    CGPoint point = CGPointMake(41, 41);
    CGFloat radius = 39.0;
    CGFloat startA = -M_PI_2;  //设置进度条起点位置
    CGFloat endA = -M_PI_2 + M_PI * 2 * progress;  //设置进度条终点位置
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:radius startAngle:startA endAngle:endA clockwise:YES];
    
    self.shapeLayer.path = path.CGPath;
    
    [self.callCameraView.cameraImageView.layer addSublayer:self.shapeLayer];
}

- (void)removeRecordProgress {
    
    [self.callCameraView updateCameraButtonConstraint:YES];
    
    if (self.shapeLayer) {
        [self.shapeLayer removeFromSuperlayer];
    }
}

- (void)releaseCaptureData {
    
    if (self.captureSession) {
        [self.captureSession stopRunning];
        self.captureSession = nil;
    }
    if (self.movieFileOutput) {
        self.movieFileOutput = nil;
    }
    if (self.videoDeviceInput) {
        self.videoDeviceInput = nil;
    }
    if (self.previewLayer) {
        [self.previewLayer removeFromSuperlayer];
        self.previewLayer = nil;
    }
    self.currentFileURL = nil;
}

//AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    
    self.videoSaveFilePath = [fileURL absoluteString];
    self.currentFileURL = fileURL;
    
    NSLog(@"录制开始 -- %@",[fileURL absoluteString]);
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {

    [self mergeAndExportVideoAtFileURLs:[NSArray arrayWithObjects:outputFileURL, nil]];
    NSLog(@"录制结束 -- %@",outputFileURL.absoluteString);
    
//    //保存视频到相册
//    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
//    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:nil];
//
//    [self.view makeToast:@"视频保存成功" duration:0.8 position:CSToastPositionCenter];
}

//合成并导出视频
- (void)mergeAndExportVideoAtFileURLs:(NSArray *)fileURLArray {
    
    [SVProgressHUD showWithStatus:@"正在转码..."];
    SVProgressHUD.defaultMaskType = SVProgressHUDMaskTypeBlack;
    SVProgressHUD.defaultStyle = SVProgressHUDAnimationTypeNative;
    
    NSError *error = nil;
    CGSize renderSize = CGSizeMake(0, 0);//渲染尺寸
    
    NSMutableArray *layerInstructionArray = [NSMutableArray array];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];//用来合成视频
    CMTime totalDuration = kCMTimeZero;
    
    //先取assetTrack 也为了取renderSize
    NSMutableArray *assetTrackArray = [NSMutableArray array];
    NSMutableArray *assetArray = [NSMutableArray array];
    
    for (NSURL *fileURL in fileURLArray) {
        
        AVAsset *asset = [AVAsset assetWithURL:fileURL];//AVAsset：素材库里的素材
        
        if (!asset) {
            continue;
        }
        
        [assetArray addObject:asset];
        
        //素材的轨道
        NSArray *assetArray = [asset tracksWithMediaType:AVMediaTypeVideo];
        if (assetArray.count == 0) {
            continue;
        }
        AVAssetTrack *assetTrack = [assetArray objectAtIndex:0]; //返回一个数组AVAssetTracks资产
        [assetTrackArray addObject:assetTrack];
        
        renderSize.width = MAX(renderSize.width, assetTrack.naturalSize.height);
        renderSize.height = MAX(renderSize.height, assetTrack.naturalSize.width);
    }
    
    CGFloat renderW = TDWidth;
    
    for (NSInteger i = 0; i < [assetArray count] && i < assetTrackArray.count; i++) {
        
        AVAsset *asset = [assetArray objectAtIndex:i];
        AVAssetTrack *assetTrack = [assetTrackArray objectAtIndex:i];
        
        //文件中的音频轨道，里面可以插入各种对应的素材
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        NSArray*dataSourceArray= [asset tracksWithMediaType:AVMediaTypeAudio];//获取声道，即麦克风相关信息
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:((dataSourceArray.count > 0)?[dataSourceArray objectAtIndex:0]:nil) atTime:totalDuration error:nil];
        
        //工程文件中的轨道，有音频轨，里面可以插入各种对应的素材
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack atTime:totalDuration error:&error];
        
        //视频轨道中的一个视频，可以缩放、旋转等
        AVMutableVideoCompositionLayerInstruction *layerInstrucition = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
        
        CGFloat rate = renderW / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
        
        CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
//        layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0));//向上移动取中部影相
        layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, 0)); //向上移动取中部影相
        layerTransform = CGAffineTransformScale(layerTransform, rate, rate); //放缩，解决前后摄像结果大小不对称
        
        [layerInstrucition setTransform:layerTransform atTime:kCMTimeZero];
        [layerInstrucition setOpacity:0.0 atTime:totalDuration];
        
        [layerInstructionArray addObject:layerInstrucition];//data
    }

    
    //export
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    mainInstruction.layerInstructions = layerInstructionArray;
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 100);
    mainCompositionInst.renderSize = CGSizeMake(renderW, TDHeight);
    
    NSURL *mergeFileURL = [NSURL fileURLWithPath:[self pathMp4VideoFile]];
    //资源导出
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.videoComposition = mainCompositionInst;
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4; //视频格式MP4
    exporter.shouldOptimizeForNetworkUse = YES;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        [SVProgressHUD dismiss];
        
         if ([exporter status] == AVAssetExportSessionStatusCompleted) {
             NSLog(@"----- 转码成功");
         }
         else if ([exporter status] == AVAssetExportSessionStatusWaiting) {
             NSLog(@"----- 正在转码");
         }
         else if ([exporter status] == AVAssetExportSessionStatusFailed) {
             NSLog(@"----- 转码失败；失败信息---- %@",exporter.error);
         }
         else {
              NSLog(@"----- 000 %ld",(long)[exporter status]);
         }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self playVideoWithPath:[mergeFileURL absoluteString]]; //播放MP4文件
            [self removeMovFile]; //移除mov文件
            [self finishDealWithButtonStatus:2];
            
            NSInteger kb = [self getFileSize:[mergeFileURL absoluteString]];
            NSLog(@"mp4 视频大小 == > %ld kb",(long)kb);
            NSLog(@"mp4转换结束 %@",mergeFileURL);
            //            NSLog(@"本段视频的时间: %f", _currentVideoDur);
        });
    }];
}

//移除 mov 格式的视频文件
- (void)removeMovFile {
    
    if (self.videoSaveFilePath) {
        
        NSString *path = self.videoSaveFilePath;
        path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            
            NSInteger kb = [self getFileSize:path];
            NSLog(@"mov 视频大小 -- %ld kb",(long)kb);
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError *error;
                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                if (error) {
                    NSLog(@"mov file remove error: %@",error);
                }
            });
        }
    } else {
        NSLog(@"不存在 -- Mov");
    }
}

- (NSString *)pathMp4VideoFile {//最后合成为 mp4
    
    NSString *nowTimeStr = [NSString stringWithFormat:@"%lld",[SRUtil getNowTimeStamp]];
    NSString *videoName = [NSString stringWithFormat:@"%@.mp4",nowTimeStr];
    NSString *path = [SRUtil getVideoCachePath:videoName];
    
    NSLog(@"mp4 存储位置拼接 -- %@",path);
    
    return path;
}

- (NSString *)getVideoSaveFilePathString {//录制保存的时候要保存为 mov
    
    NSString *nowTimeStr = [NSString stringWithFormat:@"%lld",[SRUtil getNowTimeStamp]];
    NSString *videoName = [NSString stringWithFormat:@"%@.mov",nowTimeStr];
    
    NSString *path = [SRUtil getVideoCachePath:videoName];
    
    NSLog(@"wov 存储位置拼接 -- %@",path);
    
    return path;
}

- (NSInteger)getFileSize:(NSString *)path {

    path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];

    NSFileManager *filemanager = [NSFileManager defaultManager];

    if([filemanager fileExistsAtPath:path]){

        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;

        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue]/1024;
        else
            return -1;
    } else {
        return -1;
    }
}

#pragma mark - 播放视频
- (void)playVideoWithPath:(NSString *)pathStr {
    
    pathStr = [pathStr stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathStr]) {
        return;
    }
    
    self.playView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDHeight)];
    self.playView.backgroundColor = [UIColor blackColor];
    [self.callCameraView insertSubview:self.playView belowSubview:self.callCameraView.cameraImageView];
    
    [self registerNotficationMessage];
    
    AVAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:pathStr] options:nil];
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];

    self.player = [[AVPlayer alloc] init];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    [self.player seekToTime:kCMTimeZero];
    [self.player setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    
    self.playerLayer.frame = self.playView.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.playView.layer addSublayer:self.playerLayer];
    
    [self playRecordVideo];
}

- (void)playRecordVideo {
    
    [self.playerItem seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)pauseRecordVideo {
    
    [self.playerItem seekToTime:kCMTimeZero];
    [self.player pause];
}

- (void)releaseVideoPlayer {
    
    [self removeNotificationMessage];

    if (self.player) {
        [self.player pause];
    }
    
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
    }
    
    if (self.playView) {
        [self.playView removeFromSuperview];
    }
    
    self.player = nil;
    self.playerLayer = nil;
    self.playerItem = nil;
    self.playView = nil;
}

- (void)registerNotficationMessage { //播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)removeNotificationMessage { //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)avPlayerItemDidPlayToEnd:(NSNotification *)notification { //播放结束自动从头播放
    if (notification.object != self.playerItem) {
        return;
    }
    
    [self.playerItem seekToTime:kCMTimeZero];
    [self.player play];
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.callCameraView = [[TDCallCameraView alloc] init];
    [self.view addSubview:self.callCameraView];
    
    [self.callCameraView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.callCameraView.dismissButton addTarget:self action:@selector(dismissButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.callCameraView.discarButton addTarget:self action:@selector(discarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.callCameraView.selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.callCameraView.exchangeButton addTarget:self action:@selector(exchangeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.callCameraView.cameraImageView addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.callCameraView.cameraImageView addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}

#pragma mark - 隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

