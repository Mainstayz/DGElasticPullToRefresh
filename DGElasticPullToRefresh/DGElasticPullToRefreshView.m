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

#import "DGElasticPullToRefreshExtension.h"
#import "DGElasticPullToRefreshLoadingViewCircle.h"
#import "DGElasticPullToRefreshView.h"

static NSString* keyPathForContentOffset = @"contentOffset";
static NSString* keyPathForContentInset = @"contentInset";
static NSString* keyPathForFrame = @"frame";
static NSString* keyPathForPanGestureRecognizerState = @"panGestureRecognizer.state";

@interface DGElasticPullToRefreshView ()
@property (nonatomic, assign) DGElasticPullToRefreshState state;
@property (nonatomic, assign) CGFloat originalContentInsetTop;
@property (nonatomic, strong) CAShapeLayer* shapeLayer;
@property (nonatomic, strong) CADisplayLink* displayLink;

@property (nonatomic, strong) UIView* bounceAnimationHelperView;

@property (nonatomic, strong) UIView* cControlPointView;
@property (nonatomic, strong) UIView* l1ControlPointView;
@property (nonatomic, strong) UIView* l2ControlPointView;
@property (nonatomic, strong) UIView* l3ControlPointView;

@property (nonatomic, strong) UIView* r1ControlPointView;
@property (nonatomic, strong) UIView* r2ControlPointView;
@property (nonatomic, strong) UIView* r3ControlPointView;

@end
@implementation DGElasticPullToRefreshView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initialize];
        
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink.paused = YES;

        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
        self.shapeLayer.fillColor = [UIColor blackColor].CGColor;
        [self.shapeLayer setActions:@{ @"path" : [NSNull null],
            @"position" : [NSNull null],
            @"bounds" : [NSNull null]
        }];
        [self.layer addSublayer:self.shapeLayer];
        [self addSubview:_bounceAnimationHelperView];
        [self addSubview:_l1ControlPointView];
        [self addSubview:_l2ControlPointView];
        [self addSubview:_l3ControlPointView];
        [self addSubview:_cControlPointView];
        [self addSubview:_r1ControlPointView];
        [self addSubview:_r2ControlPointView];
        [self addSubview:_r3ControlPointView];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
    NSAssert(NO, @"init(coder:) has not been implemented");
    self = [super initWithCoder:aDecoder];
    return nil;
}

#pragma mark -initialize

- (void)initialize
{
    _state = DGElasticPullToRefreshStateStoped;
    _originalContentInsetTop = 0.0;
    _observing = NO;
    _fillColor = [UIColor clearColor];

    _waveMaxHeight = 70.0;
    _minOffsetToPull = 95.0;
    _loadingContentInset = 50.0;
    _loadingViewSize = 30.0;
    
    _bounceAnimationHelperView = [UIView new];
    _cControlPointView = [UIView new];
    _l1ControlPointView = [UIView new];
    _l2ControlPointView = [UIView new];
    _l3ControlPointView = [UIView new];
    _r1ControlPointView = [UIView new];
    _r2ControlPointView = [UIView new];
    _r3ControlPointView = [UIView new];
}

#pragma mark -

- (void)disassociateDisplayLink
{
    [self.displayLink invalidate];
}

- (void)dealloc
{
    self.observing = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{

    if ([keyPath isEqualToString:keyPathForContentOffset]) {

        CGFloat newContentOffsetY = [change[NSKeyValueChangeNewKey] CGPointValue].y;
        UIScrollView* scrollView = [self scrollView];

        if (newContentOffsetY && scrollView) {
            if ([self pullToRefreshStateIsAnyOfValue:@[ @(DGElasticPullToRefreshStateLoading), @(DGElasticPullToRefreshStateAnimatingToStopped) ]] && newContentOffsetY < -scrollView.contentInset.top) {
                [scrollView setContentOffsetY:-scrollView.contentInset.top];
            }
            else {
                [self scrollViewDidChangeContentOffset:scrollView.dragging];
            }
            [self layoutSubviews];
        }
    }

    else if ([keyPath isEqualToString:keyPathForContentInset]) {
        CGFloat newContentInsetTop = [change[NSKeyValueChangeNewKey] UIEdgeInsetsValue].top;
        self.originalContentInsetTop = newContentInsetTop;
    }
    else if ([keyPath isEqualToString:keyPathForFrame]) {
        [self layoutSubviews];
    }
    else if ([keyPath isEqualToString:keyPathForPanGestureRecognizerState]) {
        NSInteger state = [self scrollView].panGestureRecognizer.state;
        if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateFailed || state == UIGestureRecognizerStateCancelled) {
            [self scrollViewDidChangeContentOffset:NO];
        }
    }
}

