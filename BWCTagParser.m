//
//  BWCTagParser.m
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


#import "BWCTagParser.h"
#import "Tag.h"
#import "Snippet.h"

@implementation BWCTagParser

-(id)init
{
    self = [super init];
    if (self)
    {
        self.boldRanges = [[NSMutableArray alloc] initWithCapacity:10];
        self.italicRanges = [[NSMutableArray alloc] initWithCapacity:10];
        self.paragraphHashes = [NSMutableDictionary dictionaryWithCapacity:10];
        self.snippets = [[NSMutableArray alloc] initWithCapacity:1000];
        self.openSnippets = [[NSMutableArray alloc] initWithCapacity:1000];
        self.tags = [[NSMutableArray alloc] initWithCapacity:10];
        self.neededTags = [NSArray arrayWithObjects:@"p", @"i", @"b", @"a", @"u", @"br", @"em", @"st", nil];
        self.neededTwoCharTags = [NSArray arrayWithObjects:@"br", @"em", @"st", nil];
        self.neededSingletons = [NSArray arrayWithObjects:@"<br />", nil];
    }
    return self;
}

// pre-processing: remove any sneaky control and formatting marks, etc
// going to rely entirely on explicit HTML tags for formatting
-(NSString *)preprocess:(NSString*)string
{
    NSString *newLineCharAsStr = [NSString stringWithFormat:@"%d", NSNewlineCharacter];
    NSString *carriageReturnCharAsStr = [NSString stringWithFormat:@"%d", NSCarriageReturnCharacter];
    NSString *lineSeparatorCharAsStr = [NSString stringWithFormat:@"%d", NSLineSeparatorCharacter];
    NSString *paragraphSeparatorCharAsStr = [NSString stringWithFormat:@"%d", NSParagraphSeparatorCharacter];
    NSDictionary *controlAndFormattingMarks = [NSDictionary dictionaryWithObjectsAndKeys:
                                               @"", newLineCharAsStr,
                                               @"", carriageReturnCharAsStr,
                                               @"", lineSeparatorCharAsStr,
                                               @"", paragraphSeparatorCharAsStr,nil];
    
    NSEnumerator *controlAndFormattingMarksEnumerator = [controlAndFormattingMarks keyEnumerator];
    
    NSString *key;
    
    while ((key = (NSString*)[controlAndFormattingMarksEnumerator nextObject]))
    {
        string = [string stringByReplacingOccurrencesOfString:key withString:@""];
    }
    
    return string;
}

-(NSAttributedString*)attributedStringFromHTML:(NSString*)htmlString
{
    // first unescape
    htmlString = [htmlString gtm_stringByUnescapingFromHTML];
 
    // now pre-process to remove sneaky tags
    htmlString = [self preprocess:htmlString];
    
    // now parse to generate a set of snippets and associated tags
    [self parseHTMLTags:htmlString];
    
#ifdef DEBUG_VERBOSE
    NSLog(@"At end of parsing...\n");
    NSLog(@"%i snippets:\n", [self.snippets count]);
    int count = 1;
    for (Snippet *snippet in self.snippets)
    {
        NSLog(@"Contents of snippet %i: '%@'\n", count, [snippet text]);
        NSLog(@"Tags associated with snippet %i:\n", count);
        for (Tag *tag in snippet.tags)
             [tag print];
        count++;
    }
#endif
    // now return an attributed string
    return [self generateAttributedString];
}

// returns a plain NSString but also generates bold, italic and underline ranges
// if generation of attributed string needs to happen elsewhere
-(NSString*)stringFromHTML:(NSString*)htmlString
{
    // first unescape
    htmlString = [htmlString gtm_stringByUnescapingFromHTML];
    
    // now pre-process to remove sneaky tags
    htmlString = [self preprocess:htmlString];
    
    // now parse to generate a set of snippets and associated tags
    [self parseHTMLTags:htmlString];
    
#ifdef DEBUG_VERBOSE
    NSLog(@"At end of parsing...\n");
    NSLog(@"%i snippets:\n", [self.snippets count]);
    int count = 1;
    for (Snippet *snippet in self.snippets)
    {
        NSLog(@"Contents of snippet %i: '%@'\n", count, [snippet text]);
        NSLog(@"Tags associated with snippet %i:\n", count);
        for (Tag *tag in snippet.tags)
            [tag print];
        count++;
    }
#endif
    // now return an attributed string
    return [self generateStringWithAttributedRanges];
}

