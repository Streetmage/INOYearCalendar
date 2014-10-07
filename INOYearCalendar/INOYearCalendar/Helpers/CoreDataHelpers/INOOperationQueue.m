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

#import "INOOperationQueue.h"

@implementation INOOperationQueue

- (id)init {
    self = [super init];
    
    if (self) {
        _needsCancelOperationsWithEqualTag = YES;
    }
    
    return self;
}

- (void)addOperation:(INOOperation *)op {
    if (_needsCancelOperationsWithEqualTag) {
        [self cancelOperationsWithTag:[op tag]];
    }
    [super addOperation:op];
}

- (void)cancelOperationsWithTag:(NSInteger)tag {
    NSArray *filteredArray = [self.operations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag == %d", tag]];
    [filteredArray makeObjectsPerformSelector:@selector(cancel)];
}

@end
