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

Less than a month ago a <a target="_blank" href="https://github.com/GyulyVGC/sniffnet/releases/tag/v1.4.2">new version</a> of Sniffnet was released, and
among the most notable introduced feature there's the possibility to **forward in-app notifications via webhook**. <br><br>
This is useful, for instance, when you are away from your computer and want to be informed about its network activity. <br>
Or maybe you're running Sniffnet on a server and want to receive notifications on your main workstation. <br>
Or even you're a network administrator in need to be alerted about events happening on multiple machines.

<div align="center">
<picture>
<img alt="Remote notifications" title="Remote notifications" src="{{ 'assets/img/post/remote-notifications/cover.png' | relative_url }}" width="80%"/>
</picture>
</div>

Today you'll understand how Sniffnet makes this possible, and you'll also learn how to get the most out of built-in notifications by setting up advanced packet filter programs.

The only prerequisite is to <a href="{{ 'download' | relative_url }}">install Sniffnet 1.4.2</a>. <br>
If you already downloaded it, sit back and have a good read!

<hr>

### Introduction to webhooks

For a long time Sniffnet allowed its users to be warned about certain network events in the form of **in-app notifications**. <br>
While this is useful to get alerts on the monitored machine, it doesn't allow one to be notified remotely. <br>
To fill this gap, support for remote notifications via webhook was added recently.

A **webhook** is a real-time, automated message sent from one app to another, acting as a notification mechanism to 
signal that an event has occurred.<br>
The webhook producer (Sniffnet in this case) sends an object (typically in JSON format) containing the event details to a
consumer, which listens for messages at a given endpoint and shows them to the user.<br>
Webhooks are powerful yet simple in how they are conceived: in practical terms they consist of
HTTP POST requests sent to a URL — this means that you could even set up your own server to handle such messages in a custom way.

<div align="center">
<picture>
<img alt="Webhook diagram" title="Webhook diagram" src="{{ 'assets/img/post/remote-notifications/webhook.png' | relative_url }}" width="50%"/>
</picture>
</div>

Since creating a custom web server is beyond the scope of this blog post, the first step we need to take is **determine which service to use** as the consumer of Sniffnet's alerts. <br>
Said in a different way, we need a solution that makes available for us a pre-configured URL to receive webhooks:
<a target="_blank" href="https://www.svix.com">Svix</a>,
<a target="_blank" href="https://ifttt.com/maker_webhooks/">IFTTT</a>,
and <a target="_blank" href="https://www.signl4.com">SIGNL4</a> are some examples of enterprise-ready services,
but if you're just playing around and want to test things out you can also look at something ready-to-use like <a target="_blank" href="https://webhook.site">Webhook.site</a>.

<hr>

### Setting up the webhook consumer

<a target="_blank" href="https://www.signl4.com">
<img style="padding-left: 5px" align="right" alt="SIGNL4" title="SIGNL4" src="{{ 'assets/img/post/remote-notifications/signl4.png' | relative_url }}" width="140px"/>
</a>

In this tutorial we'll use **SIGNL4**, an application that can run on all modern smartphones
and displays webhook notifications in an intuitive way. <br>
It comes with a free plan that supports our use case, and it's characterised by a straightforward setup,
as described in the following.

1. Install SIGNL4 on your smartphone from the <a target="_blank" href="https://apps.apple.com/us/app/signl4-mobile-alerting/id1100283480">App Store</a> or <a target="_blank" href="https://play.google.com/store/apps/details?id=com.derdack.signl4&hl=en">Google Play</a>.
2. Create a new account (you can even sign up using Google or Microsoft).
3. Once logged in, click on the button in the top right corner to access settings, then select the _"APIs"_ tab.
4. There you'll find your unique webhook URL in the _"Inbound Webhook"_ section; write it down somewhere, as we'll need it later.

<div align="center">
<picture>
<img alt="SIGNL4 Inbound Webhook" title="SIGNL4 Inbound Webhook" src="{{ 'assets/img/post/remote-notifications/url.png' | relative_url }}" width="30%"/>
</picture>
</div>

Feel free to explore other SIGNL4 settings, as you can customize alerts categories, notification preferences, and more.

<hr>

### Configuring Sniffnet

Now that we have a webhook URL ready to receive notifications, it's time to configure Sniffnet to send them out. <br>