-(void)parseHTMLTags:(NSString*)candidate
{
    NSLog(@"1");
    NSString *scanContents = @"";
    NSScanner *scanner = [NSScanner scannerWithString:candidate];
    [scanner setCharactersToBeSkipped:nil];
    
    Snippet *snippet = [[Snippet alloc] init];
    [snippet setup];
    [self.snippets addObject:snippet];
    
    // add any open tags to the new snippet (except paragraph)
    [self addOpenTagsToSnippet:snippet];
        NSLog(@"2");
    // scan to an opening tag
    [scanner scanUpToString:@"<" intoString:&scanContents];
    
    // store contents of scan (will be nothing first time round)
    if (scanContents != NULL)
    {
        snippet.text = [snippet.text stringByAppendingString: scanContents];
    }
    
    // hop over opening tag
    [scanner setScanLocation:scanner.scanLocation+1];
    
    // scan to closing tag
    [scanner scanUpToString:@">" intoString:&scanContents];
    
    // process tag
    [self processTag:[self generateTagFromText:scanContents] forSnippet:snippet];
        NSLog(@"3");
    // substring from current location+1
    NSString *substring = [candidate substringFromIndex:scanner.scanLocation+1];
    
    if ([substring length]>0)
        [self parseHTMLTags:substring];

}

-(void)addOpenTagsToSnippet:(Snippet*)snippet
{
    NSMutableArray *tagsToRemove = [NSMutableArray arrayWithCapacity:1];
    for (Tag *tag in self.tags)
    {
        if (tag.isOpen)
        {
            [snippet openTag:tag];
            
            // singleton tags must be handled here
            if (tag.tagType == LINE_BREAK)
            {
                [tagsToRemove addObject:tag];
                [tag setIsOpen:NO];
                if ([snippet closeTag:tag])
                {
                    [self.openSnippets removeObject:snippet];
                }
            }
            else
            {
                if (![self.openSnippets containsObject:snippet])
                    [self.openSnippets addObject:snippet];
            }
        }
    }
    
    for (Tag *tag in tagsToRemove)
    {
        [self.tags removeObject:tag];
    }
}

-(void)processTag:(Tag*)newTag forSnippet:(Snippet *)snippet
{
    Tag *youngestTag = nil;
    // get tag at front of queue
    if ([self.tags count]>0)
        youngestTag = [self.tags objectAtIndex:[self.tags count]-1];
    
    if (youngestTag != nil && youngestTag.tagType == newTag.tagType)
    {
        // if tags match, this is a pair
        // close the oldest tag and add to the snippet
        [youngestTag setIsOpen:NO];
        
        NSMutableArray *closeSnippets = [NSMutableArray arrayWithCapacity:5];
        for (Snippet *sn in self.openSnippets)
        {
            BOOL closeSnippet = NO;
            if ([sn containsOpenTag:youngestTag])
            {
                closeSnippet = [sn closeTag:youngestTag];
            }
            if (closeSnippet)
                [closeSnippets addObject:sn];
        }
        
        for (Snippet *sn in closeSnippets)
            [self.openSnippets removeObject: sn];
        
        [snippet closeTag:youngestTag];
        [self.tags removeObject:youngestTag];
    }
    else if (newTag.tagType != UNKNOWN)
    {
        // add to the queue
        [self.tags addObject:newTag];
    }
}

