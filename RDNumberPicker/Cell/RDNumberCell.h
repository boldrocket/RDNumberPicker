//
//  RDNumberCell.h
//  RDNumberPicker
//
//  Created by Ricky Dunn on 24/06/2015.
//  Copyright (c) 2015 BoldRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDNumberCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *label;

- (void)configureCellWithNumber:(NSNumber *)number withColor:(UIColor *)color;

@end
