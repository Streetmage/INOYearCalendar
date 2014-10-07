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

#import "INOOperation.h"

@implementation INOOperation

@synthesize privateContext = _privateContext;

- (id)init {
    self = [super init];
    
    if (self) {
        
        _mainContext = nil;
        _privateContext = nil;
        _needsMergeChanges = NO;
        _needsSaveAfterExecution = NO;
        
    }
    
    return self;
}

- (id)initWithMainManagedObjectContext:(NSManagedObjectContext *)mainManagedObjectContext {
    self = [self init];
    
    if (self) {
        _mainContext = mainManagedObjectContext;
    }
    
    return self;
}

- (void)dealloc {
	
	if (_privateContext) {
		[[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSManagedObjectContextDidSaveNotification
                                                      object:_privateContext
		 ];
	}
    
}

#pragma mark - Public Methods

- (void)setupOpeationWithBlock:(BlockOperation)block success:(Success)success failure:(Failure)failure {
    _block = block;
    _success = success;
    _failure = failure;
}

- (void)main {
    @autoreleasepool {
        
        if ([self isCancelled] && _failure) {
            _failure();
            return;
        }
        
        if (_block) {
            
            __weak typeof(self) weakSelf = self;
            _data = _block([self privateContext], ^BOOL() {
                return [weakSelf isCancelled];
            });
            
            if (_needsSaveAfterExecution) {
                NSError *error = nil;
                if (![[self privateContext] save:&error]) {
                    NSLog(@"Saving error %@",error);
                }
            }
            
            if (![self isCancelled]) {
                if (_success) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        _success(_data);
                    });
                }
            } else {
                if (_failure) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        _failure();
                    });
                }
            }
            
        }
        
    }
}

- (NSManagedObjectContext *)privateContext {
    
	if( !_privateContext ){
		
		NSAssert([self mainContext], @"No Main context set in %@, cannot create private context!", self);
        
		_privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        [_privateContext performBlockAndWait: ^{
            [_privateContext setPersistentStoreCoordinator:[[self mainContext] persistentStoreCoordinator]];
        }];
        
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(privateContextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:_privateContext
		 ];
	}
	
	return _privateContext;
}

#pragma mark - Private Methods

- (void)privateContextDidSave:(NSNotification *)notification {
    if(_needsMergeChanges){
		NSManagedObjectContext *blockContext = _mainContext;
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[blockContext mergeChangesFromContextDidSaveNotification:notification];
		}];
	}
}

@end