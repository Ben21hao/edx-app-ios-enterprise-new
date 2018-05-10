//
//  TDQuetionInputViewController.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDQuetionInputViewController.h"

#import "TDRecordView.h"
#import "TDQuetionInputView.h"

#import <AVFoundation/AVFoundation.h>
#import "lame.h"

#import "TDImageGroupViewController.h"
#import "TDPreViewImageViewController.h"

#import "NSString+OEXFormatting.h"

#define Limite_Record_Time 60

@interface TDQuetionInputViewController () <AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property (nonatomic,strong) TDRecordView *recordView;
@property (nonatomic,strong) TDQuetionInputView *inputView;

@property (nonatomic,strong) AVAudioRecorder *audioRecorder; //录音
@property (nonatomic,strong) AVAudioSession *audioSession;
@property (nonatomic,strong) NSString *recordUrl;//存储路径
@property (nonatomic,strong) NSString *mp3FilePath;//mp3路径

@property (nonatomic,strong) NSTimer *recordTimer;
@property (nonatomic,strong) NSTimer *recordCountTimer;
@property (nonatomic,assign) NSInteger recordTimeNum;
@property (nonatomic,assign) int mp3TimeNum;
@property (nonatomic,assign) BOOL isSwipe;

@property (nonatomic,strong) AVAudioPlayer *avPlayer;
@property (nonatomic,strong) NSTimer *playTimer;
@property (nonatomic,assign) NSInteger playImageNum;
@property (nonatomic,assign) BOOL isOverTime;

@property (nonatomic,strong) NSString *recordKeyStr; //录音的唯一标识

@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic,assign) BOOL isHanding;

@property (nonatomic,strong) TDBaseToolModel *baseTool;


@end

@implementation TDQuetionInputViewController

- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc] init];
    }
    return _imageArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = self.titleStr;

    self.rightButton.hidden = NO;
    [self.rightButton setTitle:TDLocalizeSelect(@"SUBMIT", nil) forState:UIControlStateNormal];
    
    self.baseTool = [[TDBaseToolModel alloc] init];
    [self setViewConstraint];
    
    self.mp3TimeNum = 0;
    self.recordKeyStr = @"selfRecord";
    self.isHanding = NO;
    [self initAvAudio];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageSelectNoti:) name:@"User_Had_SelectImage" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopRecord];
    [SVProgressHUD dismiss];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)deleteVoiceFile { //删除保存在本地的录音文件，防止占用手机存储空间
    
    if ([self.avPlayer isPlaying]) {
        [self.avPlayer stop];
    }
    [self.audioRecorder deleteRecording];
    
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileUrl = [NSString stringWithFormat:@"%@/%@.mp3",strUrl,self.recordKeyStr];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fileUrl error:nil];
}

- (void)leftButtonAction:(UIButton *)sender {
    
    if (self.audioRecorder.isRecording) { //正在录音，请先结束录音
        [self.view makeToast:TDLocalizeSelect(@"RECORDING_LEAVE_FINISH", nil) duration:0.8 position:CSToastPositionCenter];
        return;
    }
    
    if (self.isHanding) {
        self.isHanding = NO;
        [self.view makeToast:TDLocalizeSelect(@"SUMITTING_SURE_LEAVE", nil) duration:0.8 position:CSToastPositionCenter];
        return;
    }
    
    [self popAndDeleteFile];
}


- (void)rightButtonAciton:(UIButton *)sender { //提交
    
    [self.inputView.quetionTextView resignFirstResponder];
    
    if (self.isHanding) {
        return;
    }
    
    if (self.whereFrom == TDQuetionInputFromNewQuetion) {
        
        [self.inputView.titleTextView resignFirstResponder];
        
        [self postQuetionContentHandin];
        
    } else {
        
        [self replyQuetionHandin];
    }
}

- (BOOL)judgeHadContent:(NSString *)voiceStr { //判断 文字，图片，语音 三者必有一

    BOOL hasContent = NO;
    if (self.imageArray.count > 0) {
        hasContent = YES;
    }
    
    if (self.inputView.quetionTextView.text.length > 0) {
        hasContent = YES;
    }
    
    if (voiceStr.length > 0) {
        hasContent = YES;
    }
    
    return hasContent;
}

