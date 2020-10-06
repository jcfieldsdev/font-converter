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

#import "Font.hh"

NSUInteger const kMagicLength = 4;
const char kMagicTTF[]  = {0x00, 0x01, 0x00, 0x00};
const char *kMagicCFF   = "OTTO";
const char *kMagicWOFF  = "wOFF";
const char *kMagicWOFF2 = "wOF2";

NSArray *const kFileExtensions = @[@"fon", @"ttf", @"otf", @"woff", @"woff2"];
NSArray *const kFileFormats = @[@"Unknown", @"TrueType", @"OpenType", @"WOFF", @"WOFF2"];

@implementation Font

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super init];
    
    if (self != nil) {
        _URL = URL;
        _size = [self determineSize];
        _ratio = 1;
        _format = [self determineCurrentFormat];
        _status = kStatusIncomplete;
        
        _familyName = [NSString string];
        _traits = 0;
        
        _products = [NSMutableArray array];
    }
    
    return self;
}

- (BOOL)convertFormat {
    if (self.status == kStatusComplete) {
        return YES;
    }
    
    if (self.format == kFormatUnknown) {
        self.status = kStatusReadError;
        return NO;
    }
    
    self.status = kStatusInProgress;
    
    NSError *error = nil;
    NSArray *collection = [self doConversions:&error];
    
    if (error != nil) {
        self.status = kStatusConvertError;
        return NO;
    }
    
    [self writeFiles:collection];
    
    self.status = kStatusComplete;
    return YES;
}

- (NSArray *)doConversions:(NSError **)errorPtr {
    NSMutableArray *collection = [NSMutableArray array];
    
    ConvertedFont *convertedFont = nil;
    Preferences *preferences = [[Preferences alloc] init];
    NSUInteger encodeFormat = [preferences outputFormat];
    
    if (self.format == kFormatTTF || self.format == kFormatCFF) {
        if (encodeFormat == kFormatWOFF || encodeFormat == kFormatBoth) {
            convertedFont = [[ConvertedFont alloc]
                initWithURL:self.URL
                contents:[WOFFConverter encodeFromURL:self.URL error:errorPtr]
                format:kFormatWOFF];
            [collection addObject:convertedFont];
        }
        
        if (encodeFormat == kFormatWOFF2 || encodeFormat == kFormatBoth) {
            convertedFont = [[ConvertedFont alloc]
                initWithURL:self.URL
                contents:[WOFF2Converter encodeFromURL:self.URL error:errorPtr]
                format:kFormatWOFF2];
            [collection addObject:convertedFont];
        }
        
        [self loadMetadata:self.URL];
    } else if (self.format == kFormatWOFF) {
        convertedFont = [[ConvertedFont alloc]
            initWithURL:self.URL
            contents:[WOFFConverter decodeFromURL:self.URL error:errorPtr]
            format:[self determineOriginalFormat]];
        [collection addObject:convertedFont];
    } else if (self.format == kFormatWOFF2) {
        convertedFont = [[ConvertedFont alloc]
            initWithURL:self.URL
            contents:[WOFF2Converter decodeFromURL:self.URL error:errorPtr]
            format:[self determineOriginalFormat]];
        [collection addObject:convertedFont];
    }
    
    return [NSArray arrayWithArray:collection];
}

- (void)writeFiles:(NSArray *)collection {
    NSMutableArray *products = [NSMutableArray array];
    BOOL success = YES;
    
    for (ConvertedFont *convertedFont in collection) {
        NSString *extension = [kFileExtensions objectAtIndex:[convertedFont format]];
        NSError *error = nil;
        [convertedFont writeFileWithExtension:extension error:&error];
        
        Font *font = [[Font alloc] initWithURL:[convertedFont convertedURL]];
        
        if (error != nil) {
            font.status = kStatusWriteError;
            [products addObject:font];
            success = NO;
            continue;
        }
        
        if ([convertedFont format] == kFormatTTF || [convertedFont format] == kFormatCFF) {
            [self loadMetadata:[convertedFont convertedURL]];
        }
        
        float ratio = self.size > 0 ? (float)[convertedFont convertedSize] / self.size : 1;
        
        font.size = [convertedFont convertedSize];
        font.ratio = MIN(ratio, 1);
        font.format = [convertedFont format];
        font.status = kStatusComplete;
        
        [products addObject:font];
    }
    
    if (success) {
        Preferences *preferences = [[Preferences alloc] init];
        
        if ([preferences moveToTrash]) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager trashItemAtURL:self.URL resultingItemURL:nil error:nil];
        }
    }
    
    self.products = products;
}

- (NSUInteger)determineSize {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *attr = [fileManager attributesOfItemAtPath:[self.URL path] error:&error];
    
    if (error == nil && attr != nil) {
       return [attr fileSize];
    }
    
    return 0;
}

- (NSUInteger)determineCurrentFormat {
    return [self determineFormat:NSMakeRange(0, kMagicLength)];
}

