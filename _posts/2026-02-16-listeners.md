---
layout: post
title: "Coming soon to Sniffnet: Program identification"
share-title: "Coming soon to Sniffnet: Program identification"
nav-title: News
thumbnail-img: /assets/img/post/listeners/cover.png
share-img: /assets/img/post/listeners/cover.png
tags: [development]
github-discussion: xxxx
---

Listeners is a cross-platform library to get PID and name of processes listening on active network sockets. Even though this seems a very straightforward task, implementing it is a pain if you want to support multiple platforms, since each one has its OS-specific directories, data structure, and APIs (most of them written in C).

The fact that there is no other existing Rust library to do this task is what originally made me start develop this library 2 years ago, and I'm happy to see that it now has multiple public dependants, because it means that this problem is shared among other people / projects.

I faced this same issue in two different contexts: at my job, and while trying to implement process identification for Sniffnet (I'm Sniffnet's maintainer).

I'm particularly excited about this release for three reasons:

Support for FreeBSD (in addition to the already existing support for Windows, Linux, and macOS) was introduced thanks to my colleague Anton. To my knowledge there is no existing crate at all that does something similar on FreeBSD and this adds a huge value to the library, even if at the moment we're using bindings to C for this.
I've spent the past week's nights testing and adding exhaustive benchmarks that allowed to considerably improve the APIs performance. I had so much fun using criterion to benchmark it under different system loads, and I've made the results generation completely automated on GitHub Actions runners for all the supported platforms. You can find the results and charts on the README's Benchmarks section.
Thanks to point 2, I now judge the library mature, fast, and reliable enough for use in Sniffnet. I've already drafted a PR and I'm so excited that in-app process support is finally coming I hope in about a couple months.
Needless to say that you're more than welcome to contribute to the library trying to make it even faster, or adding support for more Operating Systems (NetBSD, OpenBSD, or even iOS and Android, why not!).