//
//  DGElasticPullToRefreshLoadingView.m
//  TSPullToRefresh
//
//  Created by 何宗柱 on 15/12/31.
//  Copyright © 2015年 TuShu72. All rights reserved.
//

#import "DGElasticPullToRefreshLoadingView.h"

@implementation DGElasticPullToRefreshLoadingView
- (CAShapeLayer *)maskLayer{
    if (_maskLayer == nil) {
        _maskLayer = [[CAShapeLayer alloc] init];
        _maskLayer.backgroundColor = [UIColor clearColor].CGColor;
        _maskLayer.fillColor = [UIColor blackColor].CGColor;
        _maskLayer.actions = @{@"path":[NSNull null],
                               @"position":[NSNull null],
                               @"bounds":[NSNull null]
                               };
        self.layer.mask = _maskLayer;
    }
    return _maskLayer;
}
- (instancetype)init{
    if (self = [super initWithFrame:CGRectZero]) {
        
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:CGRectZero]) {
        
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    NSAssert(NO, @"init(coder:) has not been implemented");
    return nil;
}
- (void)setPullProgress:(CGFloat)progress{
    
}
- (void)startAnimating{
    
}
- (void)stopLoading{
    
}
@end
