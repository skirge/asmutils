/*
    Based on code of J.T. Conklin <jtc@netbsd.org> and drepper@cygnus.com
    Public domain.
    Adapted for "C" and for asmutils by Nick Kurshev <nickols_k@mail.ru>.
    I did an attemp to collect better parts from other free GPL'ed projects:
    - DJGPP for DOS <www.delorie.com>
    - EMX for OS2 by Eberhard Mattes

    $Id: libm.c,v 1.2 2001/02/23 12:39:29 konst Exp $

 White C but not asm?
 1. Today gcc doesnot handle floating point as comercial compilers do.
    But I belive that in the future versions gcc will be able to handle
    floating point better.
 2. Such function declaraton allow us to be free from calling convention
    and build universal models.
*/

/*
  Missed: drem(l,f), erf(l,f), erfc(l,f), expm1(l,f), fpclassify, gamma(l,f),
          infnan, isfinite, isgreater,  isgreaterequal, isinf(l,f), isless,
          islessequal,  islessgreater, isnan(l,f), isnormal, isunordered,
          j0(l,f),  j1(l,f), jn(l,f), ldexp(l,f), lgamma(l,f) lgamma(l,f)_r,
          llround(l,f), lround(l,f), mod(f,l), nan(l,f), nearbyint(l,f),
          nextafter(l,f),  nexttoward(l,f), round(l,f), scalb(l,f), signbit,
          tgamma(l,f), y0(l,f),  y1(l,f),  yn(l,f)
*/

typedef unsigned int uint32_t;

/* acos = atan (sqrt(1 - x^2) / x) */

#define IEEE754_ACOS(ret,x)\
   asm("fld	%0\n"\
      "	fmul	%0\n"\
      "	fld1\n"\
      "	fsubp\n"\
      "	fsqrt\n"\
      "	fxch	%%st(1)\n"\
      "	fpatan"   :\
      "=t"(ret)   :\
      "0"(x)      :\
      "st(1)")

float acosf(float x)
{
  register float ret;
  IEEE754_ACOS(ret,x);
  return ret;
}

double acos(double x)
{
  register double ret;
  IEEE754_ACOS(ret,x);
  return ret;
}

long double acosl(long double x)
{
  register long double ret;
  IEEE754_ACOS(ret,x);
  return ret;
}

/* asin = atan (x / sqrt(1 - x^2)) */

#define IEEE754_ASIN(ret,x)\
   asm("fld	%0\n"\
      "	fmul	%0\n"\
      "	fld1\n"\
      "	fsubp\n"\
      "	fsqrt\n"\
      "	fpatan"   :\
      "=t"(ret)   :\
      "0"(x)      :\
      "st(1)")

float asinf(float x)
{
  register float ret;
  IEEE754_ASIN(ret,x);
  return ret;
}

double asin(double x)
{
  register double ret;
  IEEE754_ASIN(ret,x);
  return ret;
}

long double asinl(long double x)
{
  register long double ret;
  IEEE754_ASIN(ret,x);
  return ret;
}

#define IEEE754_ATAN2(ret,y,x)\
   asm("fpatan" :\
       "=t"(ret):\
       "u"(y),\
       "0"(x)   :\
       "st(1)")

float atan2f(float y,float x)
{
  register float ret;
  IEEE754_ATAN2(ret,y,x);
  return ret;
}

double atan2(double y,double x)
{
  register double ret;
  IEEE754_ATAN2(ret,y,x);
  return ret;
}

long double atan2l(long double y,long double x)
{
  register long double ret;
  IEEE754_ATAN2(ret,y,x);
  return ret;
}

/* e^x = 2^(x * log2(e)) */
#define IEEE754_EXP(ret,x)\
  asm("fldl2e\n"\
      "	fxch	%%st(1)\n"\
      "	fmulp\n"\
      "	fst	%%st(1)\n"\
      "	frndint\n"\
      "	fst	%%st(2)\n"\
      "	fsubrp\n"\
      "	f2xm1\n"\
      "	fld1\n"\
      "	faddp\n"\
      "	fscale\n"\
      "	ffree	%%st(1)\n":\
        "=t"(ret):\
        "0"(x):\
        "st(2)")

float expf(float x)
{
  register float ret;
  IEEE754_EXP(ret,x);
  return ret;
}

double exp(double x)
{
  register double ret;
  IEEE754_EXP(ret,x);
  return ret;
}

long double expl(long double x)
{
  register long double ret;
  IEEE754_EXP(ret,x);
  return ret;
}

/* e^x = 2^(x * log2l(10)) */

