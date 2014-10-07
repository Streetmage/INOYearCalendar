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

#import "INOYearModel.h"
#import "INOMonthImageFactory.h"
#import "INOOperationQueue.h"
#import "INOAppDelegate.h"

#import "Event.h"

static NSUInteger const kMonthsInSingleYear = 12;

@interface INOYearModel ()

@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, strong) INOOperationQueue *queue;

@end

@implementation INOYearModel

- (id)init {
    self = [super init];
    
    if (self) {
        
        _currentDate = [NSDate date];
    
        _queue = [[INOOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:1];
        
        [[INOMonthImageFactory sharedFactory] setColorsForEventCategories:@{@(0) : [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.4f],
                                                                            @(1) : [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.4f],
                                                                            @(2) : [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.4f],
                                                                            @(3) : [UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:0.4f]}];
        
    }
    
    return self;
}

#pragma mark - Public Methods

- (NSDate *)yearWithOffsetFromCurrentDate:(NSUInteger)offset {
    return [_currentDate dateByAddingValue:offset
                                forDateKey:@"year"];
}

- (void)makeMonthsImagesWithDate:(NSDate *)yearDate ofSize:(CGSize)size cancelTag:(NSUInteger)cancelTag completion:(Completion)completion {
    
    INOAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    INOOperation *operation = [[INOOperation alloc] initWithMainManagedObjectContext:[appDelegate managedObjectContext]];
    
    BlockOperation block = ^id(NSManagedObjectContext *privateContext, CancelObservingBlock isCancelled) {
        
        NSDate *beginningOfYear = [yearDate beginningOfYear];
        NSDate *endOfYear = [yearDate endOfYear];
        
        NSArray *events = [Event eventsFromDate:beginningOfYear toDate:endOfYear inContext:privateContext];
        
        NSMutableDictionary *eventsForDates = [NSMutableDictionary dictionary];
        for (Event *event in events) {
            
            NSDate *searchKey = [event.eventDate beginningOfDay];
            
            NSMutableArray *eventsForDay = [eventsForDates objectForKey:searchKey];
            
            if (!eventsForDay) {
                eventsForDay = [NSMutableArray array];
            }
            
            [eventsForDay addObject:event];
            
            [eventsForDates setObject:eventsForDay forKey:searchKey];
            
            if (isCancelled()) {
                return nil;
            }
            
        }
        
        NSMutableArray *monthsImages = [NSMutableArray array];
        for (NSUInteger i = 0; i < kMonthsInSingleYear; i++) {
            NSDate *monthDate = [beginningOfYear dateByAddingValue:i forDateKey:@"month"];
            UIImage *monthImage = [[INOMonthImageFactory sharedFactory] monthImageWithDate:monthDate ofSize:size eventsForDates:eventsForDates];
            if (monthImage) {
                [monthsImages addObject:monthImage];
            }
        }
        
        return [NSArray arrayWithArray:monthsImages];
        
    };
    
    Success success = ^( NSArray *monthsImages) {
        if (completion) {
            completion(YES, monthsImages);
        }
    };
    
    Failure failure = ^() {
        if (completion) {
            completion(NO, nil);
        }
    };
    
    [operation setupOpeationWithBlock:block success:success failure:failure];
    [operation setTag:cancelTag];
    
    [_queue addOperation:operation];
    
}

- (void)suspendLoadingOperations {
    [_queue setSuspended:YES];
}

- (void)proceedLoadingOperations {
    [_queue setSuspended:NO];
}

@end
