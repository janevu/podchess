//
//  SettingViewController.h
//  PodChess
//
//  Created by Nevo(nhua@geminimobile.com) on 8/17/09.
//  Copyright 2009 Gemini Mobile Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingViewController : UIViewController {
    IBOutlet UISlider *difficulty_setting;
    IBOutlet UISlider *time_setting;
}

@property(nonatomic,retain) IBOutlet UISlider *difficulty_setting;
@property(nonatomic,retain) IBOutlet UISlider *time_setting;

@end
