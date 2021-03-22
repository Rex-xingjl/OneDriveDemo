//
//  FilesViewController.m
//  OneDriveDemo
//
//  Created by Rex on 2021/3/3.
//

#import "FilesViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>

#import "MSAL.h"
#import "MSConstants.h"
#import "MSCollection.h"
#import "MSGraphClientModels.h"

#import "YXHUD.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "RXNetworking.h"
#import "UIAlertController+Category.h"
#import "UIImageView+WebCache.h"
#import "RXAuthorization.h"

#import "FilesSearchController.h"
#import "FilesRestoreController.h"
#import "FolderSelectController.h"
#import "FilesListCell.h"

static NSInteger chunkLength = 320*10*1024;

@interface FilesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *editToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBBI;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *downloadBBI;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBBI;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *moveBBI;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *coBBI;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottom;

@property (nonatomic, strong) NSString * uploadUrl;

@property (nonatomic, strong) NSString * nextLink;

// 界面使用的元素数组
@property (nonatomic, strong) NSMutableArray * driveItems;

// 已选中的待操作Items
@property (nonatomic, strong) NSMutableArray * selectItems;

// 当前是否处于选择状态
@property (nonatomic, assign) BOOL selecting;

@end

@implementation FilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self cancelItemBBIEnabled];
    
    __weak typeof(self) weak = self;
    [self graphCurrentItemId:self.driveItemId completed:^(NSString *driveItemId) {
        __strong typeof(self) strong = weak;
        strong.driveItemId = driveItemId;
        [strong graphGetDriveChildrenWithToken:YES];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoStateFooter footerWithRefreshingBlock:^{
        __strong typeof(self) strong = weak;
        [strong graphGetDriveChildrenWithToken:NO];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDriveChildrenNoti:) name:@"RefreshDriveListNotification" object:nil];
}

