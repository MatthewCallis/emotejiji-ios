//
//  EmoteBox.h
//  emotejiji
//
//  Created by Matthew Callis on 7/11/13.
//  Copyright (c) 2013 emotejiji. All rights reserved.
//

#import "MGBox.h"

@interface EmoteBox : MGBox

+ (EmoteBox *)emoteBoxFor:(NSInteger)i size:(CGSize)size;

- (void)loadEmote;

@end
