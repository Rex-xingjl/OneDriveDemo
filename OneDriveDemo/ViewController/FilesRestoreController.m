//
//  FilesRestoreController.m
//  OneDriveDemo
//
//  Created by Rex on 2021/3/18.
//

#import "FilesRestoreController.h"
#import "YXHUD.h"
#import "RXNetworking.h"

#import "MSAL.h"
#import "MSConstants.h"
#import "MSGraphClientModels.h"

#import "FilesRestoreCell.h"

@interface FilesRestoreController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

// 界面使用的元素数组
@property (nonatomic, strong) NSMutableArray * driveItems;

@end

@implementation FilesRestoreController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"回收站";
//    [self graphGetRestoreList];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [YXHUD showInfo:@"Graph文档中没有找到相关的RESTAPI"];
}

- (void)graphGetRestoreList {
    
    NSString * graphAPI = [NSString stringWithFormat:@"%@/me/drive/restore", MSGraphBaseURL];
    [YXHUD show];
    [[RXNetworking shared] Get_Params:nil Url:graphAPI Token:self.token Completed:^(BOOL success, RXResponse *response) {
        if (!success) {
            [YXHUD showInfo:[NSString stringWithFormat:@"获取回收站失败：%@", response.object]];
            return;
        }
        NSMutableArray * items = [[NSMutableArray alloc] init];
        NSArray * dicts = response.object[@"value"];
        for (NSDictionary * dict in dicts) {
            MSGraphDriveItem * item = [[MSGraphDriveItem alloc] initWithDictionary:dict];
            [items addObject:item];
        }
        self.driveItems = items;
        [self.tableView reloadData];
        if (items.count <= 0) {
            [YXHUD showInfo:@"回收站为空"];
        } else {
            [YXHUD hide];
        }
    }];
}

#pragma mark - ------------------ UITableViewDelegate -------------------

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FilesRestoreCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FilesRestoreCell" forIndexPath:indexPath];
    MSGraphDriveItem * item = self.driveItems[indexPath.row];
    cell.fileNameLabel.text = item.name;
    cell.restoreAction = ^{
        
    };
//    if (item.thumbnails.count) {
//        NSDictionary * thumbnail = item.thumbnails[0];
//        NSString * url = thumbnail[@"small"][@"url"];
//        [cell.thumbImageView sd_setImageWithURL:[NSURL URLWithString:url]];
//    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.driveItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSGraphDriveItem *item = [self.driveItems objectAtIndex:indexPath.row];
    return item.folder ? 50 : 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (NSMutableArray *)driveItems {
    if (!_driveItems) {
        _driveItems = [[NSMutableArray alloc] init];
    }
    return _driveItems;
}

@end