-(Tag*)generateTagFromText:(NSString*)tagText
{
    // remove any '/' from the tag
    tagText = [tagText stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *content = @"";
    
    // handle more complex tags
    if ([tagText length]>1)
    {
        // strip any ugly attributes: if second character is a space, strip everything
        if ([[tagText substringWithRange:NSMakeRange(1, 1)] isEqualToString:@" "])
        {
            if ([[tagText substringToIndex:1] isEqualToString:@"a"])
            {
                // if it's a link, get the link contents
                NSScanner *linkScanner = [NSScanner scannerWithString:tagText];
                [linkScanner setCharactersToBeSkipped:nil];
                [linkScanner scanUpToString:@"href=" intoString:nil];
                
                // step beyond href and whatever delimiter is being used
                [linkScanner setScanLocation:[linkScanner scanLocation]+6];
                
                [linkScanner scanUpToString:@"\"" intoString:&content];
            }
            
            // now substring - only interested in the first letter
            tagText = [tagText substringToIndex:1];
        }
        else
        {
            // check if substring indices 0,1 equals any desirable two-char tags
            for (NSString *twoCharTag in self.neededTwoCharTags)
            {
                if ([twoCharTag isEqualToString:[tagText substringToIndex:2]])
                {
                    // if so, make sure tag is stripped to that alone (to handle variations on <br>, for example)
                    tagText = [tagText substringToIndex:2];
                }
            }
        }
    }
    
    Tag *tag = [[Tag alloc] init];
    [tag setup];
    
    for (NSString *tagNeeded in self.neededTags)
    {
        if ([tagText isEqualToString:tagNeeded])
        {
            [tag setTagType:[self tagTypeFromText: tagNeeded]];
            
            [tag setIsOpen:YES];
            
            if ([content length]>0)
                tag.content = content;
            
            break;
        }
    }
    
    return tag;
}

-(tagType)tagTypeFromText:(NSString*)text
{
    tagType tt;
    
    if ([text isEqualToString:@"p"])
    {
        tt = PARAGRAPH;
    }
    else if ([text isEqualToString:@"i"])
    {
        tt = ITALIC;
    }
    else if ([text isEqualToString:@"b"])
    {
        tt = BOLD;
    }
    else if ([text isEqualToString:@"br"])
    {
        tt = LINE_BREAK;
    }
    else if ([text isEqualToString:@"a"])
    {
        tt = HYPERLINK;
    }
    else if ([text isEqualToString:@"u"])
    {
        tt = UNDERLINE;
    }
    else if ([text isEqualToString:@"em"])
    {
        tt = ITALIC;
    }
    else if ([text isEqualToString:@"st"])
    {
        tt = BOLD;
    }
    return tt;
}

-(NSString*)generateStringWithAttributedRanges
{
    NSMutableString *finalString = [[NSMutableString alloc] initWithCapacity:1];
    int charCounter = 0;
    int snippetStart = 0;
    int snippetLength = 0;
    
    for (Snippet *snippet in self.snippets)
    {
        snippetStart = charCounter;
        snippetLength = [[snippet text] length];
        [finalString appendString:[snippet text]];
        charCounter += snippetLength;
        
        if ([snippet hasTagType:BOLD])
        {
            
            [self.boldRanges addObject: NSStringFromRange(NSMakeRange(snippetStart, snippetLength))];
        }
        
        if ([snippet hasTagType:ITALIC])
        {
            [self.italicRanges addObject: NSStringFromRange(NSMakeRange(snippetStart, snippetLength))];
        }
        
        if ([snippet hasTagType:UNDERLINE])
        {
            [self.underlineRanges addObject: NSStringFromRange(NSMakeRange(snippetStart, snippetLength))];
        }

    }
    return finalString;
}

-(NSAttributedString*)generateAttributedString
{
    UIFont *boldFont = [UIFont boldSystemFontOfSize:12.0];
    UIFont *italicFont = [UIFont italicSystemFontOfSize:12.0];
    UIFont *regularFont = [UIFont systemFontOfSize:12.0];
    
    NSMutableAttributedString * finalString = [[NSMutableAttributedString alloc] initWithString:@""];
    for (Snippet * snippet in self.snippets) {
        
        NSMutableArray *attributeObjects = [NSMutableArray arrayWithCapacity:[snippet.tags count]];
        NSMutableArray *attributeKeys = [NSMutableArray arrayWithCapacity:[snippet.tags count]];
        
        if ([snippet hasTagType:UNDERLINE])
        {
            [attributeObjects addObject:[NSNumber numberWithInt:NSUnderlineStyleSingle]];
            [attributeKeys addObject:NSUnderlineStyleAttributeName];
        }
        
        if ([snippet hasTagType:HYPERLINK])
        {
            // this would be where you'd handle the action for a hyperlink; this just adds the formatting
            [attributeObjects addObject:[NSNumber numberWithInt:NSUnderlineStyleSingle]];
            [attributeKeys addObject:NSUnderlineStyleAttributeName];
        }
        
        if ([snippet hasTagType:LINE_BREAK])
        {
            NSAttributedString * paraBreak = [[NSAttributedString alloc] initWithString: @"\n" attributes:nil];
            [finalString appendAttributedString: paraBreak];

        }
        
        if ([snippet hasTagType:PARAGRAPH])
        {
            if ([self.paragraphHashes objectForKey:[snippet paragraphTagHash]] == nil)
            {
                NSAttributedString * paraBreak = [[NSAttributedString alloc] initWithString: @"\n    " attributes:nil];
                [finalString appendAttributedString: paraBreak];
                [self.paragraphHashes setObject:@"YES" forKey:[snippet paragraphTagHash]];
            }
        }
        if ([snippet hasTagType:ITALIC])
        {
            [attributeObjects addObject:italicFont];
            [attributeKeys addObject:NSFontAttributeName];
        }
        if ([snippet hasTagType:BOLD])
        {
            [attributeObjects addObject:boldFont];
            [attributeKeys addObject:NSFontAttributeName];
        }
        if (![snippet hasTagType:BOLD] && ![snippet hasTagType:ITALIC])
        {
            [attributeObjects addObject:regularFont];
            [attributeKeys addObject:NSFontAttributeName];
        }
    
        NSDictionary * attributes = [NSDictionary dictionaryWithObjects:attributeObjects forKeys:attributeKeys];
        NSAttributedString * subString = [[NSAttributedString alloc] initWithString:snippet.text attributes:attributes];
        [finalString appendAttributedString:subString];
    }
    
    return finalString;
}

@end
