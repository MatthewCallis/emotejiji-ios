//
//  EJViewController.m
//  emotejiji
//
//  Created by Matthew Callis on 7/11/13.
//  Copyright (c) 2013 emotejiji. All rights reserved.
//

#import "EJViewController.h"
#import "MGScrollView.h"
#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"
#import "EmoteBox.h"

@interface EJViewController ()

@end

#define ROW_SIZE               (CGSize){304, 44}

#define IPHONE_PORTRAIT_PHOTO  (CGSize){148, 48}
#define IPHONE_LANDSCAPE_PHOTO (CGSize){152, 52}

#define IPHONE_PORTRAIT_GRID   (CGSize){312, 0}
#define IPHONE_LANDSCAPE_GRID  (CGSize){160, 0}
#define IPHONE_TABLES_GRID     (CGSize){320, 0}

#define IPAD_PORTRAIT_PHOTO    (CGSize){128, 128}
#define IPAD_LANDSCAPE_PHOTO   (CGSize){122, 122}

#define IPAD_PORTRAIT_GRID     (CGSize){136, 0}
#define IPAD_LANDSCAPE_GRID    (CGSize){390, 0}
#define IPAD_TABLES_GRID       (CGSize){624, 0}

#define HEADER_FONT            [UIFont fontWithName:@"HelveticaNeue" size:18]
#define TOTAL_EMOTES           32

@implementation EJViewController {
    MGBox *emotesGrid, *tablesGrid, *table1, *table2;
    UIImage *arrow;
    BOOL phone;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // iPhone or iPad?
    UIDevice *device = UIDevice.currentDevice;
    phone = device.userInterfaceIdiom == UIUserInterfaceIdiomPhone;

    arrow = [UIImage imageNamed:@"arrow"];
    
    // setup the main scroller (using a grid layout)
    self.scroller.contentLayoutMode = MGLayoutGridStyle;
    self.scroller.bottomPadding = 8;
    
    // iPhone or iPad grid?
    CGSize emotesGridSize = phone ? IPHONE_PORTRAIT_GRID : IPAD_PORTRAIT_GRID;
    
    // the emotes grid
    emotesGrid = [MGBox boxWithSize:emotesGridSize];
    emotesGrid.contentLayoutMode = MGLayoutGridStyle;
    [self.scroller.boxes addObject:emotesGrid];
    
    // the tables grid
    CGSize tablesGridSize = phone ? IPHONE_TABLES_GRID : IPAD_TABLES_GRID;
    tablesGrid = [MGBox boxWithSize:tablesGridSize];
    tablesGrid.contentLayoutMode = MGLayoutGridStyle;
    [self.scroller.boxes addObject:tablesGrid];
    
    // the features table
    table1 = MGBox.box;
    [tablesGrid.boxes addObject:table1];
    table1.sizingMode = MGResizingShrinkWrap;
    
    // the subsections table
    table2 = MGBox.box;
    [tablesGrid.boxes addObject:table2];
    table2.sizingMode = MGResizingShrinkWrap;
    
    // add emote boxes to the grid
    for (NSInteger i = 1; i <= TOTAL_EMOTES; i++) {
        [emotesGrid.boxes addObject:[self emoteBoxFor:i]];
    }
    
    // load some table sections
    if (phone) {
        [self loadIntroSection];
    } else {
        [self loadFilterEmotesSection:NO];
        [self loadSearchEmotesSection:NO];
    }
    [tablesGrid layout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:1];
    [self didRotateFromInterfaceOrientation:UIInterfaceOrientationPortrait];
}

