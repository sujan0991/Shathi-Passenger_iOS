//
//  CancelReasonTableViewCell.m
//  Shathi
//
//  Created by Sujan on 8/2/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "CancelReasonTableViewCell.h"
#import "HexColors.h"


@implementation CancelReasonTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = [UIColor hx_colorWithHexString:@"323B61"];
    self.reasonLabel.highlightedTextColor = [UIColor whiteColor];
    

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
