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

#import "ViewController.hh"

NSString *const kWebSiteURL = @"https://github.com/jcfieldsdev/font-converter";

@implementation ViewController

- (void)viewWillAppear {
    [super viewWillAppear];
    
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    _fileController = [appDelegate fileController];
    _rows = [NSMutableArray array];
    _selectedIndexes = [NSIndexSet indexSet];
    _selectedItems = [NSArray array];
    
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(receiveNotification:)
        name:@"queueChanged"
        object:self.fileController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (NSTableColumn *tableColumn in [self.tableView tableColumns]) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor
            sortDescriptorWithKey:[tableColumn identifier]
            ascending:YES
            selector:@selector(compare:)];
        tableColumn.sortDescriptorPrototype = sortDescriptor;
    }
    
    [self.tableView registerForDraggedTypes:@[NSFilenamesPboardType]];
    [self.tableView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
    self.tableView.allowsMultipleSelection = YES;
}

- (void)viewDidAppear {
    [self reloadData];
    [self validateToolbar];
    [self processQueue];
}

- (void)viewDidDisappear {
    [self.fileController clearQueue];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSelectedIndexes:(NSIndexSet *)indexSet {
    if (indexSet != _selectedIndexes) {
        indexSet = [indexSet copy];
        _selectedIndexes = indexSet;
        self.selectedItems = [self.arrayController.content objectsAtIndexes:indexSet];
    }
}

- (void)setSelectedItems:(NSArray *)items {
    if (items != _selectedItems) {
        items = [items copy];
        _selectedItems = items;
    }
}

- (void)receiveNotification:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"queueChanged"]) {
        [self reloadData];
        [self validateToolbar];
        [self processQueue];
    }
}

- (void)processQueue {
    for (Font *font in [self.fileController fonts]) {
        // processes queue items asynchronously
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([font status] == kStatusIncomplete) {
                [font convertFormat];
            }
            
            // reloads table data after processing done
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self reloadData];
                [self validateToolbar];
            });
        });
    }
    
    [self reloadData];
    [self validateToolbar];
}

- (void)reloadData {
    NSMutableArray *rows = [NSMutableArray array];
    
    for (Font *font in [self.fileController fonts]) {
        if ([font status] == kStatusComplete) {
            // replaces font with its products in table position
            for (Font *product in [font products]) {
                TableRow *tableRow = [[TableRow alloc] initWithFont:product];
                [rows addObject:tableRow];
            }
        } else {
            TableRow *tableRow = [[TableRow alloc] initWithFont:font];
            [rows addObject:tableRow];
        }
    }
    
    NSIndexSet *selected = [self.tableView selectedRowIndexes];
    
    self.rows = rows;
    self.arrayController.content = [NSArray arrayWithArray:rows];
    
    // re-selects previously selected row
    [self.tableView selectRowIndexes:selected byExtendingSelection:NO];
}

- (void)validateToolbar {
    NSToolbar *toolbar = [[self.view window] toolbar];
    
    for (NSToolbarItem *toolbarItem in [toolbar visibleItems]) {
        SEL action = [toolbarItem action];
        BOOL state = YES;
        
        if (action == @selector(doRemoveFont:) || action == @selector(doOpenFolder:)) {
            state = [self.tableView selectedRow] >= 0;
        } else if (action == @selector(doCopyCSS:) || action == @selector(doClearQueue:)) {
            state = [[self.fileController fonts] count] > 0;
        }
        
        toolbarItem.enabled = state;
    }
}

- (NSUInteger)translateTableRowToArrayRow:(NSUInteger)selectedRow {
    NSUInteger arrayRow = 0;
    NSUInteger tableRow = 0;
    
    for (Font *font in [self.fileController fonts]) {
        if (tableRow < selectedRow) {
            if ([font status] == kStatusComplete) {
                tableRow += [[font products] count];
            } else {
                tableRow++;
            }
            
            arrayRow++;
        }
    }
    
    return arrayRow;
}

#pragma mark - IBAction

- (IBAction)newWindow:(id)sender {
    NSWindow *window = [[NSApplication sharedApplication] keyWindow];
    
    // only one window open at a time
    if ([window isVisible]) {
        return;
    }
    
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    NSWindowController *windowController = [storyboard instantiateInitialController];
    [windowController showWindow:self];
}

