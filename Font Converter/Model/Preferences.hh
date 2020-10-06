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

#import <Foundation/Foundation.h>
#import "Font.hh"

NS_ASSUME_NONNULL_BEGIN

@interface Preferences : NSObject

@property(retain) NSUserDefaults *defaults;
@property(assign) NSUInteger outputFormat;
@property(assign) BOOL moveToTrash;
@property(assign) BOOL useTabs;
@property(assign) NSUInteger WOFFCompressionLevel;
@property(assign) NSUInteger WOFF2CompressionLevel;
@property(assign) BOOL allowTransforms;

- (BOOL)getBoolValue:(NSString *)key defaultValue:(BOOL)defaultValue;
- (NSUInteger)getIntValue:(NSString *)key defaultValue:(NSUInteger)defaultValue;

@end

NS_ASSUME_NONNULL_END
