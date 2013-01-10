//
//  BWCTagParser.h
//  TagParser
//
//  Created by Beaudry Kock on 1/8/13.
//  Copyright (c) 2013 Better World Coding | www.betterworldcoding.org
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import "GTMNSString+HTML.h"

enum {
    NSEnterCharacter                = 0x0003,
    NSBackspaceCharacter            = 0x0008,
    NSTabCharacter                  = 0x0009,
    NSNewlineCharacter              = 0x000a,
    NSFormFeedCharacter             = 0x000c,
    NSCarriageReturnCharacter       = 0x000d,
    NSBackTabCharacter              = 0x0019,
    NSDeleteCharacter               = 0x007f,
    NSLineSeparatorCharacter        = 0x2028,
    NSParagraphSeparatorCharacter   = 0x2029
};

@interface BWCTagParser : NSObject
{}

@property (nonatomic, retain) NSMutableArray *neededTwoCharTags;
@property (nonatomic, retain) NSMutableDictionary *paragraphHashes;
@property (nonatomic) NSInteger paragraphCounter;
@property (nonatomic, retain) NSArray *neededTags;
@property (nonatomic, retain) NSArray *neededSingletons;
@property (nonatomic, copy) NSString *rawHTML;
@property (nonatomic, copy) NSString *strippedHTML;
@property (nonatomic, retain) NSMutableArray *openSnippets;
@property (nonatomic, retain) NSMutableArray *snippets;
@property (nonatomic, retain) NSMutableArray *tags;

// for use with creating NSAttributedString elsewhere
// create more ranges if necessary here
@property (nonatomic, retain) NSMutableArray *boldRanges;
@property (nonatomic, retain) NSMutableArray *italicRanges;
@property (nonatomic, retain) NSMutableArray *underlineRanges;

// use this to generate plain string with no HTML tags, along with bold, italic, underline ranges
-(NSString*)stringFromHTML:(NSString*)htmlString;

// use this to generate a fully attributed string ready for slotting into a UILabel, etc
-(NSAttributedString*)attributedStringFromHTML:(NSString*)htmlString;

@end