- (IBAction)doAddFonts:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = NO;
    panel.allowsMultipleSelection = YES;
    panel.allowedFileTypes = kFileExtensions;
    
    [panel beginSheetModalForWindow:[self.view window] completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            [self.fileController addFilesToQueue:[panel URLs]];
        }
    }];
}

- (IBAction)doRemoveFont:(id)sender {
    if ([self.selectedIndexes count] == 0) {
        return;
    }
    
    [self.selectedIndexes enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        NSUInteger row = [self translateTableRowToArrayRow:range.location];
        NSArray *fontsToRemove = [[self.fileController fonts] subarrayWithRange:NSMakeRange(row, range.length)];
        
        [self.fileController removeFromQueue:fontsToRemove];
    }];
}

- (IBAction)doOpenFolder:(id)sender {
    if ([self.selectedIndexes count] == 0) {
        return;
    }
    
    NSMutableArray *files = [NSMutableArray array];
    
    [self.selectedIndexes enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        NSArray *items = [self.rows subarrayWithRange:range];
        
        for (TableRow *tableRow in items) {
            Font *font = [tableRow font];
            [files addObject:[font URL]];
        }
    }];
    
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:files];
}

- (IBAction)doCopyCSS:(id)sender {
    NSMutableArray *rules = [NSMutableArray array];
    
    for (Font *font in [self.fileController fonts]) {
        if ([font status] == kStatusComplete) {
            [rules addObject:[font generateCSS]];
        }
    }
    
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    [pboard clearContents];
    [pboard setString:[rules componentsJoinedByString:@"\n\n"] forType:NSStringPboardType];
}

- (IBAction)doClearQueue:(id)sender {
    [self.fileController clearQueue];
    
    [self reloadData];
    [self validateToolbar];
}

- (IBAction)doHelp:(id)sender {
    NSURL *URL = [[NSURL alloc] initWithString:kWebSiteURL];
    [[NSWorkspace sharedWorkspace] openURL:URL];
}

#pragma mark - NSMenuItemValidation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    SEL action = [menuItem action];
    
    if (action == @selector(doHelp:)) {
        return YES;
    }
    
    if (action == @selector(newWindow:)) {
        return NO; // always off when window is open
    }
    
    if (action == @selector(doRemoveFont:) || action == @selector(doOpenFolder:)) {
        return [self.selectedIndexes count] > 0;
    }
    
    if (action == @selector(doCopyCSS:) || action == @selector(doClearQueue:)) {
        return [[self.fileController fonts] count] > 0;
    }
    
    return YES;
}

#pragma mark - NSTableViewDataSource

- (NSDictionary *)pasteboardReadingOptions {
    return @{
        NSPasteboardURLReadingFileURLsOnlyKey: @YES,
        NSPasteboardURLReadingContentsConformToTypesKey: @[@"public.font"]
    };
}

- (BOOL)containsAcceptableURLsFromPasteboard:(NSPasteboard *)pasteboard {
    return [pasteboard canReadObjectForClasses:@[[NSURL class]] options:[self pasteboardReadingOptions]];
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    if (dropOperation == NSTableViewDropAbove) {
        if ([self containsAcceptableURLsFromPasteboard:[info draggingPasteboard]]) {
            info.animatesToDestination = YES;
            return NSDragOperationCopy;
        }
    }
    
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    [self performInsertWithDragInfo:info row:row];
    [self reloadData];
    
    return YES;
}

- (void)performInsertWithDragInfo:(id<NSDraggingInfo>)info row:(NSInteger)row {
    NSArray<Class> *classes = @[[Font class]];
    
    __block NSUInteger insertionIndex = [self translateTableRowToArrayRow:row];
    
    [info enumerateDraggingItemsWithOptions:0 forView:self.tableView classes:classes searchOptions:@{} usingBlock:^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop) {
        Font *font = [draggingItem item];
        [self.fileController addFontToQueue:font row:insertionIndex];
        
        insertionIndex++;
    }];
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self validateToolbar];
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)sortDescriptors {
    self.arrayController.content = [self.rows sortedArrayUsingDescriptors:sortDescriptors];
    [tableView reloadData];
}

@end
