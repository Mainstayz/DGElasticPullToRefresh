//
//  DGElasticPullToRefreshView.h
//  TSPullToRefresh
//
//  Created by 何宗柱 on 16/1/4.
//  Copyright © 2016年 TuShu72. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DGElasticPullToRefreshLoadingView;
typedef NS_ENUM(NSInteger,DGElasticPullToRefreshState){
    DGElasticPullToRefreshStateStoped = 2000,
    DGElasticPullToRefreshDragging = 2001,
    DGElasticPullToRefreshStateAnimatingBounce = 2002,
    DGElasticPullToRefreshStateLoading = 2003,
    DGElasticPullToRefreshStateAnimatingToStopped = 2004
    
};

@interface DGElasticPullToRefreshView : UIView
@property (nonatomic, copy) void(^actionHandler)();
@property (nonatomic, strong) DGElasticPullToRefreshLoadingView *loadingView;
@property (nonatomic, assign) BOOL observing;
@property (nonatomic, strong) UIColor *fillColor;
- (UIScrollView *)scrollView;
- (void)disassociateDisplayLink;
- (void)stopLoading;
@end