- (NSString *)base64Code:(UIImage *)image { //图片base64
    
    //    NSData *faceData = UIImagePNGRepresentation(image);
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    NSString *imageStr = [imageData base64EncodedStringWithOptions:0];
    return imageStr;
}

- (NSMutableString *)dealWithImageStr {
    
    NSString *headerStr = @"data:image/jpeg;base64,";
    NSMutableString *pictureStr = [[NSMutableString alloc] init];
    
    for (int i = 0; i < self.imageArray.count; i ++) {
        TDSelectImageModel *model = self.imageArray[i];
        NSString *imageStr = [NSString stringWithFormat:@"%@%@",headerStr,[self base64Code:model.image]];
        [pictureStr appendString:i == self.imageArray.count - 1 ? imageStr : [NSString stringWithFormat:@"%@~",imageStr]];
    }
    return pictureStr;
}

- (NSString *)mp3ToBASE64 { //录音上传需要转码BASE64
    
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSData *mp3Data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.mp3",strUrl,self.recordKeyStr]];
    
    NSString *encodedImageStr = [mp3Data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSLog(@"64位编码 ------->>> %@", encodedImageStr);
    return encodedImageStr;
}

#pragma mark - 接口
- (void)postQuetionContentHandin {//新增咨询
    
    if (![self.baseTool networkingState]) {//网络监测
        return;
    }
    
    if (self.inputView.titleTextView.text.length == 0) {
        [self.view makeToast:TDLocalizeSelect(@"ENTER_TITLE_TEXT", nil) duration:0.8 position:CSToastPositionCenter];
        return;
    }
    
    NSString *pictureStr = self.imageArray.count > 0 ? [self dealWithImageStr] : @"";
    NSString *voiceStr = [self mp3ToBASE64];
    
    if (![self judgeHadContent:voiceStr]) {
        [self.view makeToast:TDLocalizeSelect(@"THREE_MUST_ONRE", nil) duration:0.8 position:CSToastPositionCenter];
        return;
    }
    
    if (self.avPlayer.playing) {
        [self.avPlayer stop];
        [self stopPlayMp3Constraint];
    }
    
    [SVProgressHUD showWithStatus:TDLocalizeSelect(@"SUBMITTING_TEXT", nil)];
    SVProgressHUD.defaultMaskType = SVProgressHUDMaskTypeBlack;
    SVProgressHUD.defaultStyle = SVProgressHUDAnimationTypeNative;
    
    self.isHanding = YES;
    self.view.userInteractionEnabled = NO;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:self.username forKey:@"username"];
    
    [params setValue:self.inputView.titleTextView.text forKey:@"title"];
    [params setValue:self.inputView.quetionTextView.text forKey:@"content"];
    [params setValue:pictureStr forKey:@"pictures"];
    
    if (voiceStr.length > 0) {
        [params setValue:[NSString stringWithFormat:@"data:audio/mp3;base64,%@",voiceStr] forKey:@"voice"];//base64编码
        [params setValue:[NSString stringWithFormat:@"%d",self.mp3TimeNum] forKey:@"voice_duration"];
        
        NSLog(@"录音时间 --->> %d",self.mp3TimeNum);
    }
 
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/add_consult_message/",ELITEU_URL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//        NSLog(@"提交---->>> %@ -- %@",responseObject,responseObject[@"msg"]);
        [SVProgressHUD dismiss];
        self.isHanding = NO;
        self.view.userInteractionEnabled = YES;
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        int code = [responseDic[@"code"] intValue];
        
        if (code == 200) {
            [self.view makeToast:TDLocalizeSelect(@"HANDIN_SUCCESS", nil) duration:0.8 position:CSToastPositionCenter];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"new_quetion_handin_notification" object:nil];
            
            [self popAndDeleteFile];
    
        } else if (code == 311) { //学员未关联组织
         [self.view makeToast:TDLocalizeSelect(@"STUDENT_NO_LINKE_ORGANIZATION", nil) duration:0.8 position:CSToastPositionCenter];
            
        } else if (code == 312) { //学员不存在
            [self.view makeToast:TDLocalizeSelect(@"NOT_FOUND_STUDENT", nil) duration:0.8 position:CSToastPositionCenter];
        }
