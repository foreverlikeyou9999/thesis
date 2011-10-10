#import "AugustDevViewController.h"

@implementation AugustDevViewController



@synthesize panner, done, table, arryData, imageView; 
 


//-----------------------------------------// 
- (void)viewDidLoad
{ 
	
	mapness = [[MapViewController alloc] initWithNibName: @"MapViewController" bundle: nil];
    [mapness resetStations];
  
	UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Hi there, explorer!" message:@"Please select up to three simultaneous sources." delegate:nil cancelButtonTitle:@"Hey, ok!" otherButtonTitles:nil];
	[errorAlert show];
	[errorAlert release]; 
		
		
	//---------ARRAY FOR TABLE VIEW TEST-----------//
	
	
	NSString *wfuv = @"WFUV 128K"; 
	NSString *wnyc = @"WNYC - FM: New York Public Radio";
	NSString *wbgo = @"WBGO Newark Public Radio";
	
		
	arryData = [[NSArray alloc] initWithObjects:wfuv, wnyc, wbgo, nil];

	if(arryData){
		NSLog (@"viewDidLoad");
		
	}

}
//--------------------------------------//


//--------------------------------------// 
- (IBAction) sourceSelect: (id)sender {
	
	
	NSLog(@"Should now push new view onto stack, giving map interface");
	//NSLog(@"Sources selected");

	
	[self.view addSubview:mapness.view];

	
	
}
//--------------------------------------//



//-----------Table Methods--------------------//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3; 
} 
//--------------------------------------//

//--------------------------------------//
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 
    return @"Streamscape: select a source."; 
}

//--------------------------------------//
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
//--------------------------------------//



//--------------------------------------//
// Adds a checkmark to selected cells

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {

		
    [theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:NO];
	
    UITableViewCell *cell = [theTableView cellForRowAtIndexPath:newIndexPath];
	
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
		
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
		[mapness setupStations];
        NSLog(@"selection is %i", newIndexPath.row);
		 [mapness captureStations:newIndexPath.row];
	
		
        // Reflect selection in data model
		
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
		
        cell.accessoryType = UITableViewCellAccessoryNone;
		
        // Reflect deselection in data model
		
    }
	
}
//--------------------------------------//




- (void)dealloc 
{  

	[super dealloc];
}

@end