#define IEEE754_EXP10(ret,x)\
  asm("fldl2t\n"\
      "	fxch	%%st(1)\n"\
      "	fmulp\n"\
      "	fst	%%st(1)\n"\
      "	frndint\n"\
      "	fst	%%st(2)\n"\
      "	fsubrp\n"\
      "	f2xm1\n"\
      "	fld1\n"\
      "	faddp\n"\
      "	fscale\n"\
      "	ffree	%%st(1)\n":\
        "=t"(ret):\
        "0"(x):\
        "st(2)")

float exp10f(float x)
{
  register float ret;
  IEEE754_EXP10(ret,x);
  return ret;
}

double exp10(double x)
{
  register double ret;
  IEEE754_EXP10(ret,x);
  return ret;
}

long double exp10l(long double x)
{
  register long double ret;
  IEEE754_EXP10(ret,x);
  return ret;
}

#define IEEE754_FMOD(ret,x,y)\
  asm("1:\n"\
      "	fprem\n"\
      "	fstsw	%%ax\n"\
      "	sahf\n"\
      "	jp  	1b\n":\
      "=t"(ret):\
      "u"(y),\
      "0"(x):\
      "eax","st")

float fmodf(float x,float y)
{
  register float ret;
  IEEE754_FMOD(ret,x,y);
  return ret;
}

double fmod(double x,double y)
{
  register double ret;
  IEEE754_FMOD(ret,x,y);
  return ret;
}

long double fmodl(long double x,long double y)
{
  long double ret;
  IEEE754_FMOD(ret,x,y);
  return ret;
}

/* We have to test whether any of the parameters is Inf.
   In this case the result is infinity. */
#define IEEE754_HYPOT(retval,x,y)\
   asm (\
      "fxam\n"\
      "	fnstsw\n"\
      "	movb	%%ah, %%ch\n"\
      "	fxch	%2\n"\
      "	fld	%0\n"\
      "	fstp	%0\n"\
      "	fxam\n"\
      "	fnstsw\n"\
      "	movb	%%ah, %%al\n"\
      "	orb	%%ch, %%ah\n"\
      "	sahf\n"\
      "	jc	1f\n"\
      "	fxch	%2\n"\
      "	fmul	%0\n"\
      "	fxch\n"\
      "	fmul	%0\n"\
      "	faddp\n"\
      "	fsqrt\n"\
      "	jmp	2f\n"\
"1:	andb	$0x45, %%al\n"\
      "	cmpb	$5, %%al\n"\
      "	je	3f\n"\
      "	andb	$0x45, %%ch\n"\
      "	cmpb	$5, %%ch\n"\
      "	jne	4f\n"\
      "	fxch\n"\
"3:	fstp	%2\n"\
      "	fabs\n"\
      "	jmp	2f\n"\
"4:	testb	$1, %%al\n"\
      "	jnz	5f\n"\
      "	fxch\n"\
"5:	fstp	%2\n"\
"2:":\
      "=t"(retval)   :\
      "0"(x),"u"(y)  :\
      "eax","ecx","st(1)")

float hypotf(float x,float y)
{
  register float retval;
  IEEE754_HYPOT(retval,x,y);
  return retval;
}

double hypot(double x,double y)
{
  register double retval;
  IEEE754_HYPOT(retval,x,y);
  return retval;
}

long double hypotl(long double x,long double y)
{
  register long double retval;
  IEEE754_HYPOT(retval,x,y);
  return retval;
}

/*
   We pass address of contstants one and limit through registers
   for non relocatable system (-fpic -fPIC)
*/

#define IEEE754_LOG(ret,x)\
   asm("fldln2\n"\
      "	fxch\n"\
      "	fyl2x":\
      "=t"(ret):\
      "0"(x))

float logf(float x)
{
  register float ret;
  IEEE754_LOG(ret,x);
  return ret;
}

double log(double x)
{
  register double ret;
  IEEE754_LOG(ret,x);
  return ret;
}

long double logl(long double x)
{
  register long double ret;
  IEEE754_LOG(ret,x);
  return ret;
}

#define IEEE754_LOG10(ret,x)\
   asm("fldlg2\n"\
      "	fxch\n"\
      "	fyl2x":\
      "=t"(ret):\
      "0"(x))

float log10f(float x)
{
  register float ret;
  IEEE754_LOG10(ret,x);
  return ret;
}

double log10(double x)
{
  register double ret;
  IEEE754_LOG10(ret,x);
  return ret;
}

long double log10l(long double x)
{
  register long double ret;
  IEEE754_LOG10(ret,x);
  return ret;
}

