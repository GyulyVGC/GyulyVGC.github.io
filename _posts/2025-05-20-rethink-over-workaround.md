---
layout: post
title: "When rethinking a codebase is better than a workaround"
share-title: "When rethinking a codebase is better than a workaround"
nav-title: News
thumbnail-img: /assets/img/post/rethink-over-workaround/cover.png
share-img: /assets/img/post/rethink-over-workaround/cover.png
tags: [development]
github-discussion: 809
---

This is a different kind of post from what you're used to read on this blog.<br>
Today I won't be sharing a new release or achievement, but rather a **more technical behind-the-scenes** about the ongoing development of the project.<br><br>
We'll have a look at the framework that powers Sniffnet's user interface,
and at how the Rust programming language can be a life-saver when it comes to **restructuring a codebase**.<br><br>
But first, let me take a step back and explain **why** I decided to write this post in the first place.<br>

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

I had **two options** in front of me:
1. **duplicate** some of the UI logic and adapt it to support the respective data source
2. **rethink** the frontend architecture to make it more flexible and decoupled from the backend

The first option? A quick and easy fix — wait that's awesome!<br>
The second one? A more time-consuming and by far more complex solution — blah,
who wants to rethink core parts of a 20k+ lines codebase that works?<br>

Who the hell would choose the second route?<br>
Well, if this topic is worth a blog post, it's obvious **I chose option _2_**.<br>
It's pretty clear that option _1_ would've made the codebase way more difficult to maintain in the long run.<br>

<hr>

### The Elm Architecture

As you may already know, Sniffnet's UI is built on top of the <a target="_blank" href="https://iced.rs">iced</a> library.<br>
The framework takes inspiration from the <a target="_blank" href="https://guide.elm-lang.org/architecture/">Elm Architecture</a>,
a programming pattern to build interactive applications.

The Elm Architecture is based on four main components:
- **model** — the application's state
- **view** — a way to graphically represent the state
- **messages** — commands that trigger updates to the state
- **update** — a way to update the state in reaction to messages

<div align="center">
    <img width="50%" title="The Elm Architecture" src="{{ 'assets/img/post/rethink-over-workaround/cover.png' | relative_url }}" alt="The Elm Architecture"/>
</div>

This separation of concerns allows for a **deterministic flow of data**,
enabling to reconstruct the state of the application at any point in time given the initial model and the list of messages that have been processed by the update logic.<br>

In iced, what empowers these ideas even further are the constraints imposed by the **Rust** programming language.<br>
In fact, Rust's concepts of **ownership** and **immutability** make it possible to enforce a **single source of truth** for the application's state,
and to ensure that the state is only **modified in a controlled manner**.<br>
In other words, this means the state cannot be modified directly by the view logic or by any other part of the codebase,
but only via producing messages that are then processed by the update logic (the only component that has access to a mutable reference to the state).

<hr>

### So again, what's the problem?

I mentioned earlier that the UI was tightly coupled with the backend routine parsing network traffic,
but this seems to be in contrast with Elm principles of separating concerns and having a single source of truth.<br>
So, how is that possible?

Some parameters of Sniffnet's state were wrapped in structures
(see <a target="_blank" href="https://doc.rust-lang.org/std/sync/struct.Arc.html">`Arc`</a> and <a target="_blank" href="https://doc.rust-lang.org/std/sync/struct.Mutex.html">`Mutex`</a>)
that allow having shared, <a target="_blank" href="https://doc.rust-lang.org/reference/interior-mutability.html">interior-mutable</a> access to them.<br>
When I first started developing Sniffnet almost three years ago,
I was eager to use this pattern to let secondary threads access and modify the state of the app directly.

While this is a recurrent pattern in Rust and is generally a blessing in achieving 
<a target="_blank" href="https://doc.rust-lang.org/book/ch16-00-concurrency.html">fearless concurrency</a>,
it's not ideal using it for the iced application's state.

At the time, it was generally less clear to me how having a single source of truth could help keeping the flow of data smoother.<br>
A fact that was confusing to me was also that <a target="_blank" href="https://docs.rs/iced/0.4.0/iced/trait.Application.html#tymethod.view">iced's view logic had mutable access to the state</a> 
(_not how it's supposed to be, and later fixed_).

<hr>

### The solution

With time, I started realizing that using a different approach would've brought several benefits,
but it's only when I started working on PCAP file import that I finally decided to **take the plunge and rethink
how the backend interacts with the UI**.<br>

Instead of letting the backend modify the state remotely,
I started using the full power of iced's message handling system
(see <a target="_blank" href="https://docs.rs/iced/0.13.1/iced/struct.Task.html">`Task`</a> and <a target="_blank" href="https://docs.rs/iced/0.13.1/iced/struct.Subscription.html">`Subscription`</a>)
to **asynchronously send messages from the secondary threads to the frontend update logic**.

There were so **many moving pieces** that I was reluctant to do this at first.<br>
In the end, despite the consistent amount of needed changes, Rust's **powerful type system** allowed me to
define proper message kinds to correctly handle all the different scenarios,
and the compiler, as always, was my best friend in **orchestrating the whole process**.

I won't go and bore you with the details but if you'd like to, feel free to check all the implementation
specifics in the relative <a target="_blank" href="https://github.com/GyulyVGC/sniffnet/pull/806">pull request</a> on GitHub.

<hr>

### Conclusion

Even though the architectural changes object of this post don't impact the user experience or the app's performance,
it's a relief to know that everything is now less prone to bugs and easier to maintain.

What I can say is that I already loved iced for its concepts,
despite I wasn't using them to their full potential.<br>
This, hence, is also the story of how **I fell in love with iced once again**.

Wait, one last thing.

_Can I be honest with you?_

I **don't** care about flexing Sniffnet is written in Rust.<br>
I **don't** care about flexing my Rust skills either.<br>
I **don't** care if "_Rust_" sounds cool.

But I **do** care about **not getting crazy** when major changes are needed.<br>
And I **do** care about having a **clean and maintainable** codebase that makes me sleep at night.

Well, _Rust makes this possible_.<br>

It's _not_ marketing.<br>
It's _not_ a trend.<br>
It's _not_ a hype.<br>

It's _not only_ about performance and safety.

It's also, and _most importantly_, about **developer experience**.

This, in my humble opinion, is the real power of Rust.
