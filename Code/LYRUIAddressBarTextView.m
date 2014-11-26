//
//  LYRUIAddresBarView.m
//  Pods
//
//  Created by Kevin Coleman on 10/27/14.
//
//

#import "LYRUIAddressBarTextView.h"
#import "LYRUIConstants.h"
#import "LYRUIMessagingUtilities.h"

NSString *const LYRUIAddressBarPartAttributeName = @"LYRUIAddressBarPart";
NSString *const LYRUIAddressBarNamePart = @"fullName";
NSString *const LYRUIAddressBarDelimiterPart = @"delimiter";

@interface LYRUIAddressBarTextView ()

@property (nonatomic) UILabel *toLabel;
@property (nonatomic) CGFloat maxHeight;

@end

@implementation LYRUIAddressBarTextView

static CGFloat const LYRUILineSpacing = 6;

- (id)init
{
    self = [super init];
    if (self) {
        _addressBarFont = LSMediumFont(14);
        _addressBarTextColor = [UIColor blackColor];
        _addressBarHighlightColor = LSBlueColor();

        self.backgroundColor = [UIColor clearColor];
        self.textContainerInset = UIEdgeInsetsMake(10, 0, 10, 0);

        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.firstLineHeadIndent = 28.0f;
        paragraphStyle.lineSpacing = LYRUILineSpacing;
        self.typingAttributes = @{NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: self.addressBarTextColor};
        self.font = self.addressBarFont;
        
        self.toLabel = [UILabel new];
        self.toLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.toLabel.text = @"To:";
        self.toLabel.textColor = LSGrayColor();
        self.toLabel.font = self.addressBarFont;
        [self addSubview:self.toLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.toLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:12]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.toLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:10]];
        // Adding the constraint below works around a crash on iOS 7.1. It will be overriden by the content size.
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.toLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];

        [self setUpMaxHeight];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    [self layoutSubviews];
    if (self.contentSize.height > self.maxHeight) {
        return CGSizeMake(self.contentSize.width, self.maxHeight);
    }
    return self.contentSize;
}

- (void)setAddressBarFont:(UIFont *)addressBarFont
{
    if (!addressBarFont) return;
    self.font = addressBarFont;
    self.toLabel.font = addressBarFont;
    [self setUpMaxHeight];
    [self invalidateIntrinsicContentSize];
    _addressBarFont = addressBarFont;
}

 - (void)setAddressBarTextColor:(UIColor *)addressBarTextColor
{
    if (!addressBarTextColor) return;
    _addressBarTextColor = addressBarTextColor;
    if (!self.userInteractionEnabled) return;
    NSAttributedString *attributedText = self.attributedText;
    NSMutableAttributedString *adjustedAttributedText = [attributedText mutableCopy];
    NSRange selectedRange = self.selectedRange;
    [attributedText enumerateAttributesInRange:NSMakeRange(0, attributedText.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        if (attrs[LYRUIAddressBarNamePart]) return;
        if (attrs[LYRUIAddressBarDelimiterPart]) return;
        [adjustedAttributedText addAttribute:NSForegroundColorAttributeName value:addressBarTextColor range:range];
    }];
    self.attributedText = adjustedAttributedText;
    self.selectedRange = selectedRange;
}

- (void)setAddressBarHighlightColor:(UIColor *)addressBarHighlightColor
{
    if (!addressBarHighlightColor) return;
    _addressBarHighlightColor = addressBarHighlightColor;
    if (!self.userInteractionEnabled) return;
    NSAttributedString *attributedText = self.attributedText;
    NSMutableAttributedString *adjustedAttributedText = [attributedText mutableCopy];
    NSRange selectedRange = self.selectedRange;
    [attributedText enumerateAttribute:LYRUIAddressBarPartAttributeName inRange:NSMakeRange(0, attributedText.length) options:0 usingBlock:^(NSString *partName, NSRange range, BOOL *stop) {
        if (!partName || ![partName isEqualToString:LYRUIAddressBarNamePart]) return;
        [adjustedAttributedText addAttribute:NSForegroundColorAttributeName value:addressBarHighlightColor range:range];
    }];
    self.attributedText = adjustedAttributedText;
    self.selectedRange = selectedRange;
}

- (void)setUpMaxHeight
{
    CGSize size = LYRUITextPlainSize(@" ", self.font);
    self.maxHeight = ceil(size.height) * 2 + LYRUILineSpacing + self.textContainerInset.top + self.textContainerInset.bottom;
}

@end
