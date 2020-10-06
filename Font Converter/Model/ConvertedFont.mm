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

#import "ConvertedFont.hh"

@implementation ConvertedFont

- (instancetype)initWithURL:(NSURL *)URL contents:(NSData *)contents format:(NSUInteger)format {
    self = [super init];
    
    if (self != nil) {
        _originalURL = URL;
        _convertedURL = URL;
        _convertedSize = 0;
        
        _contents = contents;
        _format = format;
    }
    
    return self;
}

- (BOOL)writeFileWithExtension:(NSString *)extension error:(NSError **)errorPtr {
    NSURL *changedExtension = [[self.originalURL URLByDeletingPathExtension] URLByAppendingPathExtension:extension];
    NSURL *convertedURL = [ConvertedFont generateUniqueFileName:changedExtension];
    
    [self.contents writeToURL:convertedURL options:0 error:errorPtr];
    
    if (*errorPtr == nil) {
        _convertedURL = convertedURL;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *attr = [fileManager attributesOfItemAtPath:[convertedURL path] error:errorPtr];
        
        if (*errorPtr == nil && attr != nil) {
           _convertedSize = [attr fileSize];
        }
    }
    
    return *errorPtr == nil;
}

+ (NSURL *)generateUniqueFileName:(NSURL *)URL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // returns if name is unique
    if (![fileManager fileExistsAtPath:[URL path]]) {
        return URL;
    }
    
    NSString *containingFolder = [[URL path] stringByDeletingLastPathComponent];
    NSString *fullFileName = [URL lastPathComponent];
    NSString *fileName = [fullFileName stringByDeletingPathExtension];
    NSString *extension = [fullFileName pathExtension];
    
    NSUInteger number = 1; // starting value
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"-(\\d+)$" options:0 error:&error];
    NSTextCheckingResult *result = [regex firstMatchInString:fileName options:0 range:NSMakeRange(0, [fileName length])];
    
    // file name already ends with a number, so increments it
    if (error == nil && result != nil) {
        NSString *match = [fileName substringWithRange:[result rangeAtIndex:1]];
        
        fileName = [fileName substringToIndex:[fileName length] - [match length] - 1];
        number = [match integerValue] + 1;
    }
    
    NSString *formattedFileName = [NSString stringWithFormat:@"%@-%lu", fileName, number];
    NSString *newFullFileName = [@[formattedFileName, extension] componentsJoinedByString:@"."];
    NSString *path = [containingFolder stringByAppendingPathComponent:newFullFileName];
    
    // repeats until unique file name found
    return [ConvertedFont generateUniqueFileName:[NSURL fileURLWithPath:path]];
}

@end
