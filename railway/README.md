# Supabase Self-Hosted on Railway

This repo holds only the selfhost part: the official docker/ recipe plus the railway/ template adaptation. The docker/ files were extracted from supabase/supabase at commit e6e5c5626470976cad4e1287375347214178fbbc.

Your own app backend, in one click. No Supabase Cloud account
needed, no keys to generate by hand, no server to manage.

## What it is, in plain words

Supabase gives your app everything it needs on the server side:

- A database to store your data, with an instant API to read
  and write it
- Login and signup for your users, with passwords and email
- File storage for uploads like images and documents
- Live updates, so screens refresh when data changes
- Small server functions for custom logic
- A dashboard called Studio to see and manage everything

This template installs the full official Supabase stack on
Railway, wired together and ready to use.

## Deploy

Press deploy. That is the whole setup. Nothing is asked of
you at deploy time: every password and secret is generated
for you, and the API keys are derived automatically when each
service starts.

Wait until all services show healthy. The database takes a
few minutes on the very first boot. Services may restart once
or twice while the database initializes. That is normal.

## After deploy, in order

1. Open the Gateway service's public domain in Railway. That
   is your Supabase URL. Use it everywhere an app asks for a
   Supabase URL.
2. Log in to the dashboard with the dashboard username
   (supabase) and the dashboard password, which you find in
   the Gateway service's Variables tab in Railway.
3. Get your keys in Studio: open Project Settings, then API.
   You need the anon key for your app. The service role key
   is secret and stays on the server side only, never in app
   code or a web page.
4. You can also find the anon key in the Gateway service's
   deploy log, printed when Envoy starts.

## Connect your app

Use the gateway URL as your Supabase URL and the anon key
from Studio:

```js
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://your-gateway-domain.up.railway.app',
  'your-anon-key'
)
```

## What runs inside

Only the gateway is public. Everything else talks to it over
Railway's private network.

- Gateway: the front door. Routes every request to the right
  service and protects the dashboard with a login.
- Postgres: your database. Data lives on a persistent volume.
- Studio: the dashboard, at the gateway address, behind login.
- Auth: signup, login, passwords, and login tokens.
- REST: the instant API over your database tables.
- Realtime: live updates, chat style features, presence.
- Storage: file uploads, stored in a Railway Bucket.
- Imgproxy: image resizing for stored images.
- Meta: the schema API Studio uses to manage tables.
- Functions: your server functions, including the hello
  example at /functions/v1/hello.
- Supavisor: a connection pooler for the database.

## Email and signup

Signup works straight away: new users are confirmed
automatically, so you do not need an email server to get
started. For a real product, add your SMTP details to the
Auth service and turn mailer autoconfirm off, so new users
confirm by email like normal.

Also change the Auth service's site URL to your app's URL
once your app is live, so auth emails and redirects point
at your app instead of the gateway address.

## Costs, honestly

This runs 11 services plus a bucket, not one. It will use
more Railway usage than a single database template. Deploy
it, watch one full day of usage in the Railway dashboard,
then decide if the cost fits. Do not judge it from the
first hour.

## What is not included

Logs and analytics services, SMTP email sending, custom
domain setup, and backups. Back up by snapshotting the
Postgres volume or scheduling database dumps.

## Honest scope

Verified before publish: the template definition parses,
every variable referenced exists, every image tag matches
the official stack, no real secrets in this repo, and the
gateway key derivation and config generation were run
locally against the official Envoy templates (see
docs/static-verification-2026-11-03.md).

Not yet tested on a live Railway deploy: the first real
deploy, the storage bucket connection details, the gateway
port behavior, the pooler connection URL, image
transformation, and the first day cost. Those checks happen
on the first live deploy, and this page will be updated
with the results.

## Upgrades

Image tags follow the official Supabase stack at the time
this template was built. To upgrade, compare the next
official self-hosted release, update the tags here and in
railway-template.json together, and apply any config
changes the release notes list. Never change the database
password, the JWT secret, or the encryption keys after the
first deploy unless you follow the upstream rotation guides.
