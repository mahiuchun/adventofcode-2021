#import <ObjFW/ObjFW.h>

typedef struct res {
  long long value;
  int read;
} Res;

Res decode(char *bstr, long long *acc) {
  int V = 4 * bstr[0] + 2 * bstr[1] + bstr[2];
  // [OFStdErr writeFormat:@"V: %d\n", V];
  int T = 4 * bstr[3] + 2 * bstr[4] + bstr[5];
  // [OFStdErr writeFormat:@"T: %d\n", T];
  int read = 6, I, L;
  int i;
  Res res, temp;
  OFMutableArray *a = [OFMutableArray array];
  *acc += V;
  if (T == 4) {
    res.value = 0;
    while (bstr[read]) {
      res.value = 16*res.value+8*bstr[read+1]+4*bstr[read+2]+2*bstr[read+3]+bstr[read+4];
      read += 5;
    }
    res.value = 16*res.value+8*bstr[read+1]+4*bstr[read+2]+2*bstr[read+3]+bstr[read+4];
    read += 5;
  } else {
    I = bstr[read];
    read += 1;
    // [OFStdErr writeFormat:@"I: %d\n", I];
    L = 0;
    if (I == 0) {
      for (i = 0; i < 15; ++i) L = L * 2 + bstr[read+i];
      read += 15;
      // [OFStdErr writeFormat:@"L: %d\n", L];
      while (L > 0) {
	 temp = decode(bstr+read, acc);
	 read += temp.read;
	 L -= temp.read;
	 [a addObject:[OFNumber numberWithLongLong:temp.value]];
      }
    } else {
      for (i = 0; i < 11; ++i) L = L * 2 + bstr[read+i];
      read += 11;
      // [OFStdErr writeFormat:@"L: %d\n", L];
      for (i = 0; i < L; ++i) {
	temp = decode(bstr+read, acc);
	read += temp.read;
	[a addObject:[OFNumber numberWithLongLong:temp.value]];
      }
    }
    // eval
    switch (T) {
    case 0: {
      res.value = 0;
      for (i = 0; i < a.count; ++i) {
	res.value += [[a objectAtIndex:i] longLongValue];
      }
      break;
    }
    case 1: {
      res.value = 1;
      for (i = 0; i < a.count; ++i) {
	res.value *= [[a objectAtIndex:i] longLongValue];
      }
      break;
    }
    case 2: {
      res.value = LLONG_MAX;
      for (i = 0; i < a.count; ++i) {
	temp.value = [[a objectAtIndex:i] longLongValue];
	if (temp.value < res.value) res.value = temp.value;
      }
      break;
    }
    case 3: {
      res.value = LLONG_MIN;
      for (i = 0; i < a.count; ++i) {
	temp.value = [[a objectAtIndex:i] longLongValue];
	if (temp.value > res.value) res.value = temp.value;
      }
      break;
    }
    case 5: {
      if (a.count != 2) [OFStdErr writeFormat:@"Error when T=%d\n", T];
      res.value = [[a objectAtIndex:0] longLongValue] > [[a objectAtIndex:1] longLongValue];
      break;
    }
    case 6: {
      if (a.count != 2) [OFStdErr writeFormat:@"Error when T=%d\n", T];
      res.value = [[a objectAtIndex:0] longLongValue] < [[a objectAtIndex:1] longLongValue];
      break;
    }
    case 7: {
      if (a.count != 2) [OFStdErr writeFormat:@"Error when T=%d\n", T];
      res.value = [[a objectAtIndex:0] longLongValue] == [[a objectAtIndex:1] longLongValue];
      break;
    }
    }
  }
  res.read = read;
  return res;
}

@interface Day16: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day16)

@implementation Day16
- (void)applicationDidFinishLaunching
{
  char *h2b[128];
  char bstr[10000] = {0};
  OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
  OFString *s = [f readLine];
  int i, len;
  long long acc = 0;
  Res r;
  h2b['0'] = "0000";
  h2b['1'] = "0001";
  h2b['2'] = "0010";
  h2b['3'] = "0011";
  h2b['4'] = "0100";
  h2b['5'] = "0101";
  h2b['6'] = "0110";
  h2b['7'] = "0111";
  h2b['8'] = "1000";
  h2b['9'] = "1001";
  h2b['A'] = "1010";
  h2b['B'] = "1011";
  h2b['C'] = "1100";
  h2b['D'] = "1101";
  h2b['E'] = "1110";
  h2b['F'] = "1111";
  for (i = 0; i < [s length]; ++i) {
    strcat(bstr, h2b[[s characterAtIndex:i]]);
  }
  // [OFStdErr writeFormat:@"%s\n", bstr];
  len = strlen(bstr);
  for (i = 0; i < len; ++i) bstr[i] -= '0';
  r = decode(bstr, &acc);
  [OFStdOut writeFormat:@"%lld\n", r.value];
  [OFApplication terminate];
}
@end