#define IEEE754_REMAINDER(ret,x,y)\
   asm("\n1:	fprem1\n"\
      "	fstsw	%%ax\n"\
      "	sahf\n"\
      "	jp	1b\n"\
      "	fstp	%2"  :\
      "=t"(ret)      :\
      "0"(x),\
      "u"(y):\
      "st(1)","eax")

float remainderf(float x,float y)
{
  register float ret;
  IEEE754_REMAINDER(ret,x,y);
  return ret;
}

double remainder(double x,double y)
{
  register double ret;
  IEEE754_REMAINDER(ret,x,y);
  return ret;
}

long double remainderl(long double x,long double y)
{
  register long double ret;
  IEEE754_REMAINDER(ret,x,y);
  return ret;
}

#define IEEE754_SQRT(ret,x)\
   asm("fsqrt"  :\
       "=t"(ret):\
       "0"(x))

float sqrtf(float x)
{
  register float ret;
  IEEE754_SQRT(ret,x);
  return ret;
}

double sqrt(double x)
{
  register double ret;
  IEEE754_SQRT(ret,x);
  return ret;
}

long double sqrtl(long double x)
{
  register long double ret;
  IEEE754_SQRT(ret,x);
  return ret;
}

#define __ATAN(ret,x)\
   asm("fld1\n"\
      "	fpatan":\
      "=t"(ret):\
      "0"(x))

float atanf(float x)
{
  register float ret;
  __ATAN(ret,x);
  return ret;
}

double atan(double x)
{
  register double ret;
  __ATAN(ret,x);
  return ret;
}

long double atanl(long double x)
{
  register long double ret;
  __ATAN(ret,x);
  return ret;
}

#define __CEIL(ret,val,cw,new_cw)\
   asm("fstcw	%0":"=m"(cw)::"memory");\
   new_cw = (cw | 0x800) & 0xfbff;\
   asm("fldcw	%3\n"\
      "	frndint\n"\
      "	fldcw	%2"\
      :"=t"(ret)\
      :"0"(val),\
      "m"(cw),\
      "m"(new_cw))

float ceilf(float val)
{
  unsigned int cw;
  unsigned int new_cw;
  register float ret;
  __CEIL(ret,val,cw,new_cw);
  return ret;
}

double ceil(double val)
{
  unsigned int cw;
  unsigned int new_cw;
  register double ret;
  __CEIL(ret,val,cw,new_cw);
  return ret;
}

long double ceill(long double val)
{
  unsigned int cw;
  unsigned int new_cw;
  register long double ret;
  __CEIL(ret,val,cw,new_cw);
  return ret;
}

float copysignf(float x,float y)
{
  return y > 0 ? x : -x;
}

double copysign(double x,double y)
{
  return y > 0 ? x : -x;
}

long double copysignl(long double x,long double y)
{
  return y > 0 ? x : -x;
}

#define __FTRIG(name,ret,x)\
   asm(name\
      "	fnstsw	%%ax\n"\
      "	testl	$0x400, %%eax\n"\
      "	je	2f\n"\
      "	fldpi\n"\
      "	fadd	%0\n"\
      "	fxch	%%st(1)\n"\
"1:	fprem1\n"\
      "	fnstsw	%%ax\n"\
      "	testl	$0x400, %%eax\n"\
      "	jne	1b\n"\
      "	fstp	%%st(1)\n"\
      "	"name\
"2:":\
      "=t"(ret)    :\
      "0"(x):\
      "st(1)","eax")

float cosf(float x)
{
  register float ret;
  __FTRIG("fcos\n",ret,x);
  return ret;
}

double cos(double x)
{
  register double ret;
  __FTRIG("fcos\n",ret,x);
  return ret;
}

long double cosl(long double x)
{
  register long double ret;
  __FTRIG("fcos\n",ret,x);
  return ret;
}

float sinf(float x)
{
  register float ret;
  __FTRIG("fsin\n",ret,x);
  return ret;
}

double sin(double x)
{
  register double ret;
  __FTRIG("fsin\n",ret,x);
  return ret;
}

long double sinl(long double x)
{
  register long double ret;
  __FTRIG("fsin\n",ret,x);
  return ret;
}

#define __FTAN(ret,x)\
   asm("fptan\n"\
      "	fnstsw	%%ax\n"\
      "	testl	$0x400, %%eax\n"\
      "	je	2f\n"\
      "	fldpi\n"\
      "	fadd	%0\n"\
      "	fxch	%%st(1)\n"\
"1:	fprem1\n"\
      "	fnstsw	%%ax\n"\
      "	testl	$0x400, %%eax\n"\
      "	jne	1b\n"\
      "	fstp	%%st(1)\n"\
      "	fptan\n"\
"2:	fstp	%0":\
      "=t"(ret)    :\
      "0"(x):\
      "st(1)","eax")

