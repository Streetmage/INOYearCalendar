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

#import "INOAppDelegate.h"
#import "INOYearTableController.h"
#import "Event.h"

@implementation INOAppDelegate

@synthesize managedObjectContext       = _managedObjectContext;
@synthesize managedObjectModel         = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self managedObjectContext];
    [self createTestEvents];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    INOYearTableController *yearController = [[INOYearTableController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:yearController];
    [navController.navigationBar setTranslucent:NO];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - CoreData Helpers

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
	
	_managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"YearCalendarModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSAssert([_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error],
             @"NSPersistentStoreCoordinator error: %@", [error userInfo]);
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Sample Helpers

- (void)createTestEvents {
    
    const NSUInteger secondsInSingleYear = 31556926;
    const NSUInteger yearsToPopulate     = 50;
    const NSUInteger eventsCount         = 1000;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    NSInteger count = [self.managedObjectContext countForFetchRequest:request error:nil];
    
    if (count < eventsCount) {
        for (NSUInteger i = count; i < eventsCount; i++) {
            
            Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
            
            [event setEventCategory:@(arc4random() % 4)];
            [event setEventDate:[NSDate dateWithTimeIntervalSinceNow:arc4random() % (secondsInSingleYear * yearsToPopulate)]];
            
            NSError *error = nil;
            [event.managedObjectContext save:&error];
            NSAssert(!error, @"Error while saving event: %@", [error userInfo]);
        }
    }
}

@end