//        else if (code == 313) { //音频保存失败
//
//        } else if (code == 314) { //图片保存失败
//            
//        }
        else {
            [self.view makeToast:TDLocalizeSelect(@"FALILED_SUBMIT", nil) duration:0.8 position:CSToastPositionCenter];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"新咨询---->>> %@",error);
        [SVProgressHUD dismiss];
        self.isHanding = NO;
        self.view.userInteractionEnabled = YES;
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
    }];
}

- (void)replyQuetionHandin { //回复、继续咨询
    
    if (![self.baseTool networkingState]) {//网络监测
        return;
    }
    
    NSString *pictureStr = [self dealWithImageStr];
    NSString *voiceStr = [self mp3ToBASE64];
    
    if (![self judgeHadContent:voiceStr]) {
        [self.view makeToast:TDLocalizeSelect(@"THREE_MUST_ONRE", nil) duration:0.8 position:CSToastPositionCenter];
        return;
    }
    
    if (self.avPlayer.playing) {
        [self.avPlayer stop];
        [self stopPlayMp3Constraint];
    }
    
    [SVProgressHUD showWithStatus:TDLocalizeSelect(@"SUBMITTING_TEXT", nil)];
    SVProgressHUD.defaultMaskType = SVProgressHUDMaskTypeBlack;
    SVProgressHUD.defaultStyle = SVProgressHUDAnimationTypeNative;
    
    self.isHanding = YES;
    self.view.userInteractionEnabled = NO;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:self.username forKey:@"username"];
    
    [params setValue:self.consult_id forKey:@"consult_id"];
    [params setValue:self.inputView.quetionTextView.text forKey:@"content"];
    [params setValue:pictureStr forKey:@"pictures"];
    
    if (voiceStr.length > 0) {
        [params setValue:[NSString stringWithFormat:@"data:audio/mp3;base64,%@",voiceStr] forKey:@"voice"];//base64编码
        [params setValue:[NSString stringWithFormat:@"%d",self.mp3TimeNum] forKey:@"voice_duration"];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/reply_consult_message/",ELITEU_URL];
    WS(weakSelf);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"咨询回复 ---->>> %@ -- %@",responseObject,responseObject[@"msg"]);
        [SVProgressHUD dismiss];
        self.isHanding = NO;
        self.view.userInteractionEnabled = YES;
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        int code = [responseDic[@"code"] intValue];
        if (code == 200) {
            
            if (weakSelf.replyHandle) {
                weakSelf.replyHandle();
            }
            
            [self.view makeToast:TDLocalizeSelect(@"HANDIN_SUCCESS", nil) duration:0.8 position:CSToastPositionCenter];
            [self popAndDeleteFile];
            
        } else if (code == 311) { //学员未关联企业
          [self.view makeToast:TDLocalizeSelect(@"STUDENT_NO_LINKE_ORGANIZATION", nil) duration:0.8 position:CSToastPositionCenter];
        } else if (code == 312) { //学员不存在
            [self.view makeToast:TDLocalizeSelect(@"NOT_FOUND_STUDENT", nil) duration:0.8 position:CSToastPositionCenter];
        }
//        else if (code == 313) { //音频保存失败
//
//        } else if (code == 314) { //图片保存失败
//            
//        } else if (code == 315) { //咨询id不存在
//            
//        }
        else if (code == 316) { //咨询不存在
            [self.view makeToast:TDLocalizeSelect(@"NO_FOUND_CONSULTATION", nil) duration:0.8 position:CSToastPositionCenter];
        } else if (code == 317) { //无权提交回复
            [self.view makeToast:TDLocalizeSelect(@"NO_REPLY_PERMISSION", nil) duration:0.8 position:CSToastPositionCenter];
            
        } else {
            [self.view makeToast:TDLocalizeSelect(@"FALILED_SUBMIT", nil) duration:0.8 position:CSToastPositionCenter];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"咨询回复---->>> %@",error);
        [SVProgressHUD dismiss];
        self.isHanding = NO;
        self.view.userInteractionEnabled = YES;
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
    }];
}

- (void)popAndDeleteFile {
    
    [self deleteVoiceFile];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark - 录音
- (void)initAvAudio { //初始化
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    //设置录音格式 AVFormatIDKey==kAudioFormatLinearPCM 全称脉冲编码调制，是一种模拟信号的数字化的方法。
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）, 采样率必须要设为11025才能使转化成mp3格式后不会失真
    [recordSetting setValue:[NSNumber numberWithFloat:11025.0] forKey:AVSampleRateKey];
    //录音通道数  1 或 2 ，要转换成mp3格式必须为双通道
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInteger:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    //存储录音文件
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.recordUrl = [NSString stringWithFormat:@"%@/%@.lpcm",strUrl,self.recordKeyStr];
    
    //初始化录音控制器
    NSError *error;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:self.recordUrl] settings:recordSetting error:&error];
    //开启音量检测
    self.audioRecorder.meteringEnabled = YES;
    self.audioRecorder.delegate = self;
    
    self.audioSession = [AVAudioSession sharedInstance];//得到AVAudioSession单例对象
    //设置类别,表示该应用同时支持播放和录音
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
//    self.recordTimeNum = 0;
    self.isOverTime = NO;
    
    [self deleteFile];
}


- (void)startRecord { //开始录音
    
    //设置类别,表示该应用同时支持播放和录音
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [self deleteFile];
    
    if (![self.audioRecorder isRecording]) {
        
        [self.audioSession setActive:YES error:nil]; //启动音频会话管理,此时会阻断后台音乐的播放.
        
        [self.audioRecorder prepareToRecord];
        [self.audioRecorder peakPowerForChannel:0.0];
        [self.audioRecorder record];
    }
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    self.recordCountTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordCountAction) userInfo:nil repeats:YES];
}

- (void)cancelRecord { //取消录音
    
    [self inalidateTimer];
    
    [self.audioRecorder deleteRecording]; //删除录音文件
    [self stopRecord];
}

- (void)inalidateTimer { //取消
    [self.recordTimer invalidate];
    [self.recordCountTimer invalidate];
    
//    self.recordTimeNum = 0;
}

- (void)stopRecord { //录音停止
    [self.audioRecorder stop];
    [self.audioSession setActive:NO error:nil]; //一定要在录音停止以后再关闭音频会话管理（否则会报错），此时会延续后台音乐播放
}

- (void)recordFinish { //结束录音
    
    [self inalidateTimer];
    
    self.mp3TimeNum = self.audioRecorder.currentTime > Limite_Record_Time ? Limite_Record_Time : ceil(self.audioRecorder.currentTime);
    NSLog(@"录音时间 --->> %d",self.mp3TimeNum);
    
    if (self.mp3TimeNum > 2) { //如果录制时间<2不发送
        [NSThread detachNewThreadSelector:@selector(transformVAFToMP3) toTarget:self withObject:nil];
        [self updateAvButtonConstraint];
        [self updateRecordButton:TDLocalizeSelect(@"MAX_ONE_RECORD", nil) imageStr:@"record_not_image" enable:NO];
        
    } else {
        [self.audioRecorder deleteRecording];
        [self updateRecordButton:TDLocalizeSelect(@"HOLD_TO_RECORD", nil) imageStr:@"record_not_image" enable:YES];
        [self.view makeToast:TDLocalizeSelect(@"ENCH_RECOR_LESS_TWO_SECOND", nil) duration:0.8 position:CSToastPositionCenter];
    }
    
    [self stopRecord];
}

- (void)deleteRecordAuadio { //删除录音文件
    
    if (self.avPlayer.playing) {
        [self.avPlayer stop];
        [self stopPlayMp3Constraint];
    }
    
    [self.audioRecorder deleteRecording];
}

- (void)deleteFile { //删除已保存的语音
    
    [self deleteRecordAuadio];
    
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileUrl = [NSString stringWithFormat:@"%@/%@.mp3",strUrl,self.recordKeyStr];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fileUrl error:nil];
    
    self.recordUrl = [NSString stringWithFormat:@"%@/%@.lpcm",strUrl,self.recordKeyStr];
}

- (void)detectionVoice { //音量大小
    
    if (self.isSwipe) {
        return;
    }
    
    [self.audioRecorder updateMeters]; //刷新音量数据
    
//    [self.audioRecorder averagePowerForChannel:0]; //获取音量的平均值
//    [self.audioRecorder peakPowerForChannel:0]; //音量的最大值
    
    double lowPassResults = pow(10, ([self.audioRecorder peakPowerForChannel:0] * 0.05));
//    NSLog(@"音量最大值----->>>%lf",lowPassResults);
    if (lowPassResults < 0) {
        self.recordView.imageView.image = [UIImage imageNamed:@"record_voice_zero"];
    } else if (0 < lowPassResults && lowPassResults <= 0.25) {
        self.recordView.imageView.image = [UIImage imageNamed:@"record_voice_one"];
    } else if (0.25 < lowPassResults && lowPassResults <= 0.5) {
        self.recordView.imageView.image = [UIImage imageNamed:@"record_voice_two"];
    } else if (0.5 < lowPassResults && lowPassResults <= 0.75) {
        self.recordView.imageView.image = [UIImage imageNamed:@"record_voice_three"];
    } else {
        self.recordView.imageView.image = [UIImage imageNamed:@"record_voice_fourth"];
    }
}