float tanf(float x)
{
  register float ret;
  __FTAN(ret,x);
  return ret;
}

double tan(double x)
{
  register double ret;
  __FTAN(ret,x);
  return ret;
}

long double tanl(long double x)
{
  register long double ret;
  __FTAN(ret,x);
  return ret;
}

#define IEEE754_EXP2(ret,x)\
   asm("fxam\n"\
      "	fstsw	%%ax\n"\
      "	movb	$0x45, %%dh\n"\
      "	andb	%%ah, %%dh\n"\
      "	cmpb	$0x05, %%dh\n"\
      "	je	1f\n"\
      "	fld	%0\n"\
      "	frndint\n"\
      "	fsubr	%0, %%st(1)\n"\
      "	fxch\n"\
      "	f2xm1\n"\
      "	fld1\n"\
      "	faddp\n"\
      "	fscale\n"\
      "	fstp	%%st(1)\n"\
      "	jmp	2f\n"\
"1:	testl	$0x200, %%eax\n"\
      "	jz	2f\n"\
      "	fstp	%0\n"\
      "	fldz\n"\
"2:":\
      "=t"(ret):\
      "0"(x):\
      "eax","edx")

float exp2f(float x)
{
  register float ret;
  IEEE754_EXP2(ret,x);
  return ret;
}

double exp2(double x)
{
  register double ret;
  IEEE754_EXP2(ret,x);
  return ret;
}

long double exp2l(long double x)
{
  register long double ret;
  IEEE754_EXP2(ret,x);
  return ret;
}

#define __FDIM(ret,x,y)\
   asm("fsubp	%2\n"\
      "	fabs":\
       "=t"(ret):\
       "0"(y),\
       "u"(x))

float fdimf(float x, float y)
{
  register float ret;
  __FDIM(ret,x,y);
  return ret;
}

double fdim(double x, double y)
{
  register double ret;
  __FDIM(ret,x,y);
  return ret;
}

long double fdiml(long double x, long double y)
{
  register long double ret;
  __FDIM(ret,x,y);
  return ret;
}

int finitef(float val)
{
  const uint32_t *contents;
  register uint32_t magic;
  contents = (const uint32_t *)&val;
  magic = 0xFF7FFFFFL;
  return ((magic-contents[0])^magic) >> 31;
}

int finite(double val)
{
  const uint32_t *contents;
  register uint32_t magic;
  contents = (const uint32_t *)&val;
  magic = 0xFFEFFFFFL;
  return ((magic-contents[1])^magic) >> 31;
}

int finitel(long double val)
{
  const uint32_t *contents;
  register uint32_t retval;
  contents = (const uint32_t *)&val;
  retval = 0xFFFF8000L | contents[2];
  return (++retval) >> 31;
}

#define __FLOOR(ret,val,cw,new_cw)\
   asm("fstcw	%0":"=m"(cw)::"memory");\
   new_cw = (cw | 0x400) & 0xf7ff;\
   asm("fldcw	%3\n"\
      "	frndint\n"\
      "	fldcw	%2"\
      :"=t"(ret)\
      :"0"(val),\
      "m"(cw),\
      "m"(new_cw))

float floorf(float val)
{
  unsigned int cw;
  unsigned int new_cw;
  register float ret;
  __FLOOR(ret,val,cw,new_cw);
  return ret;
}

double floor(double val)
{
  unsigned int cw;
  unsigned int new_cw;
  register double ret;
  __FLOOR(ret,val,cw,new_cw);
  return ret;
}

long double floorl(long double val)
{
  unsigned int cw;
  unsigned int new_cw;
  register long double ret;
  __FLOOR(ret,val,cw,new_cw);
  return ret;
}

#define __FMA(x,y,z) ((x*y)+z)

float fmaf(float x,float y,float z)
{
  return __FMA(x,y,z);
}

double fma(double x,double y,double z)
{
  return __FMA(x,y,z);
}

long double fmal(long double x,long double y,long double z)
{
  return __FMA(x,y,z);
}

#define __FMAX(ret,x,y)\
   asm("fxam\n"\
      "	fnstsw\n"\
      "	andb	$0x45, %%ah\n"\
      "	fxch	%2\n"\
      "	cmpb	$0x01, %%ah\n"\
      "	je	1f\n"\
      "	fucom	%2\n"\
      "	fnstsw\n"\
      "	sahf\n"\
      "	jnc	1f\n"\
      "	fxch	%2\n"\
"1:	fstp	%2":\
      "=t"(ret):\
      "0"(y),\
      "u"(x):\
      "eax","st(1)")

