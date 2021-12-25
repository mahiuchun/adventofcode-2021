#import <ObjFW/ObjFW.h>

int field[200][200];
BOOL okay[200][200];

int basin_size_r(int i, int j) {
  int res = 1;
  if (!okay[i][j]) return 0;
  if (field[i][j] == 9) return 0;
  okay[i][j] = NO;
  if (field[i][j] < field[i-1][j])
    res += basin_size_r(i - 1, j);
  if (field[i][j] < field[i+1][j])
    res += basin_size_r(i + 1, j);
  if (field[i][j] < field[i][j-1])
    res += basin_size_r(i, j - 1);
  if (field[i][j] < field[i][j+1])
    res += basin_size_r(i, j + 1);
  return res;
}

int basin_size(int ii, int jj, int row, int col) {
  int i, j;
  for (i = 1; i <= row; i++) {
    for (j = 1; j <= col; j++) {
      okay[i][j] = YES;
    }
  }
  return basin_size_r(ii, jj);
}

@interface Day9: OFObject <OFApplicationDelegate>


@end

OF_APPLICATION_DELEGATE(Day9)

@implementation Day9
- (void)applicationDidFinishLaunching
{
  OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
  OFString *s;
  int row = 0, col, bs;
  int i, j;
  OFMutableArray *a = [OFMutableArray array];
  long long b1, b2, b3, ans;
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
	bs = basin_size(i, j, row, col);
	[a addObject:[OFNumber numberWithInt:bs]];
	// [OFStdErr writeFormat:@"bs:%d\n", bs];
      }
    }
  }
  [a sort];
  b1 = [[a objectAtIndex:a.count - 1] longLongValue];
  b2 = [[a objectAtIndex:a.count - 2] longLongValue];
  b3 = [[a objectAtIndex:a.count - 3] longLongValue];
  ans = b1 * b2 * b3;
  [OFStdOut writeFormat:@"%lld\n", ans];
  [OFApplication terminate];
}
@end
