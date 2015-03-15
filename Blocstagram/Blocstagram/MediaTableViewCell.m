//
//  MediaTableViewCell.m
//  Blocstagram
//
//  Created by Waine Tam on 2/16/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "MediaTableViewCell.h"
#import "Media.h"
#import "Comment.h"
#import "User.h"

@interface MediaTableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *imageWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *usernameAndCaptionLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *usernameAndCaptionLabelWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *usernameAndCaptionLabelLeftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentLabelWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentLabelLeftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentLabelTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *usernameAndCaptionLabelTopConstraint;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

static UIFont *lightFont;
static UIFont *boldFont;
static UIColor *usernameLabelGray;
static UIColor *commentLabelGray;
static UIColor *linkColor;
static NSParagraphStyle *paragraphStyle;

@implementation MediaTableViewCell
+ (void)load {
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:13];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    usernameLabelGray = [UIColor colorWithRed:1 green:1 blue:1 alpha:1]; // #fff
    commentLabelGray = [UIColor colorWithRed:1 green:1 blue:1 alpha:1]; // #fff
    linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1]; // #58506d
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    mutableParagraphStyle.tailIndent = -20.0;
    mutableParagraphStyle.paragraphSpacingBefore = 5;
    mutableParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    paragraphStyle = mutableParagraphStyle;
}

+ (CGFloat)heightForMediaItem:(Media *)mediaItem width:(CGFloat)width {
    // make a cell
    MediaTableViewCell *layoutCell = [[MediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
//    
//    // set it again to the given width, and the max possible height
//    layoutCell.frame = CGRectMake(0, 0, width, CGFLOAT_MAX);
//    
//    // give it to the media item
    layoutCell.mediaItem = mediaItem;
    
    layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    [layoutCell setNeedsLayout];
    
    [layoutCell layoutIfNeeded];
    
//    NSLog(@"height for media item %f", CGRectGetMaxY(layoutCell.mediaImageView.frame));
    
    // get the actual height required for the cell
    return CGRectGetMaxY(layoutCell.mediaImageView.frame) + layoutCell.usernameAndCaptionLabel.frame.size.height + layoutCell.commentLabel.frame.size.height;
//    return CGRectGetMaxY(layoutCell.mediaImageView.frame) + MAX(100, CGRectGetMaxY(layoutCell.usernameAndCaptionLabel.frame) + CGRectGetMaxY(layoutCell.commentLabel.frame));
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // initialization code
        self.mediaImageView = [[UIImageView alloc] init];
        
        self.mediaImageView.userInteractionEnabled = YES;
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        self.tapGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.tapGestureRecognizer];
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        self.longPressGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.longPressGestureRecognizer];
        
        self.usernameAndCaptionLabel = [[UILabel alloc] init];
        self.usernameAndCaptionLabel.numberOfLines = 0;
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel]) {
            [self.contentView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel);
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView]|" options:kNilOptions metrics:nil views:viewDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel]|" options:kNilOptions metrics:nil views:viewDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentLabel]|" options:kNilOptions metrics:nil views:viewDictionary]];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel]" options:kNilOptions metrics:nil views:viewDictionary]];
        
//        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView]" options:kNilOptions metrics:nil views:viewDictionary]];
        
//        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel]|" options:kNilOptions metrics:nil views:viewDictionary]];
        
        self.imageHeightConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant: [UIScreen mainScreen].bounds.size.width];
        
//        self.imageWidthConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView
//                                                                  attribute:NSLayoutAttributeWidth
//                                                                  relatedBy:NSLayoutRelationEqual
//                                                                     toItem:nil
//                                                                  attribute:NSLayoutAttributeNotAnAttribute
//                                                                 multiplier:1
//                                                                   constant:320];
        
        self.usernameAndCaptionLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                                   multiplier:1
                                                                                     constant:100];
        
//        self.usernameAndCaptionLabelWidthConstraint = [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel
//                                                                                    attribute:NSLayoutAttributeWidth
//                                                                                    relatedBy:NSLayoutRelationEqual
//                                                                                       toItem:nil
//                                                                                    attribute:NSLayoutAttributeNotAnAttribute
//                                                                                   multiplier:1
//                                                                                     constant:100];
        
        self.commentLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_commentLabel
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:100];
        
