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

#import "ViewController.h"
#import "MCGifEmojiLabel.h"

@interface ViewController ()<MCGifEmojiLabelDelegate>
{
    MCGifEmojiLabel* label;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    label = [[MCGifEmojiLabel alloc] initWithFrame:CGRectMake(10, 100, 300, 100)];
    label.backgroundColor = [UIColor lightGrayColor];
    label.delegate = self;
    [label setTextWithEmoji:@"When I was young I'd listen to the radio(#laughing),waiting for my favorite songs(#smiling).When they played I'd sing along(#flushed).It made me smile." font:[UIFont systemFontOfSize:14]];
    [label addCustomLink:[NSURL URLWithString:@"https://github.com"] inRange:NSMakeRange(0, 40)];
    label.highlightedLinkColor = [UIColor grayColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.view addSubview:label];
}

- (BOOL)emojiLabel:(MCGifEmojiLabel*)attributedLabel shouldAdaptToSuggestedHeight:(CGFloat)height
{
    CGRect frame = label.frame;
    frame.size.height = height;
    label.frame = frame;
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
