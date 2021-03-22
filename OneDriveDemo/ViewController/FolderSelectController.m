//
//  FolderSelectController.m
//  OneDriveDemo
//
//  Created by Rex on 2021/3/19.
//

#import "FolderSelectController.h"
#import "YXHUD.h"
#import "RXNetworking.h"
#import "MJRefresh.h"

#import "MSAL.h"
#import "MSConstants.h"
#import "MSCollection.h"
#import "MSGraphClientModels.h"

#import "FolderSelectCell.h"

@interface FolderSelectController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *moveBBI;

// 界面使用的元素数组
@property (nonatomic, strong) NSMutableArray * driveItems;

@property (nonatomic, strong) NSString * nextLink;

@end

@implementation FolderSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择路径";
    [self graphGetFolderList:YES];
    
    __weak typeof(self) weak = self;
    self.tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        __strong typeof(self) strong = weak;
        [strong graphGetFolderList:NO];
    }];
    
    if ([self.driveItemId isEqual:self.fromDriveItemId]) {
        self.moveBBI.enabled = NO;
    }
}

- (IBAction)moveBBIAction:(id)sender {
    if (self.selectFolderDone) {
        self.selectFolderDone(self.driveItemId);
    }
}

- (void)graphGetFolderList:(BOOL)clean {
    if (clean) {
        self.nextLink = nil;
        [self.driveItems removeAllObjects];
    }
    NSString * graphAPI;
    if (self.nextLink) {
        graphAPI = self.nextLink;
    } else {
        graphAPI = [NSString stringWithFormat:@"%@/me/drive/items/%@/children?$top=20&filter=folder ne null", MSGraphBaseURL, self.driveItemId];
    }
    __weak typeof(self) weak = self;
    [YXHUD show];
    [[RXNetworking shared] Get_Params:nil Url:graphAPI Token:self.token Completed:^(BOOL success, RXResponse *response) {
        __weak typeof(self) strong = weak;
        if (!success) {
            [YXHUD showInfo:[NSString stringWithFormat:@"获取文件夹列表失败：%@", response.object]];
            return;
        }
        [YXHUD hide];
        MSCollection *collection = [[MSCollection alloc] initWithDictionary:response.object];
        for (NSDictionary * dict in collection.value) {
            MSGraphDriveItem * item = [[MSGraphDriveItem alloc] initWithDictionary:dict];
            [strong.driveItems addObject:item];
        }
        if (collection.nextLink) {
            strong.nextLink = collection.nextLink.absoluteString;
            [strong.tableView.mj_footer resetNoMoreData];
        } else {
            [strong.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [self.tableView reloadData];
    }];
}

#pragma mark - ------------------ UITableViewDelegate -------------------

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FolderSelectCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FolderSelectCell" forIndexPath:indexPath];
    MSGraphDriveItem * item = self.driveItems[indexPath.row];
    cell.folderNameLabel.text = item.name;
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
    
    MSGraphDriveItem *item = [self.driveItems objectAtIndex:indexPath.row];
    FolderSelectController * fileVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FolderSelectController"];
    fileVC.token = self.token;
    fileVC.driveItemId = item.entityId;
    fileVC.fromDriveItemId = self.fromDriveItemId;
    fileVC.selectFolderDone = self.selectFolderDone;
    [self.navigationController pushViewController:fileVC animated:YES];
}

- (NSMutableArray *)driveItems {
    if (!_driveItems) {
        _driveItems = [[NSMutableArray alloc] init];
    }
    return _driveItems;
}

@end
