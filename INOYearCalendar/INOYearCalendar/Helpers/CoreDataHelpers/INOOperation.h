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

#import <Foundation/Foundation.h>

typedef BOOL(^CancelObservingBlock)();
typedef id(^BlockOperation)(NSManagedObjectContext *privateContext, CancelObservingBlock isCancelled);

typedef void(^Success)(id data);
typedef void(^Failure)();

@interface INOOperation : NSOperation

@property (nonatomic, readonly)	NSManagedObjectContext *mainContext;
@property (nonatomic, readonly) NSManagedObjectContext *privateContext;
@property (nonatomic, assign)	BOOL				    needsMergeChanges;
@property (nonatomic, assign)   BOOL                    needsSaveAfterExecution;

@property (nonatomic, readonly) id data;

@property (nonatomic, strong) BlockOperation block;
@property (nonatomic, strong) Success        success;
@property (nonatomic, strong) Failure        failure;

@property (nonatomic, assign) NSInteger tag; // is used to cancel operation together with INOOperationQueue

- (id)initWithMainManagedObjectContext:(NSManagedObjectContext *)mainManagedObjectContext;

- (void)setupOpeationWithBlock:(BlockOperation)block success:(Success)success failure:(Failure)failure;

@end
