//
//  FilesSearchController.m
//  OneDriveDemo
//
//  Created by Rex on 2021/3/17.
//

#import "FilesSearchController.h"
#import "FilesSearchCell.h"

#import "UIImageView+WebCache.h"
#import "RXNetworking.h"
#import "YXHUD.h"

#import "MSAL.h"
#import "MSConstants.h"
#import "MSCollection.h"
#import "MSGraphClientModels.h"

@interface FilesSearchController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// 界面使用的元素数组
@property (nonatomic, strong) NSMutableArray * driveItems;

@end

@implementation FilesSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"搜索内容";
    self.searchTF.returnKeyType = UIReturnKeySearch;
}

- (void)graphSearchItem:(NSString *)keyword {
    NSString * graphAPI = [NSString stringWithFormat:@"%@/me/drive/items/%@/search(q='%@')?expand=thumbnails", MSGraphBaseURL, self.driveItemId, keyword];
    [YXHUD show];
    [[RXNetworking shared] Get_Params:nil Url:graphAPI Token:self.token Completed:^(BOOL success, RXResponse *response) {
        if (!success) {
            [YXHUD showInfo:[NSString stringWithFormat:@"搜索内容失败：%@", response.object]];
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
            [YXHUD showInfo:@"没有搜索到相关内容"];
        } else {
            [YXHUD hide];
        }
        NSLog(@"搜索到的内容：%@", response.object);
    }];
}

#pragma mark - ------------------ UITextFieldDelegate -------------------

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    [self graphSearchItem:textField.text];
    return YES;
}

#pragma mark - ------------------ UITableViewDelegate -------------------

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FilesSearchCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FilesSearchCell" forIndexPath:indexPath];
    MSGraphDriveItem * item = self.driveItems[indexPath.row];
    cell.nameLabel.text = item.name;
    cell.thumbImageView.hidden = item.folder;
    if (item.thumbnails.count) {
        NSDictionary * thumbnail = item.thumbnails[0];
        NSString * url = thumbnail[@"small"][@"url"];
        [cell.thumbImageView sd_setImageWithURL:[NSURL URLWithString:url]];
    }
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
