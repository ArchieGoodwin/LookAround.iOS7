//
//  NWTwitterCell.m
//  LookAround
//
//  Created by Sergey Dikarev on 2/12/13.
//  Copyright (c) 2013 Sergey Dikarev. All rights reserved.
//

#import "NWTwitterCell.h"
#import "NWtwitter.h"
#import "NWLabel.h"
#import "DKAHelper.h"
#import "Defines.h"
@implementation NWTwitterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) { // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"TwitterCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) { return nil; }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UITableViewCell class]]) { return nil; }
        
        self = [arrayOfViews objectAtIndex:0];
        
        
    }
    
    return self;
}



-(void) setTweet:(NWtwitter *)tweet{
    
    _lblText.text = tweet.message;
    _lblText.verticalAlignment = VerticalAlignmentTop;
    _lblDate.text =  [NSDateFormatter localizedStringFromDate:tweet.dateCreated dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    _lblAuthor.text = tweet.author;
    if(tweet.iconUrl)
    {
        UIImage *cacheImage =  [_imagesCache objectForKey:tweet.iconUrl];
        
        if(!cacheImage)
        {
            NSURLSessionDownloadTask *getImageTask =
            [helper.session downloadTaskWithURL:[NSURL URLWithString:tweet.iconUrl]
                              completionHandler:^(NSURL *location, NSURLResponse *response,
                                                  NSError *error) {
                                  // 2
                                  UIImage *downloadedImage = [UIImage imageWithData:
                                                              [NSData dataWithContentsOfURL:location]];
                                  //3
                                  
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      if(downloadedImage)
                                      {
                                          [_imagesCache setObject:downloadedImage forKey:tweet.iconUrl];
                                          
                                          self.imgProfile.image = downloadedImage;
                                      }
                                     
                                  });
                              }];
            
            [getImageTask resume];
            
            
        }
        else
        {
            self.imgProfile.image = cacheImage;
            
        }
    }
    
    
}


-(void)setAll:(NWtwitter *)twit
{
    
    
   // [_lblText sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
