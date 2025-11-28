---
layout: post
title: "Sniffnet webhook notifications to monitor remote network activity"
share-title: "Sniffnet webhook notifications to monitor remote network activity"
nav-title: News
thumbnail-img: /assets/img/post/remote-notifications/cover.png
share-img: /assets/img/post/remote-notifications/cover.png
tags: [tutorial]
github-discussion: xxx
---

Earlier this month a <a target="_blank" href="https://github.com/GyulyVGC/sniffnet/releases/tag/v1.4.2">new version</a> of Sniffnet was released, and
among the most notable introduced feature there's the possibility to **forward in-app notifications via webhook**. <br><br>
This is useful, for instance, when you are away from your computer and want to be informed about its network activity. <br>
Or maybe you're running Sniffnet on a server and want to receive notifications on your main workstation. <br>
Or even you're a network administrator in need to be alerted about events happening on multiple machines.

<div align="center">
<picture>
<img alt="Remote notifications" title="Remote notifications" src="{{ 'assets/img/post/remote-notifications/cover.png' | relative_url }}" width="80%"/>
</picture>
</div>

Today you'll understand how to do all of this, and you'll also learn how to get the most out of built-in notifications by setting up advanced packet filter programs.

The only prerequisite is to have <a href="{{ 'download' | relative_url }}">Sniffnet installed</a>; if you already do, sit back and have a good read!

<hr>

### Introduction to webhooks

For a long time Sniffnet allowed its users to be warned about certain network events in the form of **in-app notifications**. <br>
While this is useful to get alerts on the monitored machine, it doesn't allow one to be notified remotely. <br>
To fill this gap, we recently added support for remote notifications via webhook.

A **webhook** is a real-time, automated message sent from one app to another, acting as a notification mechanism to 
signal that an event has occurred.<br>
The webhook producer (Sniffnet in this case) sends an object containing the event details to a
consumer, which listens for messages at a given endpoint and shows them to the user.<br>
Webhooks are powerful yet simple in how they are conceived: in more practical terms they simply consist of
HTTP POST requests sent to a URL — this means that you could even set up your own server to handle such messages in a custom way.

Since creating a custom web server is beyond the scope of this blog post, the first step we need to take is **determine which service** to use as the consumer of Sniffnet's alerts. <br>
Said in a different way, we need a solution that makes available for us a pre-configured URL to receive webhooks:
svix, IFTTT, and SIGNL4 are some examples of enterprise-ready services, but if you're just playing around and want to test things out you can also use something more straightforward like webhook.site.

<hr>

### Setting up the webhook receiver

In this tutorial we'll use **SIGNL4**, an application that can run on all modern smartphones
and displays webhook notifications in an intuitive way. <br>
It comes with a free plan that supports our use case, and it's characterised by a quite easy setup,
as described in the following.

1. Install SIGNL4 from the App Store or Google Play.
2. 
