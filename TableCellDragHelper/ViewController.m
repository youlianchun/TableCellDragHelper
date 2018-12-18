//
//  ViewController.m
//  TableCellDragHelper
//
//  Created by YLCHUN on 2018/12/12.
//  Copyright © 2018年 YLCHUN. All rights reserved.
//

#import "ViewController.h"
#import "TableCellDragHelper.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<NSString *> *> *datas;
@property (nonatomic, strong) TableCellDragHelper *tableCellDrag;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
    self.tableCellDrag = [TableCellDragHelper dragWithTableView:self.tableView dataArray:self.datas];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 100;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

-(NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray array];
        for (int i = 0; i < 2; i++) {
            NSMutableArray *arr = [NSMutableArray array];
            for (int j = 0; j < 10; j++) {
                [arr addObject:[NSString stringWithFormat:@"%d %d", i,j]];
            }
            [_datas addObject:arr];
        }
    }
    return _datas;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas[section].count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.datas[indexPath.section][indexPath.row];
    return cell;
}

@end
