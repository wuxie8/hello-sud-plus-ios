//
//  GameListViewController.m
//  HelloSud-iOS
//
//  Created by Mary on 2022/1/20.
//

#import "GameListViewController.h"
#import "SearchHeaderView.h"
#import "GameListTableViewCell.h"
#import "AudioRoomViewController.h"

@interface GameListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) SearchHeaderView *searchHeaderView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <HSRoomInfoList *> *dataList;
@end

@implementation GameListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addRefreshHeader];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestData];
}

- (BOOL)dtIsHidenNavigationBar {
    return YES;
}

- (void)dtConfigUI {
    self.view.backgroundColor = [UIColor colorWithHexString:@"#F5F6FB" alpha:1];
}

- (void)dtConfigEvents {
    WeakSelf
    [[NSNotificationCenter defaultCenter] addObserverForName:TOKEN_REFRESH_NTF object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        if (AppManager.shared.isRefreshedToken) {
            [weakSelf requestData];
        } else {
            [weakSelf.tableView.mj_header endRefreshing];
        }
    }];
    if (AppManager.shared.isRefreshedToken) {
        [self requestData];
    }
}

- (void)dtAddViews {
    [self.view addSubview:self.searchHeaderView];
    [self.view addSubview:self.tableView];
}

- (void)dtLayoutViews {
    [self.searchHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.searchHeaderView.mas_bottom);
        make.left.mas_equalTo(16);
        make.right.mas_equalTo(-16);
        make.bottom.mas_equalTo(-kTabBarHeight);
    }];
}

// 添加下来刷新
- (void)addRefreshHeader {
    WeakSelf
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (!AppManager.shared.isRefreshedToken) {
            [AppManager.shared refreshToken];
            return;
        }
        [weakSelf requestData];
    }];
    self.tableView.mj_header = header;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#F5F6FB" alpha:1];
}

#pragma mark - requst Data
- (void)requestData {
    WeakSelf
    [HttpService postRequestWithApi:kINTERACTURL(@"room/list/v1") param:nil success:^(NSDictionary *rootDict) {
        [weakSelf.tableView.mj_header endRefreshing];
        RoomListModel *model = [RoomListModel decodeModel:rootDict];
        if (model.retCode != 0) {
            [ToastUtil show:model.retMsg];
            return;
        }
        [self.dataList removeAllObjects];
        [weakSelf.dataList addObjectsFromArray:model.roomInfoList];
        [weakSelf.tableView reloadData];
    } failure:^(id error) {
        [ToastUtil show:@"网络错误"];
    }];
}

#pragma mark - UITableViewDelegate || UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GameListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GameListTableViewCell"];
    cell.model = self.dataList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HSRoomInfoList *m = self.dataList[indexPath.row];
    [AudioRoomManager.shared reqEnterRoom:m.roomId];
}

#pragma mark - lazy

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 90;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor colorWithHexString:@"#F5F6FB" alpha:1];
        [_tableView registerClass:[GameListTableViewCell class] forCellReuseIdentifier:@"GameListTableViewCell"];
        UIView *headerNode = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
        headerNode.backgroundColor = [UIColor colorWithHexString:@"#F5F6FB" alpha:1];
        _tableView.tableHeaderView = headerNode;
    }
    return _tableView;
}

- (SearchHeaderView *)searchHeaderView {
    if (!_searchHeaderView) {
        _searchHeaderView = [[SearchHeaderView alloc] init];
    }
    return _searchHeaderView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
