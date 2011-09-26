#import "AugustDevViewController.h"

@implementation AugustDevViewController



@synthesize panner, done, table, arryData; 
 


//-----------------------------------------//
- (void)viewDidLoad
{
	[self createStreamer];
	
	
	//---------ARRAY FOR TABLE VIEW TEST-----------//
	arryData = [[NSArray alloc] initWithObjects:@"WNYC - FM: New York Public Radio",@"Carnegie Hall:Spring for Muzak", @"WFUV 128K", nil];
	if(arryData){
		NSLog (@"viewDidLoad");
	}

}
//--------------------------------------//


//--------------------------------------// 
- (IBAction) sourceSelect: (id)sender {
	
	
	NSLog(@"Should now push new view onto stack, giving map interface");
	//NSLog(@"Sources selected");
	

	mapness = [[MapViewController alloc] initWithNibName: @"MapViewController" bundle: nil];
	
	[self.view addSubview:mapness.view];
	
	
}
//--------------------------------------//


//--------------------------------------//
- (void)createStreamer
{
	if (stream)
	{
		return;
	}

	[stream fmodKill];
	
	stream = [[fmodStreamer alloc] init];
	
	[stream startStream];
	
	NSLog(@"Stream started called");
}
//--------------------------------------//



//--------------------------------------//
-(IBAction)pannerMoved:(id)sender {
	
	[stream changePan:panner.value];

}
//--------------------------------------//



//--------------------------------------//
- (void)viewWillDisappear:(BOOL)animated
{
    /*
	 Shut down
	 */    
   // [timer invalidate];
    
    [stream fmodKill];

}
//--------------------------------------//



//--------------------------------------//
- (IBAction)pauseResume:(id)sender 
{
    [stream pause];		
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
		
        // Reflect selection in data model
		
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
		
        cell.accessoryType = UITableViewCellAccessoryNone;
		
        // Reflect deselection in data model
		
    }
	
}
//--------------------------------------//




- (void)dealloc 
{  
	[time release];
	[status release];
	[buffered release];
	[lasttag release]; 
	[stream release];
	[super dealloc];
}

@end