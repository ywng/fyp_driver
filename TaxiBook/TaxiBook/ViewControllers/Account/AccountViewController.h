//
//  AccountViewController.h
//  
//
//  Created by Tony Tsang on 18/3/14.
//
//

#import <UIKit/UIKit.h>

@interface AccountViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UISwitch *isAvailableSwitch;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

-(IBAction) isAvailableSwitchValueChanged;

@end