- (void)refreshDriveChildrenNoti:(NSNotification *)noti {
    if ([noti.object isEqualToString:self.driveItemId]) {
        [self graphGetDriveChildrenWithToken:YES];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Status

- (void)cancelAllSelectAndRefreshTable {
    self.selecting = NO;
    [self.selectItems removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.rightBarButtonItem.title = @"选择";
        [self cancelItemBBIEnabled];
        [self.tableView reloadData];
    });
}

- (void)cancelItemBBIEnabled {
    self.editToolbar.hidden = !self.selecting;
    self.tableViewBottom.constant = self.selecting ? 44.f : 0.f;
    self.downloadBBI.enabled = NO;
    self.deleteBBI.enabled = NO;
    self.editBBI.enabled = NO;
    self.coBBI.enabled = NO;
    self.moveBBI.enabled = NO;
}

#pragma mark - ---------------------- Actions ----------------------

- (IBAction)createNewFolderAction:(id)sender {
    [UIAlertController showTextAlert:self Text:nil PlaceHolder:@"请输入目录名称" Title:@"创建目录" Message:nil EnsureBlock:^(NSString *text) {
        if (!text) return;
        [self graphCreateFolder:text];
    }];
}

- (IBAction)recycleBinAction:(id)sender {
    FilesRestoreController * fileVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FilesRestoreController"];
    fileVC.token = self.token;
    [self.navigationController pushViewController:fileVC animated:YES];
}

- (IBAction)copyFileAction:(id)sender {
    FolderSelectController * fileVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FolderSelectController"];
    fileVC.token = self.token;
    fileVC.driveItemId = self.rootId;
    fileVC.fromDriveItemId = self.driveItemId;
    UINavigationController * navi = [[UINavigationController alloc] initWithRootViewController:fileVC];
    [self.navigationController presentViewController:navi animated:YES completion:nil];
    
    __weak typeof(self) weak = self;
    __weak typeof(fileVC) weakVC = fileVC;
    fileVC.selectFolderDone = ^(NSString * _Nonnull driveItemId) {
        __strong typeof(self) strong = weak;
        __strong typeof(fileVC) strongVC = weakVC;
        [strong graphCopyItemsTo:driveItemId completed:^{
            [weak graphGetDriveChildrenWithToken:YES];
            [strongVC.navigationController dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshDriveListNotification" object:driveItemId];
        }];
    };
}

- (IBAction)moveFileAction:(id)sender {
    FolderSelectController * fileVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FolderSelectController"];
    fileVC.token = self.token;
    fileVC.driveItemId = self.rootId;
    fileVC.fromDriveItemId = self.driveItemId;
    UINavigationController * navi = [[UINavigationController alloc] initWithRootViewController:fileVC];
    [self.navigationController presentViewController:navi animated:YES completion:nil];
    
    __weak typeof(self) weak = self;
    __weak typeof(fileVC) weakVC = fileVC;
    fileVC.selectFolderDone = ^(NSString * _Nonnull driveItemId) {
        __strong typeof(self) strong = weak;
        __strong typeof(fileVC) strongVC = weakVC;
        [strong graphMoveItemsTo:driveItemId completed:^{
            [weak graphGetDriveChildrenWithToken:YES];
            [strongVC.navigationController dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshDriveListNotification" object:driveItemId];
        }];
    };
}

- (IBAction)downloadFileAction:(id)sender {
    [UIAlertController showTwoActionAlert:self Title:@"确定要下载吗？" Message:nil LeftTitle:@"取消" RightTitle:@"确定" EnsureBlock:^{
        for (MSGraphDriveItem * item in self.selectItems) {
            [self graphDownloadItem:item];
        }
        [self.selectItems removeAllObjects];
        [self cancelItemBBIEnabled];
        [self.tableView reloadData];
    }];
}

- (IBAction)editFilesAction:(UIBarButtonItem *)sender {
    self.selecting = !self.selecting;
    sender.title = self.selecting ? @"取消" : @"选择";
    
    self.editToolbar.hidden = !self.selecting;
    self.tableViewBottom.constant = self.selecting ? 44.f : 0.f;
    [self cancelItemBBIEnabled];
    
    [self.selectItems removeAllObjects];
    [self.tableView reloadData];
}

- (IBAction)uploadFileAction:(id)sender {
    [RXAuthorization authWithType:RXAuthorizationType_Camera permission:^(BOOL allow) {
        if(allow) {
            [RXAuthorization authWithType:RXAuthorizationType_Photo permission:^(BOOL allow) {
                if(allow) {
                    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.delegate = (id)self;
                    imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
                    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];
                    imagePicker.videoMaximumDuration = 60;
                    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
                }
            }];
        }
    }];
}

- (IBAction)searchBtnAction:(id)sender {
    FilesSearchController * fileVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FilesSearchController"];
    fileVC.token = self.token;
    fileVC.driveItemId = self.driveItemId;
    [self.navigationController pushViewController:fileVC animated:YES];
}

- (IBAction)editBtnAction:(id)sender {
    MSGraphDriveItem * item = self.selectItems.firstObject;
    [UIAlertController showTextAlert:self Text:nil PlaceHolder:@"输入要修改的名称" Title:item.folder ? @"修改文件夹名称" : @"修改文件名称" Message:@"修改文件名需要输入后缀" EnsureBlock:^(NSString *text) {
        if (text.length) {
            [self graphChangeItem:item Name:text];
        }
    }];
}

- (IBAction)deleteFolderAction:(id)sender {
    [UIAlertController showTwoActionAlert:self Title:@"确定要删除吗？" Message:nil LeftTitle:@"取消" RightTitle:@"确定" EnsureBlock:^{
        [self graphDeleteItems];
    }];
}

#pragma mark - ---------------------- Graph APIs ----------------------

// 如果是根目录 则获取itemId
- (void)graphCurrentItemId:(NSString *)driveItemId completed:(void (^)(NSString * driveItemId)) block {
    if (!driveItemId) {
        NSString * graphAPI = [NSString stringWithFormat:@"%@/me/drive/root", MSGraphBaseURL];
        [YXHUD show];
        __weak typeof(self) weak = self;
        [[RXNetworking shared] Get_Params:nil Url:graphAPI Token:self.token Completed:^(BOOL success, RXResponse *response) {
            __strong typeof(self) strong = weak;
            if (!success) {
                [YXHUD showInfo:@"获取drive信息失败！"];
                return;
            }
            MSGraphDriveItem * item = [[MSGraphDriveItem alloc] initWithDictionary:response.object];
            strong.rootId = item.entityId;
            if (block) {
                block(item.entityId);
            }
        }];
    } else {
        if (block) {
            block(driveItemId);
        }
    }
}

- (void)graphCreateFolder:(NSString *)folderName {
    NSString * graphAPI = [NSString stringWithFormat:@"%@/me/drive/items/%@/children", MSGraphBaseURL, self.driveItemId];
    NSDictionary * params = @{@"name": folderName,
                              @"folder": @{ },
                              @"@microsoft.graph.conflictBehavior": @"rename"};
    __weak typeof(self) weak = self;
    [YXHUD show];
    [[RXNetworking shared] Post_Params:params Url:graphAPI Token:self.token Completed:^(BOOL success, RXResponse *response) {
        __strong typeof(self) strong = weak;
        if (!success) {
            [YXHUD showInfo:response.object];
            NSLog(@"创建目录失败: %@", response.object);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [strong graphGetDriveChildrenWithToken:YES];
        });
    }];
}

- (void)graphChangeItem:(MSGraphDriveItem *)item Name:(NSString *)name {
    NSString * graphAPI = [NSString stringWithFormat:@"%@/me/drive/items/%@", MSGraphBaseURL, item.entityId];
    [YXHUD show];
    __weak typeof(self) weak = self;
    [[RXNetworking shared] Patch_Params:@{@"name":name} Url:graphAPI Token:self.token Completed:^(BOOL success, RXResponse *response) {
        __strong typeof(self) strong = weak;
        if (!success) {
            [YXHUD showInfo:response.object];
            return;
        }
        [strong graphGetDriveChildrenWithToken:YES];
    }];
}

- (void)graphCopyItemsTo:(NSString *)driveItemId completed:(void (^)(void)) block {
    NSMutableArray * requests = [[NSMutableArray alloc] init];
    NSInteger index = 0;
    for (MSGraphDriveItem * item in self.selectItems) {
        NSString * url = [NSString stringWithFormat:@"/me/drive/items/%@/copy", item.entityId];
        NSDictionary * request = @{@"id": @(index),
                                   @"method": @"POST",
                                   @"url": url,
                                   @"body": @{@"parentReference": @{@"id": driveItemId},
                                              @"@microsoft.graph.conflictBehavior": @"rename"},
                                   @"headers": @{@"Content-Type": @"application/json"},
        };
        [requests addObject:request];
        index ++;
    }
    NSString * batchAPI = [NSString stringWithFormat:@"%@/$batch", MSGraphBaseURL];
    [YXHUD show];
    [[RXNetworking shared] Post_Params:@{@"requests":requests} Url:batchAPI Token:self.token Completed:^(BOOL success, RXResponse *response) {
        if (!success) {
            [YXHUD showInfo:response.object];
            NSLog(@"复制文件失败: %@", response.object);
            return;
        }
        [YXHUD hide];
        NSArray * responses = response.object[@"responses"];
        for (NSDictionary * res in responses) {
            NSInteger status = [res[@"status"] integerValue];
            if (status != 202) { NSLog(@"复制文件有失败: id = %ld", [res[@"id"] integerValue]); }
        }
        if (block) block();
    }];
}

- (void)graphMoveItemsTo:(NSString *)driveItemId completed:(void (^)(void)) block {
    NSMutableArray * requests = [[NSMutableArray alloc] init];
    NSInteger index = 0;
    for (MSGraphDriveItem * item in self.selectItems) {
        NSString * url = [NSString stringWithFormat:@"/me/drive/items/%@", item.entityId];
        NSDictionary * request = @{@"id": @(index),
                                   @"method": @"PATCH",
                                   @"url": url,
                                   @"body": @{@"parentReference": @{@"id": driveItemId},
                                              @"@microsoft.graph.conflictBehavior": @"rename"},
                                   @"headers": @{@"Content-Type": @"application/json"},
        };
        [requests addObject:request];
        index ++;
    }
    NSString * batchAPI = [NSString stringWithFormat:@"%@/$batch", MSGraphBaseURL];
    [YXHUD show];
    [[RXNetworking shared] Post_Params:@{@"requests":requests} Url:batchAPI Token:self.token Completed:^(BOOL success, RXResponse *response) {
        if (!success) {
            [YXHUD showInfo:response.object];
            NSLog(@"移动文件失败: %@", response.object);
            return;
        }
        [YXHUD hide];
        NSArray * responses = response.object[@"responses"];
        for (NSDictionary * res in responses) {
            NSInteger status = [res[@"status"] integerValue];
            if (status != 200) { NSLog(@"移动文件有失败: id = %ld", [res[@"id"] integerValue]); }
        }
        if (block) block();
    }];
}

- (void)graphDeleteItems {
    NSMutableArray * requests = [[NSMutableArray alloc] init];
    NSInteger index = 0;
    for (MSGraphDriveItem * item in self.selectItems) {
        NSString * url = [NSString stringWithFormat:@"/me/drive/items/%@", item.entityId];
        NSDictionary * request = @{@"id": @(index),
                                   @"method": @"DELETE",
                                   @"url": url};
        [requests addObject:request];
        index ++;
    }
    NSString * batchAPI = [NSString stringWithFormat:@"%@/$batch", MSGraphBaseURL];
    __weak typeof(self) weak = self;
    [YXHUD show];
    [[RXNetworking shared] Post_Params:@{@"requests":requests} Url:batchAPI Token:self.token Completed:^(BOOL success, RXResponse *response) {
        __strong typeof(self) strong = weak;
        if (!success) {
            [YXHUD showInfo:response.object];
            NSLog(@"删除失败: %@", response.object);
            return;
        }
        NSArray * responses = response.object[@"responses"];
        for (NSDictionary * res in responses) {
            NSInteger status = [res[@"status"] integerValue];
            if (status != 204) { NSLog(@"批量删除文件有失败: id = %ld", [res[@"id"] integerValue]); }
        }
        [strong graphGetDriveChildrenWithToken:YES];
    }];
}

- (void)graphGetDriveChildrenWithToken:(BOOL)clean {
    if (clean) {
        self.nextLink = nil;
        [self.driveItems removeAllObjects];
    }
    NSString * graphAPI;
    if (self.nextLink) {
        graphAPI = self.nextLink;
    } else {
        graphAPI = [NSString stringWithFormat:@"%@/me/drive/items/%@/children?$expand=thumbnails&$top=20", MSGraphBaseURL, self.driveItemId];
    }
    __weak typeof(self) weak = self;
    [YXHUD show];
    [[RXNetworking shared] Get_Params:nil Url:graphAPI Token:self.token Completed:^(BOOL success, RXResponse *response) {
        __weak typeof(self) strong = weak;
        if (!success) {
            [YXHUD showInfo:response.object];
            NSLog(@"刷新文件列表失败: %@", response.object);
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
        [strong cancelAllSelectAndRefreshTable];
    }];
}

- (void)graphUploadFile:(NSURL *)fileUrl fileName:(NSString *)fileName {
    NSError * error;
    NSDictionary * fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:fileUrl.path error:&error];
    long long filesize = [fileInfo[NSFileSize] longLongValue];
    if (filesize < 3.99*1024*1024) { // onedrive最大支持4M小文件上传
        NSLog(@"小文件上传");
        NSData * data = [NSData dataWithContentsOfURL:fileUrl];
        [self uploadSmallFileData:data fileUrl:fileUrl fileName:fileName];
    } else {
        NSLog(@"大文件上传");
        [self createUploadSessionForFileName:fileName completed:^(MSGraphUploadSession *session) {
            [self uploadFileUrl:fileUrl fileSize:filesize withGraphUploadSession:session];
        }];
    }
}

- (void)graphDownloadItem:(MSGraphDriveItem *)item {
    NSString * graphAPI = [NSString stringWithFormat:@"%@/me/drive/items/%@/content", MSGraphBaseURL, item.entityId];
    [YXHUD show];
    [[RXNetworking shared] download:graphAPI token:self.token path:nil progress:^(NSProgress * progress) {
        NSLog(@"下载进度 %.2lf%%", progress.fractionCompleted*100);
    } block:^(id result, NSString *error) {
        if (error) {
            [YXHUD hide];
            NSLog(@"下载失败: %@", error);
            return;
        }
        [YXHUD showInfo:@"下载成功"];
        NSLog(@"下载成功 path: %@", result);
    }];
}

#pragma mark - upload

- (void)uploadSmallFileData:(NSData *)data fileUrl:(NSURL *)fileUrl fileName:(NSString *)fileName {
    NSString * graphAPI = [NSString stringWithFormat:@"%@/me/drive/items/%@:/%@:/content", MSGraphBaseURL, self.driveItemId, fileName];
    __weak typeof(self) weak = self;
    [YXHUD showInfo:@"上传小文件..."];
    [[RXNetworking shared] upload_File:data Url:graphAPI Token:self.token FileName:fileName Params:nil UploadProgress:^(NSProgress *progress) {
        NSLog(@"上传进度 %.2lf%%", progress.fractionCompleted*100);
    } Completed:^(BOOL success, RXResponse *response) {
        __strong typeof(self) strong = weak;
        if (!success) {
            [YXHUD showInfo:@"小文件上传失败"];
            NSLog(@"小文件上传失败: %@", response.object);
            return;
        }
        NSError * ferror;
        [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:&ferror];
        NSLog(@"小文件上传成功 删除缓存文件：%@", ferror ? : @"OK");
        [strong graphGetDriveChildrenWithToken:YES];
    }];
}

- (void)createUploadSessionForFileName:(NSString *)fileName completed:(void(^)(MSGraphUploadSession * session)) completed {
    NSString * graphAPI = [NSString stringWithFormat:@"%@/me/drive/items/%@:/%@:/createUploadSession", MSGraphBaseURL, self.driveItemId, fileName];
    NSDictionary * params = @{@"item":@{@"@microsoft.graph.conflictBehavior":@"rename",
                                        @"name":fileName}};
    [YXHUD showHUDWithInfo:@"创建上传会话"];
    [[RXNetworking shared] Post_Params:params Url:graphAPI Token:self.token Completed:^(BOOL success, RXResponse *response) {
        if (!success) {
            [YXHUD showInfo:[NSString stringWithFormat:@"无法创建上传会话:%@", response.object]];
            NSLog(@"无法创建上传会话: %@", response.object);
            return;
        }
        MSGraphUploadSession * session = [[MSGraphUploadSession alloc] initWithDictionary:response.object];
        if (completed) completed(session);
    }];
}

- (void)uploadFileUrl:(NSURL *)fileUrl fileSize:(long)fileSize withGraphUploadSession:(MSGraphUploadSession *)session {
    NSInteger times = fileSize/chunkLength + (fileSize%chunkLength>0) -1;
    NSString * uploadUrl = session.uploadUrl;
    self.uploadUrl = uploadUrl;
    __weak typeof(self) weak = self;
    [YXHUD showInfo:@"开始上传..."];
    [self uploadFileChunkWithFileUrl:fileUrl fileSize:fileSize chunkIndex:0 times:times uploadURL:uploadUrl completed:^(BOOL success, id object) {
        __strong typeof(self) strong = weak;
        if (!success) {
            [YXHUD showInfo:@"大文件上传失败"];
            NSLog(@"大文件上传失败: %@", object);
            return;
        }
        NSError * ferror;
        [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:&ferror];
        NSLog(@"大文件上传成功 删除缓存文件：%@", ferror ? : @"OK");
        [strong graphGetDriveChildrenWithToken:YES];
    }];
}

- (void)uploadFileChunkWithFileUrl:(NSURL *)fileUrl fileSize:(long)fileSize chunkIndex:(NSInteger)index times:(NSInteger)times uploadURL:(NSString *)uploadURL  completed:(void(^)(BOOL success, id object)) completed {
    NSData * data = [self handleChunkOfFileUrl:fileUrl chunkIndex:index];

    NSInteger beginChunk = index*chunkLength;
    NSInteger endChunk = MIN(fileSize, (index+1)*chunkLength)-1;
    NSString * range  = [NSString stringWithFormat:@"bytes %ld-%ld/%ld", beginChunk, endChunk, fileSize];
    NSString * length = [NSString stringWithFormat:@"%ld", data.length];
    NSDictionary * header = @{@"Content-Range" : range,
                              @"Content-Length" : length};
    __weak typeof(self) weak = self;
    [[RXNetworking shared] upload_File:data Url:uploadURL Token:self.token Header:header FileName:fileUrl.lastPathComponent Params:nil UploadProgress:^(NSProgress *progress) {
        NSLog(@"上传大文件 分包:%ld 进度%.2lf%%", index,progress.fractionCompleted*100);
    } Completed:^(BOOL success, RXResponse *response) {
        __strong typeof(self) strong = weak;
        if (!success) {
            if (completed) completed(NO, response.object);
            return;
        }
        if (index < times) {
            [strong uploadFileChunkWithFileUrl:fileUrl fileSize:fileSize chunkIndex:index+1 times:times uploadURL:uploadURL completed:completed];
        } else {
            if (completed) completed(YES, response.object);
        }
    } Target:nil];
}

- (NSData *)handleChunkOfFileUrl:(NSURL *)fileUrl chunkIndex:(NSInteger)index {
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:fileUrl.path];
    [handle seekToFileOffset:chunkLength*index];
    NSData * data = [handle readDataOfLength:chunkLength];
    return data;
}

