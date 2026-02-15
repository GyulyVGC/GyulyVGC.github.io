---
layout: post
title: "One of the most intricate programming challenges I've ever faced"
share-title: "One of the most intricate programming challenges I've ever faced"
nav-title: News
thumbnail-img: /assets/img/post/process-identification/cover.png
share-img: /assets/img/post/process-identification/cover.png
tags: [development]
github-discussion: xxxx
---

Hey everyone, it's already been two months since the last blog post!<br><br>
Today I'm back to share some behind-the-scenes about the development of a new feature for Sniffnet: **process identification**, a.k.a. <a target="_blank" href="https://github.com/GyulyVGC/sniffnet/issues/170#issuecomment-3145510131">the most requested feature</a> since the very beginning of the project.

<hr>

### What's process identification?

With _"process identification"_ in a network monitoring context, I mean the possibility to discover which program is responsible for a given network connection.

This can be determined by looking at the open TCP/UDP ports on the system and finding out which process is currently using them.

It's a very useful feature, because it allows you to understand which applications are responsible for the observed network activity.

<div align="center">
<picture>
<img alt="Processes and network data" title="Processes and network data" src="{{ 'assets/img/post/process-identification/cover.png' | relative_url }}" width="40%"/>
</picture>
</div>

If implementing this feature seems like a no-brainer to you, _well..._ read on because it turned out to be a much more complex task than I could imagine, and this is the reason why the related GitHub issue has been open for almost 3 years.

<hr>

### Challenges in implementing process identification

First of all, the implementation is highly **OS-specific**: each platform has its own directories and data structures storing such information, and APIs to interact with them are often not well documented and written in C (therefore not very ergonomic to use from Rust). <br>
And unfortunately, there is no Rust library ready-to-use satisfying the needs of Sniffnet.

One could argue that this is a solved problem, since there are already existing tools to do it: for instance, on Linux and Windows you have `netstat`, and on macOS you have `lsof` or `nettop`. <br>
However, these tools are not designed to be used as libraries and spawining a shell to execute them repeatedly is not efficient, especially if you want to monitor the network activity in real-time. <br>
Moreover, they don't provide all the information Sniffnet needs, such as the process name and path.

And I didn't even mention yet what's the biggest challenge: the least system-intrusive ways to implement the feature are **snapshot-based**, meaning that they require to read the system state at a given moment in time and do some computations to find out the associations between open ports and their owning processes. <br>
I'm referring to using `libproc` on macOS, the `/proc` filesystem on Linux, and `iphlpapi` on Windows. <br>
This is not a problem in itself, but it generates the need to do this processing very efficiently, and it leads to cases where it's not possible to retrieve process information at all.<br>
For instance, short-lived connections can go undetected, and system processes with elevated privileges can be hidden to user-space applications for security reasons.

More system-intrusive approaches exist, such as using **kernel-level hooks** to intercept the system calls responsible for creating network connections. <br>
An example of this is <a target="_blank" href="https://ebpf.io/what-is-ebpf/">eBPF</a> on Linux, which requires to run privileged code inside the kernel. <br>
On macOS, you'd even need entitlements from Apple to be able to do something similar through their <a target="_blank" href="https://developer.apple.com/documentation/networkextension">Network Extension framework</a>. <br>
While these approaches are way more accurate, they go against Sniffnet's philosophy of being a lightweight, non-intrusive, and friendly app that can be installed by anyone.

After considering all the options, I decided to go with the snapshot-based approach. <br>
Despite being aware it's not flawless, I believe it to be the best compromise for Sniffnet's use case.

<hr>

### The library behind the feature: `listeners`

<a target="_blank" href="https://github.com/GyulyVGC/listeners">`listeners`</a> is an open-source library I've been working on for the past 2 years with the goal of supporting this feature.

<div align="center">
<picture>
<a target="_blank" href="https://github.com/GyulyVGC/listeners?tab=readme-ov-file#listeners">
<img alt="listeners library" title="listeners library" src="{{ 'assets/img/post/process-identification/listeners.png' | relative_url }}" width="90%"/>
</a>
</picture>
</div>

Being Sniffnet a cross-platform application, I needed a solution that could work on different Operating Systems:
no other Rust crate provides this functionality supporting multiple platforms, and the existing ones are not maintained or satisfactory enough even for a single OS.

Interestingly, I also had this same need at my job, where we also wanted a Rust way to do it: this motivated me even further to contribute to the library. <br>
After two years, I'm happy to see that `listeners` was downloaded 150k times and has now multiple public dependents both on _crates.io_ and GitHub, which means that this is a problem shared among many people and projects.

Just some days ago `listeners` <a target="_blank" href="https://github.com/GyulyVGC/listeners/releases/tag/v0.4.0">v0.4.0</a> was published, and I'm particularly proud of this release for at least two reasons:
1. **Support for FreeBSD** was introduced thanks to my colleague <a target="_blank" href="https://github.com/antoncxx">Anton</a> (in addition to the already existing support for Windows, Linux, and macOS).<br>To my knowledge there is no existing crate at all that does something similar targeting FreeBSD and this adds a huge value to the library, even if at the moment we're using Rust-to-C bindings for this.
2. I've spent the past week's nights **testing and extensively benchmarking** the library, considerably improving the APIs performance.<br>I had so much fun using <a target="_blank" href="https://crates.io/crates/criterion">`criterion`</a> to benchmark it under different system loads, and I've made the results generation completely automated on GitHub Actions runners for all the supported platforms.<br>You can find the results and more charts in the README's <a target="_blank" href="https://github.com/GyulyVGC/listeners?tab=readme-ov-file#benchmarks">Benchmarks section</a>.

<div align="center">
<picture>
<img alt="Windows benchmark (high system load)" title="Windows benchmark (high system load)" src="{{ 'assets/img/post/process-identification/windows_bench.svg' | relative_url }}" width="50%"/>
</picture>
</div>

Thanks to point 2, I now judge the library **mature, fast, and reliable enough** for use in Sniffnet.

If you're a Rust developer, you're more than welcome to contribute to the library trying to make it even faster, or adding support for more Operating Systems (NetBSD, OpenBSD, or even iOS and Android, why not!).

<hr>

### How Sniffnet will implement the feature

Sniffnet will use `listeners` to retrieve the process for each observed network connection, and will show it in the UI's _Overview_ and _Inspect_ pages.

Additionally, it will use another library called <a target="_blank" href="https://github.com/GyulyVGC/picon">`picon`</a> (I'm still working on it) to retrieve app icons given their program path, and will show them in the UI as well making it easier to identify processes at a glance.

The workflow I plan to use is indeed pretty complex, including **caching** to minimize performance impact and **retries** to maximize the chances to correctly retrieve process information for a given open port.

In the flowchart below you can see a draft of Sniffnet-side implementation of the feature.

// img will go here

<hr>

### Conclusion

I hope this post wasn't too scary to read,
and that it gave you an idea of how much work is behind a seemingly simple feature like this.

_Nothing worth having comes easy_, someone says.


