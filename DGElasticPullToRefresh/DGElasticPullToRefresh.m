/*

 The MIT License (MIT)

 Copyright (c) 2016 Mainstayz

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

 */

#import "DGElasticPullToRefresh.h"
#import <objc/runtime.h>

static NSString* pullToRefreshViewKey = @"pullToRefreshView";

@implementation UIScrollView (DGElasticPullToRefresh)

- (DGElasticPullToRefreshView*)pullToRefreshView
{
    return objc_getAssociatedObject(self, &pullToRefreshViewKey);
}
- (void)setPullToRefreshView:(DGElasticPullToRefreshView*)pullToRefreshView
{
    objc_setAssociatedObject(self, &pullToRefreshViewKey, pullToRefreshView,
        OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)dg_addPullToRefreshWithWaveMaxHeight:(CGFloat)waveMaxHeight
                             minOffsetToPull:(CGFloat)minOffsetToPull
                         loadingContentInset:(CGFloat)loadingContentInset
                             loadingViewSize:(CGFloat)loadingViewSize
                               actionHandler:(void (^)())actionHandler
                                 loadingView:(DGElasticPullToRefreshLoadingView *)loadingView{
    
    self.multipleTouchEnabled = NO;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    DGElasticPullToRefreshView* pullToRefreshView =[[DGElasticPullToRefreshView alloc] init];
    
    pullToRefreshView.waveMaxHeight = waveMaxHeight;
    pullToRefreshView.minOffsetToPull = minOffsetToPull;
    pullToRefreshView.loadingContentInset = loadingContentInset;
    pullToRefreshView.loadingViewSize = loadingViewSize;
    self.pullToRefreshView = pullToRefreshView;
    pullToRefreshView.actionHandler = actionHandler;
    pullToRefreshView.loadingView = loadingView;
    [self addSubview:pullToRefreshView];
    
    pullToRefreshView.observing = YES;
    
}
- (void)dg_addPullToRefreshWithActionHandler:(void (^)())actionHandler
                                 loadingView:(DGElasticPullToRefreshLoadingView*)loadingView
{
    [self dg_addPullToRefreshWithWaveMaxHeight:70.0 minOffsetToPull:95.0 loadingContentInset:50.0 loadingViewSize:30.0 actionHandler:actionHandler loadingView:loadingView];
}
- (void)dg_removePullToRefresh
{
    [self.pullToRefreshView disassociateDisplayLink];
    self.pullToRefreshView.observing = NO;
    [self.pullToRefreshView removeFromSuperview];
}
- (void)dg_setPullToRefreshBackgroundColor:(UIColor*)color
{
    self.pullToRefreshView.backgroundColor = color;
}
- (void)dg_setPullToRefreshFillColor:(UIColor*)color
{
    self.pullToRefreshView.fillColor = color;
}
- (void)dg_stopLoading
{
    [self.pullToRefreshView stopLoading];
}
@end
