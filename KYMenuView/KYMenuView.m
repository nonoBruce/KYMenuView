//
//  KYMenuView.m
//  KYMenuView
//
//  Created by yanwen on 5/19/15.
//  Copyright (c) 2015 GameBegin. All rights reserved.
//
//
//
#define KYMenuViewTag               1999
#define KYMenuViewImageHeight       60
#define KYMenuViewImageWidth KYMenuViewImageHeight
#define KYMenuViewTitleHeight       20
#define KYMenuViewVerticalPadding   20
#define KYMenuViewHorizontalMargin  20
#define KYMenuViewRriseAnimationID      @"KYMenuViewRriseAnimationID"
#define KYMenuViewDismissAnimationID    @"KYMenuViewDismissAnimationID"
#define KYMenuViewAnimationTime     0.36
#define KYMenuViewAnimationInterval (KYMenuViewAnimationTime / 6)


#import "KYMenuView.h"

#pragma mark - button class
#pragma mark -

@interface KYMenuItemButton : UIButton

+ (instancetype)menuItemButtonWithTitle:(NSString*)title andIcon:(UIImage*)icon andSelectedBlock:(KYSelectedBlock)block;

@property(nonatomic,copy)KYSelectedBlock selectedBlock;

@end

@implementation KYMenuItemButton

//add a button
+ (instancetype)menuItemButtonWithTitle:(NSString*)title andIcon:(UIImage*)icon
                       andSelectedBlock:(KYSelectedBlock)block{
    KYMenuItemButton *button = [KYMenuItemButton buttonWithType:UIButtonTypeCustom];
    [button setImage:icon forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    button.selectedBlock = block;
    return button;
}

//drow the button
- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, KYMenuViewImageHeight, KYMenuViewImageHeight);
    self.titleLabel.frame = CGRectMake(0, KYMenuViewImageHeight+5, KYMenuViewImageHeight, KYMenuViewTitleHeight);
}

@end


@interface KYMenuView()<UIGestureRecognizerDelegate>{
    NSMutableArray *_buttons;
    NSInteger _numberInRow; //一行要多少个
    NSInteger _itemInPage;//一页多少个item
    NSInteger _pageNum ;//页数
    
}
@property(nonatomic,strong)KYSelectedBlock selectedBlock;


@end

#pragma mark - KYMenuView
#pragma mark -

@implementation KYMenuView


//singleton
static KYMenuView *mInstance;

+ (KYMenuView *)shareInstance{
    if(!mInstance){
        mInstance = [[KYMenuView alloc] init];
    }
    return mInstance;
}

- (instancetype)init{
    if(self = [super init]){
        [self setTag:KYMenuViewTag];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        ges.delegate = self;
        [self addGestureRecognizer:ges];
        _buttons = [[NSMutableArray alloc] initWithCapacity:6];

        self.backgroundImgView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundImgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.backgroundImgView];
    }
    return self;
}

//caculate columnCount
#pragma mark - 设置buttonframe大小
#pragma mark -

