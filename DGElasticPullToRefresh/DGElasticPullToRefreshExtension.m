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
#import <objc/runtime.h>

static NSString* observersArray = @"observers";

@implementation NSObject (DGElasticExtension)
- (NSMutableArray*)dg_observers
{
    id observers = objc_getAssociatedObject(self, &observersArray);
    if (observers) {
        return observers;
    }
    else {
        NSMutableArray* observers = [NSMutableArray array];
        [self setDg_observers:observers];
        return observers;
    }
}

- (void)setDg_observers:(NSMutableArray*)dg_observers
{
    objc_setAssociatedObject(self, &observersArray, dg_observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dg_addObserver:(NSObject*)observer forKeyPath:(NSString*)keyPath
{
    NSDictionary* observerInfo = @{ keyPath : observer };
    if ([self.dg_observers indexOfObject:observerInfo] == NSNotFound) {
        [self.dg_observers addObject:observerInfo];
        [self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    }
}
- (void)dg_removeObserver:(NSObject*)observer forKeyPath:(NSString*)keyPath
{
    NSDictionary* observerInfo = @{ keyPath : observer };
    if ([self.dg_observers containsObject:observerInfo]) {
        [self.dg_observers removeObject:observerInfo];
        [self removeObserver:observer forKeyPath:keyPath];
    }
}
@end

@implementation UIView (DGElasticExtension)

- (void)setCenterX:(CGFloat)centerX
{
    self.center = CGPointMake(centerX, self.center.y);
}
- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    self.center = CGPointMake(self.center.x, centerY);
}
- (CGFloat)centerY
{
    return self.center.y;
}
- (CGPoint)dg_center:(BOOL)usePresentationLayerIfPossible
{
    CALayer* persentationLayer = self.layer.presentationLayer;
    if (usePresentationLayerIfPossible && persentationLayer) {
        return persentationLayer.position;
    }
    return self.center;
}
@end

@implementation UIScrollView (DGElasticExtension)

- (void)setContentInsetTop:(CGFloat)contentInsetTop
{
    self.contentInset = UIEdgeInsetsMake(contentInsetTop, self.contentInset.left, self.contentInset.bottom, self.contentInset.right);
}
- (CGFloat)contentInsetTop
{
    return self.contentInset.top;
}

- (void)setContentInsetLeft:(CGFloat)contentInsetLeft
{
    self.contentInset = UIEdgeInsetsMake(self.contentInset.top, contentInsetLeft, self.contentInset.bottom, self.contentInset.right);
}
- (CGFloat)contentInsetLeft
{
    return self.contentInset.left;
}

- (void)setContentInsetBottom:(CGFloat)contentInsetBottom
{
    self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, contentInsetBottom, self.contentInset.right);
}
- (CGFloat)contentInsetBottom
{
    return self.contentInset.bottom;
}

- (void)setContentInsetRight:(CGFloat)contentInsetRight
{
    self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, self.contentInset.bottom, contentInsetRight);
}
- (CGFloat)contentInsetRight
{
    return self.contentInset.right;
}

- (void)setContentOffsetX:(CGFloat)contentOffsetX
{
    self.contentOffset = CGPointMake(contentOffsetX, self.contentOffset.y);
}
- (CGFloat)contentOffsetX
{
    return self.contentOffset.x;
}

- (void)setContentOffsetY:(CGFloat)contentOffsetY
{
    self.contentOffset = CGPointMake(self.contentOffset.x, contentOffsetY);
}
- (CGFloat)contentOffsetY
{
    return self.contentOffset.y;
}

@end
