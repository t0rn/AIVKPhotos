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

@interface ViewController () <VKSdkDelegate,VKSdkUIDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property VKSdk * vksdk;
@property (nonatomic,strong) VKPhotoAlbums* photoAlbums;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.vksdk = [VKSdk initializeWithAppId:VK_APP_ID];
    [self.vksdk registerDelegate:self];
    self.vksdk.uiDelegate = self;

    NSArray *SCOPE = @[@"photos"];
    
//    [self.tableView registerClass:[AITableViewCell class] forCellReuseIdentifier:@"tableCellId"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AITableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"tableCellId"];
    
    [VKSdk wakeUpSession:SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
        if (error) {
            NSLog(@"error to wakeUpSession %@",error);
            return;
        }
        
        switch (state) {
            case VKAuthorizationAuthorized:
                [self showPhotos];
                break;
            case VKAuthorizationInitialized:
                [VKSdk authorize:SCOPE withOptions:VKAuthorizationOptionsDisableSafariController];
                break;
            default:
                break;
        }
    }];
}

- (IBAction)refreshButtonPressed:(id)sender
{
    [self.tableView reloadData];
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
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
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
    VKPhotoAlbum* album =[self.photoAlbums objectAtIndex:collectionViewIndex];
    
    VKPhoto* photo = album.photos[indexPath.row];
    
    [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:photo.photo_130]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    
                              }];
    
    
    return cell;
}


#pragma mark - VK api
-(void)showPhotos
{
    VKRequest* photoAlbumsRequest = [VKApi requestWithMethod:@"photos.getAlbums" andParameters:@{}];
    
    [photoAlbumsRequest executeWithResultBlock:^(VKResponse *response) {
        if ([response.json isKindOfClass:[NSDictionary class]]) {
            self.photoAlbums = [[VKPhotoAlbums alloc] initWithDictionary:response.json];
        
            ///////////////// requestssss
            for (VKPhotoAlbum* album in self.photoAlbums) {
                NSLog(@"getting photos for album %@",album.id.stringValue);
                NSNumber* ownerId = album.owner_id;
                NSNumber* albumId = album.id;
                VKRequest* photosReq = [[VKApi photos] prepareRequestWithMethodName:@"get" parameters:@{@"owner_id": ownerId,
                                                                                                        @"album_id": albumId}];
                
                [photosReq executeWithResultBlock:^(VKResponse *response) {
                    VKPhotoArray * photos = [[VKPhotoArray alloc] initWithDictionary:response.json];
                    NSLog(@"got photos for album %@",album.id.stringValue);
                    album.photos = photos;
                    

                } errorBlock:^(NSError *error) {
                    
                }];
            }

            //TODO: dispatch group for one callback
        }
    } errorBlock:^(NSError *error) {
        
    }];
    

}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - VKSdkDelegate

-(void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result
{
    switch (result.state) {
        case VKAuthorizationAuthorized:
            [self showPhotos];
            break;
            
        default:
            break;
    }
}
-(void)vkSdkUserAuthorizationFailed
{
    
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
