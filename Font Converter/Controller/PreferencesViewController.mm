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

#import "PreferencesViewController.hh"

@implementation PreferencesViewController

- (void)viewWillAppear {
    _preferences = [[Preferences alloc] init];
    
    int WOFFCompressionLevel = (int)[self.preferences WOFFCompressionLevel];
    int WOFF2CompressionLevel = (int)[self.preferences WOFF2CompressionLevel];
    
    [self.outputFormatPopUp selectItemWithTag:[self.preferences outputFormat]];
    
    self.moveToTrashCheckbox.state = [self.preferences moveToTrash];
    self.useTabsCheckbox.state = [self.preferences useTabs];
    self.allowTransformsCheckbox.state = [self.preferences allowTransforms];
    
    self.WOFFCompressionLevelSlider.intValue = WOFFCompressionLevel;
    self.WOFF2CompressionLevelSlider.intValue = WOFF2CompressionLevel;
    self.WOFFCompressionLevelLabel.stringValue = [NSString stringWithFormat:@"%d", WOFFCompressionLevel];
    self.WOFF2CompressionLevelLabel.stringValue = [NSString stringWithFormat:@"%d", WOFF2CompressionLevel];
}

- (IBAction)outputFormatChanged:(id)sender {
    self.preferences.outputFormat = [sender selectedTag];
}

- (IBAction)moveToTrashChanged:(id)sender {
    self.preferences.moveToTrash = [sender state];
}

- (IBAction)useTabsChanged:(id)sender {
    self.preferences.useTabs = [sender state];
}

- (IBAction)WOFFCompressionLevelChanged:(id)sender {
    self.preferences.WOFFCompressionLevel = [sender intValue];
    self.WOFFCompressionLevelLabel.stringValue = [NSString stringWithFormat:@"%d", [sender intValue]];
}

- (IBAction)WOFF2CompressionLevelChanged:(id)sender {
    self.preferences.WOFF2CompressionLevel = [sender intValue];
    self.WOFF2CompressionLevelLabel.stringValue = [NSString stringWithFormat:@"%d", [sender intValue]];
}

- (IBAction)allowTransformsChanged:(id)sender {
    self.preferences.allowTransforms = [sender state];
}

@end
