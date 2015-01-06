/***********************************************************************************
 * This software is under the MIT License quoted below:
 ***********************************************************************************
 *
 * Copyright (c) 2014 Morris Chen
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 ***********************************************************************************/

#import "MCGifEmojiTimerProcessor.h"

@implementation MCGifEmojiTimerProcessor

- (instancetype)init
{
    self = [super init];
    if (self) {
        timerDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (MCGifEmojiTimerProcessor *)sharedClient
{
    static MCGifEmojiTimerProcessor *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] init];
    });
    return sharedClient;
}

- (void)addTimerForLabel:(MCGifEmojiLabel *)label
{
    NSString* labelAddr = [NSString stringWithFormat:@"%p", label];
    NSTimer* gifTimer = [NSTimer timerWithTimeInterval:0.15 target:self selector:@selector(gifAnimate:) userInfo:labelAddr repeats:YES];
    [timerDict setObject:gifTimer forKey:labelAddr];
    [[NSRunLoop mainRunLoop] addTimer:gifTimer forMode:NSRunLoopCommonModes];
}

- (void)gifAnimate:(NSTimer *)timer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCGifEmojiLabelSetNeedDisplay" object:timer.userInfo];
}

- (void)killTimerForLabel:(MCGifEmojiLabel *)label
{
    NSString* labelAddr = [NSString stringWithFormat:@"%p", label];
    NSTimer* gifTimer = [timerDict objectForKey:labelAddr];
    if (nil != gifTimer)
    {
        [gifTimer invalidate];
    }
    
    [timerDict removeObjectForKey:labelAddr];
}

@end
