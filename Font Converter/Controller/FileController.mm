/*
 * Copyright (C) 2020 J.C. Fields (jcfields@jcfields.dev).
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above.
 */

#import "FileController.hh"

@implementation FileController

- (instancetype)init {
    self = [super init];
    
    if (self != nil) {
        _fonts = [NSMutableArray array];
    }
    
    return self;
}

- (void)addFilesToQueue:(NSArray *)files {
    for (NSURL *URL in files) {
        Font *font = [[Font alloc] initWithURL:URL];
        [self.fonts addObject:font];
    }
    
    [self sendNotification];
}

- (void)addFontToQueue:(Font *)font row:(NSUInteger)row {
    [self.fonts insertObject:font atIndex:MIN(row, [self.fonts count])];
    [self sendNotification];
}

- (void)clearQueue {
    NSMutableArray *fonts = [NSMutableArray array];
    
    for (Font *font in self.fonts) {
        // skips items that are being processed
        if ([font status] == kStatusIncomplete) {
            [fonts addObject:font];
        }
    }
    
    _fonts = fonts;
    
    [self sendNotification];
}

- (void)removeFromQueue:(NSArray *)fontsToRemove {
    for (Font *font in fontsToRemove) {
        [self.fonts removeObject:font];
    }
    
    [self sendNotification];
}

- (void)sendNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"queueChanged" object:self];
}

@end
