# TableCellDragHelper
TableCellDragHelper  TableCell拖动

### TableCellDragHelper
```
@interface TableCellDragHelper : NSObject
+(instancetype _Nullable )dragWithTableView:(UITableView * _Nonnull)tableView dataArray:(__strong  NSMutableArray * _Nonnull )dataArray;
@end
```
### 示例
```
@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<NSString *> *> *datas;
@end

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
    _tableCellDrag = [TableCellDragHelper dragWithTableView:self.tableView dataArray:self.datas];
}
```
