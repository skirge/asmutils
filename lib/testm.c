/*
    Copyright (C) 2001 Nick Kurshev <nickols_k@mail.ru>
    Based on libm-test.c testsuite from glibc-2.1.3

    $Id: testm.c,v 1.1 2001/03/18 07:08:25 konst Exp $
*/

#ifndef _GNU_SOURCE
# define _GNU_SOURCE
#endif

# define __NO_MATH_INLINES	1
# define __USE_ISOC9X 1
# define __USE_MISC 1
# define __USE_XOPEN_EXTENDED 1
# define __USE_GNU 1
# define __USE_BSD 1
# define __USE_XOPEN 1
# define __USE_SVID 1
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

typedef double MATHTYPE;
#define FUNC(name) name
/*
typedef MATHTYPE long double;
#define FUNC(name) name##l

typedef MATHTYPE float;
#define FUNC(name) name##f
*/

#define EPS 10e-10

#define MATH_ASSERT(name,expr,result)\
  printf("%s - %s computed: %10.15e should be: %10.15e\n",name,\
  (expr >= result-EPS && expr <= result+EPS) ? "ok" : "fail",(double)expr,(double)result)
#define INT_ASSERT(name,expr,result)\
  printf("%s - %s computed: %i should be: %i\n",name,\
  (expr == result) ? "ok" : "fail",(int)expr,(int)result)

