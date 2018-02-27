//
//  HomeVC.m
//  Hinteen
//
//  Created by xaoxuu on 07/09/2017.
//  Copyright © 2017 hinteen. All rights reserved.
//

#import "HomeVC.h"
#import "HomeTableView.h"
#import "BKRefreshView.h"
#import "BKBatteryView.h"
#import "DeviceSettingTV.h"
#import <MJRefresh.h>
#import "BKSportQuery.h"
#import "BKSportData.h"
#import "BKHeartRateQuery.h"
#import "BKSleepQuery.h"
#import "BKSleepData.h"

static NSString *reuseIdentifier = @"home table view cell";


@interface HomeVC () <BKDeviceDelegate, BKDataObserver, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) BKSportQuery *sport;
@property (strong, nonatomic) BKSleepQuery *sleep;


@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.width = kScreenW;
    self.view.height -= kTabBarHeight;
    
    [self setupTableView];
    
    [[BKServices sharedInstance] registerDeviceDelegate:self];
    [[BKServices sharedInstance] registerDataObserver:self];
    
    [self setupRefreshView];
    
    [self setupBatteryView];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadData];
    if ([BKServices sharedInstance].connector.state != BKConnectStateConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.mj_header endRefreshing];
        });
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[BKServices sharedInstance] unRegisterDeviceDelegate:self];
    [[BKServices sharedInstance] unRegisterDataObserver:self];
}

- (void)setupTableView{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
    
}

- (void)setupRefreshView{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem ax_itemWithCustomView:[BKRefreshView sharedInstance] action:^(UIBarButtonItem * _Nonnull sender) {
        [[BKRefreshView sharedInstance] startAnimating];
        [[BKDevice currentDevice] requestUpdateBatteryCompletion:nil error:nil];
        [[BKDevice currentDevice] requestUpdateAllHealthDataCompletion:nil error:nil];
    }];
}
- (void)setupBatteryView{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem ax_itemWithCustomView:[BKBatteryView sharedInstance] action:^(UIBarButtonItem * _Nonnull sender) {
        
    }];
}


/**
 更新了电池信息
 
 @param battery 电池电量
 */
- (void)deviceDidUpdateBattery:(NSInteger)battery{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[BKBatteryView sharedInstance] updateBatteryPercent:(CGFloat)battery / 100.0f];
    });
}

- (void)deviceDidSynchronizing:(BOOL)synchronizing{
    if (!synchronizing) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.mj_header endRefreshing];
        });
    }
}

- (void)dataDidUpdated:(__kindof BKData *)data{
    [self reloadData];
}

- (void)reloadData{
    self.sport = [BKSportQuery querySummaryWithDate:[NSDate date] unit:BKQueryUnitDaily].lastObject;
//    self.sleep = [BKSleepQuery querySummaryWithDate:[NSDate date] unit:BKQueryUnitDaily].lastObject;
    [self.tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // 今日概览、分段运动、心率数据、睡眠数据
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 4;
    } else if (section == 1) {
        if (self.sport) {
            return self.sport.items.count;
        } else {
            return 0;
        }
    } else if (section == 2) {
        return 1;
    } else if (section == 3) {
        if (self.sleep) {
            return self.sleep.items.count;
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"步数";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d steps", self.sport.steps.intValue];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"距离";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f km", self.sport.distance.doubleValue / 1000.0f];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"卡路里";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f cal", self.sport.calorie.doubleValue];
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"活动时间";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d minutes", self.sport.activity.intValue];
        }
    } else if (indexPath.section == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", self.sport.items[indexPath.row].start.stringValue(@"HH:mm"), self.sport.items[indexPath.row].end.stringValue(@"HH:mm")];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d steps", (int)self.sport.items[indexPath.row].steps];
    } else if (indexPath.section == 2) {
        cell.textLabel.text = @"心率图表";
    } else if (indexPath.section == 3) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", self.sleep.items[indexPath.row].start.stringValue(@"HH:mm"), self.sleep.items[indexPath.row].end.stringValue(@"HH:mm")];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d minutes", (int)self.sleep.items[indexPath.row].duration];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"今日概览";
    } else if (section == 1) {
        return @"分段运动";
    } else if (section == 2) {
        return @"心率数据";
    } else if (section == 3) {
        return @"睡眠数据";
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
