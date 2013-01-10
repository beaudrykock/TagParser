//
//  BWCViewController.m
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


#import "BWCViewController.h"

@interface BWCViewController ()

@end

@implementation BWCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self testParse];
}

-(void)testParse
{
    NSString*test = @"<p>This is an example of a paragraph. Note that snippets of text are uniquely associated with each paragraph, should you need to apply a paragraph styling.</p><p>Here is a section of <b>bold</b> text within a paragraph, and here is a section of <i>italicized</i> text. 'em' tags are parsed as <em>italics</em>, 'strong' as <strong>bold</strong>. Finally, here is a section of <u>underlined text</u>.</p><p>The parser can also handle line breaks, <br>like this.</p><p>Tags that the parser does not recognize (e.g. img) will be ignored, like this one:<img src=\"blah\"></p><p>Links are handled in formatting but no gesture recognizers, etc, are added, e.g. <a href=\"http://www.google.com\">click here!</a></p>";
    
    NSString*escapedTest = @"&lt;p&gt;This is an example of a paragraph. Note that snippets of text are uniquely associated with each paragraph, should you need to apply a paragraph styling.&lt;/p&gt;&lt;p&gt;Here is a section of &lt;b&gt;bold&lt;/b&gt; text within a paragraph, and here is a section of &lt;i&gt;italicized&lt;/i&gt; text. 'em' tags are parsed as &lt;em&gt;italics&lt;/em&gt;, 'strong' as &lt;strong&gt;bold&lt;/strong&gt;. Finally, here is a section of &lt;u&gt;underlined text&lt;/u&gt;.&lt;/p&gt;&lt;p&gt;The parser can also handle line breaks, &lt;br&gt;like this.&lt;/p&gt;&lt;p&gt;Tags that the parser does not recognize (e.g. img) will be ignored, like this one:&lt;img src=&quot;blah&quot;&gt;&lt;/p&gt;&lt;p&gt;Links are handled in formatting but no gesture recognizers, etc, are added, e.g. &lt;a href=&quot;http://www.google.com&quot;&gt;click here!&lt;/a&gt;&lt;/p&gt;";
    
    BWCTagParser *btp = [[BWCTagParser alloc] init];
    
    // handles both escaped and unescaped strings thanks to GTMNSString+HTML from Google Tools
    //NSAttributedString *str = [btp stringFromHTML:test];
    NSAttributedString *str = [btp attributedStringFromHTML:escapedTest];
    
    self.displayedText.attributedText = str;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
