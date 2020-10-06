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

#import <Cocoa/Cocoa.h>
#import "ConvertedFont.hh"
#import "Preferences.hh"
#import "WOFFConverter.hh"
#import "WOFF2Converter.hh"

NS_ASSUME_NONNULL_BEGIN

// statuses
typedef NS_ENUM(NSUInteger, StatusType) {
    kStatusIncomplete,
    kStatusInProgress,
    kStatusComplete,
    kStatusReadError,
    kStatusConvertError,
    kStatusWriteError
};

// file formats
typedef NS_ENUM(NSUInteger, FormatType) {
    kFormatUnknown,
    kFormatTTF,
    kFormatCFF,
    kFormatWOFF,
    kFormatWOFF2,
    kFormatBoth
};

FOUNDATION_EXPORT NSArray *const kFileExtensions;
FOUNDATION_EXPORT NSArray *const kFileFormats;

@interface Font : NSObject <NSPasteboardReading>

@property(retain) NSURL *URL;
@property(assign) NSUInteger size;
@property(assign) float ratio;
@property(assign) NSUInteger format;
@property(assign) NSUInteger status;
@property(copy) NSString *familyName;
@property(assign) NSUInteger traits;
@property(retain) NSMutableArray *products;

- (instancetype)initWithURL:(NSURL *)URL;
- (BOOL)convertFormat;
- (NSArray *)doConversions:(NSError **)errorPtr;
- (void)writeFiles:(NSArray *)queue;
- (NSUInteger)determineSize;
- (NSUInteger)determineCurrentFormat;
- (NSUInteger)determineOriginalFormat;
- (NSUInteger)determineFormat:(NSRange)magic;
- (void)loadMetadata:(NSURL *)URL;
- (NSString *)generateCSS;

@end

NS_ASSUME_NONNULL_END
