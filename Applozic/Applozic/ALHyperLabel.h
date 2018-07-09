//
//  ALHyperLabel.h
//  ALHyperLabelDemo


#import <UIKit/UIKit.h>

@interface ALHyperLabel : UILabel

@property (nonatomic) NSDictionary *linkAttributeDefault;
@property (nonatomic) NSDictionary *linkAttributeHighlight;

- (void)setLinkForRange:(NSRange)range withAttributes:(NSDictionary *)attributes andLinkHandler:(void (^)(ALHyperLabel *label, NSRange selectedRange))handler;
- (void)setLinkForRange:(NSRange)range withLinkHandler:(void(^)(ALHyperLabel *label, NSRange selectedRange))handler;

- (void)setLinkForSubstring:(NSString *)substring withAttribute:(NSDictionary *)attribute andLinkHandler:(void(^)(ALHyperLabel *label, NSString *substring))handler;
- (void)setLinkForSubstring:(NSString *)substring withLinkHandler:(void(^)(ALHyperLabel *label, NSString *substring))handler;

- (void)setLinksForSubstrings:(NSArray *)substrings withLinkHandler:(void(^)(ALHyperLabel *label, NSString *substring))handler;

- (void)clearActionDictionary;

@end
