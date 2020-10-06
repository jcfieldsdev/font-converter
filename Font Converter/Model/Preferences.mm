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

#import "Preferences.hh"

// default preferences
NSUInteger const kDefaultOutputFormat = kFormatBoth;
BOOL const kDefaultMoveToTrash = NO;
BOOL const kDefaultUseTabs = NO;
NSUInteger const kDefaultWOFFCompressionLevel = 15;
NSUInteger const kDefaultWOFF2CompressionLevel = 12;
BOOL const kDefaultAllowTransforms = YES;

@implementation Preferences

- (instancetype)init {
    self = [super init];
    
    if (self != nil) {
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (BOOL)getBoolValue:(NSString *)key defaultValue:(BOOL)defaultValue {
    if ([self.defaults objectForKey:key] != nil) {
        return [self.defaults boolForKey:key];
    }
    
    return defaultValue;
}

- (NSUInteger)getIntValue:(NSString *)key defaultValue:(NSUInteger)defaultValue {
    if ([self.defaults objectForKey:key] != nil) {
        return [self.defaults integerForKey:key];
    }
    
    return defaultValue;
}

- (NSUInteger)outputFormat {
    return [self getIntValue:@"outputFormat" defaultValue:kDefaultOutputFormat];
}

- (BOOL)moveToTrash {
    return [self getBoolValue:@"moveToTrash" defaultValue:kDefaultMoveToTrash];
}

- (BOOL)useTabs {
    return [self getBoolValue:@"useTabs" defaultValue:kDefaultUseTabs];
}

- (NSUInteger)WOFFCompressionLevel {
    return [self getIntValue:@"WOFFCompressionLevel" defaultValue:kDefaultWOFFCompressionLevel];
}

- (NSUInteger)WOFF2CompressionLevel {
    return [self getIntValue:@"WOFF2CompressionLevel" defaultValue:kDefaultWOFF2CompressionLevel];
}

- (BOOL)allowTransforms {
    return [self getBoolValue:@"allowTransforms" defaultValue:kDefaultAllowTransforms];
}

- (void)setOutputFormat:(NSUInteger)value {
    [self.defaults setInteger:value forKey:@"outputFormat"];
}

- (void)setMoveToTrash:(BOOL)value {
    [self.defaults setBool:value forKey:@"moveToTrash"];
}

- (void)setUseTabs:(BOOL)value {
    [self.defaults setBool:value forKey:@"useTabs"];
}

- (void)setWOFFCompressionLevel:(NSUInteger)value {
    [self.defaults setInteger:value forKey:@"WOFFCompressionLevel"];
}

- (void)setWOFF2CompressionLevel:(NSUInteger)value {
    [self.defaults setInteger:value forKey:@"WOFF2CompressionLevel"];
}

- (void)setAllowTransforms:(BOOL)value {
    [self.defaults setBool:value forKey:@"allowTransforms"];
}

@end