float fmaxf(float x, float y)
{
  register float ret;
  __FMAX(ret,x,y);
  return ret;
}

double fmax(double x, double y)
{
  register double ret;
  __FMAX(ret,x,y);
  return ret;
}

long double fmaxl(long double x, long double y)
{
  register long double ret;
  __FMAX(ret,x,y);
  return ret;
}

#define __FMIN(ret,x,y)\
   asm("fxam\n"\
      "	fnstsw\n"\
      "	andb	$0x45, %%ah\n"\
      "	cmpb	$0x01, %%ah\n"\
      "	je	1f\n"\
      "	fucom	%2\n"\
      "	fnstsw\n"\
      "	sahf\n"\
      "	jc	2f\n"\
"1:	fxch	%2\n"\
"2:	fstp	%2\n":\
       "=t"(ret):\
       "0"(y),\
       "u"(x):\
       "eax","st(1)")

float fminf(float x, float y)
{
  register float ret;
  __FMIN(ret,x,y);
  return ret;
}

double fmin(double x, double y)
{
  register double ret;
  __FMIN(ret,x,y);
  return ret;
}

long double fminl(long double x, long double y)
{
  register long double ret;
  __FMIN(ret,x,y);
  return ret;
}

/*
 frexp.s (emx+gcc) -- Copyright (c) 1992-1993 by Steffen Haecker
                      Modified 1993-1996 by Eberhard Mattes
*/

#define __FREXP(result,x,eptr)\
{\
  register long double minus_one;\
  asm("fld1\n"\
      "	fchs":\
      "=t"(minus_one));\
   *eptr = 0;\
   asm("ftst\n"\
      "	fstsw	%%ax\n"\
      "	andb	$0x41, %%ah\n"\
      "	xorb	$0x40, %%ah\n"\
      "	jz	1f\n"\
      "	fxtract\n"\
      "	fxch	%2\n"\
      "	fistpl	(%3)\n"\
      "	fscale\n"\
      "	incl	(%3)\n"\
"1:	fstp	%2":\
       "=t"(retval):\
       "0"(x),\
       "u"(minus_one),\
       "r"(eptr):\
       "eax","memory","st(1)");\
}
float frexpf(float x, int *eptr)
{
  register float retval;
  __FREXP(retval,x,eptr);
  return retval;
}

double frexp(double x, int *eptr)
{
  register double retval;
  __FREXP(retval,x,eptr);
  return retval;
}

long double frexpl(long double x, int *eptr)
{
  register long double retval;
  __FREXP(retval,x,eptr);
  return retval;
}

#define __ILOGB(ret,x)\
   asm("fxtract\n"\
      "	fstp	%1\n"\
      "	fistpl	%0\n"\
      "	fwait" :\
      "=m"(ret):\
      "t"(x))

int ilogbf(float x)
{
  int ret;
  __ILOGB(ret,x);
  return ret;
}

double ilogb(double x)
{
  int ret;
  __ILOGB(ret,x);
  return ret;
}

long double ilogbl(long double x)
{
  int ret;
  __ILOGB(ret,x);
  return ret;
}

#define __LLRINT(ret,x)\
   asm("fistpll	%0\n"\
      "	fwait" :\
      "=m"(ret):\
      "t"(x)   :\
      "st")

long long int llrintf(float x)
{
  long long int ret;
  __LLRINT(ret,x);
  return ret;
}

long long int llrint(double x)
{
  long long int ret;
  __LLRINT(ret,x);
  return ret;
}

long long int llrintl(long double x)
{
  long long int ret;
  __LLRINT(ret,x);
  return ret;
}

	/* The fyl2xp1 can only be used for values in
		-1 + sqrt(2) / 2 <= x <= 1 - sqrt(2) / 2
	   0.29 is a safe value.
	*/

/*
 * Use the fyl2xp1 function when the argument is in the range -0.29 to 0.29,
 * otherwise fyl2x with the needed extra computation.
 */

#define __LOG1P(retval,x)\
   asm("fldln2\n"\
      "	fxch\n"\
      "	fld1\n"\
      "	faddp %%st(1)\n"\
      "	fyl2x":\
      "=t"(retval):\
      "0"(x))

float log1pf(float x)
{
  register float retval;
  __LOG1P(retval,x);
  return retval;
}

double log1p(double x)
{
  register double retval;
  __LOG1P(retval,x);
  return retval;
}

long double log1pl(long double x)
{
  register long double retval;
  __LOG1P(retval,x);
  return retval;
}

#define __LOG2(retval,x)\
   asm("fld1\n"\
      "	fxch\n"\
      "	fyl2x":\
      "=t"(retval):\
      "0"(x))