- (NSUInteger)determineOriginalFormat {
    return [self determineFormat:NSMakeRange(kMagicLength, 2 * kMagicLength)];
}

- (NSUInteger)determineFormat:(NSRange)range {
    NSData *contents = [NSData dataWithContentsOfFile:[self.URL path]];
    char buffer[kMagicLength];
    [contents getBytes:buffer range:range];
    
    NSData *data = [NSData dataWithBytes:buffer length:kMagicLength];
    
    if ([data isEqualToData:[NSData dataWithBytes:kMagicTTF length:kMagicLength]]) {
        return kFormatTTF;
    }
    
    if ([data isEqualToData:[NSData dataWithBytes:kMagicCFF length:kMagicLength]]) {
        return kFormatCFF;
    }
    
    if ([data isEqualToData:[NSData dataWithBytes:kMagicWOFF length:kMagicLength]]) {
        return kFormatWOFF;
    }
    
    if ([data isEqualToData:[NSData dataWithBytes:kMagicWOFF2 length:kMagicLength]]) {
        return kFormatWOFF2;
    }
    
    return kFormatUnknown;
}

- (void)loadMetadata:(NSURL *)URL {
    NSData *data = [[NSData alloc] initWithContentsOfURL:URL];
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGFontRef cgFont = CGFontCreateWithDataProvider(dataProvider);
    CTFontRef ctFont = CTFontCreateWithGraphicsFont(cgFont, 0, NULL, 0);
    
    self.familyName = (NSString *)CFBridgingRelease(CTFontCopyFamilyName(ctFont));
    self.traits = CTFontGetSymbolicTraits(ctFont);
    
    CGDataProviderRelease(dataProvider);
    CGFontRelease(cgFont);
    CFRelease(ctFont);
}

- (NSString *)generateCSS {
    NSString *CSS = [NSString stringWithFormat:
        @"@font-face {"
         "\n\tfont-family: %@;"
         "\n\tfont-style: %@;"
         "\n\tfont-weight: %@;"
         "\n\tsrc: %@;"
         "\n}",
        [self CSSFontFamily],
        [self CSSFontStyle],
        [self CSSFontWeight],
        [self CSSSrc]];
    
    Preferences *preferences = [[Preferences alloc] init];
    
    if (![preferences useTabs]) {
        return [CSS stringByReplacingOccurrencesOfString:@"\t" withString:@"    "];
    }
    
    return CSS;
}

- (NSString *)CSSFontFamily {
    NSMutableArray *list = [NSMutableArray array];
    [list addObject:[NSString stringWithFormat:@"\"%@\"", self.familyName]];
    
    if (self.traits & kCTFontTraitMonoSpace) {
        [list addObject:@"monospace"];
    } else if (self.traits & kCTFontClassSansSerif) {
        [list addObject:@"sans-serif"];
    } else if (self.traits & (kCTFontClassOldStyleSerifs
                            | kCTFontClassTransitionalSerifs
                            | kCTFontClassModernSerifs
                            | kCTFontClassClarendonSerifs
                            | kCTFontClassSlabSerifs
                            | kCTFontClassFreeformSerifs)) {
        [list addObject:@"serif"];
    }
    
    return [list componentsJoinedByString:@", "];
}

- (NSString *)CSSFontStyle {
    return (self.traits & kCTFontTraitItalic) ? @"italic" : @"normal";
}

- (NSString *)CSSFontWeight {
    return (self.traits & kCTFontTraitBold) ? @"bold" : @"normal";
}

- (NSString *)CSSSrc {
    NSMutableArray *collection = [NSMutableArray array];
    
    for (Font *font in [self.products reverseObjectEnumerator]) {
        [collection addObject:@{@"URL": [font URL], @"format": @([font format])}];
    }
    
    Preferences *preferences = [[Preferences alloc] init];
    
    if (![preferences moveToTrash]) {
        NSDictionary *original = @{@"URL": self.URL, @"format": @(self.format)};
        
        // ensures uncompressed font is last
        if (self.format == kFormatTTF || self.format == kFormatCFF) {
            [collection addObject:original];
        } else {
            [collection insertObject:original atIndex:0];
        }
    }
    
    NSMutableArray *list = [NSMutableArray array];
    
    for (NSDictionary *item in collection) {
        NSString *path = [[item objectForKey:@"URL"] lastPathComponent];
        NSUInteger format = [[item objectForKey:@"format"] unsignedIntegerValue];
        NSString *type = [[kFileFormats objectAtIndex:format] lowercaseString];
        
        [list addObject:[NSString stringWithFormat:@"url(\"%@\") format(\"%@\")", path, type]];
    }
    
    return [list componentsJoinedByString:@", "];
}

#pragma mark - NSPasteboardReading

+ (NSArray<NSPasteboardType> *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return @[(id)kUTTypeFileURL];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    return NSPasteboardReadingAsString;
}

- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type {
    NSURL *URL = [[[NSURL alloc] initWithPasteboardPropertyList:propertyList ofType:type] filePathURL];
    self = [[Font alloc] initWithURL:URL];
    return self;
}

@end