#pragma mark - Notifications
- (void)applicationWillEnterForeground
{
    if (self.state == DGElasticPullToRefreshStateLoading) {
        [self layoutSubviews];
    }
}
#pragma mark - PublicMethods
- (UIScrollView*)scrollView
{
    UIView* view = self.superview;
    if ([view isKindOfClass:[UIScrollView class]]) {
        return (UIScrollView*)view;
    }
    return nil;
}
- (void)stopLoading
{
    if (self.state == DGElasticPullToRefreshStateAnimatingToStopped) {
        return;
    }
    self.state = DGElasticPullToRefreshStateAnimatingToStopped;
}
#pragma mark - PrivateMethods
- (BOOL)pullToRefreshStateIsAnyOfValue:(NSArray*)values
{
    return [values containsObject:@(self.state)];
}
- (BOOL)isAnimating
{
    return [self pullToRefreshStateIsAnyOfValue:@[ @(DGElasticPullToRefreshStateAnimatingBounce), @(DGElasticPullToRefreshStateAnimatingToStopped) ]];
}
- (CGFloat)actualContentOffsetY
{
    UIScrollView* scrollView = [self scrollView];
    if (!scrollView) {
        return 0;
    }
    return MAX(-scrollView.contentInset.top - scrollView.contentOffset.y, 0);
}
- (CGFloat)currentHeight
{
    UIScrollView* scrollView = [self scrollView];
    if (!scrollView) {
        return 0;
    }
    return MAX(-self.originalContentInsetTop - scrollView.contentOffset.y, 0);
}
- (CGFloat)currentWaveHeight
{
    return MIN(self.bounds.size.height / 3.0 * 1.6, self.waveMaxHeight);
}

- (CGPathRef)currentPath
{
    CGFloat width = [self scrollView].bounds.size.width ?: 0;

    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    BOOL animating = [self isAnimating];

    [bezierPath moveToPoint:CGPointMake(0, 0)];

    [bezierPath addLineToPoint:CGPointMake(0, [self.l3ControlPointView dg_center:animating].y)];
    [bezierPath addCurveToPoint:[self.l1ControlPointView dg_center:animating]
                  controlPoint1:[self.l3ControlPointView dg_center:animating]
                  controlPoint2:[self.l2ControlPointView dg_center:animating]];

    [bezierPath addCurveToPoint:[self.r1ControlPointView dg_center:animating]
                  controlPoint1:[self.cControlPointView dg_center:animating]
                  controlPoint2:[self.r1ControlPointView dg_center:animating]];

    [bezierPath addCurveToPoint:[self.r3ControlPointView dg_center:animating]
                  controlPoint1:[self.r1ControlPointView dg_center:animating]
                  controlPoint2:[self.r2ControlPointView dg_center:animating]];

    [bezierPath addLineToPoint:CGPointMake(width, 0)];

    [bezierPath closePath];

    return bezierPath.CGPath;
}

