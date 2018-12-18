//
//  TableCellDragHelper.h
//  TableCellDragHelper
//
//  Created by YLCHUN on 2018/12/12.
//  Copyright © 2018年 YLCHUN. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UITableView;
@interface TableCellDragHelper : NSObject
+(instancetype _Nullable )dragWithTableView:(UITableView * _Nonnull)tableView dataArray:(__strong  NSMutableArray * _Nonnull )dataArray;
@end

NS_ASSUME_NONNULL_END
