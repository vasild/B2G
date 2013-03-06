#!/bin/sh

B2G_DIR=${B2G_DIR:-$(cd $(dirname $0)/..; pwd)}

cp ${B2G_DIR}/patches/apitrace_Android.mk ${B2G_DIR}/external/apitrace/Android.mk
