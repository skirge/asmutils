/*
    Based on code of J.T. Conklin <jtc@netbsd.org> and drepper@cygnus.com
    Public domain.
    Adapted for "C" and for asmutils by Nick Kurshev <nickols_k@mail.ru>.

    $Id: libm.c,v 1.1 2001/01/21 15:18:46 konst Exp $

 White C but not asm?
 1. Today gcc doesnot handle floating point as commercial compilers do.
    But I belive that in the future versions gcc will be able to handle
    floating point better.
 2. Such function declaraton allow us to be free from calling convention
    and build universal models.
*/
 
#include <stdint.h>
 
static const double one = 1.0;
	/* It is not important that this constant is precise.  It is only
	   a value which is known to be on the safe side for using the
	   fyl2xp1 instruction.  */
static const double limit = 0.29;

static const float two25 =  3.3554432000e+07; 
/* 0x4c000000 */
static const double two54 =  1.80143985094819840000e+16; 
/* 0x43500000, 0x00000000 */
static const long double two65 =  3.68934881474191032320e+19L;
/* 0x4040, 0x80000000, 0x00000000 */


/* acos = atan (sqrt(1 - x^2) / x) */

#define IEEE754_ACOS(ret,x)\
   asm("fld	%0\n"\
      "	fmul	%0\n"\
      "	fld1\n"\
      "	fsubp\n"\
      "	fsqrt\n"\
      "	fxch	%1\n"\
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

/* I added the following ugly construct because expl(+-Inf) resulted
   in NaN.  The ugliness results from the bright minds at Intel.
   For the i686 the code can be written better.
   -- drepper@cygnus.com.  */
#define __IEEE754_EXP(ret,x)\
  asm("fxam\n"\
      "	fstsw	%%ax\n"\
      "	movb	$0x45, %%dh\n"\
      "	andb	%%ah, %%dh\n"\
      "	cmpb	$0x05, %%dh\n"\
      "	je	1f\n"\
      "	fldl2e\n"\
      "	fmulp\n"\
      "	fld	%0\n"\
      "	frndint\n"\
      "	fsubr	%0,%2\n"\
      "	fxch\n"\
      "	f2xm1\n"\
      "	fld1\n"\
      "	faddp\n"\
      "	fscale\n"\
      "	fstp	%2\n"\
      "	jmp     2f\n"\
"1:	testl	$0x200, %%eax\n"\
      "	jz	2f\n"\
      "	fxch\n"\
"2:	fstp	%0\n":\
        "=t"(ret)  :\
        "0"(x),\
        "u"(0.):\
        "st(1)","eax","edx")

float expf(float x)
{
  register float ret;
  __IEEE754_EXP(ret,x);
  return ret;
}

double exp(double x)
{
  register double ret;
  __IEEE754_EXP(ret,x);
  return ret;
}

long double expl(long double x)
{
  register long double ret;
  __IEEE754_EXP(ret,x);
  return ret;
}

/* e^x = 2^(x * log2l(10)) */

/* I added the following ugly construct because expl(+-Inf) resulted
   in NaN.  The ugliness results from the bright minds at Intel.
   For the i686 the code can be written better.
   -- drepper@cygnus.com.  */
#define __IEEE754_EXP10(ret,x)\
  asm("fxam\n"\
      "	fstsw	%%ax\n"\
      "	movb	$0x45, %%dh\n"\
      "	andb	%%ah, %%dh\n"\
      "	cmpb	$0x05, %%dh\n"\
      "	je	1f\n"\
      "	fldl2t\n"\
      "	fmulp\n"\
      "	fld	%0\n"\
      "	frndint\n"\
      "	fsubr	%0,%2\n"\
      "	fxch\n"\
      "	f2xm1\n"\
      "	fld1\n"\
      "	faddp\n"\
      "	fscale\n"\
      "	fstp	%2\n"\
      "	jmp	2f\n"\
"1:	testl	$0x200, %%eax\n"\
      "	jz	2f\n"\
      "	fxch\n"\
"2:	fstp	%0" :\
      "=t"(ret)     :\
      "0"(x),\
      "u"(0.):\
      "st(1)","eax","edx")

float exp10f(float x)
{
  register float ret;
  __IEEE754_EXP10(ret,x);
  return ret;
}

double exp10(double x)
{
  register double ret;
  __IEEE754_EXP10(ret,x);
  return ret;
}

long double exp10l(long double x)
{
  register long double ret;
  __IEEE754_EXP10(ret,x);
  return ret;
}

#define IEEE754_FMOD(ret,x,y)\
  asm("\n1:	fprem\n"\
      "	fstsw	%%ax\n"\
      "	sahf\n"\
      "	jp  	1b\n"\
      "	fstp	%2":\
      "=t"(ret)    :\
      "0"(x),\
      "u"(y)       :\
      "st(1)","eax")

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
#define __IEEE754_HYPOT(retval,x,y)\
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
  __IEEE754_HYPOT(retval,x,y);
  return retval;
}

