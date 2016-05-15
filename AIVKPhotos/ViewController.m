//
//  ViewController.m
//  AIVKPhotos
//
//  Created by Alexey Ivanov on 17.03.16.
//  Copyright © 2016 Alexey Ivanov. All rights reserved.
//

#import "ViewController.h"
#import "VKSdk.h"
#import "AITableViewCell.h"
#import "AIVKPhotoCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "VKPhotoAlbum.h"

#define VK_APP_ID @"5360356"

@interface ViewController () <VKSdkDelegate,VKSdkUIDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property VKSdk * vksdk;
@property (nonatomic,strong) VKPhotoAlbums* photoAlbums;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //setup tableview
    [self.tableView registerNib:[UINib nibWithNibName:@"AITableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"tableCellId"];
    [self createRefreshControl];
    
    //setup VK sdk and wake up session
    [self prepareVKSdk];
}

-(void)prepareVKSdk
{
    self.vksdk = [VKSdk initializeWithAppId:VK_APP_ID];
    [self.vksdk registerDelegate:self];
    self.vksdk.uiDelegate = self;
    
    NSArray *SCOPE = @[@"photos"];
    [VKSdk wakeUpSession:SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
        if (error) {
            NSLog(@"error to wakeUpSession %@",error);
            return;
        }
        
        switch (state) {
            case VKAuthorizationAuthorized:
                [self loadPhotos];
                break;
            case VKAuthorizationInitialized:
                [VKSdk authorize:SCOPE withOptions:VKAuthorizationOptionsDisableSafariController];
                break;
            default:
                break;
        }
    }];
}

#pragma mark - UITableViewDataSource
#pragma mark - UITableViewDataSource Methods


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photoAlbums.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tableCellId";
    
    AITableViewCell *cell = (AITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[AITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    VKPhotoAlbum* album = self.photoAlbums[indexPath.row];
    cell.albumNameLabel.text = album.title;
    cell.descriptionLabel.text = [NSString stringWithFormat:@"%ld photos",album.photos.count];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(AITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
//    NSInteger index = cell.collectionView.tag;
    
//    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
//    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger collectionViewIndex = [(AIIndexedCollectionView*)collectionView indexPath].row;
    VKPhotoAlbum* album =[self.photoAlbums objectAtIndex:collectionViewIndex];

    return album.photos.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AIVKPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier
                                                                           forIndexPath:indexPath];
    
    NSUInteger collectionViewIndex = [(AIIndexedCollectionView*)collectionView indexPath].row;
    
    VKPhotoAlbum* album = [self photoAlbumAtIndex:collectionViewIndex];
    VKPhoto* photo = [self photoFromAlbum:album atIndex:indexPath.row];
    VKPhotoSize* photoSize = [photo.sizes photoSizeWithType:@"x"];
    
    [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:photoSize.src]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    
                              }];
    
    
    return cell;
}

#pragma mark - UICollectionView Delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSUInteger collectionViewIndex = [(AIIndexedCollectionView*)collectionView indexPath].row;
    VKPhotoAlbum* album = [self photoAlbumAtIndex:collectionViewIndex];
    VKPhoto* photo = [self photoFromAlbum:album atIndex:indexPath.row];
    VKPhotoSize* photoSize = [photo.sizes photoSizeWithType:@"x"];
    NSLog(@"did select photo %@ with url %@",photo,photoSize.src);
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger collectionViewIndex = [(AIIndexedCollectionView*)collectionView indexPath].row;
    VKPhotoAlbum* album =[self.photoAlbums objectAtIndex:collectionViewIndex];
    VKPhoto* photo = album.photos[indexPath.row];
    VKPhotoSize* photoSize = [photo.sizes photoSizeWithType:@"x"];
    //NOTE that we can have width/height == 0 and size with 0 devided to 0 will give exeption
    if (photoSize.width.integerValue == 0) {
        return CGSizeMake(collectionView.contentSize.height, collectionView.contentSize.height);
    }
    CGFloat scaleFactor = photoSize.height.floatValue / collectionView.contentSize.height;
    CGSize size = CGSizeMake(photoSize.width.floatValue /scaleFactor, collectionView.contentSize.height);
   
    return size;
}

