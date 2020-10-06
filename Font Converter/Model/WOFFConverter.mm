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

#import "WOFFConverter.hh"

NSString *const kErrorDomain = @"dev.jcfields.font-converter";

@implementation WOFFConverter

+ (NSData *)decodeFromURL:(NSURL *)URL error:(NSError **)errorPtr { // from WOFF to TTF
    NSData *data = [NSData dataWithContentsOfFile:[URL path]];
    const unsigned char *original = (const unsigned char *)[data bytes];
    unsigned int originalSize = (unsigned int)[data length];
    unsigned int convertedSize = 0;
    unsigned int status = 0;
    
    const unsigned char *converted = woffDecode(original, originalSize, &convertedSize, &status);
    
    if (WOFF_SUCCESS(status)) {
        NSData *contents = [[NSData alloc] initWithBytes:converted length:convertedSize];
        free((void *)converted);
        
        return contents;
    }
    
    if (WOFF_FAILURE(status) && *errorPtr != nil) {
        NSError *error = [[NSError alloc] initWithDomain:kErrorDomain code:status userInfo:@{
            NSLocalizedDescriptionKey: @"WOFF decode error"
        }];
        *errorPtr = error;
    }
    
    return [NSData data];
}

+ (NSData *)encodeFromURL:(NSURL *)URL error:(NSError **)errorPtr { // from TTF to WOFF
    NSData *data = [NSData dataWithContentsOfFile:[URL path]];
    const unsigned char *original = (const unsigned char *)[data bytes];
    unsigned int originalSize = (unsigned int)[data length];
    unsigned int convertedSize = 0;
    unsigned int status = 0;
    
    Preferences *preferences = [[Preferences alloc] init];
    int iterations = (int)[preferences WOFFCompressionLevel];
    
    const unsigned char *converted = woffEncode(original, originalSize, 0, 0, iterations, &convertedSize, &status);
    
    if (WOFF_SUCCESS(status)) {
        NSData *contents = [[NSData alloc] initWithBytes:converted length:convertedSize];
        free((void *)converted);
        
        return contents;
    }
    
    if (WOFF_FAILURE(status) && *errorPtr != nil) {
        NSError *error = [[NSError alloc] initWithDomain:kErrorDomain code:status userInfo:@{
            NSLocalizedDescriptionKey: @"WOFF encode error"
        }];
        *errorPtr = error;
    }
    
    return [NSData data];
}

@end
