#import <ObjFW/ObjFW.h>

typedef struct _board {
  int nums[5][5];
  bool marked[5][5];
} Board;

static void mark(Board *b, int n) {
  int i, j;
  for (i = 0; i < 5; ++i) {
    for (j = 0; j < 5; ++j) {
      if (b->nums[i][j] == n) {
	b->marked[i][j] = true;
      }
    }
  }
}

static int wins(Board *b) {
  int i, j;
  int unmarked = 0;
  int r[5] = {0}, c[5] = {0};
  for (i = 0; i < 5; ++i) {
    for (j = 0; j < 5; ++j) {
      r[i] += b->marked[i][j];
      c[i] += b->marked[j][i];
    }
  }
  for (i = 0; i < 5; ++i) {
    if (r[i] == 5 || c[i] == 5) goto found;
  }
  return -1;
 found:
  for (i = 0; i < 5; ++i) {
    for (j = 0; j < 5; ++j) {
      if (!b->marked[i][j]) {
	unmarked += b->nums[i][j];
      }
    }
  }
  return unmarked;
}

@interface Day4: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day4)

@implementation Day4
- (void)applicationDidFinishLaunching
{
  OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
  OFString *s;
  OFMutableArray *boards = [OFMutableArray array];
  int i, j;
  Board b;
  // first line
  s = [f readLine];
  OFArray *draws = [s componentsSeparatedByString:@","];
  [OFStdErr writeFormat:@"# numbers to draw %d\n", draws.count];
  // boards
  s = [f readLine];
  while (s != nil) {
    if ([s length] == 0) {
      [boards addObject:[OFValue valueWithBytes:&b objCType:@encode(Board)]];
      i = 0;
    } else {
      OFArray* row = [s componentsSeparatedByString:@" " options:OFStringSkipEmptyComponents];
      for (j = 0; j < 5; ++j) {
	b.nums[i][j] = (int)[[row objectAtIndex:j] longLongValue];
	b.marked[i][j] = false;
      }
      i += 1;
    }
    s = [f readLine];
  }
  [boards addObject:[OFValue valueWithBytes:&b objCType:@encode(Board)]];
  [OFStdErr writeFormat:@"# boards: %d\n", boards.count];
  for (i = 0; i < draws.count; ++i) {
    long long n = [[draws objectAtIndex:i] longLongValue];
    for (j = 1; j < boards.count; ++j) {
      OFValue *value = [boards objectAtIndex:j];
      [value getValue:&b size:sizeof(Board)];
      mark(&b, n);
      int unmarked = wins(&b);
      if (unmarked >= 0) {
	[OFStdErr writeFormat:@"sum of unmarked: %d\n", unmarked];
	[OFStdErr writeFormat:@"Number just called: %lld\n", n];
	long long score = unmarked * n;
	[OFStdOut writeFormat:@"%lld\n", score];
	goto done;
      }
      [boards setObject:[OFValue valueWithBytes:&b objCType:@encode(Board)] atIndexedSubscript:j];
    }
  }
 done:
  [OFApplication terminate];
}
@end
