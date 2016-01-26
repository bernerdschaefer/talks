# AtmanOS: A unikernel experiment for Go

What would a unikernel for Go, written in Go, look like?

AtmanOS is a project built to explore that question. It allows you to compile
ordinary Go programs and run them on cloud providers like Amazon's EC2, without
a traditional operating system.

Let's explore how it works, how and why you might want to use it, and some of
the open questions for taking unikernels to production.

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
- Open questions
  - Logging, debugging, configuration, etc.
