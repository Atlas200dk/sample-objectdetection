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
#include "main.h"

#include <cstdlib>
#include <memory>
#include <unistd.h>

#include "hiaiengine/api.h"
#include "hiaiengine/data_type.h"
#include "hiaiengine/data_type_reg.h"
#include "data_type.h"
#include "tool_api.h"

using namespace std;

namespace {
// graph id
const uint32_t kGraphId = 1676964756;
// device id
const uint32_t kDeviceId = 0;
// inference engine id
const uint32_t kFirstEngineId = 487;
// inference port id
const uint32_t kFirstEnginePortId = 0;
// post engine id
const uint32_t kPostEngineId = 641;
// graph.config path
const string kGraphConfigFilePath = "./graph.config";

// args positon
const int32_t kModelWidthPos = 1;
const int32_t kModelHeightPos = 2;
const int32_t kImagePathPos = 3;
const int32_t kOutputPathPos = 4;
const int32_t kOutputNumsPos = 5;

// sleep interval for every image (unit: microseconds)
const __useconds_t kSleepInterval = 100000;
}

// register custom data
HIAI_REGISTER_DATA_TYPE("ConsoleParams", ConsoleParams);

// flag for end
int flag = 1;
// mutex for decrease flag
mutex mt;

HIAI_StatusT CustomDataRecvInterface::RecvData(
    const std::shared_ptr<void>& message) {
  // no need to read any message, only decrease flag
  mt.lock();
  flag--;
  mt.unlock();
  return HIAI_OK;
}

// set console parameters
void SetConsoleParams(char *argv[], shared_ptr<ConsoleParams> param_ptr) {
  // no need to check anything, python script already checked
  // and parameters all fixed position
  param_ptr->model_width = atoi(argv[kModelWidthPos]);
  param_ptr->model_height = atoi(argv[kModelHeightPos]);
  param_ptr->input_path = string(argv[kImagePathPos]);
  param_ptr->output_path = string(argv[kOutputPathPos]);
  param_ptr->output_nums = atoi(argv[kOutputNumsPos]);
}

int main(int argc, char *argv[]) {

  // Step1: Global System Initialization before using HIAI Engine
  HIAI_StatusT status = HIAI_Init(kDeviceId);
  if (status != HIAI_OK) {
    ERROR_LOG("Failed to call HIAI_Init, ret=%d.", status);
    return kHiaiInitFailed;
  }

  // Step2: Create and Start the Graph
  status = hiai::Graph::CreateGraph(kGraphConfigFilePath);
  if (status != HIAI_OK) {
    ERROR_LOG("Failed to start graph, ret=%d.", status);
    return kCreateGraphFailed;
  }

  // Step3: get instance
  std::shared_ptr<hiai::Graph> graph = hiai::Graph::GetInstance(kGraphId);
  if (graph == nullptr) {
    ERROR_LOG("Failed to get the graph-%u.", kGraphId);
    return kGetGraphInstanceFailed;
  }

  // Step4: set callback function
  hiai::EnginePortID target_port_config;
  target_port_config.graph_id = kGraphId;
  target_port_config.engine_id = kPostEngineId;
  target_port_config.port_id = 0;
  status = graph->SetDataRecvFunctor(
      target_port_config,
      std::shared_ptr<CustomDataRecvInterface>(
          new (nothrow) CustomDataRecvInterface()));
  if (status != HIAI_OK) {
    ERROR_LOG("Failed to set callback function.");
    return kSetCallbackFunctionError;
  }

  // Step5: send data
  hiai::EnginePortID engine_id;
  engine_id.graph_id = kGraphId;
  engine_id.engine_id = kFirstEngineId;
  engine_id.port_id = kFirstEnginePortId;

  shared_ptr<ConsoleParams> param_ptr = nullptr;
  MAKE_SHARED_NO_THROW(param_ptr, ConsoleParams);
  if (param_ptr == nullptr) {
    ERROR_LOG("Failed to send data. Reason: new data failed.");
    return kOtherError;
  }
  SetConsoleParams(argv, param_ptr);
  graph->SendData(engine_id, "ConsoleParams",
                  static_pointer_cast<void>(param_ptr));

  for (;;) {
    // finished, break
    if (flag <= 0) {
      break;
    } else {
      usleep(kSleepInterval);
    }
  }

  // destroy graph
  hiai::Graph::DestroyGraph(kGraphId);
  return 0;
}
