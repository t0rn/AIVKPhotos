//
//  AITableViewCell.h
//  AIVKPhotos
//
//  Created by Alexey Ivanov on 20.03.16.
//  Copyright © 2016 Alexey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AIIndexedCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface AITableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet AIIndexedCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;


- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate
                                  indexPath:(NSIndexPath *)indexPath;


@end
