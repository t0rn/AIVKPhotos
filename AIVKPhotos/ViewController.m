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


#define VK_APP_ID @"5360356"

@interface ViewController () <VKSdkDelegate,VKSdkUIDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property VKSdk * vksdk;
@property NSMutableDictionary* albums;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.albums = [NSMutableDictionary new];
    
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
    return self.albums.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tableCellId";
    
    AITableViewCell *cell = (AITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[AITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(AITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
//    NSInteger index = cell.collectionView.tag;
    
//    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
//    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}



#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSString* key = self.albums.allKeys[[(AIIndexedCollectionView *)collectionView indexPath].row];
    NSArray *collectionViewArray = self.albums[key];
    return collectionViewArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AIVKPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier
                                                                           forIndexPath:indexPath];
    
    NSString* key = self.albums.allKeys[[(AIIndexedCollectionView *)collectionView indexPath].row];
    NSArray *collectionViewArray = self.albums[key];
    
    VKPhoto* photo = collectionViewArray[indexPath.row];
    
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
            NSDictionary* jsonDict = (NSDictionary*)response.json;
            NSArray* albums = jsonDict[@"items"];
            if (albums == nil) {
                return;
            }
            ///////////////// requestssss
            for (NSDictionary* album in albums) {
                NSString* ownerId = album[@"owner_id"];
                NSString* albumId = album[@"id"];
                VKRequest* photosReq = [[VKApi photos] prepareRequestWithMethodName:@"get" parameters:@{@"owner_id": ownerId,
                                                                                                        @"album_id":albumId}];
                
                [photosReq executeWithResultBlock:^(VKResponse *response) {
                    VKPhotoArray * photos = [[VKPhotoArray alloc] initWithDictionary:response.json];
                    NSLog(@"photos %@",photos);
                    [self.albums setObject:photos forKey:album];
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
