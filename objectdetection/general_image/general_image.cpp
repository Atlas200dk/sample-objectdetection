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

#include "general_image.h"

#include <cstdlib>
#include <dirent.h>
#include <fstream>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <vector>

#include "hiaiengine/log.h"
#include "opencv2/opencv.hpp"
#include "tool_api.h"

using hiai::Engine;
using namespace std;

namespace {
// output port (engine port begin with 0)
const uint32_t kSendDataPort = 0;

// sleep interval when queue full (unit:microseconds)
const __useconds_t kSleepInterval = 200000;

// get stat success
const int kStatSuccess = 0;
// image file path split character
const string kImagePathSeparator = ",";
// path separator
const string kPathSeparator = "/";

}

// register custom data type
HIAI_REGISTER_DATA_TYPE("ConsoleParams", ConsoleParams);
HIAI_REGISTER_DATA_TYPE("EngineTrans", EngineTrans);

HIAI_StatusT GeneralImage::Init(
    const hiai::AIConfig& config,
    const vector<hiai::AIModelDescription>& model_desc) {
  // do noting
  return HIAI_OK;
}

void GeneralImage::GetAllFiles(const string &path, vector<string> &file_vec) {
  // split file path
  vector<string> path_vector;
  SplitPath(path, path_vector);

  for (string every_path : path_vector) {
    // check path exist or not
    if (!IsPathExist(path)) {
      ERROR_LOG("Failed to deal path=%s. Reason: not exist or can not access.",
                every_path.c_str());
      continue;
    }

    // get files in path and sub-path
    GetPathFiles(every_path, file_vec);
  }

}

bool GeneralImage::IsDirectory(const string &path) {
  // get path stat
  struct stat buf;
  if (stat(path.c_str(), &buf) != kStatSuccess) {
    return false;
  }

  // check
  if (S_ISDIR(buf.st_mode)) {
    return true;
  } else {
    return false;
  }
}

bool GeneralImage::IsPathExist(const string &path) {
  ifstream file(path);
  if (!file) {
    return false;
  }
  return true;
}

void GeneralImage::SplitPath(const string &path, vector<string> &path_vec) {
  char *char_path = const_cast<char*>(path.c_str());
  const char *char_split = kImagePathSeparator.c_str();
  char *tmp_path = strtok(char_path, char_split);
  while (tmp_path) {
    path_vec.emplace_back(tmp_path);
    tmp_path = strtok(nullptr, char_split);

  }
}

void GeneralImage::GetPathFiles(const string &path, vector<string> &file_vec) {
  struct dirent *dirent_ptr = nullptr;
  DIR *dir = nullptr;
  if (IsDirectory(path)) {
    dir = opendir(path.c_str());
    while ((dirent_ptr = readdir(dir)) != nullptr) {
      // skip . and ..
      if (dirent_ptr->d_name[0] == '.') {
        continue;
      }

      // file path
      string full_path = path + kPathSeparator + dirent_ptr->d_name;
      // directory need recursion
      if (IsDirectory(full_path)) {
        GetPathFiles(full_path, file_vec);
      } else {
        // put file
        file_vec.emplace_back(full_path);
      }
    }
  } else {
    file_vec.emplace_back(path);
  }
}

bool GeneralImage::ArrangeImageInfo(shared_ptr<EngineTrans> &image_handle,
                                    const string &image_path) {
  // read image using OPENCV
  cv::Mat mat = cv::imread(image_path, CV_LOAD_IMAGE_COLOR);
  if (mat.empty()) {
    ERROR_LOG("Failed to deal file=%s. Reason: read image failed.",
              image_path.c_str());
    return false;
  }

  // set property
  image_handle->image_info.path = image_path;
  image_handle->image_info.width = mat.cols;
  image_handle->image_info.height = mat.rows;

  // set image data
  uint32_t size = mat.total() * mat.channels();
  u_int8_t *image_buf_ptr = new (nothrow) u_int8_t[size];
  if (image_buf_ptr == nullptr) {
    HIAI_ENGINE_LOG("new image buffer failed, size=%d!", size);
    ERROR_LOG("Failed to deal file=%s. Reason: new image buffer failed.",
              image_path.c_str());
    return false;
  }

  error_t mem_ret = memcpy_s(image_buf_ptr, size, mat.ptr<u_int8_t>(),
                             mat.total() * mat.channels());
  if (mem_ret != EOK) {
    delete[] image_buf_ptr;
    ERROR_LOG("Failed to deal file=%s. Reason: memcpy_s failed.",
              image_path.c_str());
    image_buf_ptr = nullptr;
    return false;
  }

  image_handle->image_info.size = size;
  image_handle->image_info.data.reset(image_buf_ptr,
                                      default_delete<u_int8_t[]>());
  return true;
}

