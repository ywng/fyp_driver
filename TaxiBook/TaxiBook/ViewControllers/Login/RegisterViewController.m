//
//  TaxiBookRegisterViewController.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 27/11/13.
//  Copyright (c) 2013 taxibook. All rights reserved.
//

#import "RegisterViewController.h"
#import <SSKeychain/SSKeychain.h>
#import <NSUserDefaults+SecureAdditions.h>
#import "SubView.h"
#import "FDTakeController.h"
#import "OrderTableViewController.h"

@interface RegisterViewController ()<FDTakeDelegate>

@end

@implementation RegisterViewController
@synthesize selectedLicenseImageView;


- (IBAction)uploadLicenseButtonPressed:(id)sender {
    [self.takeController takePhotoOrChooseFromLibrary];
    self.takeController.allowsEditingPhoto = false;
}

- (IBAction)registerButtonPressed:(id)sender {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (self.emailTextField.text.length > 0) {
        [dict setObject:self.emailTextField.text forKey:@"email"];
    }else{
        [SubView showError:@"Please input email address!" withTitle:@"Register Failed"];
        return;
    }
    if (self.phoneTextField.text.length > 0) {
        [dict setObject:self.phoneTextField.text forKey:@"phone"];
    }else{
        [SubView showError:@"Please input 8-digit phone number!" withTitle:@"Register Failed"];
        return;
    }
    if (self.firstNameTextField.text.length > 0) {
        [dict setObject:self.firstNameTextField.text forKey:@"first_name"];
    }else{
        [SubView showError:@"Please input your first name!" withTitle:@"Register Failed"];
        return;
    }
    if (self.lastNameTextField.text.length > 0) {
        [dict setObject:self.lastNameTextField.text forKey:@"last_name"];
    }else{
        [SubView showError:@"Please input your last name!" withTitle:@"Register Failed"];
        return;
    }
    if (self.passwordTextField.text.length > 0) {
        [dict setObject:self.passwordTextField.text forKey:@"password"];
    }else{
        [SubView showError:@"Please input at least 6 character password!" withTitle:@"Register Failed"];
        return;
    }
    if(![self.retypePasswordTextField.text isEqualToString:self.passwordTextField.text]){
        [SubView showError:@"Please ensure the password is typed correctly!" withTitle:@"Register Failed"];
        return;
    }
    if (self.driverLicense.text.length > 0) {
        [dict setObject:self.driverLicense.text forKey:@"license_no"];
    }else{
        [SubView showError:@"Please input driver license number!" withTitle:@"Register Failed"];
        return;
    }
    
    if (self.selectedLicenseImageView.image) {
        
    }else{
        [SubView showError:@"Please upload a driver license photo!" withTitle:@"Register Failed"];
        return;
    }
    
    [self.emailTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    TaxiBookConnectionManager *manager = [TaxiBookConnectionManager sharedManager];
    // [self setupLoadingView];
 
    [manager registerDriver:dict image:self.licenseImage success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // get the pid
        NSLog(@"responseObject %@", responseObject);
        
        NSInteger did = [[responseObject objectForKey:@"did"] integerValue];
        
        [[NSUserDefaults standardUserDefaults] setSecretObject:self.emailTextField.text forKey:TaxiBookInternalKeyEmail];
        [[NSUserDefaults standardUserDefaults] setSecretObject:self.firstNameTextField.text forKey:TaxiBookInternalKeyFirstName];
        [[NSUserDefaults standardUserDefaults] setSecretObject:self.lastNameTextField.text forKey:TaxiBookInternalKeyLastName];
        [[NSUserDefaults standardUserDefaults] setSecretInteger:did forKey:TaxiBookInternalKeyUserId];

        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [manager loginwithParemeters:@{@"email": self.emailTextField.text, @"password": self.passwordTextField.text, @"user_type": @"driver",@"license_no":self.driverLicense.text} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //the notification is already included in login request
            //[[NSNotificationCenter defaultCenter] postNotificationName:TaxiBookNotificationUserLoggedIn object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            [SubView dismissAlert];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SubView dismissAlert];
            NSLog(@"error login %@", error);
            
            if ([error.domain isEqualToString:TaxiBookServiceName]) {
                NSString *message = [error.userInfo objectForKey:@"message"];
                [SubView showError:message withTitle:@"Register Failed"];
            }else{
                [SubView showError:@"Cannot login after registration!" withTitle:@"Login Failed"];
            }
            
        }];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SubView dismissAlert];
        NSLog(@"error on register %@", error);
        
        if ([error.domain isEqualToString:TaxiBookServiceName]) {
            NSString *message = [error.userInfo objectForKey:@"message"];
            [SubView showError:message withTitle:@"Register Failed"];
        }else{
            [SubView showError:@"Cannot register an account!" withTitle:@"Registration Failed"];
        }
        
    }];
    
    [SubView loadingView:nil];
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.

}


#pragma mark - VC Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
   // [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    self.takeController = [[FDTakeController alloc] init];
    self.takeController.viewControllerForPresentingImagePickerController = self;
    self.takeController.delegate = self;
    self.takeController.allowsEditingPhoto = YES;
    self.takeController.tabBar = self.tabBarController.tabBar;
    
	// Do any additional setup after loading the view.
//    [self.emailTextField setText:@"default_email2@email.com"];
//    [self.phoneTextField setText:@"98765431"];
//    [self.firstNameTextField setText:@"default_first"];
//    [self.lastNameTextField setText:@"default_last"];
//    [self.passwordTextField setText:@"passwordSecret"];
    
  
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    [super viewWillDisappear:animated];
}


#pragma mark - FDTakeDelegate

- (void)takeController:(FDTakeController *)controller didCancelAfterAttempting:(BOOL)madeAttempt
{
    UIAlertView *alertView;
    alertView = [[UIAlertView alloc] initWithTitle:@"Upload License" message:@"You must upload a valid driver license!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertView show];
}

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info
{
    [self.selectedLicenseImageView setImage:photo];
    self.licenseImage=photo;
}

- (void)viewDidUnload {
    [self setSelectedLicenseImageView:nil];
    [super viewDidUnload];
}


@end