1. Open Sniffnet and head to the settings by clicking on the button at the top right.
2. Select the _"Notifications"_ tab.
3. Enable the events you want to be alerted about: you can learn more about them in the <a target="_blank" href="https://github.com/GyulyVGC/sniffnet/wiki/Notifications">_Notifications_</a> Wiki page.
4. In the same settings tab, enable the _"Remote notifications"_ toggle, and paste the SIGNL4 URL you got from the previous section.

<div align="center">
<picture>
<img alt="Remote notifications" title="Remote notifications" src="{{ 'assets/img/post/remote-notifications/remote_notifications.png' | relative_url }}" width="90%"/>
</picture>
</div>

At this point, Sniffnet is all set to send webhook notifications to the configured endpoint.

Below you can see a sample notification received on the SIGNL4 app when activating the _"New data exchanged from favorite"_ alert and saving `github.com` as favorite in Sniffnet.

<div align="center">
<picture>
<img alt="Favorite notification" title="Favorite notification" src="{{ 'assets/img/post/remote-notifications/favorite.png' | relative_url }}" width="30%"/>
</picture>
</div>

<hr>

### Enhancing notifications with packet filters

Among the available notification types, Sniffnet support alerts when a specified data threshold is exceeded. <br>
In general, this is useful to be informed about large downloads or uploads happening on the monitored machine. <br>
However, if you want to closely track a certain kind of traffic, you can leverage filters to refine when such notifications are triggered.

**Packet filters programs** are routines that run inside Sniffnet and inspect each packet to determine whether it matches given criteria. <br>
Such programs follow the <a target="_blank" href="https://en.wikipedia.org/wiki/Berkeley_Packet_Filter">Berkeley Packet Filter</a> (BPF) syntax, a standardized, powerful, and flexible way to specify the traffic you want to monitor. <br>
Online you can find many resources to learn BPF syntax: <a target="_blank" href="https://www.ibm.com/docs/en/qsip/7.4?topic=queries-berkeley-packet-filters">this IBM guide</a> is a good starting point.

Once you're familiar with the syntax, setting up a filter is simple and can be done from Sniffnet initial screen as described in the <a target="_blank" href="https://github.com/GyulyVGC/sniffnet/wiki/Filters-configuration">_Filters configuration_</a> Wiki page.

As an example, let's say you want to be notified whenever your machine opens a new TCP connection to a server running on port 22 (SSH). <br>
To do so, you can set a filter like the following one:

<div align="center">
<picture>
<img alt="BPF program" title="BPF program" src="{{ 'assets/img/post/remote-notifications/filter.png' | relative_url }}" width="90%"/>
</picture>
</div>

This program checks whether the TCP flags field (the 14th byte of the TCP header, hence the index 13) has the SYN bit set (indicating a new connection) and whether the destination port is 22. <br>
With this filter in place, Sniffnet will only monitor packets matching such criteria:
in this scenario, you can set the notifications data threshold to zero to effectively get an alert for every new SSH connection attempt.

<div align="center">
<picture>
<img alt="Notifications threshold" title="Notifications threshold" src="{{ 'assets/img/post/remote-notifications/threshold.png' | relative_url }}" width="90%"/>
</picture>
</div>

If you followed the steps in the previous sections, you won't only receive in-app notifications on the monitored machine,
but also webhook alerts on your smartphone via SIGNL4,
allowing you to keep track of your machine's network activity even when you're away from it.

<hr>

### Wrapping up

Getting remote notifications from Sniffnet is a powerful way to monitor your machine's network activity from afar. <br>
By leveraging webhooks and packet filters, you can customize alerts to fit your specific needs and stay informed about important events happening on your system.

Among the features planned for the near future there are <a target="_blank" href="https://github.com/GyulyVGC/sniffnet/issues/729">custom IP blacklists</a> and <a target="_blank" href="https://github.com/GyulyVGC/sniffnet/issues/839">enhancements to favorites</a>, which will further extend Sniffnet's alerting capabilities. <br>
If you have in mind more events of interest to trigger a notification, don't hesitate to share your ideas. 

This post is the first tutorial-like article published on the blog, and I hope you found it useful. <br>
I may consider writing more tutorials in the future, especially targeted at covering the app's most advanced use cases.

I wish you all a joyful holiday season in advance and, as always, happy sniffing!
