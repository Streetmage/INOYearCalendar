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

#import "INOMonthView.h"
#import "INOMonthGlyphsHelper.h"
#import "INOMonthImageFactory.h"

@interface INOMonthView ()

// Data
@property (nonatomic, strong) NSDate *monthDate;

// View
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation INOMonthView

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_imageView setFrame:self.bounds];
    
}

#pragma mark - Public Methods

- (void)setupWithMonthDate:(NSDate *)monthDate {
    _monthDate = monthDate;
    [_imageView setImage:[[INOMonthImageFactory sharedFactory] monthImageWithDate:_monthDate ofSize:self.bounds.size]];
}

- (void)setupWithMonthImage:(UIImage *)monthImage {
    [_imageView setImage:monthImage];
}

@end
