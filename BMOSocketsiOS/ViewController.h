//
//  ViewController.h
//  BMOSocketsiOS
//
//  Created by Breno on 05/04/21.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


// This property can only be used in Objective-C++ code
#ifdef atributeBMOSocketiOS
@property  (weak, nonatomic) BMOSocketiOS *bmo;
#endif

@end

