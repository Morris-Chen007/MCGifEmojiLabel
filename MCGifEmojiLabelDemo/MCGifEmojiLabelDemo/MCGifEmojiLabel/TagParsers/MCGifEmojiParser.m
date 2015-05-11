/***********************************************************************************
 * This software is under the MIT License quoted below:
 ***********************************************************************************
 *
 * Copyright (c) 2010 Olivier Halligon
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


#import "MCGifEmojiParser.h"
#import "NSAttributedString+Attributes.h"

#if __has_feature(objc_arc)
#define MRC_AUTORELEASE(x) (x)
#else
#define MRC_AUTORELEASE(x) [(x) autorelease]
#endif

@implementation MCGifEmojiParser

NSDictionary *emotDicts =nil;

+(void)processMarkupInAttributedString:(NSMutableAttributedString*)mutAttrString font:(UIFont *)font containEmoji:(BOOL *)containEmoji
{
    NSDictionary* mappings = [self tagMappings:font];
    
    NSRegularExpressionOptions options = NSRegularExpressionAnchorsMatchLines | NSRegularExpressionDotMatchesLineSeparators | NSRegularExpressionUseUnicodeWordBoundaries;
    [mappings enumerateKeysAndObjectsUsingBlock:^(id pattern, id obj, BOOL *stop1)
     {
         TagProcessorBlockType block = (TagProcessorBlockType)obj;
         NSRegularExpression* regEx = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:nil];
         
         NSAttributedString* processedString = [mutAttrString copy];
         __block NSUInteger offset = 0;
         NSRange range = NSMakeRange(0, processedString.length);
         [regEx enumerateMatchesInString:processedString.string options:0 range:range
                              usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop2)
          {
              NSAttributedString* repl = block(processedString, result);
              if (repl)
              {
                  int start = (int)(result.range.location - offset);
                  
                  NSRange offsetRange = NSMakeRange(start, result.range.length);
                  NSUInteger resultLen = result.range.length;
                  if ((nil != containEmoji) && ([(NSString *)pattern isEqualToString:@"\\(#([a-zA-Z0-9\\u4e00-\\u9fa5]+?)\\)"]))
                  {
                      *containEmoji = YES;
                  }
                  //                  NSLog(@"1111-%@-%@",NSStringFromRange(offsetRange),repl);
                  [mutAttrString replaceCharactersInRange:offsetRange withAttributedString:repl];
                  offset += resultLen - repl.length;
              }
          }];
#if ! __has_feature(objc_arc)
         [processedString release];
#endif
     }];
    
}

+ (NSMutableAttributedString*)attributedStringByProcessingMarkupInString:(NSString*)string font:(UIFont *)font containEmoji:(BOOL *)containEmoji
{
    NSMutableAttributedString* mutAttrString = [NSMutableAttributedString attributedStringWithString:string];
    [self processMarkupInAttributedString:mutAttrString font:font containEmoji:containEmoji];
    return mutAttrString;
}

+(void)initialize {
    [super initialize];
    if (emotDicts!=nil) {
        return;
    }
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"gifEmoji.plist"];
    emotDicts = [[NSDictionary alloc] initWithContentsOfFile:filePath];
}

+(NSDictionary*)tagMappings:(UIFont *)font
{
    static CGFloat ascent = 0;
    ascent = font.ascender;
    static CGFloat descent = 0;
    descent = -font.descender;
    static CGFloat width = 0;
    width = ascent + descent;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange linkRange = [match rangeAtIndex:1];
                NSRange textRange = [match rangeAtIndex:1];
                if ((linkRange.length>0) && (textRange.length>0))
                {
                    NSString* link = [str attributedSubstringFromRange:linkRange].string;
                    //render empty space for drawing the image in the text //1
                    CTRunDelegateCallbacks callbacks;
                    callbacks.version = kCTRunDelegateVersion1;
                    callbacks.getAscent = ascentCallback;
                    callbacks.getDescent = descentCallback;
                    callbacks.getWidth = widthCallback;
                    callbacks.dealloc = deallocCallback;
                    
                    NSDictionary* imgAttr = [[NSDictionary dictionaryWithObjectsAndKeys: //2
                                              [NSString stringWithFormat:@"%f", width], @"width",
                                              [NSString stringWithFormat:@"%f", ascent], @"ascent",
                                              [NSString stringWithFormat:@"%f", descent], @"descent",
                                              nil] retain];
                    
                    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, imgAttr); //3
                    NSDictionary *attrDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:
                                                            //set the delegate
                                                            (id)delegate, (NSString*)kCTRunDelegateAttributeName,
                                                            nil];
                    NSMutableAttributedString* foundString = [[NSMutableAttributedString alloc] initWithString:@" " attributes:attrDictionaryDelegate];
                    [foundString setEmoit:emotDicts[link] width:imgAttr[@"width"] height:imgAttr[@"ascent"]];
                    
                    return MRC_AUTORELEASE(foundString);
                } else {
                    return nil;
                }
            }, @"\\(#([a-zA-Z0-9\\u4e00-\\u9fa5]+?)\\)",
            nil];
}



/* Callbacks */
static void deallocCallback( void* ref ){
    [(id)ref release];
}
static CGFloat ascentCallback( void *ref ){
    return [(NSString*)[(NSDictionary*)ref objectForKey:@"ascent"] floatValue];
}
static CGFloat descentCallback( void *ref ){
    return [(NSString*)[(NSDictionary*)ref objectForKey:@"descent"] floatValue];
}
static CGFloat widthCallback( void* ref ){
    return [(NSString*)[(NSDictionary*)ref objectForKey:@"width"] floatValue];
}

@end