#pragma mark - Accessors

-(VKPhotoAlbum*)photoAlbumAtIndex:(NSUInteger)index
{
    if (index == NSNotFound || index >= self.photoAlbums.count) {
        return nil;
    }
    VKPhotoAlbum*album = [self.photoAlbums objectAtIndex:index];
    return album;
}

-(VKPhoto*)photoFromAlbum:(VKPhotoAlbum*)album atIndex:(NSUInteger)index
{
    if (index == NSNotFound || index >= album.photos.count) {
        return nil;
    }
    
    return [album.photos objectAtIndex:index];;
}

#pragma mark - VK API


-(void)getAlbumsAndPhotosWithCompletionBlock:(void(^)(NSError* error))completionBlock
{
    VKRequest* photoAlbumsRequest = [VKApi requestWithMethod:@"photos.getAlbums" andParameters:@{}];
    
    [photoAlbumsRequest executeWithResultBlock:^(VKResponse *response) {
   
        self.photoAlbums = [[VKPhotoAlbums alloc] initWithDictionary:response.json];
    
        dispatch_group_t photosInAlbumDispatchGroup = dispatch_group_create();

        for (VKPhotoAlbum* album in self.photoAlbums) {
            dispatch_group_enter(photosInAlbumDispatchGroup);
            
            NSNumber* ownerId = album.owner_id;
            NSNumber* albumId = album.id;
            VKRequest* photosReq = [[VKApi photos] prepareRequestWithMethodName:@"get" parameters:@{@"owner_id": ownerId,
                                                                                                    @"album_id": albumId,
                                                                                                    @"photo_sizes":@(1)
                                                                                                    }];
            
            [photosReq executeWithResultBlock:^(VKResponse *response) {
                VKPhotoArray * photos = [[VKPhotoArray alloc] initWithDictionary:response.json];
                //add photos into photo album
                album.photos = photos;
                
                dispatch_group_leave(photosInAlbumDispatchGroup);
                
            } errorBlock:^(NSError *error) {
                NSLog(@"error to get photos in album %@",album.id.stringValue);
                
                dispatch_group_leave(photosInAlbumDispatchGroup);
            }];
        }
        
        dispatch_group_notify(photosInAlbumDispatchGroup, dispatch_get_main_queue(),^{
            if (completionBlock) {
                completionBlock(nil);
            }
        });
        
    } errorBlock:^(NSError *error) {
        if (completionBlock) {
            completionBlock(error);
        }
    }];
    

}


-(void)didLoadPhotoAlbums:(NSError*)error
{
    [self.refreshControl endRefreshing];
    if (error) {
        //show error HUD
        return;
    }
    [self.tableView reloadData];
}

#pragma mark - RefreshControl

- (void)createRefreshControl {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadPhotos) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

-(void)loadPhotos
{
    //TODO: add and show loading activity indicator
    [self clearContent];
    
    [self getAlbumsAndPhotosWithCompletionBlock:^(NSError *error) {
        [self didLoadPhotoAlbums:error];
    }];
}

-(void)clearContent
{
    self.photoAlbums = nil;
    [self.tableView reloadData];
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - VKSdkDelegate

-(void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result
{
    //TODO: check at first time when auth finished
    switch (result.state) {
        case VKAuthorizationAuthorized:
            [self loadPhotos];
            break;
            
        default:
            break;
    }
}

-(void)vkSdkUserAuthorizationFailed
{
    NSLog(@"vkSdkUserAuthorizationFailed");
}

#pragma mark - VKSdkUIDelegate

-(void)vkSdkShouldPresentViewController:(UIViewController *)controller
{
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)vkSdkNeedCaptchaEnter:(VKError *)captchaError
{
    VKCaptchaViewController * captcha = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [self presentViewController:captcha animated:YES completion:nil];
}

@end