- (void)scrollViewDidChangeContentOffset:(BOOL)dragging
{
    CGFloat offsetY = [self actualContentOffsetY];
    if (self.state == DGElasticPullToRefreshStateStoped && dragging) {
        self.state = DGElasticPullToRefreshDragging;
    }
    else if (self.state == DGElasticPullToRefreshDragging && dragging == NO) {
        if (offsetY >= self.minOffsetToPull) {
            self.state = DGElasticPullToRefreshStateAnimatingBounce;
        }
        else {
            self.state = DGElasticPullToRefreshStateStoped;
        }
    }
    else if ([self pullToRefreshStateIsAnyOfValue:@[ @(DGElasticPullToRefreshDragging), @(DGElasticPullToRefreshStateStoped) ]]) {
        CGFloat pullProgress = offsetY / self.minOffsetToPull;
        [self.loadingView setPullProgress:pullProgress];
    }
}
- (void)resetScrollViewContentInset:(BOOL)shouldAddObserverWhenFinished animated:(BOOL)animated completion:(void (^)())completion
{
    UIScrollView* scrollView = [self scrollView];
    if (!scrollView) {
        return;
    }

    UIEdgeInsets contentInset = scrollView.contentInset;
    contentInset.top = self.originalContentInsetTop;

    if (self.state == DGElasticPullToRefreshStateAnimatingBounce) {
        contentInset.top += [self currentHeight];
    }
    else if (self.state == DGElasticPullToRefreshStateLoading) {
        contentInset.top += self.loadingContentInset;
    }

    [scrollView dg_removeObserver:self forKeyPath:keyPathForContentInset];

    void (^completionBlock)() = ^{
        if (shouldAddObserverWhenFinished && self.observing) {
            [scrollView dg_addObserver:self forKeyPath:keyPathForContentInset];
        }
        if (completion) {
            completion();
        }
    };
    if (animated) {
        [self startDisplayLink];
        [UIView animateWithDuration:0.4 animations:^{
            scrollView.contentInset = contentInset;
        }
            completion:^(BOOL finished) {
                [self stopDisplayLink];
                completionBlock();
            }];
    }
    else {
        scrollView.contentInset = contentInset;
        completionBlock();
    }
}
- (void)animateBounce
{
    UIScrollView* scrollView = [self scrollView];
    if (!scrollView) {
        return;
    }

    [self resetScrollViewContentInset:NO animated:NO completion:nil];

    CGFloat centerY = self.loadingContentInset;
    CGFloat duration = 0.9;

    scrollView.scrollEnabled = NO;
    [self startDisplayLink];
    [scrollView dg_removeObserver:self forKeyPath:keyPathForContentOffset];
    [scrollView dg_removeObserver:self forKeyPath:keyPathForContentInset];

    [UIView animateWithDuration:duration
        delay:0.0
        usingSpringWithDamping:0.43
        initialSpringVelocity:0.0
        options:0
        animations:^{
            [self.cControlPointView setCenterY:centerY];
            [self.l1ControlPointView setCenterY:centerY];
            [self.l2ControlPointView setCenterY:centerY];
            [self.l3ControlPointView setCenterY:centerY];
            [self.r1ControlPointView setCenterY:centerY];
            [self.r2ControlPointView setCenterY:centerY];
            [self.r3ControlPointView setCenterY:centerY];

        }
        completion:^(BOOL finished) {
            [self stopDisplayLink];
            [self resetScrollViewContentInset:YES animated:NO completion:nil];
            UIScrollView* strongScrollView = [self scrollView];
            if (strongScrollView) {
                [strongScrollView dg_addObserver:self forKeyPath:keyPathForContentOffset];
                strongScrollView.scrollEnabled = YES;
            }

            self.state = DGElasticPullToRefreshStateLoading;
        }];
    self.bounceAnimationHelperView.center = CGPointMake(0, self.originalContentInsetTop + [self currentHeight]);
    [UIView animateWithDuration:duration * 0.4 animations:^{
        CGFloat contentInsetTop = self.originalContentInsetTop;
        self.bounceAnimationHelperView.center = CGPointMake(0, contentInsetTop + self.loadingContentInset);

    }completion:nil];
}
#pragma mark - CADisplayLink

