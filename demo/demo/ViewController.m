//
//  ViewController.m
//  demo
//
//  Created by Zongzhu on 16/1/5.
//  Copyright © 2016年 Zongzhu. All rights reserved.
//

#import "DGElasticPullToRefresh.h"
#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) UITableView* tableView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:57 / 255.0 green:67 / 255.0 blue:89 / 255.0 alpha:1];

#warning what reason is this？
    //  Don't forget the fllow code!  bug？
    self.extendedLayoutIncludesOpaqueBars = YES;

    UITableView* tabelView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tabelView.dataSource = self;
    tabelView.delegate = self;

    [self.view addSubview:tabelView];
    self.tableView = tabelView;

    DGElasticPullToRefreshLoadingViewCircle* loadingView = [[DGElasticPullToRefreshLoadingViewCircle alloc] init];
    loadingView.tintColor = [UIColor whiteColor];

    __weak typeof(self) weakSelf = self;

    [tabelView dg_addPullToRefreshWithWaveMaxHeight:70 minOffsetToPull:80 loadingContentInset:50 loadingViewSize:30 actionHandler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView dg_stopLoading];
        });
    }
                                        loadingView:loadingView];

    [tabelView dg_setPullToRefreshFillColor:[UIColor colorWithRed:57 / 255.0 green:67 / 255.0 blue:89 / 255.0 alpha:1]];

    [tabelView dg_setPullToRefreshBackgroundColor:tabelView.backgroundColor];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString* cellIdentifier = @"cellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

        cell.contentView.backgroundColor = [UIColor colorWithRed:250 / 255.0 green:250 / 255.0 blue:251 / 255.0 alpha:1];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    return cell;
}

- (void)dealloc
{
    [self.tableView dg_removePullToRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

@end
