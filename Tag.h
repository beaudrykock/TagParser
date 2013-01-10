//
//  Tag.h
//  
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

// definitions of types once tag has been created
typedef enum
{
    UNKNOWN=0,
    PARAGRAPH=1,
    BOLD=2,
    ITALIC=3,
    LINE_BREAK=4,
    HYPERLINK=5,
    UNDERLINE=6
} tagType;

// These tags are not currently handled, but will be in future:
// @"strong"
// @"em"
// @"ol"
// @"ul"

@interface Tag : NSObject {
	
}

@property (nonatomic, copy) NSString *content; // to hold, for example, link contents
@property (nonatomic) tagType tagType;
@property (nonatomic) BOOL isOpen;

-(BOOL)isOfSameTagType:(int)tagType;
-(BOOL)isParagraph;
-(void)print;
-(void)setup;

@end
