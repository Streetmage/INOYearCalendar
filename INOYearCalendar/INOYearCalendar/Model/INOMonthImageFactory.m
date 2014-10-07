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

#import "INOMonthImageFactory.h"
#import "INOMonthGlyphsHelper.h"

#import "Event.h"

static INOMonthImageFactory *factory = nil;


static NSUInteger const kMonthDaysColumns = 7;
static NSUInteger const kMonthDaysRows    = 6;

@interface INOMonthImageFactory ()

@property (nonatomic, strong) NSDateFormatter *monthTitleDateFormatter;

@property (nonatomic, strong) INOMonthGlyphsHelper *glyphsHelper;

@end

@implementation INOMonthImageFactory

+ (INOMonthImageFactory *)sharedFactory {
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        factory = [[self alloc] init];
    });
    return factory;
}

+ (id)alloc {
    @synchronized([INOMonthImageFactory class]) {
        NSAssert(factory == nil, @"Attempted to allocate a second instance of the INOMonthImageFactory singleton");
        factory = [super alloc];
        return factory;
    }
    return nil;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self resetFactory];
    }
    
    return self;
}

#pragma mark - Public Methods

- (UIImage *)monthImageWithDate:(NSDate *)monthDate ofSize:(CGSize)size {
    return [self monthImageWithDate:monthDate ofSize:size eventsForDates:nil];
}

- (UIImage *)monthImageWithDate:(NSDate *)monthDate ofSize:(CGSize)size eventsForDates:(NSDictionary *)eventsForDates {
    
    if (!CGSizeEqualToSize(CGSizeZero, size)) {
        
        CGContextRef ctx = CGContextCreate(size);
        UIImage *monthImage = UIGraphicsGetImageFromContext([self drawMonthInContext:ctx monthDate:monthDate ofSize:size eventsForDates:eventsForDates]);
        CGContextRelease(ctx);
        return monthImage;
        
    }
    
    return nil;
    
}

- (void)resetFactory {
    
    _monthTitleDateFormatter = [[NSDateFormatter alloc] init];
    [_monthTitleDateFormatter setDateFormat:@"LLLL"];
    
    _colorsForEventCategories = @{};
    
    _glyphsHelper = [INOMonthGlyphsHelper glyphHelperWithFontName:@"Helvetica" fontSize:8.0f];
    
}

#pragma mark - Private Methods