//button frme
- (CGRect)buttonFrameAtIndex:(NSUInteger)index{
    
     NSUInteger currentPage = index/9;
    if(_numberInRow==5){
        currentPage = index/10;
        index = index%10;
    }else{
        index = index%9;
    }
   
    NSUInteger columnCount = _numberInRow;
    NSUInteger columnIndex =  index % columnCount;
    
    NSUInteger rowCount = _buttons.count%_numberInRow==0? _buttons.count/_numberInRow:_buttons.count/_numberInRow+1;
    if(_pageNum>1){
        rowCount = _itemInPage/_numberInRow;
    }

    CGFloat offsetX = [self screenSize].width/_numberInRow*columnIndex + ([self screenSize].width/_numberInRow-KYMenuViewImageHeight)/2.0 +currentPage*[self screenSize].width;
    
    CGFloat itemHeight = (KYMenuViewImageHeight + KYMenuViewTitleHeight) * rowCount + (rowCount > 1?(rowCount - 1) * KYMenuViewHorizontalMargin:0);//全部高度
    CGFloat offsetY = ([self screenSize].height - itemHeight)-40;
    
    NSUInteger rowIndex = index / columnCount;
    offsetY += (KYMenuViewImageHeight + KYMenuViewTitleHeight + KYMenuViewVerticalPadding) * rowIndex;
    return CGRectMake(offsetX, offsetY, KYMenuViewImageHeight, (KYMenuViewImageHeight+KYMenuViewTitleHeight));
    
}
- (void)initData{
    
    if([self screenSize].width >= [self screenSize].height){
        _numberInRow = 5;
        _itemInPage = 10;
    }
    else{
        _numberInRow = 3;
        _itemInPage = 9;
    }
    //page numbers
    _pageNum = _buttons.count%_itemInPage>0?_buttons.count/_itemInPage+1:_buttons.count/_itemInPage;

    self.contentSize = CGSizeMake([self screenSize].width *_pageNum, [self screenSize].height);
    self.backgroundImgView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    for (NSUInteger i = 0; i < _buttons.count; i++) {
        KYMenuItemButton *button = _buttons[i];
        button.frame = [self buttonFrameAtIndex:i];
    }
}

//is want to respond the gesture
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer.view isKindOfClass:[KYMenuItemButton class]]) {
        return NO;
    }
    
    CGPoint location = [gestureRecognizer locationInView:self];
    for (UIView* subview in _buttons) {
        if (CGRectContainsPoint(subview.frame, location)) {
            return NO;
        }
    }
    return YES;
}

- (void)dismiss:(id)sender{
    [self dropAnimation];
    double delayInSeconds = KYMenuViewAnimationTime;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self removeFromSuperview];
    });
}

- (void)buttonTapped:(KYMenuItemButton*)btn{
    [self dismiss:nil];
    double delayInSeconds = KYMenuViewAnimationTime;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        btn.selectedBlock();
    });
}

- (void)riseAnimation{
    [self initData];
    NSUInteger columnCount = _numberInRow;
    NSUInteger rowCount = _buttons.count / columnCount + (_buttons.count%columnCount>0?1:0);
    for (NSUInteger index = 0; index < _buttons.count; index++) {
        KYMenuItemButton *button = _buttons[index];
        button.layer.opacity = 0;
        CGRect frame = [self buttonFrameAtIndex:index];
        NSUInteger rowIndex = index / columnCount;
        NSUInteger columnIndex = index % columnCount;
        CGPoint fromPosition = CGPointMake(frame.origin.x + KYMenuViewImageHeight / 2.0,frame.origin.y +  (rowCount - rowIndex + 2)*200 + (KYMenuViewImageHeight + KYMenuViewTitleHeight) / 2.0);
        
          CGPoint toPosition = CGPointMake(frame.origin.x + KYMenuViewImageHeight / 2.0,frame.origin.y + (KYMenuViewImageHeight + KYMenuViewTitleHeight) / 2.0);
      
        double delayInSeconds = rowIndex * columnCount * KYMenuViewAnimationInterval;
        delayInSeconds += KYMenuViewAnimationInterval *columnIndex;
        
        CABasicAnimation *positionAnimation;
        
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.45f :1.2f :0.75f :1.0f];
        positionAnimation.duration = KYMenuViewAnimationTime;
        positionAnimation.beginTime = [button.layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
        [positionAnimation setValue:[NSNumber numberWithUnsignedInteger:index] forKey:KYMenuViewRriseAnimationID];
        positionAnimation.delegate = self;
        
        [button.layer addAnimation:positionAnimation forKey:@"riseAnimation"];
    }
}

