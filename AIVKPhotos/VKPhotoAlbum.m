//
//  VKPhotoAlbum.m
//  AIVKPhotos
//
//  Created by Alexey Ivanov on 20.03.16.
//  Copyright © 2016 Alexey Ivanov. All rights reserved.
//

#import "VKPhotoAlbum.h"

@implementation VKPhotoAlbum

@end

@implementation VKPhotoAlbums

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    return [super initWithDictionary:dict objectClass:[VKPhotoAlbum class]];
}

@end