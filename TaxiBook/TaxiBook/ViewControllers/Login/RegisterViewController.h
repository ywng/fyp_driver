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
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;

@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;

@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *retypePasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *driverLicense;

@property (strong, nonatomic) IBOutlet UIButton *uploadLicenseButton;
@property (strong, nonatomic) IBOutlet UIImageView *selectedLicenseImageView;
@property (strong, nonatomic) UIImage *licenseImage;



@end