bool GeneralImage::SendToEngine(const shared_ptr<EngineTrans> &image_handle) {
  // can not discard when queue full
  HIAI_StatusT hiai_ret;
  do {
    hiai_ret = SendData(kSendDataPort, "EngineTrans",
                        static_pointer_cast<void>(image_handle));
    // when queue full, sleep
    if (hiai_ret == HIAI_QUEUE_FULL) {
      HIAI_ENGINE_LOG("queue full, sleep 200ms");
      usleep(kSleepInterval);
    }
  } while (hiai_ret == HIAI_QUEUE_FULL);

  // send failed
  if (hiai_ret != HIAI_OK) {
    HIAI_ENGINE_LOG(HIAI_ENGINE_RUN_ARGS_NOT_RIGHT,
                    "call SendData failed, err_code=%d", hiai_ret);
    return false;
  }
  return true;
}

HIAI_IMPL_ENGINE_PROCESS("general_image",
    GeneralImage, INPUT_SIZE) {
  HIAI_StatusT ret = HIAI_OK;

  // Step1: check arg0
  if (arg0 == nullptr) {
    ERROR_LOG("Failed to deal file=nothing. Reason: arg0 is empty.");
    return HIAI_ERROR;
  }

  // Step2: get all files
  shared_ptr<ConsoleParams> console_param = static_pointer_cast<ConsoleParams>(
      arg0);
  string input_path = string(console_param->input_path);
  vector<string> file_vec;
  GetAllFiles(input_path, file_vec);
  if (file_vec.empty()) {
    ERROR_LOG("Failed to deal all empty path=%s.", input_path.c_str());
    return HIAI_ERROR;
  }

  // Step3: send every image to inference engine
  for (string path : file_vec) {
    shared_ptr<EngineTrans> image_handle = nullptr;
    MAKE_SHARED_NO_THROW(image_handle, EngineTrans);
    if (image_handle == nullptr) {
      ERROR_LOG("Failed to deal file=%s. Reason: new EngineTrans failed.",
                path.c_str());
      continue;
    }
    // arrange image information, if failed, skip this image
    if (!ArrangeImageInfo(image_handle, path)) {
      continue;
    }

    // send data to inference engine
    image_handle->console_params.input_path = console_param->input_path;
    image_handle->console_params.model_height = console_param->model_height;
    image_handle->console_params.model_width = console_param->model_width;
    image_handle->console_params.output_nums = console_param->output_nums;
    image_handle->console_params.output_path = console_param->output_path;
    if (!SendToEngine(image_handle)) {
      ERROR_LOG("Failed to deal file=%s. Reason: send data failed.",
                path.c_str());
      continue;
    }

    // sleep
    usleep(kSleepInterval);
  }

  // Step4: send finished data
  shared_ptr<EngineTrans> image_handle = nullptr;
  MAKE_SHARED_NO_THROW(image_handle, EngineTrans);
  if (image_handle == nullptr) {
    ERROR_LOG("Failed to send finish data. Reason: new EngineTrans failed.");
    ERROR_LOG("Please stop this process manually.");
    return HIAI_ERROR;
  }
  image_handle->is_finished = true;
  if (SendToEngine(image_handle)) {
    return HIAI_OK;
  }
  ERROR_LOG("Failed to send finish data. Reason: SendData failed.");
  ERROR_LOG("Please stop this process manually.");
  return HIAI_ERROR;
}