double hypot(double x,double y)
{
  register double retval;
  __IEEE754_HYPOT(retval,x,y);
  return retval;
}

long double hypotl(long double x,long double y)
{
  register long double retval;
  __IEEE754_HYPOT(retval,x,y);
  return retval;
}

/* 
   We pass address of contstants one and limit through registers
   for non relocatable system (-fpic -fPIC) 
*/

#define __IEEE754_LOG(ret,x)\
   asm("fldln2\n"\
      "	fxch\n"\
      "	fld	%0\n"\
      "	fsubl	(%2)\n"\
      "	fld	%0\n"\
      "	fcompl	(%3)\n"\
      "	fnstsw\n"\
      "	andb	$0x45, %%ah\n"\
      "	jz	1f\n"\
      "	fstp	%%st(1)\n"\
      "	fyl2xp1\n"\
      "	jmp	2f\n"\
"1:	fstp	%0\n"\
      "	fyl2x\n"\
"2:	fstp	%0":\
      "=t"(ret):\
      "0"(x),\
      "r"(&one),\
      "r"(&limit):\
      "eax")

float logf(float x)
{
  register float ret;
  __IEEE754_LOG(ret,x);
  return ret;    
}

double log(double x)
{
  register double ret;
  __IEEE754_LOG(ret,x);
  return ret;    
}

long double logl(long double x)
{
  register long double ret;
  __IEEE754_LOG(ret,x);
  return ret;    
}

#define __IEEE754_LOG10(ret,x)\
   asm("fldlg2\n"\
      "	fxch\n"\
      "	fld	%0\n"\
      "	fsubl	(%2)\n"\
      "	fld	%0\n"\
      "	fabs\n"\
      "	fcompl	(%3)\n"\
      "	fnstsw\n"\
      "	andb	$0x45, %%ah\n"\
      "	jz	1f\n"\
      "	fstp	%%st(1)\n"\
      "	fyl2xp1\n"\
      "	jmp	2f\n"\
"1:	fstp	%0\n"\
      "	fyl2x\n"\
"2:	fstp	%0\n":\
      "=t"(ret):\
      "0"(x),\
      "r"(&one),\
      "r"(&limit):\
      "eax")

float log10f(float x)
{
  register float ret;
  __IEEE754_LOG10(ret,x);
  return ret;
}

double log10(double x)
{
  register double ret;
  __IEEE754_LOG10(ret,x);
  return ret;
}

