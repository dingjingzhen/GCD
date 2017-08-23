//
//  ViewController.m
//  gcdDemo
//
//  Created by Apple on 2017/8/22.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self testBarrier];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)testOne

{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        NSLog(@"代码块只执行了一次");
    });
}


- (void)testBarrier
{
    //队列不能是系统的并行队列
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    size_t t = 6;
    dispatch_apply(t, concurrentQueue, ^(size_t q) {
        NSLog(@"我擦");
    });
    
    //线程一
    dispatch_async(concurrentQueue, ^{
        for (int i=0; i<100; i++) {
            NSLog(@"线程一:%d",i);
        }
    });
    //线程二
    dispatch_async(concurrentQueue, ^{
        for (int i=0; i<100; i++) {
            NSLog(@"线程二:%d",i);
        }
    });
    //在线程一,线程二执行完成之后,在线程三执行之前执行一段代码,再开始执行线程三
    dispatch_barrier_async(concurrentQueue, ^{
        NSLog(@"barrier");
    });
    
    //线程三
    dispatch_async(concurrentQueue, ^{
        for (int i=0; i<100; i++) {
            NSLog(@"线程三:%d",i);
        }
    });
    //线程四
    dispatch_async(concurrentQueue, ^{
        for (int i=0; i<100; i++) {
            NSLog(@"线程四:%d",i);
        }
    });
}


- (void)testApply
{
    /*
     @param1 代码块执行的次数
     @param2 代码块所在的队列
     @param3 线程的执行体
     */
    size_t t = 10;
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply(t, globalQueue, ^(size_t q){
        NSLog(@"线程一:%ld",q);
    });
}

- (void)testAffter
{
    NSLog(@"执行之前");
    //当前时间10秒之后
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 10);
    /*
     @param1:时间
     @param2:线程所在的队列
     @param3:线程的执行体
     */
    dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"执行了after");
    });
}

//将线程放到一个组里面
//当组中所有队列中的线程执行完后,将会执行dispatch_group_notify(dispatch_group_t group,queue,^(void){});方法中Block
//作用:当一个页面需要多个下载时候,就可以将该将所有异步下载的线程添加到队列后再添加到组中,当完成了所有的下载,最后在dispatch_group_notify方法中重新刷新页面.
- (void)testGroup
{
    //创建一个组
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    /*
     @param1:线程所在的组
     @param2:线程所在的队列
     @param3:线程的执行体
     */
    dispatch_group_async(group, globalQueue, ^{
        for (int i=0; i<100; i++) {
            NSLog(@"线程一:%d",i);
        }
    });
    //在组中在添加一个线程
    dispatch_group_async(group, globalQueue, ^{
        for (int i=0; i<100; i++) {
            NSLog(@"线程二:%d",i);
        }
    });
    
    //在多有线程组里面的所有线程执行完成之后调用的代码
    dispatch_group_notify(group, globalQueue, ^{
        NSLog(@"线程所有的方法执行完成");
    });
}
@end