- (CGContextRef)drawMonthInContext:(CGContextRef)ctx monthDate:(NSDate *)monthDate ofSize:(CGSize)size eventsForDates:(NSDictionary *)eventsForDates {
    
    // Initializing
    CGFloat monthNameHeight = 20.0f;
    CGRect monthNameFrame = CGRectMake(0.0f, 0.0f, size.width, monthNameHeight);
    
    CGSize datesAreaSize = CGSizeMake(size.width, size.height - monthNameHeight);
    CGSize dateSize = CGSizeMake(datesAreaSize.width / kMonthDaysColumns, datesAreaSize.height / kMonthDaysRows);
    
    NSUInteger datesIterator = [monthDate dayOfWeek];
    
    CGPoint   *glyphPositions = (CGPoint *)malloc(sizeof(CGPoint) * _glyphsHelper.length);
    NSUInteger glyphIterator = 0;
    
    NSDate     *beginningOfMonthDate = [monthDate beginningOfMonth];
    NSUInteger  secondsInSingleDay = 86400;
    
    NSUInteger daysInMonth = [monthDate daysInMonth];
    for (NSUInteger i = 0; i < daysInMonth; i++) {
        
        // Glyphs positions calculating
        CGPoint offset = CGPointMake(datesIterator % kMonthDaysColumns,
                                     datesIterator / kMonthDaysColumns);
        
        if (i < kSignleFigureGlyphsCount) {
            
            CGSize glyphAdvance = _glyphsHelper.glyphAdvances[glyphIterator];
            CGPoint position = CGPointMake(offset.x * dateSize.width + 0.5 * (dateSize.width - glyphAdvance.width),
                                           (datesAreaSize.height - (offset.y + 1) * dateSize.height) + 0.5 * (dateSize.height - glyphAdvance.height));
            glyphPositions[glyphIterator++] = position;
            
        } else {
            
            CGSize firstFigureGlyphAdvance = _glyphsHelper.glyphAdvances[glyphIterator];
            CGSize secondFigureGlyphAdvance = _glyphsHelper.glyphAdvances[glyphIterator + 1];
            
            CGFloat glyphPositionY = (datesAreaSize.height - (offset.y + 1) * dateSize.height) + 0.5 * (dateSize.height - firstFigureGlyphAdvance.height);
            
            glyphPositions[glyphIterator++] = CGPointMake(offset.x * dateSize.width + 0.5 * (dateSize.width - firstFigureGlyphAdvance.width) - 0.5 *secondFigureGlyphAdvance.width,
                                                          glyphPositionY);
            
            glyphPositions[glyphIterator++] = CGPointMake(offset.x * dateSize.width + 0.5 * (dateSize.width - secondFigureGlyphAdvance.width) + 0.5 * firstFigureGlyphAdvance.width,
                                                          glyphPositionY);
        }
        
        // Events markers drawing
        if (eventsForDates) {
            
            NSDate *date = [beginningOfMonthDate dateByAddingTimeInterval:secondsInSingleDay * i];
            NSArray *eventsForDate = [eventsForDates objectForKey:date];
            
            if ([eventsForDate count] > 0) {
                UIColor *categoryColor = [_colorsForEventCategories objectForKey:[[eventsForDate firstObject] eventCategory]];
                
                if (!categoryColor) {
                    categoryColor = [UIColor grayColor];
                }
                
                CGContextSetFillColorWithColor(ctx, categoryColor.CGColor);
                CGContextFillEllipseInRect(ctx, UIEdgeInsetsInsetRect(CGRectMake(offset.x * dateSize.width,
                                                                                 offset.y * dateSize.height + monthNameHeight - dateSize.height / 4,
                                                                                 dateSize.width,
                                                                                 dateSize.height),
                                                                      UIEdgeInsetsMake(1.0f, 1.0f, 1.0f, 1.0f)));
            }
        }
        
        datesIterator++;
        
    }
    
    // Glyphs drawing
    CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, size.height);
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    CGContextSetTextMatrix(ctx, transform);
    
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CTFontDrawGlyphs(_glyphsHelper.font, _glyphsHelper.glyphs, glyphPositions, glyphIterator, ctx);
    free(glyphPositions);
    
    // Drawing month title
    [self drawMonthTitleInContext:ctx inRect:monthNameFrame monthName:[_monthTitleDateFormatter stringFromDate:monthDate]];
    
    return ctx;
    
}

- (void)drawMonthTitleInContext:(CGContextRef)ctx inRect:(CGRect)rect monthName:(NSString *)monthName {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    
    NSDictionary *attributes = @{(id)kCTForegroundColorAttributeName : (id)[UIColor colorWithRed:1.0f green:59 / 255.0f blue:48 / 255.0f alpha:1.0f].CGColor,
                                 NSFontAttributeName                 : [UIFont systemFontOfSize:12.0f]};
    NSAttributedString* attString = [[NSAttributedString alloc] initWithString:monthName
                                                                    attributes:attributes];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attString length]), path, NULL);
    
    CGContextSetFillColorWithColor(ctx, [UIColor orangeColor].CGColor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor orangeColor].CGColor);
    CTFrameDraw(frame, ctx);
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    
}

#pragma mark - CG Helpers

CG_INLINE CGContextRef CGContextCreate(CGSize size) {
    
    CGFloat scaleFactor = [[UIScreen mainScreen] scale];
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(NULL, size.width * scaleFactor, size.height * scaleFactor, 8, size.width * 2 * (CGColorSpaceGetNumberOfComponents(space) + 1), space, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextScaleCTM(ctx, scaleFactor, scaleFactor);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    CGContextSetShouldAntialias(ctx, YES);
    CGContextSetAllowsAntialiasing(ctx, YES);
	CGColorSpaceRelease(space);
    
	return ctx;
    
}

CG_INLINE UIImage* UIGraphicsGetImageFromContext(CGContextRef ctx) {
    
	CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
	UIImage* image = [UIImage imageWithCGImage:cgImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDownMirrored];
	CGImageRelease(cgImage);
    
	return image;
    
}

@end
