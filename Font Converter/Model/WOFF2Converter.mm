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

#import "WOFF2Converter.hh"

NSString *const kErrorDomain = @"dev.jcfields.font-converter";

@implementation WOFF2Converter

+ (NSData *)decodeFromURL:(NSURL *)URL error:(NSError **)errorPtr { // from WOFF2 to TTF
    NSData *data = [NSData dataWithContentsOfFile:[URL path]];
    const uint8_t *original = reinterpret_cast<const uint8_t *>([data bytes]);
    size_t originalSize = [data length];
    
    size_t convertedSize = woff2::ComputeWOFF2FinalSize(original, originalSize);
    std::string output(std::min(convertedSize, woff2::kDefaultMaxSize), 0);
    uint8_t *converted = reinterpret_cast<uint8_t *>(&output[0]);
    
    BOOL status = woff2::ConvertWOFF2ToTTF(converted, convertedSize, original, originalSize);
    
    if (status) {
        return [[NSData alloc] initWithBytes:converted length:convertedSize];
    }
    
    if (*errorPtr != nil) {
        NSError *error = [[NSError alloc] initWithDomain:kErrorDomain code:status userInfo:@{
            NSLocalizedDescriptionKey: @"WOFF2 decode error"
        }];
        *errorPtr = error;
    }
    
    return [NSData data];
}

+ (NSData *)encodeFromURL:(NSURL *)URL error:(NSError **)errorPtr { // from TTF to WOFF2
    NSData *data = [NSData dataWithContentsOfFile:[URL path]];
    const uint8_t *original = reinterpret_cast<const uint8_t *>([data bytes]);
    size_t originalSize = [data length];
    
    size_t convertedSize = woff2::MaxWOFF2CompressedSize(original, originalSize);
    std::string output(std::min(convertedSize, woff2::kDefaultMaxSize), 0);
    uint8_t *converted = reinterpret_cast<uint8_t *>(&output[0]);
    
    Preferences *preferences = [[Preferences alloc] init];
    woff2::WOFF2Params params;
    params.brotli_quality = (int)[preferences WOFF2CompressionLevel] - 1;
    params.allow_transforms = [preferences allowTransforms];
    
    BOOL status = woff2::ConvertTTFToWOFF2(original, originalSize, converted, &convertedSize, params);
    
    if (status) {
        return [[NSData alloc] initWithBytes:converted length:convertedSize];
    }
    
    if (*errorPtr != nil) {
        NSError *error = [[NSError alloc] initWithDomain:kErrorDomain code:status userInfo:@{
            NSLocalizedDescriptionKey: @"WOFF2 encode error"
        }];
        *errorPtr = error;
    }
    
    return [NSData data];
}

@end
