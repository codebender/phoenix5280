---
title: Integrating with Fitbit - Part 1
created_at: 2017-04-28
intro: Integrating with Fitbit's API in Elixir. I've done it many times in ruby, node, and go. Time for a new language!
---

![Fitbit](https://s2.q4cdn.com/857130097/files/doc_downloads/Alta/Product/Fitbit-Family.jpg){:height="450px" width="100%"}



#### TL;DR - [My Fitbit Stats Page](/fitbit)



## The MVP
In the past, I've integrated with Fitbit using Ruby to show my daily stats like
number of steps and even hours of sleep. It made sense to replicate what I've
done in the past, only in Elixir this time. I only want to show my stats, so I
don't have to mess with OAuth2 handshaking.

Fitbit has added a new
[Lifetime Stats endpoint](https://dev.fitbit.com/docs/activity/#get-lifetime-stats)
which looks includes an interesting set of data. They provide the best single
day stats for number of steps, floors climbed and distance. Plus I can show the
"lifetime" (Fitbit membership lifetime) aggregate of those stats.

Fitbit also introduced a
[User Badges endpoint](https://dev.fitbit.com/docs/user/#get-badges). This
dataset includes all my earned badges.  Fitbit has different categories for the
badges that could be grouped together as well as the date the badge was
achieved.

## What exists out there for Elixir
When searching the vast open source ocean that is Github I found
[https://github.com/trestrantham/fitbit](https://github.com/trestrantham/fitbit).
It was a pretty good start of a Fitbit API wrapper. It has some functionality
for fetching account info and badges, but it is missing the lifetime stats...
For part 1 I'm going to borrow what I want and throw away what I don't need. One
thing I like about this design, is that it allows for more endpoints to easily
be added. Each new resource just needs to call the following method:

```
def user_request(method, endpoint, token \\ "", body \\ "") do
  endpoint = "1/user/-/" <> endpoint

  api_request(method, endpoint, body, :token, token)
end
```
So for the new Lifetime stats all that is needed is:
```
case Fitbit.user_request(:get, "activities", user_token) do
  {:ok, body} ->
    body |> ...
  error ->
    ...
end
```

## Fitbit Handshaking
I started by generating an access token for my Fitbit user. In order to do this,
I first had to [create and register an app in the Fitbit ecosystem](https://dev.fitbit.com/apps/new).
Since I'm only using this app to access my own data, I set the "OAuth 2.0
Application Type" to "Personal". This will allow me to access intraday time
series data as needed in the future. I also set the app's callback URL to
`http://localhost:9292`, this is part of the auth token generation flow.  To do
the actual OAuth2 handshake process, I used the [omniauth-fitbit-oauth2 ruby gem](https://github.com/codebender/omniauth-fitbit-oauth2)
by setting up the example [small Ruby sinatra app](https://github.com/codebender/omniauth-fitbit-oauth2/tree/master/example).
I spun up the app run with: `FITBIT_CLIENT_ID=<Fitbit client ID HERE> FITBIT_CLIENT_SECRET=<Fitbit client secret HERE> rackup`
Then visited [http://localhost:9292](http://localhost:9292) in my browser to
start the auth flow. I saved the access token that was generated to a
dev.secret.exs file. To double check that my token was valid, I did a quick curl
command using it: `curl -i -H "Authorization: Bearer <Access Token HERE>" https://api.fitbit.com/1/user/-/profile.json` Great Success!
![Great Success!](https://eserioblog.files.wordpress.com/2014/02/borat.jpg)


## On to the Elixir!
Initially I copied in the parts of the [aforementioned "fitbit" hex package](https://github.com/trestrantham/fitbit).
I brought in the main module that makes all the requests to Fitbit.  The code is
straight forward and easily allows for more endpoints and resources to be added
to the library.
[See the code here](https://github.com/codebender/phoenix5280/blob/47f33b55ab5f2659ad586f15b9ca042afd58d222/lib/phoenix5280/fitbit.ex)


Next I brought in the User resource.  This resource provides the account profile
information, like when I joined Fitbit and other basic account information:
```
def profile(user_token) do
  case Fitbit.user_request(:get, "profile", user_token) do
    {:ok, body} ->
      body["user"] |> parse_user
    error ->
      error
  end
end
```
I separated the user badges into its own resource. I also added some logic to
parse out the fields I care about.  
```
def all(user_token) do
  case Fitbit.user_request(:get, "badges", user_token) do
    {:ok, body} ->
      body["badges"] |> parse_badges
    error ->
      error
  end
end

defp parse_badges(badges) do
  Enum.map(badges, fn(badge) ->
    %Web5280.Fitbit.Badge{
      category: badge["category"],
      name: badge["shortName"],
      image_url: badge["image125px"],
      times_achieved: badge["timesAchieved"],
      description: badge["description"],
      value: badge["value"]
    }
  end)
end
```
I also wanted the badges to be grouped by the badge category, i.e (Daily Steps,
Lifetime Distance), hence a method to group the badges.
```
def all_grouped(user_token) do
  all(user_token)
  |> Enum.sort_by(fn x -> x.value end)
  |> Enum.group_by(fn x -> x.category end)
end
```


The final resource that I integrated was the lifetime stats.  I created those in
a new module and parsed out the complex JSON that Fitbit returns.
```
def stats(user_token) do
  case Fitbit.user_request(:get, "activities", user_token) do
    {:ok, body} ->
      body |> parse_lifetime_stats
    error ->
      error
  end
end

defp parse_lifetime_stats(lifetime_stats) do
  %Web5280.Fitbit.Lifetime{
    best_steps: Utils.delimit(lifetime_stats["best"]["total"]["steps"]["value"], 0),
    best_steps_date: Utils.display_date(lifetime_stats["best"]["total"]["steps"]["date"]),
    best_distance: Utils.delimit(lifetime_stats["best"]["total"]["distance"]["value"], 2),
    best_distance_date: Utils.display_date(lifetime_stats["best"]["total"]["distance"]["date"]),
    best_floors: Utils.delimit(lifetime_stats["best"]["total"]["floors"]["value"], 0),
    best_floors_date: Utils.display_date(lifetime_stats["best"]["total"]["floors"]["date"]),
    total_steps: Utils.delimit(lifetime_stats["lifetime"]["total"]["steps"], 0),
    total_distance: Utils.delimit(lifetime_stats["lifetime"]["total"]["distance"], 2),
    total_floors: Utils.delimit(lifetime_stats["lifetime"]["total"]["floors"], 0),
  }
end
```
Next I hooked everything up everything to a fitbit controller and template.  For
this prototype I was happy with the simplest solution, not worried about
performance just yet.

```
defmodule Web5280.FitbitController do
  use Web5280.Web, :controller

  alias Web5280.Fitbit

  def show(conn, _params) do
    user = Fitbit.User.profile(Fitbit.token)
    badges = Fitbit.Badge.all_grouped(Fitbit.token)
    lifetime = Fitbit.Lifetime.stats(Fitbit.token)

    render(conn, "show.html", user: user, badges: badges, lifetime: lifetime)
  end
end
```

The [template can be viewed here](https://github.com/codebender/phoenix5280/blob/47f33b55ab5f2659ad586f15b9ca042afd58d222/web/templates/fitbit/show.html.eex)


## Conclusions
The integration was pretty straight forward in the end.  Using the existing
elixir hex helped with the initial bootstrapping of the feature. There is a lot
of room for refactoring and optimization.

![MVP](http://www.varteq.com/wp-content/uploads/2017/03/MVP.png)


## Ideas for Part 2
- Move Fitbit Integration to an OTP Application
- Rate limit / cache calls to Fitbit using an ETS table

## Idea for Part 3
Integrate with [Fitbit's subscription notifications](https://dev.fitbit.com/docs/subscriptions/#overview).
Using Phoenix's channel, I could update the step count on the website in real
time as I sync my steps to Fitbit and they send update notifications to the
site.

### Questions or Comments?
Hit me up on twitter [@5280code](https://twitter.com/5280code)!
