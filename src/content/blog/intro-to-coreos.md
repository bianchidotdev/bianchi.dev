---
title: TODO
description: TODO
pubDate: '2024-04-14'
heroImage: # TODO
---

Having worked on a lot of hand-crafted systems that are not reproducible or even fully understood, I've really come to appreciate infrastructure that's definable in code.

While systems like Kubernetes or Nomad can help achieve that, it's hardly suitable for the small-scale projects or a homelab.

The main alternatives tend to be:
* Configuration Management Software (such as Ansible)
* Virtual Machine Image Building (such as Packer)
* Declarative Operating Systems (such as NixOS or CoreOS)

Configuration management software is probably the most powerful and flexible of this set but comes with a number of drawbacks.
* 