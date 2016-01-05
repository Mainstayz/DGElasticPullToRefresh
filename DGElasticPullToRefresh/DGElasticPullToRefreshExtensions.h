//
//  DGElasticPullToRefreshExtensions.h
//  TSPullToRefresh
//
//  Created by 何宗柱 on 15/12/31.
//  Copyright © 2015年 TuShu72. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGElasticPullToRefreshView.h"
#import "DGElasticPullToRefreshLoadingView.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"

@interface NSObject (Extension)
@property (nonatomic, strong) NSMutableArray *dg_observers;

- (void)dg_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
- (void)dg_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
@end


@interface UIScrollView (Extension)

@property (nonatomic) CGFloat contentInsetTop;
@property (nonatomic) CGFloat contentInsetLeft;
@property (nonatomic) CGFloat contentInsetBottom;
@property (nonatomic) CGFloat contentInsetRight;

@property (nonatomic) CGFloat contentOffsetX;
@property (nonatomic) CGFloat contentOffsetY;

@property (nonatomic, strong) DGElasticPullToRefreshView *pullToRefreshView;

- (void)dg_addPullToRefreshWithActionHandler:(void (^)())actionHandler loadingView:(DGElasticPullToRefreshLoadingView *)DGElasticPullToRefreshLoadingView;
- (void)dg_removePullToRefresh;
- (void)dg_setPullToRefreshBackgroundColor:(UIColor *)color;
- (void)dg_setPullToRefreshFillColor:(UIColor *)color;
- (void)dg_stopLoading;

@end

@interface UIView (Extension)
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

- (CGPoint)dg_center:(BOOL)usePresentationLayerIfPossible;
@end


@interface UIPanGestureRecognizer (Extension)
- (void)dg_resign;
@end

