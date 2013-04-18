/*M///////////////////////////////////////////////////////////////////////////////////////
//
//  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.
//
//  By downloading, copying, installing or using the software you agree to this license.
//  If you do not agree to this license, do not download, install,
//  copy or use the software.
//
//
//                           License Agreement
//                For Open Source Computer Vision Library
//
// Copyright (C) 2000-2008, Intel Corporation, all rights reserved.
// Copyright (C) 2009, Willow Garage Inc., all rights reserved.
// Third party copyrights are property of their respective owners.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
//   * Redistribution's of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//
//   * Redistribution's in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//   * The name of the copyright holders may not be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
// This software is provided by the copyright holders and contributors "as is" and
// any express or implied warranties, including, but not limited to, the implied
// warranties of merchantability and fitness for a particular purpose are disclaimed.
// In no event shall the Intel Corporation or contributors be liable for any direct,
// indirect, incidental, special, exemplary, or consequential damages
// (including, but not limited to, procurement of substitute goods or services;
// loss of use, data, or profits; or business interruption) however caused
// and on any theory of liability, whether in contract, strict liability,
// or tort (including negligence or otherwise) arising in any way out of
// the use of this software, even if advised of the possibility of such damage.
//
//M*/

#if !defined CUDA_DISABLER

#include "opencv2/core/cuda/common.hpp"
#include "opencv2/core/cuda/functional.hpp"
#include "opencv2/core/cuda/transform.hpp"
#include "opencv2/core/cuda/saturate_cast.hpp"
#include "opencv2/core/cuda/simd_functions.hpp"

#include "arithm_func_traits.hpp"

using namespace cv::gpu;
using namespace cv::gpu::cudev;

namespace arithm
{
    template <typename T, typename S> struct AbsDiffScalar : unary_function<T, T>
    {
        S val;

        explicit AbsDiffScalar(S val_) : val(val_) {}

        __device__ __forceinline__ T operator ()(T a) const
        {
            abs_func<S> f;
            return saturate_cast<T>(f(a - val));
        }
    };
}

namespace cv { namespace gpu { namespace cudev
{
    template <typename T, typename S> struct TransformFunctorTraits< arithm::AbsDiffScalar<T, S> > : arithm::ArithmFuncTraits<sizeof(T), sizeof(T)>
    {
    };
}}}

namespace arithm
{
    template <typename T, typename S>
    void absDiffScalar(PtrStepSzb src1, double val, PtrStepSzb dst, cudaStream_t stream)
    {
        AbsDiffScalar<T, S> op(static_cast<S>(val));

        cudev::transform((PtrStepSz<T>) src1, (PtrStepSz<T>) dst, op, WithOutMask(), stream);
    }

    template void absDiffScalar<uchar, float>(PtrStepSzb src1, double src2, PtrStepSzb dst, cudaStream_t stream);
    template void absDiffScalar<schar, float>(PtrStepSzb src1, double src2, PtrStepSzb dst, cudaStream_t stream);
    template void absDiffScalar<ushort, float>(PtrStepSzb src1, double src2, PtrStepSzb dst, cudaStream_t stream);
    template void absDiffScalar<short, float>(PtrStepSzb src1, double src2, PtrStepSzb dst, cudaStream_t stream);
    template void absDiffScalar<int, float>(PtrStepSzb src1, double src2, PtrStepSzb dst, cudaStream_t stream);
    template void absDiffScalar<float, float>(PtrStepSzb src1, double src2, PtrStepSzb dst, cudaStream_t stream);
    template void absDiffScalar<double, double>(PtrStepSzb src1, double src2, PtrStepSzb dst, cudaStream_t stream);
}

#endif // CUDA_DISABLER