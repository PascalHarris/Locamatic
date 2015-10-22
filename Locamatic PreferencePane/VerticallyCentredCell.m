//
//  VerticallyCentredCell.m
//  USBleat
//
//  Created by Pascal Harris on 20/03/2013.
//  Copyright (c) 2013 Pascal Harris. All rights reserved.
//

#import "VerticallyCentredCell.h"

@implementation VerticallyCentredCell

- (NSRect)titleRectForBounds:(NSRect)theRect
{
    NSRect titleFrame = [super titleRectForBounds:theRect];
    NSSize titleSize = [[self attributedStringValue] size];
    titleFrame.origin.y = theRect.origin.y + (theRect.size.height - titleSize.height) / 2.0;
    return titleFrame;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSRect titleRect = [self titleRectForBounds:cellFrame];
    [[self attributedStringValue] drawInRect:titleRect];
}
@end