float log2f(float x)
{
  register float retval;
  __LOG2(retval,x);
  return retval;
}

double log2(double x)
{
  register double retval;
  __LOG2(retval,x);
  return retval;
}

long double log2l(long double x)
{
  register long double retval;
  __LOG2(retval,x);
  return retval;
}

#define __ILOGBF(ret,x)\
   asm("fxtract\n"\
      "	fstp	%0":\
      "=t"(ret)    :\
      "0"(x)       :\
      "st(1)")

float logbf(float x)
{
  register float ret;
  __ILOGBF(ret,x);
  return ret;
}

double logb(double x)
{
  register double ret;
  __ILOGBF(ret,x);
  return ret;
}

long double logbl(long double x)
{
  register long double ret;
  __ILOGBF(ret,x);
  return ret;
}

#define __LRINT(ret,x)\
   asm("fistpl	%0\n"\
      "	fwait" :\
      "=m"(ret):\
      "t"(x)   :\
      "st")

long int lrintf(float x)
{
  long int ret;
  __LRINT(ret,x);
  return ret;
}

long int lrint(double x)
{
  long int ret;
  __LRINT(ret,x);
  return ret;
}

long int lrintl(long double x)
{
  long int ret;
  __LRINT(ret,x);
  return ret;
}

#define __RINT(ret,x)\
   asm("frndint":\
      "=t"(ret) :\
      "0"(x))

float rintf(float x)
{
  register float ret;
  __RINT(ret,x);
  return ret;
}

double rint(double x)
{
  register double ret;
  __RINT(ret,x);
  return ret;
}

long double rintl(long double x)
{
  register long double ret;
  __RINT(ret,x);
  return ret;
}

#define __SCALBN(ret,x,n)\
   asm("fscale"   :\
      "=t"(ret)   :\
      "0"(x),\
      "u"(n):\
      "st")

float scalbnf(float x,int n)
{
  register float ret;
  __SCALBN(ret,x,(float)n);
  return ret;
}

double scalbn(double x,int n)
{
  register double ret;
  __SCALBN(ret,x,(double)n);
  return ret;
}

long double scalbnl(long double x,int n)
{
  register long double ret;
  __SCALBN(ret,x,(long double)n);
  return ret;
}

#define __SIGNIFICAND(ret,x)\
   asm("fxtract\n"\
      "	fstp	%%st(1)":\
      "=t"(ret)    :\
      "0"(x))
float significandf(float x)
{
  float ret;
  __SIGNIFICAND(ret,x);
  return ret;
}

double significand(double x)
{
  double ret;
  __SIGNIFICAND(ret,x);
  return ret;
}

long double significandl(long double x)
{
  long double ret;
  __SIGNIFICAND(ret,x);
  return ret;
}

#define __SINCOS(x,cosptr,sinptr)\
{\
  register long double sv,cv;\
  asm("fsincos":"=t"(cv),"=u"(sv):"0"(x):"st","st(1)");\
  *cosptr = cv;\
  *sinptr = sv;\
}

void sincosf(float x,float *sinptr,float *cosptr)
{
  __SINCOS(x,cosptr,sinptr);
}

void sincos(double x,double *sinptr,double *cosptr)
{
  __SINCOS(x,cosptr,sinptr);
}

void sincosl(long double x,long double *sinptr,long double *cosptr)
{
  __SINCOS(x,cosptr,sinptr);
}

#define __TRUNC(ret,x,orig_cw,mod_cw)\
   asm("fstcw	%0":"=m"(orig_cw)::"memory");\
   mod_cw = orig_cw | 0xc00;\
   asm("fldcw	%3\n"\
      "	frndint\n"\
      "	fldcw	%2":\
      "=t"(ret)    :\
      "0"(x),\
      "m"(orig_cw),\
      "m"(mod_cw))

float truncf(float x)
{
  register float ret;
  int i1,i2;
  __TRUNC(ret,x,i1,i2);
  return ret;
}

double trunc(double x)
{
  register double ret;
  int i1,i2;
  __TRUNC(ret,x,i1,i2);
  return ret;
}

long double truncl(long double x)
{
  register long double ret;
  int i1,i2;
  __TRUNC(ret,x,i1,i2);
  return ret;
}

#define IEEE754_FABS(ret,x)\
   asm("fabs" :\
       "=t"(ret):\
       "0"(x))

float fabsf(float x)
{
  register float ret;
  IEEE754_FABS(ret,x);
  return ret;
}

double fabs(double x)
{
  register double ret;
  IEEE754_FABS(ret,x);
  return ret;
}

long double fabsl(long double x)
{
  register long double ret;
  IEEE754_FABS(ret,x);
  return ret;
}