- (void)recordCountAction { //时间
    
//    ceil(self.audioRecorder.currentTime)
//    self.recordTimeNum ++;//self.audioRecorder.currentTime
//    NSLog(@"%ld -- 录音时间%lf",self.recordTimeNum,self.audioRecorder.currentTime);
    
    NSLog(@"%f -- 录音时间%lf",ceil(self.audioRecorder.currentTime),self.audioRecorder.currentTime);
    
    if (ceil(self.audioRecorder.currentTime) >= Limite_Record_Time) {
        
        self.isOverTime = YES;
        self.recordView.hidden = YES;
        [self recordFinish];
        [self.view makeToast:TDLocalizeSelect(@"EACH_RECORD_MORE_SECOND", nil) duration:0.8 position:CSToastPositionCenter];
    }
}

- (void)transformVAFToMP3 { //将录音文件转为 MP3 文件
    
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.mp3FilePath = [NSString stringWithFormat:@"%@/%@.mp3",strUrl,self.recordKeyStr];

    @try {
        int read, write;
        
        FILE *pcm = fopen([self.recordUrl cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([self.mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        NSLog(@"MP3生成成功: %@",self.mp3FilePath);
        self.recordUrl = self.mp3FilePath;
        
        //MP3时间
//        AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.mp3FilePath] options:nil];
//        CMTime audioDuration = audioAsset.duration;
//        float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
//        
//        NSLog(@"mp3的时间 -- %lf",audioDurationSeconds);
//        
//        //MP3大小
//        NSInteger fileSize =  [self getFileSize:self.mp3FilePath];
//        NSLog(@"mp3大小 ------- %@", [NSString stringWithFormat:@"%ld kb", fileSize/1024]);
    }
}

- (NSInteger)getFileSize:(NSString *)path { //计算文件大小
    
    NSFileManager *filemanager = [[NSFileManager alloc] init];
    if([filemanager fileExistsAtPath:path]){
        
        NSDictionary *attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) ) {
            return  [theFileSize intValue];
        } else {
            return -1;
        }
        
    } else {
        return -1;
    }
}

#pragma mark - 长按录音
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures {
    return UIRectEdgeNone;
}

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    if (![self authorizationMicrophone]) {
        return;
    }
    
    CGPoint point = [gestureRecognizer locationInView:self.inputView.recordButton];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"长按开始");
        
        self.recordView.hidden = NO;
        [self startRecord];
        [self updateRecordButton:TDLocalizeSelect(@"RELEASE_TO_SAVE", nil) imageStr:@"record_black_image" enable:YES];
        
    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"长按结束");
        
        if (self.isOverTime) {
            self.isOverTime = NO;
            return;
        }
        
        self.recordView.hidden = YES;
        
        if (point.y > -35) {
            [self recordFinish];
            
        } else {
            self.inputView.audioPlayView.hidden = YES;
            [self updateRecordButton:TDLocalizeSelect(@"HOLD_TO_RECORD", nil) imageStr:@"record_not_image" enable:YES];
            [self updateRecordView:NO];
            [self cancelRecord];
        }
        
    } else if(gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"长按中");
        
        if (self.isOverTime) {
            return;
        }
        
        [self updateRecordButton:TDLocalizeSelect(@"RELEASE_TO_SAVE", nil) imageStr:@"record_black_image" enable:YES];
        if (point.y > -35) {
            [self updateRecordView:NO];
            
        } else {
            [self updateRecordView:YES];
        }
    }
    
//    NSLog(@"y轴移动-------->>> %lf",point.y);
}

