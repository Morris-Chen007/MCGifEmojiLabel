MCGifEmojiLabel is a user-friendly UILabel subclass which can show emoji with animation effects.It also allows you to add custom links to its text.
How to use
-

- Copy all the files in `MCGifEmojiLabel` folder to your project.
- Modify `gifEmoji.plist` and files in `emojiGifs` accordingly.
- Create a MCGifEmojiLabel object, set its text or add some custom links, and then add it to the super view.

   		 MCGifEmojiLabel* label = [[MCGifEmojiLabel 
                        alloc]initWithFrame:CGRectMake(10, 100, 300, 100)];
         [label setTextWithEmoji:@"When I was young I'd listen to the  
								   radio(#laughing),waiting for my favorite 
								   songs(#smiling).When they played I'd sing 
								   along(#flushed).It made me smile."];
    	 [label addCustomLink:[NSURL URLWithString:@"https://github.com"] 
				inRange:NSMakeRange(0, 40)];
         label.highlightedLinkColor = [UIColor grayColor];
         label.lineBreakMode = NSLineBreakByWordWrapping;
    
         [self.view addSubview:label];
 
Screenshots
-

![](https://github.com/Morris-Chen007/MCGifEmojiLabel/blob/master/ScreenShots/screenshot.gif)

Acknowledgement
- Some of the code is merged from OHAttributedLabel.
