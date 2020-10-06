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

#import "AppDelegate.hh"

@implementation AppDelegate

- (instancetype)init {
    self = [super init];
    
    if (self != nil) {
        _fileController = [[FileController alloc] init];
    }
    
    return self;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [NSApp setServicesProvider:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return NO;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    // opens new window if no windows open and Dock icon clicked
    if (!flag) {
        [self newWindow:sender];
    }
    
    return YES;
}

- (IBAction)newWindow:(id)sender {
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    NSWindowController *windowController = [storyboard instantiateInitialController];
    [windowController showWindow:self];
}

// handles files dropped onto Dock icon
- (void)application:(NSApplication *)sender openFiles:(NSArray *)paths {
    NSWindow *window = [[NSApplication sharedApplication] keyWindow];
    
    // opens window if not already open
    if (![window isVisible]) {
        [self newWindow:self];
    }
    
    [self openPaths:paths];
    [NSApp replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
}

// handles files received from Services menu
- (void)handleService:(NSPasteboard *)pasteboard userData:(NSString *)userData error:(NSString **)error {
    [self openPaths:[pasteboard propertyListForType:NSFilenamesPboardType]];
    [NSApp replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
}

- (void)openPaths:(NSArray *)paths {
    NSMutableArray *files = [NSMutableArray arrayWithCapacity:[paths count]];
    
    for (NSString *path in paths) {
        [files addObject:[NSURL fileURLWithPath:path]];
    }
    
    [self.fileController addFilesToQueue:files];
}

@end
