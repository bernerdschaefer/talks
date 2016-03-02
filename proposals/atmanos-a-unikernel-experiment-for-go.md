# Go without the operating system

Go lets you to compile your program into stand-alone binaries which can be
safely shared across systems without worrying about a missing dependency. But
there's one thing even a stand-alone executable depends on: the operating
system. What if you could remove that dependency, too?

AtmanOS is a project built to explore that question. It allows you to compile
ordinary Go programs and run them on cloud providers like Amazon's EC2, without
a traditional operating system.

Let's explore how it works, how to use it, and some condierations for putting
it into production.

Notes for Organizers
--------------------

AtmanOS is my nights-and-weekends project,
which allows you to cross-compile programs (`GOOS=atman go build`)
to run directly on Xen -- and therefore providers like EC2 --
without a traditional operating system.

It's a unikernel for Go, written in Go.

I've been quietly building AtmanOS over the last few months.
The project is still really young,
but I'd love to share it with more people.
GopherCon is the best-fitting venue I know of to do that.

I want attendees to come away with a better understanding
of what unikernels are (without the buzzwords),
and an excitement to start experimenting with them.

There are a lot of open questions around unikernels
before we see wider adoption in production;
I think that by sharing AtmanOS --
which allows people to start using them today --
we'll get more people thinking about and answering these questions.

I intend for the talk to have the following structure,
with a mix of slides and live demos:

- Intro to unikernels (What / Why / How)
- Intro to AtmanOS
  - What is it?
  - Unikernels for Go?
- Code walk: What happens when my program runs?
  - Managing memory
  - Scheduling goroutines
  - Using the network
- Writing Go applications with unikernels in mind
- Deploying to Xen and cloud providers
  - Live: build, deploy to EC2, hit in a browser?
- Unsolved problems / areas for further research
  - Logging, debugging, configuration, etc.

Bio
---

Bernerd leads the team at thoughtbot in Portland, where he helps clients build great digital products. He prefers to spend his nights and weekends hiking in Forest Park and cooking up tasty meals at home, as well as hacking on personal projects like AtmanOS.
