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
    MCGifEmojiLabel* label = [[MCGifEmojiLabel alloc] initWithFrame:CGRectMake(10, 100, 300, 100)];
    [label setTextWithEmoji:@"When I was young I'd listen to the radio(#laughing),waiting for my favorite songs(#smiling).When they played I'd sing along(#flushed).It made me smile."];
    [label addCustomLink:[NSURL URLWithString:@"https://github.com"] inRange:NSMakeRange(0, 34)];
    label.highlightedLinkColor = [UIColor grayColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