//按钮消失动画
- (void)dropAnimation{
    NSUInteger columnCount = _numberInRow;
    for (NSUInteger index = 0; index < _buttons.count; index++) {
        KYMenuItemButton *button = _buttons[index];
        CGRect frame = [self buttonFrameAtIndex:index];
        
        CGPoint fromPosition = CGPointMake(frame.origin.x + KYMenuViewImageHeight / 2.0,frame.origin.y + (KYMenuViewImageHeight + KYMenuViewTitleHeight) / 2.0);
        CGPoint toPosition  = CGPointMake(frame.origin.x + KYMenuViewImageHeight / 2.0, [UIScreen mainScreen].bounds.size.height+200);
        
        NSUInteger rowIndex = index%columnCount>0?index/columnCount+1:index/columnCount;
        rowIndex = index/columnCount;
        NSUInteger columnIndex = index%columnCount;
        double delayInSeconds =  (_numberInRow - rowIndex+1) * KYMenuViewAnimationInterval;
        delayInSeconds -= KYMenuViewAnimationInterval *columnIndex;
        CABasicAnimation *positionAnimation;
        positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:1.0f :1.0f :1.0f :1.0f];
        positionAnimation.duration = KYMenuViewAnimationTime;
        positionAnimation.beginTime = [button.layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
        [positionAnimation setValue:[NSNumber numberWithUnsignedInteger:index] forKey:KYMenuViewDismissAnimationID];
        positionAnimation.delegate = self;
        [button.layer addAnimation:positionAnimation forKey:@"riseAnimation"];
    }
}

//动画开始都会被调用
- (void)animationDidStart:(CAAnimation *)anim{
    if([anim valueForKey:KYMenuViewRriseAnimationID]) {
        NSUInteger index = [[anim valueForKey:KYMenuViewRriseAnimationID] unsignedIntegerValue];
        UIView *view = _buttons[index];
        CGRect frame = [self buttonFrameAtIndex:index];
        CGPoint toPosition = CGPointMake(frame.origin.x + KYMenuViewImageHeight / 2.0,frame.origin.y + (KYMenuViewImageHeight + KYMenuViewTitleHeight) / 2.0);
        CGFloat toAlpha = 1.0;
        
        view.layer.position = toPosition;
        view.layer.opacity = toAlpha;
        
    }
    else if([anim valueForKey:KYMenuViewDismissAnimationID]) {
        NSUInteger index = [[anim valueForKey:KYMenuViewDismissAnimationID] unsignedIntegerValue];
        UIView *view = _buttons[index];
        CGRect frame = [self buttonFrameAtIndex:index];
        CGPoint toPosition = CGPointMake(frame.origin.x + KYMenuViewImageHeight / 2.0,[UIScreen mainScreen].bounds.size.height+200);
        
        view.layer.position = toPosition;
    }
}


#pragma mark - public method
#pragma mark -

- (void)addMenuItemWithTitle:(NSString*)title andIcon:(UIImage*)icon andSelectedBlock:(KYSelectedBlock)block{
    KYMenuItemButton *button = [KYMenuItemButton menuItemButtonWithTitle:title andIcon:icon andSelectedBlock:block];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [_buttons addObject:button];
}

//show on the current view
- (void)show{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UIViewController *appRootViewController = window.rootViewController;
    
    
    UIViewController *topViewController = appRootViewController;
    while (topViewController.presentedViewController != nil)
    {
        topViewController = topViewController.presentedViewController;
    }
    if ([topViewController.view viewWithTag:KYMenuViewTag]) {
        [[topViewController.view viewWithTag:KYMenuViewTag] removeFromSuperview];
    }
    self.frame = topViewController.view.bounds;
    [topViewController.view addSubview:self];
    [self riseAnimation];
}

#pragma mark - 无关方法
#pragma mark -

#define IsIOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0 ? YES : NO)
- (CGSize)screenSize{
    //获得设备方向，然后根据方向获取设备的宽高。
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if(!IsIOS8){
        if(orientation == UIDeviceOrientationLandscapeLeft  || orientation == UIDeviceOrientationLandscapeRight){
            CGFloat temp = width;
            width = height;
            height = temp;
        }
    }
    CGSize size = CGSizeMake(width, height);
    return size;
}

@end



