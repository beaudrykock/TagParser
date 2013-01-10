//
//  Snippet.m
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


#import "Snippet.h"


@implementation Snippet

@synthesize text, tags;

-(void)addTag:(Tag*)newTag
{
	[tags addObject: newTag];
}

-(BOOL)hasTagType:(tagType)type
{
    BOOL found = NO;
    int counter = 0;
    while (!found && counter < [tags count])
    {
        if ([[tags objectAtIndex:counter] tagType] == type) found = YES;
        counter++;
    }
    
    return found;
}

-(NSString *)tagContentsForType:(tagType)type
{
    Tag *tag = [self getTagOfType:type];
    
    return tag.content;
}

-(void)setup
{
	tags = [NSMutableArray arrayWithCapacity:5];
    self.candidateTags = [NSMutableDictionary dictionaryWithCapacity:10];
    text = @"";
}

-(Tag*)getParagraphTag
{
    BOOL found = NO;
    NSInteger foundIndex = -1;
    int counter = 0;
    while (!found && counter < [tags count])
    {
        if ([[tags objectAtIndex:counter] tagType] == PARAGRAPH)
        {
            found = YES;
            foundIndex = counter;
        }
        counter++;
    }
    
    return [tags objectAtIndex:foundIndex];
}

-(Tag*)getTagOfType:(tagType)type
{
    BOOL found = NO;
    NSInteger foundIndex = -1;
    int counter = 0;
    while (!found && counter < [tags count])
    {
        if ([[tags objectAtIndex:counter] tagType] == type)
        {
            found = YES;
            foundIndex = counter;
        }
        counter++;
    }
    
    return [tags objectAtIndex:foundIndex];
}

-(void)openTag:(Tag *)tag
{
    if (![self.tags containsObject:tag])
    {
        [self.candidateTags setObject:tag forKey:[NSNumber numberWithInt:tag.hash]];
        self.openTags++;
    }
}

// returns TRUE when all tags are closed
-(BOOL)closeTag:(Tag *)tag
{
    if ([self.candidateTags objectForKey:[NSNumber numberWithInt:tag.hash]] != nil)
    {
        Tag *tagToClose  = [self.candidateTags objectForKey:[NSNumber numberWithInt:tag.hash]];
        [self.tags addObject:tagToClose];
        [self.candidateTags removeObjectForKey:[NSNumber numberWithInt:tag.hash]];
        self.openTags--;
    }
    return self.openTags==0;
}

-(BOOL)containsOpenTag:(Tag*)tag
{
    return ([self.candidateTags objectForKey:[NSNumber numberWithInt:tag.hash]]!=nil);
}

-(NSString *)paragraphTagHash
{
    return [NSString stringWithFormat:@"%i",[[self getParagraphTag] hash]];
}

-(void)print
{
    NSLog(@"\n\nPrinting contents of snippet");
    NSLog(@"Full text: %@", text);
    NSLog(@"Tags...");
    for (Tag *tag in tags)
    {
        [tag print];
    }
}

@end
