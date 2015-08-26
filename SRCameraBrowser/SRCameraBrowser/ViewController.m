//
//  ViewController.m
//  SRCameraBrowser
//
//  Created by SarielTang on 15/8/24.
//  Copyright (c) 2015年 Sariel. All rights reserved.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import "SRCameraController.h"
#import "SRPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <Photos/PHFetchResult.h>

@interface ViewController ()<UIActionSheetDelegate,SRPhotoBrowserDelegate>
{
    UIButton *_uploadBtn;
}
@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, strong) ALAssetsLibrary *ALAssetsLibrary;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [[UIButton alloc]init];
    _uploadBtn = btn;
    [self.view addSubview:btn];
    [btn setBackgroundImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    [self loadAssets];
}

- (void)btnClick:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"上传图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"照相机" otherButtonTitles:@"从相册选择", nil];
    actionSheet.tag = 200;
    [actionSheet showFromRect:CGRectMake(160, 568, 320, 120) inView:self.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag==200)
    {
        switch (buttonIndex)
        {
            case 0://拍照
                NSLog(@"拍照");
                //判断相机、相册是否可用
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"相机无法使用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                }
                else
                {
                    SRCameraController *vc = [[SRCameraController alloc]init];
                    vc.uploadBtn = _uploadBtn;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                break;
            case 1://从相册选择
                NSLog(@"从相册选择");
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
                {
                    NSLog(@"图片库可用");
                    SRPhotoBrowser *vc = [[SRPhotoBrowser alloc]init];
                    vc.assets = _assets;
                    vc.delegate = self;
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"图片库不可用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                }
                break;
            case 2://取消
            {
                
            }
                break;
                
            default:
                break;
        }
    }
    
}

- (void)didSelectSomePhotos:(SRPhotoBrowser *)vc photos:(NSArray *)photos {
    NSLog(@"得到选中的照片:%@",photos);
    if (photos != nil) {
        [_uploadBtn setImage:photos[0] forState:UIControlStateNormal];
    }
}

#pragma mark - Load Assets

- (void)loadAssets {
    if (NSClassFromString(@"PHAsset")) {
        
        // Check library permissions
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self performLoadAssets];
                }
            }];
        } else if (status == PHAuthorizationStatusAuthorized) {
            [self performLoadAssets];
        }
        
    } else {
        
        // Assets library
        [self performLoadAssets];
        
    }
}

- (void)performLoadAssets {
    
    // Initialise
    _assets = [NSMutableArray new];
    
    // Load
    if (NSClassFromString(@"PHAsset")) {
        
        // Photos library iOS >= 8
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PHFetchOptions *options = [PHFetchOptions new];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHFetchResult *fetchResults = [PHAsset fetchAssetsWithOptions:options];
            [fetchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [_assets addObject:obj];
            }];
        });
        
    } else {
        
        // Assets Library iOS < 8
        _ALAssetsLibrary = [[ALAssetsLibrary alloc] init];
        
        // Run in the background as it takes a while to get all assets from the library
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
            NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
            
            // Process assets
            void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    NSString *assetType = [result valueForProperty:ALAssetPropertyType];
                    if ([assetType isEqualToString:ALAssetTypePhoto] || [assetType isEqualToString:ALAssetTypeVideo]) {
                        [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                        NSURL *url = result.defaultRepresentation.url;
                        [_ALAssetsLibrary assetForURL:url
                                          resultBlock:^(ALAsset *asset) {
                                              if (asset) {
                                                  @synchronized(_assets) {
                                                      [_assets addObject:asset];
                                                  }
                                              }
                                          }
                                         failureBlock:^(NSError *error){
                                             NSLog(@"operation was not successfull!");
                                         }];
                        
                    }
                }
            };
            
            // Process groups
            void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
                if (group != nil) {
                    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                    [assetGroups addObject:group];
                }
            };
            
            // Process!
            [_ALAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                            usingBlock:assetGroupEnumerator
                                          failureBlock:^(NSError *error) {
                                              NSLog(@"There is an error");
                                          }];
            
        });
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
