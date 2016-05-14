//
//  AITableViewCell.m
//  AIVKPhotos
//
//  Created by Alexey Ivanov on 20.03.16.
//  Copyright © 2016 Alexey Ivanov. All rights reserved.
//

#import "AITableViewCell.h"

@implementation AIIndexedCollectionView


@end


@implementation AITableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self commonInit];
}

-(void)commonInit
{
    [self.collectionView registerNib:[UINib nibWithNibName:@"AIVKPhotoCollectionViewCell" bundle:[NSBundle mainBundle]]
          forCellWithReuseIdentifier:CollectionViewCellIdentifier];
}


- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>)dataSourceDelegate
                                 indexPath:(NSIndexPath *)indexPath
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.indexPath = indexPath;
    
    [self.collectionView reloadData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
