//
//  ViewController.m
//  TextPlayer
//
//  Created by Steven on 2017/4/27.
//  Copyright © 2017年 Steven. All rights reserved.
//

#import "ViewController.h"
#import "DGTextPlayer.h"
#import "JXTProgressLabel.h"
#import "Masonry.h"

#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
#define kDeviceHight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *testTextView;
@property (weak, nonatomic) IBOutlet UIButton *playerBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *suspendBtn;
@property (weak, nonatomic) IBOutlet UISlider *rateSlider;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIButton *continueSpeakingBtn;

@property(nonatomic,strong) DGTextPlayer *textPlayer;
@property(nonatomic,strong) JXTProgressLabel *progressLableOne;
@property (nonatomic, strong) NSTimer *timer;
@property(nonatomic,assign) NSInteger index;
@property (nonatomic,strong) NSMutableArray *textArr;
@property (nonatomic,strong) NSString *TextStr;
@property(nonatomic,strong) NSString *textStrRange;//截取


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setUP];
}


-(void)setUP{
    self.testTextView.delegate=self;
    [self.playerBtn addTarget:self action:@selector(playText) forControlEvents:UIControlEventTouchUpInside];
    [self.stopBtn addTarget:self action:@selector(stopBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.suspendBtn addTarget:self action:@selector(suspendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.continueSpeakingBtn addTarget:self action:@selector(continueSpeakingBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.TextStr=self.testTextView.text;
    [self createProgressLable];
}


#pragma mark - progressLabel的使用
- (void)createProgressLable {

    _progressLableOne = [[JXTProgressLabel alloc] initWithFrame:CGRectMake(0, 0, 220, 30)];
    _progressLableOne.backgroundColor = [UIColor lightGrayColor];
    _progressLableOne.backgroundTextColor = [UIColor whiteColor];
    _progressLableOne.foregroundTextColor = [UIColor cyanColor];
    _progressLableOne.text = self.TextStr;
    _progressLableOne.textAlignment = NSTextAlignmentCenter;
    _progressLableOne.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:_progressLableOne];
    
    
    MASAttachKeys(self.progressLableOne,_progressLableOne);
    [_progressLableOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.testTextView.mas_right);
        make.left.equalTo(self.testTextView.mas_left);
        make.height.equalTo(@30);
        make.bottom.equalTo(self.testTextView.mas_top).offset(-10);
    }];
}


#pragma mark -TextViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    
    if (self.testTextView.text.length>0) {
        self.TextStr=textView.text;
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    
    if (self.testTextView.text.length>0) {
        self.TextStr=textView.text;
        //分隔语句,设置字符
        [self subTextStrAddArrayWithText:textView.text];
    }
}

#pragma mark -分割输入文字
-(void)subTextStrAddArrayWithText:(NSString *)TextStr{
    
    NSMutableArray *textArr=[NSMutableArray array];
    self.textStrRange=TextStr;
    while(self.textStrRange.length>10){
        
        NSString *rangeText=[self.textStrRange substringToIndex:10];
        self.textStrRange=[self.textStrRange substringFromIndex:10];
        [textArr addObject:rangeText];
    }
    
    [textArr addObject:self.textStrRange];
    [self.textArr removeAllObjects];
    self.textArr=textArr;
    self.index=0;
    self.progressLableOne.text=self.textArr[self.index];
}

#pragma mark -btnClick
-(void)playText{
    
   DGTextPlayer *textPlayer = [DGTextPlayer sharedInstance];
    textPlayer.rate=self.rateSlider.value;
    textPlayer.volume=self.volumeSlider.value;
    textPlayer.pitchMultiplier=1;
    self.textPlayer=textPlayer;
    //设置结束 Block
    __block typeof(self) weakSelf = self;
    //语音播报结束回调
    [self.textPlayer setStop:^{
        [weakSelf.timer invalidate];
         weakSelf.timer = nil;
         weakSelf.progressLableOne.dispProgress = 0;
    }];
    
    [textPlayer play:self.TextStr];
    //label
    [self startTimer];
    //初始状态
    [self subTextStrAddArrayWithText:self.TextStr];
}

-(void)continueSpeakingBtnClick{
    [self.textPlayer.qPlayer continueSpeaking];
    [self startTimer];
}

-(void)suspendBtnClick{
    
    [self.textPlayer.qPlayer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    [self stopTimer];
}

-(void)stopBtnClick{
    _progressLableOne.dispProgress = 0;
    [self.textPlayer.qPlayer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    [self stopTimer];
}

#pragma mark -文字进度

-(void)stopTimer{
    [_timer invalidate];
    _timer = nil;
}

-(void)startTimer{
    [_timer invalidate];
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progress) userInfo:nil repeats:YES];
}

- (void)progress{
    _progressLableOne.dispProgress += self.rateSlider.value/135;
    if (_progressLableOne.dispProgress >= 1) {
        self.index++;
        if (self.index==self.textArr.count) {
            self.index=0;
        }
        
        self.progressLableOne.text=self.textArr[self.index];
        _progressLableOne.dispProgress = 0;
        
    }
}

- (IBAction)rateSlider:(id)sender {
    UISlider *slider = (UISlider *)sender;

    self.textPlayer.rate=slider.value;
    
}

- (IBAction)volumeSlider:(id)sender {
    UISlider *slider = (UISlider *)sender;
    
    self.textPlayer.volume=slider.value;
    
}


#pragma mark-懒加载
- (NSMutableArray *)textArr{
    if (_textArr==nil) {
        _textArr=[NSMutableArray array];
    }
    return _textArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end





