static void frac(void)
{
  short cw1,cw2;
   asm("fnstcw	%0\n"
      "	fwait"
      :"=m"(cw1));
  cw2 = (cw1 & 0xf3ff) | 0x0400;
   asm("fldcw	%1\n"
      "	fld	%%st\n"
      "	frndint\n"
      "	fldcw	%0\n"
      "	fxch	%%st(1)\n"
      "	fsub	%%st(1), %%st"
      ::"m"(cw1),"m"(cw2):"memory");
}

static void Lpow2( void )
{
  double one;
   asm("fld1":"=t"(one)::"st(1)");
   asm("call	frac\n"
      "	f2xm1\n"
      "	faddl	%0\n"
      "	fscale\n"
      "	fstp	%%st(1)\n"
      :: "m"(one): "memory");
}

#define __POW10(retval, y)\
{\
  double one;\
   asm("fld1":"=t"(one)::"st(1)");\
   asm("fldl2t\n"\
      "	fmulp\n"\
      "	call	frac\n"\
      "	f2xm1\n"\
      "	faddl	%2\n"\
      "	fscale\n"\
      "	fstp	%%st(1)\n"\
      :"=t"(retval)\
      :"0"(y), "m"(one));\
}

#define __POW(retval,x,y)\
{\
  int yint;\
   asm("ftst\n"\
      "	fnstsw	%%ax\n"\
      "	sahf\n"\
      "	jbe	1f\n"\
      "	fyl2x\n"\
      "	call	Lpow2\n"\
      "	jmp	6f\n"\
"1:	jb	4f\n"\
      "	fstp	%0\n"\
      "	ftst\n"\
      "	fnstsw	%%ax\n"\
      "	sahf\n"\
      "	ja	3f\n"\
      "	jb	2f\n"\
      "	fstp	%0\n"\
      "	fld1\n"\
      "	fchs\n"\
"2:	fsqrt\n"\
      "	jmp     6f\n"\
"3:	fstp	%0\n"\
      "	fldz\n"\
      "	jmp	6f\n"\
"4:	fabs\n"\
      "	fxch	%2\n"\
      "	call	frac\n"\
      "	ftst\n"\
      "	fnstsw	%%ax\n"\
      "	fstp	%0\n"\
      "	sahf\n"\
      "	je	5f\n"\
      "	fstp	%0\n"\
      "	fchs\n"\
      "	jmp	2b\n"\
"5:	fistl	%3\n"\
      "	fxch	%2\n"\
      "	fyl2x\n"\
      "	call	Lpow2\n"\
      "	andl	$1, %3\n"\
      "	jz	6f\n"\
      "	fchs\n"\
"6:"\
      :"=t"(retval)\
      :"0"(x),"u"(y),"m"(yint)\
      :"eax","memory","st(1)");\
}

float powf(float x, float y)
{
  register float retval;
  if(x == (float)10.) __POW10(retval, y)
  else                __POW(retval,x,y)
  return retval;
}

double pow(double x, double y)
{
  register double retval;
  if(x == (double)10.) __POW10(retval, y)
  else                 __POW(retval,x,y)
  return retval;
}

long double powl(long double x, long double y)
{
  register long double retval;
  if(x == (long double)10.) __POW10(retval, y)
  else                      __POW(retval,x,y)
  return retval;
}

float pow10f(float y)
{
  register float retval;
  __POW10(retval, y)
  return retval;
}

double pow10(double y)
{
  register double retval;
  __POW10(retval, y)
  return retval;
}

long double pow10l(long double y)
{
  register long double retval;
  __POW10(retval, y)
  return retval;
}

/*
 cbrt.c (emx+gcc) -- Copyright (c) 1992-1995 by Eberhard Mattes
*/

float cbrtf (float x)
{
  if (x >= 0)
    return powf (x, 1.0 / 3.0);
  else
    return -powf (-x, 1.0 / 3.0);
}

double cbrt (double x)
{
  if (x >= 0)
    return pow (x, 1.0 / 3.0);
  else
    return -pow (-x, 1.0 / 3.0);
}

long double cbrtl (long double x)
{
  if (x >= 0)
    return powl (x, 1.0 / 3.0);
  else
    return -powl (-x, 1.0 / 3.0);
}

float acoshf(float x)
{
/* return log(x + sqrt(x*x - 1)); */
  float retval;
  IEEE754_SQRT(retval, x*x-1);
  IEEE754_LOG(retval,x + retval);
  return retval;
}

double acosh(double x)
{
/* return log(x + sqrt(x*x - 1)); */
  double retval;
  IEEE754_SQRT(retval, x*x-1);
  IEEE754_LOG(retval,x + retval);
  return retval;
}

