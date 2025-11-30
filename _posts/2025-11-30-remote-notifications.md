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

The only prerequisite is to have <a href="{{ 'download' | relative_url }}">Sniffnet 1.4.2 installed</a>; if you already do, sit back and have a good read!

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

1. Install SIGNL4 on your smartphone from the App Store or Google Play.
2. Create a new account (you can even sign up using your Google or Microsoft account).
3. Once logged in, click on the button at the top right to access settings, then select the "APIs" tab.
4. There you'll find your unique webhook URL in the "Inbound Webhook" section; write it down somewhere, as we'll need it later.
5. (Optional) Feel free to explore other app settings, as you can customize alerts categories, notification preferences, and more.

<hr>

### Configuring Sniffnet

Now that we have a webhook URL ready to receive notifications, it's time to configure Sniffnet to send them. <br>

1. Open Sniffnet and head to the settings by clicking on the button at the top right.
2. Select the "Notifications" tab.
3. Enable the "Remote notifications" toggle, and paste the SIGNL4 URL you got from the previous section.
4. In the same "Notifications" tab, enable the events you want to be alerted about: you can learn more about them in the _Notifications_ Wiki page.

At this point, Sniffnet is all set to send webhook notifications to your SIGNL4 app!

Below you can see a sample notification received on the SIGNL4 app when activating the "New data exchanged from favorite" alert and saving `github.com` as favorite in Sniffnet.

<hr>

### Enhancing notifications with packet filters

Among the available notification types, Sniffnet support alerts when a specified data threshold is exceeded. <br>
In general, this is useful to be informed about large downloads or uploads happening on the monitored machine. <br>
However, if you want to closely track a certain kind of traffic, you can leverage filters to refine when such notifications are triggered.

Packet filters programs are routines that run inside Sniffnet and inspect each packet to determine whether it matches given criteria. <br>
Such programs follow the Berkeley Packet Filter (BPF) syntax, a standardized, powerful, and flexible way to specify the traffic you want to monitor. <br>
Online you can find many resources to learn BPF syntax: <a target="_blank" href="https://www.ibm.com/docs/en/qsip/7.4?topic=queries-berkeley-packet-filters">this IBM guide</a> is a good starting point.

Setting up a filter is quite straightforward and can be done from Sniffnet initial screen as described in the _Filters configuration_ Wiki page.

As an example, let's say you want to be notified whenever your machine opens a new TCP connection to a server running on port 22 (SSH). <br>
To do so, you can set a filter like the following one:

```
tcp[13] & 2 != 0 and dst port 22
```

This program checks whether the TCP flags field (the 14th byte of the TCP header, hence the index 13) has the SYN bit set (indicating a new connection) and whether the destination port is 22. <br>
With this filter in place, Sniffnet will only monitor packets matching these criteria:
in this scenario, you can set the notifications data threshold to zero to effectively get an alert for every new SSH connection attempt.

If you followed the steps in the previous sections, you won't only receive in-app notifications on the monitored machine,
but also webhook alerts on your smartphone via SIGNL4,
allowing you to keep track of your machine's network activity even when you're away from it.

<hr>

### Wrapping up

Getting remote notifications from Sniffnet is a powerful way to monitor your machine's network activity from afar. <br>
By leveraging webhooks and packet filters, you can customize alerts to fit your specific needs and stay informed about important events happening on your system.

Among the features planned for the near future there are custom IP blacklist and enhancements to favorites, which will further extend Sniffnet's alerting capabilities. <br>
If you have in mind other possible events of interest to trigger a notification, don't hesitate to share your feedback. 

This post was the first tutorial-like article published on the blog, and I hope you found it useful. <br>
I may consider writing more tutorials in the future, especially targeted at covering the app's most advanced use cases.

Stay tuned for more updates and, as always, happy sniffing!
