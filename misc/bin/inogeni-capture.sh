#!/bin/bash

gst-launch-1.0 v4l2src device=/dev/v4l/by-id/usb-INOGENI_0832-INOGENI_4K2USB3_014A0832-video-index0  ! 'video/x-raw,width=1280,framerate=60/1' ! videoconvert ! videoscale ! autovideosink
