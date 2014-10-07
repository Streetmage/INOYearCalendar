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

#import "Event.h"

@implementation Event

@dynamic eventCategory;
@dynamic eventDate;

+ (NSArray *)eventsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate inContext:(NSManagedObjectContext *)context {
 
    NSEntityDescription *eventEntity = [NSEntityDescription entityForName:NSStringFromClass([Event class]) inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:eventEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventDate >= %@ AND eventDate <= %@", fromDate, toDate];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *events = [context executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Error during %@ objects fetch: %@", [Event class], [error userInfo]);
    }
 
    return events;
}

@end
