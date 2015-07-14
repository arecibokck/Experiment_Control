#! /usr/bin/env python
# -*- coding: utf-8 -*-

from os import devnull
import argparse
import re
from subprocess import Popen, PIPE
import numpy as np
from PIL import Image, ImageDraw, ImageFont

font = ImageFont.truetype("UbuntuMono-R.ttf",22)

def ffmpegReadPipe(file_path):
    temp=Popen(['ffmpeg', '-i', video_file], stdout=PIPE, stderr=PIPE)
    stdout, stderr = temp.communicate()
    pattern = re.compile(r'([1-9]\d+)x(\d+)')
    match = pattern.search(stderr)
    width = int(match.groups()[0])
    height = int(match.groups()[1])
    ffmpeg_command = ['ffmpeg',
                      '-i', file_path,
                      '-f', 'image2pipe',
                      '-pix_fmt', 'rgba',
                      '-vcodec', 'rawvideo',
                      '-threads', '0',
                      '-']
    dev_null = open(devnull, 'w')
    return Popen(ffmpeg_command, stdout=PIPE, stderr=dev_null), \
           width, height

def ffmpegWritePipe(file_path, width, height):
    ffmpeg_command = ['ffmpeg', '-y',
                      '-r', '5',
                      '-f', 'image2pipe',
                      '-vcodec', 'png',
                      '-s', str(width)+'x'+str(height),
                      '-pix_fmt','rgba',
                      '-i', '-',
                      '-vcodec', 'wmv2',
                      '-q:v', '2',
                      '-pix_fmt', 'yuv420p',
                      '-an',
                      '-threads', '0',
                      file_path]
    return Popen(ffmpeg_command, stdin=PIPE)

def getFrame(ffmpeg_pipe, width, height):
    return Image.fromstring('RGBA',(width, height),
                             ffmpeg_pipe.stdout.read(width*height*4),
                             'raw')

def putFrame(ffmpeg_pipe, frame):
    frame.save(ffmpeg_pipe.stdin, 'PNG')

def markImage(img, *argv):
    global font
    img_temp = ImageDraw.Draw(img)
    for marking in argv:
        if 'from_to' in marking:
            img_temp.line(lineEndPoints(marking['from_to'], img.size),
                          fill=marking['color'], width=marking['width'])
        if 'legend_text' in marking:
            img_temp.text(marking['legend_position'], 
                          marking['legend_text'], 
                          fill=marking['color'], font=font)
    return img

def lineEndPoints(point_list, size):
    width, height = size
    x1, y1, x2, y2 = point_list
    if x1 == x2:
        return [x1, 0, x1, height]
    if y1 == y2:
        return [0, y1, width, y1]
    m = float(y1 - y2) / (x1 - x2)
    c = y1 - (m * x1)
    y_start = 0
    y_end = height
    x_start = -c / m
    if x_start < 0:
        x_start = 0
        y_start = c
    elif x_start > width:
        x_start = width
        y_start = (m * x_start) + c
    x_end = (height - c) / m
    if x_end < 0:
        x_end = 0
        y_end = c
    elif x_end > width:
        x_end = width
        y_end = (m * x_end) + c
    return [x_start, y_start, x_end, y_end]

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Draw head and thorax\
            line on digitized head stabilization video with digitized \
            data.")
    parser.add_argument('-v', '--video', help="Digitized video file", 
                        required=True, dest='video_file')
    parser.add_argument('-d', '--data', help="Digitized data file",
                        required=True, dest='data_file')
    parser.add_argument('-o', '--output', help="Output video file",
                        required=False, dest='output_file',
                        default=None)
    
    args = parser.parse_args()
    video_file = args.video_file
    data_file = args.data_file
    output_file = args.output_file

    input_video_pipe, width, height = ffmpegReadPipe(video_file)
    data = np.genfromtxt(data_file, delimiter=',', skip_header=1)
    number_of_frames = data.shape[0]
    print number_of_frames
    if output_file is None:
        output_file = video_file[:-4] + "-marked.wmv"
    output_video_pipe = ffmpegWritePipe(output_file, width, height)

    for frame_number in range(number_of_frames):
        time = "  Time : " + '%3.3f' % (frame_number / float(600)) + "s"
        frame_read = getFrame(input_video_pipe, width, height)
        thorax_points = data[frame_number][1:5]
        head_points = data[frame_number][5:9]
        thorax_angle = data[frame_number][-2]
        head_angle = data[frame_number][-1]
        thorax_legend = "Thorax : " + '%+03.1f' % (thorax_angle) + u"°"
        head_legend = "  Head : " + '%+03.1f' % (head_angle) + u"°"
        marked_frame  = markImage(frame_read,
                                  {'from_to':thorax_points,
                                   'color':(255,0,0,128),
                                   'width':1,
                                   'legend_text':thorax_legend,
                                   'legend_position':(20,20)},
                                  {'from_to':head_points,
                                   'color':(255,255,0,128),
                                   'width':1,
                                   'legend_text':head_legend,
                                   'legend_position':(20,50)},
                                  {'legend_text':time,
                                   'legend_position':(20,100),
                                   'color':(255,255,255,128)})
        putFrame(output_video_pipe, marked_frame)

    input_video_pipe.terminate()
    output_video_pipe.terminate()

# vim: set ai nu et ts=4 sw=4:
