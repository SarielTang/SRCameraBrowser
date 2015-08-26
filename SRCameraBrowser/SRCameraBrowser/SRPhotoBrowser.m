//
//  SRPhotoBrowser.m
//  SRCameraBrowser
//
//  Created by SarielTang on 15/8/26.
//  Copyright (c) 2015年 Sariel. All rights reserved.
//

#import "SRPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>

@interface SRPhotoBrowser ()<MWPhotoBrowserDelegate>
{
    NSMutableArray *_Photos;
    NSMutableArray *_selections;
}
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, strong) ALAssetsLibrary *ALAssetsLibrary;

@end

@implementation SRPhotoBrowser

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadAssets];
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    BOOL autoPlayOnAppear = NO;
    
    @synchronized(_assets) {
        NSMutableArray *copy = [_assets copy];
        if (NSClassFromString(@"PHAsset")) {
            // Photos library
            UIScreen *screen = [UIScreen mainScreen];
            CGFloat scale = screen.scale;
            // Sizing is very rough... more thought required in a real implementation
            CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
            CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
            CGSize thumbTargetSize = CGSizeMake(imageSize / 3.0 * scale, imageSize / 3.0 * scale);
            for (PHAsset *asset in copy) {
                [photos addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
                [thumbs addObject:[MWPhoto photoWithAsset:asset targetSize:thumbTargetSize]];
            }
        } else {
            // Assets library
            for (ALAsset *asset in copy) {
                MWPhoto *photo = [MWPhoto photoWithURL:asset.defaultRepresentation.url];
                [photos addObject:photo];
                MWPhoto *thumb = [MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]];
                [thumbs addObject:thumb];
                if ([asset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo) {
                    photo.videoURL = asset.defaultRepresentation.url;
                    thumb.isVideo = true;
                }
            }
        }
    }
    
    self.photos = photos;
    self.thumbs = thumbs;
    
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = autoPlayOnAppear;
    [browser setCurrentPhotoIndex:0];
    // Reset selections
    if (displaySelectionButtons) {
        _selections = [NSMutableArray new];
        for (int i = 0; i < photos.count; i++) {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
    // Push
    [self.navigationController pushViewController:browser animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
