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

#import "TableRow.hh"

@implementation TableRow

- (instancetype)initWithFont:(Font *)font {
    self = [super init];
    
    if (self != nil) {
        _font = font;
    }
    
    return self;
}

- (NSString *)name {
    return [[self.font URL] lastPathComponent];
}

- (NSUInteger)size {
    return [self.font size];
}

- (NSString *)format {
    return [kFileFormats objectAtIndex:[self.font format]];
}

- (NSUInteger)status {
    return [self.font status];
}

- (NSString *)formattedSize {
    NSByteCountFormatter *sizeFormatter = [[NSByteCountFormatter alloc] init];
    sizeFormatter.countStyle = NSByteCountFormatterCountStyleFile;
    
    return [sizeFormatter stringFromByteCount:self.size];
}

- (NSString *)formattedRatio {
    return [NSString stringWithFormat:@"%.1f%%", 100 * (1 - [self.font ratio])];
}

- (NSImage *)formattedStatus {
    NSUInteger status = [self.font status];
    
    if (status == kStatusComplete) {
        return [NSImage imageNamed:@"Check"];
    }
    
    if (status == kStatusReadError || status == kStatusConvertError || status == kStatusWriteError) {
        return [NSImage imageNamed:@"Error"];
    }
    
    return nil;
}

@end
