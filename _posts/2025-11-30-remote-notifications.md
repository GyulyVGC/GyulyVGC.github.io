---
layout: post
title: "Monitor remote network activity with Sniffnet webhook notifications"
share-title: "Monitor remote network activity with Sniffnet webhook notifications"
nav-title: News
thumbnail-img: /assets/img/post/remote-notifications/cover.png
share-img: /assets/img/post/remote-notifications/cover.png
tags: [tutorial]
github-discussion: xxx
---

Earlier this month, a <a target="_blank" href="https://github.com/GyulyVGC/sniffnet/releases/tag/v1.4.2">new version</a> of Sniffnet was released.<br>
The most notable feature introduced by this release is the possibility to **forward in-app notifications via webhook**. <br>
This is useful, for instance, when you are away from your computer and want to be informed about its network activity. <br>
Or maybe you're running Sniffnet on a server and want to receive notifications on your main workstation. <br>
Or even you're a network administrator in need to be alerted about events happening on multiple machines. <br><br>
Today you'll learn how to do all of this, and you'll understand how to get the most out of built-in notifications by setting up advanced packet filter programs. <br>
The only prerequisite is to have <a href="{{ 'download' | relative_url }}">Sniffnet installed</a>; if you already do, sit back and have a good read!

<hr>

### Remote notifications

For a long time Sniffnet allowed its users to be warned about certain network events in the form of in-app notifications. <br>
While this is useful to get alerts on the monitored machine, it doesn't allow to be notified remotely. <br>
To fill this gap, we recently added support for remote notifications via webhook.

A **webhook** is a real-time, automated message sent from one app to another, acting as a notification mechanism to 
signal that an event has occurred.<br>
The webhook sender (Sniffnet in this case) emits an HTTP request containing the event details,
while the receiver listens for messages at a given URL and shows them to the user. 

The first step we need to take is to **determine which service** to use as the receiver for Sniffnet's remote notifications. <br>
There is a bunch of solutions available for this use case: svix, IFTTT, and octohook are some examples 
of enterprise-ready services, but if you're just playing around and want to test things out you can also use something like webhook.site.<br>
In this tutorial, we'll use **SIGNL4** that has a free plan compatible with what we need to do, can run on all modern smartphones,
and natively displays notifications in an intuitive way.

You can install SIGNL4 from the App Store or Google Play. <br>
