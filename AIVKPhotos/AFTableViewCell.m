//
//  AFTableViewCell.m
//  AFTabledCollectionView
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import "AFTableViewCell.h"

@implementation AFIndexedCollectionView

@end

@implementation AFTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    [self commonInit];

    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.itemSize = CGSizeMake(80, 80);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[AFIndexedCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    //    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"AIVKPhotoCollectionViewCell" bundle:[NSBundle mainBundle]]
          forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    
    [self.contentView addSubview:self.collectionView];

}
-(void)prepareForReuse
{
    [self.collectionView setContentOffset:CGPointMake(0.0, 0.0)];
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = self.contentView.bounds;
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.indexPath = indexPath;
    
    [self.collectionView reloadData];
}

@end
