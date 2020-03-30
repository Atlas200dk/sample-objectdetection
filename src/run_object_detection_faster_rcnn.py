""" faster rcnn params check module"""
# !/usr/bin/env python3
# -*- coding: UTF-8 -*-
#
#   =======================================================================
#
# Copyright (C) 2018, Hisilicon Technologies Co., Ltd. All Rights Reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   1 Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#
#   2 Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#
#   3 Neither the names of the copyright holders nor the names of the
#   contributors may be used to endorse or promote products derived from this
#   software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#   =======================================================================
#
import argparse
import os
import re
import sys


CPP_EXE = None
CONCOLE_LIST = ' {} {} {} {} {}'


def get_args():
    """input argument parser function
        -w --model_width: width of input images required by model.
        -h --model_height: height of input images required by model.
        -i --input_path: paths and folders of input images.
        -o --output_path: folders of output images.
        -c --output_categories: number of faster r-cnn output categories.
        eg:
        python3 object_detection_faster_rcnn.py  \
        -w 512 -h 512 -i ./example.jpg -o ./out -c 21
    """
    parser = argparse.ArgumentParser(
        conflict_handler='resolve',
        description='''eg: python3 object_detection_faster_rcnn.py
         -w 512 -h 512 -i ./example.jpg -o ./out -c 21''')
    parser.add_argument('-w', '--model_width', required=True, type=int,
                        help='resized image width before inference.')
    parser.add_argument('-h', '--model_height', required=True, type=int,
                        help='resized image height before inference.')
    parser.add_argument('-i', '--input_path', required=True, nargs='*',
                        help='file path or folder of input images.')
    parser.add_argument('-o', '--output_path', default='./',
                        help='folder of output images.')
    parser.add_argument('-c', '--output_categories', type=int, default=21,
                        help='number of faster rcnn output categories.')
    return parser.parse_args()


def eprint(*args, **kwargs):
    """print error message to stderr
    """
    print(*args, file=sys.stderr, **kwargs)


def validate_args(args):
    """check console parameters according to restrictions.
    :return: True or False
    """
    check_flag = True
    for path in args.input_path:
        if os.path.isdir(path):
            if not os.listdir(path):
                eprint('[ERROR] input image path=%r is empty.' % path)
                check_flag = False
        elif not os.path.isfile(path):
            eprint('[ERROR] input image path=%r does not exist.' % path)
            check_flag = False
    if os.path.isfile(args.output_path):
        eprint('[ERROR] argument output_path should be a folder.')
    elif not os.path.exists(args.output_path):
        os.makedirs(args.output_path)
    if not 2 <= args.output_categories <= 32:
        eprint('[ERROR] number of faster rcnn output categories '
               'should between 2 and 32.')
        check_flag = False
    if not 16 <= args.model_width <= 4096:
        eprint('[ERROR] resized image width should between 16 and 4096.')
        check_flag = False
    if not 16 <= args.model_height <= 4096:
        eprint('[ERROR] resized image height should between 16 andd 4096.')
        check_flag = False
    return check_flag


def assemble_console_params(args):
    """assemble console params as agreed with cpp program.
    :return: console params string
    """
    image_path = ','.join(args.input_path)
    console_params = CONCOLE_LIST.format(args.model_width, args.model_height,
                                         image_path, args.output_path,
                                         args.output_categories)
    return console_params

    
def Init_CPP_EXE():
    check_flag = True
    global CPP_EXE
    file_dir=os.getcwd()
    count=0
    for dirpath, dirname, filename in os.walk(file_dir):
        if count >= 1:
            break
        for i in filename:
            if re.match("workspace_mind_studio",i):
                CPP_EXE='./'+i
                break
    if not CPP_EXE:
        eprint('[ERROR] excute file does not exist.')
        check_flag = False
    return check_flag
    
    
def main():
    """main function to receive console params then call cpp program.
    """
    args = get_args()
    if validate_args(args):
        if Init_CPP_EXE():
            if os.path.exists(CPP_EXE):
                console_params = assemble_console_params(args)
                os.system(CPP_EXE + console_params)
            else:
                eprint('[ERROR] cpp file does not exist.')


if __name__ == '__main__':
    main()
