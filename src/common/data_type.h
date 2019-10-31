/**
 * ============================================================================
 *
 * Copyright (C) 2018, Hisilicon Technologies Co., Ltd. All Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   1 Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *
 *   2 Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *
 *   3 Neither the names of the copyright holders nor the names of the
 *   contributors may be used to endorse or promote products derived from this
 *   software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 * ============================================================================
 */

#ifndef COMMON_DATA_TYPE_H_
#define COMMON_DATA_TYPE_H_

#include <string>
#include <memory>

/**
 * @brief: console input parameter
 */
struct ConsoleParams {
  // model width
  uint32_t model_width = 0;
  // model height
  uint32_t model_height = 0;
  // input image path
  std::string input_path = "";
  // result output path
  std::string output_path = "";
  // output categories
  uint32_t output_nums = 0;
};

/**
 * @brief: serialize for ConsoleParams
 */
template<class Archive>
void serialize(Archive& ar, ConsoleParams& data) {
  ar(data.model_width, data.model_height, data.input_path, data.output_path,
     data.output_nums);
}

/**
 * @brief: image information
 */
struct ImageInfo {
  std::string path = ""; // the path of image
  int32_t width = 0; // original width
  int32_t height = 0; // original height
  int32_t size = 0; // data size
  std::shared_ptr<u_int8_t> data;
};

/**
 * @brief: serialize for ImageInfo
 */
template<class Archive>
void serialize(Archive& ar, ImageInfo& data) {
  ar(data.path);
  ar(data.width);
  ar(data.height);
  ar(data.size);
  if (data.size > 0 && data.data.get() == nullptr) {
    data.data.reset(new u_int8_t[data.size]);
  }
  ar(cereal::binary_data(data.data.get(), data.size * sizeof(u_int8_t)));
}

/**
 * @brief: inference output data
 */
struct Output {
  int32_t size = 0;
  std::shared_ptr<u_int8_t> data;
};

/**
 * @brief: serialize for Output
 */
template<class Archive>
void serialize(Archive& ar, Output& data) {
  ar(data.size);
  if (data.size > 0 && data.data.get() == nullptr) {
    data.data.reset(new u_int8_t[data.size]);
  }
  ar(cereal::binary_data(data.data.get(), data.size * sizeof(u_int8_t)));
}

/**
 * @brief: Inference engine error message
 */
struct ErrorInferenceMsg {
  bool error = false;
  std::string err_msg = "";
};

/**
 * @brief: serialize for EngineTrans
 */
template<class Archive>
void serialize(Archive& ar, ErrorInferenceMsg& data) {
  ar(data.error, data.err_msg);
}

/**
 * @brief: Engine Transform information
 */
struct EngineTrans {
  ConsoleParams console_params;
  ImageInfo image_info;
  ErrorInferenceMsg err_msg;
  std::vector<Output> inference_res;
  bool is_finished = false;
};

/**
 * @brief: serialize for EngineTrans
 */
template<class Archive>
void serialize(Archive& ar, EngineTrans& data) {
  ar(data.console_params, data.image_info, data.err_msg, data.inference_res,
     data.is_finished);
}

struct BoundingBox {
  uint32_t lt_x;
  uint32_t lt_y;
  uint32_t rb_x;
  uint32_t rb_y;
  uint32_t attribute;
  float score;
};

/**
 * error code
 */
enum ErrorCode {
  kOk,
  kHiaiInitFailed,
  kCreateGraphFailed,
  kGetGraphInstanceFailed,
  kSetCallbackFunctionError,
  kFilePathError,
  kModelInitFailed,
  kImageFileParseError,
  kImageConversionError,
  kInferenceError,
  kResultError,
  kOtherError
};

#endif /* COMMON_DATA_TYPE_H_ */
