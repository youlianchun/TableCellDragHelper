//
//  TableCellDragHelper.m
//  TableCellDragHelper
//
//  Created by YLCHUN on 2018/12/12.
//  Copyright © 2018年 YLCHUN. All rights reserved.
//

#import "TableCellDragHelper.h"
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DragScrollDirectionUp,
    DragScrollDirectionDoun,
    DragScrollDirectionNone,
} DragScrollDirection;
@implementation TableCellDragHelper
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    UIImageView *_markImageView;
    NSIndexPath *_fromIndexPath;
    CADisplayLink *_displayLink;
    CGFloat _minY, _maxY;
}
+(instancetype)dragWithTableView:(UITableView*)tableView dataArray:(NSMutableArray*)dataArray
{
    if (dataArray.count == 0)
    {
        return nil;
    }
    TableCellDragHelper *drag = [[TableCellDragHelper alloc] init];
    drag->_tableView = tableView;
    drag->_dataArray = dataArray;
    [drag setup];
    return drag;
}
-(void)dealloc
{
    _tableView = nil;
    _dataArray = nil;
    _markImageView = nil;
    _fromIndexPath = nil;
    [self stopToScrollTableViewIfNeed];
}
-(void)setup
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(dragHandler:)];
    [_tableView addGestureRecognizer:longPress];
}
-(UIImageView*)markImageViewWithCell:(UITableViewCell*)cell
{
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, [UIScreen mainScreen].scale);
    [cell.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *markImageView = [[UIImageView alloc] initWithImage:image];
    markImageView.backgroundColor = [UIColor whiteColor];
    markImageView.layer.shadowOffset = CGSizeMake(1, 1);
    markImageView.layer.shadowRadius = 3.0;
    markImageView.layer.shadowOpacity = 0.3;
    markImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    return markImageView;
}
-(void)dragHandler:(UILongPressGestureRecognizer *)sender
{
    CGPoint superPoint = [sender locationInView:_tableView.superview];
    CGPoint point = [sender locationInView:_tableView];
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            _fromIndexPath = [_tableView indexPathForRowAtPoint:point];
            if (!_fromIndexPath) return;
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:_fromIndexPath];
            _markImageView = [self markImageViewWithCell:cell];
            CGPoint center = [_tableView.superview convertPoint:cell.center fromView:_tableView];
            _markImageView.center = center;
            [_tableView.superview addSubview:_markImageView];
            _minY = CGRectGetMinY(_tableView.frame) + CGRectGetMidY(_markImageView.bounds);
            _maxY = CGRectGetMaxY(_tableView.frame) - CGRectGetMidY(_markImageView.bounds);
            center.y = superPoint.y;
            cell.hidden = YES;
            [UIView animateWithDuration:0.25 animations:^{
                self->_markImageView.center = center;
                self->_markImageView.transform = CGAffineTransformMakeScale(1.05, 1.05);
            } completion:^(BOOL finished) {
                self->_tableView.userInteractionEnabled = NO;
            }];
        } break;
        case UIGestureRecognizerStateChanged: {
            CGPoint center = _markImageView.center;
            CGFloat y = superPoint.y;
            if (y > _maxY) {
                y = _maxY;
            }else if(y < _minY) {
                y = _minY;
            }
            center.y = y;
            _markImageView.center = center;
            [self startToScrollTableViewIfNeed];
            if (_displayLink==nil) {
                [self exchangeCellIfNeed];
            }
        } break;
        default: {
            [self stopToScrollTableViewIfNeed];
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:_fromIndexPath];
            CGPoint center = [_tableView.superview convertPoint:cell.center fromView:_tableView];
            [UIView animateWithDuration:0.25 animations:^{
                self->_markImageView.center = center;
                self->_markImageView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                cell.hidden = NO;
                self->_tableView.userInteractionEnabled = YES;
                [self->_markImageView removeFromSuperview];
                self->_markImageView = nil;
                self->_fromIndexPath = nil;
            }];
        } break;
    }
}
- (void)exchangeCellIfNeed
{
    CGPoint point = [_tableView.superview convertPoint:_markImageView.center toView:_tableView];
    NSIndexPath *toIndexPath = [_tableView indexPathForRowAtPoint:point];
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:_fromIndexPath];
    cell.hidden = YES;
    if (toIndexPath && !(toIndexPath.section == _fromIndexPath.section && toIndexPath.row == _fromIndexPath.row))
    {
        CGPoint contentOffset = _tableView.contentOffset;
        if (_tableView.numberOfSections > 1)
        {
            NSMutableArray *fromArray = _dataArray[_fromIndexPath.section];
            NSMutableArray *toArray = _dataArray[toIndexPath.section];
            id data = fromArray[_fromIndexPath.row];
            fromArray[_fromIndexPath.row] = toArray[toIndexPath.row];
            toArray[toIndexPath.row] = data;
            [UIView performWithoutAnimation:^{
                [self->_tableView beginUpdates];
                [self->_tableView moveRowAtIndexPath:toIndexPath toIndexPath:self->_fromIndexPath];
                [self->_tableView moveRowAtIndexPath:self->_fromIndexPath toIndexPath:toIndexPath];
                [self->_tableView endUpdates];
            }];
        }
        else
        {
            [_dataArray exchangeObjectAtIndex:_fromIndexPath.row withObjectAtIndex:toIndexPath.row];
            [UIView performWithoutAnimation:^{
                [self->_tableView beginUpdates];
                [self->_tableView moveRowAtIndexPath:self->_fromIndexPath toIndexPath:toIndexPath];
                [self->_tableView endUpdates];
            }];
        }
        [_tableView setContentOffset:contentOffset animated:NO];
        _fromIndexPath = toIndexPath;
    }
}
- (DragScrollDirection)scrollDirectioWithDragEdge
{
    if (CGRectGetMinY(_markImageView.frame) <= CGRectGetMinY(_tableView.frame)) {
        return DragScrollDirectionUp;
    }else if (CGRectGetMaxY(_markImageView.frame) >= CGRectGetMaxY(_tableView.frame)) {
        return DragScrollDirectionDoun;
    }else {
        return DragScrollDirectionNone;
    }
}
-(BOOL)needScrollWithDirection:(DragScrollDirection)dragScrollDirection
{
    switch (dragScrollDirection)
    {
        case DragScrollDirectionUp:
            return _tableView.contentOffset.y > -_tableView.contentInset.top;
        case DragScrollDirectionDoun:
            return _tableView.contentOffset.y + _tableView.bounds.size.height - _tableView.contentInset.bottom < _tableView.contentSize.height;
        default:
            return NO;
    }
}
- (void)startToScrollTableViewIfNeed
{
    if ([self needScrollWithDirection:[self scrollDirectioWithDragEdge]])
    {
        if (_displayLink == nil) {
            _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(scrollTableView)];
            [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        }
    }else {
        [self stopToScrollTableViewIfNeed];
    }
}
- (void)stopToScrollTableViewIfNeed
{
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}
- (void)scrollTableView
{
    static const CGFloat scrollSpeed = 3;
    CGFloat midY1 = CGRectGetMidY(_markImageView.frame);
    CGFloat midY2 = CGRectGetMidY(_tableView.frame);
    CGPoint contentOffset = _tableView.contentOffset;
    DragScrollDirection dragScrollDirection;
    if (midY1 < midY2)
    {
        dragScrollDirection = DragScrollDirectionUp;
        contentOffset.y -= scrollSpeed;
    }else if (midY1 > midY2)
    {
        dragScrollDirection = DragScrollDirectionDoun;
        contentOffset.y += scrollSpeed;
    } else
    {
        [self stopToScrollTableViewIfNeed];
        return;
    }
    [_tableView setContentOffset:contentOffset animated:NO];
    [self exchangeCellIfNeed];
    if(![self needScrollWithDirection:dragScrollDirection])
    {
        [self stopToScrollTableViewIfNeed];
    }
}
@end

