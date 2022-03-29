---
##-- draftstate --##
draft: false
##-- page info --##
title: "Octave"
date: 2022-03-27T23:27:12+08:00
categories:
- 学习笔记
tags:
series:
##-- page setting --##
# slug: ""
# type: ""
pinned: false
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

## 环境相关

载入 Spack:


```bash
source /opt/spack/share/spack/setup-env.sh
```

查看已经安装的包:

```bash
spack find
```

导入这里需要的包:

```bash
spack load cuda@11.0.2
spack load --first cmake@3.21.4
spack load openmpi
```

构建流程：

```bash
mkdir build
cd build
cmake -DCMAKE_CUDA_ARCHITECTURES=80 build ..
make -j
```

没有 `uint32_t`，可能是个 bug，需要额外 `#include<cstdint>` ，改在 `dataloader.h` 了。

## 运行

```bash
./bin/gpu_graph ~/data/orkut.g 5 0111010011100011100001100
```

把  `.g` 的图拷贝了一份过来

## Multiple GPU on cuda

[GPU programming in CUDA: Using multiple GPUs (prace-ri.eu)](https://events.prace-ri.eu/event/989/sessions/3096/attachments/1196/2029/cuda-multiple-gpus.pdf)

[CUDA Runtime API :: CUDA Toolkit Documentation (nvidia.com)](https://docs.nvidia.com/cuda/cuda-runtime-api/group__CUDART__DEVICE.html)		
