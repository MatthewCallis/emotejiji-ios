//
//  EmoteBox.m
//  emotejiji
//
//  Created by Matthew Callis on 7/11/13.
//  Copyright (c) 2013 emotejiji. All rights reserved.
//

#import "EmoteBox.h"

@implementation EmoteBox

#pragma mark - Init

- (void)setup {

  // positioning
  self.topMargin = 8;
  self.leftMargin = 8;

  // background
  self.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.95 alpha:1];

  // shadow
  self.layer.shadowColor = [UIColor colorWithWhite:0.12 alpha:1].CGColor;
  self.layer.shadowOffset = CGSizeMake(0, 0.5);
  self.layer.shadowRadius = 1;
  self.layer.shadowOpacity = 1;
}

#pragma mark - Factories

+ (EmoteBox *)emoteBoxFor:(NSInteger)i size:(CGSize)size {

  // box with emote number tag
  EmoteBox *box = [EmoteBox boxWithSize:size];
  box.tag = i;

  // add a loading spinner
  UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  spinner.center = CGPointMake(box.width / 2, box.height / 2);
  spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
      | UIViewAutoresizingFlexibleRightMargin
      | UIViewAutoresizingFlexibleBottomMargin
      | UIViewAutoresizingFlexibleLeftMargin;
  spinner.color = UIColor.lightGrayColor;
  [box addSubview:spinner];
  [spinner startAnimating];

  // do the emote loading async, because internets
  __weak id wbox = box;
  box.asyncLayoutOnce = ^{
    [wbox loadEmote];
  };

  return box;
}

#pragma mark - Layout

- (void)layout {
  [super layout];

  // speed up shadows
  self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

#pragma mark - Emote Box loading

- (void)loadEmote {
    NSLog(@"Loading Emote %d...", self.tag);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *arrayPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"emotes.data"];
    NSArray *emotes = [NSArray arrayWithContentsOfFile:arrayPath];

    // do UI stuff back in UI land
    dispatch_async(dispatch_get_main_queue(), ^{

        // ditch the spinner
        UIActivityIndicatorView *spinner = self.subviews.lastObject;
        [spinner stopAnimating];
        [spinner removeFromSuperview];

        NSString *emoteText = [NSString stringWithFormat:@"%@", [[emotes objectAtIndex:self.tag] valueForKeyPath:@"text"]];
        NSLog(@"Emote: %@", emoteText);

        // failed to get the emote?
        if (!emoteText) {
            self.alpha = 0.3;
            return;
        }

        // got the emote, so lets show it
        UILabel *yourLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
        yourLabel.alpha = 0;
        yourLabel.textColor = [UIColor blackColor];
        yourLabel.backgroundColor = [UIColor clearColor];

        yourLabel.tag = self.tag;
        yourLabel.size = self.size;
        yourLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        yourLabel.font = [UIFont fontWithName: @"Courier New" size: 16.0f];
        yourLabel.adjustsFontSizeToFitWidth = YES;
        yourLabel.textAlignment = NSTextAlignmentCenter;
        yourLabel.text = emoteText;

        [self addSubview:yourLabel];

        // fade the image in
        [UIView animateWithDuration:0.2 animations:^{
          yourLabel.alpha = 1;
        }];
    });
}

@end
