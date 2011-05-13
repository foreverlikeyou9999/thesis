//
//  MayDemoViewController.m
//  MayDemo
//
//  Created by Russell de Moose on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MayDemoViewController.h"

@implementation MayDemoViewController


@synthesize table, done;
@synthesize arryData;



- (IBAction) sourceSelect: (id)sender {
	
	///[self createConverter];
	NSLog(@"Should now push new view onto stack, giving map interface");
	//[convert start];
	//NSLog(@"Sources selected");
	


		mapness = [[MapViewController alloc] initWithNibName: @"MapViewController" bundle: nil];
	
	[self.view addSubview:mapness.view];
	
	
}




- (void) viewDidLoad 

{
	
	//---------ARRAY FOR TABLE VIEW TEST-----------//
	
	arryData = [[NSArray alloc] initWithObjects:@"WNYC - FM: New York Public Radio",@"Carnegie Hall:Spring for Muzak", @"WFUV 128K", nil];
	if(arryData){
	NSLog (@"viewDidLoad");
	}
	//-----------------------------------END TABLE TEST-------------------------//
	
	
}

- (void)awakeFromNib


{
	
	NSLog(@"Loaded, guy");
	
}	

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}
//------------------TEST TABLE CODE---------------//



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// Set up the cell...
	cell.text = [arryData objectAtIndex:indexPath.row];
	return cell;
}

// Adds a checkmark to selected cells

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
	
	
    [theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:NO];
	
    UITableViewCell *cell = [theTableView cellForRowAtIndexPath:newIndexPath];
	
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
		
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
		
        // Reflect selection in data model
		
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
		
        cell.accessoryType = UITableViewCellAccessoryNone;
		
        // Reflect deselection in data model
		
    }
	
}
 
 
@end

