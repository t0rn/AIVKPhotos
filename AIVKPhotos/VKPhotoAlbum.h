//
//  VKPhotoAlbum.h
//  AIVKPhotos
//
//  Created by Alexey Ivanov on 20.03.16.
//  Copyright © 2016 Alexey Ivanov. All rights reserved.
//

#import "VKSdk.h"
@class VKPhotoArray;
@interface VKPhotoAlbum : VKApiObject
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSNumber *thumb_id;
@property (nonatomic, strong) NSNumber *owner_id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *created;
@property (nonatomic, strong) NSNumber *updated;
@property (nonatomic, strong) NSNumber *size;
@property (nonatomic, strong) NSString *thumb_src;

@property (nonatomic, strong) VKPhotoArray* photos;
@end


@interface VKPhotoAlbums : VKApiObjectArray
@end