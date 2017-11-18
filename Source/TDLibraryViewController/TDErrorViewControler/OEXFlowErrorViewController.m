//
//  OEXFlowErrorViewController.m
//  edXVideoLocker
//
//  Created by Rahul Varma on 28/05/14.
//  Copyright (c) 2014 edX. All rights reserved.
//

#import "OEXFlowErrorViewController.h"

#import "edX-Swift.h"

#define ERRORVIEW_X 0
#define ERRORVIEW_Y -98
#define ERRORVIEW_HEIGHT 100

@interface OEXFlowErrorViewController ()

- (void)setErrorTitle:(NSString*)title WithMessage:(NSString*)message;

@property (nonatomic, assign) CGRect parentViewFrame;

@end

static OEXFlowErrorViewController* _sharedInterface = nil;

@implementation OEXFlowErrorViewController

+ (id)sharedInstance {
    if(!_sharedInterface) {
        _sharedInterface = [[OEXFlowErrorViewController alloc] init];
    }

    return _sharedInterface;
}

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        // Custom initialization
    }
    return self;
}

#pragma mark Public Actions

- (void)showErrorWithTitle:(NSString*)title message:(NSString*)message onViewController:(UIView*)View shouldHide:(BOOL)hide {
    
    //Remove previous instance and animation
    [self removeSelfFromSuperView];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    //Set initial frame
    self.parentViewFrame = View.frame;
    _sharedInterface.view.frame = CGRectMake(_parentViewFrame.origin.x,
                                             _parentViewFrame.origin.y - ERRORVIEW_HEIGHT,
                                             SCREEN_WIDTH,
                                             ERRORVIEW_HEIGHT);
    [View addSubview:_sharedInterface.view];

    //Pass data
    [_sharedInterface setErrorTitle:title WithMessage:message];

    //Animate
    [_sharedInterface showHidingAutomatically:hide];
}

#pragma Logic

- (void)setErrorTitle:(NSString*)title WithMessage:(NSString*)message {
    self.lbl_ErrorTitle.text = title;
    self.lbl_ErrorMessage.text = message;
}

#pragma mark Animation

// Animate and Show the error controller by sliding From the Top of the view
- (void)showHidingAutomatically:(BOOL)shouldHide {
    _sharedInterface.view.hidden = NO;
    
    [UIView animateWithDuration:ANI_DURATION
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        _sharedInterface.view.frame = CGRectMake(_parentViewFrame.origin.x,
                                                 _parentViewFrame.origin.y,
                                                 SCREEN_WIDTH,
                                                 ERRORVIEW_HEIGHT);
    } completion:^(BOOL finished) {
        if(shouldHide) {
            [self performSelector:@selector(animationUp) withObject:nil afterDelay:ANI_ERROR_TIMEOUT];
        }
    }];
}

// Animates and Hide the error controller by sliding To the Top of the view
- (void)animationUp {
    [UIView animateWithDuration:ANI_DURATION
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        _sharedInterface.view.frame = CGRectMake(_parentViewFrame.origin.x,
                                                 _parentViewFrame.origin.y - ERRORVIEW_HEIGHT,
                                                 SCREEN_WIDTH,
                                                 ERRORVIEW_HEIGHT);
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _sharedInterface.view.hidden = YES;
        });
    }];
}

- (void)removeSelfFromSuperView {
    [self.view removeFromSuperview];
}

- (void)showNoConnectionErrorOnView:(UIView *)view {
    [self showErrorWithTitle:TDLocalizeSelect(@"NETWORK_NOT_AVAILABLE_TITLE", nil)
                     message:TDLocalizeSelect(@"NETWORK_NOT_AVAILABLE_MESSAGE", nil)
            onViewController:view
                  shouldHide:YES];
}

@end
