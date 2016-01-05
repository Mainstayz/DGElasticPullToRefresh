//
//  DGElasticPullToRefreshLoadingView.h
//  TSPullToRefresh
//
//  Created by 何宗柱 on 15/12/31.
//  Copyright © 2015年 TuShu72. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGElasticPullToRefreshLoadingView : UIView
@property (nonatomic, strong) CAShapeLayer *maskLayer;
- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)setPullProgress:(CGFloat)progress;
- (void)startAnimating;
- (void)stopLoading;
@end
