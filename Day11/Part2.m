#import <ObjFW/ObjFW.h>

typedef struct grid {
  int d[12][12];
} Grid;

@interface Day11: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day11)

@implementation Day11
- (void)applicationDidFinishLaunching
{
  Grid grid, next, flash;
  OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
  OFString *s;
  int i = 0, j, k;
  long long tot = 0;
  BOOL cont;
  while ((s = [f readLine])) {
    i += 1;
    for (j = 1; j <= [s length]; ++j) {
      grid.d[i][j] = [s characterAtIndex:j-1] - '0';
    }
  }
  for (k = 1; k <= 10000; ++k) {
    for (i = 1; i <= 10; ++i) {
      for (j = 1; j <= 10; ++j) {
	next.d[i][j] = grid.d[i][j] + 1;
	flash.d[i][j] = 0;
      }
    }
    cont = YES;
    while (cont) {
      cont = NO;
      for (i = 1; i <= 10; ++i) {
	for (j = 1; j <= 10; ++j) {
	  if (next.d[i][j] > 9) {
	    next.d[i][j] = 0;
	    flash.d[i][j] = 1;
	    cont = YES;
	    next.d[i-1][j] += 1;
	    next.d[i-1][j+1] += 1;
	    next.d[i][j+1] += 1;
	    next.d[i+1][j+1] += 1;
	    next.d[i+1][j] += 1;
	    next.d[i+1][j-1] += 1;
	    next.d[i][j-1] += 1;
	    next.d[i-1][j-1] += 1;
	  }
	}
      }
    }
    tot = 0;
    for (i = 1; i <= 10; ++i) {
      for (j = 1; j <= 10; ++j) {
	if (flash.d[i][j]) {
	  next.d[i][j] = 0;
	  tot += 1;
	}
      }
    }
    if (tot == 100) break;
    grid = next;
  }
  [OFStdOut writeFormat:@"%d\n", k];
  [OFApplication terminate];
}
@end
