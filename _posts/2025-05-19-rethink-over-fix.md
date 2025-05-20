---
layout: post
title: "When rethinking a codebase is better than a quick fix"
share-title: "When rethinking a codebase is better than a quick fix"
nav-title: News
thumbnail-img: /assets/img/post/rethink-over-fix/cover.svg
share-img: /assets/img/post/rethink-over-fix/cover.svg
tags: [development]
---

This is a different kind of post from what you're used to read on this blog.<br>
Today I won't be sharing a new release or achievement, but rather a more technical **behind-the-scenes** about the ongoing development of the project.<br><br>
We'll have a look at the framework that powers Sniffnet (<a target="_blank" href="https://iced.rs">iced</a>),
and at how the Rust programming language can be a life-saver when it comes to **restructuring a codebase**.<br><br>
But first, let me take a step back and explain why I decided to write this post in the first place.<br>

<hr>

### The problem

While developing a new feature for Sniffnet, I realized that some important architectural changes were needed to make it work as intended.

The feature in question is the ability to **import offline data from a PCAP file** in addition to live network adapters monitoring.<br>
One of my goals was to **abstract the data source**, so that most of the code could be used to handle both live and offline data.<br>
This required a major rework of the way Sniffnet handles and displays network traffic,
and made me realize that the old infrastructure was not flexible enough to accommodate these changes.<br>

In particular, the frontend was **tightly coupled** with the backend routine in charge of parsing Internet traffic,
making it difficult to separate the two concerns.<br>
The side effects on the UI caused by capturing packets from a file instead of a network interface were more than I originally expected:
one of the most annoying ones was that while processing live data we can simply periodically poll the backend for traffic intensity,
this is not anymore true when importing from a file given that the read speed isn't known apriori and data in the file can potentially
contain time gaps.

I had two **options** in front of me:
- **Duplicate and adapt** some of the UI logic to accommodate both data sources
- **Re-think** the frontend architecture to make it more flexible and decoupled from the backend

The first option? A quick and easy fix — wait that's awesome!<br>
The second one? A more time-consuming and by far more complex solution — blah,
who wants to re-think core parts of a 20k+ lines codebase that works?<br>

Who the hell would choose the second route?<br>
Well, if this topic is worth a blog post, it's obvious I choose option 2.<br>
It was pretty obvious that option 1 would've made the codebase way more difficult to maintain in the long run.<br>
