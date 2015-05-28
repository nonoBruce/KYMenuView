//
//  ViewController.m
//  KYMenuView
//
//  Created by yanwen on 5/19/15.
//  Copyright (c) 2015 GameBegin. All rights reserved.
//

#import "ViewController.h"
#import "KYMenuView.h"

@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//      [self showMenu];
}
- (IBAction)btnAction:(id)sender {
    [self showMenu];
}

- (void)showMenu {
    KYMenuView *menuView = [[KYMenuView alloc] init];
    [menuView setPagingEnabled:YES];
    menuView.bounces = NO;
    [menuView.backgroundImgView setImage:[UIImage imageNamed:@"ky_background"]];
    
    
    [menuView addMenuItemWithTitle:@"Facebook" andIcon:[UIImage imageNamed:@"ky_facebook"] andSelectedBlock:^{
        NSLog(@"Facebook");
    }];
    [menuView addMenuItemWithTitle:@"Instagram" andIcon:[UIImage imageNamed:@"ky_instagram"] andSelectedBlock:^{
        NSLog(@"Instagram");
    }];
    [menuView addMenuItemWithTitle:@"Line" andIcon:[UIImage imageNamed:@"ky_line"] andSelectedBlock:^{
        NSLog(@"Line");
    }];
    [menuView addMenuItemWithTitle:@"Wechat" andIcon:[UIImage imageNamed:@"ky_wechat"] andSelectedBlock:^{
        NSLog(@"Wechat");
    }];
    [menuView addMenuItemWithTitle:@"Wechat" andIcon:[UIImage imageNamed:@"ky_wechat_friend"] andSelectedBlock:^{
        NSLog(@"Wechatfriend");
    }];
    

    [menuView show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