//        self.commentLabelWidthConstraint = [NSLayoutConstraint constraintWithItem:_commentLabel
//                                                                         attribute:NSLayoutAttributeWidth
//                                                                         relatedBy:NSLayoutRelationEqual
//                                                                            toItem:nil
//                                                                         attribute:NSLayoutAttributeNotAnAttribute
//                                                                        multiplier:1
//                                                                          constant:100];

        
//        self.usernameAndCaptionLabelLeftConstraint = [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel
//                                                                                    attribute:NSLayoutAttributeLeft
//                                                                                    relatedBy:NSLayoutRelationEqual
//                                                                                       toItem:_mediaImageView
//                                                                                    attribute:NSLayoutAttributeLeft
//                                                                                   multiplier:1
//                                                                                     constant:0];
//        
//        self.commentLabelLeftConstraint = [NSLayoutConstraint constraintWithItem:_commentLabel
//                                                                         attribute:NSLayoutAttributeLeft
//                                                                         relatedBy:NSLayoutRelationEqual
//                                                                            toItem:_mediaImageView
//                                                                         attribute:NSLayoutAttributeLeft
//                                                                        multiplier:1
//                                                                          constant:0];
        
//        self.commentLabelTopConstraint = [NSLayoutConstraint constraintWithItem:_commentLabel
//                                                                       attribute:NSLayoutAttributeTop
//                                                                       relatedBy:NSLayoutRelationEqual
//                                                                          toItem:_usernameAndCaptionLabel
//                                                                       attribute:NSLayoutAttributeLeft
//                                                                      multiplier:1
//                                                                        constant:20];
        
//        self.usernameAndCaptionLabelTopConstraint = [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel
//                                                                       attribute:NSLayoutAttributeTop
//                                                                       relatedBy:NSLayoutRelationEqual
//                                                                          toItem:_mediaImageView
//                                                                       attribute:NSLayoutAttributeBottom
//                                                                      multiplier:1
//                                                                        constant:200];
        
        [self.contentView addConstraints:@[self.imageHeightConstraint, self.usernameAndCaptionLabelHeightConstraint, self.commentLabelHeightConstraint
                                           ]];
        
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // before layout, calculate the intrinsic size of the labels (the size they 'want' to be), and add 20 to the height
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
    CGSize usernameLabelSize = [self.usernameAndCaptionLabel sizeThatFits:maxSize];
    CGSize commentLabelSize = [self.commentLabel sizeThatFits:maxSize];
    usernameLabelSize.width = [UIScreen mainScreen].bounds.size.width;
    
    //    self.usernameAndCaptionLabelWidthConstraint.constant = maxSize.width;
    self.usernameAndCaptionLabelHeightConstraint.constant = usernameLabelSize.height + 20;

    self.commentLabelHeightConstraint.constant = commentLabelSize.height + 20;
//    self.commentLabelWidthConstraint.constant = CGRectGetWidth(self.contentView.bounds);

    // section below moved from setMediaItem
    if (_mediaItem.image) {
        self.imageHeightConstraint.constant = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
    } else {
        self.imageHeightConstraint = 0;
    }
    
    // hide the line between cells
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.bounds));
}

- (void)setMediaItem:(Media *)mediaItem {
    _mediaItem = mediaItem;
    self.mediaImageView.image = _mediaItem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];
    
//    self.imageWidthConstraint.constant = CGRectGetWidth(self.contentView.bounds);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:NO animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
//    [super setSelected:NO animated:animated];

    // Configure the view for the selected state
}

- (NSAttributedString *)usernameAndCaptionString {
    CGFloat usernameFontSize = 15;
    
    // make a string that says 'username caption text'
    NSString *baseString = [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName, self.mediaItem.caption];
    
    // make an attributed string, with the 'username bold'
    NSMutableAttributedString *mutableUsernameAndCaptionString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize], NSParagraphStyleAttributeName: paragraphStyle}];
    
    NSRange usernameRange = [baseString rangeOfString:self.mediaItem.user.userName];
    [mutableUsernameAndCaptionString addAttribute:NSFontAttributeName value:[boldFont fontWithSize:usernameFontSize] range:usernameRange];
    [mutableUsernameAndCaptionString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
    
    return mutableUsernameAndCaptionString;
}

- (NSAttributedString *)commentString {
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] init];
    
    for (Comment *comment in self.mediaItem.comments) {
        // make a string that says 'username comment text' followed by a line break
        NSString *baseString = [NSString stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];
        
        // make an attributed string, with the 'username' bold
        
        NSMutableAttributedString *oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSParagraphStyleAttributeName : paragraphStyle}];
        
        NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
        [oneCommentString addAttribute:NSFontAttributeName value:boldFont range:usernameRange];
        [oneCommentString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
        
        [commentString appendAttributedString:oneCommentString];
    }
    
    return commentString;
}

#pragma mark - Image View

- (void) tapFired:(UITapGestureRecognizer *)sender {
    [self.delegate cell:self didTapImageView:self.mediaImageView];
}

- (void) longPressFired:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.delegate cell:self didLongPressImageView:self.mediaImageView];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.isEditing == NO;
}


@end
