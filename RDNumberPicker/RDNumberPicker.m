//
//  RDNumberPicker.m
//  RDNumberPicker
//
//  Created by Ricky Dunn on 24/06/2015.
//  Copyright (c) 2015 BoldRocket. All rights reserved.
//

#import "RDNumberPicker.h"
#import "RDNumberCell.h"

static NSString *cellIdentifier = @"RDSelectableNumberCell";
static CGFloat cellSize = 50.0f;

@interface RDNumberPicker () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign, readwrite) NSInteger currentValue;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UIView *maskView;

@end

@implementation RDNumberPicker

#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self commonInit];
}

- (void)commonInit
{
    // Create Collection View
    CGRect collectionFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    // Flow Layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    // CollectionView Setup
    _collectionView = [[UICollectionView alloc] initWithFrame:collectionFrame collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView setShowsHorizontalScrollIndicator:NO];
    [_collectionView setShowsVerticalScrollIndicator:NO];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView setPagingEnabled:NO];
    [self addSubview:_collectionView];
    
    // XIB
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([RDNumberCell class]) bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:cellIdentifier];
    
    // Selection Mask (the round circle in the middle)
    #if !TARGET_INTERFACE_BUILDER
        [self renderMask];
    #endif
    
    // Create the number objects and populate array
    [self initNumbersList];
    
    // Highlight the default cell
    [self highlightNumberWithValue:self.defaultValue animated:NO];
}

- (void)initNumbersList
{    
    // Set a default upper value if none set by the user
    if (!_maximumValue) {
        _maximumValue = 10;
    }
    
    NSMutableArray *arrayOfNumbers = [NSMutableArray array];
    for (NSInteger i = self.minimumValue; i <= self.maximumValue; i++) {
        [arrayOfNumbers addObject:@(i)];
    }
    
    self.currentValue = [[arrayOfNumbers firstObject] integerValue];
    self.numbersList = [arrayOfNumbers mutableCopy];
}

- (void)renderMask
{
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [_maskView setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)]; // position in centre of view
    [_maskView setBackgroundColor:[UIColor clearColor]];
    [_maskView.layer setBorderColor:self.selectedColor.CGColor];
    [_maskView.layer setBorderWidth:2.0f];
    [_maskView.layer setCornerRadius:_maskView.frame.size.height / 2];
    [_maskView setUserInteractionEnabled:NO]; // pass through touches
    [self addSubview:_maskView];
}

#pragma mark - RDNumberPicker
- (void)highlightNumberWithValue:(NSInteger)valueToFind animated:(BOOL)animated
{
    NSNumber *numberToFind = @(valueToFind);
    NSInteger valueFoundAtIndex = [self.numbersList indexOfObject:numberToFind];
    
    if (valueFoundAtIndex != NSNotFound) {
        [self highlightNumberAtIndex:valueFoundAtIndex animated:animated];
    }
}

- (void)highlightNumberAtIndex:(NSInteger)index animated:(BOOL)animated
{
    if (self.numbersList.count > index && [self.numbersList objectAtIndex:index] != nil) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    }
}

#pragma mark - UICollectionViewDelegate / UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.numbersList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RDNumberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSNumber *number = self.numbersList[indexPath.row];
    UIColor *labelColor = indexPath.row == self.currentPage ? self.selectedColor : self.unselectedColor;
    [cell configureCellWithNumber:number withColor:labelColor];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self highlightNumberAtIndex:indexPath.row animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cellSize, cellSize);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat inset = (self.frame.size.width - cellSize) / 2;
    return UIEdgeInsetsMake(0, inset, 0, inset);
}

#pragma mark - Setters
- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    self.maskView.layer.borderColor = selectedColor.CGColor;
    [self.collectionView reloadData];
}

- (void)setUnselectedColor:(UIColor *)unselectedColor
{
    _unselectedColor = unselectedColor;
    [self.collectionView reloadData];
}

- (void)setMinimumValue:(NSInteger)minimumValue
{
    _minimumValue = minimumValue;
    [self initNumbersList];
}

- (void)setMaximumValue:(NSInteger)maximumValue
{
    _maximumValue = maximumValue;
    [self initNumbersList];
}

- (void)setDefaultValue:(NSInteger)defaultValue
{
    _defaultValue = defaultValue;
    [self highlightNumberWithValue:self.defaultValue animated:NO];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint point = *targetContentOffset;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat visibleWidth = layout.minimumInteritemSpacing + layout.itemSize.width;
    
    NSInteger indexOfItemToSnap = round(point.x / visibleWidth);
    
    if (indexOfItemToSnap + 1 == [self.collectionView numberOfItemsInSection:0]) {
        *targetContentOffset = CGPointMake(self.collectionView.contentSize.width - self.bounds.size.width, 0);
    } else {
        *targetContentOffset = CGPointMake(indexOfItemToSnap * visibleWidth, 0);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat visibleWidth = layout.minimumInteritemSpacing + layout.itemSize.width;
    NSInteger page = floor((self.collectionView.contentOffset.x - visibleWidth / 2) / visibleWidth) + 1;
    
    // As the user can potentially use bounce to drag a little further we need to make sure we're in bounds
    if (page != self.currentPage && page >= 0 && page < self.numbersList.count) {
        self.currentPage = page;
        self.currentValue = [self.numbersList[page] integerValue];
        [self.collectionView reloadData];
        
        if ([self.numberPickerDelegate respondsToSelector:@selector(numberPicker:didPickNumber:atIndex:)]) {
            [self.numberPickerDelegate numberPicker:self didPickNumber:self.currentValue atIndex:self.currentPage];
        }
    }
}

#pragma mark - Private
- (void)prepareForInterfaceBuilder
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = self.selectedColor;
    label.text = @"1";
    [self addSubview:label];
    [self renderMask];
}

@end