- (void)updateRecordView:(BOOL)isSwipe {
    
    self.isSwipe = isSwipe;
    
    self.recordView.remindLabel.text = isSwipe == NO ? TDLocalizeSelect(@"SCROLL_UP_TO_CANCEL", nil) : TDLocalizeSelect(@"RELEASE_FINGER_TO_CANCEL", nil);
    self.recordView.imageView.image = [UIImage imageNamed:isSwipe == NO ? @"record_voice_zero" : @"record_revoke_image"];
    self.recordView.remindLabel.backgroundColor = isSwipe == NO ? [UIColor clearColor] : [UIColor colorWithHexString:colorHexStr5];
    self.recordView.remindLabel.textColor = isSwipe == NO ? [UIColor whiteColor] : [UIColor redColor];
}

//更新按钮状态
- (void)updateRecordButton:(NSString *)titleStr imageStr:(NSString *)imageStr enable:(BOOL)enable {
    [self.inputView.recordButton setTitle:titleStr forState:UIControlStateNormal];
    [self.inputView.recordButton setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
    self.inputView.recordButton.userInteractionEnabled = enable;
}

- (void)updateAvButtonConstraint { //更新语音的布局
    
    self.inputView.audioPlayView.hidden = NO;
    
    self.inputView.audioPlayView.timeLabel.text = [NSString stringWithFormat:@"%d“",self.mp3TimeNum];
    float width = (TDWidth - 88) * (self.mp3TimeNum / Limite_Record_Time);
    
    [self.inputView.audioPlayView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(13);
        make.bottom.mas_equalTo(self.inputView.imageView.mas_top).offset(-18);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(width > 88 ? width : 88);
    }];
}

#pragma mark - 播放录音
- (void)playAvAudio { //点击时候播放与暂停
    
    if (self.avPlayer.playing) {
        [self.avPlayer stop];
        [self stopPlayMp3Constraint];
        return;
    }
    
    
    [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.audioSession setActive:YES error:nil];
    
    self.avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:self.recordUrl] error:nil];
    self.avPlayer.delegate = self;
    [self.avPlayer prepareToPlay];
    [self.avPlayer play];
    
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playTimerAction) userInfo:nil repeats:YES];
    
    //    NSLog(@"播放时间 ---->> %f",self.avPlayer.duration);
}

- (void)playTimerAction {
    
    self.playImageNum ++;
    switch (self.playImageNum % 3) {
        case 0:
            self.inputView.audioPlayView.imageView.image = [UIImage imageNamed:@"player_three_image"];
            break;
        case 1:
            self.inputView.audioPlayView.imageView.image = [UIImage imageNamed:@"player_one_image"];
            break;
        default:
            self.inputView.audioPlayView.imageView.image = [UIImage imageNamed:@"player_two_image"];
            break;
    }
    
}

// AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag { //播放结束
    
    [self stopPlayMp3Constraint];
}

- (void)stopPlayMp3Constraint {
    self.inputView.audioPlayView.imageView.image = [UIImage imageNamed:@"player_black_image"];
    [self.playTimer invalidate];
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.inputView = [[TDQuetionInputView alloc] initWithType: self.whereFrom];
    [self.view addSubview:self.inputView];
    
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
    
    WS(weakSelf);
    self.inputView.audioPlayView.tapAction = ^{
        [weakSelf playAvAudio];
    };
    self.inputView.audioPlayView.longPressAction = ^{
        [weakSelf showSheetView:0 tag:0];
    };
    
    self.inputView.imageView.deleteImageHandle = ^(NSInteger tag) {
        [weakSelf showSheetView:1 tag:tag];
    };
    
    self.inputView.imageView.tapImageHandle = ^(NSInteger tag) {
        [weakSelf gotoPreViewImageVC:tag];
    };
    
    [self.inputView.imageView.firstButton addTarget:self action:@selector(selectImageButton:) forControlEvents:UIControlEventTouchUpInside];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.3;
    [self.inputView.recordButton addGestureRecognizer:longPress];

    self.recordView = [[TDRecordView alloc] init];
    self.recordView.frame = CGRectMake(0, 0, TDWidth, TDHeight - BAR_ALL_HEIHT - 48);
    [self.view addSubview:self.recordView];

    self.recordView.hidden = YES;
    
}

