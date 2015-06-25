//
//  ViewController.m
//  RDNumberPickerDemo
//
//  Created by Ricky Dunn on 25/06/2015.
//  Copyright (c) 2015 BoldRocket. All rights reserved.
//

#import "ViewController.h"
#import "RDNumberPicker/RDNumberPicker.h"

@interface ViewController () <RDNumberPickerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *guestLabel;
@property (nonatomic, weak) IBOutlet RDNumberPicker *guestsPicker;
@property (nonatomic, weak) IBOutlet UILabel *bedroomsLabel;
@property (nonatomic, strong) RDNumberPicker *bedroomsPicker;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.guestsPicker.numberPickerDelegate = self;
    
    self.bedroomsPicker = [[RDNumberPicker alloc] initWithFrame:CGRectMake(15, 190, 345, 80)];
    self.bedroomsPicker.minimumValue = 1;
    self.bedroomsPicker.maximumValue = 5;
    self.bedroomsPicker.defaultValue = 1;
    self.bedroomsPicker.unselectedColor = [UIColor lightGrayColor];
    self.bedroomsPicker.selectedColor = [UIColor colorWithRed:250.0/255.0 green:134.0/255.0 blue:140.0/255.0 alpha:1.0];
    self.bedroomsPicker.backgroundColor = [UIColor whiteColor];
    self.bedroomsPicker.numberPickerDelegate = self;
    [self.view addSubview:self.bedroomsPicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - RDNumberDelegate
- (void)numberPicker:(RDNumberPicker *)numberPicker didPickNumber:(NSInteger)value atIndex:(NSInteger)index
{
    if (numberPicker == self.guestsPicker) {
        self.guestLabel.text = [NSString stringWithFormat:@"%ld", (long)value];
    } else if (numberPicker == self.bedroomsPicker) {
        self.bedroomsLabel.text = [NSString stringWithFormat:@"%ld", (long)value];
    }
}

- (IBAction)submit:(id)sender
{
    NSInteger numberOfGuests = self.guestsPicker.currentValue;
    NSInteger numberOfBedrooms = self.bedroomsPicker.currentValue;
    
    NSString *alertText = [NSString stringWithFormat:@"Guests: %ld Bedrooms: %ld", (long)numberOfGuests, (long)numberOfBedrooms];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