#pragma mark - ------------------ UITableViewDelegate -------------------

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FilesListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FilesListCell" forIndexPath:indexPath];
    MSGraphDriveItem * item = self.driveItems[indexPath.row];
    cell.nameLabel.text = item.name;
    cell.thumbImageView.hidden = item.folder;
    if (item.thumbnails.count) {
        NSDictionary * thumbnail = item.thumbnails[0];
        NSString * url = thumbnail[@"small"][@"url"];
        [cell.thumbImageView sd_setImageWithURL:[NSURL URLWithString:url]];
    }
    cell.accessoryType = [self.selectItems containsObject:item] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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

    if (!self.selecting) {
        if (item.folder) {
            FilesViewController * fileVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FilesViewController"];
            fileVC.token = self.token;
            fileVC.driveItemId = item.entityId;
            fileVC.rootId = self.rootId;
            fileVC.title = item.name;
            [self.navigationController pushViewController:fileVC animated:NO];
        } else {
            [UIAlertController showOneActionAlert:self Title:@"这是一个文件" Message:item.name ActionTitle:nil EnsureBlock:nil];
        }
    } else {
        if ([self.selectItems containsObject:item]) {
            [self.selectItems removeObject:item];
        } else {
            [self.selectItems addObject:item];
        }
        BOOL canDelete = self.selectItems.count > 0;
        BOOL canEdit = self.selectItems.count == 1;
        BOOL canDownload = canDelete;
        BOOL canMove = canDelete;
        BOOL canCopy = canDelete;
        for (MSGraphDriveItem * item in self.selectItems) {
            if (item.folder) {
                canDownload = NO;
                canCopy = NO;
                break;
            }
        }
        _downloadBBI.enabled = canDownload;
        _deleteBBI.enabled = canDelete;
        _editBBI.enabled = canEdit;
        _coBBI.enabled = canCopy;
        _moveBBI.enabled = canMove;
        [self.tableView reloadData];
    }
}

#pragma mark - ---------------- UIImagePickerControllerDelegate ---------------

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    PHAsset * asset = info[UIImagePickerControllerPHAsset];
    PHAssetResource * resource = [PHAssetResource assetResourcesForAsset:asset].firstObject;
 
    NSString * url = [NSTemporaryDirectory() stringByAppendingPathComponent:resource.originalFilename];
    NSURL * fileUrl = [NSURL fileURLWithPath:url];
    [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource toFile:fileUrl options:nil completionHandler:^(NSError * _Nullable error) {
        [self graphUploadFile:fileUrl fileName:resource.originalFilename];
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Lazy Load

- (NSMutableArray *)selectItems {
    if (!_selectItems) {
        _selectItems = [[NSMutableArray alloc] init];
    }
    return _selectItems;
}

- (NSMutableArray *)driveItems {
    if (!_driveItems) {
        _driveItems = [[NSMutableArray alloc] init];
    }
    return _driveItems;
}

@end
