//
//  ViewController.m
//  RunLoop演示
//
//  Created by zuoA on 16/10/13.
//  Copyright © 2016年 啊左. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

//测试一
@property (strong,nonatomic)NSThread *thread;
- (IBAction)showSource:(id)sender;
//测试二
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)addTime:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建自定义的子线程
    self.thread = [[NSThread alloc]initWithTarget:self selector:@selector(threadMethod) object:nil];
    [self.thread start];  //启动子线程
}
-(void)threadMethod
{
    NSLog(@"打开子线程方法");
    while (1) {
        
        //条件一：run，进入循环，如果没有source/timer就直接退出，不进入循环，后面加上source才能进入工作。
        /*【原因：如果线程中有需要处理的源，但是响应的事件没有到来的时候，线程就会休眠等待相应事件的发生;
         这就是为什么run loop可以做到让线程有工作的时候忙于工作，而没工作的时候处于休眠状态。】
         */
        [[NSRunLoop currentRunLoop]run];
        
        //上面一行代码等于加了参数为1的while，所以当有source进入循环，下面这条代码的就不会运行。
        NSLog(@"这里是threadMethod：%@", [NSThread currentThread]);
        //如果要测试“二、addTime”按钮的话，建议注释掉上面这句代码。
    }
}

#pragma mark -- 测试一：子线程Selector源的启动
- (IBAction)showSource:(id)sender {
    
    //注意：在这个方法里面输出的是main主线程，因为是主线程运行的UI控件行为。
    NSLog(@"这里是主线程：%@",[NSThread currentThread]);
    /*
     在没有run之前，一直处于休眠状态。所以如果要运行selector方法，还需要threadMethod中条件一不断循环的Run！
     在我们指定的线程中调用方法，此处相当于增加了一个带source的mode，有内容,实现了RunLoop循环运行成立的条件二。
     */
    //试着在这句之前添加[[NSRunLoop currentRunLoop]run];是不能启动子线程的RunLoop，因为此处是在main主线程上。
    [self performSelector:@selector(threadSelector) onThread:self.thread withObject:nil waitUntilDone:NO];

}
-(void)threadSelector//【在子线程】
{
    NSLog(@"打开子线程Selector源");
    NSLog(@"此处是threadSelector源：%@",[NSThread currentThread]);
}


#pragma mark -- 二、Time测试
- (IBAction)addTime:(UIButton *)sender {
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(showTimer) userInfo:nil repeats:YES];
    //添加timer到RunLoop
    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];
}
-(void)showTimer   //【在主线程】
{
    NSLog(@"调用time的线程：%@",[NSThread currentThread]);
    [self showText:@"-------time-------"];
}
#pragma mark --在文本控件textView后面增加str字符串
-(void)showText:(NSString *)str  //注意：UI控件需要在主线程里面，如果是在子线程执行此段代码则运行报错。
{
    NSString *text = self.textView.text;
    self.textView.text = [text stringByAppendingString:str];
}
@end