long double log10l(long double x)
{
  register long double ret;
  __IEEE754_LOG10(ret,x);
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
   asm("fstcw	%2\n"\
      "	movl	$0x800, %%edx\n"\
      "	orl	%2, %%edx\n"\
      "	andl	$0xfbff, %%edx\n"\
      "	movl	%%edx, %3\n"\
      "	fldcw	%3\n"\
      "	frndint\n"\
      "	fldcw	%2"\
      :"=t"(ret)\
      :"0"(val),\
      "m"(cw),\
      "m"(new_cw)\
      :"edx")

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
   asm("fldz":\
      "=t"(ret));\
   asm(name\
      "	fnstsw	%%ax\n"\
      "	testl	$0x400, %%eax\n"\
      "	je	2f\n"\
      "	fldpi\n"\
      "	fadd	%0\n"\
      "	fxch	%2\n"\
"1:	fprem1\n"\
      "	fnstsw	%%ax\n"\
      "	testl	$0x400, %%eax\n"\
      "	jne	1b\n"\
      "	fstp	%2\n"\
      "	"name\
"2:	fstp	%1"   :\
      "=t"(ret)       :\
      "0"(x),\
      "u"(ret):\
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

float tanf(float x)
{
  register float ret;
  __FTRIG("fptan\n",ret,x);
  return ret;
}

double tan(double x)
{
  register double ret;
  __FTRIG("fptan\n",ret,x);
  return ret;
}

long double tanl(long double x)
{
  register long double ret;
  __FTRIG("fptan\n",ret,x);
  return ret;
}

#define __IEEE754_EXP2(ret,x)\
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
  __IEEE754_EXP2(ret,x);
  return ret;
}

double exp2(double x)
{
  register double ret;
  __IEEE754_EXP2(ret,x);
  return ret;
}

long double exp2l(long double x)
{
  register long double ret;
  __IEEE754_EXP2(ret,x);
  return ret;
}

#define __FDIM(ret,x,y)\
   asm("fucom	%2\n"\
      "	fnstsw\n"\
      "	sahf\n"\
      "	jp	1f\n"\
      "	fsubrp	%0, %2\n"\
      "	jc	2f\n"\
      "	fstp	%0\n"\
      "	fldz\n"\
      "	jmp	2f\n"\
"1:	fxam\n"\
      "	fnstsw\n"\
      "	andb	$0x45, %%ah\n"\
      "	cmpb	$0x01, %%ah\n"\
      "	je	3f\n"\
      "	fxch\n"\
"3:	fstp	%2\n"\
"2:"   :\
       "=t"(ret):\
       "0"(y),\
       "u"(x):\
       "eax","st(1)")

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

int fiitel(long double val)
{
  const uint32_t *contents;
  register uint32_t retval;
  contents = (const uint32_t *)&val;
  retval = 0xFFFF8000L | contents[2];
  return (++retval) >> 31;    
}

#define __FLOOR(ret,val,cw,new_cw)\
   asm("fstcw	%2\n"\
      "	movl	$0x400, %%edx\n"\
      "	orl	%2, %%edx\n"\
      "	andl	$0xf7ff, %%edx\n"\
      "	movl	%%edx, %3\n"\
      "	fldcw	%3\n"\
      "	frndint\n"\
      "	fldcw	%2"\
      :"=t"(ret)\
      :"0"(val),\
      "m"(cw),\
      "m"(new_cw)\
      :"edx")

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

float frexpf(float x, int *eptr)
{
	register unsigned long hx,ix;
	hx = *(unsigned long *)&x;
	ix = 0x7fffffff&hx;
	*eptr = 0;
	if(!(ix>=0x7f800000||(ix==0)))	/* 0,inf,nan */
	{
	if (ix<0x00800000) {		/* subnormal */
	    x *= two25;
	    hx = *(unsigned long *)&x;
	    ix = hx&0x7fffffff;
	    *eptr = -25;
	}
	*eptr += (ix>>23)-126;
	hx = (hx&0x807fffff)|0x3f000000;
	*(unsigned long*)&x = hx;
        }
	return x;
}

double frexp(double x, int *eptr)
{
	register unsigned long hx, ix, lx;
        lx = ((unsigned long *)&x)[0];
        hx = ((unsigned long *)&x)[1];
	ix = 0x7fffffff&hx;
	*eptr = 0;
	if(!(ix>=0x7ff00000||((ix|lx)==0))) /* 0,inf,nan */
        {
	if (ix<0x00100000) {		/* subnormal */
	    x *= two54;
            hx = ((unsigned long *)&x)[1];
	    ix = hx&0x7fffffff;
	    *eptr = -54;
	}
	*eptr += (ix>>20)-1022;
	hx = (hx&0x800fffff)|0x3fe00000;
        ((unsigned long *)&x)[1] = hx;
        }
	return x;
}

long double frexpl(long double x, int *eptr)
{
	register unsigned long se, hx, ix, lx;
        lx = ((unsigned long *)&x)[0];
        hx = ((unsigned long *)&x)[1];
	se = ((unsigned long *)&x)[2];
	ix = 0x7fff&se;
	*eptr = 0;
	if(!(ix==0x7fff||((ix|hx|lx)==0)))/* 0,inf,nan */
        {
	if (ix==0x0000) {		/* subnormal */
	    x *= two65;
	    se = ((unsigned long *)&x)[2];
	    ix = se&0x7fff;
	    *eptr = -65;
	}
	*eptr += ix-16382;
	se = (se & 0x8000) | 0x3ffe;
	((unsigned long *)&x)[2] = se;
        }
	return x;
}

#define __ILOGB(ret,x)\
   asm("fxtract\n"\
      "	fstp	%1\n"\
      "	fistp	%0\n"\
      "	fwait" :\
      "=m"(ret):\
      "t"(x)   :\
      "st")

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

#define __LOG1P(retval,x,limit)\
   asm(\
      "fldln2\n"\
      "	fxch	%%st(1)\n"\
      "	fld	%0\n"\
      "	fabs\n"\
      "	fcomp%z2	%2\n"\
      "	fnstsw\n"\
      "	sahf\n"\
      "	jc	2f\n"\
      "	fld1\n"\
      "	faddp	%%st(1)\n"\
      "	fyl2x\n"\
      "	jmp	1f\n"\
"2:	fyl2xp1\n"\
"1:	fstp	%0":\
      "=t"(retval) :\
      "0"(x),\
      "m"(limit)   :\
      "eax")

float log1pf(float x)
{
  const float limit = 0.29;
  register float retval;
  __LOG1P(retval,x,limit);
  return retval;
}

double log1p(double x)
{
  const double limit = 0.29;
  register double retval;
  __LOG1P(retval,x,limit);
  return retval;
}

long double log1pl(long double x)
{
  const double limit = 0.29;
  register long double retval;
  __LOG1P(retval,x,limit);
  return retval;
}

#define __LOG2(retval,x,limit)\
   asm(\
      "fld	%0\n"\
      "	fsub	%%st(2), %0\n"\
      "	fld	%0\n"\
      "	fabs\n"\
      "	fcomp%z3	%3\n"\
      "	fnstsw\n"\
      "	andb	$0x45, %%ah\n"\
      "	jz	2f\n"\
      "	fstp	%1\n"\
      "	fyl2xp1\n"\
      "	jmp	1f\n"\
"2:	fstp	%0\n"\
      "	fyl2x\n"\
"1:	fstp	%0":\
      "=t"(retval):\
      "u"(1.),\
      "0"(x),\
      "m"(limit):\
      "eax","st(1)")

float log2f(float x)
{
  const float limit = 0.29;
  register float retval;
  __LOG2(retval,x,limit);
  return retval;
}

double log2(double x)
{
  const double limit = 0.29;
  register double retval;
  __LOG2(retval,x,limit);
  return retval;
}

long double log2l(long double x)
{
  const double limit = 0.29;
  register long double retval;
  __LOG2(retval,x,limit);
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

/* Adapted for use as nearbyint by Ulrich Drepper <drepper@cygnus.com>.  */
#define __NEARBYINT(retval,x,new_sw,org_sw)\
   asm(\
      "fnstcw	%2\n"\
      "	movl	%2, %%eax\n"\
      "	andl	$~0x20, %%eax\n"\
      "	movl	%%eax, %3\n"\
      "	fldcw	%3\n"\
      "	frndint\n"\
      "	fclex\n"\
      "	fldcw	%2":\
      "=t"(retval):\
      "0"(x),\
      "m"(new_sw),\
      "m"(org_sw):\
      "eax")

float nearbyintf(float x)
{
  register float retval;
  int new_sw,org_sw;
  __NEARBYINT(retval,x,new_sw,org_sw);
  return retval;
}

double nearbyint(double x)
{
  register double retval;
  int new_sw,org_sw;
  __NEARBYINT(retval,x,new_sw,org_sw);
  return retval;
}

long double nearbyintl(long double x)
{
  register long double retval;
  int new_sw,org_sw;
  __NEARBYINT(retval,x,new_sw,org_sw);
  return retval;
}

#define __REMQUO(retval,x,y,quo,xcontents,ycontents,i_const)\
   asm(".align 4\n"\
"1:\n"\
      "	fprem1\n"\
      "	fstsw	%%ax\n"\
      "	sahf\n"\
      "	jp	1b\n"\
      "	fstp	%1\n"\
      "	movl	%%eax, %%edx\n"\
      "	shrl	$8, %%eax\n"\
      "	shrl	$12, %%edx\n"\
      "	andl	$3, %%eax\n"\
      "	andl	$4, %%edx\n"\
      "	orl	%%eax, %%edx\n"\
      "	movl	$0xef2960, %%eax\n"\
      "	shrl	%%cl, %%eax\n"\
      "	andl	$3, %%eax\n"\
      "	movl	%4, %%edx\n"\
      "	xorl	%5, %%edx\n"\
      "	testl	%6, %%edx\n"\
      "	jz	2f\n"\
      "	negl	%%eax\n"\
"2:\n"\
      "	movl	%%eax, (%3)"\
      :"=t"(retval)\
      :"0"(x),\
       "u"(y),\
       "c"(quo),\
       "g"(xcontents),\
       "g"(ycontents),\
       "i"(i_const)\
      :"eax","edx","st(1)")

float remquof (float x, float y, int *quo)
{
  const uint32_t *xcontents;
  const uint32_t *ycontents;
  register float retval;
  xcontents = (const uint32_t *)&x;
  ycontents = (const uint32_t *)&y;
  __REMQUO(retval,x,y,quo,xcontents[0],ycontents[0],0x80000000L);
  return retval;
}

double remquo (double x, double y, int *quo)
{
  const uint32_t *xcontents;
  const uint32_t *ycontents;
  register double retval;
  xcontents = (const uint32_t *)&x;
  ycontents = (const uint32_t *)&y;
  __REMQUO(retval,x,y,quo,xcontents[1],ycontents[1],0x80000000L);
  return retval;
}

long double remquol (long double x, long double y, int *quo)
{
  const uint32_t *xcontents;
  const uint32_t *ycontents;
  register long double retval;
  xcontents = (const uint32_t *)&x;
  ycontents = (const uint32_t *)&y;
  __REMQUO(retval,x,y,quo,xcontents[2],ycontents[2],0x8000);
  return retval;
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
  asm ("fsincos\n"\
      "	fnstsw	%%ax\n"\
      "	testl	$0x400,%%eax\n"\
      "	jz	2f\n"\
      "	fldpi\n"\
      "	fadd	%0\n"\
      "	fxch	%1\n"\
      ".align 4\n"\
"1:	fprem1\n"\
      "	fnstsw	%%ax\n"\
      "	testl	$0x400,%%eax\n"\
      "	jnz	1b\n"\
      "	fstp	%1\n"\
      "	fstp	%0\n"\
      "	fsincos\n"\
"2:"                   :\
      "=t"(cosptr),\
      "=u"(sinptr)     :\
      "0"(x):\
      "st(1)","eax")

void sincosf(float x,float *sinptr,float *cosptr)
{
  __SINCOS(x,*cosptr,*sinptr);
}

void sincos(double x,double *sinptr,double *cosptr)
{
  __SINCOS(x,*cosptr,*sinptr);
}

void sincosl(long double x,long double *sinptr,long double *cosptr)
{
  __SINCOS(x,*cosptr,*sinptr);
}

#define __TRUNC(ret,x,orig_cw,mod_cw)\
   asm("fstcw %2\n"\
      "	fstcw %3\n"\
      "	orl   $0xC00, %3\n"\
      "	fldcw %3\n"\
      "	frndint\n"\
      "	fldcw %2"    :\
      "=t"(ret)      :\
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