- (void)showSheetView:(NSInteger)type tag:(NSInteger)tag { //0 语音，1 图片
    
    WS(weakSelf);
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:type == 0 ? TDLocalizeSelect(@"DELETE_RECORD_TEXT", nil) : TDLocalizeSelect(@"DELETE_PHOTO_TEXT", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        if (type == 0) {
            
            weakSelf.inputView.audioPlayView.hidden = YES;
            [weakSelf deleteFile];
            [weakSelf updateRecordButton:TDLocalizeSelect(@"HOLD_TO_RECORD", nil) imageStr:@"record_not_image" enable:YES];
            
        } else {
            [weakSelf removeImage:tag];
        }
    }];
    [alertView addAction:cancelAction];
    [alertView addAction:deleteAction];
    
    [self presentViewController:alertView animated:YES completion:nil];
}

#pragma mark - 麦克风授权
- (BOOL)authorizationMicrophone {
    
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (audioStatus) {
        case AVAuthorizationStatusNotDetermined: { //未询问过用户是否授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (granted) {
                    NSLog(@"---允许用户使用麦克风");
                }
            }];
        }
            break;
            
        case AVAuthorizationStatusRestricted: //未授权，例如家长控制
            
//            break;
        case AVAuthorizationStatusDenied://未授权，用户曾选择过拒绝授权
            [self showAuthenAlertView:1];
            break;
            
        case AVAuthorizationStatusAuthorized://已经授权
            return YES;
            break;
            
        default:
            break;
    }
    return NO;
}

#pragma mark - 图片
- (void)selectImageButton:(UIButton *)sender {//选择图片
    
    PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
    switch (photoStatus) {
        case PHAuthorizationStatusNotDetermined: { //第一次选择
            
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {//获取图片权限
                if (status == PHAuthorizationStatusAuthorized) {
                    [self gotoPhotoSelectVc];
                }
            }];
        }
            break;
        case PHAuthorizationStatusRestricted://不能完成授权，可能开启了访问限制
            
//            break;
        case PHAuthorizationStatusDenied://禁止了 -- 提示跳转相册授权设置
            [self showAuthenAlertView:0];
            break;
            
        case PHAuthorizationStatusAuthorized://已经通过授权
            [self gotoPhotoSelectVc];
            break;
            
        default:
            break;
    }
}

//设置权限
- (void)showAuthenAlertView:(NSInteger )type {
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDic));
    NSString *appName = infoDic[@"CFBundleDisplayName"];
    
    NSString *messageStr = type == 0 ? [TDLocalizeSelect(@"ALLOW_USE_CAMERA_TEXT", nil) oex_formatWithParameters:@{@"name": appName}] : [TDLocalizeSelect(@"ALLOW_USE_MICROPHONE_TEXT", nil) oex_formatWithParameters:@{@"name": appName}];
    
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:TDLocalizeSelect(@"SYSTEM_WARING", nil) message:messageStr preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
        }
        
    }];
    [alertControl addAction:cancelAction];
    [alertControl addAction:sureAction];
    
    [self presentViewController:alertControl animated:YES completion:nil];
}

- (void)gotoPhotoSelectVc { //图片选择页
    
    TDImageGroupViewController *imageGroupVc = [[TDImageGroupViewController alloc] init];
    imageGroupVc.hadImageArray = self.imageArray;
    
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:imageGroupVc];
    [self presentViewController:naviController animated:YES completion:nil];
}

- (void)removeImage:(NSInteger)index { //删除图片
    
    [self.imageArray removeObjectAtIndex:index];
    self.inputView.imageView.imageArray = self.imageArray;
}

- (void)gotoPreViewImageVC:(NSInteger)index { //预览图片
    
    TDPreViewImageViewController *previewVC = [[TDPreViewImageViewController alloc] init];
    previewVC.imageArray = self.imageArray;
    previewVC.index = index;
    previewVC.whereFrom = TDPreviewImageFromQuedionInputView;
    
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:previewVC];
    [self presentViewController:naviController animated:YES completion:nil];
}

- (void)imageSelectNoti:(NSNotification *)notification { //已选择图片通知传值
    
    NSDictionary *dic = notification.userInfo;
    NSArray *infoArray = dic[@"selectImageArray"];
    if (infoArray.count > 0) {
        for (TDSelectImageModel *model in infoArray) {
            if (![self.imageArray containsObject:model]) {
                [self.imageArray addObject:model];
            }
        }
    }
    
    //    [self.imageArray addObjectsFromArray:dic[@"selectImageArray"]];
    self.inputView.imageView.imageArray = self.imageArray;
    
    //    NSLog(@"传值 ----------->>> %@",dic);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
