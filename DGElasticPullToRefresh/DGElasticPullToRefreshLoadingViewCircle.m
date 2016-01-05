//
//  DGElasticPullToRefreshLoadingViewCircle.m
//  TSPullToRefresh
//
//  Created by 何宗柱 on 15/12/31.
//  Copyright © 2015年 TuShu72. All rights reserved.
//

#import "DGElasticPullToRefreshLoadingViewCircle.h"

static NSString *kRotationAnimation = @"kRotationAnimation";

@interface DGElasticPullToRefreshLoadingViewCircle ()
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) CATransform3D identityTransform;
@end




@implementation DGElasticPullToRefreshLoadingViewCircle


- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _shapeLayer  = [CAShapeLayer layer];
        _shapeLayer.lineWidth = 1.0;
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        _shapeLayer.strokeColor = self.tintColor.CGColor;
        _shapeLayer.actions = @{@"strokeEnd":[NSNull null],
                                    @"transform":[NSNull null]};
        _shapeLayer.anchorPoint = CGPointMake(0.5,0.5);
        [self.layer addSublayer:_shapeLayer];
        
        _identityTransform = CATransform3DIdentity;
        _identityTransform.m34 = (1/-500.0);
        _identityTransform = CATransform3DRotate(_identityTransform, toRadians(-90.0), 0.0, 0.0, 1.0);

    }
    return self;
}

- (void)setPullProgress:(CGFloat)progress{
    [super setPullProgress:progress];
    self.shapeLayer.strokeEnd = MIN(0.9 * progress, 0.9);
    
    if (progress > 1.0) {
        CGFloat degrees = ((progress - 1) * 200);
        self.shapeLayer.transform = CATransform3DRotate(self.identityTransform, toRadians(degrees), 0, 0, 1);
        
    }else{
        self.shapeLayer.transform = self.identityTransform;
        
    }
}

- (void)startAnimating{
    [super startAnimating];
    if ([self.shapeLayer animationForKey:kRotationAnimation] != nil) {
        return;
    }
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(2 * M_PI + [self currentDegree]);
    rotationAnimation.duration = 1.0;
    rotationAnimation.repeatCount = MAXFLOAT;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    
    [self.shapeLayer addAnimation:rotationAnimation forKey:kRotationAnimation];

}

- (void)stopLoading{
    [super stopLoading];
    [self.shapeLayer removeAnimationForKey:kRotationAnimation];
}

- (CGFloat)currentDegree{
    return [[self.shapeLayer valueForKeyPath:@"transform.rotation.z"] floatValue];
}

- (void)tintColorDidChange{
    [super tintColorDidChange];
    
    self.shapeLayer.strokeColor = self.tintColor.CGColor;
    
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.shapeLayer.frame = self.bounds;
    CGFloat inset = self.shapeLayer.lineWidth / 2.0;
    self.shapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.shapeLayer.bounds, inset, inset)].CGPath;
}
#pragma mark - helpsMethod

static float toRadians(float value){
    
    return (value * (float)M_PI)/180.0;
}

static float toDegrees(float value){
    return value * 180 / (float)M_PI;
}

#pragma mark - LazyLoad

@end
