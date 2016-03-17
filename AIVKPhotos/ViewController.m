//
//  ViewController.m
//  AIVKPhotos
//
//  Created by Alexey Ivanov on 17.03.16.
//  Copyright © 2016 Alexey Ivanov. All rights reserved.
//

#import "ViewController.h"
#import "VKSdk.h"

#define VK_APP_ID @"5360356"

@interface ViewController () <VKSdkDelegate,VKSdkUIDelegate>
@property VKSdk * vksdk;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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
                } errorBlock:^(NSError *error) {
                    
                }];
            }

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
