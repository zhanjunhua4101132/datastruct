//
//  main.m
//  testThread
//
//  Created by 张军华 on 2019/11/7.
//  Copyright © 2019年 张军华. All rights reserved.
//

#import <Foundation/Foundation.h>


//启动三个线程A，B，C，打印10次 按照ABC的顺序输出
static NSLock *lockA;
void testThread1()
{
    lockA = [[NSLock alloc] init];
    dispatch_semaphore_t semaA = dispatch_semaphore_create(1);
    dispatch_semaphore_t semaB = dispatch_semaphore_create(0);
    dispatch_semaphore_t semaC = dispatch_semaphore_create(0);
    
    dispatch_queue_t queueA = dispatch_queue_create("queuea", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueA, ^{
        for (int i = 0; i<1; i++) {
            NSLog(@"ABegin(%d)",i);
            dispatch_semaphore_wait(semaA, DISPATCH_TIME_FOREVER);
            NSLog(@"A======= %@",@(i));
            dispatch_semaphore_signal(semaB);
            NSLog(@"AEnd(%d)",i);
        }
    });
    
    dispatch_queue_t queueB = dispatch_queue_create("queueb", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueB, ^{
        for (int i = 0; i<1; i++) {
            NSLog(@"BBegin(%d)",i);
            dispatch_semaphore_wait(semaB, DISPATCH_TIME_FOREVER);
            NSLog(@"B======= %@",@(i));
            dispatch_semaphore_signal(semaC);
            NSLog(@"BEnd(%d)",i);
        }
    });
    
    dispatch_queue_t queueC = dispatch_queue_create("queuec", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueC, ^{
        for (int i = 0; i<1; i++) {
            NSLog(@"CBegin(%d)",i);
            dispatch_semaphore_wait(semaC, DISPATCH_TIME_FOREVER);
            NSLog(@"C======= %@",@(i));
            dispatch_semaphore_signal(semaA);
            NSLog(@"CEnd(%d)",i);
            NSLog(@"   ");
        }
    });
}


//启动三个线程A，B，C，打印10次 AB交替打印奇偶，C打印结束
void testThread2()
{
    //此处必须用static，不然会因为信号量释放而崩溃
    static dispatch_semaphore_t semaA;
    static dispatch_semaphore_t semaB;
    static dispatch_semaphore_t semaC;
    semaA = dispatch_semaphore_create(1);
    semaB = dispatch_semaphore_create(0);
    semaC = dispatch_semaphore_create(0);
    
    __block int i = 0;
    int count = 10;
    
    dispatch_queue_t queueA = dispatch_queue_create("queuea", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueA, ^{
        NSLog(@"queueA---begin");
        for (; i<count;) {
            dispatch_semaphore_wait(semaA, DISPATCH_TIME_FOREVER);
        
            //此处在等待的时候，B线程有可能修改i的值，导致下面的业务逻辑出现问题
            if (i+1 <= count) {
               NSLog(@"A======= %@",@(i));
               i++;
            }
            
            dispatch_semaphore_signal(semaB);
        }
        NSLog(@"queueA---exist");
        dispatch_semaphore_signal(semaC);
        
    });
    
    dispatch_queue_t queueB = dispatch_queue_create("queueb", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueB, ^{
        NSLog(@"queueB---begin");
        for (; i<count;) {
            dispatch_semaphore_wait(semaB, DISPATCH_TIME_FOREVER);
            
            //此处在等待的时候，A线程有可能修改i的值，导致下面的业务逻辑出现问题
            if (i+1 <= count) {
                NSLog(@"B======= %@",@(i));
                i++;
            }
            dispatch_semaphore_signal(semaA);
        }
         NSLog(@"queueB---exist");
         dispatch_semaphore_signal(semaC);
    });
    
    dispatch_queue_t queueC = dispatch_queue_create("queuec", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueC, ^{
            NSLog(@"queueC---begin");
            dispatch_semaphore_wait(semaC, DISPATCH_TIME_FOREVER);
            NSLog(@"C=======finish");
            NSLog(@"queueC---exist");
    });
    
    
    //sleep(5);
//    dispatch_queue_t queueA = dispatch_queue_create("queuea", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(queueA, ^{
//        NSLog(@"queueA---begin");
//        for (; i<count;) {
//            dispatch_semaphore_wait(semaA, DISPATCH_TIME_FOREVER);
//            NSLog(@"A======= %@",@(i));
//            i++;
//            dispatch_semaphore_signal(semaB);
//        }
//        NSLog(@"queueA---exist");
//        dispatch_semaphore_signal(semaC);
//
//    });
}

//找到不大于n的最大的2的密数
int test2Pow(int N){
    //step1
//    int sum = 1;
//    while (YES) {
//        if (sum*2 > N) {
//            break;
//        }
//        sum = sum * 2;
//    }
//    NSLog(@"sum = %d",sum);
//    return sum;
    
    //step2
    int sum = N;
    sum |= sum >> 1;
    sum |= sum >> 2;
    sum |= sum >> 4;
    sum =  (sum + 1) >> 1;
    NSLog(@"sum = %d",sum);
    return sum;
}

int main(int argc, const char * argv[]) {

    //testThread1();
    testThread2();
    //test2Pow(19);

    
    sleep(20);
    NSLog(@"main exit");
    return 0;
}
