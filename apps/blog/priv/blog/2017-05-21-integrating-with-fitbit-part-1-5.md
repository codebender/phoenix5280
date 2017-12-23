---
title: Integrating with Fitbit - Part 1.5 ☂️
created_at: 2017-05-21
intro: Refactoring the Fitbit portion into an OTP App and the entire website into an Elixir umbrella App. Harder, Better, Faster, Stronger.
---

![umbrellas](https://cloud.githubusercontent.com/assets/987305/26287451/ef2000d6-3e38-11e7-9aed-d03b2244f681.jpeg){:width="100%"}

#### TL;DR - [My Umbrella App Pull Request](https://github.com/codebender/phoenix5280/pull/4)

&laquo; [Integrating with Fitbit - Part 1](/blog_posts/2017-04-28-integrating-with-fitbit-part-1)

&laquo; [My Fitbit Stats Page](/fitbit)

## New Ideas & Architectural Design
After watching a great ElixirConf talk "Selling Food With Elixir" by Chris Bell,
I really thought about the design paradigms that I've been using with this
website...

<iframe width="560" height="315" src="https://www.youtube.com/embed/fkDhU-2NWJ8" frameborder="0" allowfullscreen></iframe>

#### Elixir Design Principals
1. Phoenix is not your application.
1. Embrace state outside of the database.
1. If it's concurrent, extract it into an OTP application.
1. (Don't just) Let it crash.

#### Tips for next time
1. Feed work, don't read work.
1. Start with an umbrella app
1. Don't use heroku?


... This website was starting to live and grow under the `lib` directory. I
realized I was creating the same ol' Ruby on Rails `lib` directory bloat that
happens with many Ruby on Rails monoliths.  The blog of my website was using OTP
but also living in `lib`.

## Pull out an umbrella... app
One of the "Tips for next time" from Chris Bell's talk was to "Start with an
umbrella app". Too late for me to start with an umbrella app, but it is never
too late to convert to one!

#### Steps to convert the existing phoenix app into an umbrella app
1. `mv phoenix_app web_app` - Rename the phoenix app directory to something new, i.e. web_app
1. `mix new <previous app name> --umbrella` - Create the umbrella app with the name of the original app
1. `cp -r <path phoenix app> <previous app name>/apps/` - Copy the original phoenix app into the app directory of the umbrella app
1. Add paths to phoenix app `mix.exs`
    ```
    def project do
       [app: :web_app,
        version: "0.0.1",
        build_path: "../../_build",
        config_path: "../../config/config.exs",
        deps_path: "../../deps",
        lockfile: "../../mix.lock",
        elixir: "~> 1.4",
        elixirc_paths: elixirc_paths(Mix.env),
        ...
    ```
1. Update paths in phoenix app's `package.json`
    ```
    "dependencies": {
      "phoenix": "file:../../deps/phoenix",
      "phoenix_html": "file:../../deps/phoenix_html"
    },
    ```
1. Update the the namespaces in the Phoenix app
1. `mix deps.get` - Get dependencies for new umbrella `mix.lock`
1. Ship it!
    ![Ship it squirrel](https://img.memesuper.com/502e486a4d1c8acc0f0e00682ee95bd9_service-advisor-wrote-word-for-word-what-the-customer-said-squirrel-in-armor-meme_364-393.jpeg){:width="100px"}
1. ** If using heroku, add `phoenix_static_buildpack.config` file to root of the
umbrella, with the path to the phoenix app `phoenix_relative_path="apps/web_app"`

[source](https://gist.github.com/emilsoman/9bdabbfe873ef28358d83eaa11d45024)

#### Move OTP Blog under apps/
My next app that needs to move under the umbrella that was still living in the
phoenix lib directory was a blog OTP app.
1. `cd apps` - Change the apps directory of the umbrella
1. `mix new blog --sup` - Create a new app Blog with a supervisor
1. Copy blog.ex and blog.exs files to new app
1. Update namespaces
1. Add blog specific dependencies to the new app's `mix.exs`
    ```
    defp deps do
      [{:earmark, "~> 1.2"},
       {:yamerl, "~> 0.4.0"}]
    end
    ```
1. Remove unneeded dependencies from phoenix app
1. Declare the blog app as a dependency of the phoenix app
    ```
    def application do
      [mod: {WebApp, []},
       applications: [:phoenix, :phoenix_html, :cowboy, :logger,
        :gettext, :blog, ...]]
    end

    defp deps do
      [{:phoenix, "~> 1.2.2"},
       {:phoenix_pubsub, "~> 1.0"},
       {:phoenix_html, "~> 2.6"},
       {:phoenix_live_reload, "~> 1.0", only: :dev},
       {:gettext, "~> 0.13"},
       {:cowboy, "~> 1.1"},
       {:blog, in_umbrella: true}
       ...
    ```

## You down with OTP, yeah you know me!
OTP (Open Telecom Platform) is one of Elixir/Erlang's features that a new
rubyist convert, like myself, might not pay attention to at first. OTP is an
important feature for building a distributed concurrent system. GerServer
(generic server process) is provides an easy interface for building out an
isolated running process can handle message passing as well as state. GerServer
processes also hook into Supervision trees with ease.

Each GenServer will linking, initializing state & possibly handling messaging
passing.

To refactor the Fitbit app into a GenServer app:
1. `cd apps` - Change the apps directory of the umbrella
1. `mix new fitbit --sup` - Create a new app Fitbit with supervisor
1. Copy code that was umbrella app lib to fitbit app lib
1. Start with GenServer in Fitbit.ex
    ```
    defmodule Fitbit do
      use GenServer
    end
    ```
1. Add `start_link` to Fitbit
    ```
    def start_link do
      GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
    end
    ```
1. Add `init` to Fitbit, with no state
    ```
    def init(:ok) do
      {:ok, nil}
    end
    ```
1. Implement Server handle_calls for Fitbit API calls
    ```
    def handle_call({:user_profile}, _from, _state) do
      {:reply, {:ok, Fitbit.User.profile()}, nil}
    end

    def handle_call({:user_badges}, _from, _state) do
      {:reply, {:ok, Fitbit.Badge.all_grouped()}, nil}
    end

    def handle_call({:lifetime_stats}, _from, _state) do
      {:reply, {:ok, Fitbit.Lifetime.stats()}, nil}
    end
    ```
1. Implement Client functions for Fitbit API calls
    ```
    def user_profile() do
      GenServer.call(__MODULE__, {:user_profile})
    end

    def user_badges() do
      GenServer.call(__MODULE__, {:user_badges})
    end

    def lifetime_stats() do
      GenServer.call(__MODULE__, {:lifetime_stats})
    end
    ```







## Conclusions
I'm going to strive to create Elixir applications that utilize all the great
features of Elixir/Erlang.  I will also try to not fall into Ruby on Rails
pattern mistakes. My code will be better organized, "supervised", and

### Ideas for Part 2.0
Rate limit / cache calls to Fitbit using an ETS table

### Idea for Part 3.0
Integrate with [Fitbit's subscription notifications](https://dev.fitbit.com/docs/subscriptions/#overview).
Using Phoenix's channel, I could update the step count on the website in real
time as I sync my steps to Fitbit and they send update notifications to the
site.

### Questions or Comments?
Hit me up on twitter [@5280code](https://twitter.com/5280code)!
