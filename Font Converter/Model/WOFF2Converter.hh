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
#import "Preferences.hh"
#import "woff2_decode.hh"
#import "woff2_encode.hh"

NS_ASSUME_NONNULL_BEGIN

@interface WOFF2Converter : NSObject

+ (NSData *)decodeFromURL:(NSURL *)URL error:(NSError **)errorPtr;
+ (NSData *)encodeFromURL:(NSURL *)URL error:(NSError **)errorPtr;

@end

NS_ASSUME_NONNULL_END
