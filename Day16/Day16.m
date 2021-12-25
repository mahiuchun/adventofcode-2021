#import <ObjFW/ObjFW.h>

int decode(char *bstr, long long *acc) {
  int V = 4 * bstr[0] + 2 * bstr[1] + bstr[2];
  // [OFStdErr writeFormat:@"V: %d\n", V];
  int T = 4 * bstr[3] + 2 * bstr[4] + bstr[5];
  // [OFStdErr writeFormat:@"T: %d\n", T];
  int read = 6, I, L, temp;
  int i;
  *acc += V;
  if (T == 4) {
    while (bstr[read]) {
      read += 5;
    }
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
	 read += temp;
	 L -= temp;
      }
    } else {
      for (i = 0; i < 11; ++i) L = L * 2 + bstr[read+i];
      read += 11;
      // [OFStdErr writeFormat:@"L: %d\n", L];
      for (i = 0; i < L; ++i) {
	read += decode(bstr+read, acc);
      }
    }
  }
  return read;
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
  decode(bstr, &acc);
  [OFStdOut writeFormat:@"%lld\n", acc];
  [OFApplication terminate];
}
@end
