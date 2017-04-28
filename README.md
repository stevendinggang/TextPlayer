# TextPlayer iOS文字转语音播放器

主要使用了AVFoundation/AVFoundation 系统库来实现语音播报
AVSpeechSynthesizer
这个类可以用来播放一个或者多个语音内容，播放的语音内容都是通过实例化AVSpeechUtterance而得到，对于一个或者多个AVSpeechUtterance实例，
AVSpeechSynthesizer对象起到队列的作用，提供了API可以控制和监视正在进行的语音播放

AVSpeechSynthesizerDelegate协议的监听方法：

@optional
// 播放开始状态
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance;
// 播放结束状态
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance;
// 播放暂停状态
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance;
// 跳出播放状态
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance;
// 退出播放状态
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance;
// 播放状态时，当前所播放的字符串范围，及AVSpeechUtterance实例（可通过此方法监听当前播放的字或者词）
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange 
utterance:(AVSpeechUtterance *)utterance;

简单计算了一下输入内容文字的长度,进行分割显示

引用了 JXTLibrary  实现文字播放的效果



