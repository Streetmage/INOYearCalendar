//
// Copyright 2014 Inostudio Solutions
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "INOMonthGlyphsHelper.h"

NSUInteger const kSignleFigureGlyphsCount = 9;

static NSString *const kMonthDatesChars = @"12345678910111213141516171819202122232425262728293031";

@implementation INOMonthGlyphsHelper

+ (INOMonthGlyphsHelper *)glyphHelperWithFontName:(NSString *)fontName fontSize:(CGFloat)fontSize {

    INOMonthGlyphsHelper *glyphsHelper = [[INOMonthGlyphsHelper alloc] init];
    
    glyphsHelper.length = [kMonthDatesChars length];
    UniChar characters[glyphsHelper.length];
    CFStringGetCharacters((__bridge CFStringRef)kMonthDatesChars, CFRangeMake(0, glyphsHelper.length), characters);
    
    glyphsHelper.font = CTFontCreateWithName((__bridge CFStringRef)[UIFont systemFontOfSize:fontSize].fontName, fontSize, NULL);
    glyphsHelper.glyphs =  (CGGlyph *)malloc(sizeof(CGGlyph) * glyphsHelper.length);
    CTFontGetGlyphsForCharacters(glyphsHelper.font, characters, glyphsHelper.glyphs, glyphsHelper.length);
    glyphsHelper.glyphRects = (CGRect *)malloc(sizeof(CGRect) * glyphsHelper.length);
    glyphsHelper.glyphRect = CTFontGetBoundingRectsForGlyphs(glyphsHelper.font, kCTFontHorizontalOrientation, glyphsHelper.glyphs, glyphsHelper.glyphRects, glyphsHelper.length);
    
    glyphsHelper.glyphAdvances = (CGSize *)malloc(sizeof(CGSize) * glyphsHelper.length);
    glyphsHelper.glyphAdvance = CTFontGetAdvancesForGlyphs(glyphsHelper.font, kCTFontHorizontalOrientation, glyphsHelper.glyphs, glyphsHelper.glyphAdvances, glyphsHelper.length);

    return glyphsHelper;

}

@end