long double acoshl(long double x)
{
/* return log(x + sqrt(x*x - 1)); */
  long double retval;
  IEEE754_SQRT(retval, x*x-1);
  IEEE754_LOG(retval,x + retval);
  return retval;
}

float asinhf(float x)
{
/* return x>0 ? log(x + sqrt(x*x + 1)) : -log(sqrt(x*x+1)-x); */
  float retval;
  IEEE754_SQRT(retval, x*x+1);
  if(x>0) IEEE754_LOG(retval,x + retval);
  else
  {
    IEEE754_LOG(retval,retval-x);
    retval = -retval;
  }
  return retval;
}

double asinh(double x)
{
/* return x>0 ? log(x + sqrt(x*x + 1)) : -log(sqrt(x*x+1)-x); */
  double retval;
  IEEE754_SQRT(retval, x*x+1);
  if(x>0) IEEE754_LOG(retval,x + retval);
  else
  {
    IEEE754_LOG(retval,retval-x);
    retval = -retval;
  }
  return retval;
}

long double asinhl(long double x)
{
/* return x>0 ? log(x + sqrt(x*x + 1)) : -log(sqrt(x*x+1)-x); */
  long double retval;
  IEEE754_SQRT(retval, x*x+1);
  if(x>0) IEEE754_LOG(retval,x + retval);
  else
  {
    IEEE754_LOG(retval,retval-x);
    retval = -retval;
  }
  return retval;
}

float atanhf(float x)
{
/*  return log((1+x)/(1-x)) / 2.0;*/
  float retval;
  IEEE754_LOG(retval,(1+x)/(1-x));
  return retval/2.;
}

double atanh(double x)
{
/*  return log((1+x)/(1-x)) / 2.0;*/
  double retval;
  IEEE754_LOG(retval,(1+x)/(1-x));
  return retval/2.;
}

long double atanhl(long double x)
{
/*  return log((1+x)/(1-x)) / 2.0;*/
  long double retval;
  IEEE754_LOG(retval,(1+x)/(1-x));
  return retval/2.;
}

float coshf(float x)
{
  float retval;
  IEEE754_FABS(retval, x);
  IEEE754_EXP(retval, retval);
  return (retval + 1.0/retval) / 2.0;
}

double cosh(double x)
{
  double retval;
  IEEE754_FABS(retval, x);
  IEEE754_EXP(retval, retval);
  return (retval + 1.0/retval) / 2.0;
}

long double coshl(long double x)
{
  long double retval;
  IEEE754_FABS(retval, x);
  IEEE754_EXP(retval, retval);
  return (retval + 1.0/retval) / 2.0;
}

float sinhf(float x)
{
 if(x >= 0.0)
 {
   float epos;
   IEEE754_EXP(epos, x);
   return (epos - 1.0/epos) / 2.0;
 }
 else
 {
   float eneg;
   IEEE754_EXP(eneg, -x);
   return (1.0/eneg - eneg) / 2.0;
 }
}

double sinh(double x)
{
 if(x >= 0.0)
 {
   double epos;
   IEEE754_EXP(epos, x);
   return (epos - 1.0/epos) / 2.0;
 }
 else
 {
   double eneg;
   IEEE754_EXP(eneg, -x);
   return (1.0/eneg - eneg) / 2.0;
 }
}

long double sinhl(long double x)
{
 if(x >= 0.0)
 {
   long double epos;
   IEEE754_EXP(epos, x);
   return (epos - 1.0/epos) / 2.0;
 }
 else
 {
   long double eneg;
   IEEE754_EXP(eneg, -x);
   return (1.0/eneg - eneg) / 2.0;
 }
}

float tanhf(float x)
{
  if (x > 50)
    return 1;
  else if (x < -50)
    return -1;
  else
  {
    float ebig;
    float esmall;
    IEEE754_EXP(ebig, x);
    esmall = 1./ebig;
    return (ebig - esmall) / (ebig + esmall);
  }
}

double tanh(double x)
{
  if (x > 50)
    return 1;
  else if (x < -50)
    return -1;
  else
  {
    double ebig;
    double esmall;
    IEEE754_EXP(ebig, x);
    esmall = 1./ebig;
    return (ebig - esmall) / (ebig + esmall);
  }
}

long double tanhl(long double x)
{
  if (x > 50)
    return 1;
  else if (x < -50)
    return -1;
  else
  {
    long double ebig;
    long double esmall;
    IEEE754_EXP(ebig, x);
    esmall = 1./ebig;
    return (ebig - esmall) / (ebig + esmall);
  }
}
