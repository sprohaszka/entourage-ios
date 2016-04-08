//
//  OTUserEditViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 01/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

// Controllers
#import "OTUserEditViewController.h"
#import "UIViewController+menu.h"
#import "OTUserEditPasswordViewController.h"

// Service
#import "OTAuthService.h"

// Helpers
#import "UIColor+entourage.h"
#import "NSUserDefaults+OT.h"
#import "UIButton+AFNetworking.h"
#import "SVProgressHUD.h"
#import "A0SimpleKeychain.h"

typedef NS_ENUM(NSInteger) {
    SectionTypeSummary,
    SectionTypeInfoPrivate,
    SectionTypeInfoPublic,
    SectionTypeAssociations,
    SectionTypeDelete
} SectionType;

#define EDIT_PASSWORD_SEGUE @"EditPasswordSegue"

@interface OTUserEditViewController() <UITableViewDelegate, UITableViewDataSource, OTUserEditPasswordProtocol>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UITextField *firstNameTextField;
@property (nonatomic, strong) UITextField *lastNameTextField;

@end

@implementation OTUserEditViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PROFIL";
    [self setupCloseModal];
    [self showSaveButton];
    
    self.user = [[NSUserDefaults standardUserDefaults] currentUser];


}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:EDIT_PASSWORD_SEGUE]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        OTUserEditPasswordViewController *controller = (OTUserEditPasswordViewController*)navController.topViewController;
        controller.delegate = self;
    }
}

/**************************************************************************************************/
#pragma mark - Private

- (void)showSaveButton {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Enregistrer"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(updateUser)];
    [saveButton setTintColor:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:saveButton];
}

- (void)updateUser {
    
    self.user.firstName = [self editedTextAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:SectionTypeSummary]];
    self.user.lastName = [self editedTextAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:SectionTypeSummary]];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"user_edit_saving", @"")];
    [[OTAuthService new] updateUserInformationWithUser:self.user success:^(OTUser *user) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"user_edit_saved_ok", @"")];
        [[NSUserDefaults standardUserDefaults] setCurrentUser:user];
        if (self.user.password != nil) {
            [[A0SimpleKeychain keychain] setString:self.user.password forKey:kKeychainPassword];
        }
        
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"user_edit_saved_error", @"")];
        NSLog(@"%@", [error description]);
    }];
}

/**************************************************************************************************/
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionTypeSummary: {
            return 3;
        }
        case SectionTypeInfoPrivate: {
            return 3;
        }
        case SectionTypeInfoPublic: {
            return 0;
        }
        case SectionTypeAssociations: {
            return self.user.organization == nil ? 0 : 1;
        }
        default:
            return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    CGFloat height = 0.0f;
    switch (section) {
        case SectionTypeInfoPrivate:
            height = 45.0f;
            break;
        case SectionTypeAssociations:
            height = self.user.organization == nil ? 0.0f : 45.0f;
        default:
            break;
    }
    return height;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return .5f;
    
}

#define CELLHEIGHT_SUMMARY 135.0f
#define CELLHEIGHT_TITLE    33.0f
#define CELLHEIGHT_ENTOURAGES  80.0f
#define CELLHEIGHT_DEFAULT  51.0f

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SectionTypeSummary: {
            
            if (indexPath.row == 0)
                return CELLHEIGHT_SUMMARY;
            else
                return CELLHEIGHT_DEFAULT;
        }
        case SectionTypeInfoPrivate: {
            return CELLHEIGHT_DEFAULT;
        }
        case SectionTypeInfoPublic: {
            return CELLHEIGHT_DEFAULT;
        }
        case SectionTypeAssociations: {
            return CELLHEIGHT_ENTOURAGES;
        }
            
        default:
            return CELLHEIGHT_DEFAULT;;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 15)];
    headerView.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    headerView.textColor = [UIColor appGreyishBrownColor];
    headerView.backgroundColor = [UIColor appPaleGreyColor];
    headerView.text = (section == 1 ? @"Informations privées" : @"Association(s)");
    headerView.textAlignment = NSTextAlignmentCenter;
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID;
    switch (indexPath.section) {
        case SectionTypeSummary: {
            cellID = indexPath.row == 0 ? @"SummaryProfileCell" : @"EditProfileCell";
            break;
        }
        case SectionTypeInfoPrivate: {
            switch (indexPath.row) {
                case 0:
                    cellID = @"EditProfileCell";
                    break;
                case 1:
                    cellID = @"EditPasswordCell";
                    break;
                case 2:
                    cellID = @"PhoneCell";
                    break;
                default:
                    break;
            }
            break;
        }
        case SectionTypeInfoPublic: {
            cellID = @"EntouragesProfileCell";
            break;
        }
        case SectionTypeAssociations: {
            cellID = @"AssociationProfileCell";
            break;
        }
        default:
            break;
    }
    //NSLog(@"cell id: %@ at %@", cellID, indexPath.description);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    switch (indexPath.section) {
        case SectionTypeSummary: {
            if (indexPath.row == 0) {
                [self setupSummaryProfileCell:cell];
                
            } else {
                NSString *title = indexPath.row == 1 ? @"Prénom" : @"Nom";
                NSString *text = indexPath.row == 1 ? self.user.firstName : self.user.lastName;
                UITextField *textField = indexPath.row == 1 ? self.firstNameTextField : self.lastNameTextField;
                [self setupInfoCell:cell withTitle:title withTextField:textField andText:text];

            }
            break;
        }
        case SectionTypeInfoPrivate: {
            switch (indexPath.row) {
                case 0:
                    [self setupInfoCell:cell withTitle:@"E-mail" withTextField:nil andText:self.user.email];
                    break;
                case 1:
                    //nothing
                    break;
                case 2:
                    [self setupPhoneCell:cell withPhone:self.user.phone];
                    break;
                default:
                    break;
            }
            break;
        }
        case SectionTypeInfoPublic: {
            [self setupEntouragesProfileCell:cell];
            break;
        }
        case SectionTypeAssociations: {
            if (self.user.organization != nil) {
                [self setupAssociationProfileCell:cell
                             withAssociationTitle:self.user.organization.name
                              andAssociationImage:self.user.organization.logoUrl];
            }
            break;
        }
            
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SectionTypeInfoPrivate) {
        if (indexPath.row == 1) {
            [self performSegueWithIdentifier:EDIT_PASSWORD_SEGUE sender:nil];
        }
    }
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
}

