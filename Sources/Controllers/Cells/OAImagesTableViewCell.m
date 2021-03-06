//
//  OAImagesTableViewCell.m
//  OsmAnd Maps
//
//  Created by nnngrach on 09.06.2021.
//  Copyright © 2021 OsmAnd. All rights reserved.
//

#import "OAImagesTableViewCell.h"
#import "OAImagesCollectionViewCell.h"

@implementation OAImagesTableViewCell
{
    int _imageIndex;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:[OAImagesCollectionViewCell getCellIdentifier] bundle:nil] forCellWithReuseIdentifier:[OAImagesCollectionViewCell getCellIdentifier]];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [_collectionView setCollectionViewLayout:layout];
    [_collectionView setShowsHorizontalScrollIndicator:NO];
    [_collectionView setShowsVerticalScrollIndicator:NO];
    _pageControl.hidesForSinglePage = YES;
    _imageIndex = 0;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height);
    _collectionViewWidth.constant = self.superview.frame.size.width;
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_imageIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    _pageControl.frame = CGRectMake(0, _collectionViewHeight.constant - 30, self.superview.frame.size.width, 30);
}

- (void)setImages:(NSArray<UIImage *> *)images
{
    _images = images;
    _pageControl.numberOfPages = _images.count;
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _images.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OAImagesCollectionViewCell* cell = nil;
    cell = (OAImagesCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[OAImagesCollectionViewCell getCellIdentifier] forIndexPath:indexPath];
    cell.imageView.image = _images[indexPath.row];
    return cell;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
   sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_collectionViewWidth.constant, _collectionViewHeight.constant);
}

- (CGPoint)collectionView:(UICollectionView *)collectionView targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
{
    return CGPointMake(_imageIndex * _collectionView.frame.size.width, 0);
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    _imageIndex = [self getCurrentIndex];
    _pageControl.currentPage = _imageIndex;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _imageIndex = [self getCurrentIndex];
    _pageControl.currentPage = _imageIndex;
}

- (int) getCurrentIndex
{
    return (int) _collectionView.contentOffset.x / _collectionView.frame.size.width;
}

@end

