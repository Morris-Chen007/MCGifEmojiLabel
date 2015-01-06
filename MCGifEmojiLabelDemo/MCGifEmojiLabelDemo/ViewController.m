//
//  ViewController.m
//  MCGifEmojiLabelDemo
//
//  Created by morris on 14-12-24.
//  Copyright (c) 2014年 morris. All rights reserved.
//

#import "ViewController.h"
#import "MCGifEmojiLabel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    MCGifEmojiLabel* label = [[MCGifEmojiLabel alloc] initWithFrame:CGRectMake(0, 100, 320, 30)];
    [label setTextWithEmoji:@"陈昕:狗狗好可爱(#抱抱)哈哈(#爱你)微风的撒(#害羞)额风(#闭嘴)fdf(#蛋糕)"];
    //[processor addExpressionAndLink:label rawstring:@"陈昕:狗狗好可爱(#嘻嘻)(#嘻嘻)"];
    [label addCustomLink:[NSURL URLWithString:@"aaa"] inRange:NSMakeRange(0, 3)];
    label.highlightedLinkColor = [UIColor grayColor];
    
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
