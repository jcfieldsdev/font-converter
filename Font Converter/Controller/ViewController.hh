/*
 * Copyright (C) 2020 J.C. Fields (jcfields@jcfields.dev).
 * Updated Augsut 2025 by Disky_eth (https://github.com/Diskyeth)
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
#import "AppDelegate.hh"
#import "FileController.hh"
#import "Font.hh"
#import "TableRow.hh"

@interface ViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property(strong) FileController *fileController;
@property(strong) NSMutableArray *rows;
@property(nonatomic, strong) NSIndexSet *selectedIndexes;
@property(nonatomic, strong) NSArray *selectedItems;
@property(weak) IBOutlet NSArrayController *arrayController;
@property(weak) IBOutlet NSTableView *tableView;

- (void)receiveNotification:(NSNotification *)notification;
- (void)processQueue;
- (void)reloadData;
- (void)validateToolbar;
- (NSUInteger)translateTableRowToArrayRow:(NSUInteger)selectedRow;
- (IBAction)newWindow:(id)sender;
- (IBAction)doAddFonts:(id)sender;
- (IBAction)doRemoveFont:(id)sender;
- (IBAction)doOpenFolder:(id)sender;
- (IBAction)doCopyCSS:(id)sender;
- (IBAction)doClearQueue:(id)sender;
- (IBAction)doHelp:(id)sender;

@end
