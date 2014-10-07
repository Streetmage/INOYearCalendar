//
// Copyright 2014 Inostudio Solutions
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "INOYearTableCell.h"
#import "INOMonthView.h"

static NSUInteger const kMonthsInSingleYear           = 12;
static NSUInteger const kNumberOfMonthsInSingleRow    = 3;
static NSUInteger const kNumberOfMonthsInSingleColumn = kMonthsInSingleYear / kNumberOfMonthsInSingleRow;

static NSDateFormatter *yearFormatter = nil;

static CGFloat const kYearTitleHeight = 30.0f;
static CGFloat const kDefaultMargin   = 5.0f;

@interface INOYearTableCell ()

// Data
@property (nonatomic, strong) NSDate  *yearDate;

// View
@property (nonatomic, strong) UILabel *yearLabel;
@property (nonatomic, strong) UIView  *monthsHolder;
@property (nonatomic, strong) NSArray *monthsViews;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation INOYearTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if (!yearFormatter) {
            yearFormatter = [[NSDateFormatter alloc] init];
            [yearFormatter setDateFormat:@"YYYY"];
        }
        
        _yearLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_yearLabel];
        
        _monthsHolder = [[UIView alloc] init];
        [self.contentView addSubview:_monthsHolder];
        
        NSMutableArray *mutableMonthViews = [NSMutableArray array];
        for (NSUInteger i = 0; i < kMonthsInSingleYear; i++) {
            INOMonthView *monthView = [[INOMonthView alloc] init];
            [_monthsHolder addSubview:monthView];
            [mutableMonthViews addObject:monthView];
        }
        _monthsViews = [NSArray arrayWithArray:mutableMonthViews];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] init];
        [_activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_activityIndicator setColor:[UIColor orangeColor]];
        [_monthsHolder addSubview:_activityIndicator];
        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_yearLabel setFrame:CGRectMake(kDefaultMargin,
                                    kDefaultMargin,
                                    self.frame.size.width - 2 * kDefaultMargin,
                                    kYearTitleHeight)];
    
    CGFloat monthsHolderTopMargin = kDefaultMargin + CGRectGetMaxY(_yearLabel.frame);
    CGSize monthsHolderSize = [INOYearTableCell monthsHolderSize];
    [_monthsHolder setFrame:CGRectMake(kDefaultMargin,
                                       monthsHolderTopMargin,
                                       monthsHolderSize.width,
                                       monthsHolderSize.height)];
    
    CGSize monthViewSize = [INOYearTableCell monthViewSize];
    [_monthsViews enumerateObjectsUsingBlock: ^(INOMonthView *monthView, NSUInteger idx, BOOL *stop) {
        [monthView setFrame:CGRectMake((monthViewSize.width + kDefaultMargin) * (idx % kNumberOfMonthsInSingleRow),
                                       (monthViewSize.height + kDefaultMargin) * (idx / kNumberOfMonthsInSingleRow),
                                       monthViewSize.width,
                                       monthViewSize.height)];
    }];
    
    [_activityIndicator setCenter:CGPointMake(_monthsHolder.center.x, _monthsHolder.center.y - 50.0f)];
}

#pragma mark - Accessors

- (void)setLoadingInProgress:(BOOL)loadingInProgress {
    _loadingInProgress = loadingInProgress;
    if (_loadingInProgress) {
        [_activityIndicator startAnimating];
    } else {
        [_activityIndicator stopAnimating];
    }
}

#pragma mark - Public Methods

- (void)setupWithYearDate:(NSDate *)yearDate {
    _yearDate = [yearDate beginningOfYear];
    [_yearLabel setText:[yearFormatter stringFromDate:_yearDate]];
    [_monthsViews enumerateObjectsUsingBlock: ^(INOMonthView *monthView, NSUInteger idx, BOOL *stop) {
        [monthView setupWithMonthDate:[_yearDate dateByAddingValue:idx forDateKey:@"month"]];
    }];
}

- (void)setupWithMonthsImages:(NSArray *)monthsImages {
    if ([monthsImages count] == [_monthsViews count]) {
        [_monthsViews enumerateObjectsUsingBlock: ^(INOMonthView *monthView, NSUInteger idx, BOOL *stop) {
            [monthView setupWithMonthImage:[monthsImages objectAtIndex:idx]];
        }];
    }
}

+ (CGFloat)cellHeight {
    return 450.0f;
}

+ (CGSize)monthViewSize {
   
    CGSize monthsHolderSize = [INOYearTableCell monthsHolderSize];
    return CGSizeMake((monthsHolderSize.width - (kNumberOfMonthsInSingleRow - 1) * kDefaultMargin) / kNumberOfMonthsInSingleRow,
                      (monthsHolderSize.height - (kNumberOfMonthsInSingleColumn - 1) * kDefaultMargin) / kNumberOfMonthsInSingleColumn);
}

+ (CGSize)monthsHolderSize {
    return CGSizeMake([UIApplication sharedApplication].delegate.window.frame.size.width - 2 * kDefaultMargin,
                      [INOYearTableCell cellHeight] - kYearTitleHeight - 2 * kDefaultMargin);
}

@end