int main ( void )
{
  MATHTYPE xtmp,ytmp;
  int	itmp;
  printf("*** It's test for new mathlib *** !!!\n\n");
  MATH_ASSERT("acos",acos(1.) , 0.);
  MATH_ASSERT("acos",acos(-1.) , M_PI);
  MATH_ASSERT("acos",acos(-0.5) , 2.*M_PI/3.);
  printf("\n");
  MATH_ASSERT("acosh",acosh(1.) , 0.);
  MATH_ASSERT("acosh",acosh(7.) , 2.6339157938496334172L);
  printf("\n");
  MATH_ASSERT("asin",asin(0.) , 0.);
  MATH_ASSERT("asin",asin(1.) , M_PI/2.);
  MATH_ASSERT("asin",asin(0.5) , M_PI/6.);
  printf("\n");
  MATH_ASSERT("asinh",asinh(0.) , 0.);
  MATH_ASSERT("asinh",asinh(0.7) , 0.652666566082355786L);
  printf("\n");
  MATH_ASSERT("atan",atan(0.) , 0.);
  MATH_ASSERT("atan",atan(1.) , M_PI/4);
  printf("\n");
  MATH_ASSERT("atanh",atanh(0.) , 0.);
  MATH_ASSERT("atanh",atanh(0.7) , 0.8673005276940531944L);
  printf("\n");
  MATH_ASSERT("atan2",atan2 (-0.,+0.) , -0.);
  MATH_ASSERT("atan2",atan2 (0.4,0.0003) , 1.5700463269355215718L);
  printf("\n");
  MATH_ASSERT("cbrt",cbrt (-0.) , -0.);
  MATH_ASSERT("cbrt",cbrt (-0.001) , -0.1);
  MATH_ASSERT("cbrt",cbrt (27.) , 3.);
  MATH_ASSERT("cbrt",cbrt (0.7) , 0.8879040017426007084L);
  MATH_ASSERT("cbrt",cbrt (-8.) , -2.);
  printf("\n");
  MATH_ASSERT("ceil",ceil (-0.) , -0.);
  MATH_ASSERT("ceil",ceil (M_PI) , 4.);
  MATH_ASSERT("ceil",ceil (-M_PI) , -3.);
  printf("\n");
  MATH_ASSERT("copysign",copysign (0., -4.) , -0.);
  MATH_ASSERT("copysign",copysign (0., 4.) , 0.);
  printf("\n");
  MATH_ASSERT("cos",cos (+0.) , 1.);
  MATH_ASSERT("cos",cos (M_PI/2.) , 0.);
  MATH_ASSERT("cos",cos (2.*M_PI/3.) , -0.5);
  printf("\n");
  MATH_ASSERT("cosh",cosh (0.) , 1.);
  MATH_ASSERT("cosh",cosh (0.7) , 1.255169005630943018L);
  printf("\n");
  MATH_ASSERT("exp",exp (0.) , 1.);
  MATH_ASSERT("exp",exp (1.) , M_E);
  MATH_ASSERT("exp",exp (0.7) , 2.0137527074704765216L);
  printf("\n");
  MATH_ASSERT("exp10",exp10 (0.) , 1.);
  MATH_ASSERT("exp10",exp10 (3.) , 1000.);
  MATH_ASSERT("exp10",exp10 (0.7) , 5.0118723362727228500L);
  printf("\n");
  MATH_ASSERT("exp2",exp2 (0.) , 1.);
  MATH_ASSERT("exp2",exp2 (10.) , 1024.);
  MATH_ASSERT("exp2",exp2 (0.7) , 1.6245047927124710452L);
  printf("\n");
  MATH_ASSERT("fabs",fabs(-0.) , 0.);
  MATH_ASSERT("fabs",fabs(-1.22) , 1.22);
  MATH_ASSERT("fabs",fabs(38.) , 38.);
  printf("\n");
  MATH_ASSERT("fdim",fdim (0., 0.) , 0.);
  MATH_ASSERT("fdim",fdim (9., 0.) , 9.);
  MATH_ASSERT("fdim",fdim (0., 9.) , 9.);
  MATH_ASSERT("fdim",fdim (-9., 0.) , 9.);
  MATH_ASSERT("fdim",fdim (0., -9.) , 9.);
  printf("\n");
/*  MATH_ASSERT("finite",);*/ /* may be later */
  MATH_ASSERT("floor",floor (-0.) , -0.);
  MATH_ASSERT("floor",floor (M_PI) , 3.);
  MATH_ASSERT("floor",floor (-M_PI) , -4.);
  printf("\n");
  MATH_ASSERT("fma",fma(1.0, 2.0, 3.0) , 5.0);
  printf("\n");
  MATH_ASSERT("fmax",fmax (0., 0.) , 0.);
  MATH_ASSERT("fmax",fmax (9., 0.) , 9.);
  MATH_ASSERT("fmax",fmax (0., -9.) , 0.);
  printf("\n");
  MATH_ASSERT("fmin",fmin (0., 0.) , 0.);
  MATH_ASSERT("fmin",fmin (9., 0.) , 0.);
  MATH_ASSERT("fmin",fmin (0., -9.) , -9.);
  printf("\n");
  MATH_ASSERT("fmod",fmod (6.5, 2.3) , 1.9);
  MATH_ASSERT("fmod",fmod (-6.5, 2.3) , -1.9);
  MATH_ASSERT("fmod",fmod (6.5, -2.3) , 1.9);
  MATH_ASSERT("fmod",fmod (-6.5, -2.3) , -1.9);
  printf("\n");
  MATH_ASSERT("frexp",frexp(-27.34, &itmp), -0.854375L);
  INT_ASSERT("frexp",itmp, 5);
  MATH_ASSERT("frexp",frexp(0., &itmp), 0.);
  INT_ASSERT("frexp",itmp, 0);
  MATH_ASSERT("frexp",frexp(12.8, &itmp), 0.8L);
  INT_ASSERT("frexp",itmp, 4);
  printf("\n");
  MATH_ASSERT("hypot",hypot(3., 4.) , 5.);
  MATH_ASSERT("hypot",hypot(0.7, 1.2) , 1.3892443989449804508L);
  printf("\n");
  MATH_ASSERT("ilogb",ilogb (1.) , 0.);
  MATH_ASSERT("ilogb",ilogb (M_E) , 1.);
  MATH_ASSERT("ilogb",ilogb (1024) , 10.);
  MATH_ASSERT("ilogb",ilogb (-2000.) , 10.);
  printf("\n");
/*  MATH_ASSERT("llrint",);*/ /* may be later */
  MATH_ASSERT("log",log (M_E) , 1.);
  MATH_ASSERT("log",log (1./M_E) , -1.);
  MATH_ASSERT("log",log (2.) , M_LN2);
  MATH_ASSERT("log",log (10.) , M_LN10);
  printf("\n");
  MATH_ASSERT("log10",log10 (0.1) , -1.);
  MATH_ASSERT("log10",log10 (10.) , 1.);
  MATH_ASSERT("log10",log10 (M_E) , M_LOG10E);
  MATH_ASSERT("log10",log10 (10000.) , 4.);
  printf("\n");
  MATH_ASSERT("log2",log2 (1.) , 0.);
  MATH_ASSERT("log2",log2 (M_E) , M_LOG2E);
  MATH_ASSERT("log2",log2 (2.) , 1.);
  MATH_ASSERT("log2",log2 (16.) , 4.);
  printf("\n");
  MATH_ASSERT("log1p",log1p (0.) , 0.);
  MATH_ASSERT("log1p",log1p (M_E - 1.0) , 1.);
  MATH_ASSERT("log1p",log1p (-0.3) , -0.35667494393873237891L);
  printf("\n");
  MATH_ASSERT("logb",logb (1.) , 0.);
  MATH_ASSERT("logb",logb (M_E) , 1.);
  MATH_ASSERT("logb",logb (1024.) , 10.);
  MATH_ASSERT("logb",logb (-2000.) , 10.);
  printf("\n");
  MATH_ASSERT("lrint",lrint(0.) , 0.);
  MATH_ASSERT("lrint",lrint(0.4) , 0.);
  MATH_ASSERT("lrint",lrint(1.4) , 1.);
  MATH_ASSERT("lrint",lrint(-1.4) , -1.);
  printf("\n");
  MATH_ASSERT("remainder",remainder(1.625, 1.0) , -0.375);
  MATH_ASSERT("remainder",remainder(-1.625, 1.0) , 0.375);
  MATH_ASSERT("remainder",remainder(1.625, -1.0) , -0.375);
  MATH_ASSERT("remainder",remainder(-1.625, -1.0) , 0.375);
  printf("\n");
  MATH_ASSERT("rint",rint(-0.) , -0.);
  printf("\n");
  MATH_ASSERT("pow",pow(0., 1.25) , 0.);
  MATH_ASSERT("pow",pow(3.16, 0.) , 1.);
  MATH_ASSERT("pow",pow(5., 3.) , 125.);
  MATH_ASSERT("pow",pow(36., 0.5) , 6.);
  MATH_ASSERT("pow",pow(10., 3.) , 1000.);
  MATH_ASSERT("pow",pow(2., 3.) , 8.);
  printf("\n");
  MATH_ASSERT("pow10",pow10(0.) , 1.);
  MATH_ASSERT("pow10",pow10(1.) , 10.);
  MATH_ASSERT("pow10",pow10(3.) , 1000.);
  printf("\n");
  MATH_ASSERT("scalbn",scalbn (0., 0.) , 0.);
  MATH_ASSERT("scalbn",scalbn (0.8, 4.) , 12.8);
  MATH_ASSERT("scalbn",scalbn (-0.854375L, 5.) , -27.34L);
  printf("\n");
/*  MATH_ASSERT("significand",);*/ /* may be later */
  MATH_ASSERT("sin",sin (-0.) , -0.);
  MATH_ASSERT("sin",sin (M_PI/2.) , 1.);
  MATH_ASSERT("sin",sin (-M_PI/2.) , -1.);
  MATH_ASSERT("sin",sin (0.7) , 0.64421768723769105367L);
  printf("\n");
  sincos(0.,&xtmp,&ytmp);
  MATH_ASSERT("sincos",xtmp, 0.);
  MATH_ASSERT("sincos",ytmp, 1.);
  sincos(M_PI/2.,&xtmp,&ytmp);
  MATH_ASSERT("sincos",xtmp, 1.);
  MATH_ASSERT("sincos",ytmp, 0.);
  sincos(0.7,&xtmp,&ytmp);
  MATH_ASSERT("sincos",xtmp, 0.64421768723769105367L);
  MATH_ASSERT("sincos",ytmp, 0.76484218728448842626L);
  printf("\n");
  MATH_ASSERT("sinh",sinh (0.) , 0.);
  MATH_ASSERT("sinh",sinh (0.7) , 0.75858370183953350346L);
  printf("\n");
  MATH_ASSERT("sqrt",sqrt(9.) , 3.);
  MATH_ASSERT("sqrt",sqrt(0.25) , 0.5);
  MATH_ASSERT("sqrt",sqrt(0.7) , 0.83666002653407554798L);
  printf("\n");
  MATH_ASSERT("tan",tan (-0.) , -0.);
  MATH_ASSERT("tan",tan (M_PI/4.) , 1.);
  MATH_ASSERT("tan",tan (0.7) , 0.84228838046307944813L);
  printf("\n");
  MATH_ASSERT("tanh",tanh (0.) , 0.);
  MATH_ASSERT("tanh",tanh (0.7) , 0.60436777711716349631L);
  printf("\n");
  MATH_ASSERT("trunc",trunc(0.) , 0.);
  MATH_ASSERT("trunc",trunc(0.625) , 0.);
  MATH_ASSERT("trunc",trunc(1048580.625L) , 1048580L);
  printf("\n");
  exit(0); /* no errors */
  return 0;
}
