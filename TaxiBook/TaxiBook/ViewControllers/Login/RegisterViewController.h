//
//  RegisterViewController.h
//  TaxiBook
//
//  Created by Chan Ho Pan on 27/11/13.
//  Copyright (c) 2013 taxibook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDTakeController.h"

@interface RegisterViewController : UIViewController <UITextFieldDelegate>
@property FDTakeController *takeController;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *retypePasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *driverLicense;

@property (weak, nonatomic) IBOutlet UIButton *uploadLicenseButton;
@property (weak, nonatomic) IBOutlet UIImageView *selectedLicenseImageView;



@end