/**************************************************************************************************/
#pragma mark - TableViewCells Setup

#define SUMMARY_AVATAR_TAG 1

#define CELL_TITLE_TAG 10
#define CELL_TEXTFIELD_TAG 20

#define PHONE_LABEL_TAG 1

#define VERIFICATION_LABEL_TAG 1
#define VERIFICATION_STATUS_TAG 2

#define NOENTOURAGES_TAG 1

#define ASSOCIATION_TITLE_TAG 1
#define ASSOCIATION_IMAGE_TAG 2


- (void)setupSummaryProfileCell:(UITableViewCell *)cell
{
    
    UIButton *avatarButton = [cell viewWithTag:SUMMARY_AVATAR_TAG];
    avatarButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [avatarButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [avatarButton.layer setShadowOpacity:0.5];
    [avatarButton.layer setShadowRadius:4.0];
    [avatarButton.layer setShadowOffset:CGSizeMake(0.0, 1.0)];
    
    cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
}

- (void)setupTitleProfileCell:(UITableViewCell *)cell withTitle:(NSString *)title {
    UILabel *titleLabel = [cell viewWithTag:CELL_TITLE_TAG];
    titleLabel.text = title;
    
    cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
}

- (void)setupInfoCell:(UITableViewCell *)cell
            withTitle:(NSString *)title
        withTextField:(UITextField *)myTextField
              andText:(NSString *)text
{
    UILabel *titleLabel = [cell viewWithTag:CELL_TITLE_TAG];
    titleLabel.text = title;
    
    
    UITextField *nameTextField = [cell viewWithTag:CELL_TEXTFIELD_TAG];
    myTextField = nameTextField;
    nameTextField.text = text;
}

- (NSString *)editedTextAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UITextField * textField = [cell viewWithTag:CELL_TEXTFIELD_TAG];
    if (textField != nil && [textField isKindOfClass:[UITextField class]]) {
        return textField.text;
    }
    return nil;
}

- (void)setupEntouragesProfileCell:(UITableViewCell *)cell {
    UILabel *noEntouragesLabel = [cell viewWithTag:NOENTOURAGES_TAG];
    noEntouragesLabel.text = [NSString stringWithFormat:@"%d", 1];
}

- (void)setupAssociationProfileCell:(UITableViewCell *)cell
               withAssociationTitle:(NSString *)title
                andAssociationImage:(NSString *)imageURL
{
    UILabel *titleLabel = [cell viewWithTag:ASSOCIATION_TITLE_TAG];
    titleLabel.text = title;
    
    UIButton *associationImageButton = [cell viewWithTag:ASSOCIATION_IMAGE_TAG];
    if (associationImageButton != nil && imageURL != nil) {
        [associationImageButton setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:imageURL]];
    }
}

- (void)setupPhoneCell:(UITableViewCell *)cell
             withPhone:(NSString *)phone
{
    UILabel *phoneLabel = [cell viewWithTag:PHONE_LABEL_TAG];
    if (phoneLabel != nil) {
        phoneLabel.text = phone;
    }
}

/**************************************************************************************************/
#pragma mark - OTUserEditPasswordProtocol

- (void)setNewPassword:(NSString *)password
{
    self.user.password = password;
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
