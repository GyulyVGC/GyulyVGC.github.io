---
layout: post
title: Sniffnet recently got a complete security audit
share-title: Sniffnet recently got a complete security audit
thumbnail-img: /assets/img/post/security-audit/cover.png
share-img: /assets/img/post/security-audit/cover.png
tags: [event]
---

It's not a secret that modern world heavily relies on software.<br>
From the apps installed on our phones to the systems that power our cars and homes, software is ubiquitously present in our lives.<br>
As such, guaranteeing **software security and robustness** is of utmost importance.<br><br>
Software **vulnerabilities** are more common than we think, and they can lead to serious consequences:
data breaches, unauthorized access to sensitive information, cyber-attacks exposure, and financial losses just to name a few.

<hr>

One of Sniffnet's top priorities has always been to ensure the security of its users safeguarding the **privacy** of their data and the **integrity** of their systems.<br>
To achieve this, Sniffnet is designed with a **security-first approach** characterized by **rigorous tests** to identify potential vulnerabilities,
and a **commitment to open-source development** to make the code accessible for scrutiny by the community.

Taking a step further in this direction, Sniffnet has recently undergone a **complete security audit** by <a target="_blank" href="https://www.radicallyopensecurity.com">Radically Open Security</a>,
the world’s first not-for-profit computer security consultancy company.<br>

<div align="center">
    <a target="_blank" href="https://www.radicallyopensecurity.com">
        <img width="50%" title="ROS" src="{{ 'assets/img/post/security-audit/cover.png' | relative_url }}" alt="ROS"/>
    </a>
</div>

The audit, offered as part of the <a href="{{ 'news/ngi-program' | relative_url }}">Next Generation Internet program</a>, was conducted by a seasoned penetration tester in **different phases**:
- Static analysis and dependency checking
- Code analysis and fuzzing
- Dynamic analysis on most of the supported platforms (Windows, Linux, macOS, FreeBSD)
- Interactive testing for crashes and unexpected behaviors

<hr>

The outcome of the audit was definitely **positive**, as described in an **excerpt** from the report:
> It is a good sign that this audit has not uncovered anything with significant impact.<br>
Having a small attack surface is a nice characteristic of Sniffnet.<br>
It provides its functionality mostly via offline databases, only taking what it needs from the incoming traffic, and making reverse DNS lookups to provide hostnames for IPs.<br>
Information is presented without any markup languages involved, cutting off the opportunity for any code injection.<br>
Overall we are pleased with the security posture of Sniffnet and the engagement of the developer in this process.

Given that the only relevant finding was a **low-severity issue** that <a target="_blank" href="https://github.com/GyulyVGC/sniffnet/pull/776">has already been fixed</a>,
I'm pleased to share the <a target="_blank" href="https://github.com/GyulyVGC/sniffnet/blob/main/resources/audits/security_1.pdf">full 21-pages audit report</a> for transparency and to provide users with the confidence they deserve when using Sniffnet.

As emphasized by the report itself, _"security is a process that must be continuously evaluated and improved"_.<br>
For this reason, we'll keep working hard to ensure that Sniffnet remains a secure and reliable tool for everyone.
