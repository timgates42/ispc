;;  Copyright (c) 2010-2019, Intel Corporation
;;  All rights reserved.
;;
;;  Redistribution and use in source and binary forms, with or without
;;  modification, are permitted provided that the following conditions are
;;  met:
;;
;;    * Redistributions of source code must retain the above copyright
;;      notice, this list of conditions and the following disclaimer.
;;
;;    * Redistributions in binary form must reproduce the above copyright
;;      notice, this list of conditions and the following disclaimer in the
;;      documentation and/or other materials provided with the distribution.
;;
;;    * Neither the name of Intel Corporation nor the names of its
;;      contributors may be used to endorse or promote products derived from
;;      this software without specific prior written permission.
;;
;;
;;   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
;;   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
;;   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
;;   PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
;;   OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;;   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;;   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;;   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;;   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;; This file provides a variety of macros used to generate LLVM bitcode
;; parametrized in various ways.  Implementations of the standard library
;; builtins for various targets can use macros from this file to simplify
;; generating code for their implementations of those builtins.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; It is a bit of a pain to compute this in m4 for 32 and 64-wide targets...
define(`ALL_ON_MASK',
`ifelse(WIDTH, `64', `-1',
        WIDTH, `32', `4294967295',
                     `eval((1<<WIDTH)-1)')')

define(`MASK_HIGH_BIT_ON',
`ifelse(WIDTH, `64', `-9223372036854775808',
        WIDTH, `32', `2147483648',
                     `eval(1<<(WIDTH-1))')')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; LLVM has different IR for different versions since 3.7

define(`PTR_OP_ARGS',
  ifelse(LLVM_VERSION, LLVM_3_7,
    ``$1 , $1 *'',
         LLVM_VERSION, LLVM_3_8,
    ``$1 , $1 *'',
         LLVM_VERSION, LLVM_3_9,
    ``$1 , $1 *'',
         LLVM_VERSION, LLVM_4_0,
    ``$1 , $1 *'',
         LLVM_VERSION, LLVM_5_0,
    ``$1 , $1 *'',
         LLVM_VERSION, LLVM_6_0,
    ``$1 , $1 *'',
         LLVM_VERSION, LLVM_7_0,
    ``$1 , $1 *'',
         LLVM_VERSION, LLVM_7_1,
    ``$1 , $1 *'',
         LLVM_VERSION, LLVM_8_0,
    ``$1 , $1 *'',
         LLVM_VERSION, LLVM_9_0,
    ``$1 , $1 *'',
    ``$1 *''
  )
)

;; x86 mask load/stores have different mask type since 3.8

define(`MdORi64',
  ifelse(LLVM_VERSION, LLVM_3_8,
    ``i64'',
    LLVM_VERSION, LLVM_3_9,
    ``i64'',
    LLVM_VERSION, LLVM_4_0,
    ``i64'',
    LLVM_VERSION, LLVM_5_0,
    ``i64'',
    LLVM_VERSION, LLVM_6_0,
    ``i64'',
    LLVM_VERSION, LLVM_7_0,
    ``i64'',
    LLVM_VERSION, LLVM_7_1,
    ``i64'',
    LLVM_VERSION, LLVM_8_0,
    ``i64'',
    LLVM_VERSION, LLVM_9_0,
    ``i64'',
    ``double''
  )
)

define(`MfORi32',
  ifelse(LLVM_VERSION, LLVM_3_8,
    ``i32'',
    LLVM_VERSION, LLVM_3_9,
    ``i32'',
    LLVM_VERSION, LLVM_4_0,
    ``i32'',
    LLVM_VERSION, LLVM_5_0,
    ``i32'',
    LLVM_VERSION, LLVM_6_0,
    ``i32'',
    LLVM_VERSION, LLVM_7_0,
    ``i32'',
    LLVM_VERSION, LLVM_7_1,
    ``i32'',
    LLVM_VERSION, LLVM_8_0,
    ``i32'',
    LLVM_VERSION, LLVM_9_0,
    ``i32'',
    ``float''
  )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; vector convertation utilities
;; convert vector of one width into vector of other width
;;
;; $1: vector element type
;; $2: vector of the first width
;; $3: vector of the second width


define(`convert1to8', `
  $3 = shufflevector <1 x $1> $2, <1 x $1> undef,
  <8 x i32> <i32 0, i32 undef, i32 undef, i32 undef,
             i32 undef, i32 undef, i32 undef, i32 undef>
')


define(`convert1to16', `
  $3 = shufflevector <1 x $1> $2, <1 x $1> undef,
  <16 x i32> <i32 0, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef>
')

define(`convert4to8', `
  $3 = shufflevector <4 x $1> $2, <4 x $1> undef,
  <8 x i32> <i32 0, i32 1, i32 2, i32 3,
             i32 undef, i32 undef, i32 undef, i32 undef>
')

define(`convert4to16', `
  $3 = shufflevector <4 x $1> $2, <4 x $1> undef,
  <16 x i32> <i32 0, i32 1, i32 2, i32 3,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef>
')

define(`convert8to16', `
  $3 = shufflevector <8 x $1> $2, <8 x $1> undef,
  <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef>
')

define(`convert4to32', `
  $3 = shufflevector <4 x $1> $2, <4 x $1> undef,
  <32 x i32> <i32 0, i32 1, i32 2, i32 3,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef>
')

define(`convert8to32', `
  $3 = shufflevector <4 x $1> $2, <4 x $1> undef,
  <32 x i32> <i32 0, i32 1, i32 2, i32 3,
              i32 4, i32 5, i32 6, i32 7,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef>
')

define(`convert16to32', `
  $3 = shufflevector <4 x $1> $2, <4 x $1> undef,
  <32 x i32> <i32  0, i32 1,  i32  2, i32  3,
              i32  4, i32 5,  i32  6, i32  7,
              i32  8, i32 9,  i32 10, i32 11,
              i32 12, i32 13, i32 14, i32 15
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef,
              i32 undef, i32 undef, i32 undef, i32 undef>
')

define(`convert8to1', `
  $3 = shufflevector <8 x $1> $2, <8 x $1> undef,
    <1 x i32> <i32 0>
')


define(`convert16to1', `
  $3 = shufflevector <16 x $1> $2, <16 x $1> undef,
    <1 x i32> <i32 0>
')

define(`convert8to4', `
  $3 = shufflevector <8 x $1> $2, <8 x $1> undef,
    <4 x i32> <i32 0, i32 1, i32 2, i32 3>
')


define(`convert16to4', `
  $3 = shufflevector <16 x $1> $2, <16 x $1> undef,
    <4 x i32> <i32 0, i32 1, i32 2, i32 3>
')

define(`convert16to8', `
  $3 = shufflevector <16 x $1> $2, <16 x $1> undef,
  <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
')

define(`convert32to4', `
  $3 = shufflevector <32 x $1> $2, <32 x $1> undef,
    <4 x i32> <i32 0, i32 1, i32 2, i32 3>
')

define(`convert32to8', `
  $3 = shufflevector <32 x $1> $2, <32 x $1> undef,
    <8 x i32> <i32 0, i32 1, i32 2, i32 3>
')

define(`convert32to16', `
  $3 = shufflevector <32 x $1> $2, <32 x $1> undef,
    <16 x i32> <i32 0, i32 1, i32 2, i32 3>
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;saturation arithmetic

define(`saturation_arithmetic',
`ifelse(WIDTH,  `4', `saturation_arithmetic_vec4()',
        WIDTH,  `8', `saturation_arithmetic_vec8()',
        WIDTH, `16', `saturation_arithmetic_vec16() ',
                     `errprint(`ERROR: saturation_arithmetic() macro called with unsupported width = 'WIDTH
)
                      m4exit(`1')')
')

;; create vector constant. Used by saturation_arithmetic_novec_universal below.

define(`const_vector', `
ifelse(WIDTH,  `4', `<$1 $2, $1 $2, $1 $2, $1 $2>',
       WIDTH,  `8', `<$1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2>',
       WIDTH, `16', `<$1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2,
                      $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2>',
       WIDTH, `32', `<$1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2,
                      $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2,
                      $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2,
                      $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2>',
       WIDTH, `64', `<$1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2,
                       $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2,
                       $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2,
                       $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2,
                       $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2,
                       $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2,
                       $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2,
                       $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2, $1 $2>',
                        `<$1 $2>')')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Saturarion arithmetic, supported in visa

define(`saturation_arithmetic_op', `
declare <WIDTH x $1> @llvm.genx.ss$2.sat.$1(<WIDTH x $1>, <WIDTH x $1>)  nounwind readnone

define <WIDTH x $1> @__saturating_$2_$1(<WIDTH x $1> %a, <WIDTH x $1> %b) nounwind alwaysinline {
  %res = call <WIDTH x $1> @llvm.genx.ss$2.sat.$1(<WIDTH x $1> %a, <WIDTH x $1> %b)
  ret <WIDTH x $1> %res
}

declare <WIDTH x $1> @llvm.genx.uu$2.sat.$1(<WIDTH x $1>, <WIDTH x $1>)  nounwind readnone

define <WIDTH x $1> @__saturating_$2_u$1(<WIDTH x $1> %a, <WIDTH x $1> %b) nounwind alwaysinline {
  %res = call <WIDTH x $1> @llvm.genx.uu$2.sat.$1(<WIDTH x $1> %a, <WIDTH x $1> %b)
  ret <WIDTH x $1> %res
}
')

saturation_arithmetic_op(i8, add)
saturation_arithmetic_op(i16, add)
saturation_arithmetic_op(i32, add)
saturation_arithmetic_op(i64, add)
saturation_arithmetic_op(i8, mul)
saturation_arithmetic_op(i16, mul)
saturation_arithmetic_op(i32, mul)

;; utility function used by saturation_arithmetic_novec below.  This shouldn't be called by
;; target .ll files directly.
;; $1: {add,sub} (used in constructing function names)

define(`saturation_arithmetic_novec_universal', `
define <WIDTH x i8> @__p$1s_vi8(<WIDTH x i8>, <WIDTH x i8>) {
  %v0_i16 = sext <WIDTH x i8> %0 to <WIDTH x i16>
  %v1_i16 = sext <WIDTH x i8> %1 to <WIDTH x i16>
  %res = $1 <WIDTH x i16> %v0_i16, %v1_i16
  %over_mask = icmp sgt <WIDTH x i16> %res, const_vector(i16, 127)
  %over_res = select <WIDTH x i1> %over_mask, <WIDTH x i16> const_vector(i16, 127), <WIDTH x i16> %res
  %under_mask = icmp slt <WIDTH x i16> %res, const_vector(i16, -128)
  %ret_i16 = select <WIDTH x i1> %under_mask, <WIDTH x i16> const_vector(i16, -128), <WIDTH x i16> %over_res
  %ret = trunc <WIDTH x i16> %ret_i16 to <WIDTH x i8>
  ret <WIDTH x i8> %ret
}

define <WIDTH x i16> @__p$1s_vi16(<WIDTH x i16>, <WIDTH x i16>) {
  %v0_i32 = sext <WIDTH x i16> %0 to <WIDTH x i32>
  %v1_i32 = sext <WIDTH x i16> %1 to <WIDTH x i32>
  %res = $1 <WIDTH x i32> %v0_i32, %v1_i32
  %over_mask = icmp sgt <WIDTH x i32> %res, const_vector(i32, 32767)
  %over_res = select <WIDTH x i1> %over_mask, <WIDTH x i32> const_vector(i32, 32767), <WIDTH x i32> %res
  %under_mask = icmp slt <WIDTH x i32> %res, const_vector(i32, -32768)
  %ret_i32 = select <WIDTH x i1> %under_mask, <WIDTH x i32> const_vector(i32, -32768), <WIDTH x i32> %over_res
  %ret = trunc <WIDTH x i32> %ret_i32 to <WIDTH x i16>
  ret <WIDTH x i16> %ret
}

define <WIDTH x i8> @__p$1us_vi8(<WIDTH x i8>, <WIDTH x i8>) {
  %v0_i16 = zext <WIDTH x i8> %0 to <WIDTH x i16>
  %v1_i16 = zext <WIDTH x i8> %1 to <WIDTH x i16>
  %res = $1 <WIDTH x i16> %v0_i16, %v1_i16
  %over_mask = icmp ugt <WIDTH x i16> %res, const_vector(i16, 255)
  %over_res = select <WIDTH x i1> %over_mask, <WIDTH x i16> const_vector(i16, 255), <WIDTH x i16> %res
  %under_mask = icmp slt <WIDTH x i16> %res, const_vector(i16, 0)
  %ret_i16 = select <WIDTH x i1> %under_mask, <WIDTH x i16> const_vector(i16, 0), <WIDTH x i16> %over_res
  %ret = trunc <WIDTH x i16> %ret_i16 to <WIDTH x i8>
  ret <WIDTH x i8> %ret
}

define <WIDTH x i16> @__p$1us_vi16(<WIDTH x i16>, <WIDTH x i16>) {
  %v0_i32 = zext <WIDTH x i16> %0 to <WIDTH x i32>
  %v1_i32 = zext <WIDTH x i16> %1 to <WIDTH x i32>
  %res = $1 <WIDTH x i32> %v0_i32, %v1_i32
  %over_mask = icmp ugt <WIDTH x i32> %res, const_vector(i32, 65535)
  %over_res = select <WIDTH x i1> %over_mask, <WIDTH x i32> const_vector(i32, 65535), <WIDTH x i32> %res
  %under_mask = icmp slt <WIDTH x i32> %res, const_vector(i32, 0)
  %ret_i32 = select <WIDTH x i1> %under_mask, <WIDTH x i32> const_vector(i32, 0), <WIDTH x i32> %over_res
  %ret = trunc <WIDTH x i32> %ret_i32 to <WIDTH x i16>
  ret <WIDTH x i16> %ret
}
')

;; implementation for targets which doesn't have h/w instructions

define(`saturation_arithmetic_novec', `
saturation_arithmetic_novec_universal(sub)
saturation_arithmetic_novec_universal(add)
')

;;4-wide vector saturation arithmetic

define(`saturation_arithmetic_vec4', `
declare <16 x i8> @llvm.x86.sse2.padds.b(<16 x i8>, <16 x i8>) nounwind readnone
define <4 x i8> @__padds_vi8(<4 x i8>, <4 x i8>) {
  convert4to16(i8, %0, %v0)
  convert4to16(i8, %1, %v1)
  %r16 = call <16 x i8> @llvm.x86.sse2.padds.b(<16 x i8> %v0, <16 x i8> %v1)
  convert16to4(i8, %r16, %r)
  ret <4 x i8> %r
}

declare <8 x i16> @llvm.x86.sse2.padds.w(<8 x i16>, <8 x i16>) nounwind readnone
define <4 x i16> @__padds_vi16(<4 x i16>, <4 x i16>) {
  convert4to8(i16, %0, %v0)
  convert4to8(i16, %1, %v1)
  %r16 = call <8 x i16> @llvm.x86.sse2.padds.w(<8 x i16> %v0, <8 x i16> %v1)
  convert8to4(i16, %r16, %r)
  ret <4 x i16> %r
}

declare <16 x i8> @llvm.x86.sse2.paddus.b(<16 x i8>, <16 x i8>) nounwind readnone
define <4 x i8> @__paddus_vi8(<4 x i8>, <4 x i8>) {
  convert4to16(i8, %0, %v0)
  convert4to16(i8, %1, %v1)
  %r16 = call <16 x i8> @llvm.x86.sse2.paddus.b(<16 x i8> %v0, <16 x i8> %v1)
  convert16to4(i8, %r16, %r)
  ret <4 x i8> %r
}

declare <8 x i16> @llvm.x86.sse2.paddus.w(<8 x i16>, <8 x i16>) nounwind readnone
define <4 x i16> @__paddus_vi16(<4 x i16>, <4 x i16>) {
  convert4to8(i16, %0, %v0)
  convert4to8(i16, %1, %v1)
  %r16 = call <8 x i16> @llvm.x86.sse2.paddus.w(<8 x i16> %v0, <8 x i16> %v1)
  convert8to4(i16, %r16, %r)
  ret <4 x i16> %r
}

declare <16 x i8> @llvm.x86.sse2.psubs.b(<16 x i8>, <16 x i8>) nounwind readnone
define <4 x i8> @__psubs_vi8(<4 x i8>, <4 x i8>) {
  convert4to16(i8, %0, %v0)
  convert4to16(i8, %1, %v1)
  %r16 = call <16 x i8> @llvm.x86.sse2.psubs.b(<16 x i8> %v0, <16 x i8> %v1)
  convert16to4(i8, %r16, %r)
  ret <4 x i8> %r
}

declare <8 x i16> @llvm.x86.sse2.psubs.w(<8 x i16>, <8 x i16>) nounwind readnone
define <4 x i16> @__psubs_vi16(<4 x i16>, <4 x i16>) {
  convert4to8(i16, %0, %v0)
  convert4to8(i16, %1, %v1)
  %r16 = call <8 x i16> @llvm.x86.sse2.psubs.w(<8 x i16> %v0, <8 x i16> %v1)
  convert8to4(i16, %r16, %r)
  ret <4 x i16> %r
}

declare <16 x i8> @llvm.x86.sse2.psubus.b(<16 x i8>, <16 x i8>) nounwind readnone
define <4 x i8> @__psubus_vi8(<4 x i8>, <4 x i8>) {
  convert4to16(i8, %0, %v0)
  convert4to16(i8, %1, %v1)
  %r16 = call <16 x i8> @llvm.x86.sse2.psubus.b(<16 x i8> %v0, <16 x i8> %v1)
  convert16to4(i8, %r16, %r)
  ret <4 x i8> %r
}

declare <8 x i16> @llvm.x86.sse2.psubus.w(<8 x i16>, <8 x i16>) nounwind readnone
define <4 x i16> @__psubus_vi16(<4 x i16>, <4 x i16>) {
  convert4to8(i16, %0, %v0)
  convert4to8(i16, %1, %v1)
  %r16 = call <8 x i16> @llvm.x86.sse2.psubus.w(<8 x i16> %v0, <8 x i16> %v1)
  convert8to4(i16, %r16, %r)
  ret <4 x i16> %r
}
')

;;8-wide vector saturation arithmetic

define(`saturation_arithmetic_vec8', `
declare <16 x i8> @llvm.x86.sse2.padds.b(<16 x i8>, <16 x i8>) nounwind readnone
define <8 x i8> @__padds_vi8(<8 x i8>, <8 x i8>) {
  convert8to16(i8, %0, %v0)
  convert8to16(i8, %1, %v1)
  %r16 = call <16 x i8> @llvm.x86.sse2.padds.b(<16 x i8> %v0, <16 x i8> %v1)
  convert16to8(i8, %r16, %r)
  ret <8 x i8> %r
}

declare <8 x i16> @llvm.x86.sse2.padds.w(<8 x i16>, <8 x i16>) nounwind readnone
define <8 x i16> @__padds_vi16(<8 x i16> %a0, <8 x i16> %a1) {
  %res = call <8 x i16> @llvm.x86.sse2.padds.w(<8 x i16> %a0, <8 x i16> %a1)
  ret <8 x i16> %res
}

declare <16 x i8> @llvm.x86.sse2.paddus.b(<16 x i8>, <16 x i8>) nounwind readnone
define <8 x i8> @__paddus_vi8(<8 x i8>, <8 x i8>) {
  convert8to16(i8, %0, %v0)
  convert8to16(i8, %1, %v1)
  %r16 = call <16 x i8> @llvm.x86.sse2.paddus.b(<16 x i8> %v0, <16 x i8> %v1)
  convert16to8(i8, %r16, %r)
  ret <8 x i8> %r
}

declare <8 x i16> @llvm.x86.sse2.paddus.w(<8 x i16>, <8 x i16>) nounwind readnone
define <8 x i16> @__paddus_vi16(<8 x i16> %a0, <8 x i16> %a1) {
  %res = call <8 x i16> @llvm.x86.sse2.paddus.w(<8 x i16> %a0, <8 x i16> %a1)
  ret <8 x i16> %res
}

declare <16 x i8> @llvm.x86.sse2.psubs.b(<16 x i8>, <16 x i8>) nounwind readnone
define <8 x i8> @__psubs_vi8(<8 x i8>, <8 x i8>) {
  convert8to16(i8, %0, %v0)
  convert8to16(i8, %1, %v1)
  %r16 = call <16 x i8> @llvm.x86.sse2.psubs.b(<16 x i8> %v0, <16 x i8> %v1)
  convert16to8(i8, %r16, %r)
  ret <8 x i8> %r
}

declare <8 x i16> @llvm.x86.sse2.psubs.w(<8 x i16>, <8 x i16>) nounwind readnone
define <8 x i16> @__psubs_vi16(<8 x i16> %a0, <8 x i16> %a1) {
  %res = call <8 x i16> @llvm.x86.sse2.psubs.w(<8 x i16> %a0, <8 x i16> %a1)
  ret <8 x i16> %res
}

declare <16 x i8> @llvm.x86.sse2.psubus.b(<16 x i8>, <16 x i8>) nounwind readnone
define <8 x i8> @__psubus_vi8(<8 x i8>, <8 x i8>) {
  convert8to16(i8, %0, %v0)
  convert8to16(i8, %1, %v1)
  %r16 = call <16 x i8> @llvm.x86.sse2.psubus.b(<16 x i8> %v0, <16 x i8> %v1)
  convert16to8(i8, %r16, %r)
  ret <8 x i8> %r
}

declare <8 x i16> @llvm.x86.sse2.psubus.w(<8 x i16>, <8 x i16>) nounwind readnone
define <8 x i16> @__psubus_vi16(<8 x i16> %a0, <8 x i16> %a1) {
  %res = call <8 x i16> @llvm.x86.sse2.psubus.w(<8 x i16> %a0, <8 x i16> %a1)
  ret <8 x i16> %res
}
')

;;16-wide vector saturation arithmetic

define(`saturation_arithmetic_vec16', `
declare <16 x i8> @llvm.x86.sse2.padds.b(<16 x i8>, <16 x i8>) nounwind readnone
define <16 x i8> @__padds_vi8(<16 x i8> %a0, <16 x i8> %a1) {
  %res = call <16 x i8> @llvm.x86.sse2.padds.b(<16 x i8> %a0, <16 x i8> %a1) ; <<16 x i8>> [#uses=1]
  ret <16 x i8> %res
}

declare <8 x i16> @llvm.x86.sse2.padds.w(<8 x i16>, <8 x i16>) nounwind readnone
define <16 x i16> @__padds_vi16(<16 x i16> %a0, <16 x i16> %a1) {
  binary8to16(ret, i16, @llvm.x86.sse2.padds.w, %a0, %a1)
  ret <16 x i16> %ret
}

declare <16 x i8> @llvm.x86.sse2.paddus.b(<16 x i8>, <16 x i8>) nounwind readnone
define <16 x i8> @__paddus_vi8(<16 x i8> %a0, <16 x i8> %a1) {
  %res = call <16 x i8> @llvm.x86.sse2.paddus.b(<16 x i8> %a0, <16 x i8> %a1) ; <<16 x i8>> [#uses=1]
  ret <16 x i8> %res
}

declare <8 x i16> @llvm.x86.sse2.paddus.w(<8 x i16>, <8 x i16>) nounwind readnone
define <16 x i16> @__paddus_vi16(<16 x i16> %a0, <16 x i16> %a1) {
  binary8to16(ret, i16, @llvm.x86.sse2.paddus.w, %a0, %a1)
  ret <16 x i16> %ret
}

declare <16 x i8> @llvm.x86.sse2.psubs.b(<16 x i8>, <16 x i8>) nounwind readnone
define <16 x i8> @__psubs_vi8(<16 x i8> %a0, <16 x i8> %a1) {
  %res = call <16 x i8> @llvm.x86.sse2.psubs.b(<16 x i8> %a0, <16 x i8> %a1) ; <<16 x i8>> [#uses=1]
  ret <16 x i8> %res
}

declare <8 x i16> @llvm.x86.sse2.psubs.w(<8 x i16>, <8 x i16>) nounwind readnone
define <16 x i16> @__psubs_vi16(<16 x i16> %a0, <16 x i16> %a1) {
  binary8to16(ret, i16, @llvm.x86.sse2.psubs.w, %a0, %a1)
  ret <16 x i16> %ret
}

declare <16 x i8> @llvm.x86.sse2.psubus.b(<16 x i8>, <16 x i8>) nounwind readnone
define <16 x i8> @__psubus_vi8(<16 x i8> %a0, <16 x i8> %a1) {
  %res = call <16 x i8> @llvm.x86.sse2.psubus.b(<16 x i8> %a0, <16 x i8> %a1) ; <<16 x i8>> [#uses=1]
  ret <16 x i8> %res
}

declare <8 x i16> @llvm.x86.sse2.psubus.w(<8 x i16>, <8 x i16>) nounwind readnone
define <16 x i16> @__psubus_vi16(<16 x i16> %a0, <16 x i16> %a1) {
  binary8to16(ret, i16, @llvm.x86.sse2.psubus.w, %a0, %a1)
  ret <16 x i16> %ret
}
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; vector deconstruction utilities
;; split 8-wide vector into 2 4-wide vectors
;;
;; $1: vector element type
;; $2: 8-wide vector
;; $3: first 4-wide vector
;; $4: second 4-wide vector

define(`v8tov4', `
  $3 = shufflevector <8 x $1> $2, <8 x $1> undef,
    <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  $4 = shufflevector <8 x $1> $2, <8 x $1> undef,
    <4 x i32> <i32 4, i32 5, i32 6, i32 7>
')

define(`v16tov8', `
  $3 = shufflevector <16 x $1> $2, <16 x $1> undef,
    <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  $4 = shufflevector <16 x $1> $2, <16 x $1> undef,
    <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
')

define(`v4tov2', `
  $3 = shufflevector <4 x $1> $2, <4 x $1> undef, <2 x i32> <i32 0, i32 1>
  $4 = shufflevector <4 x $1> $2, <4 x $1> undef, <2 x i32> <i32 2, i32 3>
')

define(`v8tov2', `
  $3 = shufflevector <8 x $1> $2, <8 x $1> undef, <2 x i32> <i32 0, i32 1>
  $4 = shufflevector <8 x $1> $2, <8 x $1> undef, <2 x i32> <i32 2, i32 3>
  $5 = shufflevector <8 x $1> $2, <8 x $1> undef, <2 x i32> <i32 4, i32 5>
  $6 = shufflevector <8 x $1> $2, <8 x $1> undef, <2 x i32> <i32 6, i32 7>
')

define(`v16tov4', `
  $3 = shufflevector <16 x $1> $2, <16 x $1> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  $4 = shufflevector <16 x $1> $2, <16 x $1> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  $5 = shufflevector <16 x $1> $2, <16 x $1> undef, <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  $6 = shufflevector <16 x $1> $2, <16 x $1> undef, <4 x i32> <i32 12, i32 13, i32 14, i32 15>
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; vector assembly: wider vector from two narrower vectors
;;
;; $1: vector element type
;; $2: first n-wide vector
;; $3: second n-wide vector
;; $4: result 2*n-wide vector
define(`v8tov16', `
  $4 = shufflevector <8 x $1> $2, <8 x $1> $3,
    <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7,
                i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Helper macro for calling various SSE instructions for scalar values
;; but where the instruction takes a vector parameter.
;; $1 : name of variable to put the final value in
;; $2 : vector width of the target
;; $3 : scalar type of the operand
;; $4 : SSE intrinsic name
;; $5 : variable name that has the scalar value
;; For example, the following call causes the variable %ret to have
;; the result of a call to sqrtss with the scalar value in %0
;;  sse_unary_scalar(ret, 4, float, @llvm.x86.sse.sqrt.ss, %0)

define(`sse_unary_scalar', `
  %$1_vec = insertelement <$2 x $3> undef, $3 $5, i32 0
  %$1_val = call <$2 x $3> $4(<$2 x $3> %$1_vec)
  %$1 = extractelement <$2 x $3> %$1_val, i32 0
')

;; Similar to `sse_unary_scalar', this helper macro is for calling binary
;; SSE instructions with scalar values,
;; $1: name of variable to put the result in
;; $2: vector width of the target
;; $3: scalar type of the operand
;; $4 : SSE intrinsic name
;; $5 : variable name that has the first scalar operand
;; $6 : variable name that has the second scalar operand

define(`sse_binary_scalar', `
  %$1_veca = insertelement <$2 x $3> undef, $3 $5, i32 0
  %$1_vecb = insertelement <$2 x $3> undef, $3 $6, i32 0
  %$1_val = call <$2 x $3> $4(<$2 x $3> %$1_veca, <$2 x $3> %$1_vecb)
  %$1 = extractelement <$2 x $3> %$1_val, i32 0
')

;; Do a reduction over a 16-wide vector
;; $1: type of final scalar result
;; $2: 16-wide function that takes 2 16-wide operands and returns the
;;     element-wise reduction
;; $3: scalar function that takes two scalar operands and returns
;;     the final reduction
;; $4: input vector

define(`reduce16', `
  %v1 = shufflevector <16 x $1> $4, <16 x $1> undef,
        <16 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15,
                    i32 undef, i32 undef, i32 undef, i32 undef,
                    i32 undef, i32 undef, i32 undef, i32 undef>
  %m1 = call <16 x $1> $2(<16 x $1> %v1, <16 x $1> $4)
  %v2 = shufflevector <16 x $1> %m1, <16 x $1> undef,
        <16 x i32> <i32 4, i32 5, i32 6, i32 7,
                    i32 undef, i32 undef, i32 undef, i32 undef,
                    i32 undef, i32 undef, i32 undef, i32 undef,
                    i32 undef, i32 undef, i32 undef, i32 undef>
  %m2 = call <16 x $1> $2(<16 x $1> %v2, <16 x $1> %m1)
  %v3 = shufflevector <16 x $1> %m2, <16 x $1> undef,
        <16 x i32> <i32 2, i32 3, i32 undef, i32 undef,
                    i32 undef, i32 undef, i32 undef, i32 undef,
                    i32 undef, i32 undef, i32 undef, i32 undef,
                    i32 undef, i32 undef, i32 undef, i32 undef>
  %m3 = call <16 x $1> $2(<16 x $1> %v3, <16 x $1> %m2)

  %m3a = extractelement <16 x $1> %m3, i32 0
  %m3b = extractelement <16 x $1> %m3, i32 1
  %m = call $1 $3($1 %m3a, $1 %m3b)
  ret $1 %m
'
)

;; Apply a unary function to the 4-vector in %0, return the vector result.
;; $1: scalar type of result
;; $2: name of scalar function to call

define(`unary1to4', `
  %v_0 = extractelement <4 x $1> %0, i32 0
  %r_0 = call $1 $2($1 %v_0)
  %ret_0 = insertelement <4 x $1> undef, $1 %r_0, i32 0
  %v_1 = extractelement <4 x $1> %0, i32 1
  %r_1 = call $1 $2($1 %v_1)
  %ret_1 = insertelement <4 x $1> %ret_0, $1 %r_1, i32 1
  %v_2 = extractelement <4 x $1> %0, i32 2
  %r_2 = call $1 $2($1 %v_2)
  %ret_2 = insertelement <4 x $1> %ret_1, $1 %r_2, i32 2
  %v_3 = extractelement <4 x $1> %0, i32 3
  %r_3 = call $1 $2($1 %v_3)
  %ret_3 = insertelement <4 x $1> %ret_2, $1 %r_3, i32 3
  ret <4 x $1> %ret_3
')

define(`unary1to8', `
  %v_0 = extractelement <8 x $1> %0, i32 0
  %r_0 = call $1 $2($1 %v_0)
  %ret_0 = insertelement <8 x $1> undef, $1 %r_0, i32 0
  %v_1 = extractelement <8 x $1> %0, i32 1
  %r_1 = call $1 $2($1 %v_1)
  %ret_1 = insertelement <8 x $1> %ret_0, $1 %r_1, i32 1
  %v_2 = extractelement <8 x $1> %0, i32 2
  %r_2 = call $1 $2($1 %v_2)
  %ret_2 = insertelement <8 x $1> %ret_1, $1 %r_2, i32 2
  %v_3 = extractelement <8 x $1> %0, i32 3
  %r_3 = call $1 $2($1 %v_3)
  %ret_3 = insertelement <8 x $1> %ret_2, $1 %r_3, i32 3
  %v_4 = extractelement <8 x $1> %0, i32 4
  %r_4 = call $1 $2($1 %v_4)
  %ret_4 = insertelement <8 x $1> %ret_3, $1 %r_4, i32 4
  %v_5 = extractelement <8 x $1> %0, i32 5
  %r_5 = call $1 $2($1 %v_5)
  %ret_5 = insertelement <8 x $1> %ret_4, $1 %r_5, i32 5
  %v_6 = extractelement <8 x $1> %0, i32 6
  %r_6 = call $1 $2($1 %v_6)
  %ret_6 = insertelement <8 x $1> %ret_5, $1 %r_6, i32 6
  %v_7 = extractelement <8 x $1> %0, i32 7
  %r_7 = call $1 $2($1 %v_7)
  %ret_7 = insertelement <8 x $1> %ret_6, $1 %r_7, i32 7
  ret <8 x $1> %ret_7
')

;; Given a unary function that takes a 2-wide vector and a 4-wide vector
;; that we'd like to apply it to, extract 2 2-wide vectors from the 4-wide
;; vector, apply it, and return the corresponding 4-wide vector result
;; $1: name of variable into which the final result should go
;; $2: scalar type of the vector elements
;; $3: 2-wide unary vector function to apply
;; $4: 4-wide operand value

define(`unary2to4', `
  %$1_0 = shufflevector <4 x $2> $4, <4 x $2> undef, <2 x i32> <i32 0, i32 1>
  %v$1_0 = call <2 x $2> $3(<2 x $2> %$1_0)
  %$1_1 = shufflevector <4 x $2> $4, <4 x $2> undef, <2 x i32> <i32 2, i32 3>
  %v$1_1 = call <2 x $2> $3(<2 x $2> %$1_1)
  %$1 = shufflevector <2 x $2> %v$1_0, <2 x $2> %v$1_1,
           <4 x i32> <i32 0, i32 1, i32 2, i32 3>
'
)

;; Similar to `unary2to4', this applies a 2-wide binary function to two 4-wide
;; vector operands
;; $1: name of variable into which the final result should go
;; $2: scalar type of the vector elements
;; $3: 2-wide binary vector function to apply
;; $4: First 4-wide operand value
;; $5: Second 4-wide operand value

define(`binary2to4', `
%$1_0a = shufflevector <4 x $2> $4, <4 x $2> undef, <2 x i32> <i32 0, i32 1>
%$1_0b = shufflevector <4 x $2> $5, <4 x $2> undef, <2 x i32> <i32 0, i32 1>
%v$1_0 = call <2 x $2> $3(<2 x $2> %$1_0a, <2 x $2> %$1_0b)
%$1_1a = shufflevector <4 x $2> $4, <4 x $2> undef, <2 x i32> <i32 2, i32 3>
%$1_1b = shufflevector <4 x $2> $5, <4 x $2> undef, <2 x i32> <i32 2, i32 3>
%v$1_1 = call <2 x $2> $3(<2 x $2> %$1_1a, <2 x $2> %$1_1b)
%$1 = shufflevector <2 x $2> %v$1_0, <2 x $2> %v$1_1,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
'
)

;; Similar to `unary2to4', this maps a 4-wide unary function to an 8-wide
;; vector operand
;; $1: name of variable into which the final result should go
;; $2: scalar type of the vector elements
;; $3: 4-wide unary vector function to apply
;; $4: 8-wide operand value

define(`unary4to8', `
  %__$1_0 = shufflevector <8 x $2> $4, <8 x $2> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %__v$1_0 = call <4 x $2> $3(<4 x $2> %__$1_0)
  %__$1_1 = shufflevector <8 x $2> $4, <8 x $2> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %__v$1_1 = call <4 x $2> $3(<4 x $2> %__$1_1)
  %$1 = shufflevector <4 x $2> %__v$1_0, <4 x $2> %__v$1_1,
           <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
'
)

;; $1: name of variable into which the final result should go
;; $2: scalar type of the input vector elements
;; $3: scalar type of the result vector elements
;; $4: 4-wide unary vector function to apply
;; $5: 8-wide operand value

define(`unary4to8conv', `
  %$1_0 = shufflevector <8 x $2> $5, <8 x $2> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v$1_0 = call <4 x $3> $4(<4 x $2> %$1_0)
  %$1_1 = shufflevector <8 x $2> $5, <8 x $2> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v$1_1 = call <4 x $3> $4(<4 x $2> %$1_1)
  %$1 = shufflevector <4 x $3> %v$1_0, <4 x $3> %v$1_1,
           <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
'
)

define(`unary4to16', `
  %__$1_0 = shufflevector <16 x $2> $4, <16 x $2> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %__v$1_0 = call <4 x $2> $3(<4 x $2> %__$1_0)
  %__$1_1 = shufflevector <16 x $2> $4, <16 x $2> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %__v$1_1 = call <4 x $2> $3(<4 x $2> %__$1_1)
  %__$1_2 = shufflevector <16 x $2> $4, <16 x $2> undef, <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %__v$1_2 = call <4 x $2> $3(<4 x $2> %__$1_2)
  %__$1_3 = shufflevector <16 x $2> $4, <16 x $2> undef, <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %__v$1_3 = call <4 x $2> $3(<4 x $2> %__$1_3)

  %__$1a = shufflevector <4 x $2> %__v$1_0, <4 x $2> %__v$1_1,
           <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %__$1b = shufflevector <4 x $2> %__v$1_2, <4 x $2> %__v$1_3,
           <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %$1 = shufflevector <8 x $2> %__$1a, <8 x $2> %__$1b,
           <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7,
                       i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
'
)

define(`unary4to16conv', `
  %$1_0 = shufflevector <16 x $2> $5, <16 x $2> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v$1_0 = call <4 x $3> $4(<4 x $2> %$1_0)
  %$1_1 = shufflevector <16 x $2> $5, <16 x $2> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v$1_1 = call <4 x $3> $4(<4 x $2> %$1_1)
  %$1_2 = shufflevector <16 x $2> $5, <16 x $2> undef, <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v$1_2 = call <4 x $3> $4(<4 x $2> %$1_2)
  %$1_3 = shufflevector <16 x $2> $5, <16 x $2> undef, <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v$1_3 = call <4 x $3> $4(<4 x $2> %$1_3)

  %$1a = shufflevector <4 x $3> %v$1_0, <4 x $3> %v$1_1,
           <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %$1b = shufflevector <4 x $3> %v$1_2, <4 x $3> %v$1_3,
           <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %$1 = shufflevector <8 x $3> %$1a, <8 x $3> %$1b,
           <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7,
                       i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
'
)

;; And so forth...
;; $1: name of variable into which the final result should go
;; $2: scalar type of the vector elements
;; $3: 8-wide unary vector function to apply
;; $4: 16-wide operand value

define(`unary8to16', `
  %$1_0 = shufflevector <16 x $2> $4, <16 x $2> undef,
             <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %v$1_0 = call <8 x $2> $3(<8 x $2> %$1_0)
  %$1_1 = shufflevector <16 x $2> $4, <16 x $2> undef,
             <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %v$1_1 = call <8 x $2> $3(<8 x $2> %$1_1)
  %$1 = shufflevector <8 x $2> %v$1_0, <8 x $2> %v$1_1,
           <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7,
                       i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
'
)

;; And along the lines of `binary2to4', this maps a 4-wide binary function to
;; two 8-wide vector operands
;; $1: name of variable into which the final result should go
;; $2: scalar type of the vector elements
;; $3: 4-wide unary vector function to apply
;; $4: First 8-wide operand value
;; $5: Second 8-wide operand value

define(`binary4to8', `
%$1_0a = shufflevector <8 x $2> $4, <8 x $2> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
%$1_0b = shufflevector <8 x $2> $5, <8 x $2> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
%v$1_0 = call <4 x $2> $3(<4 x $2> %$1_0a, <4 x $2> %$1_0b)
%$1_1a = shufflevector <8 x $2> $4, <8 x $2> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
%$1_1b = shufflevector <8 x $2> $5, <8 x $2> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
%v$1_1 = call <4 x $2> $3(<4 x $2> %$1_1a, <4 x $2> %$1_1b)
%$1 = shufflevector <4 x $2> %v$1_0, <4 x $2> %v$1_1,
         <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
'
)

define(`binary8to16', `
%$1_0a = shufflevector <16 x $2> $4, <16 x $2> undef,
          <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
%$1_0b = shufflevector <16 x $2> $5, <16 x $2> undef,
          <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
%v$1_0 = call <8 x $2> $3(<8 x $2> %$1_0a, <8 x $2> %$1_0b)
%$1_1a = shufflevector <16 x $2> $4, <16 x $2> undef,
          <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
%$1_1b = shufflevector <16 x $2> $5, <16 x $2> undef,
          <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
%v$1_1 = call <8 x $2> $3(<8 x $2> %$1_1a, <8 x $2> %$1_1b)
%$1 = shufflevector <8 x $2> %v$1_0, <8 x $2> %v$1_1,
         <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7,
                     i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
'
)

define(`binary4to16', `
%$1_0a = shufflevector <16 x $2> $4, <16 x $2> undef,
          <4 x i32> <i32 0, i32 1, i32 2, i32 3>
%$1_0b = shufflevector <16 x $2> $5, <16 x $2> undef,
          <4 x i32> <i32 0, i32 1, i32 2, i32 3>
%r$1_0 = call <4 x $2> $3(<4 x $2> %$1_0a, <4 x $2> %$1_0b)

%$1_1a = shufflevector <16 x $2> $4, <16 x $2> undef,
          <4 x i32> <i32 4, i32 5, i32 6, i32 7>
%$1_1b = shufflevector <16 x $2> $5, <16 x $2> undef,
          <4 x i32> <i32 4, i32 5, i32 6, i32 7>
%r$1_1 = call <4 x $2> $3(<4 x $2> %$1_1a, <4 x $2> %$1_1b)

%$1_2a = shufflevector <16 x $2> $4, <16 x $2> undef,
          <4 x i32> <i32 8, i32 9, i32 10, i32 11>
%$1_2b = shufflevector <16 x $2> $5, <16 x $2> undef,
          <4 x i32> <i32 8, i32 9, i32 10, i32 11>
%r$1_2 = call <4 x $2> $3(<4 x $2> %$1_2a, <4 x $2> %$1_2b)

%$1_3a = shufflevector <16 x $2> $4, <16 x $2> undef,
          <4 x i32> <i32 12, i32 13, i32 14, i32 15>
%$1_3b = shufflevector <16 x $2> $5, <16 x $2> undef,
          <4 x i32> <i32 12, i32 13, i32 14, i32 15>
%r$1_3 = call <4 x $2> $3(<4 x $2> %$1_3a, <4 x $2> %$1_3b)

%r$1_01 = shufflevector <4 x $2> %r$1_0, <4 x $2> %r$1_1,
          <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
%r$1_23 = shufflevector <4 x $2> %r$1_2, <4 x $2> %r$1_3,
          <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>

%$1 = shufflevector <8 x $2> %r$1_01, <8 x $2> %r$1_23,
          <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7,
                      i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
')

;; Maps a 2-wide unary function to an 8-wide vector operand, returning an
;; 8-wide vector result
;; $1: name of variable into which the final result should go
;; $2: scalar type of the vector elements
;; $3: 2-wide unary vector function to apply
;; $4: 8-wide operand value

define(`unary2to8', `
  %$1_0 = shufflevector <8 x $2> $4, <8 x $2> undef, <2 x i32> <i32 0, i32 1>
  %v$1_0 = call <2 x $2> $3(<2 x $2> %$1_0)
  %$1_1 = shufflevector <8 x $2> $4, <8 x $2> undef, <2 x i32> <i32 2, i32 3>
  %v$1_1 = call <2 x $2> $3(<2 x $2> %$1_1)
  %$1_2 = shufflevector <8 x $2> $4, <8 x $2> undef, <2 x i32> <i32 4, i32 5>
  %v$1_2 = call <2 x $2> $3(<2 x $2> %$1_2)
  %$1_3 = shufflevector <8 x $2> $4, <8 x $2> undef, <2 x i32> <i32 6, i32 7>
  %v$1_3 = call <2 x $2> $3(<2 x $2> %$1_3)
  %$1a = shufflevector <2 x $2> %v$1_0, <2 x $2> %v$1_1,
           <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %$1b = shufflevector <2 x $2> %v$1_2, <2 x $2> %v$1_3,
           <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %$1 = shufflevector <4 x $2> %$1a, <4 x $2> %$1b,
           <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
'
)

define(`unary2to16', `
  %$1_0 = shufflevector <16 x $2> $4, <16 x $2> undef, <2 x i32> <i32 0, i32 1>
  %v$1_0 = call <2 x $2> $3(<2 x $2> %$1_0)
  %$1_1 = shufflevector <16 x $2> $4, <16 x $2> undef, <2 x i32> <i32 2, i32 3>
  %v$1_1 = call <2 x $2> $3(<2 x $2> %$1_1)
  %$1_2 = shufflevector <16 x $2> $4, <16 x $2> undef, <2 x i32> <i32 4, i32 5>
  %v$1_2 = call <2 x $2> $3(<2 x $2> %$1_2)
  %$1_3 = shufflevector <16 x $2> $4, <16 x $2> undef, <2 x i32> <i32 6, i32 7>
  %v$1_3 = call <2 x $2> $3(<2 x $2> %$1_3)
  %$1_4 = shufflevector <16 x $2> $4, <16 x $2> undef, <2 x i32> <i32 8, i32 9>
  %v$1_4 = call <2 x $2> $3(<2 x $2> %$1_4)
  %$1_5 = shufflevector <16 x $2> $4, <16 x $2> undef, <2 x i32> <i32 10, i32 11>
  %v$1_5 = call <2 x $2> $3(<2 x $2> %$1_5)
  %$1_6 = shufflevector <16 x $2> $4, <16 x $2> undef, <2 x i32> <i32 12, i32 13>
  %v$1_6 = call <2 x $2> $3(<2 x $2> %$1_6)
  %$1_7 = shufflevector <16 x $2> $4, <16 x $2> undef, <2 x i32> <i32 14, i32 15>
  %v$1_7 = call <2 x $2> $3(<2 x $2> %$1_7)
  %$1a = shufflevector <2 x $2> %v$1_0, <2 x $2> %v$1_1,
           <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %$1b = shufflevector <2 x $2> %v$1_2, <2 x $2> %v$1_3,
           <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %$1ab = shufflevector <4 x $2> %$1a, <4 x $2> %$1b,
           <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %$1c = shufflevector <2 x $2> %v$1_4, <2 x $2> %v$1_5,
           <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %$1d = shufflevector <2 x $2> %v$1_6, <2 x $2> %v$1_7,
           <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %$1cd = shufflevector <4 x $2> %$1c, <4 x $2> %$1d,
           <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>

  %$1 = shufflevector <8 x $2> %$1ab, <8 x $2> %$1cd,
           <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7,
                       i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
'
)

;; Maps an 2-wide binary function to two 8-wide vector operands
;; $1: name of variable into which the final result should go
;; $2: scalar type of the vector elements
;; $3: 2-wide unary vector function to apply
;; $4: First 8-wide operand value
;; $5: Second 8-wide operand value

define(`binary2to8', `
  %$1_0a = shufflevector <8 x $2> $4, <8 x $2> undef, <2 x i32> <i32 0, i32 1>
  %$1_0b = shufflevector <8 x $2> $5, <8 x $2> undef, <2 x i32> <i32 0, i32 1>
  %v$1_0 = call <2 x $2> $3(<2 x $2> %$1_0a, <2 x $2> %$1_0b)
  %$1_1a = shufflevector <8 x $2> $4, <8 x $2> undef, <2 x i32> <i32 2, i32 3>
  %$1_1b = shufflevector <8 x $2> $5, <8 x $2> undef, <2 x i32> <i32 2, i32 3>
  %v$1_1 = call <2 x $2> $3(<2 x $2> %$1_1a, <2 x $2> %$1_1b)
  %$1_2a = shufflevector <8 x $2> $4, <8 x $2> undef, <2 x i32> <i32 4, i32 5>
  %$1_2b = shufflevector <8 x $2> $5, <8 x $2> undef, <2 x i32> <i32 4, i32 5>
  %v$1_2 = call <2 x $2> $3(<2 x $2> %$1_2a, <2 x $2> %$1_2b)
  %$1_3a = shufflevector <8 x $2> $4, <8 x $2> undef, <2 x i32> <i32 6, i32 7>
  %$1_3b = shufflevector <8 x $2> $5, <8 x $2> undef, <2 x i32> <i32 6, i32 7>
  %v$1_3 = call <2 x $2> $3(<2 x $2> %$1_3a, <2 x $2> %$1_3b)

  %$1a = shufflevector <2 x $2> %v$1_0, <2 x $2> %v$1_1,
           <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %$1b = shufflevector <2 x $2> %v$1_2, <2 x $2> %v$1_3,
           <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %$1 = shufflevector <4 x $2> %$1a, <4 x $2> %$1b,
           <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
'
)

define(`binary2to16', `
  %$1_0a = shufflevector <16 x $2> $4, <16 x $2> undef, <2 x i32> <i32 0, i32 1>
  %$1_0b = shufflevector <16 x $2> $5, <16 x $2> undef, <2 x i32> <i32 0, i32 1>
  %v$1_0 = call <2 x $2> $3(<2 x $2> %$1_0a, <2 x $2> %$1_0b)
  %$1_1a = shufflevector <16 x $2> $4, <16 x $2> undef, <2 x i32> <i32 2, i32 3>
  %$1_1b = shufflevector <16 x $2> $5, <16 x $2> undef, <2 x i32> <i32 2, i32 3>
  %v$1_1 = call <2 x $2> $3(<2 x $2> %$1_1a, <2 x $2> %$1_1b)
  %$1_2a = shufflevector <16 x $2> $4, <16 x $2> undef, <2 x i32> <i32 4, i32 5>
  %$1_2b = shufflevector <16 x $2> $5, <16 x $2> undef, <2 x i32> <i32 4, i32 5>
  %v$1_2 = call <2 x $2> $3(<2 x $2> %$1_2a, <2 x $2> %$1_2b)
  %$1_3a = shufflevector <16 x $2> $4, <16 x $2> undef, <2 x i32> <i32 6, i32 7>
  %$1_3b = shufflevector <16 x $2> $5, <16 x $2> undef, <2 x i32> <i32 6, i32 7>
  %v$1_3 = call <2 x $2> $3(<2 x $2> %$1_3a, <2 x $2> %$1_3b)
  %$1_4a = shufflevector <16 x $2> $4, <16 x $2> undef, <2 x i32> <i32 8, i32 9>
  %$1_4b = shufflevector <16 x $2> $5, <16 x $2> undef, <2 x i32> <i32 8, i32 9>
  %v$1_4 = call <2 x $2> $3(<2 x $2> %$1_4a, <2 x $2> %$1_4b)
  %$1_5a = shufflevector <16 x $2> $4, <16 x $2> undef, <2 x i32> <i32 10, i32 11>
  %$1_5b = shufflevector <16 x $2> $5, <16 x $2> undef, <2 x i32> <i32 10, i32 11>
  %v$1_5 = call <2 x $2> $3(<2 x $2> %$1_5a, <2 x $2> %$1_5b)
  %$1_6a = shufflevector <16 x $2> $4, <16 x $2> undef, <2 x i32> <i32 12, i32 13>
  %$1_6b = shufflevector <16 x $2> $5, <16 x $2> undef, <2 x i32> <i32 12, i32 13>
  %v$1_6 = call <2 x $2> $3(<2 x $2> %$1_6a, <2 x $2> %$1_6b)
  %$1_7a = shufflevector <16 x $2> $4, <16 x $2> undef, <2 x i32> <i32 14, i32 15>
  %$1_7b = shufflevector <16 x $2> $5, <16 x $2> undef, <2 x i32> <i32 14, i32 15>
  %v$1_7 = call <2 x $2> $3(<2 x $2> %$1_7a, <2 x $2> %$1_7b)

  %$1a = shufflevector <2 x $2> %v$1_0, <2 x $2> %v$1_1,
           <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %$1b = shufflevector <2 x $2> %v$1_2, <2 x $2> %v$1_3,
           <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %$1ab = shufflevector <4 x $2> %$1a, <4 x $2> %$1b,
           <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>

  %$1c = shufflevector <2 x $2> %v$1_4, <2 x $2> %v$1_5,
           <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %$1d = shufflevector <2 x $2> %v$1_6, <2 x $2> %v$1_7,
           <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %$1cd = shufflevector <4 x $2> %$1c, <4 x $2> %$1d,
           <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>

  %$1 = shufflevector <8 x $2> %$1ab, <8 x $2> %$1cd,
           <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7,
                       i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
'
)

;; The unary SSE round intrinsic takes a second argument that encodes the
;; rounding mode.  This macro makes it easier to apply the 4-wide roundps
;; to 8-wide vector operands
;; $1: value to be rounded
;; $2: integer encoding of rounding mode
;; FIXME: this just has a ret statement at the end to return the result,
;; which is inconsistent with the macros above

define(`round4to8', `
%v0 = shufflevector <8 x float> $1, <8 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
%v1 = shufflevector <8 x float> $1, <8 x float> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
%r0 = call <4 x float> @llvm.x86.sse41.round.ps(<4 x float> %v0, i32 $2)
%r1 = call <4 x float> @llvm.x86.sse41.round.ps(<4 x float> %v1, i32 $2)
%ret = shufflevector <4 x float> %r0, <4 x float> %r1,
         <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
ret <8 x float> %ret
'
)

define(`round4to16', `
%v0 = shufflevector <16 x float> $1, <16 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
%v1 = shufflevector <16 x float> $1, <16 x float> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
%v2 = shufflevector <16 x float> $1, <16 x float> undef, <4 x i32> <i32 8, i32 9, i32 10, i32 11>
%v3 = shufflevector <16 x float> $1, <16 x float> undef, <4 x i32> <i32 12, i32 13, i32 14, i32 15>
%r0 = call <4 x float> @llvm.x86.sse41.round.ps(<4 x float> %v0, i32 $2)
%r1 = call <4 x float> @llvm.x86.sse41.round.ps(<4 x float> %v1, i32 $2)
%r2 = call <4 x float> @llvm.x86.sse41.round.ps(<4 x float> %v2, i32 $2)
%r3 = call <4 x float> @llvm.x86.sse41.round.ps(<4 x float> %v3, i32 $2)
%ret01 = shufflevector <4 x float> %r0, <4 x float> %r1,
         <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
%ret23 = shufflevector <4 x float> %r2, <4 x float> %r3,
         <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
%ret = shufflevector <8 x float> %ret01, <8 x float> %ret23,
         <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7,
                     i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
ret <16 x float> %ret
'
)

define(`round8to16', `
%v0 = shufflevector <16 x float> $1, <16 x float> undef,
        <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
%v1 = shufflevector <16 x float> $1, <16 x float> undef,
        <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
%r0 = call <8 x float> @llvm.x86.avx.round.ps.256(<8 x float> %v0, i32 $2)
%r1 = call <8 x float> @llvm.x86.avx.round.ps.256(<8 x float> %v1, i32 $2)
%ret = shufflevector <8 x float> %r0, <8 x float> %r1,
         <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7,
                     i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
ret <16 x float> %ret
'
)

define(`round4to8double', `
%v0 = shufflevector <8 x double> $1, <8 x double> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
%v1 = shufflevector <8 x double> $1, <8 x double> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
%r0 = call <4 x double> @llvm.x86.avx.round.pd.256(<4 x double> %v0, i32 $2)
%r1 = call <4 x double> @llvm.x86.avx.round.pd.256(<4 x double> %v1, i32 $2)
%ret = shufflevector <4 x double> %r0, <4 x double> %r1,
         <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
ret <8 x double> %ret
'
)

; and similarly for doubles...

define(`round2to4double', `
%v0 = shufflevector <4 x double> $1, <4 x double> undef, <2 x i32> <i32 0, i32 1>
%v1 = shufflevector <4 x double> $1, <4 x double> undef, <2 x i32> <i32 2, i32 3>
%r0 = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %v0, i32 $2)
%r1 = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %v1, i32 $2)
%ret = shufflevector <2 x double> %r0, <2 x double> %r1,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
ret <4 x double> %ret
'
)

define(`round2to8double', `
%v0 = shufflevector <8 x double> $1, <8 x double> undef, <2 x i32> <i32 0, i32 1>
%v1 = shufflevector <8 x double> $1, <8 x double> undef, <2 x i32> <i32 2, i32 3>
%v2 = shufflevector <8 x double> $1, <8 x double> undef, <2 x i32> <i32 4, i32 5>
%v3 = shufflevector <8 x double> $1, <8 x double> undef, <2 x i32> <i32 6, i32 7>
%r0 = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %v0, i32 $2)
%r1 = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %v1, i32 $2)
%r2 = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %v2, i32 $2)
%r3 = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %v3, i32 $2)
%ret0 = shufflevector <2 x double> %r0, <2 x double> %r1,
          <4 x i32> <i32 0, i32 1, i32 2, i32 3>
%ret1 = shufflevector <2 x double> %r2, <2 x double> %r3,
          <4 x i32> <i32 0, i32 1, i32 2, i32 3>
%ret = shufflevector <4 x double> %ret0, <4 x double> %ret1,
          <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
ret <8 x double> %ret
'
)

define(`round2to16double', `
%v0 = shufflevector <16 x double> $1, <16 x double> undef, <2 x i32> <i32 0,  i32 1>
%v1 = shufflevector <16 x double> $1, <16 x double> undef, <2 x i32> <i32 2,  i32 3>
%v2 = shufflevector <16 x double> $1, <16 x double> undef, <2 x i32> <i32 4,  i32 5>
%v3 = shufflevector <16 x double> $1, <16 x double> undef, <2 x i32> <i32 6,  i32 7>
%v4 = shufflevector <16 x double> $1, <16 x double> undef, <2 x i32> <i32 8,  i32 9>
%v5 = shufflevector <16 x double> $1, <16 x double> undef, <2 x i32> <i32 10, i32 11>
%v6 = shufflevector <16 x double> $1, <16 x double> undef, <2 x i32> <i32 12, i32 13>
%v7 = shufflevector <16 x double> $1, <16 x double> undef, <2 x i32> <i32 14, i32 15>
%r0 = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %v0, i32 $2)
%r1 = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %v1, i32 $2)
%r2 = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %v2, i32 $2)
%r3 = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %v3, i32 $2)
%r4 = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %v4, i32 $2)
%r5 = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %v5, i32 $2)
%r6 = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %v6, i32 $2)
%r7 = call <2 x double> @llvm.x86.sse41.round.pd(<2 x double> %v7, i32 $2)
%ret0 = shufflevector <2 x double> %r0, <2 x double> %r1,
          <4 x i32> <i32 0, i32 1, i32 2, i32 3>
%ret1 = shufflevector <2 x double> %r2, <2 x double> %r3,
          <4 x i32> <i32 0, i32 1, i32 2, i32 3>
%ret01 = shufflevector <4 x double> %ret0, <4 x double> %ret1,
          <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
%ret2 = shufflevector <2 x double> %r4, <2 x double> %r5,
          <4 x i32> <i32 0, i32 1, i32 2, i32 3>
%ret3 = shufflevector <2 x double> %r6, <2 x double> %r7,
          <4 x i32> <i32 0, i32 1, i32 2, i32 3>
%ret23 = shufflevector <4 x double> %ret2, <4 x double> %ret3,
          <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
%ret = shufflevector <8 x double> %ret01, <8 x double> %ret23,
          <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7,
                      i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
ret <16 x double> %ret
'
)

define(`round4to16double', `
%v0 = shufflevector <16 x double> $1, <16 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
%v1 = shufflevector <16 x double> $1, <16 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
%v2 = shufflevector <16 x double> $1, <16 x double> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
%v3 = shufflevector <16 x double> $1, <16 x double> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
%r0 = call <4 x double> @llvm.x86.avx.round.pd.256(<4 x double> %v0, i32 $2)
%r1 = call <4 x double> @llvm.x86.avx.round.pd.256(<4 x double> %v1, i32 $2)
%r2 = call <4 x double> @llvm.x86.avx.round.pd.256(<4 x double> %v2, i32 $2)
%r3 = call <4 x double> @llvm.x86.avx.round.pd.256(<4 x double> %v3, i32 $2)
%ret0 = shufflevector <4 x double> %r0, <4 x double> %r1,
          <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
%ret1 = shufflevector <4 x double> %r2, <4 x double> %r3,
          <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
%ret = shufflevector <8 x double> %ret0, <8 x double> %ret1,
          <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7,
                      i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
ret <16 x double> %ret
'
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; forloop macro

divert(`-1')
# forloop(var, from, to, stmt) - improved version:
#   works even if VAR is not a strict macro name
#   performs sanity check that FROM is larger than TO
#   allows complex numerical expressions in TO and FROM
define(`forloop', `ifelse(eval(`($3) >= ($2)'), `1',
  `pushdef(`$1', eval(`$2'))_$0(`$1',
    eval(`$3'), `$4')popdef(`$1')')')
define(`_forloop',
  `$3`'ifelse(indir(`$1'), `$2', `',
    `define(`$1', incr(indir(`$1')))$0($@)')')
divert`'dnl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; stdlib_core
;;
;; This macro defines a bunch of helper routines that depend on the
;; target's vector width
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define(`shuffles', `
define <WIDTH x $1> @__broadcast_$1(<WIDTH x $1>, i32) nounwind readnone alwaysinline {
  %v = extractelement <WIDTH x $1> %0, i32 %1
  %broadcast_init = insertelement <WIDTH x $1> undef, $1 %v, i32 0
  %broadcast = shufflevector <WIDTH x $1> %broadcast_init, <WIDTH x $1> undef, <WIDTH x i32> zeroinitializer
  ret <WIDTH x $1> %broadcast
}

define <WIDTH x $1> @__rotate_$1(<WIDTH x $1>, i32) nounwind readnone alwaysinline {
  %ptr = alloca <WIDTH x $1>, i32 2
  %isc = call i1 @__is_compile_time_constant_uniform_int32(i32 %1)
  br i1 %isc, label %is_const, label %not_const

is_const:
  ; though verbose, this turms into tight code if %1 is a constant
forloop(i, 0, eval(WIDTH-1), `
  %delta_`'i = add i32 %1, i
  %delta_clamped_`'i = and i32 %delta_`'i, eval(WIDTH-1)
  %v_`'i = extractelement <WIDTH x $1> %0, i32 %delta_clamped_`'i')

  %ret_0 = insertelement <WIDTH x $1> undef, $1 %v_0, i32 0
forloop(i, 1, eval(WIDTH-1), `  %ret_`'i = insertelement <WIDTH x $1> %ret_`'eval(i-1), $1 %v_`'i, i32 i
')
  ret <WIDTH x $1> %ret_`'eval(WIDTH-1)

not_const:
  ; store two instances of the vector into memory
  %ptr0 = getelementptr PTR_OP_ARGS(`<WIDTH x $1>') %ptr, i32 0
  store <WIDTH x $1> %0, <WIDTH x $1> * %ptr0
  %ptr1 = getelementptr PTR_OP_ARGS(`<WIDTH x $1>') %ptr, i32 1
  store <WIDTH x $1> %0, <WIDTH x $1> * %ptr1

  ; compute offset in [0,vectorwidth-1], then index into the doubled-up vector
  %offset = and i32 %1, eval(WIDTH-1)
  %ptr_as_elt_array = bitcast <WIDTH x $1> * %ptr to [eval(2*WIDTH) x $1] *
  %load_ptr = getelementptr PTR_OP_ARGS(`[eval(2*WIDTH) x $1]') %ptr_as_elt_array, i32 0, i32 %offset
  %load_ptr_vec = bitcast $1 * %load_ptr to <WIDTH x $1> *
  %result = load PTR_OP_ARGS(`<WIDTH x $1> ')  %load_ptr_vec, align $2
  ret <WIDTH x $1> %result
}

define <WIDTH x $1> @__shift_$1(<WIDTH x $1>, i32) nounwind readnone alwaysinline {
  %ptr = alloca <WIDTH x $1>, i32 3
  %ptr0 = getelementptr PTR_OP_ARGS(`<WIDTH x $1>') %ptr, i32 0
  store <WIDTH x $1> zeroinitializer, <WIDTH x $1> * %ptr0
  %ptr1 = getelementptr PTR_OP_ARGS(`<WIDTH x $1>') %ptr, i32 1
  store <WIDTH x $1> %0, <WIDTH x $1> * %ptr1
  %ptr2 = getelementptr PTR_OP_ARGS(`<WIDTH x $1>') %ptr, i32 2
  store <WIDTH x $1> zeroinitializer, <WIDTH x $1> * %ptr2

  %offset = add i32 %1, WIDTH
  %ptr_as_elt_array = bitcast <WIDTH x $1> * %ptr to [eval(3*WIDTH) x $1] *
  %load_ptr = getelementptr PTR_OP_ARGS(`[eval(3*WIDTH) x $1]') %ptr_as_elt_array, i32 0, i32 %offset
  %load_ptr_vec = bitcast $1 * %load_ptr to <WIDTH x $1> *
  %result = load PTR_OP_ARGS(`<WIDTH x $1> ')  %load_ptr_vec, align $2
  ret <WIDTH x $1> %result
}


define <WIDTH x $1> @__shuffle_$1(<WIDTH x $1>, <WIDTH x i32>) nounwind readnone alwaysinline {
forloop(i, 0, eval(WIDTH-1), `
  %index_`'i = extractelement <WIDTH x i32> %1, i32 i')
forloop(i, 0, eval(WIDTH-1), `
  %v_`'i = extractelement <WIDTH x $1> %0, i32 %index_`'i')

  %ret_0 = insertelement <WIDTH x $1> undef, $1 %v_0, i32 0
forloop(i, 1, eval(WIDTH-1), `  %ret_`'i = insertelement <WIDTH x $1> %ret_`'eval(i-1), $1 %v_`'i, i32 i
')
  ret <WIDTH x $1> %ret_`'eval(WIDTH-1)
}

define <WIDTH x $1> @__shuffle2_$1(<WIDTH x $1>, <WIDTH x $1>, <WIDTH x i32>) nounwind readnone alwaysinline {
  %ptr = alloca <eval(2*WIDTH) x $1>
  %v2 = shufflevector <WIDTH x $1> %0, <WIDTH x $1> %1, <eval(2*WIDTH) x i32> <
      forloop(i, 0, eval(2*WIDTH-2), `i32 i, ') i32 eval(2*WIDTH-1)
  >
forloop(i, 0, eval(WIDTH-1), `
  %index_`'i = extractelement <WIDTH x i32> %2, i32 i')

  %isc = call i1 @__is_compile_time_constant_varying_int32(<WIDTH x i32> %2)
  br i1 %isc, label %is_const, label %not_const

is_const:
  ; extract from the requested lanes and insert into the result; LLVM turns
  ; this into good code in the end
forloop(i, 0, eval(WIDTH-1), `
  %v_`'i = extractelement <eval(2*WIDTH) x $1> %v2, i32 %index_`'i')

  %ret_0 = insertelement <WIDTH x $1> undef, $1 %v_0, i32 0
forloop(i, 1, eval(WIDTH-1), `  %ret_`'i = insertelement <WIDTH x $1> %ret_`'eval(i-1), $1 %v_`'i, i32 i
')
  ret <WIDTH x $1> %ret_`'eval(WIDTH-1)

not_const:
  ; otherwise store the two vectors onto the stack and then use the given
  ; permutation vector to get indices into that array...
  store <eval(2*WIDTH) x $1> %v2, <eval(2*WIDTH) x $1> * %ptr
  %baseptr = bitcast <eval(2*WIDTH) x $1> * %ptr to $1 *

  %ptr_0 = getelementptr PTR_OP_ARGS(`$1') %baseptr, i32 %index_0
  %val_0 = load PTR_OP_ARGS(`$1 ')  %ptr_0
  %result_0 = insertelement <WIDTH x $1> undef, $1 %val_0, i32 0

forloop(i, 1, eval(WIDTH-1), `
  %ptr_`'i = getelementptr PTR_OP_ARGS(`$1') %baseptr, i32 %index_`'i
  %val_`'i = load PTR_OP_ARGS(`$1 ')  %ptr_`'i
  %result_`'i = insertelement <WIDTH x $1> %result_`'eval(i-1), $1 %val_`'i, i32 i
')

  ret <WIDTH x $1> %result_`'eval(WIDTH-1)
}
')

define(`define_shuffles',`
shuffles(i8, 1)
shuffles(i16, 2)
shuffles(float, 4)
shuffles(i32, 4)
shuffles(double, 8)
shuffles(i64, 8)
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; global_atomic_associative
;; More efficient implementation for atomics that are associative (e.g.,
;; add, and, ...).  If a basic implementation would do sometihng like:
;; result0 = atomic_op(ptr, val0)
;; result1 = atomic_op(ptr, val1)
;; ..
;; Then instead we can do:
;; tmp = (val0 op val1 op ...)
;; result0 = atomic_op(ptr, tmp)
;; result1 = (result0 op val0)
;; ..
;; And more efficiently compute the same result
;;
;; Takes five parameters:
;; $1: vector width of the target
;; $2: operation being performed (w.r.t. LLVM atomic intrinsic names)
;;     (add, sub...)
;; $3: return type of the LLVM atomic (e.g. i32)
;; $4: return type of the LLVM atomic type, in ispc naming paralance (e.g. int32)
;; $5: identity value for the operator (e.g. 0 for add, -1 for AND, ...)

define(`mask_converts', `
define internal <$1 x i8> @convertmask_i1_i8_$1(<$1 x i1>) {
  %r = sext <$1 x i1> %0 to <$1 x i8>
  ret <$1 x i8> %r
}
define internal <$1 x i16> @convertmask_i1_i16_$1(<$1 x i1>) {
  %r = sext <$1 x i1> %0 to <$1 x i16>
  ret <$1 x i16> %r
}
define internal <$1 x i32> @convertmask_i1_i32_$1(<$1 x i1>) {
  %r = sext <$1 x i1> %0 to <$1 x i32>
  ret <$1 x i32> %r
}
define internal <$1 x i64> @convertmask_i1_i64_$1(<$1 x i1>) {
  %r = sext <$1 x i1> %0 to <$1 x i64>
  ret <$1 x i64> %r
}

define internal <$1 x i8> @convertmask_i8_i8_$1(<$1 x i8>) {
  ret <$1 x i8> %0
}
define internal <$1 x i16> @convertmask_i8_i86_$1(<$1 x i8>) {
  %r = sext <$1 x i8> %0 to <$1 x i16>
  ret <$1 x i16> %r
}
define internal <$1 x i32> @convertmask_i8_i32_$1(<$1 x i8>) {
  %r = sext <$1 x i8> %0 to <$1 x i32>
  ret <$1 x i32> %r
}
define internal <$1 x i64> @convertmask_i8_i64_$1(<$1 x i8>) {
  %r = sext <$1 x i8> %0 to <$1 x i64>
  ret <$1 x i64> %r
}

define internal <$1 x i8> @convertmask_i16_i8_$1(<$1 x i16>) {
  %r = trunc <$1 x i16> %0 to <$1 x i8>
  ret <$1 x i8> %r
}
define internal <$1 x i16> @convertmask_i16_i16_$1(<$1 x i16>) {
  ret <$1 x i16> %0
}
define internal <$1 x i32> @convertmask_i16_i32_$1(<$1 x i16>) {
  %r = sext <$1 x i16> %0 to <$1 x i32>
  ret <$1 x i32> %r
}
define internal <$1 x i64> @convertmask_i16_i64_$1(<$1 x i16>) {
  %r = sext <$1 x i16> %0 to <$1 x i64>
  ret <$1 x i64> %r
}

define internal <$1 x i8> @convertmask_i32_i8_$1(<$1 x i32>) {
  %r = trunc <$1 x i32> %0 to <$1 x i8>
  ret <$1 x i8> %r
}
define internal <$1 x i16> @convertmask_i32_i16_$1(<$1 x i32>) {
  %r = trunc <$1 x i32> %0 to <$1 x i16>
  ret <$1 x i16> %r
}
define internal <$1 x i32> @convertmask_i32_i32_$1(<$1 x i32>) {
  ret <$1 x i32> %0
}
define internal <$1 x i64> @convertmask_i32_i64_$1(<$1 x i32>) {
  %r = sext <$1 x i32> %0 to <$1 x i64>
  ret <$1 x i64> %r
}

define internal <$1 x i8> @convertmask_i64_i8_$1(<$1 x i64>) {
  %r = trunc <$1 x i64> %0 to <$1 x i8>
  ret <$1 x i8> %r
}
define internal <$1 x i16> @convertmask_i64_i16_$1(<$1 x i64>) {
  %r = trunc <$1 x i64> %0 to <$1 x i16>
  ret <$1 x i16> %r
}
define internal <$1 x i32> @convertmask_i64_i32_$1(<$1 x i64>) {
  %r = trunc <$1 x i64> %0 to <$1 x i32>
  ret <$1 x i32> %r
}
define internal <$1 x i64> @convertmask_i64_i64_$1(<$1 x i64>) {
  ret <$1 x i64> %0
}
')

mask_converts(WIDTH)

define(`global_atomic_associative', `

define <$1 x $3> @__atomic_$2_$4_global($3 * %ptr, <$1 x $3> %val,
                                        <$1 x MASK> %m) nounwind alwaysinline {
  ; first, for any lanes where the mask is off, compute a vector where those lanes
  ; hold the identity value..

  ; for the bit tricks below, we need the mask to have the
  ; the same element size as the element type.
  %mask = call <$1 x $3> @convertmask_`'MASK`'_$3_$1(<$1 x MASK> %m)

  ; zero out any lanes that are off
  %valoff = and <$1 x $3> %val, %mask

  ; compute an identity vector that is zero in on lanes and has the identiy value
  ; in the off lanes
  %idv1 = bitcast $3 $5 to <1 x $3>
  %idvec = shufflevector <1 x $3> %idv1, <1 x $3> undef,
     <$1 x i32> < forloop(i, 1, eval($1-1), `i32 0, ') i32 0 >
  %notmask = xor <$1 x $3> %mask, < forloop(i, 1, eval($1-1), `$3 -1, ') $3 -1 >
  %idoff = and <$1 x $3> %idvec, %notmask

  ; and comptue the merged vector that holds the identity in the off lanes
  %valp = or <$1 x $3> %valoff, %idoff

  ; now compute the local reduction (val0 op val1 op ... )--initialize
  ; %eltvec so that the 0th element is the identity, the first is val0,
  ; the second is (val0 op val1), ..
  %red0 = extractelement <$1 x $3> %valp, i32 0
  %eltvec0 = insertelement <$1 x $3> undef, $3 $5, i32 0

  forloop(i, 1, eval($1-1), `
  %elt`'i = extractelement <$1 x $3> %valp, i32 i
  %red`'i = $2 $3 %red`'eval(i-1), %elt`'i
  %eltvec`'i = insertelement <$1 x $3> %eltvec`'eval(i-1), $3 %red`'eval(i-1), i32 i')

  ; make the atomic call, passing it the final reduced value
  %final0 = atomicrmw $2 $3 * %ptr, $3 %red`'eval($1-1) seq_cst

  ; now go back and compute the values to be returned for each program
  ; instance--this just involves smearing the old value returned from the
  ; actual atomic call across the vector and applying the vector op to the
  ; %eltvec vector computed above..
  %finalv1 = bitcast $3 %final0 to <1 x $3>
  %final_base = shufflevector <1 x $3> %finalv1, <1 x $3> undef,
     <$1 x i32> < forloop(i, 1, eval($1-1), `i32 0, ') i32 0 >
  %r = $2 <$1 x $3> %final_base, %eltvec`'eval($1-1)

  ret <$1 x $3> %r
}
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; global_atomic_uniform
;; Defines the implementation of a function that handles the mapping from
;; an ispc atomic function to the underlying LLVM intrinsics.  This variant
;; just calls the atomic once, for the given uniform value
;;
;; Takes four parameters:
;; $1: vector width of the target
;; $2: operation being performed (w.r.t. LLVM atomic intrinsic names)
;;     (add, sub...)
;; $3: return type of the LLVM atomic (e.g. i32)
;; $4: return type of the LLVM atomic type, in ispc naming paralance (e.g. int32)

define(`global_atomic_uniform', `
define $3 @__atomic_$2_uniform_$4_global($3 * %ptr, $3 %val) nounwind alwaysinline {
  %r = atomicrmw $2 $3 * %ptr, $3 %val seq_cst
  ret $3 %r
}
')

;; Macro to declare the function that implements the swap atomic.
;; Takes three parameters:
;; $1: vector width of the target
;; $2: llvm type of the vector elements (e.g. i32)
;; $3: ispc type of the elements (e.g. int32)

define(`global_swap', `
define $2 @__atomic_swap_uniform_$3_global($2* %ptr, $2 %val) nounwind alwaysinline {
 %r = atomicrmw xchg $2 * %ptr, $2 %val seq_cst
 ret $2 %r
}
')


;; Similarly, macro to declare the function that implements the compare/exchange
;; atomic.  Takes three parameters:
;; $1: vector width of the target
;; $2: llvm type of the vector elements (e.g. i32)
;; $3: ispc type of the elements (e.g. int32)

define(`global_atomic_exchange', `

define <$1 x $2> @__atomic_compare_exchange_$3_global($2* %ptr, <$1 x $2> %cmp,
                               <$1 x $2> %val, <$1 x MASK> %mask) nounwind alwaysinline {
  %rptr = alloca <$1 x $2>
  %rptr32 = bitcast <$1 x $2> * %rptr to $2 *

  per_lane($1, <$1 x MASK> %mask, `
   %cmp_LANE_ID = extractelement <$1 x $2> %cmp, i32 LANE
   %val_LANE_ID = extractelement <$1 x $2> %val, i32 LANE

  ;; 3.5 - trunk code is the same since m4 has no OR and AND operators
  ifelse(LLVM_VERSION,LLVM_3_5,`
    %r_LANE_ID_t = cmpxchg $2 * %ptr, $2 %cmp_LANE_ID, $2 %val_LANE_ID seq_cst seq_cst
    %r_LANE_ID = extractvalue { $2, i1 } %r_LANE_ID_t, 0
  ',LLVM_VERSION,LLVM_3_6,`
    %r_LANE_ID_t = cmpxchg $2 * %ptr, $2 %cmp_LANE_ID, $2 %val_LANE_ID seq_cst seq_cst
    %r_LANE_ID = extractvalue { $2, i1 } %r_LANE_ID_t, 0
  ',LLVM_VERSION,LLVM_3_7,`
    %r_LANE_ID_t = cmpxchg $2 * %ptr, $2 %cmp_LANE_ID, $2 %val_LANE_ID seq_cst seq_cst
    %r_LANE_ID = extractvalue { $2, i1 } %r_LANE_ID_t, 0
  ',LLVM_VERSION,LLVM_3_8,`
    %r_LANE_ID_t = cmpxchg $2 * %ptr, $2 %cmp_LANE_ID, $2 %val_LANE_ID seq_cst seq_cst
    %r_LANE_ID = extractvalue { $2, i1 } %r_LANE_ID_t, 0
  ',LLVM_VERSION,LLVM_3_9,`
    %r_LANE_ID_t = cmpxchg $2 * %ptr, $2 %cmp_LANE_ID, $2 %val_LANE_ID seq_cst seq_cst
    %r_LANE_ID = extractvalue { $2, i1 } %r_LANE_ID_t, 0
  ',LLVM_VERSION,LLVM_4_0,`
    %r_LANE_ID_t = cmpxchg $2 * %ptr, $2 %cmp_LANE_ID, $2 %val_LANE_ID seq_cst seq_cst
    %r_LANE_ID = extractvalue { $2, i1 } %r_LANE_ID_t, 0
  ',LLVM_VERSION,LLVM_5_0,`
    %r_LANE_ID_t = cmpxchg $2 * %ptr, $2 %cmp_LANE_ID, $2 %val_LANE_ID seq_cst seq_cst
    %r_LANE_ID = extractvalue { $2, i1 } %r_LANE_ID_t, 0
  ',LLVM_VERSION,LLVM_6_0,`
    %r_LANE_ID_t = cmpxchg $2 * %ptr, $2 %cmp_LANE_ID, $2 %val_LANE_ID seq_cst seq_cst
    %r_LANE_ID = extractvalue { $2, i1 } %r_LANE_ID_t, 0
  ',LLVM_VERSION,LLVM_7_0,`
    %r_LANE_ID_t = cmpxchg $2 * %ptr, $2 %cmp_LANE_ID, $2 %val_LANE_ID seq_cst seq_cst
    %r_LANE_ID = extractvalue { $2, i1 } %r_LANE_ID_t, 0
  ',LLVM_VERSION,LLVM_7_1,`
    %r_LANE_ID_t = cmpxchg $2 * %ptr, $2 %cmp_LANE_ID, $2 %val_LANE_ID seq_cst seq_cst
    %r_LANE_ID = extractvalue { $2, i1 } %r_LANE_ID_t, 0
  ',LLVM_VERSION,LLVM_8_0,`
    %r_LANE_ID_t = cmpxchg $2 * %ptr, $2 %cmp_LANE_ID, $2 %val_LANE_ID seq_cst seq_cst
    %r_LANE_ID = extractvalue { $2, i1 } %r_LANE_ID_t, 0
  ',LLVM_VERSION,LLVM_9_0,`
    %r_LANE_ID_t = cmpxchg $2 * %ptr, $2 %cmp_LANE_ID, $2 %val_LANE_ID seq_cst seq_cst
    %r_LANE_ID = extractvalue { $2, i1 } %r_LANE_ID_t, 0
  ',`
    %r_LANE_ID = cmpxchg $2 * %ptr, $2 %cmp_LANE_ID, $2 %val_LANE_ID seq_cst
  ')
   %rp_LANE_ID = getelementptr PTR_OP_ARGS(`$2') %rptr32, i32 LANE
   store $2 %r_LANE_ID, $2 * %rp_LANE_ID')

  %r = load PTR_OP_ARGS(`<$1 x $2> ')  %rptr
  ret <$1 x $2> %r
}

define $2 @__atomic_compare_exchange_uniform_$3_global($2* %ptr, $2 %cmp,
                                                       $2 %val) nounwind alwaysinline {
  ;; 3.5 - trunk code is the same since m4 has no OR and AND operators
  ifelse(LLVM_VERSION,LLVM_3_5,`
   %r_t = cmpxchg $2 * %ptr, $2 %cmp, $2 %val seq_cst seq_cst
   %r = extractvalue { $2, i1 } %r_t, 0
  ',LLVM_VERSION,LLVM_3_6,`
   %r_t = cmpxchg $2 * %ptr, $2 %cmp, $2 %val seq_cst seq_cst
   %r = extractvalue { $2, i1 } %r_t, 0
  ',LLVM_VERSION,LLVM_3_7,`
   %r_t = cmpxchg $2 * %ptr, $2 %cmp, $2 %val seq_cst seq_cst
   %r = extractvalue { $2, i1 } %r_t, 0
  ',LLVM_VERSION,LLVM_3_8,`
   %r_t = cmpxchg $2 * %ptr, $2 %cmp, $2 %val seq_cst seq_cst
   %r = extractvalue { $2, i1 } %r_t, 0
  ',LLVM_VERSION,LLVM_3_9,`
   %r_t = cmpxchg $2 * %ptr, $2 %cmp, $2 %val seq_cst seq_cst
   %r = extractvalue { $2, i1 } %r_t, 0
  ',LLVM_VERSION,LLVM_4_0,`
   %r_t = cmpxchg $2 * %ptr, $2 %cmp, $2 %val seq_cst seq_cst
   %r = extractvalue { $2, i1 } %r_t, 0
  ',LLVM_VERSION,LLVM_5_0,`
   %r_t = cmpxchg $2 * %ptr, $2 %cmp, $2 %val seq_cst seq_cst
   %r = extractvalue { $2, i1 } %r_t, 0
  ',LLVM_VERSION,LLVM_6_0,`
   %r_t = cmpxchg $2 * %ptr, $2 %cmp, $2 %val seq_cst seq_cst
   %r = extractvalue { $2, i1 } %r_t, 0
  ',LLVM_VERSION,LLVM_7_0,`
   %r_t = cmpxchg $2 * %ptr, $2 %cmp, $2 %val seq_cst seq_cst
   %r = extractvalue { $2, i1 } %r_t, 0
  ',LLVM_VERSION,LLVM_7_1,`
   %r_t = cmpxchg $2 * %ptr, $2 %cmp, $2 %val seq_cst seq_cst
   %r = extractvalue { $2, i1 } %r_t, 0
  ',LLVM_VERSION,LLVM_8_0,`
   %r_t = cmpxchg $2 * %ptr, $2 %cmp, $2 %val seq_cst seq_cst
   %r = extractvalue { $2, i1 } %r_t, 0
  ',LLVM_VERSION,LLVM_9_0,`
   %r_t = cmpxchg $2 * %ptr, $2 %cmp, $2 %val seq_cst seq_cst
   %r = extractvalue { $2, i1 } %r_t, 0
  ',`
   %r = cmpxchg $2 * %ptr, $2 %cmp, $2 %val seq_cst
  ')
  ret $2 %r
}
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; count trailing zeros

define(`ctlztz', `
declare_count_zeros()

define i32 @__count_trailing_zeros_i32(i32) nounwind readnone alwaysinline {
  %rev = call i32 @llvm.genx.bfrev.i32 (i32 %0)
  %tz = call i32 @llvm.genx.lzd.i32 (i32 %rev)
  ret i32 %tz
}

define i64 @__count_trailing_zeros_i64(i64) nounwind readnone alwaysinline {
  %hi.init = lshr i64 %0, 32
  %hi = trunc i64 %hi.init to i32
  %lo = trunc i64 %0 to i32
  %tz.hi = call i32 @__count_trailing_zeros_i32(i32 %hi)
  %tz.lo = call i32 @__count_trailing_zeros_i32(i32 %lo)
  %use.hi = icmp eq i32 %tz.lo, 32
  %tz.hi.sel = select i1 %use.hi, i32 %tz.hi, i32 0
  %tz.32 = add i32 %tz.lo, %tz.hi.sel
  %tz = zext i32 %tz.32 to i64
  ret i64 %tz
}

define i32 @__count_leading_zeros_i32(i32) nounwind readnone alwaysinline {
  %c = call i32 @llvm.genx.lzd.i32(i32 %0)
  ret i32 %c
}

define i64 @__count_leading_zeros_i64(i64) nounwind readnone alwaysinline {
  %hi.init = lshr i64 %0, 32
  %hi = trunc i64 %hi.init to i32
  %lo = trunc i64 %0 to i32
  %lz.hi = call i32 @llvm.genx.lzd.i32(i32 %hi)
  %lz.lo = call i32 @llvm.genx.lzd.i32(i32 %lo)
  %use.lo = icmp eq i32 %lz.hi, 32
  %lz.lo.sel = select i1 %use.lo, i32 %lz.lo, i32 0
  %lz.32 = add i32 %lz.hi, %lz.lo.sel
  %lz = zext i32 %lz.32 to i64
  ret i64 %lz
}
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; prefetching

define(`define_prefetches', `
declare void @llvm.prefetch(i8* nocapture %ptr, i32 %readwrite, i32 %locality,
                            i32 %cachetype) ; cachetype == 1 is dcache

define void @__prefetch_read_uniform_1(i8 *) alwaysinline {
  call void @llvm.prefetch(i8 * %0, i32 0, i32 3, i32 1)
  ret void
}

define void @__prefetch_read_uniform_2(i8 *) alwaysinline {
  call void @llvm.prefetch(i8 * %0, i32 0, i32 2, i32 1)
  ret void
}

define void @__prefetch_read_uniform_3(i8 *) alwaysinline {
  call void @llvm.prefetch(i8 * %0, i32 0, i32 1, i32 1)
  ret void
}

define void @__prefetch_read_uniform_nt(i8 *) alwaysinline {
  call void @llvm.prefetch(i8 * %0, i32 0, i32 0, i32 1)
  ret void
}

define void @__prefetch_read_varying_1(<WIDTH x i64> %addr, <WIDTH x MASK> %mask) alwaysinline {
  per_lane(WIDTH, <WIDTH x MASK> %mask, `
  %iptr_LANE_ID = extractelement <WIDTH x i64> %addr, i32 LANE
  %ptr_LANE_ID = inttoptr i64 %iptr_LANE_ID to i8*
  call void @llvm.prefetch(i8 * %ptr_LANE_ID, i32 0, i32 3, i32 1)
  ')
  ret void
}

declare void @__prefetch_read_varying_1_native(i8 * %base, i32 %scale, <WIDTH x i32> %offsets, <WIDTH x MASK> %mask) nounwind

define void @__prefetch_read_varying_2(<WIDTH x i64> %addr, <WIDTH x MASK> %mask) alwaysinline {
  per_lane(WIDTH, <WIDTH x MASK> %mask, `
  %iptr_LANE_ID = extractelement <WIDTH x i64> %addr, i32 LANE
  %ptr_LANE_ID = inttoptr i64 %iptr_LANE_ID to i8*
  call void @llvm.prefetch(i8 * %ptr_LANE_ID, i32 0, i32 2, i32 1)
  ')
  ret void
}

declare void @__prefetch_read_varying_2_native(i8 * %base, i32 %scale, <WIDTH x i32> %offsets, <WIDTH x MASK> %mask) nounwind

define void @__prefetch_read_varying_3(<WIDTH x i64> %addr, <WIDTH x MASK> %mask) alwaysinline {
  per_lane(WIDTH, <WIDTH x MASK> %mask, `
  %iptr_LANE_ID = extractelement <WIDTH x i64> %addr, i32 LANE
  %ptr_LANE_ID = inttoptr i64 %iptr_LANE_ID to i8*
  call void @llvm.prefetch(i8 * %ptr_LANE_ID, i32 0, i32 1, i32 1)
  ')
  ret void
}

declare void @__prefetch_read_varying_3_native(i8 * %base, i32 %scale, <WIDTH x i32> %offsets, <WIDTH x MASK> %mask) nounwind

define void @__prefetch_read_varying_nt(<WIDTH x i64> %addr, <WIDTH x MASK> %mask) alwaysinline {
  per_lane(WIDTH, <WIDTH x MASK> %mask, `
  %iptr_LANE_ID = extractelement <WIDTH x i64> %addr, i32 LANE
  %ptr_LANE_ID = inttoptr i64 %iptr_LANE_ID to i8*
  call void @llvm.prefetch(i8 * %ptr_LANE_ID, i32 0, i32 0, i32 1)
  ')
  ret void
}

declare void @__prefetch_read_varying_nt_native(i8 * %base, i32 %scale, <WIDTH x i32> %offsets, <WIDTH x MASK> %mask) nounwind
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; AOS/SOA conversion primitives

;; take 4 4-wide vectors laid out like <r0 g0 b0 a0> <r1 g1 b1 a1> ...
;; and reorder them to <r0 r1 r2 r3> <g0 g1 g2 g3> ...

define(`aossoa', `define void
@__aos_to_soa4_float4(<4 x float> %v0, <4 x float> %v1, <4 x float> %v2,
        <4 x float> %v3, <4 x float> * noalias %out0,
        <4 x float> * noalias %out1, <4 x float> * noalias %out2,
        <4 x float> * noalias %out3) nounwind alwaysinline {
  %t0 = shufflevector <4 x float> %v2, <4 x float> %v3,  ; r2 r3 g2 g3
          <4 x i32> <i32 0, i32 4, i32 1, i32 5>
  %t1 = shufflevector <4 x float> %v2, <4 x float> %v3,  ; b2 b3 a2 a3
          <4 x i32> <i32 2, i32 6, i32 3, i32 7>
  %t2 = shufflevector <4 x float> %v0, <4 x float> %v1,  ; r0 r1 g0 g1
          <4 x i32> <i32 0, i32 4, i32 1, i32 5>
  %t3 = shufflevector <4 x float> %v0, <4 x float> %v1,  ; b0 b1 a0 a1
          <4 x i32> <i32 2, i32 6, i32 3, i32 7>

  %r0 = shufflevector <4 x float> %t2, <4 x float> %t0,  ; r0 r1 r2 r3
          <4 x i32> <i32 0, i32 1, i32 4, i32 5>
  store <4 x float> %r0, <4 x float> * %out0
  %r1 = shufflevector <4 x float> %t2, <4 x float> %t0,  ; g0 g1 g2 g3
          <4 x i32> <i32 2, i32 3, i32 6, i32 7>
  store <4 x float> %r1, <4 x float> * %out1
  %r2 = shufflevector <4 x float> %t3, <4 x float> %t1,  ; b0 b1 b2 b3
          <4 x i32> <i32 0, i32 1, i32 4, i32 5>
  store <4 x float> %r2, <4 x float> * %out2
  %r3 = shufflevector <4 x float> %t3, <4 x float> %t1,  ; a0 a1 a2 a3
          <4 x i32> <i32 2, i32 3, i32 6, i32 7>
  store <4 x float> %r3, <4 x float> * %out3
  ret void
}


;; Do the reverse of __aos_to_soa4_float4--reorder <r0 r1 r2 r3> <g0 g1 g2 g3> ..
;; to <r0 g0 b0 a0> <r1 g1 b1 a1> ...
;; This is the exact same set of operations that __soa_to_soa4_float4 does
;; (a 4x4 transpose), so just call that...

define void
@__soa_to_aos4_float4(<4 x float> %v0, <4 x float> %v1, <4 x float> %v2,
        <4 x float> %v3, <4 x float> * noalias %out0,
        <4 x float> * noalias %out1, <4 x float> * noalias %out2,
        <4 x float> * noalias %out3) nounwind alwaysinline {
  call void @__aos_to_soa4_float4(<4 x float> %v0, <4 x float> %v1,
    <4 x float> %v2, <4 x float> %v3, <4 x float> * %out0,
    <4 x float> * %out1, <4 x float> * %out2, <4 x float> * %out3)
  ret void
}

define void
@__aos_to_soa4_double4(<4 x double> %v0, <4 x double> %v1, <4 x double> %v2,
        <4 x double> %v3, <4 x double> * noalias %out0,
        <4 x double> * noalias %out1, <4 x double> * noalias %out2,
        <4 x double> * noalias %out3) nounwind alwaysinline {
  %t0 = shufflevector <4 x double> %v2, <4 x double> %v3,  ; r2 r3 g2 g3
          <4 x i32> <i32 0, i32 4, i32 1, i32 5>
  %t1 = shufflevector <4 x double> %v2, <4 x double> %v3,  ; b2 b3 a2 a3
          <4 x i32> <i32 2, i32 6, i32 3, i32 7>
  %t2 = shufflevector <4 x double> %v0, <4 x double> %v1,  ; r0 r1 g0 g1
          <4 x i32> <i32 0, i32 4, i32 1, i32 5>
  %t3 = shufflevector <4 x double> %v0, <4 x double> %v1,  ; b0 b1 a0 a1
          <4 x i32> <i32 2, i32 6, i32 3, i32 7>

  %r0 = shufflevector <4 x double> %t2, <4 x double> %t0,  ; r0 r1 r2 r3
          <4 x i32> <i32 0, i32 1, i32 4, i32 5>
  store <4 x double> %r0, <4 x double> * %out0
  %r1 = shufflevector <4 x double> %t2, <4 x double> %t0,  ; g0 g1 g2 g3
          <4 x i32> <i32 2, i32 3, i32 6, i32 7>
  store <4 x double> %r1, <4 x double> * %out1
  %r2 = shufflevector <4 x double> %t3, <4 x double> %t1,  ; b0 b1 b2 b3
          <4 x i32> <i32 0, i32 1, i32 4, i32 5>
  store <4 x double> %r2, <4 x double> * %out2
  %r3 = shufflevector <4 x double> %t3, <4 x double> %t1,  ; a0 a1 a2 a3
          <4 x i32> <i32 2, i32 3, i32 6, i32 7>
  store <4 x double> %r3, <4 x double> * %out3
  ret void
}

;; Do the reverse of __aos_to_soa4_double4--reorder <r0 r1 r2 r3> <g0 g1 g2 g3> ..
;; to <r0 g0 b0 a0> <r1 g1 b1 a1> ...
;; This is the exact same set of operations that __soa_to_soa4_double4 does
;; (a 4x4 transpose), so just call that...

define void
@__soa_to_aos4_double4(<4 x double> %v0, <4 x double> %v1, <4 x double> %v2,
        <4 x double> %v3, <4 x double> * noalias %out0,
        <4 x double> * noalias %out1, <4 x double> * noalias %out2,
        <4 x double> * noalias %out3) nounwind alwaysinline {
  call void @__aos_to_soa4_double4(<4 x double> %v0, <4 x double> %v1,
    <4 x double> %v2, <4 x double> %v3, <4 x double> * %out0,
    <4 x double> * %out1, <4 x double> * %out2, <4 x double> * %out3)
  ret void
}

;; Convert 3-wide AOS values to SOA--specifically, given 3 4-vectors
;; <x0 y0 z0 x1> <y1 z1 x2 y2> <z2 x3 y3 z3>, transpose to
;; <x0 x1 x2 x3> <y0 y1 y2 y3> <z0 z1 z2 z3>.

define void
@__aos_to_soa3_float4(<4 x float> %v0, <4 x float> %v1, <4 x float> %v2,
        <4 x float> * noalias %out0, <4 x float> * noalias %out1,
        <4 x float> * noalias %out2) nounwind alwaysinline {
  %t0 = shufflevector <4 x float> %v0, <4 x float> %v1, ; x0 x1 y0 y1
    <4 x i32> <i32 0, i32 3, i32 1, i32 4>
  %t1 = shufflevector <4 x float> %v1, <4 x float> %v2, ; x2 x3 y2 y3
    <4 x i32> <i32 2, i32 5, i32 3, i32 6>

  %r0 = shufflevector <4 x float> %t0, <4 x float> %t1, ; x0 x1 x1 x3
    <4 x i32> <i32 0, i32 1, i32 4, i32 5>
  store <4 x float> %r0, <4 x float> * %out0

  %r1 = shufflevector <4 x float> %t0, <4 x float> %t1, ; y0 y1 y2 y3
    <4 x i32> <i32 2, i32 3, i32 6, i32 7>
  store <4 x float> %r1, <4 x float> * %out1

  %t2 = shufflevector <4 x float> %v0, <4 x float> %v1, ; z0 z1 x x
    <4 x i32> <i32 2, i32 5, i32 undef, i32 undef>

  %r2 = shufflevector <4 x float> %t2, <4 x float> %v2, ; z0 z1 z2 z3
    <4 x i32> <i32 0, i32 1, i32 4, i32 7>
  store <4 x float> %r2, <4 x float> * %out2
  ret void
}


;; The inverse of __aos_to_soa3_float4: convert 3 4-vectors
;; <x0 x1 x2 x3> <y0 y1 y2 y3> <z0 z1 z2 z3> to
;; <x0 y0 z0 x1> <y1 z1 x2 y2> <z2 x3 y3 z3>.

define void
@__soa_to_aos3_float4(<4 x float> %v0, <4 x float> %v1, <4 x float> %v2,
        <4 x float> * noalias %out0, <4 x float> * noalias %out1,
        <4 x float> * noalias %out2) nounwind alwaysinline {
  %t0 = shufflevector <4 x float> %v0, <4 x float> %v1, ; x0 x1 x2 y0
    <4 x i32> <i32 0, i32 1, i32 2, i32 4>
  %t1 = shufflevector <4 x float> %v1, <4 x float> %v2, ; y1 y2 z0 z1
    <4 x i32> <i32 1, i32 2, i32 4, i32 5>

  %r0 = shufflevector <4 x float> %t0, <4 x float> %t1, ; x0 y0 z0 x1
    <4 x i32> <i32 0, i32 3, i32 6, i32 1>
  store <4 x float> %r0, <4 x float> * %out0
  %r1 = shufflevector <4 x float> %t0, <4 x float> %t1, ; y1 z1 x2 y2
    <4 x i32> <i32 4, i32 7, i32 2, i32 5>
  store <4 x float> %r1, <4 x float> * %out1

  %t2 = shufflevector <4 x float> %v0, <4 x float> %v1, ; x3 y3 x x
    <4 x i32> <i32 3, i32 7, i32 undef, i32 undef>

  %r2 = shufflevector <4 x float> %t2, <4 x float> %v2, ; z2 x3 y3 z3
    <4 x i32> <i32 6, i32 0, i32 1, i32 7>
  store <4 x float> %r2, <4 x float> * %out2
  ret void
}

define void
@__aos_to_soa3_double4(<4 x double> %v0, <4 x double> %v1, <4 x double> %v2,
        <4 x double> * noalias %out0, <4 x double> * noalias %out1,
        <4 x double> * noalias %out2) nounwind alwaysinline {
  %t0 = shufflevector <4 x double> %v0, <4 x double> %v1, ; x0 x1 y0 y1
    <4 x i32> <i32 0, i32 3, i32 1, i32 4>
  %t1 = shufflevector <4 x double> %v1, <4 x double> %v2, ; x2 x3 y2 y3
    <4 x i32> <i32 2, i32 5, i32 3, i32 6>

  %r0 = shufflevector <4 x double> %t0, <4 x double> %t1, ; x0 x1 x1 x3
    <4 x i32> <i32 0, i32 1, i32 4, i32 5>
  store <4 x double> %r0, <4 x double> * %out0

  %r1 = shufflevector <4 x double> %t0, <4 x double> %t1, ; y0 y1 y2 y3
    <4 x i32> <i32 2, i32 3, i32 6, i32 7>
  store <4 x double> %r1, <4 x double> * %out1

  %t2 = shufflevector <4 x double> %v0, <4 x double> %v1, ; z0 z1 x x
    <4 x i32> <i32 2, i32 5, i32 undef, i32 undef>

  %r2 = shufflevector <4 x double> %t2, <4 x double> %v2, ; z0 z1 z2 z3
    <4 x i32> <i32 0, i32 1, i32 4, i32 7>
  store <4 x double> %r2, <4 x double> * %out2
  ret void
}

define void
@__soa_to_aos3_double4(<4 x double> %v0, <4 x double> %v1, <4 x double> %v2,
        <4 x double> * noalias %out0, <4 x double> * noalias %out1,
        <4 x double> * noalias %out2) nounwind alwaysinline {
  %t0 = shufflevector <4 x double> %v0, <4 x double> %v1, ; x0 x1 x2 y0
    <4 x i32> <i32 0, i32 1, i32 2, i32 4>
  %t1 = shufflevector <4 x double> %v1, <4 x double> %v2, ; y1 y2 z0 z1
    <4 x i32> <i32 1, i32 2, i32 4, i32 5>

  %r0 = shufflevector <4 x double> %t0, <4 x double> %t1, ; x0 y0 z0 x1
    <4 x i32> <i32 0, i32 3, i32 6, i32 1>
  store <4 x double> %r0, <4 x double> * %out0
  %r1 = shufflevector <4 x double> %t0, <4 x double> %t1, ; y1 z1 x2 y2
    <4 x i32> <i32 4, i32 7, i32 2, i32 5>
  store <4 x double> %r1, <4 x double> * %out1

  %t2 = shufflevector <4 x double> %v0, <4 x double> %v1, ; x3 y3 x x
    <4 x i32> <i32 3, i32 7, i32 undef, i32 undef>

  %r2 = shufflevector <4 x double> %t2, <4 x double> %v2, ; z2 x3 y3 z3
    <4 x i32> <i32 6, i32 0, i32 1, i32 7>
  store <4 x double> %r2, <4 x double> * %out2
  ret void
}

;; 8-wide
;; These functions implement the 8-wide variants of the AOS/SOA conversion
;; routines above.  These implementations are all built on top of the 4-wide
;; vector versions.

define void
@__aos_to_soa4_float8(<8 x float> %v0, <8 x float> %v1, <8 x float> %v2,
        <8 x float> %v3, <8 x float> * noalias %out0,
        <8 x float> * noalias %out1, <8 x float> * noalias %out2,
        <8 x float> * noalias %out3) nounwind alwaysinline {
  ;; Split each 8-vector into 2 4-vectors
  %v0a = shufflevector <8 x float> %v0, <8 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v0b = shufflevector <8 x float> %v0, <8 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v1a = shufflevector <8 x float> %v1, <8 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v1b = shufflevector <8 x float> %v1, <8 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v2a = shufflevector <8 x float> %v2, <8 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v2b = shufflevector <8 x float> %v2, <8 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v3a = shufflevector <8 x float> %v3, <8 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v3b = shufflevector <8 x float> %v3, <8 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>

  ;; Similarly for the output pointers
  %out0a = bitcast <8 x float> * %out0 to <4 x float> *
  %out0b = getelementptr PTR_OP_ARGS(`<4 x float>') %out0a, i32 1
  %out1a = bitcast <8 x float> * %out1 to <4 x float> *
  %out1b = getelementptr PTR_OP_ARGS(`<4 x float>') %out1a, i32 1
  %out2a = bitcast <8 x float> * %out2 to <4 x float> *
  %out2b = getelementptr PTR_OP_ARGS(`<4 x float>') %out2a, i32 1
  %out3a = bitcast <8 x float> * %out3 to <4 x float> *
  %out3b = getelementptr PTR_OP_ARGS(`<4 x float>') %out3a, i32 1

  ;; Do the first part--given input vectors like
  ;; <x0 y0 z0 x1 y1 z1 x2 y2> <z2 x3 y3 z3 x4 y4 z4 x5> <y5 z5 x6 y6 z6 x7 y7 z7>,
  ;; pass 3 4-vectors <x0 y0 z0 x1> <y1 z1 x2 y2> <z2 z3 y3 z3> to the 4-vec
  ;; version to compute the first 4 SOA values for the three output variables.
  call void @__aos_to_soa4_float4(<4 x float> %v0a, <4 x float> %v0b,
         <4 x float> %v1a, <4 x float> %v1b, <4 x float> * %out0a,
         <4 x float> * %out1a, <4 x float> * %out2a, <4 x float> * %out3a)

  ;; And similarly pass <x4 y4 z4 x5> <y5 z5 x6 y6> <z6 x7 y7 z7> to the 4-wide
  ;; version to compute the second 4 SOA values for the three outputs
  call void @__aos_to_soa4_float4(<4 x float> %v2a, <4 x float> %v2b,
         <4 x float> %v3a, <4 x float> %v3b, <4 x float> * %out0b,
         <4 x float> * %out1b, <4 x float> * %out2b, <4 x float> * %out3b)
  ret void
}


define void
@__soa_to_aos4_float8(<8 x float> %v0, <8 x float> %v1, <8 x float> %v2,
        <8 x float> %v3, <8 x float> * noalias %out0,
        <8 x float> * noalias %out1, <8 x float> * noalias %out2,
        <8 x float> * noalias %out3) nounwind alwaysinline {
  ;; As above, split into 4-vectors and 4-wide outputs...
  %v0a = shufflevector <8 x float> %v0, <8 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v0b = shufflevector <8 x float> %v0, <8 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v1a = shufflevector <8 x float> %v1, <8 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v1b = shufflevector <8 x float> %v1, <8 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v2a = shufflevector <8 x float> %v2, <8 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v2b = shufflevector <8 x float> %v2, <8 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v3a = shufflevector <8 x float> %v3, <8 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v3b = shufflevector <8 x float> %v3, <8 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>

  %out0a = bitcast <8 x float> * %out0 to <4 x float> *
  %out0b = getelementptr PTR_OP_ARGS(`<4 x float>') %out0a, i32 1
  %out1a = bitcast <8 x float> * %out1 to <4 x float> *
  %out1b = getelementptr PTR_OP_ARGS(`<4 x float>') %out1a, i32 1
  %out2a = bitcast <8 x float> * %out2 to <4 x float> *
  %out2b = getelementptr PTR_OP_ARGS(`<4 x float>') %out2a, i32 1
  %out3a = bitcast <8 x float> * %out3 to <4 x float> *
  %out3b = getelementptr PTR_OP_ARGS(`<4 x float>') %out3a, i32 1

  ;; First part--given input vectors
  ;; <x0 x1 x2 x3 x4 x5 x6 x7> <y0 y1 y2 y3 y4 y5 y6 y7> <z0 z1 z2 z3 z4 z5 z6 z7>
  ;; pass 3 4-vectors <x0 x1 x2 x3> <y0 y1 y2 y3> <z0 z1 z2 z3> to
  ;; compute the first 12 AOS output values.
  call void @__soa_to_aos4_float4(<4 x float> %v0a, <4 x float> %v1a,
         <4 x float> %v2a, <4 x float> %v3a, <4 x float> * %out0a,
         <4 x float> * %out0b, <4 x float> * %out1a, <4 x float> * %out1b)

  ;; And then pass the 3 4-vectors <x4 x5 x6 x7> <y4 y5 y6 y7> <z4 z5 z6 z7>
  ;; To compute the next 12 AOS output values
  call void @__soa_to_aos4_float4(<4 x float> %v0b, <4 x float> %v1b,
         <4 x float> %v2b, <4 x float> %v3b, <4 x float> * %out2a,
         <4 x float> * %out2b, <4 x float> * %out3a, <4 x float> * %out3b)
  ret void
}

define void
@__aos_to_soa4_double8(<8 x double> %v0, <8 x double> %v1, <8 x double> %v2,
        <8 x double> %v3, <8 x double> * noalias %out0,
        <8 x double> * noalias %out1, <8 x double> * noalias %out2,
        <8 x double> * noalias %out3) nounwind alwaysinline {
  ;; Split each 8-vector into 2 4-vectors
  %v0a = shufflevector <8 x double> %v0, <8 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v0b = shufflevector <8 x double> %v0, <8 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v1a = shufflevector <8 x double> %v1, <8 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v1b = shufflevector <8 x double> %v1, <8 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v2a = shufflevector <8 x double> %v2, <8 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v2b = shufflevector <8 x double> %v2, <8 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v3a = shufflevector <8 x double> %v3, <8 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v3b = shufflevector <8 x double> %v3, <8 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>

  ;; Similarly for the output pointers
  %out0a = bitcast <8 x double> * %out0 to <4 x double> *
  %out0b = getelementptr PTR_OP_ARGS(`<4 x double>') %out0a, i32 1
  %out1a = bitcast <8 x double> * %out1 to <4 x double> *
  %out1b = getelementptr PTR_OP_ARGS(`<4 x double>') %out1a, i32 1
  %out2a = bitcast <8 x double> * %out2 to <4 x double> *
  %out2b = getelementptr PTR_OP_ARGS(`<4 x double>') %out2a, i32 1
  %out3a = bitcast <8 x double> * %out3 to <4 x double> *
  %out3b = getelementptr PTR_OP_ARGS(`<4 x double>') %out3a, i32 1

  ;; Do the first part--given input vectors like
  ;; <x0 y0 z0 x1 y1 z1 x2 y2> <z2 x3 y3 z3 x4 y4 z4 x5> <y5 z5 x6 y6 z6 x7 y7 z7>,
  ;; pass 3 4-vectors <x0 y0 z0 x1> <y1 z1 x2 y2> <z2 z3 y3 z3> to the 4-vec
  ;; version to compute the first 4 SOA values for the three output variables.
  call void @__aos_to_soa4_double4(<4 x double> %v0a, <4 x double> %v0b,
         <4 x double> %v1a, <4 x double> %v1b, <4 x double> * %out0a,
         <4 x double> * %out1a, <4 x double> * %out2a, <4 x double> * %out3a)

  ;; And similarly pass <x4 y4 z4 x5> <y5 z5 x6 y6> <z6 x7 y7 z7> to the 4-wide
  ;; version to compute the second 4 SOA values for the three outputs
  call void @__aos_to_soa4_double4(<4 x double> %v2a, <4 x double> %v2b,
         <4 x double> %v3a, <4 x double> %v3b, <4 x double> * %out0b,
         <4 x double> * %out1b, <4 x double> * %out2b, <4 x double> * %out3b)
  ret void
}

define void
@__soa_to_aos4_double8(<8 x double> %v0, <8 x double> %v1, <8 x double> %v2,
        <8 x double> %v3, <8 x double> * noalias %out0,
        <8 x double> * noalias %out1, <8 x double> * noalias %out2,
        <8 x double> * noalias %out3) nounwind alwaysinline {
  ;; As above, split into 4-vectors and 4-wide outputs...
  %v0a = shufflevector <8 x double> %v0, <8 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v0b = shufflevector <8 x double> %v0, <8 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v1a = shufflevector <8 x double> %v1, <8 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v1b = shufflevector <8 x double> %v1, <8 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v2a = shufflevector <8 x double> %v2, <8 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v2b = shufflevector <8 x double> %v2, <8 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v3a = shufflevector <8 x double> %v3, <8 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v3b = shufflevector <8 x double> %v3, <8 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>

  %out0a = bitcast <8 x double> * %out0 to <4 x double> *
  %out0b = getelementptr PTR_OP_ARGS(`<4 x double>') %out0a, i32 1
  %out1a = bitcast <8 x double> * %out1 to <4 x double> *
  %out1b = getelementptr PTR_OP_ARGS(`<4 x double>') %out1a, i32 1
  %out2a = bitcast <8 x double> * %out2 to <4 x double> *
  %out2b = getelementptr PTR_OP_ARGS(`<4 x double>') %out2a, i32 1
  %out3a = bitcast <8 x double> * %out3 to <4 x double> *
  %out3b = getelementptr PTR_OP_ARGS(`<4 x double>') %out3a, i32 1

  ;; First part--given input vectors
  ;; <x0 x1 x2 x3 x4 x5 x6 x7> <y0 y1 y2 y3 y4 y5 y6 y7> <z0 z1 z2 z3 z4 z5 z6 z7>
  ;; pass 3 4-vectors <x0 x1 x2 x3> <y0 y1 y2 y3> <z0 z1 z2 z3> to
  ;; compute the first 12 AOS output values.
  call void @__soa_to_aos4_double4(<4 x double> %v0a, <4 x double> %v1a,
         <4 x double> %v2a, <4 x double> %v3a, <4 x double> * %out0a,
         <4 x double> * %out0b, <4 x double> * %out1a, <4 x double> * %out1b)

  ;; And then pass the 3 4-vectors <x4 x5 x6 x7> <y4 y5 y6 y7> <z4 z5 z6 z7>
  ;; To compute the next 12 AOS output values
  call void @__soa_to_aos4_double4(<4 x double> %v0b, <4 x double> %v1b,
         <4 x double> %v2b, <4 x double> %v3b, <4 x double> * %out2a,
         <4 x double> * %out2b, <4 x double> * %out3a, <4 x double> * %out3b)
  ret void
}

define void
@__aos_to_soa3_float8(<8 x float> %v0, <8 x float> %v1, <8 x float> %v2,
        <8 x float> * noalias %out0, <8 x float> * noalias %out1,
        <8 x float> * noalias %out2) nounwind alwaysinline {
  %v0a = shufflevector <8 x float> %v0, <8 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v0b = shufflevector <8 x float> %v0, <8 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v1a = shufflevector <8 x float> %v1, <8 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v1b = shufflevector <8 x float> %v1, <8 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v2a = shufflevector <8 x float> %v2, <8 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v2b = shufflevector <8 x float> %v2, <8 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>

  %out0a = bitcast <8 x float> * %out0 to <4 x float> *
  %out0b = getelementptr PTR_OP_ARGS(`<4 x float>') %out0a, i32 1
  %out1a = bitcast <8 x float> * %out1 to <4 x float> *
  %out1b = getelementptr PTR_OP_ARGS(`<4 x float>') %out1a, i32 1
  %out2a = bitcast <8 x float> * %out2 to <4 x float> *
  %out2b = getelementptr PTR_OP_ARGS(`<4 x float>') %out2a, i32 1

  call void @__aos_to_soa3_float4(<4 x float> %v0a, <4 x float> %v0b,
         <4 x float> %v1a, <4 x float> * %out0a, <4 x float> * %out1a,
         <4 x float> * %out2a)
  call void @__aos_to_soa3_float4(<4 x float> %v1b, <4 x float> %v2a,
         <4 x float> %v2b, <4 x float> * %out0b, <4 x float> * %out1b,
         <4 x float> * %out2b)
  ret void
}


define void
@__soa_to_aos3_float8(<8 x float> %v0, <8 x float> %v1, <8 x float> %v2,
        <8 x float> * noalias %out0, <8 x float> * noalias %out1,
        <8 x float> * noalias %out2) nounwind alwaysinline {
  %v0a = shufflevector <8 x float> %v0, <8 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v0b = shufflevector <8 x float> %v0, <8 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v1a = shufflevector <8 x float> %v1, <8 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v1b = shufflevector <8 x float> %v1, <8 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v2a = shufflevector <8 x float> %v2, <8 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v2b = shufflevector <8 x float> %v2, <8 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>

  %out0a = bitcast <8 x float> * %out0 to <4 x float> *
  %out0b = getelementptr PTR_OP_ARGS(`<4 x float>') %out0a, i32 1
  %out1a = bitcast <8 x float> * %out1 to <4 x float> *
  %out1b = getelementptr PTR_OP_ARGS(`<4 x float>') %out1a, i32 1
  %out2a = bitcast <8 x float> * %out2 to <4 x float> *
  %out2b = getelementptr PTR_OP_ARGS(`<4 x float>') %out2a, i32 1

  call void @__soa_to_aos3_float4(<4 x float> %v0a, <4 x float> %v1a,
         <4 x float> %v2a, <4 x float> * %out0a, <4 x float> * %out0b,
         <4 x float> * %out1a)
  call void @__soa_to_aos3_float4(<4 x float> %v0b, <4 x float> %v1b,
         <4 x float> %v2b, <4 x float> * %out1b, <4 x float> * %out2a,
         <4 x float> * %out2b)
  ret void
}


define void
@__aos_to_soa3_double8(<8 x double> %v0, <8 x double> %v1, <8 x double> %v2,
        <8 x double> * noalias %out0, <8 x double> * noalias %out1,
        <8 x double> * noalias %out2) nounwind alwaysinline {
  %v0a = shufflevector <8 x double> %v0, <8 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v0b = shufflevector <8 x double> %v0, <8 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v1a = shufflevector <8 x double> %v1, <8 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v1b = shufflevector <8 x double> %v1, <8 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v2a = shufflevector <8 x double> %v2, <8 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v2b = shufflevector <8 x double> %v2, <8 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>

  %out0a = bitcast <8 x double> * %out0 to <4 x double> *
  %out0b = getelementptr PTR_OP_ARGS(`<4 x double>') %out0a, i32 1
  %out1a = bitcast <8 x double> * %out1 to <4 x double> *
  %out1b = getelementptr PTR_OP_ARGS(`<4 x double>') %out1a, i32 1
  %out2a = bitcast <8 x double> * %out2 to <4 x double> *
  %out2b = getelementptr PTR_OP_ARGS(`<4 x double>') %out2a, i32 1

  call void @__aos_to_soa3_double4(<4 x double> %v0a, <4 x double> %v0b,
         <4 x double> %v1a, <4 x double> * %out0a, <4 x double> * %out1a,
         <4 x double> * %out2a)
  call void @__aos_to_soa3_double4(<4 x double> %v1b, <4 x double> %v2a,
         <4 x double> %v2b, <4 x double> * %out0b, <4 x double> * %out1b,
         <4 x double> * %out2b)
  ret void
}


define void
@__soa_to_aos3_double8(<8 x double> %v0, <8 x double> %v1, <8 x double> %v2,
        <8 x double> * noalias %out0, <8 x double> * noalias %out1,
        <8 x double> * noalias %out2) nounwind alwaysinline {
  %v0a = shufflevector <8 x double> %v0, <8 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v0b = shufflevector <8 x double> %v0, <8 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v1a = shufflevector <8 x double> %v1, <8 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v1b = shufflevector <8 x double> %v1, <8 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v2a = shufflevector <8 x double> %v2, <8 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v2b = shufflevector <8 x double> %v2, <8 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>

  %out0a = bitcast <8 x double> * %out0 to <4 x double> *
  %out0b = getelementptr PTR_OP_ARGS(`<4 x double>') %out0a, i32 1
  %out1a = bitcast <8 x double> * %out1 to <4 x double> *
  %out1b = getelementptr PTR_OP_ARGS(`<4 x double>') %out1a, i32 1
  %out2a = bitcast <8 x double> * %out2 to <4 x double> *
  %out2b = getelementptr PTR_OP_ARGS(`<4 x double>') %out2a, i32 1

  call void @__soa_to_aos3_double4(<4 x double> %v0a, <4 x double> %v1a,
         <4 x double> %v2a, <4 x double> * %out0a, <4 x double> * %out0b,
         <4 x double> * %out1a)
  call void @__soa_to_aos3_double4(<4 x double> %v0b, <4 x double> %v1b,
         <4 x double> %v2b, <4 x double> * %out1b, <4 x double> * %out2a,
         <4 x double> * %out2b)
  ret void
}

;; 16-wide

define void
@__aos_to_soa4_float16(<16 x float> %v0, <16 x float> %v1, <16 x float> %v2,
        <16 x float> %v3, <16 x float> * noalias %out0,
        <16 x float> * noalias %out1, <16 x float> * noalias %out2,
        <16 x float> * noalias %out3) nounwind alwaysinline {
  %v0a = shufflevector <16 x float> %v0, <16 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v0b = shufflevector <16 x float> %v0, <16 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v0c = shufflevector <16 x float> %v0, <16 x float> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v0d = shufflevector <16 x float> %v0, <16 x float> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v1a = shufflevector <16 x float> %v1, <16 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v1b = shufflevector <16 x float> %v1, <16 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v1c = shufflevector <16 x float> %v1, <16 x float> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v1d = shufflevector <16 x float> %v1, <16 x float> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v2a = shufflevector <16 x float> %v2, <16 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v2b = shufflevector <16 x float> %v2, <16 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v2c = shufflevector <16 x float> %v2, <16 x float> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v2d = shufflevector <16 x float> %v2, <16 x float> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v3a = shufflevector <16 x float> %v3, <16 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v3b = shufflevector <16 x float> %v3, <16 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v3c = shufflevector <16 x float> %v3, <16 x float> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v3d = shufflevector <16 x float> %v3, <16 x float> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>

  %out0a = bitcast <16 x float> * %out0 to <4 x float> *
  %out0b = getelementptr PTR_OP_ARGS(`<4 x float>') %out0a, i32 1
  %out0c = getelementptr PTR_OP_ARGS(`<4 x float>') %out0a, i32 2
  %out0d = getelementptr PTR_OP_ARGS(`<4 x float>') %out0a, i32 3
  %out1a = bitcast <16 x float> * %out1 to <4 x float> *
  %out1b = getelementptr PTR_OP_ARGS(`<4 x float>') %out1a, i32 1
  %out1c = getelementptr PTR_OP_ARGS(`<4 x float>') %out1a, i32 2
  %out1d = getelementptr PTR_OP_ARGS(`<4 x float>') %out1a, i32 3
  %out2a = bitcast <16 x float> * %out2 to <4 x float> *
  %out2b = getelementptr PTR_OP_ARGS(`<4 x float>') %out2a, i32 1
  %out2c = getelementptr PTR_OP_ARGS(`<4 x float>') %out2a, i32 2
  %out2d = getelementptr PTR_OP_ARGS(`<4 x float>') %out2a, i32 3
  %out3a = bitcast <16 x float> * %out3 to <4 x float> *
  %out3b = getelementptr PTR_OP_ARGS(`<4 x float>') %out3a, i32 1
  %out3c = getelementptr PTR_OP_ARGS(`<4 x float>') %out3a, i32 2
  %out3d = getelementptr PTR_OP_ARGS(`<4 x float>') %out3a, i32 3

  call void @__aos_to_soa4_float4(<4 x float> %v0a, <4 x float> %v0b,
         <4 x float> %v0c, <4 x float> %v0d, <4 x float> * %out0a,
         <4 x float> * %out1a, <4 x float> * %out2a, <4 x float> * %out3a)
  call void @__aos_to_soa4_float4(<4 x float> %v1a, <4 x float> %v1b,
         <4 x float> %v1c, <4 x float> %v1d, <4 x float> * %out0b,
         <4 x float> * %out1b, <4 x float> * %out2b, <4 x float> * %out3b)
  call void @__aos_to_soa4_float4(<4 x float> %v2a, <4 x float> %v2b,
         <4 x float> %v2c, <4 x float> %v2d, <4 x float> * %out0c,
         <4 x float> * %out1c, <4 x float> * %out2c, <4 x float> * %out3c)
  call void @__aos_to_soa4_float4(<4 x float> %v3a, <4 x float> %v3b,
         <4 x float> %v3c, <4 x float> %v3d, <4 x float> * %out0d,
         <4 x float> * %out1d, <4 x float> * %out2d, <4 x float> * %out3d)
  ret void
}


define void
@__soa_to_aos4_float16(<16 x float> %v0, <16 x float> %v1, <16 x float> %v2,
        <16 x float> %v3, <16 x float> * noalias %out0,
        <16 x float> * noalias %out1, <16 x float> * noalias %out2,
        <16 x float> * noalias %out3) nounwind alwaysinline {
  %v0a = shufflevector <16 x float> %v0, <16 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v0b = shufflevector <16 x float> %v0, <16 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v0c = shufflevector <16 x float> %v0, <16 x float> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v0d = shufflevector <16 x float> %v0, <16 x float> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v1a = shufflevector <16 x float> %v1, <16 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v1b = shufflevector <16 x float> %v1, <16 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v1c = shufflevector <16 x float> %v1, <16 x float> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v1d = shufflevector <16 x float> %v1, <16 x float> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v2a = shufflevector <16 x float> %v2, <16 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v2b = shufflevector <16 x float> %v2, <16 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v2c = shufflevector <16 x float> %v2, <16 x float> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v2d = shufflevector <16 x float> %v2, <16 x float> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v3a = shufflevector <16 x float> %v3, <16 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v3b = shufflevector <16 x float> %v3, <16 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v3c = shufflevector <16 x float> %v3, <16 x float> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v3d = shufflevector <16 x float> %v3, <16 x float> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>

  %out0a = bitcast <16 x float> * %out0 to <4 x float> *
  %out0b = getelementptr PTR_OP_ARGS(`<4 x float>') %out0a, i32 1
  %out0c = getelementptr PTR_OP_ARGS(`<4 x float>') %out0a, i32 2
  %out0d = getelementptr PTR_OP_ARGS(`<4 x float>') %out0a, i32 3
  %out1a = bitcast <16 x float> * %out1 to <4 x float> *
  %out1b = getelementptr PTR_OP_ARGS(`<4 x float>') %out1a, i32 1
  %out1c = getelementptr PTR_OP_ARGS(`<4 x float>') %out1a, i32 2
  %out1d = getelementptr PTR_OP_ARGS(`<4 x float>') %out1a, i32 3
  %out2a = bitcast <16 x float> * %out2 to <4 x float> *
  %out2b = getelementptr PTR_OP_ARGS(`<4 x float>') %out2a, i32 1
  %out2c = getelementptr PTR_OP_ARGS(`<4 x float>') %out2a, i32 2
  %out2d = getelementptr PTR_OP_ARGS(`<4 x float>') %out2a, i32 3
  %out3a = bitcast <16 x float> * %out3 to <4 x float> *
  %out3b = getelementptr PTR_OP_ARGS(`<4 x float>') %out3a, i32 1
  %out3c = getelementptr PTR_OP_ARGS(`<4 x float>') %out3a, i32 2
  %out3d = getelementptr PTR_OP_ARGS(`<4 x float>') %out3a, i32 3

  call void @__soa_to_aos4_float4(<4 x float> %v0a, <4 x float> %v1a,
         <4 x float> %v2a, <4 x float> %v3a, <4 x float> * %out0a,
         <4 x float> * %out0b, <4 x float> * %out0c, <4 x float> * %out0d)
  call void @__soa_to_aos4_float4(<4 x float> %v0b, <4 x float> %v1b,
         <4 x float> %v2b, <4 x float> %v3b, <4 x float> * %out1a,
         <4 x float> * %out1b, <4 x float> * %out1c, <4 x float> * %out1d)
  call void @__soa_to_aos4_float4(<4 x float> %v0c, <4 x float> %v1c,
         <4 x float> %v2c, <4 x float> %v3c, <4 x float> * %out2a,
         <4 x float> * %out2b, <4 x float> * %out2c, <4 x float> * %out2d)
  call void @__soa_to_aos4_float4(<4 x float> %v0d, <4 x float> %v1d,
         <4 x float> %v2d, <4 x float> %v3d, <4 x float> * %out3a,
         <4 x float> * %out3b, <4 x float> * %out3c, <4 x float> * %out3d)
  ret void
}


define void
@__aos_to_soa4_double16(<16 x double> %v0, <16 x double> %v1, <16 x double> %v2,
        <16 x double> %v3, <16 x double> * noalias %out0,
        <16 x double> * noalias %out1, <16 x double> * noalias %out2,
        <16 x double> * noalias %out3) nounwind alwaysinline {
  %v0a = shufflevector <16 x double> %v0, <16 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v0b = shufflevector <16 x double> %v0, <16 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v0c = shufflevector <16 x double> %v0, <16 x double> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v0d = shufflevector <16 x double> %v0, <16 x double> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v1a = shufflevector <16 x double> %v1, <16 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v1b = shufflevector <16 x double> %v1, <16 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v1c = shufflevector <16 x double> %v1, <16 x double> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v1d = shufflevector <16 x double> %v1, <16 x double> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v2a = shufflevector <16 x double> %v2, <16 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v2b = shufflevector <16 x double> %v2, <16 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v2c = shufflevector <16 x double> %v2, <16 x double> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v2d = shufflevector <16 x double> %v2, <16 x double> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v3a = shufflevector <16 x double> %v3, <16 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v3b = shufflevector <16 x double> %v3, <16 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v3c = shufflevector <16 x double> %v3, <16 x double> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v3d = shufflevector <16 x double> %v3, <16 x double> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>

  %out0a = bitcast <16 x double> * %out0 to <4 x double> *
  %out0b = getelementptr PTR_OP_ARGS(`<4 x double>') %out0a, i32 1
  %out0c = getelementptr PTR_OP_ARGS(`<4 x double>') %out0a, i32 2
  %out0d = getelementptr PTR_OP_ARGS(`<4 x double>') %out0a, i32 3
  %out1a = bitcast <16 x double> * %out1 to <4 x double> *
  %out1b = getelementptr PTR_OP_ARGS(`<4 x double>') %out1a, i32 1
  %out1c = getelementptr PTR_OP_ARGS(`<4 x double>') %out1a, i32 2
  %out1d = getelementptr PTR_OP_ARGS(`<4 x double>') %out1a, i32 3
  %out2a = bitcast <16 x double> * %out2 to <4 x double> *
  %out2b = getelementptr PTR_OP_ARGS(`<4 x double>') %out2a, i32 1
  %out2c = getelementptr PTR_OP_ARGS(`<4 x double>') %out2a, i32 2
  %out2d = getelementptr PTR_OP_ARGS(`<4 x double>') %out2a, i32 3
  %out3a = bitcast <16 x double> * %out3 to <4 x double> *
  %out3b = getelementptr PTR_OP_ARGS(`<4 x double>') %out3a, i32 1
  %out3c = getelementptr PTR_OP_ARGS(`<4 x double>') %out3a, i32 2
  %out3d = getelementptr PTR_OP_ARGS(`<4 x double>') %out3a, i32 3

  call void @__aos_to_soa4_double4(<4 x double> %v0a, <4 x double> %v0b,
         <4 x double> %v0c, <4 x double> %v0d, <4 x double> * %out0a,
         <4 x double> * %out1a, <4 x double> * %out2a, <4 x double> * %out3a)
  call void @__aos_to_soa4_double4(<4 x double> %v1a, <4 x double> %v1b,
         <4 x double> %v1c, <4 x double> %v1d, <4 x double> * %out0b,
         <4 x double> * %out1b, <4 x double> * %out2b, <4 x double> * %out3b)
  call void @__aos_to_soa4_double4(<4 x double> %v2a, <4 x double> %v2b,
         <4 x double> %v2c, <4 x double> %v2d, <4 x double> * %out0c,
         <4 x double> * %out1c, <4 x double> * %out2c, <4 x double> * %out3c)
  call void @__aos_to_soa4_double4(<4 x double> %v3a, <4 x double> %v3b,
         <4 x double> %v3c, <4 x double> %v3d, <4 x double> * %out0d,
         <4 x double> * %out1d, <4 x double> * %out2d, <4 x double> * %out3d)
  ret void
}

define void
@__soa_to_aos4_double16(<16 x double> %v0, <16 x double> %v1, <16 x double> %v2,
        <16 x double> %v3, <16 x double> * noalias %out0,
        <16 x double> * noalias %out1, <16 x double> * noalias %out2,
        <16 x double> * noalias %out3) nounwind alwaysinline {
  %v0a = shufflevector <16 x double> %v0, <16 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v0b = shufflevector <16 x double> %v0, <16 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v0c = shufflevector <16 x double> %v0, <16 x double> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v0d = shufflevector <16 x double> %v0, <16 x double> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v1a = shufflevector <16 x double> %v1, <16 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v1b = shufflevector <16 x double> %v1, <16 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v1c = shufflevector <16 x double> %v1, <16 x double> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v1d = shufflevector <16 x double> %v1, <16 x double> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v2a = shufflevector <16 x double> %v2, <16 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v2b = shufflevector <16 x double> %v2, <16 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v2c = shufflevector <16 x double> %v2, <16 x double> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v2d = shufflevector <16 x double> %v2, <16 x double> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v3a = shufflevector <16 x double> %v3, <16 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v3b = shufflevector <16 x double> %v3, <16 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v3c = shufflevector <16 x double> %v3, <16 x double> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v3d = shufflevector <16 x double> %v3, <16 x double> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>

  %out0a = bitcast <16 x double> * %out0 to <4 x double> *
  %out0b = getelementptr PTR_OP_ARGS(`<4 x double>') %out0a, i32 1
  %out0c = getelementptr PTR_OP_ARGS(`<4 x double>') %out0a, i32 2
  %out0d = getelementptr PTR_OP_ARGS(`<4 x double>') %out0a, i32 3
  %out1a = bitcast <16 x double> * %out1 to <4 x double> *
  %out1b = getelementptr PTR_OP_ARGS(`<4 x double>') %out1a, i32 1
  %out1c = getelementptr PTR_OP_ARGS(`<4 x double>') %out1a, i32 2
  %out1d = getelementptr PTR_OP_ARGS(`<4 x double>') %out1a, i32 3
  %out2a = bitcast <16 x double> * %out2 to <4 x double> *
  %out2b = getelementptr PTR_OP_ARGS(`<4 x double>') %out2a, i32 1
  %out2c = getelementptr PTR_OP_ARGS(`<4 x double>') %out2a, i32 2
  %out2d = getelementptr PTR_OP_ARGS(`<4 x double>') %out2a, i32 3
  %out3a = bitcast <16 x double> * %out3 to <4 x double> *
  %out3b = getelementptr PTR_OP_ARGS(`<4 x double>') %out3a, i32 1
  %out3c = getelementptr PTR_OP_ARGS(`<4 x double>') %out3a, i32 2
  %out3d = getelementptr PTR_OP_ARGS(`<4 x double>') %out3a, i32 3

  call void @__soa_to_aos4_double4(<4 x double> %v0a, <4 x double> %v1a,
         <4 x double> %v2a, <4 x double> %v3a, <4 x double> * %out0a,
         <4 x double> * %out0b, <4 x double> * %out0c, <4 x double> * %out0d)
  call void @__soa_to_aos4_double4(<4 x double> %v0b, <4 x double> %v1b,
         <4 x double> %v2b, <4 x double> %v3b, <4 x double> * %out1a,
         <4 x double> * %out1b, <4 x double> * %out1c, <4 x double> * %out1d)
  call void @__soa_to_aos4_double4(<4 x double> %v0c, <4 x double> %v1c,
         <4 x double> %v2c, <4 x double> %v3c, <4 x double> * %out2a,
         <4 x double> * %out2b, <4 x double> * %out2c, <4 x double> * %out2d)
  call void @__soa_to_aos4_double4(<4 x double> %v0d, <4 x double> %v1d,
         <4 x double> %v2d, <4 x double> %v3d, <4 x double> * %out3a,
         <4 x double> * %out3b, <4 x double> * %out3c, <4 x double> * %out3d)
  ret void
}

define void
@__aos_to_soa3_float16(<16 x float> %v0, <16 x float> %v1, <16 x float> %v2,
        <16 x float> * noalias %out0, <16 x float> * noalias %out1,
        <16 x float> * noalias %out2) nounwind alwaysinline {
  %v0a = shufflevector <16 x float> %v0, <16 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v0b = shufflevector <16 x float> %v0, <16 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v0c = shufflevector <16 x float> %v0, <16 x float> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v0d = shufflevector <16 x float> %v0, <16 x float> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v1a = shufflevector <16 x float> %v1, <16 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v1b = shufflevector <16 x float> %v1, <16 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v1c = shufflevector <16 x float> %v1, <16 x float> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v1d = shufflevector <16 x float> %v1, <16 x float> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v2a = shufflevector <16 x float> %v2, <16 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v2b = shufflevector <16 x float> %v2, <16 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v2c = shufflevector <16 x float> %v2, <16 x float> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v2d = shufflevector <16 x float> %v2, <16 x float> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>

  %out0a = bitcast <16 x float> * %out0 to <4 x float> *
  %out0b = getelementptr PTR_OP_ARGS(`<4 x float>') %out0a, i32 1
  %out0c = getelementptr PTR_OP_ARGS(`<4 x float>') %out0a, i32 2
  %out0d = getelementptr PTR_OP_ARGS(`<4 x float>') %out0a, i32 3
  %out1a = bitcast <16 x float> * %out1 to <4 x float> *
  %out1b = getelementptr PTR_OP_ARGS(`<4 x float>') %out1a, i32 1
  %out1c = getelementptr PTR_OP_ARGS(`<4 x float>') %out1a, i32 2
  %out1d = getelementptr PTR_OP_ARGS(`<4 x float>') %out1a, i32 3
  %out2a = bitcast <16 x float> * %out2 to <4 x float> *
  %out2b = getelementptr PTR_OP_ARGS(`<4 x float>') %out2a, i32 1
  %out2c = getelementptr PTR_OP_ARGS(`<4 x float>') %out2a, i32 2
  %out2d = getelementptr PTR_OP_ARGS(`<4 x float>') %out2a, i32 3

  call void @__aos_to_soa3_float4(<4 x float> %v0a, <4 x float> %v0b,
         <4 x float> %v0c, <4 x float> * %out0a, <4 x float> * %out1a,
         <4 x float> * %out2a)
  call void @__aos_to_soa3_float4(<4 x float> %v0d, <4 x float> %v1a,
         <4 x float> %v1b, <4 x float> * %out0b, <4 x float> * %out1b,
         <4 x float> * %out2b)
  call void @__aos_to_soa3_float4(<4 x float> %v1c, <4 x float> %v1d,
         <4 x float> %v2a, <4 x float> * %out0c, <4 x float> * %out1c,
         <4 x float> * %out2c)
  call void @__aos_to_soa3_float4(<4 x float> %v2b, <4 x float> %v2c,
         <4 x float> %v2d, <4 x float> * %out0d, <4 x float> * %out1d,
         <4 x float> * %out2d)
  ret void
}


define void
@__soa_to_aos3_float16(<16 x float> %v0, <16 x float> %v1, <16 x float> %v2,
        <16 x float> * noalias %out0, <16 x float> * noalias %out1,
        <16 x float> * noalias %out2) nounwind alwaysinline {
  %v0a = shufflevector <16 x float> %v0, <16 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v0b = shufflevector <16 x float> %v0, <16 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v0c = shufflevector <16 x float> %v0, <16 x float> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v0d = shufflevector <16 x float> %v0, <16 x float> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v1a = shufflevector <16 x float> %v1, <16 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v1b = shufflevector <16 x float> %v1, <16 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v1c = shufflevector <16 x float> %v1, <16 x float> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v1d = shufflevector <16 x float> %v1, <16 x float> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v2a = shufflevector <16 x float> %v2, <16 x float> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v2b = shufflevector <16 x float> %v2, <16 x float> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v2c = shufflevector <16 x float> %v2, <16 x float> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v2d = shufflevector <16 x float> %v2, <16 x float> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>

  %out0a = bitcast <16 x float> * %out0 to <4 x float> *
  %out0b = getelementptr PTR_OP_ARGS(`<4 x float>') %out0a, i32 1
  %out0c = getelementptr PTR_OP_ARGS(`<4 x float>') %out0a, i32 2
  %out0d = getelementptr PTR_OP_ARGS(`<4 x float>') %out0a, i32 3
  %out1a = bitcast <16 x float> * %out1 to <4 x float> *
  %out1b = getelementptr PTR_OP_ARGS(`<4 x float>') %out1a, i32 1
  %out1c = getelementptr PTR_OP_ARGS(`<4 x float>') %out1a, i32 2
  %out1d = getelementptr PTR_OP_ARGS(`<4 x float>') %out1a, i32 3
  %out2a = bitcast <16 x float> * %out2 to <4 x float> *
  %out2b = getelementptr PTR_OP_ARGS(`<4 x float>') %out2a, i32 1
  %out2c = getelementptr PTR_OP_ARGS(`<4 x float>') %out2a, i32 2
  %out2d = getelementptr PTR_OP_ARGS(`<4 x float>') %out2a, i32 3

  call void @__soa_to_aos3_float4(<4 x float> %v0a, <4 x float> %v1a,
         <4 x float> %v2a, <4 x float> * %out0a, <4 x float> * %out0b,
         <4 x float> * %out0c)
  call void @__soa_to_aos3_float4(<4 x float> %v0b, <4 x float> %v1b,
         <4 x float> %v2b, <4 x float> * %out0d, <4 x float> * %out1a,
         <4 x float> * %out1b)
  call void @__soa_to_aos3_float4(<4 x float> %v0c, <4 x float> %v1c,
         <4 x float> %v2c, <4 x float> * %out1c, <4 x float> * %out1d,
         <4 x float> * %out2a)
  call void @__soa_to_aos3_float4(<4 x float> %v0d, <4 x float> %v1d,
         <4 x float> %v2d, <4 x float> * %out2b, <4 x float> * %out2c,
         <4 x float> * %out2d)
  ret void
}


define void
@__aos_to_soa3_double16(<16 x double> %v0, <16 x double> %v1, <16 x double> %v2,
        <16 x double> * noalias %out0, <16 x double> * noalias %out1,
        <16 x double> * noalias %out2) nounwind alwaysinline {
  %v0a = shufflevector <16 x double> %v0, <16 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v0b = shufflevector <16 x double> %v0, <16 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v0c = shufflevector <16 x double> %v0, <16 x double> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v0d = shufflevector <16 x double> %v0, <16 x double> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v1a = shufflevector <16 x double> %v1, <16 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v1b = shufflevector <16 x double> %v1, <16 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v1c = shufflevector <16 x double> %v1, <16 x double> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v1d = shufflevector <16 x double> %v1, <16 x double> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v2a = shufflevector <16 x double> %v2, <16 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v2b = shufflevector <16 x double> %v2, <16 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v2c = shufflevector <16 x double> %v2, <16 x double> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v2d = shufflevector <16 x double> %v2, <16 x double> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>

  %out0a = bitcast <16 x double> * %out0 to <4 x double> *
  %out0b = getelementptr PTR_OP_ARGS(`<4 x double>') %out0a, i32 1
  %out0c = getelementptr PTR_OP_ARGS(`<4 x double>') %out0a, i32 2
  %out0d = getelementptr PTR_OP_ARGS(`<4 x double>') %out0a, i32 3
  %out1a = bitcast <16 x double> * %out1 to <4 x double> *
  %out1b = getelementptr PTR_OP_ARGS(`<4 x double>') %out1a, i32 1
  %out1c = getelementptr PTR_OP_ARGS(`<4 x double>') %out1a, i32 2
  %out1d = getelementptr PTR_OP_ARGS(`<4 x double>') %out1a, i32 3
  %out2a = bitcast <16 x double> * %out2 to <4 x double> *
  %out2b = getelementptr PTR_OP_ARGS(`<4 x double>') %out2a, i32 1
  %out2c = getelementptr PTR_OP_ARGS(`<4 x double>') %out2a, i32 2
  %out2d = getelementptr PTR_OP_ARGS(`<4 x double>') %out2a, i32 3

  call void @__aos_to_soa3_double4(<4 x double> %v0a, <4 x double> %v0b,
         <4 x double> %v0c, <4 x double> * %out0a, <4 x double> * %out1a,
         <4 x double> * %out2a)
  call void @__aos_to_soa3_double4(<4 x double> %v0d, <4 x double> %v1a,
         <4 x double> %v1b, <4 x double> * %out0b, <4 x double> * %out1b,
         <4 x double> * %out2b)
  call void @__aos_to_soa3_double4(<4 x double> %v1c, <4 x double> %v1d,
         <4 x double> %v2a, <4 x double> * %out0c, <4 x double> * %out1c,
         <4 x double> * %out2c)
  call void @__aos_to_soa3_double4(<4 x double> %v2b, <4 x double> %v2c,
         <4 x double> %v2d, <4 x double> * %out0d, <4 x double> * %out1d,
         <4 x double> * %out2d)
  ret void
}


define void
@__soa_to_aos3_double16(<16 x double> %v0, <16 x double> %v1, <16 x double> %v2,
        <16 x double> * noalias %out0, <16 x double> * noalias %out1,
        <16 x double> * noalias %out2) nounwind alwaysinline {
  %v0a = shufflevector <16 x double> %v0, <16 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v0b = shufflevector <16 x double> %v0, <16 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v0c = shufflevector <16 x double> %v0, <16 x double> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v0d = shufflevector <16 x double> %v0, <16 x double> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v1a = shufflevector <16 x double> %v1, <16 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v1b = shufflevector <16 x double> %v1, <16 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v1c = shufflevector <16 x double> %v1, <16 x double> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v1d = shufflevector <16 x double> %v1, <16 x double> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %v2a = shufflevector <16 x double> %v2, <16 x double> undef,
         <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %v2b = shufflevector <16 x double> %v2, <16 x double> undef,
         <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %v2c = shufflevector <16 x double> %v2, <16 x double> undef,
         <4 x i32> <i32 8, i32 9, i32 10, i32 11>
  %v2d = shufflevector <16 x double> %v2, <16 x double> undef,
         <4 x i32> <i32 12, i32 13, i32 14, i32 15>

  %out0a = bitcast <16 x double> * %out0 to <4 x double> *
  %out0b = getelementptr PTR_OP_ARGS(`<4 x double>') %out0a, i32 1
  %out0c = getelementptr PTR_OP_ARGS(`<4 x double>') %out0a, i32 2
  %out0d = getelementptr PTR_OP_ARGS(`<4 x double>') %out0a, i32 3
  %out1a = bitcast <16 x double> * %out1 to <4 x double> *
  %out1b = getelementptr PTR_OP_ARGS(`<4 x double>') %out1a, i32 1
  %out1c = getelementptr PTR_OP_ARGS(`<4 x double>') %out1a, i32 2
  %out1d = getelementptr PTR_OP_ARGS(`<4 x double>') %out1a, i32 3
  %out2a = bitcast <16 x double> * %out2 to <4 x double> *
  %out2b = getelementptr PTR_OP_ARGS(`<4 x double>') %out2a, i32 1
  %out2c = getelementptr PTR_OP_ARGS(`<4 x double>') %out2a, i32 2
  %out2d = getelementptr PTR_OP_ARGS(`<4 x double>') %out2a, i32 3

  call void @__soa_to_aos3_double4(<4 x double> %v0a, <4 x double> %v1a,
         <4 x double> %v2a, <4 x double> * %out0a, <4 x double> * %out0b,
         <4 x double> * %out0c)
  call void @__soa_to_aos3_double4(<4 x double> %v0b, <4 x double> %v1b,
         <4 x double> %v2b, <4 x double> * %out0d, <4 x double> * %out1a,
         <4 x double> * %out1b)
  call void @__soa_to_aos3_double4(<4 x double> %v0c, <4 x double> %v1c,
         <4 x double> %v2c, <4 x double> * %out1c, <4 x double> * %out1d,
         <4 x double> * %out2a)
  call void @__soa_to_aos3_double4(<4 x double> %v0d, <4 x double> %v1d,
         <4 x double> %v2d, <4 x double> * %out2b, <4 x double> * %out2c,
         <4 x double> * %out2d)
  ret void
}

;; versions to be called from stdlib

define void
@__aos_to_soa4_double(double * noalias %p,
        <WIDTH x double> * noalias %out0, <WIDTH x double> * noalias %out1,
        <WIDTH x double> * noalias %out2, <WIDTH x double> * noalias %out3)
        nounwind alwaysinline {
  %p0 = bitcast double * %p to <WIDTH x double> *
  %v0 = load PTR_OP_ARGS(`<WIDTH x double> ')  %p0, align 4
  %p1 = getelementptr PTR_OP_ARGS(`<WIDTH x double>') %p0, i32 1
  %v1 = load PTR_OP_ARGS(`<WIDTH x double> ')  %p1, align 4
  %p2 = getelementptr PTR_OP_ARGS(`<WIDTH x double>') %p0, i32 2
  %v2 = load PTR_OP_ARGS(`<WIDTH x double> ')  %p2, align 4
  %p3 = getelementptr PTR_OP_ARGS(`<WIDTH x double>') %p0, i32 3
  %v3 = load PTR_OP_ARGS(`<WIDTH x double> ')  %p3, align 4
  call void @__aos_to_soa4_double`'WIDTH (<WIDTH x double> %v0, <WIDTH x double> %v1,
         <WIDTH x double> %v2, <WIDTH x double> %v3, <WIDTH x double> * %out0,
         <WIDTH x double> * %out1, <WIDTH x double> * %out2, <WIDTH x double> * %out3)
  ret void
}

define void
@__soa_to_aos4_double(<WIDTH x double> %v0, <WIDTH x double> %v1, <WIDTH x double> %v2,
             <WIDTH x double> %v3, double * noalias %p) nounwind alwaysinline {
  %out0 = bitcast double * %p to <WIDTH x double> *
  %out1 = getelementptr PTR_OP_ARGS(`<WIDTH x double>') %out0, i32 1
  %out2 = getelementptr PTR_OP_ARGS(`<WIDTH x double>') %out0, i32 2
  %out3 = getelementptr PTR_OP_ARGS(`<WIDTH x double>') %out0, i32 3
  call void @__soa_to_aos4_double`'WIDTH (<WIDTH x double> %v0, <WIDTH x double> %v1,
         <WIDTH x double> %v2, <WIDTH x double> %v3, <WIDTH x double> * %out0,
         <WIDTH x double> * %out1, <WIDTH x double> * %out2, <WIDTH x double> * %out3)
  ret void
}


;; versions to be called from stdlib

define void
@__aos_to_soa4_float(float * noalias %p,
        <WIDTH x float> * noalias %out0, <WIDTH x float> * noalias %out1,
        <WIDTH x float> * noalias %out2, <WIDTH x float> * noalias %out3)
        nounwind alwaysinline {
  %p0 = bitcast float * %p to <WIDTH x float> *
  %v0 = load PTR_OP_ARGS(`<WIDTH x float> ')  %p0, align 4
  %p1 = getelementptr PTR_OP_ARGS(`<WIDTH x float>') %p0, i32 1
  %v1 = load PTR_OP_ARGS(`<WIDTH x float> ')  %p1, align 4
  %p2 = getelementptr PTR_OP_ARGS(`<WIDTH x float>') %p0, i32 2
  %v2 = load PTR_OP_ARGS(`<WIDTH x float> ')  %p2, align 4
  %p3 = getelementptr PTR_OP_ARGS(`<WIDTH x float>') %p0, i32 3
  %v3 = load PTR_OP_ARGS(`<WIDTH x float> ')  %p3, align 4
  call void @__aos_to_soa4_float`'WIDTH (<WIDTH x float> %v0, <WIDTH x float> %v1,
         <WIDTH x float> %v2, <WIDTH x float> %v3, <WIDTH x float> * %out0,
         <WIDTH x float> * %out1, <WIDTH x float> * %out2, <WIDTH x float> * %out3)
  ret void
}


define void
@__soa_to_aos4_float(<WIDTH x float> %v0, <WIDTH x float> %v1, <WIDTH x float> %v2,
             <WIDTH x float> %v3, float * noalias %p) nounwind alwaysinline {
  %out0 = bitcast float * %p to <WIDTH x float> *
  %out1 = getelementptr PTR_OP_ARGS(`<WIDTH x float>') %out0, i32 1
  %out2 = getelementptr PTR_OP_ARGS(`<WIDTH x float>') %out0, i32 2
  %out3 = getelementptr PTR_OP_ARGS(`<WIDTH x float>') %out0, i32 3
  call void @__soa_to_aos4_float`'WIDTH (<WIDTH x float> %v0, <WIDTH x float> %v1,
         <WIDTH x float> %v2, <WIDTH x float> %v3, <WIDTH x float> * %out0,
         <WIDTH x float> * %out1, <WIDTH x float> * %out2, <WIDTH x float> * %out3)
  ret void
}

define void
@__aos_to_soa3_double(double * noalias %p,
        <WIDTH x double> * %out0, <WIDTH x double> * %out1,
        <WIDTH x double> * %out2) nounwind alwaysinline {
  %p0 = bitcast double * %p to <WIDTH x double> *
  %v0 = load PTR_OP_ARGS(`<WIDTH x double> ')  %p0, align 4
  %p1 = getelementptr PTR_OP_ARGS(`<WIDTH x double>') %p0, i32 1
  %v1 = load PTR_OP_ARGS(`<WIDTH x double> ')  %p1, align 4
  %p2 = getelementptr PTR_OP_ARGS(`<WIDTH x double>') %p0, i32 2
  %v2 = load PTR_OP_ARGS(`<WIDTH x double> ')  %p2, align 4
  call void @__aos_to_soa3_double`'WIDTH (<WIDTH x double> %v0, <WIDTH x double> %v1,
         <WIDTH x double> %v2, <WIDTH x double> * %out0, <WIDTH x double> * %out1,
         <WIDTH x double> * %out2)
  ret void
}


define void
@__soa_to_aos3_double(<WIDTH x double> %v0, <WIDTH x double> %v1, <WIDTH x double> %v2,
                     double * noalias %p) nounwind alwaysinline {
  %out0 = bitcast double * %p to <WIDTH x double> *
  %out1 = getelementptr PTR_OP_ARGS(`<WIDTH x double>') %out0, i32 1
  %out2 = getelementptr PTR_OP_ARGS(`<WIDTH x double>') %out0, i32 2
  call void @__soa_to_aos3_double`'WIDTH (<WIDTH x double> %v0, <WIDTH x double> %v1,
         <WIDTH x double> %v2, <WIDTH x double> * %out0, <WIDTH x double> * %out1,
         <WIDTH x double> * %out2)
  ret void
}

define void
@__aos_to_soa3_float(float * noalias %p,
        <WIDTH x float> * %out0, <WIDTH x float> * %out1,
        <WIDTH x float> * %out2) nounwind alwaysinline {
  %p0 = bitcast float * %p to <WIDTH x float> *
  %v0 = load PTR_OP_ARGS(`<WIDTH x float> ')  %p0, align 4
  %p1 = getelementptr PTR_OP_ARGS(`<WIDTH x float>') %p0, i32 1
  %v1 = load PTR_OP_ARGS(`<WIDTH x float> ')  %p1, align 4
  %p2 = getelementptr PTR_OP_ARGS(`<WIDTH x float>') %p0, i32 2
  %v2 = load PTR_OP_ARGS(`<WIDTH x float> ')  %p2, align 4
  call void @__aos_to_soa3_float`'WIDTH (<WIDTH x float> %v0, <WIDTH x float> %v1,
         <WIDTH x float> %v2, <WIDTH x float> * %out0, <WIDTH x float> * %out1,
         <WIDTH x float> * %out2)
  ret void
}


define void
@__soa_to_aos3_float(<WIDTH x float> %v0, <WIDTH x float> %v1, <WIDTH x float> %v2,
                     float * noalias %p) nounwind alwaysinline {
  %out0 = bitcast float * %p to <WIDTH x float> *
  %out1 = getelementptr PTR_OP_ARGS(`<WIDTH x float>') %out0, i32 1
  %out2 = getelementptr PTR_OP_ARGS(`<WIDTH x float>') %out0, i32 2
  call void @__soa_to_aos3_float`'WIDTH (<WIDTH x float> %v0, <WIDTH x float> %v1,
         <WIDTH x float> %v2, <WIDTH x float> * %out0, <WIDTH x float> * %out1,
         <WIDTH x float> * %out2)
  ret void
}
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


define(`stdlib_core', `

declare i32 @__fast_masked_vload()

declare i8* @ISPCAlloc(i8**, i64, i32) nounwind
declare void @ISPCLaunch(i8**, i8*, i8*, i32, i32, i32) nounwind
declare void @ISPCSync(i8*) nounwind
declare void @ISPCInstrument(i8*, i8*, i32, i64) nounwind

declare i1 @__is_compile_time_constant_mask(<WIDTH x MASK> %mask)
declare i1 @__is_compile_time_constant_uniform_int32(i32)
declare i1 @__is_compile_time_constant_varying_int32(<WIDTH x i32>)

; This function declares placeholder masked store functions for the
;  front-end to use.
;
;  void __pseudo_masked_store_i8 (uniform int8 *ptr, varying int8 values, mask)
;  void __pseudo_masked_store_i16(uniform int16 *ptr, varying int16 values, mask)
;  void __pseudo_masked_store_i32(uniform int32 *ptr, varying int32 values, mask)
;  void __pseudo_masked_store_float(uniform float *ptr, varying float values, mask)
;  void __pseudo_masked_store_i64(uniform int64 *ptr, varying int64 values, mask)
;  void __pseudo_masked_store_double(uniform double *ptr, varying double values, mask)
;
;  These in turn are converted to native masked stores or to regular
;  stores (if the mask is all on) by the MaskedStoreOptPass optimization
;  pass.

declare void @__pseudo_masked_store_i8(<WIDTH x i8> * nocapture, <WIDTH x i8>, <WIDTH x MASK>)
declare void @__pseudo_masked_store_i16(<WIDTH x i16> * nocapture, <WIDTH x i16>, <WIDTH x MASK>)
declare void @__pseudo_masked_store_i32(<WIDTH x i32> * nocapture, <WIDTH x i32>, <WIDTH x MASK>)
declare void @__pseudo_masked_store_float(<WIDTH x float> * nocapture, <WIDTH x float>, <WIDTH x MASK>)
declare void @__pseudo_masked_store_i64(<WIDTH x i64> * nocapture, <WIDTH x i64>, <WIDTH x MASK>)
declare void @__pseudo_masked_store_double(<WIDTH x double> * nocapture, <WIDTH x double>, <WIDTH x MASK>)

; Declare the pseudo-gather functions.  When the ispc front-end needs
; to perform a gather, it generates a call to one of these functions,
; which ideally have these signatures:
;
; varying int8  __pseudo_gather_i8(varying int8 *, mask)
; varying int16 __pseudo_gather_i16(varying int16 *, mask)
; varying int32 __pseudo_gather_i32(varying int32 *, mask)
; varying float __pseudo_gather_float(varying float *, mask)
; varying int64 __pseudo_gather_i64(varying int64 *, mask)
; varying double __pseudo_gather_double(varying double *, mask)
;
; However, vectors of pointers weren not legal in LLVM until recently, so
; instead, it emits calls to functions that either take vectors of int32s
; or int64s, depending on the compilation target.

declare <WIDTH x i8>  @__pseudo_gather32_i8(<WIDTH x i32>, <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i16> @__pseudo_gather32_i16(<WIDTH x i32>, <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i32> @__pseudo_gather32_i32(<WIDTH x i32>, <WIDTH x MASK>) nounwind readonly
declare <WIDTH x float> @__pseudo_gather32_float(<WIDTH x i32>, <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i64> @__pseudo_gather32_i64(<WIDTH x i32>, <WIDTH x MASK>) nounwind readonly
declare <WIDTH x double> @__pseudo_gather32_double(<WIDTH x i32>, <WIDTH x MASK>) nounwind readonly

declare <WIDTH x i8>  @__pseudo_gather64_i8(<WIDTH x i64>, <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i16> @__pseudo_gather64_i16(<WIDTH x i64>, <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i32> @__pseudo_gather64_i32(<WIDTH x i64>, <WIDTH x MASK>) nounwind readonly
declare <WIDTH x float> @__pseudo_gather64_float(<WIDTH x i64>, <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i64> @__pseudo_gather64_i64(<WIDTH x i64>, <WIDTH x MASK>) nounwind readonly
declare <WIDTH x double> @__pseudo_gather64_double(<WIDTH x i64>, <WIDTH x MASK>) nounwind readonly

; The ImproveMemoryOps optimization pass finds these calls and then
; tries to convert them to be calls to gather functions that take a uniform
; base pointer and then a varying integer offset, when possible.
;
; For targets without a native gather instruction, it is best to factor the
; integer offsets like "{1/2/4/8} * varying_offset + constant_offset",
; where varying_offset includes non-compile time constant values, and
; constant_offset includes compile-time constant values.  (The scalar loads
; generated in turn can then take advantage of the free offsetting and scale by
; 1/2/4/8 that is offered by the x86 addresisng modes.)
;
; varying int{8,16,32,float,64,double}
; __pseudo_gather_factored_base_offsets{32,64}_{i8,i16,i32,float,i64,double}(uniform int8 *base,
;                                    int{32,64} offsets, uniform int32 offset_scale,
;                                    int{32,64} offset_delta, mask)
;
; For targets with a gather instruction, it is better to just factor them into
; a gather from a uniform base pointer and then "{1/2/4/8} * offsets", where the
; offsets are int32/64 vectors.
;
; varying int{8,16,32,float,64,double}
; __pseudo_gather_base_offsets{32,64}_{i8,i16,i32,float,i64,double}(uniform int8 *base,
;                                    uniform int32 offset_scale, int{32,64} offsets, mask)


declare <WIDTH x i8>
@__pseudo_gather_factored_base_offsets32_i8(i8 *, <WIDTH x i32>, i32, <WIDTH x i32>,
                                            <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i16>
@__pseudo_gather_factored_base_offsets32_i16(i8 *, <WIDTH x i32>, i32, <WIDTH x i32>,
                                             <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i32>
@__pseudo_gather_factored_base_offsets32_i32(i8 *, <WIDTH x i32>, i32, <WIDTH x i32>,
                                             <WIDTH x MASK>) nounwind readonly
declare <WIDTH x float>
@__pseudo_gather_factored_base_offsets32_float(i8 *, <WIDTH x i32>, i32, <WIDTH x i32>,
                                               <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i64>
@__pseudo_gather_factored_base_offsets32_i64(i8 *, <WIDTH x i32>, i32, <WIDTH x i32>,
                                             <WIDTH x MASK>) nounwind readonly
declare <WIDTH x double>
@__pseudo_gather_factored_base_offsets32_double(i8 *, <WIDTH x i32>, i32, <WIDTH x i32>,
                                                <WIDTH x MASK>) nounwind readonly

declare <WIDTH x i8>
@__pseudo_gather_factored_base_offsets64_i8(i8 *, <WIDTH x i64>, i32, <WIDTH x i64>,
                                            <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i16>
@__pseudo_gather_factored_base_offsets64_i16(i8 *, <WIDTH x i64>, i32, <WIDTH x i64>,
                                             <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i32>
@__pseudo_gather_factored_base_offsets64_i32(i8 *, <WIDTH x i64>, i32, <WIDTH x i64>,
                                             <WIDTH x MASK>) nounwind readonly
declare <WIDTH x float>
@__pseudo_gather_factored_base_offsets64_float(i8 *, <WIDTH x i64>, i32, <WIDTH x i64>,
                                               <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i64>
@__pseudo_gather_factored_base_offsets64_i64(i8 *, <WIDTH x i64>, i32, <WIDTH x i64>,
                                             <WIDTH x MASK>) nounwind readonly
declare <WIDTH x double>
@__pseudo_gather_factored_base_offsets64_double(i8 *, <WIDTH x i64>, i32, <WIDTH x i64>,
                                                <WIDTH x MASK>) nounwind readonly

declare <WIDTH x i8>
@__pseudo_gather_base_offsets32_i8(i8 *, i32, <WIDTH x i32>,
                                   <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i16>
@__pseudo_gather_base_offsets32_i16(i8 *, i32, <WIDTH x i32>,
                                    <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i32>
@__pseudo_gather_base_offsets32_i32(i8 *, i32, <WIDTH x i32>,
                                    <WIDTH x MASK>) nounwind readonly
declare <WIDTH x float>
@__pseudo_gather_base_offsets32_float(i8 *, i32, <WIDTH x i32>,
                                      <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i64>
@__pseudo_gather_base_offsets32_i64(i8 *, i32, <WIDTH x i32>,
                                    <WIDTH x MASK>) nounwind readonly
declare <WIDTH x double>
@__pseudo_gather_base_offsets32_double(i8 *, i32, <WIDTH x i32>,
                                       <WIDTH x MASK>) nounwind readonly

declare <WIDTH x i8>
@__pseudo_gather_base_offsets64_i8(i8 *, i32, <WIDTH x i64>,
                                   <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i16>
@__pseudo_gather_base_offsets64_i16(i8 *, i32, <WIDTH x i64>,
                                    <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i32>
@__pseudo_gather_base_offsets64_i32(i8 *, i32, <WIDTH x i64>,
                                    <WIDTH x MASK>) nounwind readonly
declare <WIDTH x float>
@__pseudo_gather_base_offsets64_float(i8 *, i32, <WIDTH x i64>,
                                      <WIDTH x MASK>) nounwind readonly
declare <WIDTH x i64>
@__pseudo_gather_base_offsets64_i64(i8 *, i32, <WIDTH x i64>,
                                    <WIDTH x MASK>) nounwind readonly
declare <WIDTH x double>
@__pseudo_gather_base_offsets64_double(i8 *, i32, <WIDTH x i64>,
                                       <WIDTH x MASK>) nounwind readonly

; Similarly to the pseudo-gathers defined above, we also declare undefined
; pseudo-scatter instructions with signatures:
;
; void __pseudo_scatter_i8 (varying int8 *, varying int8 values, mask)
; void __pseudo_scatter_i16(varying int16 *, varying int16 values, mask)
; void __pseudo_scatter_i32(varying int32 *, varying int32 values, mask)
; void __pseudo_scatter_float(varying float *, varying float values, mask)
; void __pseudo_scatter_i64(varying int64 *, varying int64 values, mask)
; void __pseudo_scatter_double(varying double *, varying double values, mask)
;

declare void @__pseudo_scatter32_i8(<WIDTH x i32>, <WIDTH x i8>, <WIDTH x MASK>) nounwind
declare void @__pseudo_scatter32_i16(<WIDTH x i32>, <WIDTH x i16>, <WIDTH x MASK>) nounwind
declare void @__pseudo_scatter32_i32(<WIDTH x i32>, <WIDTH x i32>, <WIDTH x MASK>) nounwind
declare void @__pseudo_scatter32_float(<WIDTH x i32>, <WIDTH x float>, <WIDTH x MASK>) nounwind
declare void @__pseudo_scatter32_i64(<WIDTH x i32>, <WIDTH x i64>, <WIDTH x MASK>) nounwind
declare void @__pseudo_scatter32_double(<WIDTH x i32>, <WIDTH x double>, <WIDTH x MASK>) nounwind

declare void @__pseudo_scatter64_i8(<WIDTH x i64>, <WIDTH x i8>, <WIDTH x MASK>) nounwind
declare void @__pseudo_scatter64_i16(<WIDTH x i64>, <WIDTH x i16>, <WIDTH x MASK>) nounwind
declare void @__pseudo_scatter64_i32(<WIDTH x i64>, <WIDTH x i32>, <WIDTH x MASK>) nounwind
declare void @__pseudo_scatter64_float(<WIDTH x i64>, <WIDTH x float>, <WIDTH x MASK>) nounwind
declare void @__pseudo_scatter64_i64(<WIDTH x i64>, <WIDTH x i64>, <WIDTH x MASK>) nounwind
declare void @__pseudo_scatter64_double(<WIDTH x i64>, <WIDTH x double>, <WIDTH x MASK>) nounwind

; And the ImproveMemoryOps optimization pass also finds these and
; either transforms them to scatters like:
;
; void __pseudo_scatter_factored_base_offsets{32,64}_i8(uniform int8 *base,
;             varying int32 offsets, uniform int32 offset_scale,
;             varying int{32,64} offset_delta, varying int8 values, mask)
; (and similarly for 16/32/64 bit values)
;
; Or, if the target has a native scatter instruction:
;
; void __pseudo_scatter_base_offsets{32,64}_i8(uniform int8 *base,
;             uniform int32 offset_scale, varying int{32,64} offsets,
;             varying int8 values, mask)
; (and similarly for 16/32/64 bit values)

declare void
@__pseudo_scatter_factored_base_offsets32_i8(i8 * nocapture, <WIDTH x i32>, i32, <WIDTH x i32>,
                                             <WIDTH x i8>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_factored_base_offsets32_i16(i8 * nocapture, <WIDTH x i32>, i32, <WIDTH x i32>,
                                              <WIDTH x i16>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_factored_base_offsets32_i32(i8 * nocapture, <WIDTH x i32>, i32, <WIDTH x i32>,
                                              <WIDTH x i32>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_factored_base_offsets32_float(i8 * nocapture, <WIDTH x i32>, i32, <WIDTH x i32>,
                                                <WIDTH x float>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_factored_base_offsets32_i64(i8 * nocapture, <WIDTH x i32>, i32, <WIDTH x i32>,
                                              <WIDTH x i64>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_factored_base_offsets32_double(i8 * nocapture, <WIDTH x i32>, i32, <WIDTH x i32>,
                                                 <WIDTH x double>, <WIDTH x MASK>) nounwind

declare void
@__pseudo_scatter_factored_base_offsets64_i8(i8 * nocapture, <WIDTH x i64>, i32, <WIDTH x i64>,
                                             <WIDTH x i8>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_factored_base_offsets64_i16(i8 * nocapture, <WIDTH x i64>, i32, <WIDTH x i64>,
                                              <WIDTH x i16>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_factored_base_offsets64_i32(i8 * nocapture, <WIDTH x i64>, i32, <WIDTH x i64>,
                                              <WIDTH x i32>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_factored_base_offsets64_float(i8 * nocapture, <WIDTH x i64>, i32, <WIDTH x i64>,
                                                <WIDTH x float>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_factored_base_offsets64_i64(i8 * nocapture, <WIDTH x i64>, i32, <WIDTH x i64>,
                                              <WIDTH x i64>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_factored_base_offsets64_double(i8 * nocapture, <WIDTH x i64>, i32, <WIDTH x i64>,
                                                 <WIDTH x double>, <WIDTH x MASK>) nounwind

declare void
@__pseudo_scatter_base_offsets32_i8(i8 * nocapture, i32, <WIDTH x i32>,
                                    <WIDTH x i8>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_base_offsets32_i16(i8 * nocapture, i32, <WIDTH x i32>,
                                     <WIDTH x i16>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_base_offsets32_i32(i8 * nocapture, i32, <WIDTH x i32>,
                                     <WIDTH x i32>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_base_offsets32_float(i8 * nocapture, i32, <WIDTH x i32>,
                                       <WIDTH x float>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_base_offsets32_i64(i8 * nocapture, i32, <WIDTH x i32>,
                                     <WIDTH x i64>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_base_offsets32_double(i8 * nocapture, i32, <WIDTH x i32>,
                                        <WIDTH x double>, <WIDTH x MASK>) nounwind

declare void
@__pseudo_scatter_base_offsets64_i8(i8 * nocapture, i32, <WIDTH x i64>,
                                    <WIDTH x i8>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_base_offsets64_i16(i8 * nocapture, i32, <WIDTH x i64>,
                                     <WIDTH x i16>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_base_offsets64_i32(i8 * nocapture, i32, <WIDTH x i64>,
                                     <WIDTH x i32>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_base_offsets64_float(i8 * nocapture, i32, <WIDTH x i64>,
                                       <WIDTH x float>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_base_offsets64_i64(i8 * nocapture, i32, <WIDTH x i64>,
                                     <WIDTH x i64>, <WIDTH x MASK>) nounwind
declare void
@__pseudo_scatter_base_offsets64_double(i8 * nocapture, i32, <WIDTH x i64>,
                                        <WIDTH x double>, <WIDTH x MASK>) nounwind


declare void @__pseudo_prefetch_read_varying_1(<WIDTH x i64>, <WIDTH x MASK>) nounwind

declare void
@__pseudo_prefetch_read_varying_1_native(i8 *, i32, <WIDTH x i32>,
                                         <WIDTH x MASK>) nounwind

declare void @__pseudo_prefetch_read_varying_2(<WIDTH x i64>, <WIDTH x MASK>) nounwind

declare void
@__pseudo_prefetch_read_varying_2_native(i8 *, i32, <WIDTH x i32>,
                                         <WIDTH x MASK>) nounwind

declare void @__pseudo_prefetch_read_varying_3(<WIDTH x i64>, <WIDTH x MASK>) nounwind

declare void
@__pseudo_prefetch_read_varying_3_native(i8 *, i32, <WIDTH x i32>,
                                         <WIDTH x MASK>) nounwind

declare void @__pseudo_prefetch_read_varying_nt(<WIDTH x i64>, <WIDTH x MASK>) nounwind

declare void
@__pseudo_prefetch_read_varying_nt_native(i8 *, i32, <WIDTH x i32>,
                                         <WIDTH x MASK>) nounwind

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

declare void @__use8(<WIDTH x i8>)
declare void @__use16(<WIDTH x i16>)
declare void @__use32(<WIDTH x i32>)
declare void @__usefloat(<WIDTH x float>)
declare void @__use64(<WIDTH x i64>)
declare void @__usedouble(<WIDTH x double>)

;; This is a temporary function that will be removed at the end of
;; compilation--the idea is that it calls out to all of the various
;; functions / pseudo-function declarations that we need to keep around
;; so that they are available to the various optimization passes.  This
;; then prevents those functions from being removed as dead code when
;; we do early DCE...

define void @__keep_funcs_live(i8 * %ptr, <WIDTH x i8> %v8, <WIDTH x i16> %v16,
                               <WIDTH x i32> %v32, <WIDTH x i64> %v64,
                               <WIDTH x MASK> %mask) {
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; loads
  %ml8  = call <WIDTH x i8>  @__masked_load_i8(i8 * %ptr, <WIDTH x MASK> %mask)
  call void @__use8(<WIDTH x i8> %ml8)
  %ml16 = call <WIDTH x i16> @__masked_load_i16(i8 * %ptr, <WIDTH x MASK> %mask)
  call void @__use16(<WIDTH x i16> %ml16)
  %ml32 = call <WIDTH x i32> @__masked_load_i32(i8 * %ptr, <WIDTH x MASK> %mask)
  call void @__use32(<WIDTH x i32> %ml32)
  %mlf = call <WIDTH x float> @__masked_load_float(i8 * %ptr, <WIDTH x MASK> %mask)
  call void @__usefloat(<WIDTH x float> %mlf)
  %ml64 = call <WIDTH x i64> @__masked_load_i64(i8 * %ptr, <WIDTH x MASK> %mask)
  call void @__use64(<WIDTH x i64> %ml64)
  %mld = call <WIDTH x double> @__masked_load_double(i8 * %ptr, <WIDTH x MASK> %mask)
  call void @__usedouble(<WIDTH x double> %mld)

  ;; loads
  %prml8  = call <WIDTH x i8>  @__masked_load_private_i8(i8 * %ptr, <WIDTH x MASK> %mask)
  call void @__use8(<WIDTH x i8> %prml8)
  %prml16 = call <WIDTH x i16> @__masked_load_private_i16(i8 * %ptr, <WIDTH x MASK> %mask)
  call void @__use16(<WIDTH x i16> %prml16)
  %prml32 = call <WIDTH x i32> @__masked_load_private_i32(i8 * %ptr, <WIDTH x MASK> %mask)
  call void @__use32(<WIDTH x i32> %prml32)
  %prmlf = call <WIDTH x float> @__masked_load_private_float(i8 * %ptr, <WIDTH x MASK> %mask)
  call void @__usefloat(<WIDTH x float> %prmlf)
  %prml64 = call <WIDTH x i64> @__masked_load_private_i64(i8 * %ptr, <WIDTH x MASK> %mask)
  call void @__use64(<WIDTH x i64> %prml64)
  %prmld = call <WIDTH x double> @__masked_load_private_double(i8 * %ptr, <WIDTH x MASK> %mask)
  call void @__usedouble(<WIDTH x double> %prmld)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; stores
  %pv8 = bitcast i8 * %ptr to <WIDTH x i8> *
  call void @__pseudo_masked_store_i8(<WIDTH x i8> * %pv8, <WIDTH x i8> %v8,
                                      <WIDTH x MASK> %mask)
  %pv16 = bitcast i8 * %ptr to <WIDTH x i16> *
  call void @__pseudo_masked_store_i16(<WIDTH x i16> * %pv16, <WIDTH x i16> %v16,
                                       <WIDTH x MASK> %mask)
  %pv32 = bitcast i8 * %ptr to <WIDTH x i32> *
  call void @__pseudo_masked_store_i32(<WIDTH x i32> * %pv32, <WIDTH x i32> %v32,
                                       <WIDTH x MASK> %mask)
  %vf = bitcast <WIDTH x i32> %v32 to <WIDTH x float>
  %pvf = bitcast i8 * %ptr to <WIDTH x float> *
  call void @__pseudo_masked_store_float(<WIDTH x float> * %pvf, <WIDTH x float> %vf,
                                         <WIDTH x MASK> %mask)
  %pv64 = bitcast i8 * %ptr to <WIDTH x i64> *
  call void @__pseudo_masked_store_i64(<WIDTH x i64> * %pv64, <WIDTH x i64> %v64,
                                       <WIDTH x MASK> %mask)
  %vd = bitcast <WIDTH x i64> %v64 to <WIDTH x double>
  %pvd = bitcast i8 * %ptr to <WIDTH x double> *
  call void @__pseudo_masked_store_double(<WIDTH x double> * %pvd, <WIDTH x double> %vd,
                                         <WIDTH x MASK> %mask)

  call void @__masked_store_i8(<WIDTH x i8> * %pv8, <WIDTH x i8> %v8, <WIDTH x MASK> %mask)
  call void @__masked_store_i16(<WIDTH x i16> * %pv16, <WIDTH x i16> %v16, <WIDTH x MASK> %mask)
  call void @__masked_store_i32(<WIDTH x i32> * %pv32, <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__masked_store_float(<WIDTH x float> * %pvf, <WIDTH x float> %vf, <WIDTH x MASK> %mask)
  call void @__masked_store_i64(<WIDTH x i64> * %pv64, <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__masked_store_double(<WIDTH x double> * %pvd, <WIDTH x double> %vd, <WIDTH x MASK> %mask)

  call void @__masked_store_private_i8(<WIDTH x i8> * %pv8, <WIDTH x i8> %v8, <WIDTH x MASK> %mask)
  call void @__masked_store_private_i16(<WIDTH x i16> * %pv16, <WIDTH x i16> %v16, <WIDTH x MASK> %mask)
  call void @__masked_store_private_i32(<WIDTH x i32> * %pv32, <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__masked_store_private_float(<WIDTH x float> * %pvf, <WIDTH x float> %vf, <WIDTH x MASK> %mask)
  call void @__masked_store_private_i64(<WIDTH x i64> * %pv64, <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__masked_store_private_double(<WIDTH x double> * %pvd, <WIDTH x double> %vd, <WIDTH x MASK> %mask)

  call void @__masked_store_blend_i8(<WIDTH x i8> * %pv8, <WIDTH x i8> %v8,
                                     <WIDTH x MASK> %mask)
  call void @__masked_store_blend_i16(<WIDTH x i16> * %pv16, <WIDTH x i16> %v16,
                                      <WIDTH x MASK> %mask)
  call void @__masked_store_blend_i32(<WIDTH x i32> * %pv32, <WIDTH x i32> %v32,
                                      <WIDTH x MASK> %mask)
  call void @__masked_store_blend_float(<WIDTH x float> * %pvf, <WIDTH x float> %vf,
                                        <WIDTH x MASK> %mask)
  call void @__masked_store_blend_i64(<WIDTH x i64> * %pv64, <WIDTH x i64> %v64,
                                      <WIDTH x MASK> %mask)
  call void @__masked_store_blend_double(<WIDTH x double> * %pvd, <WIDTH x double> %vd,
                                         <WIDTH x MASK> %mask)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; gathers

  %pg32_8 = call <WIDTH x i8>  @__pseudo_gather32_i8(<WIDTH x i32> %v32,
                                                     <WIDTH x MASK> %mask)
  call void @__use8(<WIDTH x i8> %pg32_8)
  %pg32_16 = call <WIDTH x i16>  @__pseudo_gather32_i16(<WIDTH x i32> %v32,
                                                        <WIDTH x MASK> %mask)
  call void @__use16(<WIDTH x i16> %pg32_16)
  %pg32_32 = call <WIDTH x i32>  @__pseudo_gather32_i32(<WIDTH x i32> %v32,
                                                        <WIDTH x MASK> %mask)
  call void @__use32(<WIDTH x i32> %pg32_32)
  %pg32_f = call <WIDTH x float>  @__pseudo_gather32_float(<WIDTH x i32> %v32,
                                                        <WIDTH x MASK> %mask)
  call void @__usefloat(<WIDTH x float> %pg32_f)
  %pg32_64 = call <WIDTH x i64>  @__pseudo_gather32_i64(<WIDTH x i32> %v32,
                                                        <WIDTH x MASK> %mask)
  call void @__use64(<WIDTH x i64> %pg32_64)
  %pg32_d = call <WIDTH x double>  @__pseudo_gather32_double(<WIDTH x i32> %v32,
                                                        <WIDTH x MASK> %mask)
  call void @__usedouble(<WIDTH x double> %pg32_d)

  %pg64_8 = call <WIDTH x i8>  @__pseudo_gather64_i8(<WIDTH x i64> %v64,
                                                     <WIDTH x MASK> %mask)
  call void @__use8(<WIDTH x i8> %pg64_8)
  %pg64_16 = call <WIDTH x i16>  @__pseudo_gather64_i16(<WIDTH x i64> %v64,
                                                        <WIDTH x MASK> %mask)
  call void @__use16(<WIDTH x i16> %pg64_16)
  %pg64_32 = call <WIDTH x i32>  @__pseudo_gather64_i32(<WIDTH x i64> %v64,
                                                        <WIDTH x MASK> %mask)
  call void @__use32(<WIDTH x i32> %pg64_32)
  %pg64_f = call <WIDTH x float>  @__pseudo_gather64_float(<WIDTH x i64> %v64,
                                                        <WIDTH x MASK> %mask)
  call void @__usefloat(<WIDTH x float> %pg64_f)
  %pg64_64 = call <WIDTH x i64>  @__pseudo_gather64_i64(<WIDTH x i64> %v64,
                                                        <WIDTH x MASK> %mask)
  call void @__use64(<WIDTH x i64> %pg64_64)
  %pg64_d = call <WIDTH x double>  @__pseudo_gather64_double(<WIDTH x i64> %v64,
                                                        <WIDTH x MASK> %mask)
  call void @__usedouble(<WIDTH x double> %pg64_d)

  %g32_8 = call <WIDTH x i8>  @__gather32_i8(<WIDTH x i32> %v32,
                                                     <WIDTH x MASK> %mask)
  call void @__use8(<WIDTH x i8> %g32_8)
  %g32_16 = call <WIDTH x i16>  @__gather32_i16(<WIDTH x i32> %v32,
                                                        <WIDTH x MASK> %mask)
  call void @__use16(<WIDTH x i16> %g32_16)
  %g32_32 = call <WIDTH x i32>  @__gather32_i32(<WIDTH x i32> %v32,
                                                        <WIDTH x MASK> %mask)
  call void @__use32(<WIDTH x i32> %g32_32)
  %g32_f = call <WIDTH x float>  @__gather32_float(<WIDTH x i32> %v32,
                                                        <WIDTH x MASK> %mask)
  call void @__usefloat(<WIDTH x float> %g32_f)
  %g32_64 = call <WIDTH x i64>  @__gather32_i64(<WIDTH x i32> %v32,
                                                        <WIDTH x MASK> %mask)
  call void @__use64(<WIDTH x i64> %g32_64)
  %g32_d = call <WIDTH x double>  @__gather32_double(<WIDTH x i32> %v32,
                                                        <WIDTH x MASK> %mask)
  call void @__usedouble(<WIDTH x double> %g32_d)

  %g64_8 = call <WIDTH x i8>  @__gather64_i8(<WIDTH x i64> %v64,
                                                     <WIDTH x MASK> %mask)
  call void @__use8(<WIDTH x i8> %g64_8)
  %g64_16 = call <WIDTH x i16>  @__gather64_i16(<WIDTH x i64> %v64,
                                                        <WIDTH x MASK> %mask)
  call void @__use16(<WIDTH x i16> %g64_16)
  %g64_32 = call <WIDTH x i32>  @__gather64_i32(<WIDTH x i64> %v64,
                                                        <WIDTH x MASK> %mask)
  call void @__use32(<WIDTH x i32> %g64_32)
  %g64_f = call <WIDTH x float>  @__gather64_float(<WIDTH x i64> %v64,
                                                        <WIDTH x MASK> %mask)
  call void @__usefloat(<WIDTH x float> %g64_f)
  %g64_64 = call <WIDTH x i64>  @__gather64_i64(<WIDTH x i64> %v64,
                                                        <WIDTH x MASK> %mask)
  call void @__use64(<WIDTH x i64> %g64_64)
  %g64_d = call <WIDTH x double>  @__gather64_double(<WIDTH x i64> %v64,
                                                        <WIDTH x MASK> %mask)
  call void @__usedouble(<WIDTH x double> %g64_d)

ifelse(HAVE_GATHER, `1',
`
  %nfpgbo32_8 = call <WIDTH x i8>
       @__pseudo_gather_base_offsets32_i8(i8 * %ptr, i32 0,
                                          <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__use8(<WIDTH x i8> %nfpgbo32_8)
  %nfpgbo32_16 = call <WIDTH x i16>
       @__pseudo_gather_base_offsets32_i16(i8 * %ptr, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__use16(<WIDTH x i16> %nfpgbo32_16)
  %nfpgbo32_32 = call <WIDTH x i32>
       @__pseudo_gather_base_offsets32_i32(i8 * %ptr, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__use32(<WIDTH x i32> %nfpgbo32_32)
  %nfpgbo32_f = call <WIDTH x float>
       @__pseudo_gather_base_offsets32_float(i8 * %ptr, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__usefloat(<WIDTH x float> %nfpgbo32_f)
  %nfpgbo32_64 = call <WIDTH x i64>
       @__pseudo_gather_base_offsets32_i64(i8 * %ptr, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__use64(<WIDTH x i64> %nfpgbo32_64)
  %nfpgbo32_d = call <WIDTH x double>
       @__pseudo_gather_base_offsets32_double(i8 * %ptr, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__usedouble(<WIDTH x double> %nfpgbo32_d)

  %nfpgbo64_8 = call <WIDTH x i8>
       @__pseudo_gather_base_offsets64_i8(i8 * %ptr, i32 0,
                                          <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__use8(<WIDTH x i8> %nfpgbo64_8)
  %nfpgbo64_16 = call <WIDTH x i16>
       @__pseudo_gather_base_offsets64_i16(i8 * %ptr, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__use16(<WIDTH x i16> %nfpgbo64_16)
  %nfpgbo64_32 = call <WIDTH x i32>
       @__pseudo_gather_base_offsets64_i32(i8 * %ptr, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__use32(<WIDTH x i32> %nfpgbo64_32)
  %nfpgbo64_f = call <WIDTH x float>
       @__pseudo_gather_base_offsets64_float(i8 * %ptr, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__usefloat(<WIDTH x float> %nfpgbo64_f)
  %nfpgbo64_64 = call <WIDTH x i64>
       @__pseudo_gather_base_offsets64_i64(i8 * %ptr, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__use64(<WIDTH x i64> %nfpgbo64_64)
  %nfpgbo64_d = call <WIDTH x double>
       @__pseudo_gather_base_offsets64_double(i8 * %ptr, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__usedouble(<WIDTH x double> %nfpgbo64_d)

  %nfgbo32_8 = call <WIDTH x i8>
       @__gather_base_offsets32_i8(i8 * %ptr, i32 0,
                                          <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__use8(<WIDTH x i8> %nfgbo32_8)
  %nfgbo32_16 = call <WIDTH x i16>
       @__gather_base_offsets32_i16(i8 * %ptr, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__use16(<WIDTH x i16> %nfgbo32_16)
  %nfgbo32_32 = call <WIDTH x i32>
       @__gather_base_offsets32_i32(i8 * %ptr, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__use32(<WIDTH x i32> %nfgbo32_32)
  %nfgbo32_f = call <WIDTH x float>
       @__gather_base_offsets32_float(i8 * %ptr, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__usefloat(<WIDTH x float> %nfgbo32_f)
  %nfgbo32_64 = call <WIDTH x i64>
       @__gather_base_offsets32_i64(i8 * %ptr, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__use64(<WIDTH x i64> %nfgbo32_64)
  %nfgbo32_d = call <WIDTH x double>
       @__gather_base_offsets32_double(i8 * %ptr, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__usedouble(<WIDTH x double> %nfgbo32_d)

  %nfgbo64_8 = call <WIDTH x i8>
       @__gather_base_offsets64_i8(i8 * %ptr, i32 0,
                                          <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__use8(<WIDTH x i8> %nfgbo64_8)
  %nfgbo64_16 = call <WIDTH x i16>
       @__gather_base_offsets64_i16(i8 * %ptr, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__use16(<WIDTH x i16> %nfgbo64_16)
  %nfgbo64_32 = call <WIDTH x i32>
       @__gather_base_offsets64_i32(i8 * %ptr, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__use32(<WIDTH x i32> %nfgbo64_32)
  %nfgbo64_f = call <WIDTH x float>
       @__gather_base_offsets64_float(i8 * %ptr, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__usefloat(<WIDTH x float> %nfgbo64_f)
  %nfgbo64_64 = call <WIDTH x i64>
       @__gather_base_offsets64_i64(i8 * %ptr, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__use64(<WIDTH x i64> %nfgbo64_64)
  %nfgbo64_d = call <WIDTH x double>
       @__gather_base_offsets64_double(i8 * %ptr, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__usedouble(<WIDTH x double> %nfgbo64_d)
',
`
  %pgbo32_8 = call <WIDTH x i8>
       @__pseudo_gather_factored_base_offsets32_i8(i8 * %ptr, <WIDTH x i32> %v32, i32 0,
                                          <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__use8(<WIDTH x i8> %pgbo32_8)
  %pgbo32_16 = call <WIDTH x i16>
       @__pseudo_gather_factored_base_offsets32_i16(i8 * %ptr, <WIDTH x i32> %v32, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__use16(<WIDTH x i16> %pgbo32_16)
  %pgbo32_32 = call <WIDTH x i32>
       @__pseudo_gather_factored_base_offsets32_i32(i8 * %ptr, <WIDTH x i32> %v32, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__use32(<WIDTH x i32> %pgbo32_32)
  %pgbo32_f = call <WIDTH x float>
       @__pseudo_gather_factored_base_offsets32_float(i8 * %ptr, <WIDTH x i32> %v32, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__usefloat(<WIDTH x float> %pgbo32_f)
  %pgbo32_64 = call <WIDTH x i64>
       @__pseudo_gather_factored_base_offsets32_i64(i8 * %ptr, <WIDTH x i32> %v32, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__use64(<WIDTH x i64> %pgbo32_64)
  %pgbo32_d = call <WIDTH x double>
       @__pseudo_gather_factored_base_offsets32_double(i8 * %ptr, <WIDTH x i32> %v32, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__usedouble(<WIDTH x double> %pgbo32_d)

  %pgbo64_8 = call <WIDTH x i8>
       @__pseudo_gather_factored_base_offsets64_i8(i8 * %ptr, <WIDTH x i64> %v64, i32 0,
                                          <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__use8(<WIDTH x i8> %pgbo64_8)
  %pgbo64_16 = call <WIDTH x i16>
       @__pseudo_gather_factored_base_offsets64_i16(i8 * %ptr, <WIDTH x i64> %v64, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__use16(<WIDTH x i16> %pgbo64_16)
  %pgbo64_32 = call <WIDTH x i32>
       @__pseudo_gather_factored_base_offsets64_i32(i8 * %ptr, <WIDTH x i64> %v64, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__use32(<WIDTH x i32> %pgbo64_32)
  %pgbo64_f = call <WIDTH x float>
       @__pseudo_gather_factored_base_offsets64_float(i8 * %ptr, <WIDTH x i64> %v64, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__usefloat(<WIDTH x float> %pgbo64_f)
  %pgbo64_64 = call <WIDTH x i64>
       @__pseudo_gather_factored_base_offsets64_i64(i8 * %ptr, <WIDTH x i64> %v64, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__use64(<WIDTH x i64> %pgbo64_64)
  %pgbo64_d = call <WIDTH x double>
       @__pseudo_gather_factored_base_offsets64_double(i8 * %ptr, <WIDTH x i64> %v64, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__usedouble(<WIDTH x double> %pgbo64_d)

  %gbo32_8 = call <WIDTH x i8>
       @__gather_factored_base_offsets32_i8(i8 * %ptr, <WIDTH x i32> %v32, i32 0,
                                          <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__use8(<WIDTH x i8> %gbo32_8)
  %gbo32_16 = call <WIDTH x i16>
       @__gather_factored_base_offsets32_i16(i8 * %ptr, <WIDTH x i32> %v32, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__use16(<WIDTH x i16> %gbo32_16)
  %gbo32_32 = call <WIDTH x i32>
       @__gather_factored_base_offsets32_i32(i8 * %ptr, <WIDTH x i32> %v32, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__use32(<WIDTH x i32> %gbo32_32)
  %gbo32_f = call <WIDTH x float>
       @__gather_factored_base_offsets32_float(i8 * %ptr, <WIDTH x i32> %v32, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__usefloat(<WIDTH x float> %gbo32_f)
  %gbo32_64 = call <WIDTH x i64>
       @__gather_factored_base_offsets32_i64(i8 * %ptr, <WIDTH x i32> %v32, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__use64(<WIDTH x i64> %gbo32_64)
  %gbo32_d = call <WIDTH x double>
       @__gather_factored_base_offsets32_double(i8 * %ptr, <WIDTH x i32> %v32, i32 0,
                                           <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__usedouble(<WIDTH x double> %gbo32_d)

  %gbo64_8 = call <WIDTH x i8>
       @__gather_factored_base_offsets64_i8(i8 * %ptr, <WIDTH x i64> %v64, i32 0,
                                          <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__use8(<WIDTH x i8> %gbo64_8)
  %gbo64_16 = call <WIDTH x i16>
       @__gather_factored_base_offsets64_i16(i8 * %ptr, <WIDTH x i64> %v64, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__use16(<WIDTH x i16> %gbo64_16)
  %gbo64_32 = call <WIDTH x i32>
       @__gather_factored_base_offsets64_i32(i8 * %ptr, <WIDTH x i64> %v64, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__use32(<WIDTH x i32> %gbo64_32)
  %gbo64_f = call <WIDTH x float>
       @__gather_factored_base_offsets64_float(i8 * %ptr, <WIDTH x i64> %v64, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__usefloat(<WIDTH x float> %gbo64_f)
  %gbo64_64 = call <WIDTH x i64>
       @__gather_factored_base_offsets64_i64(i8 * %ptr, <WIDTH x i64> %v64, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__use64(<WIDTH x i64> %gbo64_64)
  %gbo64_d = call <WIDTH x double>
       @__gather_factored_base_offsets64_double(i8 * %ptr, <WIDTH x i64> %v64, i32 0,
                                           <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__usedouble(<WIDTH x double> %pgbo64_d)
')

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; scatters

  call void @__pseudo_scatter32_i8(<WIDTH x i32> %v32, <WIDTH x i8> %v8, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter32_i16(<WIDTH x i32> %v32, <WIDTH x i16> %v16, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter32_i32(<WIDTH x i32> %v32, <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter32_float(<WIDTH x i32> %v32, <WIDTH x float> %vf, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter32_i64(<WIDTH x i32> %v32, <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter32_double(<WIDTH x i32> %v32, <WIDTH x double> %vd, <WIDTH x MASK> %mask)

  call void @__pseudo_scatter64_i8(<WIDTH x i64> %v64, <WIDTH x i8> %v8, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter64_i16(<WIDTH x i64> %v64, <WIDTH x i16> %v16, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter64_i32(<WIDTH x i64> %v64, <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter64_float(<WIDTH x i64> %v64, <WIDTH x float> %vf, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter64_i64(<WIDTH x i64> %v64, <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter64_double(<WIDTH x i64> %v64, <WIDTH x double> %vd, <WIDTH x MASK> %mask)

  call void @__scatter32_i8(<WIDTH x i32> %v32, <WIDTH x i8> %v8, <WIDTH x MASK> %mask)
  call void @__scatter32_i16(<WIDTH x i32> %v32, <WIDTH x i16> %v16, <WIDTH x MASK> %mask)
  call void @__scatter32_i32(<WIDTH x i32> %v32, <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__scatter32_float(<WIDTH x i32> %v32, <WIDTH x float> %vf, <WIDTH x MASK> %mask)
  call void @__scatter32_i64(<WIDTH x i32> %v32, <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__scatter32_double(<WIDTH x i32> %v32, <WIDTH x double> %vd, <WIDTH x MASK> %mask)

  call void @__scatter64_i8(<WIDTH x i64> %v64, <WIDTH x i8> %v8, <WIDTH x MASK> %mask)
  call void @__scatter64_i16(<WIDTH x i64> %v64, <WIDTH x i16> %v16, <WIDTH x MASK> %mask)
  call void @__scatter64_i32(<WIDTH x i64> %v64, <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__scatter64_float(<WIDTH x i64> %v64, <WIDTH x float> %vf, <WIDTH x MASK> %mask)
  call void @__scatter64_i64(<WIDTH x i64> %v64, <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__scatter64_double(<WIDTH x i64> %v64, <WIDTH x double> %vd, <WIDTH x MASK> %mask)

ifelse(HAVE_SCATTER, `1',
`
  call void @__pseudo_scatter_base_offsets32_i8(i8 * %ptr, i32 0, <WIDTH x i32> %v32,
                                                <WIDTH x i8> %v8, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_base_offsets32_i16(i8 * %ptr, i32 0, <WIDTH x i32> %v32,
                                                 <WIDTH x i16> %v16, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_base_offsets32_i32(i8 * %ptr, i32 0, <WIDTH x i32> %v32,
                                                 <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_base_offsets32_float(i8 * %ptr, i32 0, <WIDTH x i32> %v32,
                                                 <WIDTH x float> %vf, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_base_offsets32_i64(i8 * %ptr, i32 0, <WIDTH x i32> %v32,
                                                 <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_base_offsets32_double(i8 * %ptr, i32 0, <WIDTH x i32> %v32,
                                                    <WIDTH x double> %vd, <WIDTH x MASK> %mask)

  call void @__pseudo_scatter_base_offsets64_i8(i8 * %ptr, i32 0, <WIDTH x i64> %v64,
                                                <WIDTH x i8> %v8, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_base_offsets64_i16(i8 * %ptr, i32 0, <WIDTH x i64> %v64,
                                                 <WIDTH x i16> %v16, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_base_offsets64_i32(i8 * %ptr, i32 0, <WIDTH x i64> %v64,
                                                 <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_base_offsets64_float(i8 * %ptr, i32 0, <WIDTH x i64> %v64,
                                                   <WIDTH x float> %vf, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_base_offsets64_i64(i8 * %ptr, i32 0, <WIDTH x i64> %v64,
                                                 <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_base_offsets64_double(i8 * %ptr, i32 0, <WIDTH x i64> %v64,
                                                    <WIDTH x double> %vd, <WIDTH x MASK> %mask)

  call void @__scatter_base_offsets32_i8(i8 * %ptr, i32 0, <WIDTH x i32> %v32,
                                                <WIDTH x i8> %v8, <WIDTH x MASK> %mask)
  call void @__scatter_base_offsets32_i16(i8 * %ptr, i32 0, <WIDTH x i32> %v32,
                                                 <WIDTH x i16> %v16, <WIDTH x MASK> %mask)
  call void @__scatter_base_offsets32_i32(i8 * %ptr, i32 0, <WIDTH x i32> %v32,
                                                 <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__scatter_base_offsets32_float(i8 * %ptr, i32 0, <WIDTH x i32> %v32,
                                                 <WIDTH x float> %vf, <WIDTH x MASK> %mask)
  call void @__scatter_base_offsets32_i64(i8 * %ptr, i32 0, <WIDTH x i32> %v32,
                                                 <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__scatter_base_offsets32_double(i8 * %ptr, i32 0, <WIDTH x i32> %v32,
                                                    <WIDTH x double> %vd, <WIDTH x MASK> %mask)

  call void @__scatter_base_offsets64_i8(i8 * %ptr, i32 0, <WIDTH x i64> %v64,
                                                <WIDTH x i8> %v8, <WIDTH x MASK> %mask)
  call void @__scatter_base_offsets64_i16(i8 * %ptr, i32 0, <WIDTH x i64> %v64,
                                                 <WIDTH x i16> %v16, <WIDTH x MASK> %mask)
  call void @__scatter_base_offsets64_i32(i8 * %ptr, i32 0, <WIDTH x i64> %v64,
                                                 <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__scatter_base_offsets64_float(i8 * %ptr, i32 0, <WIDTH x i64> %v64,
                                                   <WIDTH x float> %vf, <WIDTH x MASK> %mask)
  call void @__scatter_base_offsets64_i64(i8 * %ptr, i32 0, <WIDTH x i64> %v64,
                                                 <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__scatter_base_offsets64_double(i8 * %ptr, i32 0, <WIDTH x i64> %v64,
                                                    <WIDTH x double> %vd, <WIDTH x MASK> %mask)
',
`
  call void @__pseudo_scatter_factored_base_offsets32_i8(i8 * %ptr, <WIDTH x i32> %v32, i32 0, <WIDTH x i32> %v32,
                                                <WIDTH x i8> %v8, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_factored_base_offsets32_i16(i8 * %ptr, <WIDTH x i32> %v32, i32 0, <WIDTH x i32> %v32,
                                                 <WIDTH x i16> %v16, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_factored_base_offsets32_i32(i8 * %ptr, <WIDTH x i32> %v32, i32 0, <WIDTH x i32> %v32,
                                                 <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_factored_base_offsets32_float(i8 * %ptr, <WIDTH x i32> %v32, i32 0, <WIDTH x i32> %v32,
                                                 <WIDTH x float> %vf, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_factored_base_offsets32_i64(i8 * %ptr, <WIDTH x i32> %v32, i32 0, <WIDTH x i32> %v32,
                                                 <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_factored_base_offsets32_double(i8 * %ptr, <WIDTH x i32> %v32, i32 0, <WIDTH x i32> %v32,
                                                    <WIDTH x double> %vd, <WIDTH x MASK> %mask)

  call void @__pseudo_scatter_factored_base_offsets64_i8(i8 * %ptr, <WIDTH x i64> %v64, i32 0, <WIDTH x i64> %v64,
                                                <WIDTH x i8> %v8, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_factored_base_offsets64_i16(i8 * %ptr, <WIDTH x i64> %v64, i32 0, <WIDTH x i64> %v64,
                                                 <WIDTH x i16> %v16, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_factored_base_offsets64_i32(i8 * %ptr, <WIDTH x i64> %v64, i32 0, <WIDTH x i64> %v64,
                                                 <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_factored_base_offsets64_float(i8 * %ptr, <WIDTH x i64> %v64, i32 0, <WIDTH x i64> %v64,
                                                   <WIDTH x float> %vf, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_factored_base_offsets64_i64(i8 * %ptr, <WIDTH x i64> %v64, i32 0, <WIDTH x i64> %v64,
                                                 <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__pseudo_scatter_factored_base_offsets64_double(i8 * %ptr, <WIDTH x i64> %v64, i32 0, <WIDTH x i64> %v64,
                                                    <WIDTH x double> %vd, <WIDTH x MASK> %mask)

  call void @__scatter_factored_base_offsets32_i8(i8 * %ptr, <WIDTH x i32> %v32, i32 0, <WIDTH x i32> %v32,
                                                <WIDTH x i8> %v8, <WIDTH x MASK> %mask)
  call void @__scatter_factored_base_offsets32_i16(i8 * %ptr, <WIDTH x i32> %v32, i32 0, <WIDTH x i32> %v32,
                                                 <WIDTH x i16> %v16, <WIDTH x MASK> %mask)
  call void @__scatter_factored_base_offsets32_i32(i8 * %ptr, <WIDTH x i32> %v32, i32 0, <WIDTH x i32> %v32,
                                                 <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__scatter_factored_base_offsets32_float(i8 * %ptr, <WIDTH x i32> %v32, i32 0, <WIDTH x i32> %v32,
                                                 <WIDTH x float> %vf, <WIDTH x MASK> %mask)
  call void @__scatter_factored_base_offsets32_i64(i8 * %ptr, <WIDTH x i32> %v32, i32 0, <WIDTH x i32> %v32,
                                                 <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__scatter_factored_base_offsets32_double(i8 * %ptr, <WIDTH x i32> %v32, i32 0, <WIDTH x i32> %v32,
                                                    <WIDTH x double> %vd, <WIDTH x MASK> %mask)

  call void @__scatter_factored_base_offsets64_i8(i8 * %ptr, <WIDTH x i64> %v64, i32 0, <WIDTH x i64> %v64,
                                                <WIDTH x i8> %v8, <WIDTH x MASK> %mask)
  call void @__scatter_factored_base_offsets64_i16(i8 * %ptr, <WIDTH x i64> %v64, i32 0, <WIDTH x i64> %v64,
                                                 <WIDTH x i16> %v16, <WIDTH x MASK> %mask)
  call void @__scatter_factored_base_offsets64_i32(i8 * %ptr, <WIDTH x i64> %v64, i32 0, <WIDTH x i64> %v64,
                                                 <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__scatter_factored_base_offsets64_float(i8 * %ptr, <WIDTH x i64> %v64, i32 0, <WIDTH x i64> %v64,
                                                   <WIDTH x float> %vf, <WIDTH x MASK> %mask)
  call void @__scatter_factored_base_offsets64_i64(i8 * %ptr, <WIDTH x i64> %v64, i32 0, <WIDTH x i64> %v64,
                                                 <WIDTH x i64> %v64, <WIDTH x MASK> %mask)
  call void @__scatter_factored_base_offsets64_double(i8 * %ptr, <WIDTH x i64> %v64, i32 0, <WIDTH x i64> %v64,
                                                    <WIDTH x double> %vd, <WIDTH x MASK> %mask)
')

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; prefetchs

  call void @__pseudo_prefetch_read_varying_1(<WIDTH x i64> %v64, <WIDTH x MASK> %mask)

  call void @__pseudo_prefetch_read_varying_1_native(i8 * %ptr, i32 0,
                                                     <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__prefetch_read_varying_1_native(i8 * %ptr, i32 0,
                                              <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__prefetch_read_varying_1(<WIDTH x i64> %v64, <WIDTH x MASK> %mask)

  call void @__pseudo_prefetch_read_varying_2(<WIDTH x i64> %v64, <WIDTH x MASK> %mask)

  call void @__pseudo_prefetch_read_varying_2_native(i8 * %ptr, i32 0,
                                                     <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__prefetch_read_varying_2_native(i8 * %ptr, i32 0,
                                              <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__prefetch_read_varying_2(<WIDTH x i64> %v64, <WIDTH x MASK> %mask)

  call void @__pseudo_prefetch_read_varying_3(<WIDTH x i64> %v64, <WIDTH x MASK> %mask)

  call void @__pseudo_prefetch_read_varying_3_native(i8 * %ptr, i32 0,
                                                     <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__prefetch_read_varying_3_native(i8 * %ptr, i32 0,
                                              <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__prefetch_read_varying_3(<WIDTH x i64> %v64, <WIDTH x MASK> %mask)

  call void @__pseudo_prefetch_read_varying_nt(<WIDTH x i64> %v64, <WIDTH x MASK> %mask)

  call void @__pseudo_prefetch_read_varying_nt_native(i8 * %ptr, i32 0,
                                                     <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__prefetch_read_varying_nt_native(i8 * %ptr, i32 0,
                                              <WIDTH x i32> %v32, <WIDTH x MASK> %mask)
  call void @__prefetch_read_varying_nt(<WIDTH x i64> %v64, <WIDTH x MASK> %mask)

  ret void
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; vector ops

define i1 @__extract_bool(<WIDTH x MASK>, i32) nounwind readnone alwaysinline {
  %extract = extractelement <WIDTH x MASK> %0, i32 %1
  ret i1 %extract
}

define <WIDTH x MASK> @__insert_bool(<WIDTH x MASK>, i32, 
                                   i1) nounwind readnone alwaysinline {
  %insert = insertelement <WIDTH x MASK> %0, MASK %2, i32 %1
  ret <WIDTH x MASK> %insert
}

define i8 @__extract_int8(<WIDTH x i8>, i32) nounwind readnone alwaysinline {
  %extract = extractelement <WIDTH x i8> %0, i32 %1
  ret i8 %extract
}

define <WIDTH x i8> @__insert_int8(<WIDTH x i8>, i32,
                                   i8) nounwind readnone alwaysinline {
  %insert = insertelement <WIDTH x i8> %0, i8 %2, i32 %1
  ret <WIDTH x i8> %insert
}

define i16 @__extract_int16(<WIDTH x i16>, i32) nounwind readnone alwaysinline {
  %extract = extractelement <WIDTH x i16> %0, i32 %1
  ret i16 %extract
}

define <WIDTH x i16> @__insert_int16(<WIDTH x i16>, i32,
                                     i16) nounwind readnone alwaysinline {
  %insert = insertelement <WIDTH x i16> %0, i16 %2, i32 %1
  ret <WIDTH x i16> %insert
}

define i32 @__extract_int32(<WIDTH x i32>, i32) nounwind readnone alwaysinline {
  %extract = extractelement <WIDTH x i32> %0, i32 %1
  ret i32 %extract
}

define <WIDTH x i32> @__insert_int32(<WIDTH x i32>, i32,
                                     i32) nounwind readnone alwaysinline {
  %insert = insertelement <WIDTH x i32> %0, i32 %2, i32 %1
  ret <WIDTH x i32> %insert
}

define i64 @__extract_int64(<WIDTH x i64>, i32) nounwind readnone alwaysinline {
  %extract = extractelement <WIDTH x i64> %0, i32 %1
  ret i64 %extract
}

define <WIDTH x i64> @__insert_int64(<WIDTH x i64>, i32,
                                     i64) nounwind readnone alwaysinline {
  %insert = insertelement <WIDTH x i64> %0, i64 %2, i32 %1
  ret <WIDTH x i64> %insert
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; various bitcasts from one type to another

define <WIDTH x i32> @__intbits_varying_float(<WIDTH x float>) nounwind readnone alwaysinline {
  %float_to_int_bitcast = bitcast <WIDTH x float> %0 to <WIDTH x i32>
  ret <WIDTH x i32> %float_to_int_bitcast
}

define i32 @__intbits_uniform_float(float) nounwind readnone alwaysinline {
  %float_to_int_bitcast = bitcast float %0 to i32
  ret i32 %float_to_int_bitcast
}

define <WIDTH x i64> @__intbits_varying_double(<WIDTH x double>) nounwind readnone alwaysinline {
  %double_to_int_bitcast = bitcast <WIDTH x double> %0 to <WIDTH x i64>
  ret <WIDTH x i64> %double_to_int_bitcast
}

define i64 @__intbits_uniform_double(double) nounwind readnone alwaysinline {
  %double_to_int_bitcast = bitcast double %0 to i64
  ret i64 %double_to_int_bitcast
}

define <WIDTH x float> @__floatbits_varying_int32(<WIDTH x i32>) nounwind readnone alwaysinline {
  %int_to_float_bitcast = bitcast <WIDTH x i32> %0 to <WIDTH x float>
  ret <WIDTH x float> %int_to_float_bitcast
}

define float @__floatbits_uniform_int32(i32) nounwind readnone alwaysinline {
  %int_to_float_bitcast = bitcast i32 %0 to float
  ret float %int_to_float_bitcast
}

define <WIDTH x double> @__doublebits_varying_int64(<WIDTH x i64>) nounwind readnone alwaysinline {
  %int_to_double_bitcast = bitcast <WIDTH x i64> %0 to <WIDTH x double>
  ret <WIDTH x double> %int_to_double_bitcast
}

define double @__doublebits_uniform_int64(i64) nounwind readnone alwaysinline {
  %int_to_double_bitcast = bitcast i64 %0 to double
  ret double %int_to_double_bitcast
}

define <WIDTH x float> @__undef_varying() nounwind readnone alwaysinline {
  ret <WIDTH x float> undef
}

define float @__undef_uniform() nounwind readnone alwaysinline {
  ret float undef
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sign extension

define i32 @__sext_uniform_bool(i1) nounwind readnone alwaysinline {
  %r = sext i1 %0 to i32
  ret i32 %r
}

define <WIDTH x i32> @__sext_varying_bool(<WIDTH x MASK>) nounwind readnone alwaysinline {
;;  ifelse(MASK,i32, `ret <WIDTH x i32> %0',
;; `%se = sext <WIDTH x MASK> %0 to <WIDTH x i32>
;; ret <WIDTH x i32> %se')
  ifelse(MASK,i32, `%se = bitcast <WIDTH x i32> %0 to <WIDTH x i32>',
         MASK,i64, `%se = trunc <WIDTH x MASK> %0 to <WIDTH x i32>',
                   `%se = sext <WIDTH x MASK> %0 to <WIDTH x i32>')
  ret <WIDTH x i32> %se
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; memcpy/memmove/memset

declare void @llvm.memcpy.p0i8.p0i8.i32(i8* %dest, i8* %src,
                                        i32 %len, i32 %align, i1 %isvolatile)
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* %dest, i8* %src,
                                        i64 %len, i32 %align, i1 %isvolatile)

define void @__memcpy32(i8 * %dst, i8 * %src, i32 %len) alwaysinline {
    call void @llvm.memcpy.p0i8.p0i8.i32(i8 * %dst, i8 * %src, i32 %len, i32 0, i1 0)
    ret void
}

define void @__memcpy64(i8 * %dst, i8 * %src, i64 %len) alwaysinline {
    call void @llvm.memcpy.p0i8.p0i8.i64(i8 * %dst, i8 * %src, i64 %len, i32 0, i1 0)
    ret void
}

declare void @llvm.memmove.p0i8.p0i8.i32(i8* %dest, i8* %src,
                                         i32 %len, i32 %align, i1 %isvolatile)
declare void @llvm.memmove.p0i8.p0i8.i64(i8* %dest, i8* %src,
                                         i64 %len, i32 %align, i1 %isvolatile)

define void @__memmove32(i8 * %dst, i8 * %src, i32 %len) alwaysinline {
    call void @llvm.memmove.p0i8.p0i8.i32(i8 * %dst, i8 * %src, i32 %len, i32 0, i1 0)
    ret void
}

define void @__memmove64(i8 * %dst, i8 * %src, i64 %len) alwaysinline {
    call void @llvm.memmove.p0i8.p0i8.i64(i8 * %dst, i8 * %src, i64 %len, i32 0, i1 0)
    ret void
}


declare void @llvm.memset.p0i8.i32(i8* %dest, i8 %val, i32 %len, i32 %align,
                                   i1 %isvolatile)
declare void @llvm.memset.p0i8.i64(i8* %dest, i8 %val, i64 %len, i32 %align,
                                   i1 %isvolatile)

define void @__memset32(i8 * %dst, i8 %val, i32 %len) alwaysinline {
    call void @llvm.memset.p0i8.i32(i8 * %dst, i8 %val, i32 %len, i32 0, i1 0)
    ret void
}

define void @__memset64(i8 * %dst, i8 %val, i64 %len) alwaysinline {
    call void @llvm.memset.p0i8.i64(i8 * %dst, i8 %val, i64 %len, i32 0, i1 0)
    ret void
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; assert

declare <8 x i32> @llvm.genx.dword.atomic.add.v8i32.v8i1.v8i32(<8 x i1>, i32, <8 x i32>, <8 x i32>, <8 x i32>)
declare void @llvm.genx.oword.st.v8i32(i32, i32, <8 x i32>)
declare void @llvm.genx.oword.st.v128i8(i32, i32, <128 x i8>)
declare i32 @llvm.genx.predefined.surface(i32)
declare void @llvm.genx.raw.send.noresult.v32i16.v16i1.v32i16(i32, <16 x i1>, i32, i32, <32 x i16>)


define void @__send_eot() {
;; llvm.genx.raw.send.noresult : vISA RAW_SEND instruction with no result
;;
;; * arg0  i32 modifier whether it is send or sendc, constant
;; * (exec_size inferred from predicate vector width, defaulting to 16
;;          if predicate is i1)
;; * arg1: i1/vXi1 predicate
;; * arg2: i32 extended message descriptor, constant
;; * (numsrc inferred from src size)
;;       (numdst is 0)
;; * arg3: i32 desc
;; * arg4: src
;;
;; The SEND instruction has a field for the size of src. This is inferred by
;; rounding the size of src up to the next whole GRF.
;;
;; The predicate must be constant i1 with value 1 for a message that is not
;; predicatable. For a predicatable message, it must be a vector of i1 with
;; width determining the execution size.
;;
;;arg2 (ExtMsge) :
;; [31:12]   Extended Function Control
;; [11]              CPS LOD Compensation, MBZ
;; [10:6]    Extended Message Length
;; [4]               Reserved [5] EOT
;; [3:0]             Target Function ID
;;
;; 33554448 = 0b10000000000000000000010000
  call void @llvm.genx.raw.send.noresult.v32i16.v16i1.v32i16(i32 0, <16 x i1>  <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, i32 39, i32 33554448, <32 x i16> zeroinitializer)
  ret void
}

define internal void @__do_print_cm(i8*) alwaysinline {
;; predefined.surface return Value: surface index of the specified id
;; id 2 is stdout
  %buf = tail call i32 @llvm.genx.predefined.surface(i32 2)
  %atomic_add = tail call <8 x i32> @llvm.genx.dword.atomic.add.v8i32.v8i1.v8i32(<8 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, i32 %buf, <8 x i32> <i32 0, i32 4, i32 8,
i32 12, i32 16, i32 20, i32 24, i32 28>, <8 x i32> <i32 192, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0>, <8 x i32> zeroinitializer), !ISPC-Uniform !1
  %extract = extractelement <8 x i32> %atomic_add, i32 0
  %lshr1 = lshr i32 %extract, 4
  tail call void @llvm.genx.oword.st.v8i32(i32 %buf, i32 %lshr1, <8 x i32> <i32 5, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0>), !ISPC-Uniform !1
  %add1 = add i32 %extract, 32
  %lshr2 = lshr i32 %add1, 4
  %strpointer = bitcast i8* %0 to <128 x i8>*
  %str1 = load PTR_OP_ARGS(`<128 x i8> ')  %strpointer
;; 128 is maximalsize for oword.st
;; TODO: add strlen as function parameter and call @llvm.genx.oword.st.v128i8 in a loop
  tail call void @llvm.genx.oword.st.v128i8(i32 %buf, i32 %lshr2, <128 x i8> %str1), !ISPC-Uniform !1
  ret void
}


define void @__do_assert_uniform(i8 *%str, i1 %test, <WIDTH x MASK> %mask) {
  br i1 %test, label %ok, label %fail

fail:
  call void @__do_print_cm(i8* %str)
  call void @__send_eot()
  ret void

ok:
  ret void
}


define void @__do_assert_varying(i8 *%str, <WIDTH x MASK> %test,
                                 <WIDTH x MASK> %mask) {
  %nottest = xor <WIDTH x MASK> %test,
                 < forloop(i, 1, eval(WIDTH-1), `MASK -1, ') MASK -1 >
  %nottest_and_mask = and <WIDTH x MASK> %nottest, %mask
  %mm = call i64 @__movmsk(<WIDTH x MASK> %nottest_and_mask)
  %all_ok = icmp eq i64 %mm, 0
  br i1 %all_ok, label %ok, label %fail

fail:
  call void @__do_print_cm(i8* %str)
  call void @__send_eot()
  ret void

ok:
  ret void
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; new/delete

;; Set of functions for 32 bit runtime.
;; They are different for Windows and Unix (Linux/MacOS),
;; on Windows we have to use _aligned_malloc/_aligned_free,
;; while on Unix we use posix_memalign/free
;;
;; Note that this should be really two different libraries for 32 and 64
;; environment and it should happen sooner or later

ifelse(WIDTH, 1, `define(`ALIGNMENT', `16')', `define(`ALIGNMENT', `eval(WIDTH*4)')')

@memory_alignment = internal constant i32 ALIGNMENT

ifelse(BUILD_OS, `UNIX',
`

ifelse(RUNTIME, `32',
`

;; Unix 32 bit environment.
;; Use: posix_memalign and free
;; Define:
;; - __new_uniform_32rt
;; - __new_varying32_32rt
;; - __delete_uniform_32rt
;; - __delete_varying_32rt

declare i32 @posix_memalign(i8**, i32, i32)
declare void @free(i8 *)

define noalias i8 * @__new_uniform_32rt(i64 %size) {
  %ptr = alloca i8*
  %conv = trunc i64 %size to i32
  %alignment = load PTR_OP_ARGS(`i32')  @memory_alignment
  %call1 = call i32 @posix_memalign(i8** %ptr, i32 %alignment, i32 %conv)
  %ptr_val = load PTR_OP_ARGS(`i8*')  %ptr
  ret i8* %ptr_val
}

define <WIDTH x i64> @__new_varying32_32rt(<WIDTH x i32> %size, <WIDTH x MASK> %mask) {
  %ret = alloca <WIDTH x i64>
  store <WIDTH x i64> zeroinitializer, <WIDTH x i64> * %ret
  %ret64 = bitcast <WIDTH x i64> * %ret to i64 *
  %alignment = load PTR_OP_ARGS(`i32')  @memory_alignment

  per_lane(WIDTH, <WIDTH x MASK> %mask, `
    %sz_LANE_ID = extractelement <WIDTH x i32> %size, i32 LANE
    %store_LANE_ID = getelementptr PTR_OP_ARGS(`i64') %ret64, i32 LANE
    %ptr_LANE_ID = bitcast i64* %store_LANE_ID to i8**
    %call_LANE_ID = call i32 @posix_memalign(i8** %ptr_LANE_ID, i32 %alignment, i32 %sz_LANE_ID)')

  %r = load PTR_OP_ARGS(`<WIDTH x i64> ')  %ret
  ret <WIDTH x i64> %r
}

define void @__delete_uniform_32rt(i8 * %ptr) {
  call void @free(i8 * %ptr)
  ret void
}

define void @__delete_varying_32rt(<WIDTH x i64> %ptr, <WIDTH x MASK> %mask) {
  per_lane(WIDTH, <WIDTH x MASK> %mask, `
      %iptr_LANE_ID = extractelement <WIDTH x i64> %ptr, i32 LANE
      %ptr_LANE_ID = inttoptr i64 %iptr_LANE_ID to i8 *
      call void @free(i8 * %ptr_LANE_ID)
  ')
  ret void
}

',
RUNTIME, `64',
`

;; Unix 64 bit environment.
;; Use: posix_memalign and free
;; Define:
;; - __new_uniform_64rt
;; - __new_varying32_64rt
;; - __new_varying64_64rt
;; - __delete_uniform_64rt
;; - __delete_varying_64rt

declare i32 @posix_memalign(i8**, i64, i64)
declare void @free(i8 *)

define noalias i8 * @__new_uniform_64rt(i64 %size) {
  %ptr = alloca i8*
  %alignment = load PTR_OP_ARGS(`i32')  @memory_alignment
  %alignment64 = sext i32 %alignment to i64
  %call1 = call i32 @posix_memalign(i8** %ptr, i64 %alignment64, i64 %size)
  %ptr_val = load PTR_OP_ARGS(`i8*') %ptr
  ret i8* %ptr_val
}

define <WIDTH x i64> @__new_varying32_64rt(<WIDTH x i32> %size, <WIDTH x MASK> %mask) {
  %ret = alloca <WIDTH x i64>
  store <WIDTH x i64> zeroinitializer, <WIDTH x i64> * %ret
  %ret64 = bitcast <WIDTH x i64> * %ret to i64 *
  %alignment = load PTR_OP_ARGS(`i32')  @memory_alignment
  %alignment64 = sext i32 %alignment to i64

  per_lane(WIDTH, <WIDTH x MASK> %mask, `
    %sz_LANE_ID = extractelement <WIDTH x i32> %size, i32 LANE
    %sz64_LANE_ID = zext i32 %sz_LANE_ID to i64
    %store_LANE_ID = getelementptr PTR_OP_ARGS(`i64') %ret64, i32 LANE
    %ptr_LANE_ID = bitcast i64* %store_LANE_ID to i8**
    %call_LANE_ID = call i32 @posix_memalign(i8** %ptr_LANE_ID, i64 %alignment64, i64 %sz64_LANE_ID)')

  %r = load PTR_OP_ARGS(`<WIDTH x i64> ')  %ret
  ret <WIDTH x i64> %r
}

define <WIDTH x i64> @__new_varying64_64rt(<WIDTH x i64> %size, <WIDTH x MASK> %mask) {
  %ret = alloca <WIDTH x i64>
  store <WIDTH x i64> zeroinitializer, <WIDTH x i64> * %ret
  %ret64 = bitcast <WIDTH x i64> * %ret to i64 *
  %alignment = load PTR_OP_ARGS(`i32')  @memory_alignment
  %alignment64 = sext i32 %alignment to i64

  per_lane(WIDTH, <WIDTH x MASK> %mask, `
    %sz64_LANE_ID = extractelement <WIDTH x i64> %size, i32 LANE
    %store_LANE_ID = getelementptr PTR_OP_ARGS(`i64') %ret64, i32 LANE
    %ptr_LANE_ID = bitcast i64* %store_LANE_ID to i8**
    %call_LANE_ID = call i32 @posix_memalign(i8** %ptr_LANE_ID, i64 %alignment64, i64 %sz64_LANE_ID)')

  %r = load PTR_OP_ARGS(`<WIDTH x i64> ')  %ret
  ret <WIDTH x i64> %r
}

define void @__delete_uniform_64rt(i8 * %ptr) {
  call void @free(i8 * %ptr)
  ret void
}

define void @__delete_varying_64rt(<WIDTH x i64> %ptr, <WIDTH x MASK> %mask) {
  per_lane(WIDTH, <WIDTH x MASK> %mask, `
      %iptr_LANE_ID = extractelement <WIDTH x i64> %ptr, i32 LANE
      %ptr_LANE_ID = inttoptr i64 %iptr_LANE_ID to i8 *
      call void @free(i8 * %ptr_LANE_ID)
  ')
  ret void
}

', `
errprint(`RUNTIME should be defined to either 32 or 64
')
m4exit(`1')
')

',
BUILD_OS, `WINDOWS',
`

ifelse(RUNTIME, `32',
`

;; Windows 32 bit environment.
;; Use: _aligned_malloc and _aligned_free
;; Define:
;; - __new_uniform_32rt
;; - __new_varying32_32rt
;; - __delete_uniform_32rt
;; - __delete_varying_32rt

declare i8* @_aligned_malloc(i32, i32)
declare void @_aligned_free(i8 *)

define noalias i8 * @__new_uniform_32rt(i64 %size) {
  %conv = trunc i64 %size to i32
  %alignment = load PTR_OP_ARGS(`i32')  @memory_alignment
  %ptr = tail call i8* @_aligned_malloc(i32 %conv, i32 %alignment)
  ret i8* %ptr
}

define <WIDTH x i64> @__new_varying32_32rt(<WIDTH x i32> %size, <WIDTH x MASK> %mask) {
  %ret = alloca <WIDTH x i64>
  store <WIDTH x i64> zeroinitializer, <WIDTH x i64> * %ret
  %ret64 = bitcast <WIDTH x i64> * %ret to i64 *
  %alignment = load PTR_OP_ARGS(`i32')  @memory_alignment

  per_lane(WIDTH, <WIDTH x MASK> %mask, `
    %sz_LANE_ID = extractelement <WIDTH x i32> %size, i32 LANE
    %ptr_LANE_ID = call noalias i8 * @_aligned_malloc(i32 %sz_LANE_ID, i32 %alignment)
    %ptr_int_LANE_ID = ptrtoint i8 * %ptr_LANE_ID to i64
    %store_LANE_ID = getelementptr PTR_OP_ARGS(`i64') %ret64, i32 LANE
    store i64 %ptr_int_LANE_ID, i64 * %store_LANE_ID')

  %r = load PTR_OP_ARGS(`<WIDTH x i64> ')  %ret
  ret <WIDTH x i64> %r
}

define void @__delete_uniform_32rt(i8 * %ptr) {
  call void @_aligned_free(i8 * %ptr)
  ret void
}

define void @__delete_varying_32rt(<WIDTH x i64> %ptr, <WIDTH x MASK> %mask) {
  per_lane(WIDTH, <WIDTH x MASK> %mask, `
      %iptr_LANE_ID = extractelement <WIDTH x i64> %ptr, i32 LANE
      %ptr_LANE_ID = inttoptr i64 %iptr_LANE_ID to i8 *
      call void @_aligned_free(i8 * %ptr_LANE_ID)
  ')
  ret void
}

',
RUNTIME, `64',
`

;; Windows 64 bit environment.
;; Use: _aligned_malloc and _aligned_free
;; Define:
;; - __new_uniform_64rt
;; - __new_varying32_64rt
;; - __new_varying64_64rt
;; - __delete_uniform_64rt
;; - __delete_varying_64rt

declare i8* @_aligned_malloc(i64, i64)
declare void @_aligned_free(i8 *)

define noalias i8 * @__new_uniform_64rt(i64 %size) {
  %alignment = load PTR_OP_ARGS(`i32')  @memory_alignment
  %alignment64 = sext i32 %alignment to i64
  %ptr = tail call i8* @_aligned_malloc(i64 %size, i64 %alignment64)
  ret i8* %ptr
}

define <WIDTH x i64> @__new_varying32_64rt(<WIDTH x i32> %size, <WIDTH x MASK> %mask) {
  %ret = alloca <WIDTH x i64>
  store <WIDTH x i64> zeroinitializer, <WIDTH x i64> * %ret
  %ret64 = bitcast <WIDTH x i64> * %ret to i64 *
  %alignment = load PTR_OP_ARGS(`i32')  @memory_alignment
  %alignment64 = sext i32 %alignment to i64

  per_lane(WIDTH, <WIDTH x MASK> %mask, `
    %sz_LANE_ID = extractelement <WIDTH x i32> %size, i32 LANE
    %sz64_LANE_ID = zext i32 %sz_LANE_ID to i64
    %ptr_LANE_ID = call noalias i8 * @_aligned_malloc(i64 %sz64_LANE_ID, i64 %alignment64)
    %ptr_int_LANE_ID = ptrtoint i8 * %ptr_LANE_ID to i64
    %store_LANE_ID = getelementptr PTR_OP_ARGS(`i64') %ret64, i32 LANE
    store i64 %ptr_int_LANE_ID, i64 * %store_LANE_ID')

  %r = load PTR_OP_ARGS(`<WIDTH x i64> ')  %ret
  ret <WIDTH x i64> %r
}

define <WIDTH x i64> @__new_varying64_64rt(<WIDTH x i64> %size, <WIDTH x MASK> %mask) {
  %ret = alloca <WIDTH x i64>
  store <WIDTH x i64> zeroinitializer, <WIDTH x i64> * %ret
  %ret64 = bitcast <WIDTH x i64> * %ret to i64 *
  %alignment = load PTR_OP_ARGS(`i32')  @memory_alignment
  %alignment64 = sext i32 %alignment to i64

  per_lane(WIDTH, <WIDTH x MASK> %mask, `
    %sz64_LANE_ID = extractelement <WIDTH x i64> %size, i32 LANE
    %ptr_LANE_ID = call noalias i8 * @_aligned_malloc(i64 %sz64_LANE_ID, i64 %alignment64)
    %ptr_int_LANE_ID = ptrtoint i8 * %ptr_LANE_ID to i64
    %store_LANE_ID = getelementptr PTR_OP_ARGS(`i64') %ret64, i32 LANE
    store i64 %ptr_int_LANE_ID, i64 * %store_LANE_ID')

  %r = load PTR_OP_ARGS(`<WIDTH x i64> ')  %ret
  ret <WIDTH x i64> %r
}

define void @__delete_uniform_64rt(i8 * %ptr) {
  call void @_aligned_free(i8 * %ptr)
  ret void
}

define void @__delete_varying_64rt(<WIDTH x i64> %ptr, <WIDTH x MASK> %mask) {
  per_lane(WIDTH, <WIDTH x MASK> %mask, `
      %iptr_LANE_ID = extractelement <WIDTH x i64> %ptr, i32 LANE
      %ptr_LANE_ID = inttoptr i64 %iptr_LANE_ID to i8 *
      call void @_aligned_free(i8 * %ptr_LANE_ID)
  ')
  ret void
}

', `
errprint(`RUNTIME should be defined to either 32 or 64
')
m4exit(`1')
')

',
`
errprint(`BUILD_OS should be defined to either UNIX or WINDOWS
')
m4exit(`1')
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; read hw clock

;; This intrinsic returns time stamp information as a vector of 4 32bit values:
;; 1st and 2nd are the low and high bits of the 64bit timestamp,
;; 3rd contain a bit that is set when a context switch occurs,
;; and the 4th is unused.
declare <4 x i32> @llvm.genx.timestamp.v4i32()

define i64 @__clock() nounwind {
  %r = call <4 x i32> @llvm.genx.timestamp.v4i32()
  %low = extractelement <4 x i32> %r, i32 0
  %low64 = zext i32 %low to i64
  %high = extractelement <4 x i32> %r, i32 1
  %high64 = zext i32 %high to i64
  %highshift = shl i64 %high64,32
  %res = or i64 %highshift, %low64
  ret i64 %res
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; stdlib transcendentals
;;
;; These functions provide entrypoints that call out to the libm
;; implementations of the transcendental functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

declare float @sinf(float) nounwind readnone
declare float @cosf(float) nounwind readnone
declare void @sincosf(float, float *, float *) nounwind
declare float @asinf(float) nounwind readnone
declare float @acosf(float) nounwind readnone
declare float @tanf(float) nounwind readnone
declare float @atanf(float) nounwind readnone
declare float @atan2f(float, float) nounwind readnone
declare float @expf(float) nounwind readnone
declare float @logf(float) nounwind readnone
declare float @powf(float, float) nounwind readnone

define float @__stdlib_sinf(float) nounwind readnone alwaysinline {
  %r = call float @sinf(float %0)
  ret float %r
}

define float @__stdlib_cosf(float) nounwind readnone alwaysinline {
  %r = call float @cosf(float %0)
  ret float %r
}

define void @__stdlib_sincosf(float, float *, float *) nounwind alwaysinline {
  call void @sincosf(float %0, float *%1, float *%2)
  ret void
}

define float @__stdlib_asinf(float) nounwind readnone alwaysinline {
  %r = call float @asinf(float %0)
  ret float %r
}

define float @__stdlib_acosf(float) nounwind readnone alwaysinline {
  %r = call float @acosf(float %0)
  ret float %r
}

define float @__stdlib_tanf(float) nounwind readnone alwaysinline {
  %r = call float @tanf(float %0)
  ret float %r
}

define float @__stdlib_atanf(float) nounwind readnone alwaysinline {
  %r = call float @atanf(float %0)
  ret float %r
}

define float @__stdlib_atan2f(float, float) nounwind readnone alwaysinline {
  %r = call float @atan2f(float %0, float %1)
  ret float %r
}

define float @__stdlib_logf(float) nounwind readnone alwaysinline {
  %r = call float @logf(float %0)
  ret float %r
}

define float @__stdlib_expf(float) nounwind readnone alwaysinline {
  %r = call float @expf(float %0)
  ret float %r
}

define float @__stdlib_powf(float, float) nounwind readnone alwaysinline {
  %r = call float @powf(float %0, float %1)
  ret float %r
}

declare double @sin(double) nounwind readnone
declare double @asin(double) nounwind readnone
declare double @cos(double) nounwind readnone
declare void @sincos(double, double *, double *) nounwind
declare double @tan(double) nounwind readnone
declare double @atan(double) nounwind readnone
declare double @atan2(double, double) nounwind readnone
declare double @exp(double) nounwind readnone
declare double @log(double) nounwind readnone
declare double @pow(double, double) nounwind readnone

define double @__stdlib_sin(double) nounwind readnone alwaysinline {
  %r = call double @sin(double %0)
  ret double %r
}

define double @__stdlib_asin(double) nounwind readnone alwaysinline {
  %r = call double @asin(double %0)
  ret double %r
}

define double @__stdlib_cos(double) nounwind readnone alwaysinline {
  %r = call double @cos(double %0)
  ret double %r
}

define void @__stdlib_sincos(double, double *, double *) nounwind alwaysinline {
  call void @sincos(double %0, double *%1, double *%2)
  ret void
}

define double @__stdlib_tan(double) nounwind readnone alwaysinline {
  %r = call double @tan(double %0)
  ret double %r
}

define double @__stdlib_atan(double) nounwind readnone alwaysinline {
  %r = call double @atan(double %0)
  ret double %r
}

define double @__stdlib_atan2(double, double) nounwind readnone alwaysinline {
  %r = call double @atan2(double %0, double %1)
  ret double %r
}

define double @__stdlib_log(double) nounwind readnone alwaysinline {
  %r = call double @log(double %0)
  ret double %r
}

define double @__stdlib_exp(double) nounwind readnone alwaysinline {
  %r = call double @exp(double %0)
  ret double %r
}

define double @__stdlib_pow(double, double) nounwind readnone alwaysinline {
  %r = call double @pow(double %0, double %1)
  ret double %r
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; atomics and memory barriers

define void @__memory_barrier() nounwind readnone alwaysinline {
  ;; see http://llvm.org/bugs/show_bug.cgi?id=2829.  It seems like we
  ;; only get an MFENCE on x86 if "device" is true, but IMHO we should
  ;; in the case where the first 4 args are true but it is false.
  ;; So we just always set that to true...
  ;; LLVM.MEMORY.BARRIER was deprecated from version 3.0
  ;; Replacing it with relevant instruction
  fence seq_cst
  ret void
}

global_atomic_associative(WIDTH, add, i32, int32, 0)
global_atomic_associative(WIDTH, sub, i32, int32, 0)
global_atomic_associative(WIDTH, and, i32, int32, -1)
global_atomic_associative(WIDTH, or, i32, int32, 0)
global_atomic_associative(WIDTH, xor, i32, int32, 0)
global_atomic_uniform(WIDTH, add, i32, int32)
global_atomic_uniform(WIDTH, sub, i32, int32)
global_atomic_uniform(WIDTH, and, i32, int32)
global_atomic_uniform(WIDTH, or, i32, int32)
global_atomic_uniform(WIDTH, xor, i32, int32)
global_atomic_uniform(WIDTH, min, i32, int32)
global_atomic_uniform(WIDTH, max, i32, int32)
global_atomic_uniform(WIDTH, umin, i32, uint32)
global_atomic_uniform(WIDTH, umax, i32, uint32)

global_atomic_associative(WIDTH, add, i64, int64, 0)
global_atomic_associative(WIDTH, sub, i64, int64, 0)
global_atomic_associative(WIDTH, and, i64, int64, -1)
global_atomic_associative(WIDTH, or, i64, int64, 0)
global_atomic_associative(WIDTH, xor, i64, int64, 0)
global_atomic_uniform(WIDTH, add, i64, int64)
global_atomic_uniform(WIDTH, sub, i64, int64)
global_atomic_uniform(WIDTH, and, i64, int64)
global_atomic_uniform(WIDTH, or, i64, int64)
global_atomic_uniform(WIDTH, xor, i64, int64)
global_atomic_uniform(WIDTH, min, i64, int64)
global_atomic_uniform(WIDTH, max, i64, int64)
global_atomic_uniform(WIDTH, umin, i64, uint64)
global_atomic_uniform(WIDTH, umax, i64, uint64)

global_swap(WIDTH, i32, int32)
global_swap(WIDTH, i64, int64)

define float @__atomic_swap_uniform_float_global(float * %ptr, float %val) nounwind alwaysinline {
  %iptr = bitcast float * %ptr to i32 *
  %ival = bitcast float %val to i32
  %iret = call i32 @__atomic_swap_uniform_int32_global(i32 * %iptr, i32 %ival)
  %ret = bitcast i32 %iret to float
  ret float %ret
}

define double @__atomic_swap_uniform_double_global(double * %ptr, double %val) nounwind alwaysinline {
  %iptr = bitcast double * %ptr to i64 *
  %ival = bitcast double %val to i64
  %iret = call i64 @__atomic_swap_uniform_int64_global(i64 * %iptr, i64 %ival)
  %ret = bitcast i64 %iret to double
  ret double %ret
}

global_atomic_exchange(WIDTH, i32, int32)
global_atomic_exchange(WIDTH, i64, int64)

define <WIDTH x float> @__atomic_compare_exchange_float_global(float * %ptr,
                      <WIDTH x float> %cmp, <WIDTH x float> %val, <WIDTH x MASK> %mask) nounwind alwaysinline {
  %iptr = bitcast float * %ptr to i32 *
  %icmp = bitcast <WIDTH x float> %cmp to <WIDTH x i32>
  %ival = bitcast <WIDTH x float> %val to <WIDTH x i32>
  %iret = call <WIDTH x i32> @__atomic_compare_exchange_int32_global(i32 * %iptr, <WIDTH x i32> %icmp,
                                                                  <WIDTH x i32> %ival, <WIDTH x MASK> %mask)
  %ret = bitcast <WIDTH x i32> %iret to <WIDTH x float>
  ret <WIDTH x float> %ret
}

define <WIDTH x double> @__atomic_compare_exchange_double_global(double * %ptr,
                      <WIDTH x double> %cmp, <WIDTH x double> %val, <WIDTH x MASK> %mask) nounwind alwaysinline {
  %iptr = bitcast double * %ptr to i64 *
  %icmp = bitcast <WIDTH x double> %cmp to <WIDTH x i64>
  %ival = bitcast <WIDTH x double> %val to <WIDTH x i64>
  %iret = call <WIDTH x i64> @__atomic_compare_exchange_int64_global(i64 * %iptr, <WIDTH x i64> %icmp,
                                                                  <WIDTH x i64> %ival, <WIDTH x MASK> %mask)
  %ret = bitcast <WIDTH x i64> %iret to <WIDTH x double>
  ret <WIDTH x double> %ret
}

define float @__atomic_compare_exchange_uniform_float_global(float * %ptr, float %cmp,
                                                             float %val) nounwind alwaysinline {
  %iptr = bitcast float * %ptr to i32 *
  %icmp = bitcast float %cmp to i32
  %ival = bitcast float %val to i32
  %iret = call i32 @__atomic_compare_exchange_uniform_int32_global(i32 * %iptr, i32 %icmp,
                                                                   i32 %ival)
  %ret = bitcast i32 %iret to float
  ret float %ret
}

define double @__atomic_compare_exchange_uniform_double_global(double * %ptr, double %cmp,
                                                               double %val) nounwind alwaysinline {
  %iptr = bitcast double * %ptr to i64 *
  %icmp = bitcast double %cmp to i64
  %ival = bitcast double %val to i64
  %iret = call i64 @__atomic_compare_exchange_uniform_int64_global(i64 * %iptr, i64 %icmp, i64 %ival)
  %ret = bitcast i64 %iret to double
  ret double %ret
}

')


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emit general-purpose code to do a masked load for targets that dont have
;; an instruction to do that.  Parameters:
;; $1: element type for which to emit the function (i32, i64, ...) (and suffix for function name)
;; $2: alignment for elements of type $1 (4, 8, ...)

define(`masked_load', `
define <WIDTH x $1> @__masked_load_$1(i8 *, <WIDTH x MASK> %mask) nounwind alwaysinline {
entry:
  %retptr = alloca <WIDTH x $1>
  %mm = call i64 @__movmsk(<WIDTH x MASK> %mask)

  ; if the first lane and the last lane are on, then it is safe to do a vector load
  ; of the whole thing--what the lanes in the middle want turns out to not matter...
  %mm_and_low = and i64 %mm, 1
  %mm_and_high = and i64 %mm, MASK_HIGH_BIT_ON
  %mm_and_high_shift = lshr i64 %mm_and_high, eval(WIDTH-1)
  %mm_and_low_i1 = trunc i64 %mm_and_low to i1
  %mm_and_high_shift_i1 = trunc i64 %mm_and_high_shift to i1
  %can_vload = and i1 %mm_and_low_i1, %mm_and_high_shift_i1

  %fast32 = call i32 @__fast_masked_vload()
  %fast_i1 = trunc i32 %fast32 to i1
  %can_vload_maybe_fast = or i1 %fast_i1, %can_vload

  ; if we are not able to do a singe vload, we will accumulate lanes in this memory..
  %retptr32 = bitcast <WIDTH x $1> * %retptr to $1 *
  br i1 %can_vload_maybe_fast, label %load, label %loop

load:
  %ptr = bitcast i8 * %0 to <WIDTH x $1> *
  %valall = load PTR_OP_ARGS(`<WIDTH x $1> ')  %ptr, align $2
  ret <WIDTH x $1> %valall

loop:
  ; loop over the lanes and see if each one is on...
  %lane = phi i32 [ 0, %entry ], [ %next_lane, %lane_done ]
  %lane64 = zext i32 %lane to i64
  %lanemask = shl i64 1, %lane64
  %mask_and = and i64 %mm, %lanemask
  %do_lane = icmp ne i64 %mask_and, 0
  br i1 %do_lane, label %load_lane, label %lane_done

load_lane:
  ; yes!  do the load and store the result into the appropriate place in the
  ; allocaed memory above
  %ptr32 = bitcast i8 * %0 to $1 *
  %lane_ptr = getelementptr PTR_OP_ARGS(`$1') %ptr32, i32 %lane
  %val = load PTR_OP_ARGS(`$1 ')  %lane_ptr
  %store_ptr = getelementptr PTR_OP_ARGS(`$1') %retptr32, i32 %lane
  store $1 %val, $1 * %store_ptr
  br label %lane_done

lane_done:
  %next_lane = add i32 %lane, 1
  %done = icmp eq i32 %lane, eval(WIDTH-1)
  br i1 %done, label %return, label %loop

return:
  %r = load PTR_OP_ARGS(`<WIDTH x $1> ')  %retptr
  ret <WIDTH x $1> %r
}
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; streaming stores

define(`gen_streaming_stores_varying_by_type', `
define void @__streaming_store_varying_$1($1* nocapture, <WIDTH x $1>) nounwind alwaysinline {
  %ptr = bitcast $1* %0 to <WIDTH x $1>*
  store <WIDTH x $1> %1, <WIDTH x $1>* %ptr , !nontemporal !1
  ret void
}
')

define(`gen_streaming_stores_uniform_by_type', `
define void @__streaming_store_uniform_$1($1* nocapture, $1) nounwind alwaysinline {
  store $1 %1, $1 * %0 , !nontemporal !1
  ret void
}
')

define(`gen_streaming_stores_metadata', `
  !1 = !{i32 1}
')

define(`gen_streaming_stores_varying', `
  gen_streaming_stores_varying_by_type(float)
  gen_streaming_stores_varying_by_type(double)
  gen_streaming_stores_varying_by_type(i8)
  gen_streaming_stores_varying_by_type(i16)
  gen_streaming_stores_varying_by_type(i32)
  gen_streaming_stores_varying_by_type(i64)
')

define(`gen_streaming_stores_uniform', `
  gen_streaming_stores_uniform_by_type(float)
  gen_streaming_stores_uniform_by_type(double)
  gen_streaming_stores_uniform_by_type(i8)
  gen_streaming_stores_uniform_by_type(i16)
  gen_streaming_stores_uniform_by_type(i32)
  gen_streaming_stores_uniform_by_type(i64)
')

define(`gen_streaming_stores', `
  gen_streaming_stores_varying()
  gen_streaming_stores_uniform()
  gen_streaming_stores_metadata()
')

gen_streaming_stores()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; streaming loads

define(`gen_streaming_loads_varying_by_type', `
  define <WIDTH x $1> @__streaming_load_varying_$1($1* nocapture) nounwind alwaysinline {
  %ptr = bitcast $1* %0 to <WIDTH x $1>*
  %loadval = load PTR_OP_ARGS(`<WIDTH x $1>') %ptr , !nontemporal !1
  ret <WIDTH x $1> %loadval
}
')

define(`gen_streaming_loads_uniform_by_type', `
define $1 @__streaming_load_uniform_$1($1* nocapture) nounwind alwaysinline {
  %loadval = load PTR_OP_ARGS(`$1') %0 , !nontemporal !1
  ret $1 %loadval
}
')

define(`gen_streaming_loads_varying', `
  gen_streaming_loads_varying_by_type(float)
  gen_streaming_loads_varying_by_type(double)
  gen_streaming_loads_varying_by_type(i8)
  gen_streaming_loads_varying_by_type(i16)
  gen_streaming_loads_varying_by_type(i32)
  gen_streaming_loads_varying_by_type(i64)
')

define(`gen_streaming_loads_uniform', `
  gen_streaming_loads_uniform_by_type(float)
  gen_streaming_loads_uniform_by_type(double)
  gen_streaming_loads_uniform_by_type(i8)
  gen_streaming_loads_uniform_by_type(i16)
  gen_streaming_loads_uniform_by_type(i32)
  gen_streaming_loads_uniform_by_type(i64)
')

define(`gen_streaming_loads', `
  gen_streaming_loads_varying()
  gen_streaming_loads_uniform()
')

gen_streaming_loads()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; masked store
;; emit code to do masked store as a set of per-lane scalar stores
;; parameters:
;; $1: llvm type of elements (and suffix for function name)

define(`gen_masked_store', `
define void @__masked_store_$1(<WIDTH x $1>* nocapture, <WIDTH x $1>, <WIDTH x MASK>) nounwind alwaysinline {
  per_lane(WIDTH, <WIDTH x MASK> %2, `
      %ptr_LANE_ID = getelementptr PTR_OP_ARGS(`<WIDTH x $1>') %0, i32 0, i32 LANE
      %storeval_LANE_ID = extractelement <WIDTH x $1> %1, i32 LANE
      store $1 %storeval_LANE_ID, $1 * %ptr_LANE_ID')
  ret void
}
')

define(`masked_store_blend_8_16_by_4', `
define void @__masked_store_blend_i8(<4 x i8>* nocapture, <4 x i8>,
                                     <4 x i32>) nounwind alwaysinline {
  %old = load PTR_OP_ARGS(`<4 x i8> ')  %0, align 1

  %m = trunc <4 x i32> %2 to <4 x i1>
  %resultvec = select <4 x i1> %m, <4 x i8> %1, <4 x i8> %old

  store <4 x i8> %resultvec, <4 x i8> * %0, align 1
  ret void
}

define void @__masked_store_blend_i16(<4 x i16>* nocapture, <4 x i16>,
                                      <4 x i32>) nounwind alwaysinline {
  %old = load PTR_OP_ARGS(`<4 x i16> ')  %0, align 2

  %m = trunc <4 x i32> %2 to <4 x i1>
  %resultvec = select <4 x i1> %m, <4 x i16> %1, <4 x i16> %old

  store <4 x i16> %resultvec, <4 x i16> * %0, align 2
  ret void
}
')

define(`masked_store_blend_8_16_by_4_mask64', `
define void @__masked_store_blend_i8(<4 x i8>* nocapture, <4 x i8>,
                                     <4 x i64>) nounwind alwaysinline {
  %old = load PTR_OP_ARGS(`<4 x i8> ')  %0, align 1

  %m = trunc <4 x i64> %2 to <4 x i1>
  %resultvec = select <4 x i1> %m, <4 x i8> %1, <4 x i8> %old

  store <4 x i8> %resultvec, <4 x i8> * %0, align 1
  ret void
}

define void @__masked_store_blend_i16(<4 x i16>* nocapture, <4 x i16>,
                                      <4 x i64>) nounwind alwaysinline {
  %old = load PTR_OP_ARGS(`<4 x i16> ')  %0, align 2

  %m = trunc <4 x i64> %2 to <4 x i1>
  %resultvec = select <4 x i1> %m, <4 x i16> %1, <4 x i16> %old

  store <4 x i16> %resultvec, <4 x i16> * %0, align 2
  ret void
}
')

define(`masked_store_blend_8_16_by_8', `
define void @__masked_store_blend_i8(<8 x i8>* nocapture, <8 x i8>,
                                     <8 x i32>) nounwind alwaysinline {
  %old = load PTR_OP_ARGS(`<8 x i8> ')  %0, align 1

  %m = trunc <8 x i32> %2 to <8 x i1>
  %resultvec = select <8 x i1> %m, <8 x i8> %1, <8 x i8> %old

  store <8 x i8> %resultvec, <8 x i8> * %0, align 1
  ret void
}

define void @__masked_store_blend_i16(<8 x i16>* nocapture, <8 x i16>,
                                      <8 x i32>) nounwind alwaysinline {
  %old = load PTR_OP_ARGS(`<8 x i16> ')  %0, align 2

  %m = trunc <8 x i32> %2 to <8 x i1>
  %resultvec = select <8 x i1> %m, <8 x i16> %1, <8 x i16> %old

  store <8 x i16> %resultvec, <8 x i16> * %0, align 2
  ret void
}
')


define(`masked_store_blend_8_16_by_16', `
define void @__masked_store_blend_i8(<16 x i8>* nocapture, <16 x i8>,
                                     <16 x i32>) nounwind alwaysinline {
  %old = load PTR_OP_ARGS(`<16 x i8> ')  %0, align 1

  %m = trunc <16 x i32> %2 to <16 x i1>
  %resultvec = select <16 x i1> %m, <16 x i8> %1, <16 x i8> %old

  store <16 x i8> %resultvec, <16 x i8> * %0, align 1
  ret void
}

define void @__masked_store_blend_i16(<16 x i16>* nocapture, <16 x i16>,
                                      <16 x i32>) nounwind alwaysinline {
  %old = load PTR_OP_ARGS(`<16 x i16> ')  %0, align 2

  %m = trunc <16 x i32> %2 to <16 x i1>
  %resultvec = select <16 x i1> %m, <16 x i16> %1, <16 x i16> %old

  store <16 x i16> %resultvec, <16 x i16> * %0, align 2
  ret void
}
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; packed load and store functions
;;
;; These define functions to emulate those nice packed load and packed store
;; instructions.  For packed store, given a pointer to destination array and
;; an offset into the array, for each lane where the mask is on, the
;; corresponding value for that lane is stored into packed locations in the
;; destination array.  For packed load, each lane that has an active mask
;; loads a sequential value from the array.
;;
;; $1: vector width of the target
;;
;; FIXME: use the per_lane macro, defined below, to implement these!

define(`packed_load_and_store', `

define i32 @__packed_load_active(i32 * %startptr, <WIDTH x i32> * %val_ptr,
                                 <WIDTH x MASK> %full_mask) nounwind alwaysinline {
entry:
  %mask = call i64 @__movmsk(<WIDTH x MASK> %full_mask)
  %mask_known = call i1 @__is_compile_time_constant_mask(<WIDTH x MASK> %full_mask)
  br i1 %mask_known, label %known_mask, label %unknown_mask

known_mask:
  %allon = icmp eq i64 %mask, ALL_ON_MASK
  br i1 %allon, label %all_on, label %unknown_mask

all_on:
  ;; everyone wants to load, so just load an entire vector width in a single
  ;; vector load
  %vecptr = bitcast i32 *%startptr to <WIDTH x i32> *
  %vec_load = load PTR_OP_ARGS(`<WIDTH x i32> ') %vecptr, align 4
  store <WIDTH x i32> %vec_load, <WIDTH x i32> * %val_ptr, align 4
  ret i32 WIDTH

unknown_mask:
  br label %loop

loop:
  %lane = phi i32 [ 0, %unknown_mask ], [ %nextlane, %loopend ]
  %lanemask = phi i64 [ 1, %unknown_mask ], [ %nextlanemask, %loopend ]
  %offset = phi i32 [ 0, %unknown_mask ], [ %nextoffset, %loopend ]

  ; is the current lane on?
  %and = and i64 %mask, %lanemask
  %do_load = icmp eq i64 %and, %lanemask
  br i1 %do_load, label %load, label %loopend

load:
  %loadptr = getelementptr PTR_OP_ARGS(`i32') %startptr, i32 %offset
  %loadval = load PTR_OP_ARGS(`i32 ') %loadptr
  %val_ptr_i32 = bitcast <WIDTH x i32> * %val_ptr to i32 *
  %storeptr = getelementptr PTR_OP_ARGS(`i32') %val_ptr_i32, i32 %lane
  store i32 %loadval, i32 *%storeptr
  %offset1 = add i32 %offset, 1
  br label %loopend

loopend:
  %nextoffset = phi i32 [ %offset1, %load ], [ %offset, %loop ]
  %nextlane = add i32 %lane, 1
  %nextlanemask = mul i64 %lanemask, 2

  ; are we done yet?
  %test = icmp ne i32 %nextlane, WIDTH
  br i1 %test, label %loop, label %done

done:
  ret i32 %nextoffset
}

define i32 @__packed_store_active(i32 * %startptr, <WIDTH x i32> %vals,
                                   <WIDTH x MASK> %full_mask) nounwind alwaysinline {
entry:
  %mask = call i64 @__movmsk(<WIDTH x MASK> %full_mask)
  %mask_known = call i1 @__is_compile_time_constant_mask(<WIDTH x MASK> %full_mask)
  br i1 %mask_known, label %known_mask, label %unknown_mask

known_mask:
  %allon = icmp eq i64 %mask, ALL_ON_MASK
  br i1 %allon, label %all_on, label %unknown_mask

all_on:
  %vecptr = bitcast i32 *%startptr to <WIDTH x i32> *
  store <WIDTH x i32> %vals, <WIDTH x i32> * %vecptr, align 4
  ret i32 WIDTH

unknown_mask:
  br label %loop

loop:
  %lane = phi i32 [ 0, %unknown_mask ], [ %nextlane, %loopend ]
  %lanemask = phi i64 [ 1, %unknown_mask ], [ %nextlanemask, %loopend ]
  %offset = phi i32 [ 0, %unknown_mask ], [ %nextoffset, %loopend ]

  ; is the current lane on?
  %and = and i64 %mask, %lanemask
  %do_store = icmp eq i64 %and, %lanemask
  br i1 %do_store, label %store, label %loopend

store:
  %storeval = extractelement <WIDTH x i32> %vals, i32 %lane
  %storeptr = getelementptr PTR_OP_ARGS(`i32') %startptr, i32 %offset
  store i32 %storeval, i32 *%storeptr
  %offset1 = add i32 %offset, 1
  br label %loopend

loopend:
  %nextoffset = phi i32 [ %offset1, %store ], [ %offset, %loop ]
  %nextlane = add i32 %lane, 1
  %nextlanemask = mul i64 %lanemask, 2

  ; are we done yet?
  %test = icmp ne i32 %nextlane, WIDTH
  br i1 %test, label %loop, label %done

done:
  ret i32 %nextoffset
}

define MASK @__packed_store_active2(i32 * %startptr, <WIDTH x i32> %vals,
                                   <WIDTH x MASK> %full_mask) nounwind alwaysinline {
entry:
  %mask = call i64 @__movmsk(<WIDTH x MASK> %full_mask)
  %mask_known = call i1 @__is_compile_time_constant_mask(<WIDTH x MASK> %full_mask)
  br i1 %mask_known, label %known_mask, label %unknown_mask

known_mask:
  %allon = icmp eq i64 %mask, ALL_ON_MASK
  br i1 %allon, label %all_on, label %unknown_mask

all_on:
  %vecptr = bitcast i32 *%startptr to <WIDTH x i32> *
  store <WIDTH x i32> %vals, <WIDTH x i32> * %vecptr, align 4
  ret MASK WIDTH

unknown_mask:
  br label %loop

loop:
  %offset = phi MASK [ 0, %unknown_mask ], [ %ch_offset, %loop ]
  %i = phi i32 [ 0, %unknown_mask ], [ %ch_i, %loop ]
  %storeval = extractelement <WIDTH x i32> %vals, i32 %i

;; Offset has value in range from 0 to WIDTH-1. So it does not matter if we
;; zero or sign extending it, while zero extend is free. Also do nothing for
;; i64 MASK, as we need i64 value.
ifelse(MASK, `i64',
` %storeptr = getelementptr PTR_OP_ARGS(`i32') %startptr, MASK %offset',
` %offset1 = zext MASK %offset to i64
  %storeptr = getelementptr PTR_OP_ARGS(`i32') %startptr, i64 %offset1')
  store i32 %storeval, i32 *%storeptr

  %mull_mask = extractelement <WIDTH x MASK> %full_mask, i32 %i
  %ch_offset = sub MASK %offset, %mull_mask

  ; are we done yet?
  %ch_i = add i32 %i, 1
  %test = icmp ne i32 %ch_i, WIDTH
  br i1 %test, label %loop, label %done

done:
  ret MASK %ch_offset
}
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; reduce_equal

;; count leading/trailing zeros
;; Macros declares set of count-trailing and count-leading zeros.
;; Macros behaves as a static functon - it works only at first invokation
;; to avoid redifinition.
define(`declare_count_zeros', `
ifelse(count_zeros_are_defined, true, `',
`
declare i32 @llvm.genx.lzd.i32(i32)
declare i32 @llvm.genx.bfrev.i32(i32)
declare i32 @llvm.cttz.i32(i32)
declare i64 @llvm.cttz.i64(i64)

define(`count_zeros_are_defined', true)
')

')

define(`reduce_equal_aux', `
declare_count_zeros()

define i1 @__reduce_equal_$3(<$1 x $2> %v, $2 * %samevalue,
                             <$1 x MASK> %mask) nounwind alwaysinline {
entry:
   %ptr = alloca <$1 x $2>
   %mm = call i64 @__movmsk(<$1 x MASK> %mask)
   %allon = icmp eq i64 %mm, ALL_ON_MASK
   br i1 %allon, label %check_neighbors, label %domixed

domixed:
  ; First, figure out which lane is the first active one
  %first = call i64 @__count_trailing_zeros_i64(i64 %mm)
  %first32 = trunc i64 %first to i32
  %baseval = extractelement <$1 x $2> %v, i32 %first32
  %basev1 = insertelement <$1 x $2> undef, $2 %baseval, i32 0
  ; get a vector that is that value smeared across all elements
  %basesmear = shufflevector <$1 x $2> %basev1, <$1 x $2> undef,
        <$1 x i32> < forloop(i, 0, eval($1-2), `i32 0, ') i32 0 >

  ; now to a blend of that vector with the original vector, such that the
  ; result will be the original value for the active lanes, and the value
  ; from the first active lane for the inactive lanes.  Given that, we can
  ; just unconditionally check if the lanes are all equal in check_neighbors
  ; below without worrying about inactive lanes...
  store <$1 x $2> %basesmear, <$1 x $2> * %ptr
  %castptr = bitcast <$1 x $2> * %ptr to <$1 x $4> *
  %castv = bitcast <$1 x $2> %v to <$1 x $4>
  call void @__masked_store_blend_i$6(<$1 x $4> * %castptr, <$1 x $4> %castv, <$1 x MASK> %mask)
  %blendvec = load PTR_OP_ARGS(`<$1 x $2> ')  %ptr
  br label %check_neighbors

check_neighbors:
  %vec = phi <$1 x $2> [ %blendvec, %domixed ], [ %v, %entry ]
  ifelse($6, `32', `
  ; For 32-bit elements, we rotate once and compare with the vector, which ends
  ; up comparing each element to its neighbor on the right.  Then see if
  ; all of those values are true; if so, then all of the elements are equal..
  %castvec = bitcast <$1 x $2> %vec to <$1 x $4>
  %castvr = call <$1 x $4> @__rotate_i$6(<$1 x $4> %castvec, i32 1)
  %vr = bitcast <$1 x $4> %castvr to <$1 x $2>
  %eq = $5 $7 <$1 x $2> %vec, %vr
  ifelse(MASK,i1, `
    %eqmm = call i64 @__movmsk(<$1 x MASK> %eq)',
    `%eqm = sext <$1 x i1> %eq to <$1 x MASK>
    %eqmm = call i64 @__movmsk(<$1 x MASK> %eqm)')
  %alleq = icmp eq i64 %eqmm, ALL_ON_MASK
  br i1 %alleq, label %all_equal, label %not_all_equal
  ', `
  ; But for 64-bit elements, it turns out to be more efficient to just
  ; scalarize and do a individual pairwise comparisons and AND those
  ; all together..
  forloop(i, 0, eval($1-1), `
  %v`'i = extractelement <$1 x $2> %vec, i32 i')

  forloop(i, 0, eval($1-2), `
  %eq`'i = $5 $7 $2 %v`'i, %v`'eval(i+1)')

  %and0 = and i1 %eq0, %eq1
  forloop(i, 1, eval($1-3), `
  %and`'i = and i1 %and`'eval(i-1), %eq`'eval(i+1)')

  br i1 %and`'eval($1-3), label %all_equal, label %not_all_equal
  ')

all_equal:
  %the_value = extractelement <$1 x $2> %vec, i32 0
  store $2 %the_value, $2 * %samevalue
  ret i1 true

not_all_equal:
  ret i1 false
}
')

define(`reduce_equal', `
reduce_equal_aux($1, i32, int32, i32, icmp, 32, eq)
reduce_equal_aux($1, float, float, i32, fcmp, 32, oeq)
reduce_equal_aux($1, i64, int64, i64, icmp, 64, eq)
reduce_equal_aux($1, double, double, i64, fcmp, 64, oeq)
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; prefix sum stuff

; $1: vector width (e.g. 4)
; $2: vector element type (e.g. float)
; $3: bit width of vector element type (e.g. 32)
; $4: operator to apply (e.g. fadd)
; $5: identity element value (e.g. 0)
; $6: suffix for function (e.g. add_float)

define(`exclusive_scan', `
define <$1 x $2> @__exclusive_scan_$6(<$1 x $2> %v,
                                  <$1 x MASK> %mask) nounwind alwaysinline {
  ; first, set the value of any off lanes to the identity value
  %ptr = alloca <$1 x $2>
  %idvec1 = bitcast $2 $5 to <1 x $2>
  %idvec = shufflevector <1 x $2> %idvec1, <1 x $2> undef,
      <$1 x i32> < forloop(i, 0, eval($1-2), `i32 0, ') i32 0 >
  store <$1 x $2> %idvec, <$1 x $2> * %ptr
  %ptr`'$3 = bitcast <$1 x $2> * %ptr to <$1 x i`'$3> *
  %vi = bitcast <$1 x $2> %v to <$1 x i`'$3>
  call void @__masked_store_blend_i$3(<$1 x i`'$3> * %ptr`'$3, <$1 x i`'$3> %vi,
                                      <$1 x MASK> %mask)
  %v_id = load PTR_OP_ARGS(`<$1 x $2> ')  %ptr

  ; extract elements of the vector to use in computing the scan
  forloop(i, 0, eval($1-1), `
  %v`'i = extractelement <$1 x $2> %v_id, i32 i')

  ; and just compute the scan directly.
  ; 0th element is the identity (so nothing to do here),
  ; 1st element is identity (op) the 0th element of the original vector,
  ; each successive element is the previous element (op) the previous element
  ;  of the original vector
  %s1 = $4 $2 $5, %v0
  forloop(i, 2, eval($1-1), `
  %s`'i = $4 $2 %s`'eval(i-1), %v`'eval(i-1)')

  ; and fill in the result vector
  %r0 = insertelement <$1 x $2> undef, $2 $5, i32 0  ; 0th element gets identity
  forloop(i, 1, eval($1-1), `
  %r`'i = insertelement <$1 x $2> %r`'eval(i-1), $2 %s`'i, i32 i')

  ret <$1 x $2> %r`'eval($1-1)
}
')

define(`scans', `
exclusive_scan(WIDTH, i32, 32, add, 0, add_i32)
exclusive_scan(WIDTH, float, 32, fadd, zeroinitializer, add_float)
exclusive_scan(WIDTH, i64, 64, add, 0, add_i64)
exclusive_scan(WIDTH, double, 64, fadd, zeroinitializer, add_double)

exclusive_scan(WIDTH, i32, 32, and, -1, and_i32)
exclusive_scan(WIDTH, i64, 64, and, -1, and_i64)

exclusive_scan(WIDTH, i32, 32, or, 0, or_i32)
exclusive_scan(WIDTH, i64, 64, or, 0, or_i64)
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; per_lane
;;
;; The scary macro below encapsulates the 'scalarization' idiom--i.e. we have
;; some operation that we'd like to perform only for the lanes where the
;; mask is on
;; $1: vector width of the target
;; $2: variable that holds the mask
;; $3: block of code to run for each lane that is on
;;       Inside this code, any instances of the text "LANE" are replaced
;;       with an i32 value that represents the current lane number

; num lanes, mask, code block to do per lane
define(`per_lane', `
  br label %pl_entry

pl_entry:
  %pl_mask = call i64 @__movmsk($2)
  %pl_mask_known = call i1 @__is_compile_time_constant_mask($2)
  br i1 %pl_mask_known, label %pl_known_mask, label %pl_unknown_mask

pl_known_mask:
  ;; the mask is known at compile time; see if it is something we can
  ;; handle more efficiently
  %pl_is_allon = icmp eq i64 %pl_mask, ALL_ON_MASK
  br i1 %pl_is_allon, label %pl_all_on, label %pl_unknown_mask

pl_all_on:
  ;; the mask is all on--just expand the code for each lane sequentially
  forloop(i, 0, eval($1-1),
          `patsubst(`$3', `LANE', i)')
  br label %pl_done

pl_unknown_mask:
  ;; we just run the general case, though we could
  ;; try to be smart and just emit the code based on what it actually is,
  ;; for example by emitting the code straight-line without a loop and doing
  ;; the lane tests explicitly, leaving later optimization passes to eliminate
  ;; the stuff that is definitely not needed.  Not clear if we will frequently
  ;; encounter a mask that is known at compile-time but is not either all on or
  ;; all off...
  br label %pl_loop

pl_loop:
  ;; Loop over each lane and see if we want to do the work for this lane
  %pl_lane = phi i32 [ 0, %pl_unknown_mask ], [ %pl_nextlane, %pl_loopend ]
  %pl_lanemask = phi i64 [ 1, %pl_unknown_mask ], [ %pl_nextlanemask, %pl_loopend ]

  ; is the current lane on?  if so, goto do work, otherwise to end of loop
  %pl_and = and i64 %pl_mask, %pl_lanemask
  %pl_doit = icmp eq i64 %pl_and, %pl_lanemask
  br i1 %pl_doit, label %pl_dolane, label %pl_loopend

pl_dolane:
  ;; If so, substitute in the code from the caller and replace the LANE
  ;; stuff with the current lane number
  patsubst(`patsubst(`$3', `LANE_ID', `_id')', `LANE', `%pl_lane')
  br label %pl_loopend

pl_loopend:
  %pl_nextlane = add i32 %pl_lane, 1
  %pl_nextlanemask = mul i64 %pl_lanemask, 2

  ; are we done yet?
  %pl_test = icmp ne i32 %pl_nextlane, $1
  br i1 %pl_test, label %pl_loop, label %pl_done

pl_done:
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; gather
;;
;; $1: scalar type for which to generate functions to do gathers

define(`gen_gather_general', `
; fully general 32-bit gather, takes array of pointers encoded as vector of i32s
define <WIDTH x $1> @__gather32_$1(<WIDTH x i32> %ptrs,
                                   <WIDTH x MASK> %vecmask) nounwind readonly alwaysinline {
  %ret_ptr = alloca <WIDTH x $1>
  per_lane(WIDTH, <WIDTH x MASK> %vecmask, `
  %iptr_LANE_ID = extractelement <WIDTH x i32> %ptrs, i32 LANE
  %ptr_LANE_ID = inttoptr i32 %iptr_LANE_ID to $1 *
  %val_LANE_ID = load PTR_OP_ARGS(`$1 ')  %ptr_LANE_ID
  %store_ptr_LANE_ID = getelementptr PTR_OP_ARGS(`<WIDTH x $1>') %ret_ptr, i32 0, i32 LANE
  store $1 %val_LANE_ID, $1 * %store_ptr_LANE_ID
 ')

  %ret = load PTR_OP_ARGS(`<WIDTH x $1> ')  %ret_ptr
  ret <WIDTH x $1> %ret
}

; fully general 64-bit gather, takes array of pointers encoded as vector of i64s
define <WIDTH x $1> @__gather64_$1(<WIDTH x i64> %ptrs,
                                   <WIDTH x MASK> %vecmask) nounwind readonly alwaysinline {
  %ret_ptr = alloca <WIDTH x $1>
  per_lane(WIDTH, <WIDTH x MASK> %vecmask, `
  %iptr_LANE_ID = extractelement <WIDTH x i64> %ptrs, i32 LANE
  %ptr_LANE_ID = inttoptr i64 %iptr_LANE_ID to $1 *
  %val_LANE_ID = load PTR_OP_ARGS(`$1 ')  %ptr_LANE_ID
  %store_ptr_LANE_ID = getelementptr PTR_OP_ARGS(`<WIDTH x $1>') %ret_ptr, i32 0, i32 LANE
  store $1 %val_LANE_ID, $1 * %store_ptr_LANE_ID
 ')

  %ret = load PTR_OP_ARGS(`<WIDTH x $1> ')  %ret_ptr
  ret <WIDTH x $1> %ret
}
')

; vec width, type
define(`gen_gather_factored', `
;; Define the utility function to do the gather operation for a single element
;; of the type
define <WIDTH x $1> @__gather_elt32_$1(i8 * %ptr, <WIDTH x i32> %offsets, i32 %offset_scale,
                                    <WIDTH x i32> %offset_delta, <WIDTH x $1> %ret,
                                    i32 %lane) nounwind readonly alwaysinline {
  ; compute address for this one from the base
  %offset32 = extractelement <WIDTH x i32> %offsets, i32 %lane
  ; the order and details of the next 4 lines are important--they match LLVMs
  ; patterns that apply the free x86 2x/4x/8x scaling in addressing calculations
  %offset64 = sext i32 %offset32 to i64
  %scale64 = sext i32 %offset_scale to i64
  %offset = mul i64 %offset64, %scale64
  %ptroffset = getelementptr PTR_OP_ARGS(`i8') %ptr, i64 %offset

  %delta = extractelement <WIDTH x i32> %offset_delta, i32 %lane
  %delta64 = sext i32 %delta to i64
  %finalptr = getelementptr PTR_OP_ARGS(`i8') %ptroffset, i64 %delta64

  ; load value and insert into returned value
  %ptrcast = bitcast i8 * %finalptr to $1 *
  %val = load PTR_OP_ARGS(`$1 ') %ptrcast
  %updatedret = insertelement <WIDTH x $1> %ret, $1 %val, i32 %lane
  ret <WIDTH x $1> %updatedret
}

define <WIDTH x $1> @__gather_elt64_$1(i8 * %ptr, <WIDTH x i64> %offsets, i32 %offset_scale,
                                    <WIDTH x i64> %offset_delta, <WIDTH x $1> %ret,
                                    i32 %lane) nounwind readonly alwaysinline {
  ; compute address for this one from the base
  %offset64 = extractelement <WIDTH x i64> %offsets, i32 %lane
  ; the order and details of the next 4 lines are important--they match LLVMs
  ; patterns that apply the free x86 2x/4x/8x scaling in addressing calculations
  %offset_scale64 = sext i32 %offset_scale to i64
  %offset = mul i64 %offset64, %offset_scale64
  %ptroffset = getelementptr PTR_OP_ARGS(`i8') %ptr, i64 %offset

  %delta64 = extractelement <WIDTH x i64> %offset_delta, i32 %lane
  %finalptr = getelementptr PTR_OP_ARGS(`i8') %ptroffset, i64 %delta64

  ; load value and insert into returned value
  %ptrcast = bitcast i8 * %finalptr to $1 *
  %val = load PTR_OP_ARGS(`$1 ') %ptrcast
  %updatedret = insertelement <WIDTH x $1> %ret, $1 %val, i32 %lane
  ret <WIDTH x $1> %updatedret
}


define <WIDTH x $1> @__gather_factored_base_offsets32_$1(i8 * %ptr, <WIDTH x i32> %offsets, i32 %offset_scale,
                                             <WIDTH x i32> %offset_delta,
                                             <WIDTH x MASK> %vecmask) nounwind readonly alwaysinline {
  ; We can be clever and avoid the per-lane stuff for gathers if we are willing
  ; to require that the 0th element of the array being gathered from is always
  ; legal to read from (and we do indeed require that, given the benefits!)
  ;
  ; Set the offset to zero for lanes that are off
  %offsetsPtr = alloca <WIDTH x i32>
  %deltaPtr = alloca <WIDTH x i32>
  store <WIDTH x i32> zeroinitializer, <WIDTH x i32> * %offsetsPtr
  call void @__masked_store_blend_i32(<WIDTH x i32> * %offsetsPtr, <WIDTH x i32> %offsets,
                                      <WIDTH x MASK> %vecmask)
  %newOffsets = load PTR_OP_ARGS(`<WIDTH x i32> ')  %offsetsPtr

  store <WIDTH x i32> zeroinitializer, <WIDTH x i32> * %deltaPtr
  call void @__masked_store_blend_i32(<WIDTH x i32> * %deltaPtr, <WIDTH x i32> %offset_delta,
                                      <WIDTH x MASK> %vecmask)
  %newDelta = load PTR_OP_ARGS(`<WIDTH x i32> ')  %deltaPtr

  %ret0 = call <WIDTH x $1> @__gather_elt32_$1(i8 * %ptr, <WIDTH x i32> %newOffsets,
                                            i32 %offset_scale, <WIDTH x i32> %newDelta,
                                            <WIDTH x $1> undef, i32 0)
  forloop(lane, 1, eval(WIDTH-1),
          `patsubst(patsubst(`%retLANE = call <WIDTH x $1> @__gather_elt32_$1(i8 * %ptr,
                                <WIDTH x i32> %newOffsets, i32 %offset_scale, <WIDTH x i32> %newDelta,
                                <WIDTH x $1> %retPREV, i32 LANE)
                    ', `LANE', lane), `PREV', eval(lane-1))')
  ret <WIDTH x $1> %ret`'eval(WIDTH-1)
}

define <WIDTH x $1> @__gather_factored_base_offsets64_$1(i8 * %ptr, <WIDTH x i64> %offsets, i32 %offset_scale,
                                             <WIDTH x i64> %offset_delta,
                                             <WIDTH x MASK> %vecmask) nounwind readonly alwaysinline {
  ; We can be clever and avoid the per-lane stuff for gathers if we are willing
  ; to require that the 0th element of the array being gathered from is always
  ; legal to read from (and we do indeed require that, given the benefits!)
  ;
  ; Set the offset to zero for lanes that are off
  %offsetsPtr = alloca <WIDTH x i64>
  %deltaPtr = alloca <WIDTH x i64>
  store <WIDTH x i64> zeroinitializer, <WIDTH x i64> * %offsetsPtr
  call void @__masked_store_blend_i64(<WIDTH x i64> * %offsetsPtr, <WIDTH x i64> %offsets,
                                      <WIDTH x MASK> %vecmask)
  %newOffsets = load PTR_OP_ARGS(`<WIDTH x i64> ')  %offsetsPtr

  store <WIDTH x i64> zeroinitializer, <WIDTH x i64> * %deltaPtr
  call void @__masked_store_blend_i64(<WIDTH x i64> * %deltaPtr, <WIDTH x i64> %offset_delta,
                                      <WIDTH x MASK> %vecmask)
  %newDelta = load PTR_OP_ARGS(`<WIDTH x i64> ')  %deltaPtr

  %ret0 = call <WIDTH x $1> @__gather_elt64_$1(i8 * %ptr, <WIDTH x i64> %newOffsets,
                                            i32 %offset_scale, <WIDTH x i64> %newDelta,
                                            <WIDTH x $1> undef, i32 0)
  forloop(lane, 1, eval(WIDTH-1),
          `patsubst(patsubst(`%retLANE = call <WIDTH x $1> @__gather_elt64_$1(i8 * %ptr,
                                <WIDTH x i64> %newOffsets, i32 %offset_scale, <WIDTH x i64> %newDelta,
                                <WIDTH x $1> %retPREV, i32 LANE)
                    ', `LANE', lane), `PREV', eval(lane-1))')
  ret <WIDTH x $1> %ret`'eval(WIDTH-1)
}

gen_gather_general($1)
'
)

; vec width, type
define(`gen_gather', `

gen_gather_factored($1)

define <WIDTH x $1>
@__gather_base_offsets32_$1(i8 * %ptr, i32 %offset_scale,
                           <WIDTH x i32> %offsets,
                           <WIDTH x MASK> %vecmask) nounwind readonly alwaysinline {
  %scale_vec = bitcast i32 %offset_scale to <1 x i32>
  %smear_scale = shufflevector <1 x i32> %scale_vec, <1 x i32> undef,
     <WIDTH x i32> < forloop(i, 1, eval(WIDTH-1), `i32 0, ') i32 0 >
  %scaled_offsets = mul <WIDTH x i32> %smear_scale, %offsets
  %v = call <WIDTH x $1> @__gather_factored_base_offsets32_$1(i8 * %ptr, <WIDTH x i32> %scaled_offsets, i32 1,
                                                     <WIDTH x i32> zeroinitializer, <WIDTH x MASK> %vecmask)
  ret <WIDTH x $1> %v
}

define <WIDTH x $1>
@__gather_base_offsets64_$1(i8 * %ptr, i32 %offset_scale,
                            <WIDTH x i64> %offsets,
                            <WIDTH x MASK> %vecmask) nounwind readonly alwaysinline {
  %scale64 = zext i32 %offset_scale to i64
  %scale_vec = bitcast i64 %scale64 to <1 x i64>
  %smear_scale = shufflevector <1 x i64> %scale_vec, <1 x i64> undef,
     <WIDTH x i32> < forloop(i, 1, eval(WIDTH-1), `i32 0, ') i32 0 >
  %scaled_offsets = mul <WIDTH x i64> %smear_scale, %offsets
  %v = call <WIDTH x $1> @__gather_factored_base_offsets64_$1(i8 * %ptr, <WIDTH x i64> %scaled_offsets,
                                                     i32 1, <WIDTH x i64> zeroinitializer, <WIDTH x MASK> %vecmask)
  ret <WIDTH x $1> %v
}

'
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; gen_scatter
;; Emit a function declaration for a scalarized scatter.
;;
;; $1: scalar type for which we want to generate code to scatter

define(`gen_scatter', `
;; Define the function that descripes the work to do to scatter a single
;; value
define void @__scatter_elt32_$1(i8 * %ptr, <WIDTH x i32> %offsets, i32 %offset_scale,
                                <WIDTH x i32> %offset_delta, <WIDTH x $1> %values,
                                i32 %lane) nounwind alwaysinline {
  %offset32 = extractelement <WIDTH x i32> %offsets, i32 %lane
  ; the order and details of the next 4 lines are important--they match LLVMs
  ; patterns that apply the free x86 2x/4x/8x scaling in addressing calculations
  %offset64 = sext i32 %offset32 to i64
  %scale64 = sext i32 %offset_scale to i64
  %offset = mul i64 %offset64, %scale64
  %ptroffset = getelementptr PTR_OP_ARGS(`i8') %ptr, i64 %offset

  %delta = extractelement <WIDTH x i32> %offset_delta, i32 %lane
  %delta64 = sext i32 %delta to i64
  %finalptr = getelementptr PTR_OP_ARGS(`i8') %ptroffset, i64 %delta64

  %ptrcast = bitcast i8 * %finalptr to $1 *
  %storeval = extractelement <WIDTH x $1> %values, i32 %lane
  store $1 %storeval, $1 * %ptrcast
  ret void
}

define void @__scatter_elt64_$1(i8 * %ptr, <WIDTH x i64> %offsets, i32 %offset_scale,
                                <WIDTH x i64> %offset_delta, <WIDTH x $1> %values,
                                i32 %lane) nounwind alwaysinline {
  %offset64 = extractelement <WIDTH x i64> %offsets, i32 %lane
  ; the order and details of the next 4 lines are important--they match LLVMs
  ; patterns that apply the free x86 2x/4x/8x scaling in addressing calculations
  %scale64 = sext i32 %offset_scale to i64
  %offset = mul i64 %offset64, %scale64
  %ptroffset = getelementptr PTR_OP_ARGS(`i8') %ptr, i64 %offset

  %delta64 = extractelement <WIDTH x i64> %offset_delta, i32 %lane
  %finalptr = getelementptr PTR_OP_ARGS(`i8') %ptroffset, i64 %delta64

  %ptrcast = bitcast i8 * %finalptr to $1 *
  %storeval = extractelement <WIDTH x $1> %values, i32 %lane
  store $1 %storeval, $1 * %ptrcast
  ret void
}

define void @__scatter_factored_base_offsets32_$1(i8* %base, <WIDTH x i32> %offsets, i32 %offset_scale,
                                         <WIDTH x i32> %offset_delta, <WIDTH x $1> %values,
                                         <WIDTH x MASK> %mask) nounwind alwaysinline {
  ;; And use the `per_lane' macro to do all of the per-lane work for scatter...
  per_lane(WIDTH, <WIDTH x MASK> %mask, `
      call void @__scatter_elt32_$1(i8 * %base, <WIDTH x i32> %offsets, i32 %offset_scale,
                                    <WIDTH x i32> %offset_delta, <WIDTH x $1> %values, i32 LANE)')
  ret void
}

define void @__scatter_factored_base_offsets64_$1(i8* %base, <WIDTH x i64> %offsets, i32 %offset_scale,
                                         <WIDTH x i64> %offset_delta, <WIDTH x $1> %values,
                                         <WIDTH x MASK> %mask) nounwind alwaysinline {
  ;; And use the `per_lane' macro to do all of the per-lane work for scatter...
  per_lane(WIDTH, <WIDTH x MASK> %mask, `
      call void @__scatter_elt64_$1(i8 * %base, <WIDTH x i64> %offsets, i32 %offset_scale,
                                    <WIDTH x i64> %offset_delta, <WIDTH x $1> %values, i32 LANE)')
  ret void
}

; fully general 32-bit scatter, takes array of pointers encoded as vector of i32s
define void @__scatter32_$1(<WIDTH x i32> %ptrs, <WIDTH x $1> %values,
                            <WIDTH x MASK> %mask) nounwind alwaysinline {
  per_lane(WIDTH, <WIDTH x MASK> %mask, `
  %iptr_LANE_ID = extractelement <WIDTH x i32> %ptrs, i32 LANE
  %ptr_LANE_ID = inttoptr i32 %iptr_LANE_ID to $1 *
  %val_LANE_ID = extractelement <WIDTH x $1> %values, i32 LANE
  store $1 %val_LANE_ID, $1 * %ptr_LANE_ID
 ')
  ret void
}

; fully general 64-bit scatter, takes array of pointers encoded as vector of i64s
define void @__scatter64_$1(<WIDTH x i64> %ptrs, <WIDTH x $1> %values,
                            <WIDTH x MASK> %mask) nounwind alwaysinline {
  per_lane(WIDTH, <WIDTH x MASK> %mask, `
  %iptr_LANE_ID = extractelement <WIDTH x i64> %ptrs, i32 LANE
  %ptr_LANE_ID = inttoptr i64 %iptr_LANE_ID to $1 *
  %val_LANE_ID = extractelement <WIDTH x $1> %values, i32 LANE
  store $1 %val_LANE_ID, $1 * %ptr_LANE_ID
 ')
  ret void
}

'
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; rdrand

define(`rdrand_decls', `
declare i1 @__rdrand_i16(i16 * nocapture)
declare i1 @__rdrand_i32(i32 * nocapture)
declare i1 @__rdrand_i64(i64 * nocapture)
')

define(`rdrand_definition', `
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; rdrand

declare {i16, i32} @llvm.x86.rdrand.16()
declare {i32, i32} @llvm.x86.rdrand.32()
declare {i64, i32} @llvm.x86.rdrand.64()

define i1 @__rdrand_i16(i16 * %ptr) {
  %v = call {i16, i32} @llvm.x86.rdrand.16()
  %v0 = extractvalue {i16, i32} %v, 0
  %v1 = extractvalue {i16, i32} %v, 1
  store i16 %v0, i16 * %ptr
  %good = icmp ne i32 %v1, 0
  ret i1 %good
}

define i1 @__rdrand_i32(i32 * %ptr) {
  %v = call {i32, i32} @llvm.x86.rdrand.32()
  %v0 = extractvalue {i32, i32} %v, 0
  %v1 = extractvalue {i32, i32} %v, 1
  store i32 %v0, i32 * %ptr
  %good = icmp ne i32 %v1, 0
  ret i1 %good
}

define i1 @__rdrand_i64(i64 * %ptr) {
  %v = call {i64, i32} @llvm.x86.rdrand.64()
  %v0 = extractvalue {i64, i32} %v, 0
  %v1 = extractvalue {i64, i32} %v, 1
  store i64 %v0, i64 * %ptr
  %good = icmp ne i32 %v1, 0
  ret i1 %good
}
')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; int8/int16 builtins

define(`define_avg_up_uint8', `
define <WIDTH x i8> @__avg_up_uint8(<WIDTH x i8>, <WIDTH x i8>) {
  %a16 = zext <WIDTH x i8> %0 to <WIDTH x i16>
  %b16 = zext <WIDTH x i8> %1 to <WIDTH x i16>
  %sum1 = add <WIDTH x i16> %a16, %b16
  %sum = add <WIDTH x i16> %sum1, < forloop(i, 1, eval(WIDTH-1), `i16 1, ') i16 1 >
  %avg = lshr <WIDTH x i16> %sum, < forloop(i, 1, eval(WIDTH-1), `i16 1, ') i16 1 >
  %r = trunc <WIDTH x i16> %avg to <WIDTH x i8>
  ret <WIDTH x i8> %r
}')

define(`define_avg_up_int8', `
define <WIDTH x i8> @__avg_up_int8(<WIDTH x i8>, <WIDTH x i8>) {
  %a16 = sext <WIDTH x i8> %0 to <WIDTH x i16>
  %b16 = sext <WIDTH x i8> %1 to <WIDTH x i16>
  %sum1 = add <WIDTH x i16> %a16, %b16
  %sum = add <WIDTH x i16> %sum1, < forloop(i, 1, eval(WIDTH-1), `i16 1, ') i16 1 >
  %avg = sdiv <WIDTH x i16> %sum, < forloop(i, 1, eval(WIDTH-1), `i16 2, ') i16 2 >
  %r = trunc <WIDTH x i16> %avg to <WIDTH x i8>
  ret <WIDTH x i8> %r
}')

define(`define_avg_up_uint16', `
define <WIDTH x i16> @__avg_up_uint16(<WIDTH x i16>, <WIDTH x i16>) {
  %a32 = zext <WIDTH x i16> %0 to <WIDTH x i32>
  %b32 = zext <WIDTH x i16> %1 to <WIDTH x i32>
  %sum1 = add <WIDTH x i32> %a32, %b32
  %sum = add <WIDTH x i32> %sum1, < forloop(i, 1, eval(WIDTH-1), `i32 1, ') i32 1 >
  %avg = lshr <WIDTH x i32> %sum, < forloop(i, 1, eval(WIDTH-1), `i32 1, ') i32 1 >
  %r = trunc <WIDTH x i32> %avg to <WIDTH x i16>
  ret <WIDTH x i16> %r
}')

define(`define_avg_up_int16', `
define <WIDTH x i16> @__avg_up_int16(<WIDTH x i16>, <WIDTH x i16>) {
  %a32 = sext <WIDTH x i16> %0 to <WIDTH x i32>
  %b32 = sext <WIDTH x i16> %1 to <WIDTH x i32>
  %sum1 = add <WIDTH x i32> %a32, %b32
  %sum = add <WIDTH x i32> %sum1, < forloop(i, 1, eval(WIDTH-1), `i32 1, ') i32 1 >
  %avg = sdiv <WIDTH x i32> %sum, < forloop(i, 1, eval(WIDTH-1), `i32 2, ') i32 2 >
  %r = trunc <WIDTH x i32> %avg to <WIDTH x i16>
  ret <WIDTH x i16> %r
}')

define(`define_avg_down_uint8', `
define <WIDTH x i8> @__avg_down_uint8(<WIDTH x i8>, <WIDTH x i8>) {
  %a16 = zext <WIDTH x i8> %0 to <WIDTH x i16>
  %b16 = zext <WIDTH x i8> %1 to <WIDTH x i16>
  %sum = add <WIDTH x i16> %a16, %b16
  %avg = lshr <WIDTH x i16> %sum, < forloop(i, 1, eval(WIDTH-1), `i16 1, ') i16 1 >
  %r = trunc <WIDTH x i16> %avg to <WIDTH x i8>
  ret <WIDTH x i8> %r
}')

define(`define_avg_down_int8', `
define <WIDTH x i8> @__avg_down_int8(<WIDTH x i8>, <WIDTH x i8>) {
  %a16 = sext <WIDTH x i8> %0 to <WIDTH x i16>
  %b16 = sext <WIDTH x i8> %1 to <WIDTH x i16>
  %sum = add <WIDTH x i16> %a16, %b16
  %avg = sdiv <WIDTH x i16> %sum, < forloop(i, 1, eval(WIDTH-1), `i16 2, ') i16 2 >
  %r = trunc <WIDTH x i16> %avg to <WIDTH x i8>
  ret <WIDTH x i8> %r
}')

define(`define_avg_down_uint16', `
define <WIDTH x i16> @__avg_down_uint16(<WIDTH x i16>, <WIDTH x i16>) {
  %a32 = zext <WIDTH x i16> %0 to <WIDTH x i32>
  %b32 = zext <WIDTH x i16> %1 to <WIDTH x i32>
  %sum = add <WIDTH x i32> %a32, %b32
  %avg = lshr <WIDTH x i32> %sum, < forloop(i, 1, eval(WIDTH-1), `i32 1, ') i32 1 >
  %r = trunc <WIDTH x i32> %avg to <WIDTH x i16>
  ret <WIDTH x i16> %r
}')

define(`define_avg_down_int16', `
define <WIDTH x i16> @__avg_down_int16(<WIDTH x i16>, <WIDTH x i16>) {
  %a32 = sext <WIDTH x i16> %0 to <WIDTH x i32>
  %b32 = sext <WIDTH x i16> %1 to <WIDTH x i32>
  %sum = add <WIDTH x i32> %a32, %b32
  %avg = sdiv <WIDTH x i32> %sum, < forloop(i, 1, eval(WIDTH-1), `i32 2, ') i32 2 >
  %r = trunc <WIDTH x i32> %avg to <WIDTH x i16>
  ret <WIDTH x i16> %r
}')

define(`define_up_avgs', `
define_avg_up_uint8()
define_avg_up_int8()
define_avg_up_uint16()
define_avg_up_int16()
')

define(`define_down_avgs', `
define_avg_down_uint8()
define_avg_down_int8()
define_avg_down_uint16()
define_avg_down_int16()
')

define(`define_avgs', `
define_up_avgs()
define_down_avgs()
')

define(`rsqrtd_decl', `
declare  double @__rsqrt_uniform_double(double)
declare <WIDTH x double> @__rsqrt_varying_double(<WIDTH x double>)
')

define(`rcpd_decl', `
declare  double @__rcp_uniform_double(double)
declare <WIDTH x double> @__rcp_varying_double(<WIDTH x double>)
')

define(`declare_nvptx',
`
declare i32 @__program_index()  nounwind readnone alwaysinline
declare i32 @__program_count()  nounwind readnone alwaysinline
declare i32 @__warp_index()  nounwind readnone alwaysinline
declare i64* @__cvt_loc2gen(i64 addrspace(3)*) nounwind readnone alwaysinline
declare i64* @__cvt_const2gen(i64 addrspace(4)*) nounwind readnone alwaysinline
declare i64* @__cvt_loc2gen_var(i64 addrspace(3)*) nounwind readnone alwaysinline
declare i64 @__movmsk_ptx(<WIDTH x i1>) nounwind readnone alwaysinline;
')

define(`global_atomic_varying',`
declare <$1 x $3> @__atomic_$2_varying_$4_global(<$1 x i64> %ptr, <$1 x $3> %val, <$1 x MASK> %maskv) nounwind alwaysinline
')

define(`global_atomic_cas_varying',`
declare <$1 x $3> @__atomic_$2_varying_$4_global(<$1 x i64> %ptr, <$1 x $3> %cmp, <$1 x $3> %val, <$1 x MASK> %maskv) nounwind alwaysinline
')

global_atomic_cas_varying(WIDTH, compare_exchange, i32, int32)
global_atomic_cas_varying(WIDTH, compare_exchange, i64, int64)
global_atomic_cas_varying(WIDTH, compare_exchange, float, float)
global_atomic_cas_varying(WIDTH, compare_exchange, double, double)

global_atomic_varying(WIDTH, swap, i32, int32)
global_atomic_varying(WIDTH, swap, i64, int64)
global_atomic_varying(WIDTH, swap, float, float)
global_atomic_varying(WIDTH, swap, double, double)

global_atomic_varying(WIDTH, add, i32, int32)
global_atomic_varying(WIDTH, sub, i32, int32)
global_atomic_varying(WIDTH, and, i32, int32)
global_atomic_varying(WIDTH, or, i32, int32)
global_atomic_varying(WIDTH, xor, i32, int32)
global_atomic_varying(WIDTH, min, i32, int32)
global_atomic_varying(WIDTH, max, i32, int32)
global_atomic_varying(WIDTH, umin, i32, uint32)
global_atomic_varying(WIDTH, umax, i32, uint32)

global_atomic_varying(WIDTH, add, i64, int64)
global_atomic_varying(WIDTH, sub, i64, int64)
global_atomic_varying(WIDTH, and, i64, int64)
global_atomic_varying(WIDTH, or, i64, int64)
global_atomic_varying(WIDTH, xor, i64, int64)
global_atomic_varying(WIDTH, min, i64, int64)
global_atomic_varying(WIDTH, max, i64, int64)
global_atomic_varying(WIDTH, umin, i64, uint64)
global_atomic_varying(WIDTH, umax, i64, uint64)

define(`transcendetals_decl',`
    declare float @__log_uniform_float(float) nounwind readnone
    declare <WIDTH x float> @__log_varying_float(<WIDTH x float>) nounwind readnone
    declare float @__exp_uniform_float(float) nounwind readnone
    declare <WIDTH x float> @__exp_varying_float(<WIDTH x float>) nounwind readnone
    declare float @__pow_uniform_float(float, float) nounwind readnone
    declare <WIDTH x float> @__pow_varying_float(<WIDTH x float>, <WIDTH x float>) nounwind readnone

    declare double @__log_uniform_double(double) nounwind readnone
    declare <WIDTH x double> @__log_varying_double(<WIDTH x double>) nounwind readnone
    declare double @__exp_uniform_double(double) nounwind readnone
    declare <WIDTH x double> @__exp_varying_double(<WIDTH x double>) nounwind readnone
    declare double @__pow_uniform_double(double, double) nounwind readnone
    declare <WIDTH x double> @__pow_varying_double(<WIDTH x double>, <WIDTH x double>) nounwind readnone
')

define(`trigonometry_decl',`
    declare <WIDTH x float> @__sin_varying_float(<WIDTH x float>) nounwind readnone
    declare <WIDTH x float> @__asin_varying_float(<WIDTH x float>) nounwind readnone
    declare <WIDTH x float> @__cos_varying_float(<WIDTH x float>) nounwind readnone
    declare <WIDTH x float> @__acos_varying_float(<WIDTH x float>) nounwind readnone
    declare void @__sincos_varying_float(<WIDTH x float>, <WIDTH x float>*, <WIDTH x float>*) nounwind
    declare <WIDTH x float> @__tan_varying_float(<WIDTH x float>) nounwind readnone
    declare <WIDTH x float> @__atan_varying_float(<WIDTH x float>) nounwind readnone
    declare <WIDTH x float> @__atan2_varying_float(<WIDTH x float>,<WIDTH x float>) nounwind readnone

    declare float @__sin_uniform_float(float) nounwind readnone
    declare float @__asin_uniform_float(float) nounwind readnone
    declare float @__cos_uniform_float(float) nounwind readnone
    declare float @__acos_uniform_float(float) nounwind readnone
    declare void @__sincos_uniform_float(float, float*, float*) nounwind
    declare float @__tan_uniform_float(float) nounwind readnone
    declare float @__atan_uniform_float(float) nounwind readnone
    declare float @__atan2_uniform_float(float,float) nounwind readnone

    declare <WIDTH x double> @__sin_varying_double(<WIDTH x double>) nounwind readnone
    declare <WIDTH x double> @__asin_varying_double(<WIDTH x double>) nounwind readnone
    declare <WIDTH x double> @__cos_varying_double(<WIDTH x double>) nounwind readnone
    declare <WIDTH x double> @__acos_varying_double(<WIDTH x double>) nounwind readnone
    declare void @__sincos_varying_double(<WIDTH x double>, <WIDTH x double>*, <WIDTH x double>*) nounwind
    declare <WIDTH x double> @__tan_varying_double(<WIDTH x double>) nounwind readnone
    declare <WIDTH x double> @__atan_varying_double(<WIDTH x double>) nounwind readnone
    declare <WIDTH x double> @__atan2_varying_double(<WIDTH x double>,<WIDTH x double>) nounwind readnone

    declare double @__sin_uniform_double(double) nounwind readnone
    declare double @__asin_uniform_double(double) nounwind readnone
    declare double @__cos_uniform_double(double) nounwind readnone
    declare double @__acos_uniform_double(double) nounwind readnone
    declare void @__sincos_uniform_double(double, double*, double*) nounwind
    declare double @__tan_uniform_double(double) nounwind readnone
    declare double @__atan_uniform_double(double) nounwind readnone
    declare double @__atan2_uniform_double(double,double) nounwind readnone
')