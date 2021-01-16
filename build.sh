#!/usr/bin/env bash

# 环境路径配置
if [ -f "./local-linux.properties" ]; then
  rm -rf ./local.properties
  mv ./local-linux.properties ./local.properties
fi

# 签名路径配置
if [ -f "./app/signing-linux.properties" ]; then
  rm -rf ./app/signing.properties
  mv ./app/signing-linux.properties ./app/signing.properties
fi

# 编译附加混淆加固
if [ -f "./riru/build-linux.gradle" ]; then
  rm -rf ./riru/build.gradle
  mv ./riru/build-linux.gradle ./riru/build.gradle
fi

# 设置权限
chmod 555 ./gradlew

# 清空编译缓存
rm -rf ./out
rm -rf ./build
rm -rf ./riru/.cxx
rm -rf ./riru/build
rm -rf ./stub/build
rm -rf ./app/build

# 转换换行符
sed -i 's/\r//' ./gradlew

# 执行编译
source ./gradlew assembleRelease