#pragma mark - Rotation and resizing

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orient
                                         duration:(NSTimeInterval)duration {
    
    BOOL portrait = UIInterfaceOrientationIsPortrait(orient);
    
    // grid size
    emotesGrid.size = phone ? portrait
    ? IPHONE_PORTRAIT_GRID
    : IPHONE_LANDSCAPE_GRID : portrait
    ? IPAD_PORTRAIT_GRID
    : IPAD_LANDSCAPE_GRID;
    
    // emote sizes
    CGSize size = phone
    ? portrait ? IPHONE_PORTRAIT_PHOTO : IPHONE_LANDSCAPE_PHOTO
    : portrait ? IPAD_PORTRAIT_PHOTO : IPAD_LANDSCAPE_PHOTO;
    
    // apply to each emote
    for (MGBox *emote in emotesGrid.boxes) {
        emote.size = size;
        emote.layer.shadowPath
        = [UIBezierPath bezierPathWithRect:emote.bounds].CGPath;
        emote.layer.shadowOpacity = 0;
    }
    
    // relayout the sections
    [self.scroller layoutWithSpeed:duration completion:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orient {
    for (MGBox *emote in emotesGrid.boxes) {
        emote.layer.shadowOpacity = 1;
    }
}

#pragma mark - Emote Box factories

- (CGSize)emoteBoxSize {
    BOOL portrait = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    
    // What size plz?
    return phone
    ? portrait ? IPHONE_PORTRAIT_PHOTO : IPHONE_LANDSCAPE_PHOTO
    : portrait ? IPAD_PORTRAIT_PHOTO : IPAD_LANDSCAPE_PHOTO;
}

- (MGBox *)emoteBoxFor:(NSInteger)i {
    // Make the Emote Box
    EmoteBox *box = [EmoteBox emoteBoxFor:i size:[self emoteBoxSize]];
    
    // Copy the emote when tapped
    __weak id wbox = box;
    box.onTap = ^{
        // MGBox *section = (id)box.parentBox;

        // Copy and Paste
        for (UILabel *emoteText in [wbox subviews]){
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = emoteText.text;
            NSLog(@"Test PB: %@", pasteboard.string);
        }
    };
    
    return box;
}

#pragma mark - Emote Box helpers

- (MGBox *)emoteBoxWithTag:(int)tag {
    for (MGBox *box in emotesGrid.boxes) {
        if (box.tag == tag) {
            return box;
        }
    }
    return nil;
}

#pragma mark - Main menu sections

- (void)loadIntroSection {
    
    // intro section
    MGTableBoxStyled *menu = MGTableBoxStyled.box;
    [table1.boxes addObject:menu];
    
    // Header
    MGLineStyled *header = [MGLineStyled lineWithLeft:@"emotejiji Demo" right:nil size:ROW_SIZE];
    header.font = HEADER_FONT;
    [menu.topLines addObject:header];
    
    // Filter Emotes Line
    MGLineStyled *filterLine = [MGLineStyled lineWithLeft:@"Filter Emotes" right:arrow size:ROW_SIZE];
    [menu.topLines addObject:filterLine];
    filterLine.onTap = ^{
        [self loadFilterEmotesSection:YES];
    };

    // Search Emotes Line
    MGLineStyled *searchLine = [MGLineStyled lineWithLeft:@"Search Emotes" right:arrow size:ROW_SIZE];
    [menu.topLines addObject:searchLine];
    searchLine.onTap = ^{
        [self loadSearchEmotesSection:YES];
    };
}

- (void)loadFilterEmotesSection:(BOOL)animated {
    if (phone && table1.boxes.count > 1) {
        [table1.boxes removeObject:table1.boxes.lastObject];
    }
    
    // make the table
    MGTableBoxStyled *layout = MGTableBoxStyled.box;
    [table1.boxes addObject:layout];
    
    // Header
    MGLineStyled *head = [MGLineStyled lineWithLeft:@"Filter Emotes" right:nil size:ROW_SIZE];
    [layout.topLines addObject:head];
    head.font = HEADER_FONT;
    
    // Content
    MGLineStyled *content = [MGLineStyled lineWithLeft:@"Filter Controls..." right:arrow size:ROW_SIZE];
    [layout.topLines addObject:content];
    content.onTap = ^{
        // Do Something on Tap
    };
    
    // Animate and Scroll
    if (animated) {
        [table1 layoutWithSpeed:0.3 completion:nil];
        [self.scroller layoutWithSpeed:0.3 completion:nil];
        [self.scroller scrollToView:layout withMargin:8];
    } else {
        [table1 layout];
    }
}

- (void)loadSearchEmotesSection:(BOOL)animated {
    if (phone && table1.boxes.count > 1) {
        [table1.boxes removeObject:table1.boxes.lastObject];
    }
    
    // Make the Section
    MGTableBoxStyled *convini = MGTableBoxStyled.box;
    [table1.boxes addObject:convini];
    
    // Header
    MGLineStyled *head = [MGLineStyled lineWithLeft:@"Search Emotes" right:nil size:ROW_SIZE];
    [convini.topLines addObject:head];
    head.font = HEADER_FONT;

    // Content
    MGLineStyled *content = [MGLineStyled lineWithLeft:@"Search..." right:arrow size:ROW_SIZE];
    [convini.topLines addObject:content];
    content.onTap = ^{
        // Do Something on Tap
    };

    // animate and scroll
    if (animated) {
        [table1 layoutWithSpeed:0.3 completion:nil];
        [self.scroller layoutWithSpeed:0.3 completion:nil];
        [self.scroller scrollToView:convini withMargin:8];
    } else {
        [table1 layout];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
