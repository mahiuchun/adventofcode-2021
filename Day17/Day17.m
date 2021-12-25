#import <ObjFW/ObjFW.h>

#define MAX(a,b) ((a)>(b)?(a):(b))

BOOL inside(int x, int y, int xmin, int xmax, int ymin, int ymax) {
	if (x < xmin || x > xmax) return NO;
	if (y < ymin || y > ymax) return NO;
	return YES;
}

int valid(int vx, int vy, int xmin, int xmax, int ymin, int ymax) {
	int x = 0, y = 0;
	int best = 0;
	BOOL reached = NO;
	for (;;) {
		best = MAX(best, y);
		if (inside(x, y, xmin, xmax, ymin, ymax)) {
			reached = YES;
		}
		x += vx;
		y += vy;
		if (vx > 0) vx -= 1;
		if (vx < 0) vx += 1;
		vy -= 1;
		if (x < xmin && vx <= 0) break;
		if (x > xmax && vx >= 0) break;
		if (xmin <= x && x <= xmax && y < ymin) break;
	}
	if (reached) {
		return best;
	} else {
		return -1;
	}
}

@interface Day17: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day17)

@implementation Day17
- (void)applicationDidFinishLaunching
{
	OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
	OFString *s = [f readLine];
	int xmin, xmax, ymin, ymax;
	int i, j, best = 0;
	OFArray *a = [s componentsSeparatedByString:@", "];
	OFString *xs = [[a objectAtIndex:0] substringFromIndex:15];
	xmin = (int)[[[xs componentsSeparatedByString:@".."] objectAtIndex:0] longLongValue];
	xmax = (int)[[[xs componentsSeparatedByString:@".."] objectAtIndex:1] longLongValue];
	OFString *ys = [[a objectAtIndex:1] substringFromIndex:2];
	ymin = (int)[[[ys componentsSeparatedByString:@".."] objectAtIndex:0] longLongValue];
	ymax = (int)[[[ys componentsSeparatedByString:@".."] objectAtIndex:1] longLongValue];
	[OFStdErr writeFormat:@"x: [%d, %d] y: [%d %d]\n", xmin, xmax, ymin, ymax];
	for (i = 1; i <= 1000; i++) {
		for (j = 1; j <= 1000; j++) {
			best = MAX(best, valid(i, j, xmin, xmax, ymin, ymax));
		}
	}
	[OFStdOut writeFormat:@"%d\n", best];
	[OFApplication terminate];
}
@end
