# Startup Guide
---------------

- [Install **rbenv**](https://github.com/rbenv/rbenv#installation) (or **rvm** but we're assuming **rbenv** for the sake of the guide)

- Run `ruby-build` (bundled with **rbenv**)

- Initialize **rbenv**: `rbenv init` then follow the directions it outputs. It will look something like:

```
    # Load rbenv automatically by appending
    # the following to ~/.zshrc:

    eval "$(rbenv init -)"
```

- Install **ruby** 2.5.1: `rbenv install 2.5.1`. This could take awhile.

- Update **rbenv**'s shims: `rbenv rehash`

- Install **rails**: `gem install rails`

- Install the **bundler**: `gem install bundler`

- You may need to install **Xcode** command line tools (`xcode-select --install`)

- Install **mongodb**: `brew install mongodb`. You can choose to run **mongodb** as a background service with `brew services start mongodb`

- Make the database directory: ``sudo mkdir -p /data/db && sudo chown -R `id -un` /data/db``

- Install **yarn**: `npm install -g yarn` (this assumes you have **node** and **npm** installed)

- Install the **node** packages: `yarn`

- Install the **ruby** packages: `bundle install`

- Start the **mongodb** database: `mongod`. If you ran `mongodb` through brew services, you can skip this step.

- In a separate shell instance, create and setup the database: `rake db:create && rake db:setup`

- Start the **rails** server: `rails s`, or run all the dev processes in one instance with `foreman start -p 3000`.

- If you don't like **foreman**'s output (for example, it doesn't play nice with pry...) consider running `ruby ./bin/webpack-dev-server` and `bundle exec guard` in separate instances.


# Workflow

-----------

- Make sure your packages are updated: `yarn` and `bundle install`

- Start the **mongodb** database: `mongod`. you can skip this if you have **mongodb** running as a background service (`brew services start mongodb`)

- In a new instance, setup database: `rake db:setup && rake db:create_indexes`

- Start the **rails** server: `rails s`, or start **rails**, **guard**, and **webpack-dev-server** in one instance: `foreman start -p 3000`

- If you don't like **foreman**'s output (for example, it doesn't play nice with pry...) consider running `ruby ./bin/webpack-dev-server` and `bundle exec guard` in separate instances