- (void)startDisplayLink
{
    self.displayLink.paused = NO;
}
- (void)stopDisplayLink
{
    self.displayLink.paused = YES;
}
- (void)displayLinkTick
{
    CGFloat width = self.bounds.size.width;
    CGFloat height = 0.0;
    if (self.state == DGElasticPullToRefreshStateAnimatingBounce) {
        UIScrollView* scrollView = [self scrollView];
        if (!scrollView) {
            return;
        }

        [scrollView setContentInsetTop:[self.bounceAnimationHelperView dg_center:[self isAnimating]].y];
        [scrollView setContentOffsetY:-scrollView.contentInset.top];

        height = scrollView.contentInset.top - self.originalContentInsetTop;

        self.frame = CGRectMake(0, -height - 1.0, width, height);
    }
    else if (self.state == DGElasticPullToRefreshStateAnimatingToStopped) {
        height = [self actualContentOffsetY];
    }
    self.shapeLayer.frame = CGRectMake(0, 0, width, height);
    self.shapeLayer.path = [self currentPath];
    [self layoutLoadingView];
}
#pragma mark - Layout
- (void)layoutLoadingView
{

    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;

    CGFloat loadingViewSize = self.loadingViewSize;

    CGFloat minOriginY = (self.loadingContentInset - loadingViewSize) / 2.0;

    CGFloat originY = MAX(MIN((height - loadingViewSize) / 2.0, minOriginY), 0);

    self.loadingView.frame = CGRectMake((width - loadingViewSize) / 2.0, originY, loadingViewSize, loadingViewSize);

    self.loadingView.maskLayer.frame = [self convertRect:self.shapeLayer.frame toView:self.loadingView];

    self.loadingView.maskLayer.path = self.shapeLayer.path;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    UIScrollView* scrollView = [self scrollView];
    if (scrollView && self.state != DGElasticPullToRefreshStateAnimatingBounce) {
        CGFloat width = scrollView.bounds.size.width;
        CGFloat height = [self currentHeight];

        self.frame = CGRectMake(0, -height, width, height);

        if (self.state == DGElasticPullToRefreshStateLoading || self.state == DGElasticPullToRefreshStateAnimatingToStopped) {
            self.cControlPointView.center = CGPointMake(width / 2.0, height);
            self.l1ControlPointView.center = CGPointMake(0, height);
            self.l2ControlPointView.center = CGPointMake(0, height);
            self.l3ControlPointView.center = CGPointMake(0, height);
            self.r1ControlPointView.center = CGPointMake(width, height);
            self.r2ControlPointView.center = CGPointMake(width, height);
            self.r3ControlPointView.center = CGPointMake(width, height);
        }
        else {
            CGFloat locationX = [scrollView.panGestureRecognizer locationInView:scrollView].x;

            CGFloat waveHeight = [self currentWaveHeight];
            CGFloat baseHeight = self.bounds.size.height - waveHeight;

            CGFloat minLeftX = MIN((locationX - width / 2.0) * 0.28, 0);
            CGFloat maxRightX = MAX(width + (locationX - width / 2.0) * 0.28, width);

            CGFloat leftPartWidth = locationX - minLeftX;
            CGFloat rightPartWidth = maxRightX - locationX;

            self.cControlPointView.center = CGPointMake(locationX, baseHeight + waveHeight * 1.36);
            self.l1ControlPointView.center = CGPointMake(minLeftX + leftPartWidth * 0.71, baseHeight + waveHeight * 0.64);
            self.l2ControlPointView.center = CGPointMake(minLeftX + leftPartWidth * 0.44, baseHeight);
            self.l3ControlPointView.center = CGPointMake(minLeftX, baseHeight);
            self.r1ControlPointView.center = CGPointMake(maxRightX - rightPartWidth * 0.71, baseHeight + waveHeight * 0.64);
            self.r2ControlPointView.center = CGPointMake(maxRightX - (rightPartWidth * 0.44), baseHeight);
            self.r3ControlPointView.center = CGPointMake(maxRightX, baseHeight);
        }
        self.shapeLayer.frame = CGRectMake(0, 0, width, height);
        self.shapeLayer.path = [self currentPath];

        [self layoutLoadingView];
    }
}

#pragma mark - setter getter

- (void)setState:(DGElasticPullToRefreshState)state
{
    DGElasticPullToRefreshState previousValue = _state;
    _state = state;

    if (previousValue == DGElasticPullToRefreshDragging && state == DGElasticPullToRefreshStateAnimatingBounce) {
        [self.loadingView startAnimating];
        [self animateBounce];
    }
    else if (state == DGElasticPullToRefreshStateLoading && _actionHandler != nil) {
        if (self.actionHandler) {
            self.actionHandler();
        }
    }
    else if (state == DGElasticPullToRefreshStateAnimatingToStopped) {
        __weak typeof (self)wself = self;
        [wself resetScrollViewContentInset:YES animated:YES completion:^{
            wself.state = DGElasticPullToRefreshStateStoped;
        }];
    }
    else if (state == DGElasticPullToRefreshStateStoped) {
        [self.loadingView stopLoading];
    }
}
- (void)setOriginalContentInsetTop:(CGFloat)originalContentInsetTop
{
    _originalContentInsetTop = originalContentInsetTop;

    [self layoutSubviews];
}

- (void)setLoadingView:(DGElasticPullToRefreshLoadingView*)loadingView
{
    if (_loadingView) {
        [_loadingView removeFromSuperview];
    }
    if (loadingView) {
        [self addSubview:loadingView];
    }

    _loadingView = loadingView;
}
- (void)setObserving:(BOOL)observing
{
    _observing = observing;
    UIScrollView* scrollView = [self scrollView];
    if (!scrollView) {
        return;
    }

    if (_observing) {
        [scrollView dg_addObserver:self forKeyPath:keyPathForContentOffset];
        [scrollView dg_addObserver:self forKeyPath:keyPathForContentInset];
        [scrollView dg_addObserver:self forKeyPath:keyPathForFrame];
        [scrollView dg_addObserver:self forKeyPath:keyPathForPanGestureRecognizerState];
    }
    else {
        [scrollView dg_removeObserver:self forKeyPath:keyPathForContentOffset];
        [scrollView dg_removeObserver:self forKeyPath:keyPathForContentInset];
        [scrollView dg_removeObserver:self forKeyPath:keyPathForFrame];
        [scrollView dg_removeObserver:self forKeyPath:keyPathForPanGestureRecognizerState];
    }
}
- (void)setFillColor:(UIColor*)fillColor
{
    _fillColor = fillColor;

    self.shapeLayer.fillColor = _fillColor.CGColor;
}
@end