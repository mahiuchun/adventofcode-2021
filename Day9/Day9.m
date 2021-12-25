#import <ObjFW/ObjFW.h>

@interface Day9: OFObject <OFApplicationDelegate>

int field[200][200];

@end

OF_APPLICATION_DELEGATE(Day9)

@implementation Day9
- (void)applicationDidFinishLaunching
{
  OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
  OFString *s;
  int row = 0, col;
  int i, j;
  long long tot = 0;
  while ((s = [f readLine])) {
    col = [s length];
    row += 1;
    for (i = 1; i <= [s length]; i++) {
      field[row][i] = [s characterAtIndex:i-1] - '0';
    }
  }
  for (i = 0; i <= row + 1; i++) {
    field[i][0] = field[i][col+1] = 987654321;
  }
  for (i = 0; i <= col + 1; i++) {
    field[0][i] = field[row+1][i] = 987654321;
  }
  for (i = 1; i <= row; i++) {
    for (j = 1; j <= col; j++) {
      if (field[i][j] < field[i-1][j] &&
	  field[i][j] < field[i+1][j] &&
	  field[i][j] < field[i][j-1] &&
	  field[i][j] < field[i][j+1]) {
	tot += field[i][j] + 1;
      }
    }
  }
  [OFStdOut writeFormat:@"%lld\n", tot];
  [OFApplication terminate];
}
@end
