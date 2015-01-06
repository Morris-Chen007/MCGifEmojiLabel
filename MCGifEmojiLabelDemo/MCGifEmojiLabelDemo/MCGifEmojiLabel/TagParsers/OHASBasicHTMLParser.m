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


#import "OHASBasicHTMLParser.h"
#import "NSAttributedString+Attributes.h"
#import "NSString+Base64.h"
#import "NSString+string.h"

#if __has_feature(objc_arc)
#define MRC_AUTORELEASE(x) (x)
#else
#define MRC_AUTORELEASE(x) [(x) autorelease]
#endif

@implementation OHASBasicHTMLParser

NSDictionary *emotDicts =nil;

+(void)initialize {
    [super initialize];
    if (emotDicts!=nil) {
        return;
    }
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"gifEmoji.plist"];
    emotDicts = [[NSDictionary alloc] initWithContentsOfFile:filePath];
}

+(NSDictionary*)tagMappings
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange linkRange = [match rangeAtIndex:1];
                NSRange textRange = [match rangeAtIndex:1];
                NSUInteger startpos = [OHASMarkupParserBase findChar:'(' In:str.string From:(linkRange.location + linkRange.length - 1)];
                NSString* userid = nil;
                NSString* username = nil;
                if (NSNotFound != startpos) {
                    NSUInteger endpos = [OHASMarkupParserBase findChar:')' In:str.string From:startpos];
                    if (NSNotFound != endpos)
                    {
                        textRange = NSMakeRange(textRange.location, (endpos - textRange.location + 1));
                        userid = [str.string substringWithRange:NSMakeRange(startpos + 1, endpos - startpos - 1)];
                        NSString* tmp = [str.string substringToIndex:startpos];
                        username = [tmp substringFromLastAppearanceOf:'@'];
                    }
                }
                
                if ((linkRange.length>0) && (textRange.length>0))
                {
                    NSString* link = [str attributedSubstringFromRange:linkRange].string;
                    link = [link base64EncodedString];
                    if (nil != userid)
                    {
                        if ((nil != username) && ![username isEqualToString:@""])
                        {
                            NSArray* array = [NSArray arrayWithObjects:userid, username, nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"setClassSpaceUserDict" object:array];
                        }
                        
                        link = [NSString stringWithFormat:@"user:%@", userid];
                    }
                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                    NSURL *url = [NSURL URLWithString:link];
                    [foundString setLink:url range:NSMakeRange(0,[foundString length])];
                    return MRC_AUTORELEASE(foundString);
                } else {
                    return nil;
                }
            }, @"(@[a-zA-Z0-9\\u4e00-\\u9fa5]+)",
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange linkRange = [match rangeAtIndex:1];
                NSRange textRange = [match rangeAtIndex:1];
                if ((linkRange.length>0) && (textRange.length>0))
                {
                    NSString* link = [str attributedSubstringFromRange:linkRange].string;
//                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:NSMakeRange(0,0)] mutableCopy];
//                    [foundString setEmoit:link range:NSMakeRange(0,[foundString length])];
                    
                    
                    //render empty space for drawing the image in the text //1
                    CTRunDelegateCallbacks callbacks;
                    callbacks.version = kCTRunDelegateVersion1;
                    callbacks.getAscent = ascentCallback;
                    callbacks.getDescent = descentCallback;
                    callbacks.getWidth = widthCallback;
                    callbacks.dealloc = deallocCallback;
                    
                    NSDictionary* imgAttr = [[NSDictionary dictionaryWithObjectsAndKeys: //2
                                              @"15", @"width",
                                              @"15", @"height",
                                              nil] retain];
                    
                    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, imgAttr); //3
                    NSDictionary *attrDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:
                                                            //set the delegate
                                                            (id)delegate, (NSString*)kCTRunDelegateAttributeName,
                                                            nil];
                    NSMutableAttributedString* foundString = [[NSMutableAttributedString alloc] initWithString:@" " attributes:attrDictionaryDelegate];
                    [foundString setEmoit:emotDicts[link] width:imgAttr[@"width"] height:imgAttr[@"height"]];
                    
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
    return [(NSString*)[(NSDictionary*)ref objectForKey:@"height"] floatValue];
}
static CGFloat descentCallback( void *ref ){
    return [(NSString*)[(NSDictionary*)ref objectForKey:@"descent"] floatValue];
}
static CGFloat widthCallback( void* ref ){
    return [(NSString*)[(NSDictionary*)ref objectForKey:@"width"] floatValue];
}

@end


