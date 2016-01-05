//
//  DGElasticPullToRefreshExtensions.m
//  TSPullToRefresh
//
//  Created by 何宗柱 on 15/12/31.
//  Copyright © 2015年 TuShu72. All rights reserved.
//

#import "DGElasticPullToRefreshExtensions.h"

#import <objc/runtime.h>

static NSString *observersArray = @"observers";
static NSString *pullToRefreshViewKey = @"pullToRefreshView";

@implementation NSObject (Extension)
- (NSMutableArray *)dg_observers{
    id observers = objc_getAssociatedObject(self, &observersArray);
    if (observers) {
        return observers;
    }else{
        NSMutableArray *observers = [NSMutableArray array];
        [self setDg_observers:observers];
        return observers;
    }
}

- (void)setDg_observers:(NSMutableArray *)dg_observers{
    objc_setAssociatedObject(self, &observersArray, dg_observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dg_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    NSDictionary *observerInfo = @{keyPath:observer};    
    if ([self.dg_observers indexOfObject:observerInfo] == NSNotFound) {
        [self.dg_observers addObject:observerInfo];
        [self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    }
}
- (void)dg_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    NSDictionary *observerInfo = @{keyPath:observer};
    if ([self.dg_observers containsObject:observerInfo]) {
        [self.dg_observers removeObject:observerInfo];
        [self removeObserver:observer forKeyPath:keyPath];
    }
}
@end

@implementation UIScrollView (Extension)

@dynamic contentInsetTop,contentInsetLeft,contentInsetBottom,contentInsetRight,contentOffsetX,contentOffsetY;


- (void)setContentInsetTop:(CGFloat)contentInsetTop{
    self.contentInset = UIEdgeInsetsMake(contentInsetTop, self.contentInset.left, self.contentInset.bottom, self.contentInset.right);
}
- (CGFloat)contentInsetTop{
    return self.contentInset.top;
}

- (void)setContentInsetLeft:(CGFloat)contentInsetLeft{
     self.contentInset = UIEdgeInsetsMake(self.contentInset.top, contentInsetLeft, self.contentInset.bottom, self.contentInset.right);
}
- (CGFloat)contentInsetLeft{
    return self.contentInset.left;
}

- (void)setContentInsetBottom:(CGFloat)contentInsetBottom{
     self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, contentInsetBottom, self.contentInset.right);
}
- (CGFloat)contentInsetBottom{
    return self.contentInset.bottom;
}

- (void)setContentInsetRight:(CGFloat)contentInsetRight{
     self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, self.contentInset.bottom, contentInsetRight);
}
- (CGFloat)contentInsetRight{
    return self.contentInset.right;
}

- (void)setContentOffsetX:(CGFloat)contentOffsetX{
    self.contentOffset = CGPointMake(contentOffsetX, self.contentOffset.y);
}
- (CGFloat)contentOffsetX{
    return self.contentOffset.x;
}

- (void)setContentOffsetY:(CGFloat)contentOffsetY{
    self.contentOffset = CGPointMake(self.contentOffset.x, contentOffsetY);
}
- (CGFloat)contentOffsetY{
    return self.contentOffset.y;
}


- (DGElasticPullToRefreshView *)pullToRefreshView{
    return objc_getAssociatedObject(self, &pullToRefreshViewKey);
}
- (void)setPullToRefreshView:(DGElasticPullToRefreshView *)pullToRefreshView{
    objc_setAssociatedObject(self, &pullToRefreshViewKey, pullToRefreshView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dg_addPullToRefreshWithActionHandler:(void (^)())actionHandler loadingView:(DGElasticPullToRefreshLoadingView *)loadingView{
    self.multipleTouchEnabled = NO;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    
    DGElasticPullToRefreshView *pullToRefreshView = [[DGElasticPullToRefreshView alloc] init];
    self.pullToRefreshView = pullToRefreshView;
    pullToRefreshView.actionHandler = actionHandler;
    pullToRefreshView.loadingView = loadingView;
    [self addSubview:pullToRefreshView];
    
    pullToRefreshView.observing = YES;;
}
- (void)dg_removePullToRefresh{
    [self.pullToRefreshView disassociateDisplayLink];
    self.pullToRefreshView.observing = NO;
    [self.pullToRefreshView removeFromSuperview];
}
- (void)dg_setPullToRefreshBackgroundColor:(UIColor *)color{
    self.pullToRefreshView.backgroundColor = color;
}
- (void)dg_setPullToRefreshFillColor:(UIColor *)color{
    self.pullToRefreshView.fillColor = color;
}
- (void)dg_stopLoading{
    [self.pullToRefreshView stopLoading];
}
@end


@implementation UIView (Extension)
@dynamic centerX,centerY;
- (void)setCenterX:(CGFloat)centerX{
    self.center = CGPointMake(centerX, self.center.y);
}
- (CGFloat)centerX{
    return self.center.x;
}

-(void)setCenterY:(CGFloat)centerY{
    self.center = CGPointMake(self.center.x, centerY);
}
- (CGFloat)centerY{
    return self.center.y;
}

- (CGPoint)dg_center:(BOOL)usePresentationLayerIfPossible{
    CALayer *persentationLayer = self.layer.presentationLayer;
    if (usePresentationLayerIfPossible && persentationLayer) {
        return persentationLayer.position;
    }
    return self.center;
    
}
@end

@implementation UIPanGestureRecognizer (Extension)

- (void)dg_resign{
    self.enabled = NO;
    self.enabled = YES;
}

@end