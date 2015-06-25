//
//  RDNumberCell.m
//  RDNumberPicker
//
//  Created by Ricky Dunn on 24/06/2015.
//  Copyright (c) 2015 BoldRocket. All rights reserved.
//

#import "RDNumberCell.h"

@implementation RDNumberCell

- (void)configureCellWithNumber:(NSNumber *)number withColor:(UIColor *)color
{
    self.label.text = [number stringValue];
    self.label.textColor = color;
}

@end
