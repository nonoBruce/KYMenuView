//
//  KYMenuView.h
//  KYMenuView
//
//  Created by yanwen on 5/19/15.
//  Copyright (c) 2015 GameBegin. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^KYSelectedBlock)(void);

@interface KYMenuView : UIScrollView


@property (nonatomic, strong)UIImageView *backgroundImgView;


+ (KYMenuView *)shareInstance;

- (void)addMenuItemWithTitle:(NSString*)title andIcon:(UIImage*)icon andSelectedBlock:(KYSelectedBlock)block;

- (void)show;

@end
