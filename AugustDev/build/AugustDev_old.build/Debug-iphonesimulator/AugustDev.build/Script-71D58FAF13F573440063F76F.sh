#!/bin/sh
install_name_tool -change ./libfmodex.dylib @loader_path/../Frameworks/libfmodex.dylib “$TARGET_BUILD_DIR/$PRODUCT_NAME.app/Contents/MacOS/$PRODUCT_NAME”
