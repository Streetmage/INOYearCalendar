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

#import "NSDate+INOHelpers.h"

@implementation NSDate (INOHelpers)

- (NSCalendar *)calendar {
    return [NSCalendar currentCalendar];
}

- (NSDate *)clippedDateWithCalendarUnits:(NSCalendarUnit)calendarUnit {
    NSDateComponents *components = [self.calendar components:calendarUnit fromDate:self];
    return [self.calendar dateFromComponents:components];
}

- (NSDate *)dateByAddingValue:(NSUInteger)value forDateKey:(NSString *)key {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setValue:@(value) forKey:key];
    return [self.calendar dateByAddingComponents:dateComponents toDate:self options:0];
}

- (NSUInteger)daysInMonth {
    NSRange range = [self.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self];
    return range.length;
}

- (NSUInteger)dayOfWeek {
    NSDateComponents *dateComponents = [self.calendar components:NSWeekdayCalendarUnit fromDate:self];
    return ([dateComponents weekday] - [self.calendar firstWeekday]) % 7;
}

- (NSDate *)beginningOfDay {
    return [self clippedDateWithCalendarUnits:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit];
}

- (NSDate *)endOfDay {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    return [[self.calendar dateByAddingComponents:components toDate:[self beginningOfDay] options:0] dateByAddingTimeInterval:-1];
}

- (NSDate *)beginningOfMonth {
    return [self clippedDateWithCalendarUnits:NSYearCalendarUnit | NSMonthCalendarUnit];
}

- (NSDate *)endOfMonth {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:1];
    return [[self.calendar dateByAddingComponents:components toDate:[self beginningOfMonth] options:0] dateByAddingTimeInterval:-1];
}

- (NSDate *)beginningOfYear {
    return [self clippedDateWithCalendarUnits:NSYearCalendarUnit];
}

- (NSDate *)endOfYear {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:1];
    return [[self.calendar dateByAddingComponents:components toDate:[self beginningOfYear] options:0] dateByAddingTimeInterval:-1];
}

@end
